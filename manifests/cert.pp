# @summary Deploy SSL certificates and keys in a couple of common formats
#
# Deploy SSL certificates and keys in a couple of common formats
#
# See the README for information about how to store certificates and keys for
# use by this type.
#
# This deploys:
#
# - `${key_dir}/${key_name}.key`
# - `${cert_dir}/${key_name}.crt`
# - `${cert_dir}/${key_name}_inter.crt` — the intermediate certificate(s)
# - `${cert_dir}/${key_name}_combined.crt` — the primary certificate
#     followed by the intermediate certificate(s)
#
# @example
#   ssl::cert { 'www.example.com': }
#
# @param [String[1]] key_name
#   The name of the certificate
#
# @param [Optional[String[1]]] cert_dir
#   The directory that certs are stored in. If no values is provided then the
#   value from $ssl::cert_dir is used.
#
# @param [Optional[String[1]]] key_dir
#   The directory that certificate keys are stored in. If no values is provided
#   then the value from $ssl::key_dir is used.
#
# @param [String[1]] user
#   The user to set as the owner of the generated files
#
# @param [String[1]] group
#   THe group to set as the owner of the generated files
#
# @param [String[1]] mode
#   The file mode to be set on each generated file
#
define ssl::cert (
  String[1]           $key_name = $title,
  Optional[String[1]] $cert_dir = undef,
  Optional[String[1]] $key_dir  = undef,
  String[1]           $user     = 'root',
  String[1]           $group    = '0',
  String[1]           $mode     = '0640',
) {
  include ssl

  $_cert_dir = pick($cert_dir, $ssl::cert_dir)
  $_key_dir = pick($key_dir, $ssl::key_dir)

  file {
    default:
      ensure => file,
      owner  => $user,
      group  => $group,
      mode   => $mode,
    ;
    # Key
    "${_key_dir}/${key_name}.key":
      mode    => '0400',
      # https://github.com/voxpupuli/hiera-eyaml/issues/264: eyaml drops newline
      content => ssl::ensure_newline($ssl::keys[$key_name]),
    ;
    # Plain cert
    "${_cert_dir}/${key_name}.crt":
      content => file("${ssl::cert_source}/${key_name}.crt"),
    ;
    # Intermediate cert
    "${_cert_dir}/${key_name}_inter.crt":
      content => file("${ssl::cert_source}/${key_name}_inter.crt"),
    ;
    # Combined cert and intermediate cert
    "${_cert_dir}/${key_name}_combined.crt":
      content => ssl::pem::join([
        file("${ssl::cert_source}/${key_name}.crt"),
        file("${ssl::cert_source}/${key_name}_inter.crt"),
      ]),
    ;
  }
}
