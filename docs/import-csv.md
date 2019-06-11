### Import from CSV

Will create new services, metrics, methods, and mapping rules having as source comma separated values (CSV) formatted file.

3scale instances can be either a [URL](docs/remotes.md#remote-urls) or the name of a [remote](docs/remotes.md).

CSV header

```csv
service_name,endpoint_name,endpoint_http_method,endpoint_path,auth_mode,endpoint_system_name,type
```

File example

```csv
service_name,endpoint_name,endpoint_http_method,endpoint_path,auth_mode,endpoint_system_name,type
Movies ,Movies (Biography),GET,/movies/biography/,api_key,movies_biography,metric
Movies ,Movies (Drama),GET,/movies/drama/,api_key,movies_drama,method
```

Help message:

```shell
$ 3scale import csv -h
NAME
    csv - Import csv file

USAGE
    3scale import csv [opts] -d <dst> -f <file>

DESCRIPTION
    Create new services, metrics, methods and mapping rules from CSV
    formatted file

OPTIONS
    -d --destination=<value>      3scale target instance. Url or remote name
    -f --file=<value>             CSV formatted file

OPTIONS FOR IMPORT
    -h --help                     show help for this command
    -k --insecure                 Proceed and operate even for server
                                  connections otherwise considered insecure
    -v --version                  Prints the version of this command
       --verbose                  Verbose mode
```

Example:

```shell
3scale import csv --destination=https://provider_key@user-admin.3scale.net --file=examples/import_example.csv
```
