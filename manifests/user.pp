define secc_snmpd::user (
  $snmpd_v3_password,
  $snmpd_v3_passphrase,
) {
  # verification password length
  if size($snmpd_v3_password) < '8' {
    warning('Password must have 8 or more than 8 characters!')
    if $securitycheck == undef {
      $securitycheck = false
    }
  }

  # verification password composition
  if !($snmpd_v3_password =~ /(^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*\W))/) {
    warning('Password must contain [a-z],[A-Z],[0-9] characters and special characters!')
    if $securitycheck == undef {
      $securitycheck = false
    }
  }

  # verification passphrase length
  if size($snmpd_v3_passphrase) < '8' {
    warning('Passphrase must have 8 or more than 8 characters!')
    if $securitycheck == undef {
      $securitycheck = false
    }
  }

  # verification passphrase composition
  if !($snmpd_v3_passphrase =~ /(^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*\W))/) {
    warning('Passphrase must contain [a-z],[A-Z],[0-9] characters and special characters!')
    if $securitycheck == undef {
      $securitycheck = false
    }
  }

  if $snmpd_v3_password == $snmpd_v3_passphrase {
    warning('Password and Passphrase are identical!')
    if $securitycheck == undef {
      $securitycheck = false
    }
  }

  if $securitycheck == false {
    fail("Security parameters for Password not met!")
  }

  # creates user
  # TODO: write users to /vat/lib/net-snmp/snmpd.conf, problem: how to change password?
  file_line { "create_v3_user_${title}":
    path      => "/etc/snmp/snmpd.conf",
    line      => "createUser ${title} SHA ${snmpd_v3_password} AES ${snmpd_v3_passphrase}",
    match     => "^createUser ${title} SHA ${snmpd_v3_password} AES ${snmpd_v3_passphrase}",
    notify    => Service['snmpd'],
    require   => File['/etc/snmp/snmpd.conf'],
  }
  file_line { "create_v3_access_${title}":
    path      => "/etc/snmp/snmpd.conf",
    line      => "rouser ${title}",
    match     => "^rouser ${title}",
    notify    => Service['snmpd'],
    require   => File['/etc/snmp/snmpd.conf'],
  }


}