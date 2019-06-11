## Proxy Configuration

* [List Proxy Configurations](#list)
* [Show Proxy Configuration](#show)
* [Promote Proxy Configuration](#promote)

### List

```shell
NAME
    list - List Proxy Configurations

USAGE
    3scale proxy-config list <remote> <service>
    <environment>

DESCRIPTION
    List all defined Proxy Configurations

OPTIONS FOR PROXY-CONFIG
    -c --config-file=<value>      3scale toolbox configuration file (default:
                                  /home/msoriano/.3scalerc.yaml)
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
                                     version

OPTIONS FOR PROXY-CONFIG
    -c --config-file=<value>         3scale toolbox configuration file
                                     (default: /home/msoriano/.3scalerc.yaml)
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
                                  /home/msoriano/.3scalerc.yaml)
    -h --help                     show help for this command
    -k --insecure                 Proceed and operate even for server
                                  connections otherwise considered insecure
    -v --version                  Prints the version of this command
       --verbose                  Verbose mode
```