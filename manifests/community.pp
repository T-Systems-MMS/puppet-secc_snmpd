define secc_snmpd::community (
  $v2_community,
  $v2_host,
) {
  # verification password length
  if size($v2_community) < '8' {
    warning('Community must have 8 or more than 8 characters!')
    if $_securitycheck == undef {
      $_securitycheck = false
    }
  }

  # verification password composition
  if !($v2_community =~ /(^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*\W))/) {
    warning('Community must contain [a-z],[A-Z],[0-9] characters and special characters!')
    if $_securitycheck == undef {
      $_securitycheck = false
    }
  }

  if $_securitycheck == false and $secc_snmpd::enforce_password_security == true {
    fail("Security parameters for Community not met!")
  }

  concat::fragment { "snmpd.conf_community_${$v2_community}_${v2_host}":
    target  => '/etc/snmp/snmpd.conf',
    content => "rocommunity ${$v2_community} ${v2_host}\n",
    order   => 05,
  }

}