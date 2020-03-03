class arc6::apel(

  Integer $cron_minutes = 35,
  Integer $cron_hours   = 1,

  #cluster identification, if needed, especially when sharing a condor with several ARC
  String $lrms_id = $::fqdn,

  #arc accounting
  String $site_name      = $arc6::gocdb_sitename,
  String $blah_dir       = $arc6::apel_accounting_dir,

) {

  include ::arc6::apel::install
  include ::arc6::apel::parser::arc

}
