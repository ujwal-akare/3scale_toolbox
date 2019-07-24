## Service copy

This command makes a copy of the referenced service.
Target service will be searched by source service system name. System name can be overriden with `--target_system_name` option.
If a service with the selected `system_name` is not found, it will be created.

Components of the service being copied:

* service settings
* proxy settings
* pricing rules
* activedocs
* metrics
* methods
* application plans
* mapping rules
* policies. Note: If the service to be copied has custom policies make sure
  that their respective custom policy definitions already exist in the
  destination where the service is to be copied before performing the copy

3scale instances can be either a [URL](docs/remotes.md#remote-urls) or the name of a [remote](docs/remotes.md).

```shell
NAME
    service - copy service

USAGE
    3scale copy service [opts] -s <src> -d <dst>
    <source-service>

DESCRIPTION
    This command makes a copy of the referenced service. Target service will
    be searched by source service system name. System name can be overriden
    with `--target_system_name` option. If a service with the selected
    `system_name` is not found, it will be created.

    Components of the service being copied:

    service settings

    proxy settings

    pricing rules

    activedocs

    metrics

    methods

    application plans

    mapping rules

OPTIONS
    -d --destination=<value>             3scale target instance. Url or
                                         remote name
    -f --force                           Overwrites the mapping rules by
                                         deleting all rules from target
                                         service first
    -r --rules-only                      Only mapping rules are copied
    -s --source=<value>                  3scale source instance. Url or
                                         remote name
    -t --target_system_name=<value>      Target system name. Default to
                                         source system name
```

```shell
3scale copy service --source=s1 --destination=s2 my_service
```
