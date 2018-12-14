# Remotes

Manage set of 3scale instances.

Added remotes are stored in configuration file and can be used in any command
where 3scale instances need to be specified.

## Synopsis

```
3scale remote [--config-file <config_file>]
3scale remote add [--config-file <config_file>] <name> <url>
3scale remote remove [--config-file <config_file>] <name>
3scale remote rename [--config-file <config_file>] <old_name> <new_name>
```

## Options

*--config-file <config_file>*

3scale CLI configuration file. When not set, the toolbox will lookup path at:

* *THREESCALE_CLI_CONFIG* environment variable
* `$HOME/.3scalerc.yaml`

## Remote URLS

The 3scale toolbox access 3scale instances by an `HTTP[S]` URL.
Tokens are used for authentication and authorization purposes.
3scale API supports the following token types:
* `access_token` (preferred)
* `provider_key`

The following syntax is used:

```
http[s]://<provider_key>|<access_token>@<3scale-instance-domain>
```

## Commands

### List

Shows the list of existing remotes. Several subcommands are available to perform operations on the remotes.

Example:

```shell
$ 3scale remote list
instance_a https://example_a.net 123456789
instance_b https://example_b.net 987654321
```

### Add

Adds a remote named <name> for the 3scale instance at `<url>`.

Example:

```shell
3scale remote add instance_a https://123456789@example_a.net
```

### Remove

Remove the remote named `<name>`.

Example:

```shell
3scale remote remove instance_a
```

### Rename

Rename the remote named `<old>` to `<new>`.

Example:

```shell
3scale remote rename instance_a instance_b
```
