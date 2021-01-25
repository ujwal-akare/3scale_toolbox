## Import API definition to 3scale from OpenAPI definition

Features:

* OpenAPI __2.0__ specification (f.k.a. __swagger__)
* OpenAPI __3.0.2__ specification
  * Limitations:
    * Only first `server.url` element in `servers` list parsed as private url. As OpenAPI `basePath` property, `server.url` element's path component will be used.
    * Toolbox will not parse servers in path item or operation objects.
    * Supported security schemes: apiKey, oauth2 (any flow type).
    * Multiple flows in security scheme object not supported.
* Update existing product or create a new one. Product's `system_name` can be passed as option parameter and defaults to *info.title* field from openapi spec.
* Create methods in the 'Definition' section. Method names are taken from `operation.operationId` field.
* Create ActiveDocs.
* Set product integration settings based on openapi spec.
  * Mapping Rules
    * All existing *mapping rules* are deleted before importing new API definition. Methods not deleted if exist before running the command.
    * Create mapping rules and show them under `API > Integration`.
    * Applied strict matching on mapping rule patterns. Prefix matching can be applied with command flat `--prefix-matching`.
  * Authentication settings
    * Just one top level security requirement supported. Operation level security requirements not supported.
    * Supported security schemes: apiKey, oauth2 (any flow type).
  * Policies
    * When there is no security requirement spec, the product is considered as an "Open API". `default_credentials` policy will be added (also called as `anonymous_policy`). `default_credentials` policy will be configured with userkey provided in optional parameter `--default-credentials-userkey`.
    * RH-SSO/Keycloak role check policy set for oauth2 security requirements.
    * URL rewriting policy set when public and private base paths do not match.
  * Deployment mode
    * When `--production-public-base-url` or `--staging-public-base-url` (or both) option params are provided, implicitly the customer is asking for "APIcast self-managed" deployment mode. Otherwise, default deployment mode will be set, that is, "APIcast 3scale managed".
* OpenAPI Specification JSON Schema validation (3.0.2 and 2.0). Can be skipped with command flag `--skip-openapi-validation`.
* OpenAPI definition resource can be provided by one of the following channels:
  * *Filename* in the available path.
  * *URL* format (supported schemes are `http` and `https`). Toolbox will try to download from a given address.
  * Read from *stdin* standard input stream.

### Usage

```shell
NAME
    openapi - Import API defintion in OpenAPI specification from a local file or URL

USAGE
    3scale import openapi [opts] -d <destination>
    <spec> (/path/to/your/spec/file.[json|yaml|yml] OR
    http[s]://domain/resource/path.[json|yaml|yml])

DESCRIPTION
    Using an API definition format like OpenAPI, import to your 3scale API
    directly from a local OpenAPI spec compliant file or a remote URL

OPTIONS
       --activedocs-hidden                        Create ActiveDocs in hidden
                                                  state
       --backend-api-host-header=<value>          Custom host header sent by
                                                  the API gateway to the
                                                  backend API
       --backend-api-secret-token=<value>         Custom secret token sent by
                                                  the API gateway to the
                                                  backend API
    -d --destination=<value>                      3scale target instance.
                                                  Format:
                                                  "http[s]://<authentication>@3scale_domain"
       --default-credentials-userkey=<value>      Default credentials policy
                                                  userkey
       --oidc-issuer-endpoint=<value>             OIDC Issuer Endpoint
       --oidc-issuer-type=<value>                 OIDC Issuer Type (rest,
                                                  keycloak)
       --override-private-base-url=<value>        Custom private base URL
       --override-private-basepath=<value>        Override the basepath for
                                                  the private URLs
       --override-public-basepath=<value>         Override the basepath for
                                                  the public URLs
       --prefix-matching                          Use prefix matching instead
                                                  of strict matching on
                                                  mapping rules derived from
                                                  openapi operations
       --production-public-base-url=<value>       Custom public production
                                                  URL
       --skip-openapi-validation                  Skip OpenAPI schema
                                                  validation
       --staging-public-base-url=<value>          Custom public staging URL
    -t --target_system_name=<value>               Target system name
```

### OpenAPI definition from filename in path

Allowed formats are `json` and `yaml`. The format is automatically detected from filename __extension__.

```shell
$ 3scale import openapi -d <destination> /path/to/your/spec/file.[json|yaml|yml]
```

### OpenAPI definition from URI

Allowed formats are `json` and `yaml`. The format is automatically detected from URL's path __extension__.

```shell
$ 3scale import openapi -d <destination> http[s]://domain/resource/path.[json|yaml|yml]
```

### OpenAPI definition from stdin

Command line parameter for the openapi resource is `-`.

Allowed formats are `json` and `yaml`. The format is automatically detected internally with parsers.

```shell
$ tool_to_read_openapi_from_source | 3scale import openapi -d <destination> -
```
