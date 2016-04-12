class secc_snmpd::install inherits secc_snmpd {
  package { "$package_name":
    ensure  => present,
  }

  file { '/etc/sysconfig/snmpd':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => '/etc/sysconfig/snmpd',
    notify  => Class['secc_snmpd::service'],
    source  => 'puppet:///modules/secc_snmpd/etc/sysconfig/snmpd',
  }
}
