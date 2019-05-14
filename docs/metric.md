## Metric

* [Create new metric](#create)
* [Apply metric](#apply)
* [List metrics](#list)
* [Delete metric](#delete)

### Create

* Creates a new metric
* Only metric name is required. `system-name` can be override with optional parameter.
* `service` positional argument is a service reference. It can be either service `id`, or service `system_name`. Toolbox will figure it out.
* This is not idempotent command. If metric with the same name already exists, command will fail.
* Create a `disabled` metric by `--disabled` flag. By default, it will be `enabled`.
* Several other options can be set. Check `usage`

```shell
NAME
    create - create metric

USAGE
    3scale metrics create [opts] <remote>
    <service> <metric-name>

DESCRIPTION
    Create metric

OPTIONS
       --description=<value>      Metric description
       --disabled                 Disables this metric in all application
                                  plans
    -t --system-name=<value>      Application plan system name
       --unit=<value>             Metric unit. Default hit

OPTIONS FOR METRICS
    -c --config-file=<value>      3scale toolbox configuration file (default:
                                  $HOME/.3scalerc.yaml)
    -h --help                     show help for this command
    -k --insecure                 Proceed and operate even for server
                                  connections otherwise considered insecure
    -v --version                  Prints the version of this command
       --verbose                  Verbose mode
```

### Apply

* Update existing metric. Create new one if it does not exist.
* `service` positional argument is a service reference. It can be either service `id`, or service `system_name`. Toolbox will figure it out.
* `metric` positional argument is a metric reference. It can be either metric `id`, or metric `system_name`. Toolbox will figure it out.
* This is command is `idempotent`.
* Update to `disabled` metric by `--disabled` flag.
* Update to `enabled` metric by `--enabled` flag.
* Several other options can be set. Check `usage`

```shell
NAME
    apply - Update metric

USAGE
    3scale metrics apply [opts] <remote> <service>
    <metric>

DESCRIPTION
    Update (create if it does not exist) metric

OPTIONS
       --description=<value>      Metric description
       --disabled                 Disables this metric in all application
                                  plans
       --enabled                  Enables this metric in all application
                                  plans
    -n --name=<value>             Metric name
       --unit=<value>             Metric unit. Default hit

OPTIONS FOR METRICS
    -c --config-file=<value>      3scale toolbox configuration file (default:
                                  $HOME/.3scalerc.yaml)
    -h --help                     show help for this command
    -k --insecure                 Proceed and operate even for server
                                  connections otherwise considered insecure
    -v --version                  Prints the version of this command
       --verbose                  Verbose mode
```

### List

```shell
NAME
    list - list metrics

USAGE
    3scale metrics list [opts] <remote> <service>

DESCRIPTION
    List metrics

OPTIONS FOR METRICS
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
    delete - delete metric

USAGE
    3scale metrics delete [opts] <remote>
    <service> <metric>

DESCRIPTION
    Delete metric

OPTIONS FOR METRICS
    -c --config-file=<value>      3scale toolbox configuration file (default:
                                  $HOME/.3scalerc.yaml)
    -h --help                     show help for this command
    -k --insecure                 Proceed and operate even for server
                                  connections otherwise considered insecure
    -v --version                  Prints the version of this command
       --verbose                  Verbose mode
```
