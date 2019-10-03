## Import API definition to 3scale from OpenAPI definition

Features:

* OpenAPI __2.0__ specification (f.k.a. __swagger__)
* Update existing service or create a new one. Service's `system_name` can be passed as option parameter and defaults to *info.title* field from openapi spec.
* Create methods in the 'Definition' section. Method names are taken from `operation.operationId` field.
* Attach newly created methods to the *Hits* metric.
* All existing *mapping rules* are deleted before importing new API definition. Methods not deleted if exist before running the command.
* Create mapping rules and show them under `API > Integration`.
* Create ActiveDocs.
* OpenAPI Specification 2.0 JSON Schema validation. Can be skipped with command flag `--skip-openapi-validation`.
* OpenAPI definition resource can be provided by one of the following channels:
  * *Filename* in the available path.
  * *URL* format (supported schemes are `http` and `https`). Toolbox will try to download from given address.
  * Read from *stdin* standard input stream.
* Applied strict matching on mapping rule patterns
* When there is no security requirement in swagger spec, the service is considered as an "Open API".
Toolbox will then add `default_credentials` policy (also called as `anonymous_policy`) if not yet in policy chain (to be idempotent).
`default_credentials` policy will be configured with userkey provided in optional parameter `--default-credentials-userkey`.

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
    -d --destination=<value>                      3scale target instance.
                                                  Format:
                                                  "http[s]://<authentication>@3scale_domain"
       --default-credentials-userkey=<value>      Default credentials policy
                                                  userkey
       --oidc-issuer-endpoint=<value>             OIDC Issuer Endpoint
       --override-private-base-url=<value>        Custom private base URL
       --override-private-basepath=<value>        Override the basepath for
                                                  the private URLs
       --override-public-basepath=<value>         Override the basepath for
                                                  the public URLs
       --production-public-base-url=<value>       Custom public production
                                                  URL
       --skip-openapi-validation                  Skip OpenAPI schema
                                                  validation
       --staging-public-base-url=<value>          Custom public staging URL
    -t --target_system_name=<value>               Target system name
```

### OpenAPI definition from filename in path

Allowed formats are `json` and `yaml`. Format is automatically detected from filename __extension__.

```shell
$ 3scale import openapi -d <destination> /path/to/your/spec/file.[json|yaml|yml]
```

### OpenAPI definition from URI

Allowed formats are `json` and `yaml`. Format is automatically detected from URL's path __extension__.

```shell
$ 3scale import openapi -d <destination> http[s]://domain/resource/path.[json|yaml|yml]
```

### OpenAPI definition from stdin

Command line parameter for the openapi resource is `-`.

Allowed formats are `json` and `yaml`. Format is automatically detected internally with parsers.

```shell
$ tool_to_read_openapi_from_source | 3scale import openapi -d <destination> -
```
