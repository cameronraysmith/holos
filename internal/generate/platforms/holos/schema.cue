package holos

import (
	"encoding/json"
	v1 "github.com/holos-run/holos/api/v1alpha1"
	dto "github.com/holos-run/holos/service/gen/holos/object/v1alpha1:object"
	corev1 "k8s.io/api/core/v1"
	certv1 "cert-manager.io/certificate/v1"
	es "external-secrets.io/externalsecret/v1beta1"
)

// _PlatformConfig represents all of the data passed from holos to cue, used to
// carry the platform and project models.
_PlatformConfig:     dto.#PlatformConfig & json.Unmarshal(_PlatformConfigJSON)
_PlatformConfigJSON: string | *"{}" @tag(platform_config, type=string)

// #Cluster represents a single cluster in the platform.
#Cluster: name: string

// _Fleets represents all the fleets in the platform.
_Fleets: #Fleets
// #Fleets defines the shape of _Fleets
#Fleets: [Name=string]: #Fleet & {name: Name}

// #Fleet represents a grouping of similar clusters.  A platform is usually
// composed of a workload fleet and a management fleet.
#Fleet: {
	name: string
	clusters: [Name=string]: #Cluster & {name: Name}
}

// _Platform represents and provides a platform to holos for rendering.
_Platform: #Platform & {
	Name:  string @tag(platform_name, type=string)
	Model: _PlatformConfig.platform_model
}
// #Platform defines the shape of _Platform.
#Platform: {
	Name: string | *"holos"

	// Components represent the platform components to render.
	Components: [string]: v1.#PlatformSpecComponent

	// Model represents the platform model from the web app form.
	Model: dto.#PlatformConfig.platform_model

	Output: v1.#Platform & {
		metadata: name: Name

		spec: {
			// model represents the web form values provided by the user.
			model: Model
			components: [for c in Components {c}]
		}
	}
}

// _Namespaces represents all managed namespaces in the platform.
_Namespaces: #Namespaces
// #Namespaces defines the shape of _Namespaces.
#Namespaces: {
	[Name=string]: corev1.#Namespace & {
		metadata: name: Name
	}
}

// _Certificates represents all managed public facing tls certificates in the
// platform.
_Certificates: #Certificates
// #Certificates defines the shape of _Certificates
#Certificates: {
	[Name=string]: certv1.#Certificate & {
		metadata: name: Name
	}
}

// _Projects represents holos projects in the platform.
_Projects: #Projects
// #Projects defines the shape of _Projects
#Projects: [Name=string]: #Project & {
	metadata: name: Name
}

// #Project defines the shape of one project.
#Project: {
	metadata: name: string

	spec: {
		// namespaces represents the namespaces associated with this project.
		namespaces: #Namespaces
		// certificates represents the public tls certs associated with this project.
		certificates: #Certificates
	}
}

// #IngressCertificate defines a certificate for use by the ingress gateway.
#IngressCertificate: certv1.#Certificate & {
	metadata: name:      string
	metadata: namespace: "istio-gateways"
	spec: {
		commonName: metadata.name
		dnsNames: [...string] | *[commonName]
		secretName: commonName
		issuerRef: kind: "ClusterIssuer"
		issuerRef: name: "letsencrypt"
	}
}

// #ExternalCert represents a tls Certificate managed in the management cluster and
// synced to the workload cluster using an ExternalSecret.
#ExternalCert: es.#ExternalSecret & {
	metadata: name:      string
	metadata: namespace: string | *"istio-gateways"
	spec: {
		target: name: metadata.name
		target: template: type: "kubernetes.io/tls"
		target: creationPolicy: "Owner"
		target: deletionPolicy: "Retain"
		dataFrom: [
			{
				extract: {
					key:                metadata.name
					conversionStrategy: "Default"
					decodingStrategy:   "None"
					metadataPolicy:     "None"
				}
			},
		]
		refreshInterval: string | *"1h"
		secretStoreRef: kind: "SecretStore"
		secretStoreRef: name: "default"
	}
}

// #IstioGatewaysNamespace represents the namespace where kubernetes Gateway API
// resources are deployed for istio.  This namespace was previously named
// "istio-ingress" when the istio Gateway api was used.
#IstioGatewaysNamespace: "istio-gateways"

// _AdminSelector represents the label selector for an admin service.  Used by
// Gateway API to grant HTTPRoute access to Namespace resources.
_AdminSelector: matchLabels: "holos.run/admin.grant": "true"
