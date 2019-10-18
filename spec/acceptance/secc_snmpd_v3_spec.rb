require 'spec_helper_acceptance'
require 'ffaker'

describe 'Class secc_snmpd' do
  context 'default snmpv3 config' do
    username = FFaker::String.from_regexp('[a-zA-Z0-9]{8}')
    password = FFaker::String.from_regexp('\w{8}aA2!')
    passphrase = FFaker::String.from_regexp('\w{9}aA2!')
    listen_ip = '127.0.0.2'

    command('service snmpd stop')

    manifest = <<-EOS
      class { 'secc_snmpd':
        service                   => 'test',
        syslocation               => 'at home',
        syscontact                => 'root@me.you',
        v3_user                   => '#{username}',
        v3_password               => '#{password}',
        v3_passphrase             => '#{passphrase}',
        listen_address            => '#{listen_ip}',
      }
    EOS

    it 'runs without errors' do
      idempotent_apply(manifest)
    end

    describe package('net-snmp') do
      it { is_expected.to be_installed }
    end

    describe service('snmpd') do
      if os[:family] == 'redhat' && os[:release].to_i >= 7
        it { is_expected.to be_enabled.under('systemd') }
        it { is_expected.to be_running.under('systemd') }
      else
        it { is_expected.to be_enabled }
        it { is_expected.to be_running }
      end
    end

    describe file('/etc/sysconfig/snmpd') do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
      it { is_expected.to be_mode 640 }
      its(:content) { is_expected.to include 'OPTIONS="-LS0-5d -Lf /dev/null -p /var/run/snmpd.pid 127.0.0.1 127.0.0.2"' }
    end

    describe file('/etc/snmp/snmpd.conf') do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
      it { is_expected.to be_mode 600 }
      its(:content) { is_expected.to include 'MANAGED BY PUPPET [secc_snmpd]' }
      its(:content) { is_expected.to include 'syscontact test root@me.you' }
      its(:content) { is_expected.to include 'syslocation at home' }
      its(:content) { is_expected.to include "rouser #{username} priv" }
    end

    describe file('/var/lib/net-snmp/snmpd.conf') do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
      it { is_expected.to be_mode 600 }
      its(:content) { is_expected.to contain "usmUser.*0x.*(#{username}|#{username.each_byte.map { |b| b.to_s(16) }.join})" }
    end

    describe port(161) do
      it { is_expected.to be_listening.on('127.0.0.1').with('udp') }
      it { is_expected.to be_listening.on(listen_ip).with('udp') }
    end
  end

  context 'default snmpv3 config, weak passwords and enforcing' do
    it 'does not accept weak password/passphrase' do
      manifest = <<-EOS
        class { 'secc_snmpd':
            service                   => 'test',
            syslocation               => 'at home',
            syscontact                => 'root@me.you',
            v3_user                   => 'testuser',
            v3_password               => 'pass',
            v3_passphrase             => 'pass',
          }
      EOS
      result = apply_manifest(manifest, catch_failures: true)
      expect(result.exit_code).to eq(2)
      expect(result.stderr).to include 'Warning: v3 user testuser - Password must have 8 or more than 8 characters!'
      expect(result.stderr).to include 'Warning: v3 user testuser - Password must contain [a-z],[A-Z],[0-9] characters and special characters!'
      expect(result.stderr).to include 'Warning: v3 user testuser - Passphrase must have 8 or more than 8 characters!'
      expect(result.stderr).to include 'Warning: v3 user testuser - Passphrase must contain [a-z],[A-Z],[0-9] characters and special characters!'
      expect(result.stderr).to include 'Warning: v3 user testuser - Password and Passphrase are identical!'
      expect(result.stderr).to include 'Error: v3 user testuser - Security parameters for Password or Passphrase not met, not configuring user!'
    end

    describe file('/etc/snmp/snmpd.conf') do
      its(:content) { is_expected.not_to include 'rouser' }
    end
  end

  context 'default snmpv3 config, weak passwords' do
    it 'does not accept weak password/passphrase' do
      manifest = <<-EOS
        class { 'secc_snmpd':
            service                   => 'test',
            syslocation               => 'at home',
            syscontact                => 'root@me.you',
            v3_user                   => 'testuser',
            v3_password               => 'pass',
            v3_passphrase             => 'pass',
            enforce_password_security => false,
          }
      EOS
      result = apply_manifest(manifest, catch_failures: true)
      expect(result.exit_code).to eq(2)
      expect(result.stderr).to include 'Warning: v3 user testuser - Password must have 8 or more than 8 characters!'
      expect(result.stderr).to include 'Warning: v3 user testuser - Password must contain [a-z],[A-Z],[0-9] characters and special characters!'
      expect(result.stderr).to include 'Warning: v3 user testuser - Passphrase must have 8 or more than 8 characters!'
      expect(result.stderr).to include 'Warning: v3 user testuser - Passphrase must contain [a-z],[A-Z],[0-9] characters and special characters!'
      expect(result.stderr).to include 'Warning: v3 user testuser - Password and Passphrase are identical!'
    end

    describe file('/etc/snmp/snmpd.conf') do
      its(:content) { is_expected.to include 'rouser' }
    end
  end

  context 'default snmpv3 config, password change' do
    username = FFaker::String.from_regexp('[a-zA-Z0-9]{8}')
    password = FFaker::String.from_regexp('\w{8}aA2!')
    passphrase = FFaker::String.from_regexp('\w{8}bB2!')

    command('service snmpd stop')

    manifest = <<-EOS
      class { 'secc_snmpd':
        service                   => 'test',
        syslocation               => 'at home',
        syscontact                => 'root@me.you',
        v3_user                   => '#{username}',
        v3_password               => '#{password}',
        v3_passphrase             => '#{passphrase}',
      }
    EOS

    manifest2 = <<-EOS
      class { 'secc_snmpd':
        service                   => 'test',
        syslocation               => 'at home',
        syscontact                => 'root@me.you',
        v3_user                   => '#{username}',
        v3_password               => '#{password}2',
        v3_passphrase             => '#{passphrase}2',
      }
    EOS

    it 'runs without errors' do
      idempotent_apply(manifest)
    end

    it 'runs without errors and new password' do
      # save old password
      coded_username = username.each_byte.map { |b| b.to_s(16) }.join
      run_shell("grep -e 'usm.*#{username}' -e 'usm.*#{coded_username}' /var/lib/net-snmp/snmpd.conf > /tmp/saved_password")

      result = apply_manifest(manifest2, catch_failures: true)
      expect(result.exit_code).to eq(2)
      expect(result.stdout).to include "stop_snmpd_#{username}"
      expect(result.stdout).to include "delete_usmUser_#{username}"
      expect(result.stdout).to include "snmp_user_#{username}"
      cfgfile = file('/var/lib/net-snmp/snmpd.conf')
      expect(cfgfile).to be_file
    end

    it 'deletes the old password' do
      # user is still there
      expect(run_shell('grep "$(awk \'{print $6}\' /tmp/saved_password)" /var/lib/net-snmp/snmpd.conf').stdout).to include 'usmUser'
      # but with different password
      expect(run_shell('grep -c "$(cat /tmp/saved_password)" /var/lib/net-snmp/snmpd.conf', expect_failures: true).stdout).to eq("0\n")
    end

    it 're-runs without changes and new password' do
      expect(apply_manifest(manifest2, catch_changes: true).exit_code).to be_zero
    end
  end

  context 'snmpv3 config with weak passwords' do
    username = FFaker::String.from_regexp('[a-zA-Z0-9]{6}')
    password = FFaker::String.from_regexp('\w{8}')
    passphrase = FFaker::String.from_regexp('\w{8}')

    command('service snmpd stop')

    manifest = <<-EOS
      class { 'secc_snmpd':
        service                   => 'test',
        syslocation               => 'at home',
        syscontact                => 'root@me.you',
        v3_user                   => '#{username}',
        v3_password               => '#{password}',
        v3_passphrase             => '#{passphrase}',
        enforce_password_security => false,
      }
    EOS

    it 'runs without errors' do
      result = apply_manifest(manifest, catch_failures: true)
      expect(result.exit_code).to eq(2)
      expect(result.stderr).to include "Warning: v3 user #{username} - Password must contain [a-z],[A-Z],[0-9] characters and special characters!"
      expect(result.stderr).to include "Warning: v3 user #{username} - Passphrase must contain [a-z],[A-Z],[0-9] characters and special characters!"
    end
    # no re-run check, because constant error with weak password
  end

  context 'snmpv3 config with weak passwords and multiple user' do
    username = FFaker::String.from_regexp('[a-zA-Z0-9]{6}')
    password = FFaker::String.from_regexp('\w{8}')
    passphrase = FFaker::String.from_regexp('\w{8}')

    command('service snmpd stop')

    manifest = <<-EOS
      class { 'secc_snmpd':
        service                   => 'test',
        syslocation               => 'at home',
        syscontact                => 'root@me.you',
        v3_user                   => '#{username}',
        v3_password               => '#{password}',
        v3_passphrase             => '#{passphrase}',
        enforce_password_security => false,
      }

      secc_snmpd::config::v3{ '#{username}1':
        v3_password   => '#{password}',
        v3_passphrase => '#{passphrase}',
      }
    EOS

    it 'runs without errors' do
      result = apply_manifest(manifest, catch_failures: true)
      expect(result.exit_code).to eq(2)
      expect(result.stderr).to include "Warning: v3 user #{username} - Password must contain [a-z],[A-Z],[0-9] characters and special characters!"
      expect(result.stderr).to include "Warning: v3 user #{username} - Passphrase must contain [a-z],[A-Z],[0-9] characters and special characters!"
    end
    # no re-run check, because constant error with weak password

    describe file('/etc/snmp/snmpd.conf') do
      its(:content) { is_expected.to include "rouser #{username} priv" }
      its(:content) { is_expected.to include "rouser #{username}1 priv" }
    end
  end
end
