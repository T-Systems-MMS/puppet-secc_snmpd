class secc_snmpd::config inherits secc_snmpd {

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

  exec { 'stop_snmpd':
    subscribe   => File['/etc/snmp/snmpd.conf'],
    refreshonly => true,
    command     => "/sbin/service snmpd stop",
    notify      => [
      Class['secc_snmpd::service'],
      Exec['delete_usmUser']
    ],
  }

  exec { 'delete_usmUser':
    subscribe   => File['/etc/snmp/snmpd.conf'],
    refreshonly => true,
    command     => "/bin/grep -v usmUser /var/lib/net-snmp/snmpd.conf  > /var/lib/net-snmp/snmpd.conf_new",
    notify      => [
      Class['secc_snmpd::service'],
      Exec['move_snmpd.conf']
    ],
  }

  exec { 'move_snmpd.conf':
    subscribe   => File['/etc/snmp/snmpd.conf'],
    refreshonly => true,
    command     => "/bin/mv /var/lib/net-snmp/snmpd.conf_new /var/lib/net-snmp/snmpd.conf",
    notify      => [
      Class['secc_snmpd::service']
    ],
  }

  concat { '/etc/snmp/snmpd.conf':
    mode    => '0600',
    group   => 'root',
    owner   => 'root',
    require => Class['secc_snmpd::install'],
    notify  => Class['secc_snmpd::service'],
  }

  concat::fragment { "snmpd.conf_base":
    target  => '/etc/snmp/snmpd.conf',
    content => template('secc_snmpd/etc/snmp/snmpd.conf.erb'),
    order   => 01,
  }

  secc_snmpd::user{ $snmpd_v3_user:
    snmpd_v3_password   => $snmpd_v3_password,
    snmpd_v3_passphrase => $snmpd_v3_passphrase,
  }

}
