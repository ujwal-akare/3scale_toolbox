## Import from a CSV file


### Usage

#### Production

```shell 
$ 3scale import csv --destination=https://provider_key@user-admin.3scale.net --file=examples/import_example.csv
```

#### Development

```shell 
$ git checkout branch_foo
$ git pull origin branch_foo
```

```shell
$ bundle exec exe/3scale-import csv --destination=https://provider_key@user-admin.3scale.net --file=examples/import_example.csv
```

### API

#### Options

##### Destination

required: ```true```

```shell
--destination=https://provider_key@user-admin.3scale.net 
```

##### File

required: ```true```

```shell
--file=examples/import_example.csv
``` 
