require 'spec_helper_acceptance'
require 'ffaker'

describe 'Class secc_snmpd' do
  context 'default snmpv3 config' do
    username = FFaker::String.from_regexp(/[a-zA-Z0-9]{8}/)
    password = FFaker::String.from_regexp(/\w{8}aA2!/)
    passphrase = FFaker::String.from_regexp(/\w{8}aA2!/)
    listen_ip = "127.0.0.2"

    command("service snmpd stop")

    let(:manifest) {
    <<-EOS
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
    }

    it 'should run without errors' do
      expect(apply_manifest(manifest, :catch_failures => true).exit_code).to eq(2)
    end

    it 'should re-run without changes' do
      expect(apply_manifest(manifest, :catch_changes => true).exit_code).to be_zero
    end

    describe package('net-snmp') do
      it { is_expected.to be_installed }
    end

    describe service('snmpd') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
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
  end

  context 'default snmpv3 config, weak passwords and enforcing' do

    it 'should not accept weak password/passphrase' do
      manifest =     <<-EOS
        class { 'secc_snmpd':
            service                   => 'test',
            syslocation               => 'at home',
            syscontact                => 'root@me.you',
            v3_user                   => 'testuser',
            v3_password               => 'pass',
            v3_passphrase             => 'pass',
          }
      EOS
      result = apply_manifest(manifest, :catch_failures => true)
      expect(result.exit_code).to eq(2)
      expect(result.output).to include 'Warning: Password must have 8 or more than 8 characters!'
      expect(result.output).to include 'Warning: Password must contain [a-z],[A-Z],[0-9] characters and special characters!'
      expect(result.output).to include 'Warning: Passphrase must have 8 or more than 8 characters!'
      expect(result.output).to include 'Warning: Passphrase must contain [a-z],[A-Z],[0-9] characters and special characters!'
      expect(result.output).to include 'Warning: Password and Passphrase are identical!'
      expect(result.output).to include 'Error: Security parameters for Password or Passphrase not met, not configuring user!'
    end

    describe file('/etc/snmp/snmpd.conf') do
      its(:content) { is_expected.not_to include "rouser" }
    end

  end

  context 'default snmpv3 config, weak passwords' do

    it 'should not accept weak password/passphrase' do
      manifest =     <<-EOS
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
      result = apply_manifest(manifest, :catch_failures => true)
      expect(result.exit_code).to eq(2)
      expect(result.output).to include 'Warning: Password must have 8 or more than 8 characters!'
      expect(result.output).to include 'Warning: Password must contain [a-z],[A-Z],[0-9] characters and special characters!'
      expect(result.output).to include 'Warning: Passphrase must have 8 or more than 8 characters!'
      expect(result.output).to include 'Warning: Passphrase must contain [a-z],[A-Z],[0-9] characters and special characters!'
      expect(result.output).to include 'Warning: Password and Passphrase are identical!'
    end

    describe file('/etc/snmp/snmpd.conf') do
      its(:content) { is_expected.to include "rouser" }
    end

  end

  context 'default snmpv3 config, password change' do
    username = FFaker::String.from_regexp(/[a-zA-Z0-9]{8}/)
    password = FFaker::String.from_regexp(/\w{8}aA2!/)
    passphrase = FFaker::String.from_regexp(/\w{8}bB2!/)

    command("service snmpd stop")

    let(:manifest) {
    <<-EOS
      class { 'secc_snmpd':
        service                   => 'test',
        syslocation               => 'at home',
        syscontact                => 'root@me.you',
        v3_user                   => '#{username}',
        v3_password               => '#{password}',
        v3_passphrase             => '#{passphrase}',
      }
    EOS
    }

    let(:manifest2) {
    <<-EOS
      class { 'secc_snmpd':
        service                   => 'test',
        syslocation               => 'at home',
        syscontact                => 'root@me.you',
        v3_user                   => '#{username}',
        v3_password               => '#{password}2',
        v3_passphrase             => '#{passphrase}2',
      }
    EOS
    }

    it 'should run without errors' do
      expect(apply_manifest(manifest, :catch_failures => true).exit_code).to eq(2)
    end

    it 'should re-run without changes' do
      expect(apply_manifest(manifest, :catch_changes => true).exit_code).to be_zero
    end

    it 'should run without errors and new password' do
      checkline = command("grep -e 'usm.*#{username}' -e 'usm.*#{username.each_byte.map { |b| b.to_s(16) }.join}' /var/lib/net-snmp/snmpd.conf").stdout
      result = apply_manifest(manifest2, :catch_failures => true)
      expect(result.exit_code).to eq(2)
      expect(result.output).to include "stop_snmpd_#{username}"
      expect(result.output).to include "delete_usmUser_#{username}"
      expect(result.output).to include "snmp_user_#{username}"
      cfgfile = file("/var/lib/net-snmp/snmpd.conf")
      expect(cfgfile).to be_file
      expect(cfgfile.content).not_to include checkline
    end

    it 'should re-run without changes and new password' do
      expect(apply_manifest(manifest2, :catch_changes => true).exit_code).to be_zero
    end


  end

  context 'snmpv3 config with weak passwords' do
    username = FFaker::String.from_regexp(/[a-zA-Z0-9]{6}/)
    password = FFaker::String.from_regexp(/\w{8}/)
    passphrase = FFaker::String.from_regexp(/\w{8}/)

    command("service snmpd stop")

    let(:manifest) {
    <<-EOS
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
    }

    it 'should run without errors' do
      result = apply_manifest(manifest, :catch_failures => true)
      expect(result.exit_code).to eq(2)
      expect(result.output).to include 'Warning: Password must contain [a-z],[A-Z],[0-9] characters and special characters!'
      expect(result.output).to include 'Warning: Passphrase must contain [a-z],[A-Z],[0-9] characters and special characters!'
     end

    # no re-run check, because constant error with weak password

  end
end
