source 'https://rubygems.org'

group :acceptance do
  gem 'nokogiri', '~> 1.8.2'
  gem 'net-ssh'
  gem 'pry'
  gem 'beaker-rspec'
  gem 'jruby-pageant'
  gem 'ffaker'
  gem 'highline'
  gem 'rake', '~> 10.1.0'
  if puppetversion = ENV['PUPPET_VERSION']
    gem 'puppet', puppetversion
  else
    gem 'puppet'
  end
  gem 'puppetlabs_spec_helper'
  gem 'puppet-lint', '1.1.0'
  gem 'puppet-syntax'
end
