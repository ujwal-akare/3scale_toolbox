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

## Troubleshooting SSL errors

If you run into SSL issues with the toolbox, you can take actions to resolve them.

There are several issues that may arise related to SSL certificates.
Check [badssl site](https://badssl.com/) for a comprehensive list.
It is very common, though, environments where `self-signed` certificates are deployed.

It can be `SSL certificate problem: self signed certificate`

```bash
# curl https://self-signed.badssl.com/
curl: (60) SSL certificate problem: self signed certificate
```

Or it can be `self signed certificate in certificate chain`

```bash
$ curl https://3scale-admin.5e1f.apps.rhpds.openshift.opentlc.com
curl: (60) SSL certificate problem: self signed certificate in certificate chain
```

The *recommended* way to solve this issues is fetching remote host certificate
and using that certificate with the toolbox.

You can get the remote host certificate by using OpenSSL:

```bash
echo | openssl s_client -showcerts -servername self-signed.badssl.com -connect self-signed.badssl.com:443 2>/dev/null | openssl x509 > self-signed-cert.pem
```

Then tell the toolbox to use that certificate using `SSL_CERT_FILE` environment variable.

```bash
SSL_CERT_FILE=self-signed-cert.pem 3scale command params
```

You can also make your Ruby install permanently trust this certificate by adding it to the trusted certificates directory.

Documentation on the format of certificates stored in that directory:
* <https://www.openssl.org/docs/man1.1.0/ssl/SSL_CTX_load_verify_locations.html>
* <https://www.openssl.org/docs/man1.1.0/apps/c_rehash.html>

How to get the all-in-one file and the certificate directory:

```bash
ruby -ropenssl -e 'p OpenSSL::X509::DEFAULT_CERT_DIR'
ruby -ropenssl -e 'p OpenSSL::X509::DEFAULT_CERT_FILE'
```

Another common issue is having an extra layer in wildcard certificates.
Let's say your server name is `myserver.web.mydomain.com`,
*but* certificate's common name (CN) is `CN=*.mydomain.com`. The SSL client will report with the following error:

```bash
$ curl https://myserver.web.mydomain.com
curl: (51) SSL: no alternative certificate subject name matches target host name 'myserver.web.mydomain.com'
```

The recommended way to solve this issue is updating server name from service changing URL to match certificate's Common Name (CN).

### Insecure connections

There is a workaround to all SSL issues, *not recommended* though, which is *disabling TLS verification*.

`3scale Toolbox` allows insecure connections when specified. For that feature, the toolbox allows `-k/--insecure`
flag on *any* command and the toolbox will proceed and operate even for server connections otherwise considered insecure.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/3scale/3scale_toolbox.

