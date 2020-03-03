class arc6::umd::repos(
  Stdlib::HTTPUrl $base_url,
  Stdlib::HTTPUrl $gpg_url,
  Boolean         $gpg_check,
  Integer         $umd_release,
  String          $os_basename,
) {

  ['base', 'updates'].each | $v | {
    ensure_resource( 'yumrepo' , "umd-${v}",
      {
        descr       => "UMD yum {$v} repository",
        baseurl     => "${base_url}/${umd_release}/${os_basename}/${v}",
        gpgcheck    => $gpg_check,
        gpgkey      => $gpg_url,
        enabled     => 1,
      }
    )
  }
}
