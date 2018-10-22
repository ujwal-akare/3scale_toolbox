## Troubleshooting SSL errors

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
echo | openssl s_client -showcerts -servername self-signed.badssl.com -connect self-signed.badssl.com:443 2>/dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > self-signed-cert.pem
```

Certificate file can be verified easily with `curl` tool using `SSL_CERT_FILE` environment variable:

```bash
SSL_CERT_FILE=self-signed-cert.pem curl -v https://self-signed.badssl.com
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
