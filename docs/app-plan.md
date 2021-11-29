## Application plans

* [Create new application plan](#create)
* [Apply application plan](#apply)
* [List application plans](#list)
* [Delete application plan](#delete)
* [Show application plan](#show)

### Create

* Creates a new application plan
* Only application plan name is required. `system-name` can be overridden with an optional parameter.
* `service` positional argument is a service reference. It can be either service `id`, or service `system_name`. Toolbox will figure it out.
* This is not idempotent command. If application plan with the same name already exists, command will fail.
* Set as `default` application plan by `--default` flag.
* Create a `published` application plan by `--publish` flag. By default, it will be `hidden`.
* Create a `disabled` application plan by `--disabled` flag. By default, it will be `enabled`.
* Several other options can be set. Check `usage`

```shell
NAME
    create - create application plan

USAGE
    3scale application-plan create [opts] <remote>
    <service> <plan-name>

DESCRIPTION
    Create application plan

OPTIONS
       --approval-required=<value>      Applications require approval. true
                                        or false
       --cost-per-month=<value>         Cost per month
       --default                        Make default application plan
       --disabled                       Disables all methods and metrics in
                                        this application plan
    -o --output=<value>                 Output format. One of: json|yaml
    -p --publish                        Publish application plan
       --setup-fee=<value>              Setup fee
    -t --system-name=<value>            Application plan system name
       --trial-period-days=<value>      Trial period days
```

### Apply

* Update existing application plan. Create a new one if it does not exist.
* `service` positional argument is a service reference. It can be either service `id`, or service `system_name`. Toolbox will figure it out.
* `plan` positional argument is a plan reference. It can be either plan `id`, or plan `system_name`. Toolbox will figure it out.
* This is command is `idempotent`.
* Update to `default` application plan by `--default` flag.
* Update to `published` application plan by `--publish` flag.
* Update to `hidden` application plan by `--hide` flag.
* Update to `disabled` application plan by `--disabled` flag.
* Update to `enabled` application plan by `--enabled` flag.
* Several other options can be set. Check `usage`

```shell
NAME
    apply - Update application plan

USAGE
    3scale application-plan apply [opts] <remote>
    <service> <plan>

DESCRIPTION
    Update (create if it does not exist) application plan

OPTIONS
       --approval-required=<value>      Applications require approval. true
                                        or false
       --cost-per-month=<value>         Cost per month
       --default                        Make default application plan
       --disabled                       Disables all methods and metrics in
                                        this application plan
       --enabled                        Enable application plan
       --hide                           Hide application plan
    -n --name=<value>                   Plan name
    -o --output=<value>                 Output format. One of: json|yaml
    -p --publish                        Publish application plan
       --setup-fee=<value>              Setup fee
       --trial-period-days=<value>      Trial period days
```

### List

```shell
NAME
    list - list application plans

USAGE
    3scale application-plan list [opts] <remote>
    <service>

DESCRIPTION
    List application plans

OPTIONS
    -o --output=<value>           Output format. One of: json|yaml
```

### Delete

```shell
NAME
    delete - delete application plan

USAGE
    3scale application-plan delete [opts] <remote>
    <service> <plan>

DESCRIPTION
    Delete application plan
```

### Show


```shell
NAME
    show - show application plan

USAGE
    3scale application-plan show [opts] <remote>
    <service> <plan>

DESCRIPTION
    show application plan

OPTIONS
    -o --output=<value>           Output format. One of: json|yaml
```
