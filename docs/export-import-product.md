## Export/Import Product

Common description:
* Export/Import a single product to/from yaml content.
* Limits defined in the application plans are included.
* Pricing rules defined in the application plans are included.
* Metrics/methods referenced by limits and pricing rules are included.
* Product can be referenced by `id` or `system_name`.
* Backends linked to the product are included. Backend metrics, methods and mapping rules are also included.
* Serialization format is:
  * [Product CRD](https://github.com/3scale/3scale-operator/blob/3scale-2.10.0-CR2/doc/product-reference.md) format for products
  * [Backend CRD](https://github.com/3scale/3scale-operator/blob/3scale-2.10.0-CR2/doc/backend-reference.md) format for backends

Specific to `export` command:
* Read only operation on remote product.
* Command `output` can be `stdout` or file. If not specified by `-f` option, by default, yaml content will be written on `stdout`.

Specific to `import` command:
* The command is idempotent. Can be run any number of time and the resulting 3scale configuration will remain the same. If there is an error during import process, it is safe to re-run the command.
* Command `input` content can be `stdin` or file. If not specified by `-f` option, by default, yaml content will be read from `stdin`.
* If the product cannot be found in the remote service, it will be created.
* Any metric or method from yaml content that cannot be found in the remote product or backend, will be created.
* The command will output a report with the imported items. Report example:

```yaml
---
api:
  product_id: 2555417888846
  backends:
    backend_01:
      backend_id: 73310
      missing_metrics_created: 1
      missing_methods_created: 1
      missing_mapping_rules_created: 1
    backend_02:
      backend_id: 73311
      missing_metrics_created: 0
      missing_methods_created: 2
      missing_mapping_rules_created: 1
  missing_methods_created: 1
  missing_metrics_created: 1
  missing_mapping_rules_created: 2
  missing_application_plans_created: 2
  application_plans:
    basic:
      application_plan_id: 2357356246461
      missing_limits_created: 7
      missing_pricing_rules_created: 7
    unlimited:
      application_plan_id: 2357356246462
      missing_limits_created: 1
      missing_pricing_rules_created: 0
```

### Export Product Usage

```shell
NAME
    export - Export product to serialized format

USAGE
    3scale product export [opts] <remote>
    <product>

DESCRIPTION
    This command serializes the referenced product and associated backends
    into a yaml format

OPTIONS
    -f --file=<value>             Write to file instead of stdout
```

### Import Product Usage

```shell
NAME
    import - Import product from serialized format

USAGE
    3scale product import [opts] <remote>

DESCRIPTION
    This command deserializes one product and associated backends

OPTIONS
    -f --file=<value>             Read from file instead of stdin
    -o --output=<value>           Output format. One of: json|yaml
```

### Export product 'petstore' to a file

```shell
$ 3scale product export -f product.yaml remote_name petstore
```

### Import product 'petstore' from a file

```shell
$ 3scale product import -f product.yaml remote_name
```

### Serialization example

```yaml
---
apiVersion: v1
kind: List
items:
- apiVersion: capabilities.3scale.net/v1beta1
  kind: Product
  metadata:
    annotations:
      3scale_toolbox_created_at: '2021-02-17T10:59:23Z'
      3scale_toolbox_version: 0.17.1
    name: api.xysnalcj
  spec:
    name: Default API
    systemName: api
    description: ''
    mappingRules:
    - httpMethod: GET
      pattern: "/v2"
      metricMethodRef: hits
      increment: 1
      last: false
    metrics:
      hits:
        friendlyName: Hits
        unit: hit
        description: Number of API hits
    methods:
      servicemethod01:
        friendlyName: servicemethod01
        description: ''
    policies:
    - name: apicast
      version: builtin
      configuration: {}
      enabled: true
    applicationPlans:
      basic:
        name: Basic
        appsRequireApproval: false
        trialPeriod: 0
        setupFee: 0.0
        custom: false
        state: published
        costMonth: 0.0
        pricingRules:
        - from: 1
          to: 1000
          pricePerUnit: 1.0
          metricMethodRef:
            systemName: hits
        limits:
        - period: hour
          value: 1222222
          metricMethodRef:
            systemName: hits
            backend: backend_01
    backendUsages:
      backend_01:
        path: "/v1/pets"
      backend_02:
        path: "/v1/cats"
    deployment:
      apicastSelfManaged:
        authentication:
          oidc:
            issuerType: rest
            issuerEndpoint: https://hello:test@example.com/auth/realms/3scale-api-consumers
            jwtClaimWithClientID: azp
            jwtClaimWithClientIDType: plain
            authenticationFlow:
              standardFlowEnabled: false
              implicitFlowEnabled: true
              serviceAccountsEnabled: false
              directAccessGrantsEnabled: true
            credentials: query
            security:
              hostHeader: ''
              secretToken: some_secret
            gatewayResponse:
              errorStatusAuthFailed: 403
              errorHeadersAuthFailed: text/plain; charset=us-ascii
              errorAuthFailed: Authentication failed
              errorStatusAuthMissing: 403
              errorHeadersAuthMissing: text/plain; charset=us-ascii
              errorAuthMissing: Authentication parameters missing
              errorStatusNoMatch: 404
              errorHeadersNoMatch: text/plain; charset=us-ascii
              errorNoMatch: No Mapping Rule matched
              errorStatusLimitsExceeded: 429
              errorHeadersLimitsExceeded: text/plain; charset=us-ascii
              errorLimitsExceeded: Usage limit exceeded
        stagingPublicBaseURL: http://staging.example.com:80
        productionPublicBaseURL: http://example.com:80
- apiVersion: capabilities.3scale.net/v1beta1
  kind: Backend
  metadata:
    annotations:
      3scale_toolbox_created_at: '2021-02-17T10:59:34Z'
      3scale_toolbox_version: 0.17.1
    name: backend.01.pcjwxbdu
  spec:
    name: Backend 01
    systemName: backend_01
    privateBaseURL: https://b1.example.com:443
    description: new desc
    mappingRules:
    - httpMethod: GET
      pattern: "/v1/pets"
      metricMethodRef: hits
      increment: 1
      last: false
    metrics:
      hits:
        friendlyName: Hits
        unit: hit
        description: Number of API hits
    methods:
      mybackendmethod01:
        friendlyName: mybackendmethod01
        description: ''
- apiVersion: capabilities.3scale.net/v1beta1
  kind: Backend
  metadata:
    annotations:
      3scale_toolbox_created_at: '2021-02-17T10:59:34Z'
      3scale_toolbox_version: 0.17.1
    name: backend.02.tiedgjsk
  spec:
    name: Backend 02
    systemName: backend_02
    privateBaseURL: https://b2.example.com:443
    description: ''
    mappingRules:
    - httpMethod: GET
      pattern: "/v1/cats"
      metricMethodRef: hits
      increment: 1
      last: false
    metrics:
      hits:
        friendlyName: Hits
        unit: hit
        description: Number of API hits
    methods:
      backend02_method01:
        friendlyName: backend02_method01
        description: ''
```
