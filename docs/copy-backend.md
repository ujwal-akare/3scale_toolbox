## Copy Backend

This command makes a copy of the referenced backend.
Target backend will be searched by source backend system name. System name can be overriden with `--target_system_name` option.
If a backend with the selected `system_name` is not found, it will be created.

Components of the backend being copied:

* backend settings
* metrics
* methods
* mapping rules

3scale instances can be either a [URL](docs/remotes.md#remote-urls) or the name of a [remote](docs/remotes.md).

```shell
NAME
    copy - Copy backend

USAGE
    3scale backend copy [opts] -s <source_remote>
    -d <target_remote> <source_backend>

DESCRIPTION
    This command makes a copy of the referenced backend. Target backend will
    be searched by source backend system name. System name can be overriden
    with `--target_system_name` option. If a backend with the selected
    `system_name` is not found, it will be created.

    Components of the backend being copied:

    metrics

    methods

    mapping rules

OPTIONS
    -d --destination=<value>             3scale target instance. Url or
                                         remote name
    -s --source=<value>                  3scale source instance. Url or
                                         remote name
    -t --target_system_name=<value>      Target system name. Default to
                                         source system name
```

```shell
3scale backend copy [-t target_system_name] -s 3scale1 -d 3scale2 backend_01
```
