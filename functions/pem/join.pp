# @summary Join certs and keys into a single PEM. Ensure the correct newlines exist.
#
# Join certs and keys into a single PEM. Ensure the correct newlines exist.
#
# @param [Array[String[0]]] items
#   An array of strings representing PEM files that need to be concatenated
#   together
#
# @return [String]
#   Returns a string representing the combined certificates.
#
# @example Joining a cert with it's intermediate cert
#   file { '/tmp/www.example.com_combined.crt":
#     ensure  => file,
#     content => ssl::pem::join([
#       file("${ssl::cert_source}/${key_name}.crt"),
#       file("${ssl::cert_source}/${key_name}_inter.crt"),
#     ]),
#   }
#
function ssl::pem::join(Array[String[0]] $items) >> String {
  $items.map |$item| { ssl::ensure_newline($item) }.join('')
}

