## Proxy Configuration

* [List Proxy Configurations](#list)
* [Show Proxy Configuration](#show)
* [Promote Proxy Configuration](#promote)
* [Export Proxy Configuration](#export)
* [Deploy Proxy Configuration](#deploy)

### List

```shell
NAME
    list - List Proxy Configurations

USAGE
    3scale proxy-config list <remote> <service>
    <environment>

DESCRIPTION
    List all defined Proxy Configurations

OPTIONS
    -o --output=<value>           Output format. One of: json|yaml

OPTIONS FOR PROXY-CONFIG
    -c --config-file=<value>      3scale toolbox configuration file (default:
                                  $HOME/.3scalerc.yaml)
    -h --help                     show help for this command
    -k --insecure                 Proceed and operate even for server
                                  connections otherwise considered insecure
    -v --version                  Prints the version of this command
       --verbose                  Verbose mode
```

### Show

```shell
NAME
    show - Show Proxy Configuration

USAGE
    3scale proxy-config show <remote> <service>
    <environment>

DESCRIPTION
    Show a Proxy Configuration

OPTIONS
       --config-version=<value>      Specify the Proxy Configuration version.
                                     If not specified it gets the latest
                                     version (default: latest)
    -o --output=<value>              Output format. One of: json|yaml

OPTIONS FOR PROXY-CONFIG
    -c --config-file=<value>         3scale toolbox configuration file
                                     (default: $HOME/.3scalerc.yaml)
    -h --help                        show help for this command
    -k --insecure                    Proceed and operate even for server
                                     connections otherwise considered
                                     insecure
    -v --version                     Prints the version of this command
       --verbose                     Verbose mode
```

### Promote

```shell
NAME
    promote - Promote latest staging Proxy Configuration to the production environment

USAGE
    3scale proxy-config promote <remote> <service>

DESCRIPTION
    Promote latest staging Proxy Configuration to the production environment

OPTIONS FOR PROXY-CONFIG
    -c --config-file=<value>      3scale toolbox configuration file (default:
                                  $HOME/.3scalerc.yaml)
    -h --help                     show help for this command
    -k --insecure                 Proceed and operate even for server
                                  connections otherwise considered insecure
    -v --version                  Prints the version of this command
       --verbose                  Verbose mode
```

### Export

```shell
NAME
    export - Export proxy configuration for the entire provider account

USAGE
    3scale proxy-config export <remote>

DESCRIPTION
    Export proxy configuration for the entire provider account

    Can be used as 3scale apicast configuration file


    https://github.com/3scale/apicast/blob/master/doc/parameters.md#threescale_config_file

OPTIONS
       --environment=<value>      Gateway environment. Must be 'sandbox' or
                                  'production' (default: sandbox)
    -o --output=<value>           Output format. One of: json|yaml
```

### Deploy

```shell
NAME
    deploy - Promotes the APIcast configuration to the Staging Environment

USAGE
    3scale proxy-config deploy <remote> <service>

DESCRIPTION
    Promotes the APIcast configuration to the Staging Environment (Production
    Environment in case of Service Mesh).

OPTIONS
    -o --output=<value>           Output format. One of: json|yaml
```
