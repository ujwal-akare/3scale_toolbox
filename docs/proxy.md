## Proxy Configuration

* [Deploy Proxy Configuration](#deploy)
* [Update Proxy Configuration](#update)
* [Show Proxy Configuration](#show)

### Deploy

```shell
NAME
    deploy - Promotes the APIcast configuration to the Staging Environment

USAGE
    3scale proxy deploy <remote> <service>

DESCRIPTION
    Promotes the APIcast configuration to the Staging Environment (Production
    Environment in case of Service Mesh).

OPTIONS
    -o --output=<value>           Output format. One of: json|yaml
```

### Update

Update APIcast configuration command. Only specified parameters will be updated.

Check out 3scale API docs (*https://tenant-admin.3scale.example.com/admin/api-docs*) **Proxy Update** doc
for a list of valid APIcast parameters.

Example:

```shel
3scale proxy update supertest api -p credentials_location=query -p error_status_auth_failed=500 -p 'error_auth_failed=Authentication failed oohhh'
```

```shell
NAME
    update - Update APIcast configuration

USAGE
    3scale proxy update <remote> <service>

DESCRIPTION
    Update APIcast configuration

OPTIONS
    -o --output=<value>           Output format. One of: json|yaml
    -p --param=<value>            APIcast configuration parameters. Format:
                                  [--param key=value]. Multiple options
                                  allowed.
```

### Show

```shell
NAME
    show - Fetch (undeployed) APIcast configuration

USAGE
    3scale proxy show <remote> <service>

DESCRIPTION
    Fetch (undeployed) APIcast configuration

OPTIONS
    -o --output=<value>           Output format. One of: json|yaml
```
