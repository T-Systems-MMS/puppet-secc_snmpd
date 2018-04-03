define secc_snmpd::config::v3 (
  $v3_password,
  $v3_passphrase,
) {
  # Req4,5: Password security
  # verification password length
  if size($v3_password) < 8 {
    notify {'Password must have 8 or more than 8 characters!':
      loglevel => warning,
    }

    if $_securitycheck == undef {
      $_securitycheck = false
    }
  }

  # verification password composition
  if !($v3_password =~ /(^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*\W))/) {
    notify {'Password must contain [a-z],[A-Z],[0-9] characters and special characters!':
      loglevel => warning,
    }

    if $_securitycheck == undef {
      $_securitycheck = false
    }
  }

  # verification passphrase length
  if size($v3_passphrase) < 8 {
    notify {'Passphrase must have 8 or more than 8 characters!':
      loglevel => warning,
    }

    if $_securitycheck == undef {
      $_securitycheck = false
    }
  }

  # verification passphrase composition
  if !($v3_passphrase =~ /(^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*\W))/) {
    notify {'Passphrase must contain [a-z],[A-Z],[0-9] characters and special characters!':
      loglevel => warning,
    }

    if $_securitycheck == undef {
      $_securitycheck = false
    }
  }

  if $v3_password == $v3_passphrase {
    notify {'Password and Passphrase are identical!':
      loglevel => warning,
    }

    if $_securitycheck == undef {
      $_securitycheck = false
    }
  }

  if $_securitycheck == false and $::secc_snmpd::enforce_password_security == true {
    notify {'Security parameters for Password or Passphrase not met, not configuring user!':
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
