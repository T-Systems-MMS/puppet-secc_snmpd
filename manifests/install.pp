class secc_snmpd::install {
  package { $::secc_snmpd::params::package_name:
    ensure   => present,
    provider => yum,
  }

  file { '/etc/sysconfig/snmpd':
    ensure  => present,
    mode    => '0640',
    owner   => 'root',
    group   => 'root',
    path    => '/etc/sysconfig/snmpd',
    content => template('secc_snmpd/etc/sysconfig/snmpd'),
    notify  => Class['secc_snmpd::service'],
  }

}
