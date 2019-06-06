## Applications

* [List applications](#list)
* [Create applications](#create)
* [show application](#show)
* [Apply application](#apply)
* [Delete application](#delete)

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
  * `<service>` reference. It can be either service `id`, or service `system_name`. Toolbox will figure it out.
  * `<account>` reference. It can be either account `id`, or `email` or `provider_key`. Toolbox will figure it out.
  * `<application plan>` reference. It can be either plan `id`, or plan `system_name`. Toolbox will figure it out.
  * `<name>` application name.
* Several other options can be set. Check `usage`.

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
       --application-key=<value>      App Key(s) or Client Secret (for OAuth
                                      and OpenID Connect authentication
                                      modes) of the application to be
                                      created.
       --description=<value>          Application description
       --user-key=<value>             User Key (API Key) of the application
                                      to be created.
```

### Show

```shell
NAME
    show - show application attributes

USAGE
    3scale application show [opts] <remote>
    <application>

DESCRIPTION
    Show application attributes

    Application param allows:

    * Application internal id

    * User_key (API key)

    * App_id (from app_id/app_key pair)

    * Client ID (for OAuth and OpenID Connect authentication modes)
```

### Apply

* Update (create if it does not exist) application.
* `application` positional argument is application unique identifier. Allowed id's are:
  * Application internal id
  * User_key (API key)
  * App_id (from app_id/app_key pair)
  * Client ID (for OAuth and OpenID Connect authentication modes)
* `name` cannot be used as unique identifier because application name is not unique in 3scale.
* This is command is `idempotent`.
* Resume a suspended application by `--resume` flag.
* Suspends an application (changes the state to suspended) by `--suspend` flag.
* Several other options can be set. Check `usage`

```shell
NAME
    apply - update (or create) application

USAGE
    3scale application apply [opts] <remote>
    <application>

DESCRIPTION
    Update (create if it does not exist) application'

    Application param allows:

    * Application internal id

    * User_key (API key)

    * App_id (from app_id/app_key pair)

    * Client ID (for OAuth and OpenID Connect authentication modes)

OPTIONS
       --account=<value>              Application's account. Required when
                                      creating
       --application-key=<value>      App Key(s) or Client Secret (for OAuth
                                      and OpenID Connect authentication
                                      modes) of the application to be
                                      created. Only used when application
                                      does not exist.
       --description=<value>          Application description
       --name=<value>                 Application name
       --plan=<value>                 Application's plan. Required when
                                      creating
       --resume                       Resume a suspended application
       --service=<value>              Application's service. Required when
                                      creating
       --suspend                      Suspends an application (changes the
                                      state to suspended)
       --user-key=<value>             User Key (API Key) of the application
                                      to be created.
```

### Delete

* `application` positional argument is application unique identifier. Allowed id's are:
  * Application internal id
  * User_key (API key)
  * App_id (from app_id/app_key pair)
  * Client ID (for OAuth and OpenID Connect authentication modes)

```shell
NAME
    delete - delete application

USAGE
    3scale application delete [opts] <remote>
    <application>

DESCRIPTION
    Delete application'

    Application param allows:

    * Application internal id

    * User_key (API key)

    * App_id (from app_id/app_key pair)

    * Client ID (for OAuth and OpenID Connect authentication modes)
```
