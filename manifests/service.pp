class secc_snmpd::service inherits secc_snmpd {

  if $v2_enabled or $v3_enabled {
    service { 'snmpd':
      ensure      => running,
      hasrestart  => true,
      hasstatus   => true,
      enable      => true,
      require     => Class['secc_snmpd::install'],
    }
  }

  if $trap_enabled {
    service { 'snmptrapd':
      ensure          => running,
      hasrestart      => true,
      hasstatus       => true,
      enable          => true,
      require         => Class['secc_snmpd::install'],
    }
  }

}
