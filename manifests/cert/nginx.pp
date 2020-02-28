# @summary DEPRECATED
#
# This is only here to simplify some of our legacy code.
#
# We recommend using `ssl::cert` and configuring NGINX to use the
# `_combined.crt` file instead of using this resource.
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
define ssl::cert::nginx (
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
    # Combined cert and intermediate cert
    "${_cert_dir}/${key_name}.crt":
      content => ssl::pem::join([
        file("${ssl::cert_source}/${key_name}.crt"),
        file("${ssl::cert_source}/${key_name}_inter.crt"),
      ]),
    ;
  }
}
