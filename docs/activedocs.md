## ActiveDocs

* [Create new activedocs](#create)
* [Apply activedocs](#apply)
* [List activedocs](#list)
* [Delete activedocs](#delete)

### Create

* Creates a new activedocs
* activedocs name is required. `system-name` can be override with optional parameter.
* The swagger spec for the ActiveDocs is required. This is controlled with the
  positional parameter `spec`. It can be one of the following values:
  * *Filename* in the available path.
  * *URL* format (supported schemes are `http` and `https`). Toolbox will try to download content from given address.
  * Read from *stdin* standard input stream. This is controlled by setting
    the `-` value
* This is not idempotent command. If activedocs with the same name already exists, command will fail.
* Several other options can be set. Check `usage`

```shell
NAME
    create - Create an ActiveDocs

USAGE
    3scale activedocs create <remote>
    <activedocs-name> <spec>

DESCRIPTION
    Create an ActiveDocs

OPTIONS
    -d --description=<value>           Specify the description of the
                                       ActiveDocs
    -i --service-id=<value>            Specify the Service ID associated to
                                       the ActiveDocs
    -o --output=<value>                Output format. One of: json|yaml
    -p --published                     Specify it to publish the ActiveDoc on
                                       the Developer Portal. Otherwise it
                                       will be hidden
    -s --system-name=<value>           Specify the system-name of the
                                       ActiveDocs
       --skip-swagger-validations      Specify it to skip validation of the
                                       Swagger specification

OPTIONS FOR ACTIVEDOCS
    -c --config-file=<value>           3scale toolbox configuration file
                                       (default:
                                       $HOME/.3scalerc.yaml)
    -h --help                          show help for this command
    -k --insecure                      Proceed and operate even for server
                                       connections otherwise considered
                                       insecure
    -v --version                       Prints the version of this command
       --verbose                       Verbose mode
```


### Apply

* Update existing activedocs. Create new one if it does not exist.
* `activedocs_id_or_system_name` positional argument is an activedocs reference.
   It can be either activedocs `id`, or activedocs `system_name`.
   Toolbox will figure it out.
* Update to `published=true` activedocs by `--publish` flag.
* Update to `published=false` method by `--hide` flag.
* *The `--openapi-spec` flag is mandatory when the specified activedocs
   is applied the first time. Otherwise an error will be returned*
* Several other options can be set. Check `usage`

```shell
NAME
    apply - Update activedocs

USAGE
    3scale activedocs apply <remote>
    <activedocs_id_or_system_name>

DESCRIPTION
    Create or update an ActiveDocs

OPTIONS
    -d --description=<value>                   Specify the description of the
                                               ActiveDocs
       --hide                                  Specify it to hide the
                                               ActiveDocs on the Developer
                                               Portal
    -i --service-id=<value>                    Specify the Service ID
                                               associated to the ActiveDocs
    -o --output=<value>                        Output format. One of:
                                               json|yaml
       --openapi-spec=<value>                  Specify the swagger spec. Can
                                               be a file, an URL or '-' to
                                               read from stdin. This option
                                               is mandatory when applying the
                                               ActiveDoc for the first time
    -p --publish                               Specify it to publish the
                                               ActiveDocs on the Developer
                                               Portal. Otherwise it will be
                                               hidden
    -s --name=<value>                          Specify the name of the
                                               ActiveDocs
       --skip-swagger-validations=<value>      Skip validation of the Swagger
                                               specification. true or false

OPTIONS FOR ACTIVEDOCS
    -c --config-file=<value>           3scale toolbox configuration file
                                       (default:
                                       $HOME/.3scalerc.yaml)
    -h --help                          show help for this command
    -k --insecure                      Proceed and operate even for server
                                       connections otherwise considered
                                       insecure
    -v --version                       Prints the version of this command
       --verbose                       Verbose mode
```

### List

```shell
NAME
    list - List ActiveDocs

USAGE
    3scale activedocs list <remote>

DESCRIPTION
    List all defined ActiveDocs

OPTIONS
    -o --output=<value>           Output format. One of: json|yaml
    -s --service-ref=<value>      Filter the ActiveDocs by Service reference

OPTIONS FOR ACTIVEDOCS
    -c --config-file=<value>      3scale toolbox configuration file (default:
                                  $HOME/.3scalerc.yaml)
    -h --help                     show help for this command
    -k --insecure                 Proceed and operate even for server
                                  connections otherwise considered insecure
    -v --version                  Prints the version of this command
       --verbose                  Verbose mode
```

### Delete

```shell
NAME
    delete - Delete an ActiveDocs

USAGE
    3scale activedocs delete <remote>
    <activedocs-id_or-system-name>

DESCRIPTION
    Remove an ActiveDocs

OPTIONS FOR ACTIVEDOCS
    -c --config-file=<value>      3scale toolbox configuration file (default:
                                  $HOME/.3scalerc.yaml)
    -h --help                     show help for this command
    -k --insecure                 Proceed and operate even for server
                                  connections otherwise considered insecure
    -v --version                  Prints the version of this command
       --verbose                  Verbose mode
```
