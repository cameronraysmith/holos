// Package push pushes resources to the holos api server.
package push

import (
	"context"
	"fmt"
	"path/filepath"

	"cuelang.org/go/cue"
	"github.com/holos-run/holos/internal/errors"
	"github.com/holos-run/holos/internal/holos"
	object "github.com/holos-run/holos/service/gen/holos/object/v1alpha1"
	"google.golang.org/protobuf/encoding/protojson"
)

const APIVersion = "holos.run/v1alpha1"

// PlatformForm builds a json powered web form from CUE code.  The CUE code is
// expected to be derived from the code generated by the `holos generate
// platform` command.
func PlatformForm(ctx context.Context, name string) (*object.Form, error) {
	// build the form which always lives at ./forms/platform relative to the
	// platform root where platform.metadata.json is.
	instance, err := NewInstance(filepath.Join(name, "forms", "platform"))
	if err != nil {
		return nil, errors.Wrap(err)
	}

	root, err := instance.Value(ctx)
	if err != nil {
		return nil, errors.Wrap(err)
	}

	var tm holos.TypeMeta
	if err := root.Decode(&tm); err != nil {
		return nil, errors.Wrap(err)
	}
	if tm.Kind != "Form" {
		return nil, errors.Wrap(fmt.Errorf("want: Form have: %s", tm.Kind))
	}
	if tm.APIVersion != APIVersion {
		return nil, errors.Wrap(fmt.Errorf("want: %s have: %s", APIVersion, tm.APIVersion))
	}

	// Extract the protobuf field to use protojson instead of json to unmarshal
	// the value.
	vForm := root.LookupPath(cue.ParsePath("spec.form"))
	formData, err := vForm.MarshalJSON()
	if err != nil {
		return nil, errors.Wrap(err)
	}

	// Finally unmarshal the protobuf canonical json into the protobuf message.
	m := &object.Form{}
	if err := protojson.Unmarshal(formData, m); err != nil {
		return nil, errors.Wrap(err)
	}

	return m, nil
}
