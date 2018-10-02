# SNMP Module

[![Build Status](https://travis-ci.org/T-Systems-MMS/puppet-secc_snmpd.svg?branch=master)](https://travis-ci.org/T-Systems-MMS/puppet-secc_snmpd)

## Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
4. [Deviations - Possible bypass of requirements](#Possible-deviations)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)

## Overview

This module provides a partial coverage of the SoC conditins for SNMP under Linux.

## Module Description

The module can install and configure SNMP on a Linux system.

## Fullfilled Requirements

* 3.45/1 SNMP musted be used in version 3.
  * older version of SNMP do not support secure authentification mechanisms which correspond to today's state of technology
* 3.45/2 The SNMP Server has to prevent the usage of a too small length of the HMAC
  * many current applications allow the SNMP client to set the length of the HMAC on their own - this represents a potential security vulnerability
* 3.45/3 Predefined authentication characteristics have to be changed
  * third-party authentication features, such as passwords or cryptographic keys, can not be trusted.
* 3.45/4 Accounts must be protected against unauthorized use by using at least one authentication feature (token, passwords, PIN's)
* 3.45/5 When using passwords for authentication, they have to be at least 8 characters long and must include three of the following character types:
  * lowercase letters
  * uppercase letters
  * digits
  * special character
* 3.45/6 Authentication and encryption must be enabled depending on the protection requirements of the data
* 3.45/7 Protective information must not be included in files, issues and messages that are accessible to unauthorized users
* 3.45/8 If customers are contractually granted SNMP access to components managed by the DTAG, it must bed ensured that they are read-only and no vulnerable data of the DTAG can be queried

## Possible deviations

- 3.45/1, 3.45/6 Can be bypassed with the parameter ```$v2_enabled = true```
- 3.45/5 Can be bypassed with the parameter```$enforce_password_security = false```

## Notable

The requirement 3.45/2 can not be fulfilled configuratively. It refers to [an old bug](https://www.kb.cert.org/vuls/id/878044), which is resolved in the current versions (Net-SNMP versions 5.4.1.1, 5.3.2.1, 5.2.4.1, 5.1.4.1, 5.0.11.1 and UCD-SNMP 4.2.7.1).

## Usage

* By using this module, SNMP v1 and v2 will be deactivated and v3 activated using a password and a passphrase.
* This module has dependencies to ```puppetlabs/stdlib``` and ```puppetlabs/concat```

## Reference

* The requirements come from the technical safety requirements [3_45_SNMP.pdf](https://www.telekom.com/psa) of the PSA procedure

## Limitations

* This module was tested with CentOS6 and CentOS7

## Development

* Please document changes withing the module using git commits
* Execution of tests: `bundler install`, `bundler exec rake`