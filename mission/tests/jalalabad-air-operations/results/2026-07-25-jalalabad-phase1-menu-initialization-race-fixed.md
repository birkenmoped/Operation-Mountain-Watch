# Jalalabad Phase 1 – F10-Menü fehlt durch Initialisierungsrennen

Stand: 2026-07-25  
Branch: `feature/jalalabad-airwing-phase1-functional-tests`

## Befund

Im Testlauf mit BuilderVersion `JBAD-AIR-OPS-PHASE1-12-MOOSE-FIRST` erschien weiterhin nur das Standard-MOOSE-Menü. Das OMW-Testmenü wurde nicht erzeugt.

Der DCS-Log zeigte unmittelbar beim Laden des Bundles:

```text
[OMW][AirOps.JBAD.PH1.MANIFEST] ERROR: Runtime group prefix missing ...
[OMW][AirOps.JBAD.PH1.MANIFEST] BLOCKED manifest validation failed
[OMW][AirOps.JBAD.PH1.MENU] ERROR: Phase 1 controller unavailable.
```

Später im selben Lauf meldete die Namensvertragsprüfung dagegen erfolgreich alle vier Runtime-Präfixe und `RESULT: PASS`. Auch AIRWING und COMMANDER starteten anschließend erfolgreich.

## Ursache

Die Dateireihenfolge im Bundle war bereits korrigiert:

```text
05c-package-contracts.lua
05b-validate-runtime-name-contract.lua
11-phase1-test-manifest.lua
```

Die Reihenfolge allein genügte jedoch nicht. `05b-validate-runtime-name-contract.lua` plante seine eigentliche Prüfung mit einem MOOSE-Scheduler erst 8,5 Sekunden später ein. `11-phase1-test-manifest.lua` wurde dagegen sofort bei der Bundle-Auswertung ausgeführt.

Damit entstand ein Initialisierungsrennen:

1. Package Contracts waren vorhanden.
2. Die Namensvertragsdatei war bereits eingebettet, ihre Prüfung aber noch nicht ausgeführt.
3. Das Manifest las `cfg.RuntimeGroupPrefixes` sofort und fand eine leere Tabelle.
4. Observer, Logistics, Factory, Controller und F10-Menü initialisierten wegen des blockierten Manifests nicht.
5. Erst später erzeugte die verzögerte Namensprüfung die korrekten Präfixe; die bereits abgebrochene Phase-1-Kette wurde jedoch nicht erneut aufgebaut.

## Korrektur

### Runtime-Namensvertrag

`05b-validate-runtime-name-contract.lua` führt die reine MOOSE-/Template-basierte Prüfung nun synchron während der Bundle-Auswertung aus.

Der Zustand wird explizit markiert:

```lua
cfg.NameContractInitialized = true
cfg.NameContractOK = true|false
```

Erwarteter Erfolgsmarker:

```text
[OMW][AirOps.JBAD.NAMES] INITIALIZATION mode=SYNCHRONOUS ready=true
```

### Manifest-Gate

`11-phase1-test-manifest.lua` verlangt nun ausdrücklich:

```lua
cfg.NameContractInitialized == true
cfg.NameContractOK == true
```

Das Manifest kann dadurch nicht mehr mit einem noch nicht ausgeführten Namensvertrag fortfahren.

### Builder-Gate

Der Builder prüft jetzt zusätzlich:

- `05c` steht vor `05b`;
- `05b` steht vor `11`;
- `05b` enthält weder `SCHEDULER` noch `timer.scheduleFunction`;
- `05b` ruft `main` synchron auf;
- `05b` enthält den synchronen Initialisierungsmarker;
- das Manifest prüft `NameContractInitialized` und `NameContractOK`.

Neue BuilderVersion:

```text
JBAD-AIR-OPS-PHASE1-13-MOOSE-FIRST
```

## Commits

```text
f892d0218af62bc21d8a3e8924ea1223db957a8f
  Runtime-Namensvertrag synchronisiert

f808d48e22f7e93faa74df624bbb115d1f592afd
  Manifest-Gate auf initialisierten Namensvertrag erweitert

5a28561095adb5d61f6d0401fc8f487dba61bd88
  Builder-Gate für synchrone Abhängigkeit ergänzt
```

## Missionsdatei

- keine `.miz` durch Repositoryarbeiten geändert;
- bestehende `OMW_Jalalabad_AirOps_Phase1_Test.miz` weiterverwenden;
- nach lokal erfolgreichem Build nur das generierte Bundle im vorhandenen `DO SCRIPT FILE` erneut auswählen;
- unter demselben Missionsnamen speichern.

## Abnahmestatus

- Quellcodekorrektur: IMPLEMENTIERT
- Builder-Gate: IMPLEMENTIERT
- lokaler PowerShell-Build: AUSSTEHEND
- F10-Menü in DCS: AUSSTEHEND
- funktionaler UH-60-OPSTRANSPORT-Test: AUSSTEHEND

Es wird kein DCS-PASS beansprucht, bevor ein frischer Log mindestens folgende Marker enthält:

```text
[OMW][AirOps.JBAD.NAMES] INITIALIZATION mode=SYNCHRONOUS ready=true
[OMW][AirOps.JBAD.PH1.MANIFEST] READY
[OMW][AirOps.JBAD.PH1.OBS] READY
[OMW][AirOps.JBAD.PH1.LOGISTICS] READY
[OMW][AirOps.JBAD.PH1.FACTORY] READY
[OMW][AirOps.JBAD.PH1] READY
[OMW][AirOps.JBAD.PH1.MENU] READY F10=OMW_AirOps_Tests/Jalalabad_Phase_1 commands=8
```
