## Export/Import Application Plan

Common description:
* Export/Import a single application plan to/from yaml content.
* Limits defined in the application plan are included.
* Pricing rules defined in the application plan are included.
* Metrics/methods referenced by limits and pricing rules are included.
* Features defined in the application plan are included.
* Service can be referenced by `id` or `system_name`.
* Application Plan can be referenced by `id` or `system_name`.

Specific to `export` command:
* Read only operation on remote service and application plan.
* Command `output` can be `stdout` or file. If not specified by `-f` option, by default, yaml content will be written on `stdout`.

Specific to `import` command:
* Command `input` content can be `stdin`, file or URL format. If not specified by `-f` option, by default, yaml content will be read from `stdin`.
* If application plan cannot be found in remote service, it will be created.
* Optional param `-p, --plan` to override remote target application plan `id` or `system_name`. If not specified by `-p` option, by default, application plan will be referenced by plan attribute `system_name` from yaml content.
* Any metric or method from yaml content that cannot be found in remote service, will be created.
* Imported resource as the source of truth. All existing pricing rules and limits will be deleted before importing new ones.

### Export Application Plan Usage

```shell
NAME
    export - export application plan

USAGE
    3scale application-plan export [opts] <remote>
    <service_system_name> <plan_system_name>

DESCRIPTION
    Export application plan, limits, pricing rules and features

OPTIONS
    -f --file=<value>             Write to file instead of stdout
```

### Import Application Plan Usage

```shell
NAME
    import - import application plan

USAGE
    3scale application-plan import [opts] <remote>
    <service_system_name>

DESCRIPTION
    Import application plan, limits, pricing rules and features

OPTIONS
    -f --file=<value>                  Read from file or url instead of stdin
    -p --plan=<value>                  Override application plan reference
```

### Export application plan 'basic' to a file

```shell
$ 3scale application-plan export -f plan.yaml remote_name service_name plan_name
```

### Import application plan 'basic' from a file

```shell
$ 3scale application-plan import -f plan.yaml remote_name service_name
```

### Import application plan 'basic' from URI

```shell
$ 3scale application-plan import -f http[s]://domain/resource/path.yaml remote_name service_name
```
