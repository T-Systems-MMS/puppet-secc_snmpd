define secc_snmpd::config::v3 (
  $v3_password,
  $v3_passphrase,
) {
  # Req4,5: Password security
  # verification password length
  if size($v3_password) < 8 {
    warning('Password must have 8 or more than 8 characters!')
    if $_securitycheck == undef {
      $_securitycheck = false
    }
  }

  # verification password composition
  if !($v3_password =~ /(^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*\W))/) {
    warning('Password must contain [a-z],[A-Z],[0-9] characters and special characters!')
    if $_securitycheck == undef {
      $_securitycheck = false
    }
  }

  # verification passphrase length
  if size($v3_passphrase) < 8 {
    warning('Passphrase must have 8 or more than 8 characters!')
    if $_securitycheck == undef {
      $_securitycheck = false
    }
  }

  # verification passphrase composition
  if !($v3_passphrase =~ /(^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*\W))/) {
    warning('Passphrase must contain [a-z],[A-Z],[0-9] characters and special characters!')
    if $_securitycheck == undef {
      $_securitycheck = false
    }
  }

  if $v3_password == $v3_passphrase {
    warning('Password and Passphrase are identical!')
    if $_securitycheck == undef {
      $_securitycheck = false
    }
  }

  if $_securitycheck == false and $secc_snmpd::enforce_password_security == true {
    fail('Security parameters for Password not met!')
  }

  # Req6: no additional prov needed, only read-only
  concat::fragment { "snmpd.conf_access_${title}":
    target  => '/etc/snmp/snmpd.conf',
    content => "rouser ${title}\n",
    order   => 10,
  }
  # Req2: use SHA
  concat::fragment { "snmpd.conf_user_${title}":
    target  => '/etc/snmp/snmpd.conf',
    content => "createUser ${title} SHA ${v3_password} AES ${v3_passphrase}\n",
    order   => 20,
  }

}
