# @summary Maintain SSL certs and private keys
#
# You can store SSL certs in your control repo. Simply create a profile and put
# the certs in its files directory. (Note that you don't actually have to create
# a manifest for it.)
#
# Suppose you wanted to use `profile::ssl`. Set `cert_source => 'profile/ssl'`,
# and add cert files in site/profile/files/ssl/.
#
# You can also store SSL keys. These should be encrypted, and the simplest
# solution for that is hiera-eyaml. Simply add keys to the keys parameter on
# this class in hiera. For example:
#
# ```yaml
# ssl::cert_source: 'profile/ssl'
# ssl::keys:
#   'puppet.com': ENC[PKCS7,MIIH...
#   'forge.puppet.com': ENC[PKCS7,MIIH...
# ```
#
#
# @param [String[1]] cert_source
#   Where to find cert files with the file() function.
#
# @param [Optional[String[1]]] group_name
#   The name of the group used for the `key_dir` permission.
#   The group will be realized if the catalog contains a group virtual resource where the title matches this parameter.
#
# @param [Hash[String[1], String[1]]] keys
#   Private keys indexed by key names.
#
# @param [Boolean] manage_group
#   Whether to manage attributes of the `group`.
#
# @param [Boolean] manage_ssl_dir
#   Enable or disable a file resource for the ssl directory
#
class ssl (
  String[1]                  $cert_source,
  Optional[String[1]]        $group_name     = 'ssl-cert',
  Hash[String[1], String[1]] $keys           = {},
  Boolean                    $manage_group   = true,
  Boolean                    $manage_ssl_dir = true,
) {
  # This doesn't quite follow the params pattern. Unfortunately, we have code
  # that relies on variables in ssl::params, but doesn't actually need the
  # directories managed. This is the simplest way to handle that legacy code.
  #
  # The PR I'm currently working on is getting too big, so I will leave
  # refactoring this to a future change.
  include ssl::params
  $ssl_dir = $ssl::params::ssl_dir
  $cert_dir = $ssl::params::cert_dir
  $key_dir = $ssl::params::key_dir

  if $manage_ssl_dir {
    file { $ssl_dir:
      ensure => directory,
      owner  => 'root',
      group  => '0',
      mode   => '0755',
    }
  }

  file { $cert_dir:
    ensure => directory,
    owner  => 'root',
    group  => '0',
    mode   => '0755',
  }

  if $manage_group {
    @group { $group_name:
      ensure => present,
    }
  }

  Group <| title == $group_name |>

  file { $key_dir:
    ensure  => directory,
    owner   => 'root',
    group   => $group_name,
    mode    => '0750',
    require => Group[$group_name],
  }
}
