class secc_snmpd::config {

  concat { '/etc/snmp/snmpd.conf':
    mode    => '0600',
    group   => 'root',
    owner   => 'root',
    require => Class['secc_snmpd::install'],
    notify  => Class['secc_snmpd::service'],
  }

  # Req3: no default user/community
  concat::fragment { 'snmpd.conf_base':
    target  => '/etc/snmp/snmpd.conf',
    content => template('secc_snmpd/etc/snmp/snmpd.conf.erb'),
    order   => 01,
  }

  if $secc_snmpd::v2_enabled {
    secc_snmpd::config::v2{ "${$secc_snmpd::v2_community}_${secc_snmpd::v2_host}":
      v2_community => $secc_snmpd::v2_community,
      v2_host      => $secc_snmpd::v2_host
    }
  }

  if $secc_snmpd::v3_enabled {
    secc_snmpd::config::v3{ $secc_snmpd::v3_user:
      v3_password   => $secc_snmpd::v3_password,
      v3_passphrase => $secc_snmpd::v3_passphrase,
    }

    exec { 'stop_snmpd':
      subscribe   => Concat['/etc/snmp/snmpd.conf'],
      refreshonly => true,
      path        => ['/usr/bin','/usr/sbin','/bin','/sbin'],
      command     => 'service snmpd stop',
      onlyif      => 'test -f /var/lib/net-snmp/snmpd.conf',
      notify      => [
        Class['secc_snmpd::service'],
        Exec['delete_usmUser']
      ],
    }

    exec { 'delete_usmUser':
      refreshonly => true,
      path        => ['/usr/bin','/usr/sbin','/bin','/sbin'],
      command     => 'grep -v usmUser /var/lib/net-snmp/snmpd.conf > /var/lib/net-snmp/snmpd.conf_new',
      onlyif      => 'test -f /var/lib/net-snmp/snmpd.conf',
      notify      => [
        Class['secc_snmpd::service'],
        Exec['move_snmpd.conf']
      ],
    }

    exec { 'move_snmpd.conf':
      refreshonly => true,
      path        => ['/usr/bin','/usr/sbin','/bin','/sbin'],
      command     => 'mv /var/lib/net-snmp/snmpd.conf_new /var/lib/net-snmp/snmpd.conf',
      onlyif      => 'test -f /var/lib/net-snmp/snmpd.conf',
      notify      => [
        Class['secc_snmpd::service']
      ],
    }
  }

  if $secc_snmpd::trap_enabled {
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
}
