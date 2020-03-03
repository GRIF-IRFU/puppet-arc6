class arc6::apel::parser::arc(
  String                $template_name = "${module_name}/apel/parser-arc.cfg.erb",
  Stdlib::Absolutepath  $config_file   = '/etc/apel/parser-arc.cfg',
  Integer               $cron_minutes = $arc6::apel::cron_minutes,
  Integer               $cron_hours   = $arc6::apel::cron_hours,
) {

  file { "$config_file" :
    owner   => 'root',
    group   => 'root',
    ensure  => 'present',
    content => template($template_name),
    mode => '0600', #file contains passwords
    require => Package[$arc6::apel::install::packages]
  }

  cron { 'apelparser-ARC':
    command => "/usr/bin/apelparser -c $config_file >> /var/log/apelparser.log 2>&1",
    user    => 'root',
    hour    => $cron_hours,
    minute  => $cron_minutes,
  }
}
