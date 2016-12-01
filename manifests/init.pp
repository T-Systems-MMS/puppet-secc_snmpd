#####################################################
## Achtung das Passwort und der Passphrase duerfen ##
## KEIN Semikolon enthalten. exec in der Klasse    ##
## config funktioniert sonst nicht!                ##
#####################################################

class secc_snmpd (
  $service,
  $syslocation,
  $syscontact,
  $v2_enabled                = $::secc_snmpd::params::v2_enabled,
  $v2_community              = $::secc_snmpd::params::v2_community,
  $v2_host                   = $::secc_snmpd::params::v2_host,
  $v3_enabled                = $::secc_snmpd::params::v3_enabled,
  $v3_user                   = $::secc_snmpd::params::v3_user,
  $v3_password               = $::secc_snmpd::params::v3_password,
  $v3_passphrase             = $::secc_snmpd::params::v3_passphrase,
  $trap_enabled              = $::secc_snmpd::params::trap_enabled,
  $enforce_password_security = $::secc_snmpd::params::enforce_password_security,
) inherits secc_snmpd::params {

  validate_bool($::secc_snmpd::v2_enabled)
  if $::secc_snmpd::v2_enabled {
    # Req1: warning if v2 enabled
    warning('use of SNMPv2 is not recommended!')

    if $::secc_snmpd::v2_community == undef {
      fail('v2_community is needed')
    }
    if $::secc_snmpd::v2_host == undef {
      fail('v2_host is needed')
    }
  }

  validate_bool($::secc_snmpd::v3_enabled)
  if $::secc_snmpd::v3_enabled {
    if $::secc_snmpd::v3_user == undef {
      fail('v3_user is needed')
    }
    if $::secc_snmpd::v3_password == undef {
      fail('v3_password is needed')
    }
    if $::secc_snmpd::v3_passphrase == undef {
      fail('v3_passphrase is needed')
    }
  }

  validate_bool($::secc_snmpd::enforce_password_security)

  contain secc_snmpd::install

  contain secc_snmpd::config

  contain secc_snmpd::service
}
