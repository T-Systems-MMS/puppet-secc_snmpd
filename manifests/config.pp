class secc_snmpd::config {

  concat { '/etc/snmp/snmpd.conf':
    mode    => '0600',
    group   => 'root',
    owner   => 'root',
    require => Class['secc_snmpd::install'],
    notify  => Class['secc_snmpd::service'],
  }

  file { '/var/lib/net-snmp/':
    ensure => directory,
    mode   => '0600',
    owner  => 'root',
    group  => 'root',
    require => Class['secc_snmpd::install'],
  }

  file { '/var/lib/net-snmp/snmpd.conf':
    ensure => present,
    mode   => '0600',
    owner  => 'root',
    group  => 'root',
    require => Class['secc_snmpd::install'],
  }
  # Req3: no default user/community
  concat::fragment { 'snmpd.conf_base':
    target  => '/etc/snmp/snmpd.conf',
    content => template('secc_snmpd/etc/snmp/snmpd.conf.erb'),
    order   => 01,
  }

  if $::secc_snmpd::v2_enabled {
    secc_snmpd::config::v2{ "${::secc_snmpd::v2_community}_${::secc_snmpd::v2_host}":
      v2_community => $::secc_snmpd::v2_community,
      v2_host      => $::secc_snmpd::v2_host
    }
  }

  if $::secc_snmpd::v3_enabled {
    concat { '/var/lib/net-snmp/pw_history.log':
      mode    => '0600',
      group   => 'root',
      owner   => 'root',
      require => [ Class['secc_snmpd::install'], File['/var/lib/net-snmp/'] ],
      notify  => Class['secc_snmpd::service'],
    }

    secc_snmpd::config::v3{ $::secc_snmpd::v3_user:
      v3_password   => $::secc_snmpd::v3_password,
      v3_passphrase => $::secc_snmpd::v3_passphrase,
    }

  }

  if $::secc_snmpd::trap_enabled {
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
