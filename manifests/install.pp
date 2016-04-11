class secc_snmpd::install inherits secc_snmpd {
  package { "$package_name":
    ensure  => present,
  }
}
