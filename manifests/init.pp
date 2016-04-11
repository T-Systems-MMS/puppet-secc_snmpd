####################################################
## Achtung das Passwort und der Passphrase dürfen ##
## KEIN Semikolon enthalten. exec in der Klasse   ##
## config funktioniert sonst nicht!               ##
####################################################

class secc_snmpd (
  $service,
  $snmpd_communityhost,
  $snmpd_v3_user,
  $snmpd_v3_password,
  $snmpd_v3_passphrase,
  $snmpd_trap_enabled = $secc_snmpd::params::snmpd_trap_enabled,
  $snmpd_v2_enabled = $secc_snmpd::params::snmpd_v2_enabled,
  $snmpd_syslocation,
  $snmpd_syscontact,
) inherits secc_snmpd::params {

  include secc_snmpd::install

  include secc_snmpd::config

  include secc_snmpd::service
}
