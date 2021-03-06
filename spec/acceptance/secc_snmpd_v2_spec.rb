require 'spec_helper_acceptance'
require 'ffaker'

describe 'Class secc_snmpd' do
  context 'snmpv2 config' do
    community = FFaker::String.from_regexp('\w{8}aA2!')
    listen_ip = '127.0.0.2'

    command('service snmpd stop')

    manifest = <<-EOS
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

    it 'runs without errors' do
      result = apply_manifest(manifest, catch_failures: true)
      expect(result.exit_code).to eq(2)
      expect(result.stderr).to include 'Warning: use of SNMPv2 is not recommended!'
    end

    # no re-run check, because constant error with snmpv2

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
      its(:content) { is_expected.to include "rocommunity #{community}" }
    end

    describe port(161) do
      it { is_expected.to be_listening.on('127.0.0.1').with('udp') }
      it { is_expected.to be_listening.on(listen_ip).with('udp') }
    end
  end

  context 'snmpv2 config with weak passwords and enforcing' do
    community = FFaker::String.from_regexp('\w{6}')

    command('service snmpd stop')

    manifest = <<-EOS
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

    it 'runs without errors' do
      result = apply_manifest(manifest, catch_failures: true)
      expect(result.exit_code).to eq(2)
      expect(result.stderr).to include 'Warning: use of SNMPv2 is not recommended!'
      expect(result.stderr).to include "Warning: v2 community #{community}_localhost - Community must have 8 or more than 8 characters!"
      expect(result.stderr).to include "Warning: v2 community #{community}_localhost - Community must contain [a-z],[A-Z],[0-9] characters and special characters!"
      expect(result.stderr).to include "Error: v2 community #{community}_localhost - Security parameters for Community not met, not configuring community!"
    end

    # no re-run check, because constant error with wrong snmpv2

    describe file('/etc/snmp/snmpd.conf') do
      its(:content) { is_expected.not_to include 'rocommunity' }
    end
  end

  context 'snmpv2 config with weak passwords' do
    community = FFaker::String.from_regexp('\w{6}')

    command('service snmpd stop')

    manifest = <<-EOS
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

    it 'runs without errors' do
      result = apply_manifest(manifest, catch_failures: true)
      expect(result.exit_code).to eq(2)
      expect(result.stderr).to include 'Warning: use of SNMPv2 is not recommended!'
      expect(result.stderr).to include "Warning: v2 community #{community}_localhost - Community must have 8 or more than 8 characters!"
      expect(result.stderr).to include "Warning: v2 community #{community}_localhost - Community must contain [a-z],[A-Z],[0-9] characters and special characters!"
    end

    # no re-run check, because constant error with wrong snmpv2

    describe file('/etc/snmp/snmpd.conf') do
      its(:content) { is_expected.to include 'rocommunity' }
    end
  end

  context 'snmpv2 config with weak passwords and duplicate community' do
    community = FFaker::String.from_regexp('\w{6}')

    command('service snmpd stop')

    manifest = <<-EOS
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

      secc_snmpd::config::v2{ "#{community}_127.0.0.2":
        v2_community => '#{community}',
        v2_host      => '127.0.0.2',
      }
    EOS

    it 'runs without errors' do
      result = apply_manifest(manifest, catch_failures: true)
      expect(result.exit_code).to eq(2)
      expect(result.stderr).to include 'Warning: use of SNMPv2 is not recommended!'
      expect(result.stderr).to include "Warning: v2 community #{community}_localhost - Community must have 8 or more than 8 characters!"
      expect(result.stderr).to include "Warning: v2 community #{community}_localhost - Community must contain [a-z],[A-Z],[0-9] characters and special characters!"
    end

    # no re-run check, because constant error with wrong snmpv2

    describe file('/etc/snmp/snmpd.conf') do
      its(:content) { is_expected.to include "rocommunity #{community} localhost" }
      its(:content) { is_expected.to include "rocommunity #{community} 127.0.0.2" }
    end
  end
end
