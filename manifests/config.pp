class secc_snmpd::config (
  $service,
  $snmpd_communityhost,
  $snmpd_syslocation,
  $snmpd_syscontact,
  $snmpd_v3_user,
  $snmpd_v3_password,
  $snmpd_v3_passphrase,
  $snmpd_trap_enabled,
  $snmpd_v2_enabled
) {

  if $snmpd_trap_enabled == true {
    file { '/etc/snmp/snmptrapd.conf':
      ensure  => present,
      mode    => '0600',
      owner   => 'root',
      group   => 'root',
      path    => '/etc/snmp/snmptrapd.conf',
      require => Class['secc_snmpd::install'],
      notify  => Class['secc_snmpd::service'],
      source  => 'puppet:///modules/secc_snmpd/etc/snmp/snmptrap.conf',
    }
  }

  file { '/etc/sysconfig/snmpd':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => '/etc/sysconfig/snmpd',
    require => Class['secc_snmpd::install'],
    notify  => Class['secc_snmpd::service'],
    source  => 'puppet:///modules/secc_snmpd/etc/sysconfig/snmpd',
  }

  # verification password length
  $snmpd_v3_password_length = size($snmpd_v3_password)
  if $snmpd_v3_password_length < '8' {
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
  $snmpd_v3_passphrase_length = size($snmpd_v3_passphrase)
  if $snmpd_v3_passphrase_length < '8' {
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

  #generation of snmpd.conf (template) if password & passphrase are validated
  file { '/etc/snmp/snmpd.conf':
    ensure  => present,
    content => template('secc_snmpd/etc/snmp/snmpd.conf.erb'),
    mode    => '0600',
    group   => 'root',
    owner   => 'root',
    require => Class['secc_snmpd::install'],
    notify  => Class['secc_snmpd::service'],
  }

  # creates user with net-snmp-config system command
  file_line { 'create_v3_user':
    path      => "/etc/snmp/snmpd.conf",
    line      => "createUser ${snmpd_v3_user} SHA ${snmpd_v3_password} AES ${snmpd_v3_passphrase}",
    match     => "^createUser ${snmpd_v3_user} SHA ${snmpd_v3_password} AES ${snmpd_v3_passphrase}",
    notify    => Service['snmpd'],
    require   => File['/etc/snmp/snmpd.conf'],
  }
}
