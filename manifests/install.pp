class secc_snmpd::install (
  $package_name
) {

  package { "$package_name":
    ensure  => present,
  }

}
