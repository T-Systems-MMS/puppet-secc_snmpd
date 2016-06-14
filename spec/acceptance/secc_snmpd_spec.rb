require 'spec_helper_acceptance'
require 'ffaker'

describe 'Class secc_snmpd' do
  context 'default snmpv3 config' do
    username = FFaker::String.from_regexp(/\w{8}/)
    password = FFaker::String.from_regexp(/\w{8}aA2!/)
    passphrase = FFaker::String.from_regexp(/\w{8}aA2!/)

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

    it 'should run without errors' do
      expect(apply_manifest(manifest, :catch_failures => true).exit_code).to eq(2)
    end

    it 'should re-run without changes' do
      expect(apply_manifest(manifest, :catch_changes => true).exit_code).to be_zero
    end

    it 'should not accept weak password/passphrase' do
      manifest =     <<-EOS
        class { 'secc_snmpd':
            service                   => 'test',
            syslocation               => 'at home',
            syscontact                => 'root@me.you',
            v3_user                   => '#{username}',
            v3_password               => 'pass',
            v3_passphrase             => 'pass',
          }
        EOS
      result = apply_manifest(manifest, :expect_failures => true)
      expect(result.exit_code).to eq(1)
      expect(result.output).to include 'Password must have 8 or more than 8 characters!'
      expect(result.output).to include 'Password must contain [a-z],[A-Z],[0-9] characters and special characters!'
      expect(result.output).to include 'Error: Security parameters for Password not met!'
      expect(result.output).to include 'Passphrase must have 8 or more than 8 characters!'
      expect(result.output).to include 'Passphrase must contain [a-z],[A-Z],[0-9] characters and special characters!'
      expect(result.output).to include 'Password and Passphrase are identical!'
      expect(result.output).to include 'Error: Security parameters for Password not met!'
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
      it { is_expected.to be_mode 644 }
      its(:content) { is_expected.to include 'OPTIONS="-LS0-5d -Lf /dev/null -p /var/run/snmpd.pid"' }
    end

    describe file('/etc/snmp/snmpd.conf') do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
      it { is_expected.to be_mode 600 }
      its(:content) { is_expected.to include 'syscontact' }
      its(:content) { is_expected.to include 'syslocation' }
      its(:content) { is_expected.to include "rouser #{username}" }
      its(:content) { is_expected.to include "createUser #{username} SHA #{password} AES #{passphrase}" }
    end

    describe file('/var/lib/net-snmp/snmpd.conf') do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
      it { is_expected.to be_mode 600 }
      its(:content) { is_expected.to contain "usmUser.*#{username}" }
    end
  end

  context 'snmpv3 config with weak passwords' do
    username = FFaker::String.from_regexp(/\w{6}/)
    password = FFaker::String.from_regexp(/\w{6}/)
    passphrase = FFaker::String.from_regexp(/\w{6}/)

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
      expect(result.output).to include 'Password must contain [a-z],[A-Z],[0-9] characters and special characters!'
      expect(result.output).to include 'Passphrase must contain [a-z],[A-Z],[0-9] characters and special characters!'
     end

    it 'should re-run without changes' do
      result = apply_manifest(manifest, :catch_changes => true)
      expect(result.exit_code).to be_zero
      expect(result.output).to include 'Password must contain [a-z],[A-Z],[0-9] characters and special characters!'
      expect(result.output).to include 'Passphrase must contain [a-z],[A-Z],[0-9] characters and special characters!'
    end
  end

  context 'snmpv2 config' do
    community = FFaker::String.from_regexp(/\w{8}aA2!/)

    let(:manifest) {
    <<-EOS
      class { 'secc_snmpd':
        service                   => 'test',
        syslocation               => 'at home',
        syscontact                => 'root@me.you',
        v2_enabled                => true,
        v3_enabled                => false,
        v2_community              => '#{community}',
        v2_host                   => 'localhost',
      }
    EOS
    }

    it 'should run without errors' do
      result = apply_manifest(manifest, :catch_failures => true)
      expect(result.exit_code).to eq(2)
      expect(result.output).to include 'use of SNMPv2 is not recommended!'
     end

    it 'should re-run without changes' do
      result = apply_manifest(manifest, :catch_changes => true)
      expect(result.exit_code).to be_zero
      expect(result.output).to include 'use of SNMPv2 is not recommended!'
    end
  end

  context 'snmpv2 config with weak passwords' do
    community = FFaker::String.from_regexp(/\w{6}/)

    let(:manifest) {
    <<-EOS
      class { 'secc_snmpd':
        service                   => 'test',
        syslocation               => 'at home',
        syscontact                => 'root@me.you',
        v2_enabled                => true,
        v3_enabled                => false,
        v2_community              => '#{community}',
        v2_host                   => 'localhost',
        enforce_password_security => false,
      }
    EOS
    }

    it 'should run without errors' do
      result = apply_manifest(manifest, :catch_failures => true)
      expect(result.exit_code).to eq(2)
      expect(result.output).to include 'use of SNMPv2 is not recommended!'
      expect(result.output).to include 'Community must have 8 or more than 8 characters!'
      expect(result.output).to include 'Community must contain [a-z],[A-Z],[0-9] characters and special characters!'
     end

    it 'should re-run without changes' do
      result = apply_manifest(manifest, :catch_changes => true)
      expect(result.exit_code).to be_zero
      expect(result.output).to include 'use of SNMPv2 is not recommended!'
      expect(result.output).to include 'Community must have 8 or more than 8 characters!'
      expect(result.output).to include 'Community must contain [a-z],[A-Z],[0-9] characters and special characters!'
    end
  end

end
