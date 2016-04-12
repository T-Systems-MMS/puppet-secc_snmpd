# SNMP Module - Version 1.0.4

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

##Overview
Dieses Modul bietet eine teilweise Abdeckung der SoC Anforderungen für SNMP unter Linux.       

##Module Description
Das Modul kann SNMP auf einem Linux System installieren und konfigurieren.

##Requirements - Abdeckung
- SoC Requirement 1 wird in init.pp erfüllt.
- SoC Requirement 2,6 wird in user.pp erfüllt.
- Soc Requirement 3 wird in config.pp erfüllt
- Soc Requirement 4,5 wird in user.pp/community.pp erfüllt
- SoC Requirement 7 erfüllt.

##Abweichungen
- SoC Requirement 1 kann mit dem Parameter $v2_enabled = true umgangen werden
- Soc Requirement 4,5 kann mit dem Parameter $enforce_password_security = false umgangen werden
- SoC Requirement 8 müssen geprüft werden.

##Usage
- Die Einsatzfähigkeit des Moduls muss noch druch AMCS SecC überprüft werden.
- Generell wird durch dieses Modul SNMP v1 und v2 deaktiviert und v3 unter Nutzung eines Passworts und einer Passphrase aktiviert.

###Usage ohne Puppet
- Eine Copy&Paste Übernahme in Projekte ist nicht möglich, aber die notwendigen Parameter sind anhand der Manifeste und Templates auslesbar.

##Reference
- Anforderungen stammen aus [SoC Requirements 3_45_SNMP_v2.0.pdf](https://psa-portal.telekom.de/intranet-ui/public/releases/documents.xhtml?style=normal&domain=56828&source=login#)

##Limitations
- Modul wurde nur auf CentOS7 gestestet.
- Es darf KEIN Semikolon (;) für Passwörter verwendet werden!

##Development
- Änderungen am Modul bitte über Git dokumentieren.

##Release Notes/Contributors/Etc **Optional**
- Initialrelease
- 1.0.1 fix of regex expression for password verification 
- 1.0.2 fixed encoding from MD5 to AES and SHA
- 1.0.3 fixed deactivation snmp v1 and v2
- 1.0.4 rewrite of some parts, added user and community functions, fixed SNMPv3 support
