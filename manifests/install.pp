class secc_snmpd::install (
  $package_name
) {

  package { "$package_name":
    ensure  => present,
  }

  # package net-snmp-devel is necessary for exec command under RedHat
  if $::osfamily == 'RedHat' {
    package { 'net-snmp-devel':
      ensure => present,
    }
  }
}
