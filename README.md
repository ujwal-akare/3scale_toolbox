# 3scale toolbox

3scale toolbox is a set of tools to help you manage your 3scale product. 

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
3scale copy service NUMBER --endpoint=https://foo-admin.3scale.net --provider-key=your-key
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec threescale_toolbox` to use the gem in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/3scale/3scale_toolbox.

