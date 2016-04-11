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

  #generation of snmpd.conf (template) if password & passphrase are validated
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
  secc_snmpd::user{ "aresr":
    snmpd_v3_password   => "asda0ASSD!!!!",
    snmpd_v3_passphrase => "asda0ASSD!!!!a",
  }
}
