# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include arc6
# default params value will be in hiera
class arc6(

  #MANDATORY ARGS
  String $gocdb_sitename,
  String $glue_site_web, #mandatory for glue1

  #authentication/authorization vars
  Optional[Array[String]] $argus_servers = undef,

  #The CE mean hepspec (HS06), for instance : 13.12
  Float   $ce_hepspec,
  Integer $ce_specint2k = undef,
  Integer $ce_ncores = 1, #the number of cpu cores in the cluster

  #repo vars
  String  $repo_baseurl,
  Boolean $repo_configure,
  Boolean $repo_enable_testing,
  Stdlib::HTTPUrl $rpm_gpg_url,

  #packages
  Array $packages_arc,
  Array $packages_lcas,
  Array $packages_lcmaps,
  String $arc_ensure, #define what version to install

  #Firewall and ports
  Boolean $firewall_manage,
  Integer $firewall_prefix,
  Hash    $services_ports,

  #storage
  Enum['yes', 'no', 'missing'] $fixdirectories = 'yes',
  String $arc_basepath = '/var/spool/arc',
  String $controldir = "$arc_basepath/jobstatus",
  Array[String] $sessiondir = [ "$arc_basepath/sessiondir" ],
  #keep default RTE dir, will prevent having to enable extra ones
  #$runtimedir = [ "$arc_basepath/extraruntimes" ],
  String $archivedir = "$arc_basepath/jura/archive",

  #ARC vars
  String $arc_hostname = $::fqdn,
  Array[String] $advertised_vos = [],
  Integer $lcas_timeout_sec = 10,
  Integer $lcmaps_timeout_sec = 30,
  #set this to no if you want to close the CE
  Enum['yes', 'no'] $allownew = 'yes',
  #set this to yes (default for ARC) if WNs and ARC share sessiondir filesystem
  Enum['yes', 'no'] $shared_filesystem = 'yes',


  #LRMS vars
  String $lrms                = 'condor',
  String $lrms_default_queue  = 'default',
  Integer $lrms_defaultmemory  = 2000,

  #Arex vars
  String $arex_default_ttl = "172800 86400", #ttl & ttr: 2+1 days
  Integer $arex_loglevel = 3,

  #Jura / accounting vars
  Boolean $jura_accounting = true,
  Optional[Hash] $jura_targets = {
    'apel:egi' => {
      'targeturl' => 'http://mq.cro-ngi.hr:6162',
      'topic' => '/queue/global.accounting.cpu.central',
      'gocdb_name' => $gocdb_sitename,
      'benchmark_type' => 'HEPSPEC',
      'benchmark_value' => $ce_hepspec,
      'benchmark_description' => 'HS06',
      'use_ssl' => 'yes',
      'urbatchsize' => 1000,
    }
  },

  #APEL ACCOUNGING - disabled by default
  #ARC params : where and how apel logs will be stored :
  Boolean $apel_accounting = false,
  Integer $apel_accounting_plugin_timeout_s = 10,
  String  $apel_accounting_dir    = '/var/log/arc/accounting',
  String  $apel_accounting_prefix = 'blahp.log',
  String  $blahp_wrapper_source = 'puppet:///modules/arc6/arc-blahp-wrapper.sh',
  #use the wrapper that "fixes" failed jobs accounting, or not :
  Boolean $blahp_use_wrapper = false,
  #apel params :
  String $apel_mysql_hostname = lookup( 'apelparser::mysql_hostname', { 'default_value' => 'localhost'}),
  Integer $apel_mysql_port     = 3306,
  String $apel_mysql_database = lookup( 'apelparser::mysql_database', { 'default_value' => 'apelclient'}),
  String $apel_mysql_user     = lookup( 'apelparser::mysql_user'    , { 'default_value' => 'apel'}),
  String $apel_mysql_password = lookup( 'apelparser::mysql_password', { 'default_value' => 'changeme'}),

  #Gridftpd vars,
  Integer $gridftpd_maxconnections = 200,
  Array[String] $gridftpd_allowaccess = [ "lcas" ], #order dependant...
  Array[String] $gridftpd_denyaccess = [ ], #order dependant...

  #Glue1 vars (optional)
  Float $resource_latitude = undef,
  Float $resource_longitude = undef,
  String $resource_location = undef,
  Optional[Hash] $infosys_glue1_extra_conf = {
    'resource_location' => $resource_location,
    'resource_latitude' => $resource_latitude,
    'resource_longitude' => $resource_longitude,
    'cpu_scaling_reference_si00' => $ce_specint2k,
    'glue_site_unique_id' => $gocdb_sitename,
    'processor_other_description' => "Cores=${ce_ncores}, Benchmark=${ce_hepspec}-HEP-SPEC06",
  },

  #infosys/cluster vars
  Enum['True', 'False'] $cluster_homogeneity = 'True',
  Array[String] $cluster_nodeaccess = ['inbound', 'outbound'],
  Optional[Integer] $cluster_nodememory = 2048,
  Array[String] $cluster_opsys = ['CentOS', '7'],
  Array[String] $benchmark_results   = [
    "SPECINT2000 $ce_specint2k",
    "HEPSPEC2006 $ce_hepspec"
  ],

  #Cluster queues
  Hash $queues = {
    'default'=> {}
  },

  #Blocks extra config hashes
  Hash $lrms_extra_conf = {},
  Hash $arex_extra_conf = {},
  Hash $arex_ws_extra_conf = {},
  Hash $arex_ws_jobs_extra_conf = {},
  Hash $arex_jura_extra_conf = {},
  Hash $arex_jura_archiving_extra_conf = {},
  Hash $gridftpd_extra_conf = {},
  Hash $gridftpd_jobs_extra_conf = {},
  Hash $infosys_extra_conf = {},
  Hash $infosys_ldap_extra_conf = {},
  Hash $infosys_glue2_extra_conf = {},
  Hash $infosys_cluster_extra_conf = {},
  Boolean $setup_RTEs          = true,
  Hash $default_RTEs = {} # see data/common.yaml or rte.pp for forat

) {

  class { ::arc6::install : }
  ->
  class { ::arc6::config : }
  ->
  class { ::arc6::services : }

  if($setup_RTEs) {
    create_resources ('arc6::rte', $default_RTEs)
  }
}
