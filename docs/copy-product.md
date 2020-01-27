## Copy Product

This command makes a copy of the referenced product.
Target product will be searched by source product system name.
System name can be overriden with `--target_system_name` option.
If a product with the selected `system_name` is not found, it will be created.

Components of the backend being copied:
* product configuration
* product settings
* product methods&metrics
* product mapping rules
* product application plans & pricing rules & limits
* product application usage rules
* product policies
* product backends
* product activedocs

3scale instances can be either a [URL](docs/remotes.md#remote-urls) or the name of a [remote](docs/remotes.md).

```shell
NAME
    copy - Copy product

USAGE
    3scale product copy [opts] -s <source_remote>
    -d <target_remote> <source_product>

DESCRIPTION
    This command makes a copy of the referenced product. Target product will
    be searched by source product system name. System name can be overriden
    with `--target_system_name` option. If a product with the selected
    `system_name` is not found, it will be created.

    Components of the product being copied:

    product configuration

    product settings

    product methods&metrics

    product mapping rules

    product application plans & pricing rules & limits

    product application usage rules

    product policies

    product backends

    product activedocs

OPTIONS
    -d --destination=<value>             3scale target instance. Url or
                                         remote name
    -s --source=<value>                  3scale source instance. Url or
                                         remote name
    -t --target_system_name=<value>      Target system name. Default to
                                         source system name
```

```shell
3scale product copy [-t target_system_name] -s 3scale1 -d 3scale2 product_01
```
