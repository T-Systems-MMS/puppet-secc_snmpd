class secc_snmpd::params {
  $trap_enabled = false
  $v2_enabled = false
  $v3_enabled = true
  $v2_community = undef
  $v2_host = undef
  $v3_user = undef
  $v3_password = undef
  $v3_passphrase = undef
  $enforce_password_security = false

  case $::operatingsystem {
    default: {
      $package_name = 'net-snmp'
    }
  }
}