package holos

// #MeshConfig provides the istio mesh config in the Output field.
#MeshConfig: {
	Output: {
		accessLogEncoding: string | *"JSON"
		accessLogFile:     string | *"/dev/stdout"
		defaultConfig: {
			discoveryAddress: string | *"istiod.istio-system.svc:15012"
			tracing: zipkin: address: string | *"zipkin.istio-system:9411"
		}
		defaultProviders: metrics: [...string] | *["prometheus"]
		enablePrometheusMerge: false | *true
		rootNamespace:         string | *"istio-system"
		trustDomain:           string | *"cluster.local"
		// NOTE: Use a Pod annotation to configure proxyProtocol, the proxyProtocol
		// field here has no effect when tested on istio 1.22.0. Refer to the
		// default Gateway in the gateways component for where the proxyProtocol is
		// configured.
		gatewayTopology: numTrustedProxies: 2
		extensionProviders: []
	}
}

// #ExtAuthzProxy defines the provider configuration for an istio external authorization auth proxy.
#ExtAuthzProxy: {
	name: string
	envoyExtAuthzHttp: {
		headersToDownstreamOnDeny: [
			"content-type",
			"set-cookie",
		]
		headersToUpstreamOnAllow: [
			"authorization",
			"path",
			"x-oidc-id-token",
		]
		includeAdditionalHeadersInCheck: "X-Auth-Request-Redirect": "%REQ(x-forwarded-proto)%://%REQ(:authority)%%REQ(:path)%%REQ(:query)%"
		includeRequestHeadersInCheck: [
			"authorization",
			"cookie",
			"x-forwarded-for",
		]
		port:    4180
		service: string
	}
}
