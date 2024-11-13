package author

import (
	ks "sigs.k8s.io/kustomize/api/types"
	core "github.com/holos-run/holos/api/core/v1alpha5:core"
)

#Platform: {
	Name:       string | *"no-platform-name"
	Components: _
	Resource: core.#Platform & {
		metadata: name: Name
		spec: components: [for x in Components {x}]
	}
}

#KustomizeConfig: {
	CommonLabels: _
	Kustomization: ks.#Kustomization & {
		apiVersion: "kustomize.config.k8s.io/v1beta1"
		kind:       "Kustomization"
		_labels: commonLabels: {
			includeSelectors: false
			pairs:            CommonLabels
		}
		labels: [for x in _labels {x}]
	}
}

// Kustomize and Kubernetes are identical.

// https://holos.run/docs/next/api/author/#Kustomize
#Kustomize: #Kubernetes

// https://holos.run/docs/next/api/author/#Kubernetes
#Kubernetes: {
	Name:            _
	Path:            _
	Parameters:      _
	Resources:       _
	OutputBaseDir:   _
	KustomizeConfig: _

	Artifacts: {
		HolosComponent: {
			_path: string
			if OutputBaseDir == "" {
				_path: "components/\(Name)"
			}
			if OutputBaseDir != "" {
				_path: "\(OutputBaseDir)/components/\(Name)"
			}

			artifact: "\(_path)/\(Name).gen.yaml"
			let ResourcesOutput = "resources.gen.yaml"
			generators: [
				{
					kind:      "Resources"
					output:    ResourcesOutput
					resources: Resources
				},
				for x in KustomizeConfig.Files {
					kind:   "File"
					output: x.Source
					file: source: x.Source
				},
			]
			transformers: [
				core.#Transformer & {
					kind: "Kustomize"
					inputs: [for x in generators {x.output}]
					output: artifact
					kustomize: kustomization: KustomizeConfig.Kustomization & {
						resources: [
							ResourcesOutput,
							for x in KustomizeConfig.Files {x.Source},
							for x in KustomizeConfig.Resources {x.Source},
						]
					}
				},
			]
		}
	}

	BuildPlan: {
		metadata: name: Name
		spec: artifacts: [for x in Artifacts {x}]
		source: component: {
			name:       Name
			path:       Path
			parameters: Parameters
		}
	}
}

// https://holos.run/docs/next/api/author/#Helm
#Helm: {
	Name:            _
	Path:            _
	Parameters:      _
	Resources:       _
	OutputBaseDir:   _
	KustomizeConfig: _

	Chart: {
		name:    string | *Name
		release: string | *name
	}
	Values:       _
	EnableHooks:  _
	Namespace?:   _
	APIVersions?: _

	Artifacts: {
		HolosComponent: {
			_path: string
			if OutputBaseDir == "" {
				_path: "components/\(Name)"
			}
			if OutputBaseDir != "" {
				_path: "\(OutputBaseDir)/components/\(Name)"
			}

			artifact: "\(_path)/\(Name).gen.yaml"
			let HelmOutput = "helm.gen.yaml"
			let ResourcesOutput = "resources.gen.yaml"
			generators: [
				{
					kind:   "Helm"
					output: HelmOutput
					helm: core.#Helm & {
						chart:       Chart
						values:      Values
						enableHooks: EnableHooks
						if Namespace != _|_ {
							namespace: Namespace
						}
						if APIVersions != _|_ {
							apiVersions: APIVersions
						}
					}
				},
				{
					kind:      "Resources"
					output:    ResourcesOutput
					resources: Resources
				},
				for x in KustomizeConfig.Files {
					kind:   "File"
					output: x.Source
					file: source: x.Source
				},
			]
			transformers: [
				core.#Transformer & {
					kind: "Kustomize"
					inputs: [for x in generators {x.output}]
					output: artifact
					kustomize: kustomization: KustomizeConfig.Kustomization & {
						resources: [
							HelmOutput,
							ResourcesOutput,
							for x in KustomizeConfig.Files {x.Source},
							for x in KustomizeConfig.Resources {x.Source},
						]
					}
				},
			]
		}
	}

	BuildPlan: {
		metadata: name: Name
		spec: artifacts: [for x in Artifacts {x}]
		source: component: {
			name:       Name
			path:       Path
			parameters: Parameters
		}
	}
}
