/**
this should help you setup your own ARC CE. But you may require to fix or tweak.

This one is configured with ARGUS for the user mapping.

Don't hesitate to give feedback. Especially on how to setup without argus or the vosupport module...
*/

  # on our node, umd installed RPMS are lcmaps, lcas, apel and argus
  include ::arc6::umd::repos
  include ::fetchcrl

  $hepspec=lookup('hepspec::hs06')
  class { 'arc6':

    gocdb_sitename => 'MY_SITE',
    glue_site_web => 'http://my.web.site',
    repo_baseurl => "http://my.own/mirrors/nordugrid/arc/centos",
    advertised_vos => ['alice','atlas','cms'],
    argus_servers => ['fqdn1', 'fqdn2'],
    shared_filesystem => 'no',
    apel_accounting => true,
    jura_accounting => false,

    ce_hepspec => $hepspec ,
    ce_specint2k => Integer($hepspec * 250),

    # this is for glue1. glue1 is doomed.
    # get the value with : condor_status -constraint '(SlotType == "Partitionable")' -af DetectedCpus |gawk '{sum+=$1} END {print sum}'
    ce_ncores => '123456',
  }

  #override condor submition script :
  # - add accounting groups
  # - overcommit requested memory
  # - remove PeriodicRemove expression for memory : not cgroups compatible
  # Use a brute overwrite rather than patch, to avoid surprises
  file {'/usr/share/arc/submit-condor-job':
    source => 'puppet:///modules/my_site_module/arc/submit-condor-job.arc6',
    require => Package[$arc6::packages_arc],
    backup => true,
  }


  # configure PER_JOB_HISTORY_DIR - and other things. BEWARE : this requires cron cleanup !
  # to configure : define (in hiera ?) htcondor::custom_knobs

  #there can be up to 20K+ files generated per day : make sure cleanup is in place
  cron::system{"condor_per_job_hist_cleanup":
    command     => "find /var/lib/condor/spool/history.perjob -type f -mtime +1 |xargs rm -f",
    user        => root,
    hour        => '*',
    minute      => '33',
  }

  #htcondor
  $custom_knobs = { 'PER_JOB_HISTORY_DIR' => '/var/lib/condor/spool/history.perjob' } + lookup('htcondor::custom_knobs', { 'default_value' => {} })
  class { ::htcondor:
    is_scheduler => true,
    template_config_local   => "$yoursite::htcondor::params::template_config_local",
    template_resourcelimits => "$yoursite::htcondor::params::template_resourcelimits",
    install_repositories => true,
    custom_knobs => $custom_knobs,
  }

  file { '/var/lib/condor/spool/history.perjob' :
    ensure => 'directory',
    mode => '0750',
    owner => $htcondor::condor_user,
    group => $htcondor::condor_group,
    require => Package['condor']
  }

  # some ordering
  Package['condor'] -> File['/etc/condor/pool_password']


  #VO support
  #this sets up /etc/grid-security/vomsdir/ directories
  $vo_classes=regsubst(lookup('supported_vos'),'[\-\.]','_','G')
  $vo_classes.each | $vo_name | {
    include "::voms::${vo_name}"
  }

  # this sets up pool accounts. Untested, as I use NIS to avoïd having to create 1000+ unix users each time a host is re-installed.
  # and to avoid having a setup that writes a few GBs just to rewrite over and over again etc/passwd AND which takes hours.
  #
  # pool accounts are evil !
  #
  # and vosupport module is evil too ! It requires a hiera setup that's out of scope here.
  class {'vosupport':
    supported_vos => lookup('supported_vos'),
    enable_mappings_for_service => 'ALL',
    enable_poolaccounts => true,
    enable_environment => false,
    enable_voms => false,
    enable_gridmapdir_for_group => "root",
  }

  #accounting: add apel parser
  include ::arc6::apel::parser::htcondor
