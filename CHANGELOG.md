# CHANGELOG
## [UNRELEASED]
* Add variable `listen_address` - this is set to $(ipaddress) by default so snmp only listens on localhost and defined interfaces
* Fix usage of listen_address variable - now it actually works

## [1.2.0] - 2018-06-25
### Changed
* `CONFIG.type` is now set to "aio" for nodesets using the AllInOne Installer ("Puppet Collections")

### Removed
* surplus code has been removed from spec files

### Fixed
* internal variable `$_securitycheck` (used in `secc_snmpd::config::v2` and `secc_snmpd::config::v3` ) no longer throws "undefined variable" warnings
* "validate()" commands in init.pp are now different for Puppet 3 / Puppet 4, because the threw deprecation warnings on Puppet 4

## [1.1.0] - 2018-05-21
* initial public release
