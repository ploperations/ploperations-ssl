# ssl

![](https://img.shields.io/puppetforge/pdk-version/ploperations/ssl.svg?style=popout)
![](https://img.shields.io/puppetforge/v/ploperations/ssl.svg?style=popout)
![](https://img.shields.io/puppetforge/dt/ploperations/ssl.svg?style=popout)
[![Build Status](https://travis-ci.org/ploperations/ploperations-ssl.svg?branch=master)](https://travis-ci.com/ploperations/ploperations-ssl)

The primary purpose of this module is to install certificates and keys in a few common formats.

- [Storing certificates and keys](#storing-certificates-and-keys)
- [Deploying certificates and keys](#deploying-certificates-and-keys)
  - [`ssl::cert`](#sslcert)
  - [`ssl::cert::haproxy`](#sslcerthaproxy)
- [Additional usage info](#additional-usage-info)
- [Changelog](#changelog)
- [Development](#development)

## Storing certificates and keys

This requires that certificates and keys are stored separately. Keys should be stored in Hiera, while files must be stored in the `files/` directory of one of your profiles.

The primary certificate must be named "name.crt", and the intermediate certificate must be name "name_inter.crt". For example, if you store your files in `profile::ssl`:

```bash
site/profile/files/ssl/puppet.com.crt
site/profile/files/ssl/puppet.com_inter.crt
site/profile/files/ssl/forge.puppet.com.crt
site/profile/files/ssl/forge.puppet.com_inter.crt
```

Set the profile to use in Hiera, or by setting the `cert_source` parameter directly on the `ssl` class. The value should be in the same format as the `file()` function expects, e.g. `'profile/ssl'`.

The private keys for your certificates go into Hiera as entries in the `ssl::keys` hash. We recommend encrypting them with [Hiera eyaml][https://github.com/voxpupuli/hiera-eyaml]. To continue with the example from above:

```yaml
ssl::cert_source: 'profile/ssl'
ssl::keys:
  'puppet.com': ENC[PKCS7,MIIH...
  'forge.puppet.com': ENC[PKCS7,MIIH...
```

## Deploying certificates and keys

### `ssl::cert`

This is the most generic resource. It stores keys in the default global certificate and key directories for your OS.

On Debian, the `puppet.com` cert would be deployed as follows:

```bash
/etc/ssl/certs/puppet.com.crt
/etc/ssl/certs/puppet.com_inter.crt
/etc/ssl/certs/puppet.com_combined.crt
/etc/ssl/private/puppet.com.key
```

The `_combined.crt` file is a concatenation of the primary certificate followed by the intermediate certificate. This is the format used by NGINX and a variety of other applications.

### `ssl::cert::haproxy`

This combines certificates with their key in the format expected by HAProxy. By default, it puts them in `/etc/haproxy/certs.d/${key_name}.crt`.

## Additional usage info

This module is documented via `pdk bundle exec puppet strings generate --format markdown`. Please see [REFERENCE.md](REFERENCE.md) for more info.

## Changelog

[CHANGELOG.md](CHANGELOG.md) is generated prior to each release via `pdk bundle exec rake changelog`. This process relies on labels that are applied to each pull request.

## Development

Pull requests are welcome!
