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
  $listen_address            = $::secc_snmpd::params::listen_address,
  $trap_enabled              = $::secc_snmpd::params::trap_enabled,
  $enforce_password_security = $::secc_snmpd::params::enforce_password_security,
  $dlmod_enabled             = $::secc_snmpd::params::dlmod_enabled,
) inherits secc_snmpd::params {

  # true if $::puppetversion < '4.0.0'
  if versioncmp($::puppetversion, '4.0.0') < 0 {
    validate_bool($::secc_snmpd::v2_enabled)
    validate_bool($::secc_snmpd::v3_enabled)
    validate_bool($::secc_snmpd::enforce_password_security)
    validate_bool($::secc_snmpd::dlmod_enabled)
} else {
    validate_legacy('Boolean', 'validate_bool', $::secc_snmpd::v2_enabled)
    validate_legacy('Boolean', 'validate_bool', $::secc_snmpd::v3_enabled)
    validate_legacy('Boolean', 'validate_bool', $::secc_snmpd::enforce_password_security)
    validate_legacy('Boolean', 'validate_bool', $::secc_snmpd::dlmod_enabled)
  }

  if $::secc_snmpd::v2_enabled {
    # Req1: warning if v2 enabled
    notify {'use of SNMPv2 is not recommended!':
      loglevel => warning,
    }

    if $::secc_snmpd::v2_community == undef {
      fail('v2_community is needed')
    }
    if $::secc_snmpd::v2_host == undef {
      fail('v2_host is needed')
    }
  }

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

  contain secc_snmpd::install

  contain secc_snmpd::config

  contain secc_snmpd::service
}
