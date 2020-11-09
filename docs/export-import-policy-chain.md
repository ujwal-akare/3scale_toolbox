## Export/Import Product Policy Chain

Common description:
* Export/Import one product's policy chain to/from yaml/json content.
* Product can be referenced by `id` or `system_name`.

Specific to `export` command:
* Read only operation on remote product.
* Command `output` can be `stdout` or file. If not specified by `-f` option, by default, content will be written on `stdout`.
* Command output format can be `json` or `yaml` using `-o` option. Defaults to `yaml`

Specific to `import` command:
* Imported content can be `stdin` (by default), file (`-f` option) or URL (`-u` option).
* Imported content can be `yaml` or `json`. No need to specify the format, the content format will be detected automatically.
* Imported resource as the source of truth. The existing policy chain will be updated with the imported new one. `SET` semantics implemented.
* All content validation is delegated to the 3scale API.

### Export Product Policy Chain

```shell
NAME
    export - export product policy chain

USAGE
    3scale policies export [opts] <remote>
    <product>

DESCRIPTION
    export product policy chain

OPTIONS
    -f --file=<value>             Write to file instead of stdout
    -o --output=<value>           Output format. One of: json|yaml
```

### Import Product Policy Chain

```shell
NAME
    import - import product policy chain

USAGE
    3scale policies import [opts] <remote>
    <product>

DESCRIPTION
    import product policy chain

OPTIONS
    -f --file=<value>             Read from file
    -u --url=<value>              Read from url
```

### Export policy chain to a file in yaml

```shell
$ 3scale policies export -f policies.yaml -o yaml remote_name product_name
```

### Import policy chain from a file

```shell
$ 3scale policies import -f plan.yaml remote_name product_name
```

### Import policy chain from URI

```shell
$ 3scale policies import -f http[s]://domain/resource/path.yaml remote_name product_name
```
