#
# Defines or undefines 1 RTEs and its params
#
define arc6::rte(
  #enables or disables the rte. a default rte is enabled even if not requested.
  Enum['present', 'absent' ] $ensure = 'present',
  # a default rte is enabled even if not requested.
  Boolean $is_default = false,
  # is this a dummy RTE ?
  Boolean $dummy = false,
  # the rte params, if any
  # please provide a hash in the form :
  # param_name:
  #   ensure: present|absent
  #   value: _the_param_value. Th
  Hash $params = {},

  #you should not need to override this...
  $required_pkg = lookup( 'arc6::packages_arc' )
) {

  Exec { path => '/bin:/sbin:/usr/bin:/usr/sbin' }

  $dummy_rte = $dummy ? {
    true => ' -d',
    default => ''
  }

  #enable or disable
  case $ensure {
    'present' : {
      $rte_enable_action = 'enable'
      $rte_enable_cmd    = "${rte_enable_action}${dummy_rte}"
      $rte_enable_condition = "test -h /var/spool/arc/jobstatus/rte/enabled/${name}"
    }
    default: {
      $rte_enable_action = 'disable'
      $rte_enable_cmd    = "${rte_enable_action}"
      $rte_enable_condition = "test ! -h /var/spool/arc/jobstatus/rte/enabled/${name}"
    }
  }
  exec { "${rte_enable_action} the RTE ${name}":
    command => "/usr/sbin/arcctl rte ${rte_enable_cmd} ${name}",
    require => Package[ $required_pkg ],
    unless  => $rte_enable_condition
  }


  #default RTE or not
  case $is_default {
    true : {
      $rte_default_action = 'default'
      $rte_default_name ="set"
      $rte_default_condition = "test -h /var/spool/arc/jobstatus/rte/default/${name}"
    }
    default: {
      $rte_default_action = 'undefault'
      $rte_default_name ="unset"
      $rte_default_condition = "test ! -h /var/spool/arc/jobstatus/rte/default/${name}"
    }
  }
  exec { "${rte_default_name} RTE default status for ${name}":
    command => "/usr/sbin/arcctl rte ${rte_default_action} ${name}",
    require => Package[ $required_pkg ],
    unless => $rte_default_condition
  }

  # rte params
  $params.each | $k, $v | {

    arc6::rte::param { "${name} param ${k}":
      rte => $name,
      ensure => $v.dig('ensure'),
      param => $k,
      value => $v.dig('value'),
      require => Package[ $required_pkg ],
    }

  }
}
