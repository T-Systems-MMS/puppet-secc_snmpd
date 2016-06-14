class secc_snmpd::install {
  package { $secc_snmpd::params::package_name:
    ensure => present,
  }

  file { '/etc/sysconfig/snmpd':
    ensure => present,
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    path   => '/etc/sysconfig/snmpd',
    notify => Class['secc_snmpd::service'],
    source => 'puppet:///modules/secc_snmpd/etc/sysconfig/snmpd',
  }
}
