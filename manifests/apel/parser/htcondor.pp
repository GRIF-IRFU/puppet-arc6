#
# standalone APEL batch log parser for htcondor. This one requires parameters as it may be called on a pure htcondor machine.
#
class arc6::apel::parser::htcondor(

  # you PROBABLY will want to change these :
  String $site_name           = lookup( 'apelparser::site_name', { 'default_value' => 'localhost'}),
  String $apel_mysql_hostname = lookup( 'apelparser::mysql_hostname', { 'default_value' => 'localhost'}),
  Integer $apel_mysql_port     = 3306,
  String $apel_mysql_database = lookup( 'apelparser::mysql_database', { 'default_value' => 'apelclient'}),
  String $apel_mysql_user     = lookup( 'apelparser::mysql_user'    , { 'default_value' => 'apel'}),
  String $apel_mysql_password = lookup( 'apelparser::mysql_password', { 'default_value' => 'changeme'}),
  #cluster identification, especially *important* when ARC is not same host as CONDOR SCHED or when sharing a condor with several ARC
  String $lrms_id = lookup( 'arc6::apel::lrms_id', { 'default_value' => $::fqdn}),

  #the number of days for which to search job in htcondor history. Ideally : 1 if parser runs once per day
  Integer $ndays=7,
  Boolean $parallel_jobs = true, #no reason to say no

  #directories and files
  String $batch_dir = '/var/log/accounting',
  String $batch_fileprefix = 'accounting.', #should include all accounting files for centuries.


  String $template_name = "${module_name}/apel/parser-htcondor.cfg.erb",
  String $config_file   = "/etc/apel/parser-htcondor.cfg",
  String $condor_parser_source = "${module_name}/apel/htcondor_acc",
  Integer $cron_minutes = 0,
  Integer $cron_hours   = 2,
) {

  include ::arc6::apel::install

  #apel config file
  file { $config_file:
    owner   => 'root',
    group   => 'root',
    ensure  => 'present',
    content => template($template_name),
    mode => '0600', #file contains passwords
    require => Package[$arc6::apel::install::packages]
  }

  #htcondor accounting dir
  file { $batch_dir : ensure => directory }

  #htcondor history to apel conversion script.
  #Not perfect as it reads all history files and causes repbulication of jobs over some time, every day
  file { "/usr/sbin/htcondor_arc":
    owner   => 'root',
    group   => 'root',
    ensure  => 'present',
    content  => template($condor_parser_source),
    mode => '0755',
  }

  #script that transforms condor history into apel "htcondor parser" compatible files

  #cron that runs the conversion script which calls the apel parser.
  cron { 'apelparser-condor':
    command => "NDAYS=${ndays} /usr/sbin/htcondor_arc >> /var/log/apelparser-htcondor.log 2>&1",
    user    => 'root',
    hour    => $cron_hours,
    minute  => $cron_minutes,
  }
}
