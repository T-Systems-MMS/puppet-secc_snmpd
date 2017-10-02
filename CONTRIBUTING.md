# Contributing

Danke, dass du dich an der Weiterentwicklung unserer SecC Puppet Module beteiligen willst! Durch deine Mithilfe können wir gemeinsam ein Sicherheitslevel in der AMCS etablieren, dass für uns alle zielführend ist und unseren 
Arbeitsaufwand in den Services deutlich reduziert.

## Einleitung

Dieses Modul wird durch die AMCS SecC Community & das SecC Kernteam betreut. Infos zur Community findest du im [Confluence](https://confluence.t-systems-mms.eu/display/asc).
Bugs, Verbesserungsvorschläge oder anderes Feedback kannst du uns gerne über das [Jira-Projekt](https://jira.t-systems-mms.eu/projects/ASC) in Form von Tickets zukommen lassen.
Wenn du direkten Kontakt zu uns sucht kannst du uns gerne eine E-Mail an folgenden Verteiler schicken: [SecC Kernteam](mailto:amcs-secc-kernteam@mms-support.de).

## Vorgehen bei Pull Requests

1. Öffnen eines JIRA-Tickets im [SecC 
Projekt](https://projectcenter.t-systems-mms.eu/jira/secure/CreateIssueDetails!init.jspa?pid=15993&summary=secc_snmpd%20changeme&issuetype=13&priority=5&description=Beschreibung&components=21139)
2. Einen neuen Branch in dem gewünschten Modul erstellen, der einen aussagekräftigen Namen trägt - z.B. Ticketnummer
3. Änderungen im neuerstellten Branch lokal durchführen und testen ggf. neue Testfälle hinzufügen
4. README.md anpassen und metadata.json anpassen
5. Pull Request erstellen und mindestens den Autor und ein weiteres Kernteam Mitglied als Prüfer eintragen
6. ggf. Nacharbeiten durchführen

## Inhalte für Fehlermeldungen

Zu jedem gefundenen Fehler sollte ein Ticket existieren. Wenn du einen neuen Fehler gefunden hast, zu dem noch kein Ticket existiert, gib uns bitte Bescheid.
Eine Fehlermeldung sollte folgenden Inhalt haben:

* was wolltest du einrichten
* wie hast du das Modul dafür konfiguriert
* welche Fehlermeldung / welches Fehlverhalten ist aufgetreten
* komplette Ausgabe eines Puppet Run

## Standards

* Änderungen am Code sind nur mit zugehörigem Ticket möglich
* Puppet Coding nach Puppet Styleguide
* sinnvolle und aussagekräftige Commit Messages
