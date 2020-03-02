# @summary Ensure there's a trailing newline
#
# Ensure there's a trailing newline
#
# @param [String[0]] string
#   A string to ensure ends with a new line (aka '\n')
#
# @return [String]
#   Returns a string that ends with a newline (`\n`)
# @example
#   file { '/tmp/www.example.com.crt':
#     ensure  => file,
#     content => ssl::ensure_newline($ssl::keys['www.example.com']),
#   }
#
function ssl::ensure_newline(String[0] $string) >> String {
  if $string[-1] == "\n" {
    $string
  } else {
    "${string}\n"
  }
}
