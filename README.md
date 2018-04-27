# SNMP Module

[![Build Status](https://travis-ci.org/T-Systems-MMS/puppet-secc_snmpd.svg?branch=master)](https://travis-ci.org/T-Systems-MMS/puppet-secc_snmpd)

## Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
4. [Abweichungen - mölgliche Umgehungen von Anforderungen](#abweichungen)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)

## Overview

Dieses Modul bietet eine teilweise Abdeckung der SoC Anforderungen für SNMP unter Linux.

## Module Description

Das Modul kann SNMP auf einem Linux System installieren und konfigurieren.

## Grundlage der SoC Requirements

- 3.45 SNMP

## Erfüllte Requirements

- 3.45/1 Es muss SNMP in der Version 3 verwendet werden.
- 3.45/2 Der SNMP Server muss verhindern, dass zu kleine Werte für die Länge des HMAC verwendet werden.
- 3.45/3 Vordefinierte Authentisierungsmerkmale müssen geändert werden.
- 3.45/4 Konten müssen gegen unautorisierte Nutzung durch Verwendung mindestens eines Authentisierungsmerkmals geschützt werden.
- 3.45/5 Falls Passwörter als Authentisierungsmerkmal genutzt werden, müssen diese mindestens 8 Zeichen lang sein und drei der folgenden Zeichentypen beinhalten: Kleinbuchstaben, Großbuchstaben, Ziffern und Sonderzeichen.
- 3.45/6 Die Authentifizierung und die Verschlüsselung müssen je nach Schutzbedarf der Daten aktiviert werden.
- 3.45/7 Schutzbedürftige Informationen dürfen nicht in Dateien, Ausgaben und Meldungen enthalten sein, die unautorisierten Benutzern zugänglich sind.
- 3.45/8 Falls Kunden ein SNMP Zugriff auf von der DTAG administrierten Komponenten vertraglich gewährt wird, muss sichergestellt sein, dass dieser ausschließlich lesend ist und keine schutzbedürftigen Daten der DTAG abgefragt werden können.

## mögliche Abweichungen

- 3.45/1, 3.45/6 kann mit dem Parameter ```$v2_enabled = true``` umgangen werden
- 3.45/5 kann mit dem Parameter ```$enforce_password_security = false``` umgangen werden

## Usage

- Generell wird durch dieses Modul SNMP v1 und v2 deaktiviert und v3 unter Nutzung eines Passworts und einer Passphrase aktiviert.
- Das Modul hat Abhängigkeiten zu ```puppetlabs/stdlib``` und ```puppetlabs/concat```

### Usage ohne Puppet

- Eine Copy&Paste Übernahme in Projekte ist nicht möglich, aber die notwendigen Parameter sind anhand der Manifeste und Templates auslesbar.

## Reference

- Anforderungen stammen aus [SoC Requirements 3_45_SNMP_v2.0.pdf](https://psa-portal.telekom.de/intranet-ui/public/releases/documents.xhtml?style=normal&domain=56828&source=login#)

## Limitations

- Modul wurde auf CentOS7 und CentOS6 gestestet.

## Development

- Änderungen am Modul bitte über Git dokumentieren.
- Ausführung von Tests: "bundler install", "bundler exec rake"
