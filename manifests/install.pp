# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include arc6::install
class arc6::install {

  # configure repos
  if($arc6::repo_configure) {

    $real_base="${arc6::repo_baseurl}/${facts[os][release][major]}/${facts[os][architecture]}"

    yumrepo { 'arc6-base':
      enabled    => true,
      descr      => 'Nordugrid ARC6 base repo',
      baseurl    => "${arc6::repo_baseurl}/${facts[os][release][major]}/${facts[os][architecture]}/base",
      gpgcheck   => '1',
      gpgkey     => $arc6::rpm_gpg_url,
      mirrorlist => absent,
      tag => 'arc',
    }
    file { '/etc/yum.repos.d/arc6-base.repo':}

    yumrepo { 'arc6-updates':
      enabled    => true,
      descr      => 'Nordugrid ARC6 base repo',
      baseurl    => "${arc6::repo_baseurl}/${facts[os][release][major]}/${facts[os][architecture]}/updates",
      gpgcheck   => '1',
      gpgkey     => $arc6::rpm_gpg_url,
      mirrorlist => absent,
      tag => 'arc',
    }
    file { '/etc/yum.repos.d/arc6-updates.repo':}

    yumrepo { 'arc6-testing':
      enabled    => $arc6::repo_enable_testing,
      descr      => 'Nordugrid ARC6 base repo',
      baseurl    => "${arc6::repo_baseurl}/${facts[os][release][major]}/${facts[os][architecture]}/testing",
      gpgcheck   => '1',
      gpgkey     => $arc6::rpm_gpg_url,
      mirrorlist => absent,
      tag => 'arc',
    }
    file { '/etc/yum.repos.d/arc6-testing.repo':}

    include ::epel
    Yumrepo <| tag == 'epel' |> -> Package <| tag == 'arc' |>
    Yumrepo <| tag == 'arc' |> -> Package <| tag == 'arc' |>
  }

  #need CAs and CRLs
  include ::fetchcrl

  #install
  package { $arc6::packages_arc : tag => 'arc' , ensure => $arc6::arc_ensure }
  package { $arc6::packages_lcas : tag => 'arc' }
  package { $arc6::packages_lcmaps : tag => 'arc' }

  #install our own BLAHP wrapper to account for failed/cancelled jobs
  file { '/usr/local/sbin/arc-blahp-wrapper.sh':
    source => $arc6::blahp_wrapper_source,
    mode   => '0755',
  }

}
