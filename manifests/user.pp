define secc_snmpd::user (
  $snmpd_v3_password,
  $snmpd_v3_passphrase,
) {
  # verification password length
  if size($snmpd_v3_password) < '8' {
    warning('Password must have 8 or more than 8 characters!')
    if $_securitycheck == undef {
      $_securitycheck = false
    }
  }

  # verification password composition
  if !($snmpd_v3_password =~ /(^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*\W))/) {
    warning('Password must contain [a-z],[A-Z],[0-9] characters and special characters!')
    if $_securitycheck == undef {
      $_securitycheck = false
    }
  }

  # verification passphrase length
  if size($snmpd_v3_passphrase) < '8' {
    warning('Passphrase must have 8 or more than 8 characters!')
    if $_securitycheck == undef {
      $_securitycheck = false
    }
  }

  # verification passphrase composition
  if !($snmpd_v3_passphrase =~ /(^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*\W))/) {
    warning('Passphrase must contain [a-z],[A-Z],[0-9] characters and special characters!')
    if $_securitycheck == undef {
      $_securitycheck = false
    }
  }

  if $snmpd_v3_password == $snmpd_v3_passphrase {
    warning('Password and Passphrase are identical!')
    if $_securitycheck == undef {
      $_securitycheck = false
    }
  }

  if $_securitycheck == false {
    fail("Security parameters for Password not met!")
  }

  concat::fragment { "snmpd.conf_access_${title}":
    target  => '/etc/snmp/snmpd.conf',
    content => "rouser ${title}\n",
    order   => 10,
  }
  concat::fragment { "snmpd.conf_user_${title}":
    target  => '/etc/snmp/snmpd.conf',
    content => "createUser ${title} SHA ${snmpd_v3_password} AES ${snmpd_v3_passphrase}\n",
    order   => 20,
  }

}