require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

task :default => [
  :syntax,
  :lint,
  :spec,
  :beaker,
]

PuppetSyntax.exclude_paths = ["spec/fixtures/**/*", "vendor/**/*"]

##
## Refer to http://puppet-lint.com/checks/ for a list of Puppet-lint checks
##
PuppetLint.configuration.fail_on_warnings
#PuppetLint.configuration.send('disable_80chars')
#PuppetLint.configuration.send('disable_variable_scope')
#PuppetLint.configuration.send('disable_class_inherits_from_params_class')
#PuppetLint.configuration.send('disable_class_parameter_defaults')
#PuppetLint.configuration.send('disable_documentation')
#PuppetLint.configuration.send('disable_single_quote_string_with_variables')
PuppetLint.configuration.ignore_paths = ["spec/**/*.pp", "pkg/**/*.pp"]
PuppetLint.configuration.log_format = "##teamcity[testStarted name='lint %{filename}:%{line}']##teamcity[testStdErr name='lint %{filename}:%{line}' out='%{message}']##teamcity[testFailed name='lint %{filename}:%{line}' message='%{message}']##teamcity[testFinished name='lint %{filename}:%{line}']"

desc "Fix puppet-lint errors"
PuppetLint::RakeTask.new :lint_fix do |configuration|
  configuration.fail_on_warnings
  configuration.ignore_paths = ["spec/**/*.pp", "pkg/**/*.pp"]
  configuration.fix = true
  configuration.log_format = ''
end
