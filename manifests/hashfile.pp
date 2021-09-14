# @summary Create certificate hash file
#
# Create certificate hash file
#
# @param [Stdlib::Unixpath] certdir
#   The directory ssl certs are stored in
#
# @example
#   [ $certfile, $certchainfile, $certinterfile, ].each |$hashfile| {
#     ssl::hashfile { $hashfile: certdir => $ssl::cert_dir }
#   }
#
define ssl::hashfile (
  Stdlib::Unixpath $certdir,
) {
  $filename = reverse(split($name, '/'))[0]

  exec { "Build cert hash for ${filename}":
    command => "ln -s ${certdir}/${filename} ${certdir}/$(openssl x509 -noout -hash -in ${certdir}/${filename}).0",
    unless  => "test -f ${certdir}/$(openssl x509 -noout -hash -in ${certdir}/${filename}).0",
    require => File["${certdir}/${filename}"],
    path    => ['/bin', '/usr/bin', '/usr/local/bin'],
  }
}
