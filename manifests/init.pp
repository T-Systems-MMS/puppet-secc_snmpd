####################################################
## Achtung das Passwort und der Passphrase dürfen ##
## KEIN Semikolon enthalten. exec in der Klasse   ##
## config funktioniert sonst nicht!               ##
####################################################

class secc_snmpd (
  $service,
  $v2_enabled = $secc_snmpd::params::v2_enabled,
  $v2_community =  $secc_snmpd::params::v2_community,
  $v2_host =  $secc_snmpd::params::v2_host,
  $v3_enabled = $secc_snmpd::params::v3_enabled,
  $v3_user =  $secc_snmpd::params::v3_user,
  $v3_password = $secc_snmpd::params::v3_password,
  $v3_passphrase = $secc_snmpd::params::v3_passphrase,
  $trap_enabled = $secc_snmpd::params::trap_enabled,
  $syslocation,
  $syscontact,
) inherits secc_snmpd::params {
  if $v2_enabled {
    warning("use of SNMPv2 is not recommended!")

    if $v2_community == undef {
      fail('v2_community is needed')
    }
    if $v2_host == undef {
      fail('v2_host is needed')
    }
  }

  if $v3_enabled {
    if $v3_user == undef {
      fail('v3_user is needed')
    }
    if $v3_password == undef {
      fail('v3_password is needed')
    }
    if $v3_passphrase == undef {
      fail('v3_passphrase is needed')
    }
  }
  include secc_snmpd::install

  include secc_snmpd::config

  include secc_snmpd::service
}
