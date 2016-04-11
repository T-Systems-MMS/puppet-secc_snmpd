class secc_snmpd::service inherits secc_snmpd {

  service { 'snmpd':
    ensure      => running,
    hasrestart  => true,
    hasstatus   => true,
    enable      => true,
    require     => Class['secc_snmpd::install'],
  }

  if $snmpd_trap_enabled == true {
    service { 'snmptrapd':
      ensure          => running,
      hasrestart      => true,
      hasstatus       => true,
      enable          => true,
      require         => Class['secc_snmpd::install'],
    }
  }

}
