class secc_snmpd::service(
  $snmpd_trap_enabled
) {

  service { 'snmpd':
    ensure      => running,
    hasrestart  => true,
    hasstatus   => true,
    enable      => true,
    require     => Class['snmpd::install'],
  }

  if $snmpd_trap_enabled == true {
    service { 'snmptrapd':
      ensure          => running,
      hasrestart      => true,
      hasstatus       => true,
      enable          => true,
      require         => Class['snmpd::install'],
    }
  }

}
