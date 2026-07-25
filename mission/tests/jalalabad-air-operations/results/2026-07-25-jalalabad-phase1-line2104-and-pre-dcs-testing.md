# Jalalabad Phase 1 – Bundle-Abbruch in Zeile 2104 und verbindlicher Pre-DCS-Test

Stand: 2026-07-25  
Branch: `feature/jalalabad-airwing-phase1-functional-tests`

## Einordnung des DCS-Laufs

Der Lauf mit BuilderVersion `JBAD-AIR-OPS-PHASE1-13-MOOSE-FIRST` ist kein Menü- oder Funktionstest, sondern ein Initialisierungsabbruch während der Auswertung des generierten Bundles.

Erfolgreich waren:

```text
[OMW][AirOps.JBAD.PACKAGES] PASS
[OMW][AirOps.JBAD.NAMES] RESULT: PASS
[OMW][AirOps.JBAD.NAMES] INITIALIZATION mode=SYNCHRONOUS ready=true
[OMW][AirOps.JBAD.PH1.MANIFEST] READY
```

Unmittelbar danach brach das Bundle ab:

```text
Mission script error:
[string "l10n/DEFAULT/OMW_AirOps_Jalalabad.lua"]:2104:
attempt to index field '?' (a nil value)
```

Observer, Logistics, Factory, Controller und F10-Menü konnten deshalb nicht mehr initialisiert werden.

## Ursache

`12-phase1-runtime-observer.lua` wurde sofort nach dem Manifest ausgewertet. Der Observer griff dabei auf das noch nicht konstruierte AIRWING-Objekt zu:

```lua
local previousFlightOnMission = cfg.Airwing.OnAfterFlightOnMission
```

Die AIRWING-Konstruktion wird im Bootstrap dagegen verzögert ausgeführt. Zum Zeitpunkt der Bundle-Auswertung war `cfg.Airwing` deshalb noch `nil`.

## Korrektur

### Verzögerte AIRWING-Anbindung

Der Observer definiert nun:

```lua
observer:AttachAirwing(airwing)
```

Der Observer kann dadurch vollständig geladen werden, obwohl das AIRWING-Objekt noch nicht existiert. Die bestehende `OnAfterFlightOnMission`-Callback-Kette wird erst an das konkret konstruierte AIRWING-Objekt gebunden.

`10-validate-and-start-complete-node.lua` ruft die Anbindung zwingend vor `cfg.Airwing:Start()` auf. Schlägt die Anbindung fehl, wird das AirOps-Node nicht gestartet.

### Menü unabhängig vom Baseline-Status

Das F10-Diagnose- und Testmenü wird nun unmittelbar nach erfolgreicher Initialisierung von Manifest, Observer, Logistics, Factory und Controller erzeugt. Es hängt nicht mehr von `cfg.BaselineReady` ab.

Die einzelnen Startbefehle bleiben weiterhin durch `Controller:StartTest()` gegen einen nicht bereiten AIRWING-/Inventarzustand geschützt.

Erwarteter Marker:

```text
[OMW][AirOps.JBAD.PH1.MENU] READY F10=OMW_AirOps_Tests/Jalalabad_Phase_1 commands=8 availability=IMMEDIATE baselineIndependent=true
```

## Pre-DCS-Test

Weitere DCS-Läufe werden nicht allein aufgrund eines erfolgreichen Bundle-Builds freigegeben.

Neu hinzugefügt wurde:

```text
tools/test-jalalabad-phase1-init-smoke.lua
```

Der Test lädt mit einer minimalen DCS-/MOOSE-Testumgebung die kanonischen Phase-1-Module in Bundle-Reihenfolge:

```text
11-phase1-test-manifest.lua
12-phase1-runtime-observer.lua
12a-phase1-moose-logistics.lua
13-phase1-mission-factory.lua
14-phase1-test-controller.lua
15-phase1-f10-and-acceptance.lua
16-phase1-moose-first-readiness-routing.lua
```

Dabei wird ausdrücklich geprüft:

- `cfg.Airwing` ist beim Laden des Observers noch `nil`;
- alle sieben Phase-1-Module laden ohne Lua-Laufzeitfehler;
- das Manifest ist gültig;
- Observer, Logistics, Factory, Controller und Routing existieren;
- das F10-Menü wird sofort erzeugt;
- genau zwei Menüebenen und acht Befehle werden erzeugt;
- die AIRWING-Callback-Anbindung erfolgt erst nachträglich;
- eine vorhandene AIRWING-Callback-Funktion bleibt erhalten;
- die Anbindung ist für dasselbe AIRWING-Objekt idempotent.

Erwartetes Testergebnis:

```text
PHASE1_INIT_SMOKE_PASS menus=2 commands=8 scheduled=<n>
```

Der GitHub-Actions-Workflow `.github/workflows/jalalabad-air-ops-preflight.yml` führt künftig vor einem DCS-Test aus:

1. kanonischen PowerShell-Build;
2. Prüfung des Bundle-Headers;
3. ausführbaren Lua-Initialisierungstest.

## Builder

Neue BuilderVersion:

```text
JBAD-AIR-OPS-PHASE1-14-MOOSE-FIRST
```

Der Builder löscht ein vorhandenes `dist`-Bundle jetzt bereits vor allen Prüfungen. Ein fehlgeschlagener Build kann daher kein altes Bundle mehr als scheinbar aktuelles Ergebnis zurücklassen.

Zusätzliche Builder-Gates prüfen:

- vollständige Abhängigkeitsreihenfolge von Manifest bis Menü;
- kein AIRWING-Zugriff während des Observer-Ladens;
- Vorhandensein der verzögerten `AttachAirwing`-API;
- AIRWING-Anbindung vor `AIRWING:Start()`;
- sofortige und baseline-unabhängige Menüerzeugung.

## Missionsdatei

- `.miz` durch die Repositorykorrektur nicht verändert;
- bis zur erfolgreichen Pre-DCS-Abnahme nicht erneut im Missionseditor speichern;
- kein weiterer DCS-Test ist freigegeben, solange kein reproduzierbares Preflight-PASS vorliegt.

## Abnahmestatus

- Fehlerursache Zeile 2104: IDENTIFIZIERT
- Observer-AIRWING-Anbindung: KORRIGIERT
- Menüerzeugung: AUF SOFORTIGE INITIALISIERUNG UMGESTELLT
- Builder-Gates: ERWEITERT
- ausführbarer Lua-Smoke-Test: IMPLEMENTIERT
- GitHub-Actions-Preflight: IMPLEMENTIERT
- DCS-Menüabnahme: AUSSTEHEND
- funktionaler UH-60-OPSTRANSPORT-Test: AUSSTEHEND
