# 3scale toolbox

3scale toolbox is a set of tools to help you manage your 3scale product. Using the [3scale API Ruby Client](https://github.com/3scale/3scale-api-ruby).

## Installation


Install the CLI:

    $ gem install 3scale_toolbox

## Usage

```shell
3scale help
```

### Copy a service

Will create a new service, copy existing methods, metrics, application plans and their usage limits.

```shell
3scale copy service NUMBER --source=https://provider_key@foo-admin.3scale.net --destination=https://provider_key@foo2-admin.3scale.net
```

### Update a service

Will update existing service, update proxy settings, metrics, methods, application plans and mapping rules.

Help docstring

```shell
NAME
    service - Update service

USAGE
    3scale update service [opts] -s <src> -d <dst>
    <src_service_id> <dst_service_id>

DESCRIPTION
    Will update existing service, update proxy settings, metrics, methods,
    application plans and mapping rules.

OPTIONS
    -d --destination=<value>      3scale target instance. Format:
                                  "http[s]://<provider_key>@3scale_url"
    -f --force                    Overwrites the mapping rules by deleting
                                  all rules from target service first
    -h --help                     show help for this command
    -r --rules-only               Updates only the mapping rules
    -s --source=<value>           3scale source instance. Format:
                                  "http[s]://<provider_key>@3scale_url"

OPTIONS FOR UPDATE
    -h --help                     show help for this command
    -k --insecure                 Proceed and operate even for server
                                  connections otherwise considered insecure
    -v --version                  Prints the version of this command
```

Example:

```shell
$ 3scale update service -s https://234239874598743@3scaleinstance_source.com -d https://2342342342342@3scaleinstance_destination.com 3 2
```

### Import from CSV

Will create a new services, metrics, methods and mapping rules.

```shell
3scale import csv --destination=https://provider_key@user-admin.3scale.net --file=examples/import_example.csv
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec 3scale` to use the gem in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Plugins

As of 3scale Toolbox 0.5.0, 3scale Toolbox will load plugins installed in gems or $LOAD_PATH. Plugins are discovered via Gem::find_files then loaded.
Install, uninstall and update plugins using tools like [RubyGems](https://guides.rubygems.org/rubygems-basics/) and/or [Bundler](https://bundler.io/).

[Make your own plugin](docs/plugins.md)

## Troubleshooting

* [SSL errors](docs/ssl_errors.md): If you run into SSL issues with the toolbox, you can take actions to resolve them.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/3scale/3scale_toolbox.

