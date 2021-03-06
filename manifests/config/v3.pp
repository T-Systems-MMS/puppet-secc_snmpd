define secc_snmpd::config::v3 (
  $v3_password,
  $v3_passphrase,
) {
  # Req4,5: Password security
  # verification password length
  if size($v3_password) < 8 {
    notify {"v3 user ${title} - Password must have 8 or more than 8 characters!":
      loglevel => warning,
    }

    unless defined('$_securitycheck') { $_securitycheck = true }
  }

  # verification password composition
  if !($v3_password =~ /(^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*\W))/) {
    notify {"v3 user ${title} - Password must contain [a-z],[A-Z],[0-9] characters and special characters!":
      loglevel => warning,
    }

    unless defined('$_securitycheck') { $_securitycheck = true }
  }

  # verification passphrase length
  if size($v3_passphrase) < 8 {
    notify {"v3 user ${title} - Passphrase must have 8 or more than 8 characters!":
      loglevel => warning,
    }

    unless defined('$_securitycheck') { $_securitycheck = true }
  }

  # verification passphrase composition
  if !($v3_passphrase =~ /(^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*\W))/) {
    notify {"v3 user ${title} - Passphrase must contain [a-z],[A-Z],[0-9] characters and special characters!":
      loglevel => warning,
    }

    unless defined('$_securitycheck') { $_securitycheck = true }
  }

  if $v3_password == $v3_passphrase {
    notify {"v3 user ${title} - Password and Passphrase are identical!":
      loglevel => warning,
    }

    unless defined('$_securitycheck') { $_securitycheck = true }
  }

  if defined('$_securitycheck') and $_securitycheck and $::secc_snmpd::enforce_password_security {
    notify {"v3 user ${title} - Security parameters for Password or Passphrase not met, not configuring user!":
      loglevel => err,
    }
  } else {
    $user_hex = bin_to_hex($title)

    # Req6: priv needed, only read-only
    concat::fragment { "snmpd.conf_access_${title}":
      target  => '/etc/snmp/snmpd.conf',
      content => "rouser ${title} priv\n",
      order   => 10,
    }

    concat::fragment { "pw_retention_${title}":
      target  => '/var/lib/net-snmp/pw_history.log',
      content => sprintf('%s = %s\n', $title, sha1("${v3_password}${v3_passphrase}")),
      order   => 01,
    }

    exec { "stop_snmpd_${title}":
      subscribe   => Concat['/var/lib/net-snmp/pw_history.log'],
      refreshonly => true,
      path        => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
      command     => 'service snmpd stop',
      onlyif      => 'test -f /var/lib/net-snmp/snmpd.conf',
      notify      => [
        Exec["delete_usmUser_${title}"]
      ],
    }

    exec { "delete_usmUser_${title}":
      refreshonly => true,
      path        => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
      command     => "sed -i -e '/usmUser.*${title}/d' -e '/usmUser.*${user_hex}/d' /var/lib/net-snmp/snmpd.conf",
      onlyif      => 'test -f /var/lib/net-snmp/snmpd.conf',
      notify      => [
        File_line["snmp_user_${title}"],
      ],
    }

    # Req2: use SHA
    file_line { "snmp_user_${title}":
      path    => '/var/lib/net-snmp/snmpd.conf',
      line    => "createUser ${title} SHA ${v3_password} AES ${v3_passphrase}",
      match   => "usmUser.*(${title}|${user_hex})",
      replace => false,
      require => [
        File['/var/lib/net-snmp/snmpd.conf'],
        Concat::Fragment["pw_retention_${title}"],
      ],
      notify  => [
        Class['secc_snmpd::service'],
      ]
    }
  }

}
