# @summary Install key and certs combination for HAProxy
#
# Install key and certs combination for HAProxy.
#
# See the README for information about how to store certificates and keys for
# use by this type.
#
# This deploys `/etc/haproxy/certs.d/${key_name}.crt`, which contains:
#
# 1. The primary certificate
# 2. The private key
# 3. The intermediate certificate(s)
#
# @param [String[1]] key_name
#   The name of the certificate
#
# @param [Stdlib::Unixpath] path
#   The full path of the certificate, including the certificate's name.
#
# @param [String[1]] user
#   The user that owns the certificate
#
# @param [String[1]] group
#   The group that owns the certificate
#
# @param [String[1]] mode
#   The file mode of the certificate file
#
# @example Place a cert in the default location
#   ssl::cert::haproxy { 'www.example.com': }
#
# @example Place a cert in a custom location
#   ssl::cert::haproxy { 'www.example.com':
#     path => '/opt/custom_haproxy_build/etc/haproxy/certs',
#   }
#
define ssl::cert::haproxy (
  String[1] $key_name    = $title,
  Stdlib::Unixpath $path = "/etc/haproxy/certs.d/${key_name}.crt",
  String[1] $user        = 'root',
  String[1] $group       = '0',
  String[1] $mode        = '0400',
) {
  include ssl

  file { $path:
    ensure  => file,
    owner   => $user,
    group   => $group,
    mode    => $mode,
    content => ssl::pem::join([
      file("${ssl::cert_source}/${key_name}.crt"),
      $ssl::keys[$key_name],
      file("${ssl::cert_source}/${key_name}_inter.crt"),
    ]),
  }
}
