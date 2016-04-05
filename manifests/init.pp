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
	$snmpd_trap_enabled = false,
	$snmpd_v2_enabled = false,
	$snmpd_syslocation,
	$snmpd_syscontact
) {

$package_name 	  = 'net-snmp'

	class { 'secc_snmpd::install':
		package_name 	  => $package_name,
	}

	class { 'secc_snmpd::config':
		service		    			=> $service,
		snmpd_communityhost => $snmpd_communityhost,
		snmpd_syslocation   => $snmpd_syslocation,
		snmpd_syscontact    => $snmpd_syscontact,
		snmpd_v3_user	    	=> $snmpd_v3_user,
		snmpd_v3_password   => $snmpd_v3_password,
		snmpd_v3_passphrase => $snmpd_v3_passphrase,
		snmpd_trap_enabled  => $snmpd_trap_enabled,
		snmpd_v2_enabled    => $snmpd_v2_enabled,
	}

	class { 'secc_snmpd::service':
		snmpd_trap_enabled  => $snmpd_trap_enabled,
	}
}
