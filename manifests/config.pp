class secc_snmpd::config (
  $service,
  $snmpd_communityhost,
  $snmpd_syslocation,
  $snmpd_syscontact,
  $snmpd_v3_user,
  $snmpd_v3_password,
  $snmpd_v3_passphrase,
  $snmpd_trap_enabled,
  $snmpd_v2_enabled
) {

  if $snmpd_trap_enabled == true {
    file { '/etc/snmp/snmptrapd.conf':
      ensure  => present,
      mode    => '0600',
      owner   => 'root',
      group   => 'root',
      path    => '/etc/snmp/snmptrapd.conf',
      require => Class['secc_snmpd::install'],
      notify  => Class['secc_snmpd::service'],
      source  => 'puppet:///modules/secc_snmpd/etc/snmp/snmptrap.conf',
    }
  }

  file { '/etc/sysconfig/snmpd':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => '/etc/sysconfig/snmpd',
    require => Class['secc_snmpd::install'],
    notify  => Class['secc_snmpd::service'],
    source  => 'puppet:///modules/secc_snmpd/etc/sysconfig/snmpd',
  }


  #generation of snmpd.conf (template) if password & passphrase are validated
  file { '/etc/snmp/snmpd.conf':
    ensure  => present,
    content => template('secc_snmpd/etc/snmp/snmpd.conf.erb'),
    mode    => '0600',
    group   => 'root',
    owner   => 'root',
    require => Class['secc_snmpd::install'],
    notify  => Class['secc_snmpd::service'],
  }

  secc_snmpd::user{ $snmpd_v3_user:
  snmpd_v3_password   => $snmpd_v3_password,
  snmpd_v3_passphrase => $snmpd_v3_passphrase,
  }
}
