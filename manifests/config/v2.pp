define secc_snmpd::config::v2 (
  $v2_community,
  $v2_host,
) {
  # Req4,5: Password security
  # verification password length
  if size($v2_community) < 8 {
    notify {'Community must have 8 or more than 8 characters!':
      loglevel => warning,
    }

    unless defined('$_securitycheck') { $_securitycheck = true }
  }

  # verification password composition
  if !($v2_community =~ /(^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*\W))/) {
    notify {'Community must contain [a-z],[A-Z],[0-9] characters and special characters!':
      loglevel => warning,
    }

    unless defined('$_securitycheck') { $_securitycheck = true }
  }

  if defined('$_securitycheck') and $_securitycheck and $::secc_snmpd::enforce_password_security {
    notify {'Security parameters for Community not met, not configuring community!':
      loglevel => err,
    }
  } else {
    concat::fragment { "snmpd.conf_community_${v2_community}_${v2_host}":
      target  => '/etc/snmp/snmpd.conf',
      content => "rocommunity ${v2_community} ${v2_host}\n",
      order   => 05,
    }
  }

}
