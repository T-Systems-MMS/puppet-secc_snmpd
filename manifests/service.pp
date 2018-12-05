class secc_snmpd::service {

#  if $::secc_snmpd::v2_enabled or $::secc_snmpd::v3_enabled {
#    service { 'snmpd':
#      ensure     => running,
#      hasrestart => true,
#      hasstatus  => true,
#      enable     => true,
#      require    => Class['secc_snmpd::install'],
#    }
#  }

  if $::secc_snmpd::v2_enabled or $::secc_snmpd::v3_enabled {
    if $::operatingsystem == 'XCP' {
      service { 'snmpd':
        ensure     => running,
        hasrestart => true,
        hasstatus  => true,
        enable     => true,
        require    => Class['secc_snmpd::install'],
        provider   => systemd
      }
    }
    else {
      service { 'snmpd':
        ensure     => running,
        hasrestart => true,
        hasstatus  => true,
        enable     => true,
        require    => Class['secc_snmpd::install'],
      }
    }
  }

  if $::secc_snmpd::trap_enabled {
    service { 'snmptrapd':
      ensure     => running,
      hasrestart => true,
      hasstatus  => true,
      enable     => true,
      require    => Class['secc_snmpd::install'],
    }
  }
}
