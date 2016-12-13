require 'beaker-rspec'
require 'pry'

RSpec.configure do |c|
  module_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  c.formatter = :documentation

  c.expect_with :rspec do |c2|
    c2.syntax = :expect
  end

  c.before :suite do
    # Install module to all hosts
    hosts.each do |host|
      host.add_env_var('HTTP_PROXY', 'http://proxy.mms-dresden.de:8080')
      host.add_env_var('HTTPS_PROXY', 'http://proxy.mms-dresden.de:8080')

      install_puppet_on(host)

      result = on(host, "puppet config print modulepath")
      modulepaths = result.stdout.split(":")
      modulepath = modulepaths[modulepaths.length - 1]
      logger.info('modulepath: ' + modulepath)

      install_dev_puppet_module_on(host, :source => module_root, :module_name => 'secc_snmpd',
          :target_module_path => modulepath)
      # Install dependencies
      on(host, puppet('module', 'install', 'puppetlabs-stdlib'))
      on(host, puppet('module', 'install', 'puppetlabs-concat'))
      # Add more setup code as needed
    end
  end
end
