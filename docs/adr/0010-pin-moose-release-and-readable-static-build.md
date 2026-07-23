# ADR 0010 – MOOSE-Release und lesbare statische Build-Fassung pinnen

- Status: Accepted
- Date: 2026-07-13

## Context

Operation Mountain Watch verwendet MOOSE ab der ersten physischen Teststufe und später als zentrale Laufzeitabhängigkeit für Spawn, Gruppensteuerung, Zonen, Scheduler, Events, CTLD, CSAR und Virtualisierung.

Der offizielle Upstream unterscheidet einen stabilen Branch `master-ng`, den Entwicklungszweig `develop` und unveränderliche Releases. Das offizielle Include-Repository erzeugt außerdem eine lesbare statische Datei `Moose.lua`, eine mit LuaSrcDiet komprimierte Datei `Moose_.lua` und dynamische Includes für Frameworkentwicklung.

Ein direkter Bezug auf einen beweglichen Branch würde reproduzierbare Testmissionen erschweren. Die komprimierte Fassung reduziert die Dateigröße, erschwert aber die direkte Suche und Fehlersuche im Frameworkcode.

## Decision

Operation Mountain Watch verwendet zunächst:

```text
MOOSE release: 2.9.18
Upstream tag: 2.9.18
Stable branch family: master-ng
Include family: Moose_Include_Static
Runtime file: Moose.lua
Compression: none
```

Der Release wird im Repository gepinnt. Die vendorte Datei erhält eine dokumentierte SHA-256-Prüfsumme und wird nicht lokal verändert.

Für alle Test- und Kampagnenmissionen gilt:

- MOOSE wird vor jedem Projektcode geladen;
- genau eine MOOSE-Include-Datei wird geladen;
- Dynamic Includes werden nicht in Missionslaufzeit oder Release-Missionen verwendet;
- automatische Upstream-Downloads sind nicht zulässig;
- `develop` wird nicht als unfixierter Branch verwendet;
- APIs werden gegen die vendorte Datei oder die passende stabile Dokumentation geprüft.

`Moose_.lua` darf später als optionale Distributionsfassung verwendet werden, wenn sie aus exakt demselben Release stammt und alle relevanten Testmissionen erneut bestanden wurden.

Ein Wechsel zu einem Entwicklungsstand erfordert einen eigenen ADR, einen vollständigen Commit-SHA, eine konkrete Begründung und einen dokumentierten Rückfallpfad.

## Consequences

### Positive

- Testmissionen und Server verwenden einen reproduzierbaren Frameworkstand;
- Frameworkfehler und Methodensignaturen können direkt in `Moose.lua` untersucht werden;
- Upstream-Änderungen gelangen nicht unbemerkt in die Mission;
- Release-Updates erhalten einen klaren Regressionstestprozess;
- Stable- und Develop-Dokumentation werden nicht versehentlich vermischt;
- Test- und Produktionslogik verwenden denselben Frameworkstand.

### Negative

- die unkomprimierte Include-Datei ist größer;
- Sicherheits- und Bugfixes werden nicht automatisch übernommen;
- MOOSE-Updates benötigen einen eigenen Wartungs- und Testvorgang;
- neue Funktionen aus `develop` stehen nicht sofort zur Verfügung;
- Prüfsummen und Lizenzdatei müssen bei jedem Update gepflegt werden.

## Rules

- Der vendorte Dateiname lautet exakt `vendor/moose/Moose.lua`.
- `vendor/moose/Moose.lua` wird nicht direkt editiert.
- Version, Herkunft, Build-Variante und SHA-256 werden in `vendor/moose/VERSION.md` dokumentiert.
- Ein fehlender Hash wird bis zum tatsächlichen Import als `PENDING_IMPORT` markiert.
- `Moose.lua` und `Moose_.lua` werden nie gleichzeitig geladen.
- Ein Buildvariantenwechsel wird getrennt von einem Versionsupdate getestet.
- Der unfixierte Branch `develop` ist keine zulässige Produktionsabhängigkeit.
- Alle MOOSE-Testmissionen müssen nach einem Frameworkupdate erneut ausgeführt werden.
