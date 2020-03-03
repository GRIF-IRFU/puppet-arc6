class arc6::firewall  {

  $arc6::services_ports.each | $proto, $rules| {
    $rules.each | $k, $v| {
      firewall { "${arc6::firewall_prefix} ARC ${k} ${proto} service":
        action => 'accept',
        proto => $proto,
        state => ['NEW', 'ESTABLISHED'],
        dport => $v,
      }
    }
  }
}
