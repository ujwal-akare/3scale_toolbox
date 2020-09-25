## Copy Policy Registry

Toolbox command to copy policy registry (a.k.a. `custom policies`) from a source account to a target account.
* Missing custom policies are being created in the target account.
* Matching custom policies are being updated in the target account.
* This copy command is idempotent.

Missing custom policies are defined as custom policies that exist in the source account and do not exist in the account tenant.

Matching custom policies are defined as custom policies that exist in both source and target accounts.

```shell
NAME
    copy - Copy policy registry

USAGE
    3scale policy-registry copy [opts]
    <source_remote> <target_remote>

DESCRIPTION
    Copy policy registry

OPTIONS FOR POLICY-REGISTRY
    -c --config-file=<value>      3scale toolbox configuration file (default:
                                  $HOME/.3scalerc.yaml)
    -h --help                     show help for this command
    -k --insecure                 Proceed and operate even for server
                                  connections otherwise considered insecure
    -v --version                  Prints the version of this command
       --verbose                  Verbose mode
```
