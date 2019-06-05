## Applications

* [List applications](#list)
* [Create applications](#create)

### List

```shell
NAME
    list - list applications

USAGE
    3scale application list [opts] <remote>

DESCRIPTION
    List applications

OPTIONS
       --account=<value>          Filter by account
       --plan=<value>             Filter by application plan. Service option
                                  required
       --service=<value>          Filter by service
```


### Create

* A new application is created always. This command is not idempotent command.
* Required positional params:
* Several other options can be set. Check `usage`

```shell
NAME
    create - create one application

USAGE
    3scale application create [opts] <remote>
    <account> <service> <application-plan> <name>

DESCRIPTION
    create one application linked to given account and application plan

OPTIONS
       --application-id=<value>       App ID or Client ID (for OAuth and
                                      OpenID Connect authentication modes) of
                                      the application to be created.
       --application_key=<value>      App ID or Client ID (for OAuth and
                                      OpenID Connect authentication modes) of
                                      the application to be created.
       --description=<value>          Application description
       --user-key=<value>             User Key (API Key) of the application
                                      to be created.
```
