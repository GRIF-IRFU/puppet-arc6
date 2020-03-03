#
# defines a specific rte param using arcctl
#
define arc6::rte::param(
  Enum['present', 'absent' ] $ensure = 'present',
  String $rte, #the rte name is mandatory to set its params

  String $param = $name,
  Optional[String] $value = undef,
) {

  Exec { path => '/bin:/sbin:/usr/bin:/usr/sbin' }

  if( $ensure == 'present') {
    exec { "set RTE named ${rte} param $param":
      command => "/usr/sbin/arcctl rte params-set ${rte} ${param} ${value}",
      unless => "egrep -q '${param}=.*${value}' /var/spool/arc/jobstatus/rte/params/${rte} 2>/dev/null"
    }
  } else {
    exec { "unset RTE named ${rte} param $param":
      command => "/usr/sbin/arcctl rte params-unset ${rte} ${param}",
      onlyif => "egrep -q '${param}=.*${value}' /var/spool/arc/jobstatus/rte/params/${rte} 2>/dev/null"
    }
  }
}
