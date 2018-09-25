require 'spec_helper_acceptance'
require 'ffaker'

describe 'Class secc_snmpd' do
  context 'snmpv2 config' do
    community = FFaker::String.from_regexp(/\w{8}aA2!/)
    listen_ip = "127.0.0.2"

    command("service snmpd stop")

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
        listen_address            => '#{listen_ip}',
      }
    EOS
    }

    it 'should run without errors' do
      result = apply_manifest(manifest, :catch_failures => true)
      expect(result.exit_code).to eq(2)
      expect(result.output).to include 'Warning: use of SNMPv2 is not recommended!'
     end

    # no re-run check, because constant error with snmpv2

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
      its(:content) { is_expected.to include "rocommunity #{community}" }
    end

  end

  context 'snmpv2 config with weak passwords and enfoorcing' do
    community = FFaker::String.from_regexp(/\w{6}/)

    command("service snmpd stop")

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
      expect(result.output).to include 'Warning: use of SNMPv2 is not recommended!'
      expect(result.output).to include 'Warning: Community must have 8 or more than 8 characters!'
      expect(result.output).to include 'Warning: Community must contain [a-z],[A-Z],[0-9] characters and special characters!'
      expect(result.output).to include 'Error: Security parameters for Community not met, not configuring community!'
    end

    # no re-run check, because constant error with wrong snmpv2

    describe file('/etc/snmp/snmpd.conf') do
      its(:content) { is_expected.not_to include "rocommunity" }
    end

  end

  context 'snmpv2 config with weak passwords' do
    community = FFaker::String.from_regexp(/\w{6}/)

    command("service snmpd stop")

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
      expect(result.output).to include 'Warning: use of SNMPv2 is not recommended!'
      expect(result.output).to include 'Warning: Community must have 8 or more than 8 characters!'
      expect(result.output).to include 'Warning: Community must contain [a-z],[A-Z],[0-9] characters and special characters!'
     end

    # no re-run check, because constant error with wrong snmpv2

    describe file('/etc/snmp/snmpd.conf') do
      its(:content) { is_expected.to include "rocommunity" }
    end

  end

end
