// Deprecated: move to the component and platform packages
// TODO(jjm): remove the builder package entirely.
package builder

import (
	"context"
	"fmt"
	"time"

	"github.com/holos-run/holos/internal/errors"
	"github.com/holos-run/holos/internal/holos"
	"github.com/holos-run/holos/internal/logger"
	"github.com/holos-run/holos/internal/platform/v1alpha5"
	"github.com/holos-run/holos/internal/platform/v1alpha6"
	"golang.org/x/sync/errgroup"
)

// PlatformOpts represents build options when processing the components in a
// platform.
type PlatformOpts struct {
	PerComponentFunc   func(context.Context, int, holos.Component) error
	ComponentSelectors holos.Selectors
	Concurrency        int
	InfoEnabled        bool
}

// Platform represents a common abstraction over different platform schema
// versions.
type Platform struct {
	holos.Platform
}

// Build calls [PlatformOpts] PerComponentFunc concurrently.
//
// Deprecated: use [platform.Platform.Build] instead.
func (p *Platform) Build(ctx context.Context, opts PlatformOpts) error {
	limit := max(opts.Concurrency, 1)
	parentStart := time.Now()
	components := p.Select(opts.ComponentSelectors...)
	total := len(components)

	g, ctx := errgroup.WithContext(ctx)
	// Limit the number of concurrent goroutines due to CUE memory usage concerns
	// while rendering components.  One more for the producer.
	g.SetLimit(limit + 1)
	// Spawn a producer because g.Go() blocks when the group limit is reached.
	g.Go(func() error {
		for idx := range components {
			select {
			case <-ctx.Done():
				return errors.Wrap(ctx.Err())
			default:
				// Capture idx to avoid issues with closure.  Fixed in Go 1.22.
				idx := idx
				component := components[idx]
				// Worker go routine. Blocks if limit has been reached.
				g.Go(func() error {
					select {
					case <-ctx.Done():
						return errors.Wrap(ctx.Err())
					default:
						start := time.Now()
						log := logger.FromContext(ctx).With("num", idx+1, "total", total)
						if err := opts.PerComponentFunc(ctx, idx, component); err != nil {
							return errors.Wrap(err)
						}
						duration := time.Since(start)
						msg := fmt.Sprintf("rendered %s in %s", component.Describe(), duration)
						if opts.InfoEnabled {
							log.InfoContext(ctx, msg, "duration", duration)
						} else {
							log.DebugContext(ctx, msg, "duration", duration)
						}
						return nil
					}
				})
			}
		}
		return nil
	})

	// Wait for completion and return the first error (if any)
	if err := g.Wait(); err != nil {
		return err
	}

	duration := time.Since(parentStart)
	msg := fmt.Sprintf("rendered platform in %s", duration)
	if opts.InfoEnabled {
		logger.FromContext(ctx).InfoContext(ctx, msg, "duration", duration)
	} else {
		logger.FromContext(ctx).DebugContext(ctx, msg, "duration", duration)
	}
	return nil
}

func LoadPlatform(i *Instance) (platform Platform, err error) {
	err = i.Discriminate(func(tm holos.TypeMeta) error {
		if tm.Kind != "Platform" {
			return errors.Format("unsupported kind: %s, want Platform", tm.Kind)
		}

		switch version := tm.APIVersion; version {
		case "v1alpha5":
			platform = Platform{&v1alpha5.Platform{}}
		case "v1alpha6":
			platform = Platform{&v1alpha6.Platform{}}
		default:
			return errors.Format("unsupported version: %s", version)
		}

		return nil
	})
	if err != nil {
		return platform, errors.Wrap(err)
	}

	// Get the holos: field value from cue.
	v, err := i.HolosValue()
	if err != nil {
		return platform, errors.Wrap(err)
	}

	// Load the platform from the cue value.
	if err := platform.Load(v); err != nil {
		return platform, errors.Wrap(err)
	}

	return platform, err
}
