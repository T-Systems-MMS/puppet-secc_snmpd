class secc_snmpd::params {
  $snmpd_trap_enabled = false
  $snmpd_v2_enabled = false

  case $::operatingsystem {
    default: {
      $package_name = 'net-snmp'
    }
  }
}