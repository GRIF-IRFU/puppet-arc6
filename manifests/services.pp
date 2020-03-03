class arc6::services(
  $services = ['arc-gridftpd', 'arc-arex' , 'arc-infosys-ldap']
) {

  $services.each | $svc | {
    service { $svc :
      ensure     => 'running',
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
    }
  }

  # SHOULD the services should start in a certain order ?

  }
