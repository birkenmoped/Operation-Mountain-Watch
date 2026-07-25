# Jalalabad Phase 1 – F10-Testmenü fehlt wegen falscher Modulreihenfolge

Stand: 2026-07-25  
Branch: `feature/jalalabad-airwing-phase1-functional-tests`  
Fehlerhafter Teststand: `62c39507bc26f414a57fdfdf34ac95955cd25d70`  
Korrekturcommit: `af08142672c7c702962950722893d02eff65e453`  
Status: **SOURCE FIXED IN GITHUB / LOCAL BUILD PENDING / DCS VALIDATION PENDING**

## Beobachtung

In DCS war das allgemeine MOOSE-F10-Menü vorhanden. Das projektspezifische Menü

```text
OMW AirOps Tests
└── Jalalabad Phase 1
```

fehlte vollständig.

## Lognachweis

Der Menücode selbst meldete:

```text
[OMW][AirOps.JBAD.PH1.MENU] ERROR: Phase 1 controller unavailable.
```

Davor war bereits das Phase-1-Manifest blockiert:

```text
[OMW][AirOps.JBAD.PH1.MANIFEST] ERROR: Runtime group prefix missing testId=AH64D_CAS
[OMW][AirOps.JBAD.PH1.MANIFEST] ERROR: Runtime group prefix missing testId=UH60_ABORT
[OMW][AirOps.JBAD.PH1.MANIFEST] ERROR: Runtime group prefix missing testId=CH47_CARGO
[OMW][AirOps.JBAD.PH1.MANIFEST] ERROR: Runtime group prefix missing testId=UH60_TROOP
[OMW][AirOps.JBAD.PH1.MANIFEST] BLOCKED manifest validation failed
```

In der Folge konnten Observer, Logistics, Factory, Controller, Menü und Routing nicht initialisiert werden.

## Ursache

Die Builder-Reihenfolge war falsch:

```text
05b-validate-runtime-name-contract.lua
05c-package-contracts.lua
```

`05b-validate-runtime-name-contract.lua` benötigt bereits die durch `05c-package-contracts.lua` erzeugten Package Contracts. Wegen der vertauschten Reihenfolge brach die Namensvalidierung vorzeitig ab und erzeugte keine `RuntimeGroupPrefixes`. Das spätere Phase-1-Manifest fand deshalb für seine Testdefinitionen keine Runtime-Präfixe.

Das allgemeine MOOSE-Menü war davon unabhängig und blieb sichtbar. Das projektspezifische Menü wird dagegen erst nach erfolgreicher Initialisierung von Manifest, Observer, Logistics, Factory und Controller erzeugt.

## Korrektur

Die kanonische Reihenfolge lautet jetzt:

```text
05c-package-contracts.lua
05b-validate-runtime-name-contract.lua
06-construct-oh58d-squadron.lua
...
11-phase1-test-manifest.lua
...
14-phase1-test-controller.lua
15-phase1-f10-and-acceptance.lua
```

Der Builder enthält zusätzlich feste Abhängigkeitsprüfungen:

```text
05c-package-contracts.lua vor 05b-validate-runtime-name-contract.lua
05b-validate-runtime-name-contract.lua vor 11-phase1-test-manifest.lua
14-phase1-test-controller.lua vor 15-phase1-f10-and-acceptance.lua
```

Die BuilderVersion wurde erhöht auf:

```text
JBAD-AIR-OPS-PHASE1-12-MOOSE-FIRST
```

## Unveränderte Grenzen

- keine `.miz` geändert;
- keine Mission-Editor-Objekte geändert;
- keine ORBAT-, Inventar- oder Paketgrößen geändert;
- keine MOOSE-Missions- oder Logistiksemantik geändert;
- kein DCS-PASS erklärt;
- der fehlgeschlagene Lauf ist kein UH-60-Transporttest, weil der Testcontroller nicht initialisiert wurde.

## Nächster Test

1. Branch-HEAD lokal aktualisieren.
2. Bundle mit BuilderVersion `JBAD-AIR-OPS-PHASE1-12-MOOSE-FIRST` neu bauen.
3. Bundle im vorhandenen `DO SCRIPT FILE` erneut auswählen und die bestehende `.miz` speichern.
4. Mission starten.
5. Prüfen, dass das F10-Menü `OMW AirOps Tests > Jalalabad Phase 1` vorhanden ist.
6. Danach ausschließlich `UH-60A Transport starten` ausführen.
7. Frische `dcs.log` und `debrief.log` auswerten.
