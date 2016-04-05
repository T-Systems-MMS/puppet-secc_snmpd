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
			ensure 	=> present,
			mode	=> '0600',
			owner	=> 'root',
			group	=> 'root',
			path	=> '/etc/snmp/snmptrapd.conf',
			require => Class['snmpd::install'],
			notify 	=> Class['snmpd::service'],
			source 	=> 'puppet:///modules/snmpd/etc/snmp/snmptrap.conf',
		}
	}

	file { '/etc/sysconfig/snmpd':
		ensure	=> present,
		mode	=> '0644',
		owner	=> 'root',
		group	=> 'root',
		path	=> '/etc/sysconfig/snmpd',
		require => Class['snmpd::install'],
		notify  => Class['snmpd::service'],
		source 	=> 'puppet:///modules/snmpd/etc/sysconfig/snmpd',
	}

# verification password length

	$snmpd_v3_password_length = size($snmpd_v3_password)

  if $snmpd_v3_password_length < '8' {
		warning('Password must have 8 or more than 8 characters!')
  }

	# verification password composition

  elsif $snmpd_v3_password =~ /(^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*\W))/ {
		$snmpd_password_validated = true

	# verification passphrase length

    $snmpd_v3_passphrase_length = size($snmpd_v3_passphrase)

	# verification passphrase composition

    if $snmpd_v3_passphrase_length < '8' {
			warning('Passphrase must have 8 or more than 8 characters!')
    }
  	elsif $snmpd_v3_passphrase =~ /(^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*\W))/ {
				$snmpd_passphrase_validated = true
  	}
  	else {
  		warning('Passphrase must contain [a-z],[A-Z],[0-9] characters and special characters!')
  	}
  }
  else {
  	warning('Password must contain [a-z],[A-Z],[0-9] characters and special characters!')
	}

	#generation of snmpd.conf (template) if password & passphrase are validated

	if $snmpd_password_validated == true and $snmpd_passphrase_validated == true {
		file { 'snmpd.conf':
	  	ensure  => present,
	    content => template('snmpd/etc/snmp/snmpd.conf.erb'),
	    path    => '/etc/snmp/snmpd.conf',
	    mode    => '0600',
	    owner   => 'root',
	    group   => 'root',
	    require => Class['snmpd::install'],
	    notify  => Class['snmpd::service'],
	  }
	}

# creates user with net-snmp-config system command

	exec { 'create_v3_user':
		path		=> ["/usr/bin","/usr/sbin"],
		command 	=> "net-snmp-config --create-snmpv3-user -ro -A ${snmpd_v3_password} -X ${snmpd_v3_passphrase} -a SHA -x AES ${snmpd_v3_user}",
		unless 		=> "grep ${snmpd_v3_user} /var/lib/net-snmp/snmpd.conf",
		notify		=> Service['snmpd'],
	}
}
