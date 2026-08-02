# FOB Salerno AIRWING / SQUADRON / COMMANDER diagnostics

## Status

```yaml
status: ACCEPTED_TECHNICAL_BASELINE
builder_version: SAL-COMMANDER-SELECTION-18
commander_dispatch: PASS
parking_calibration: PASS
parking_assignment: DEFERRED
additional_salerno_runtime_test_before_next_airfield: false
```

Dieses Verzeichnis bewahrt den vollständigen technischen Salerno-Arbeitsstrang. Bestandene Stufen, fehlgeschlagene Stufen, ungültige Testläufe, Parking-Experimente und die abschließende COMMANDER-Acceptance werden nicht geglättet oder überschrieben.

## Akzeptierte Provenienz

```text
OMW branch:              agent/salerno-read-only-diagnostics
Accepted source commit:  dba0465afbff14fb719abdeb1f9b06e24ff24717
BuilderVersion:          SAL-COMMANDER-SELECTION-18
Bundle SHA-256:          75ea74cdaa60800899345924fc4eb450c15211d605bf972767d9d68e265421ee
Mission:                 OMW_Template_v5_Salerno.miz
Mission SHA-256:         4c9670babced44007952a02100de07b42eecdec156046ca7d1497a6a932edfaf
DCS version:             2.9.28.26385
MOOSE commit:            73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Embedded Moose.lua SHA:  e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Die bereitgestellte aktuelle `.miz` enthielt bytegenau das akzeptierte Stage-18-Bundle und das seit Beginn verwendete MOOSE-Artefakt.

## Akzeptierter Funktionsumfang

- `AIRBASE.Afghanistan.FOB_Salerno` / Airbase-ID 23;
- `WH_AIR_US_SALERNO`;
- sechs Clients, fünf KI-Templates, fünfzehn Aircraft-Statics und eine Zone;
- `AW_US_SALERNO` konstruiert und gestartet;
- fünf SQUADRONs konstruiert und registriert;
- zwanzig Warehouse-Assetgruppen;
- Mission Capabilities und Payloads;
- COMMANDER `NotReadyYet -> OnDuty`;
- CAS durch `COMMANDER:CanMission()` als ausführbar erkannt;
- Salerno-AIRWING ausgewählt;
- `MissionAssign`, `MissionRequest` und `OpsOnMission` beobachtet;
- AH-64-Asset `SQ_US_SAL_AH64D_TF_TIGERSHARK_ATTACK_AID-111` rekrutiert;
- AUFTRAG bis `started` fortgeschritten;
- kontrollierter Cleanup;
- kein registrierter Verlust.

## Nicht akzeptierter Umfang

```text
exact parking compliance
client-space runtime protection
cold-ground-spawn visual confirmation
tactical target engagement
normal tactical mission completion
return, landing and recovery
persistent inventory/loss accounting
OPSTRANSPORT
multiplayer and endurance testing
theater-wide production COMMANDER
```

## Dokumentationsstruktur

Kanonisches Branch-Manifest:

- [`docs/81-salerno-air-operations-manifest.md`](../../../docs/81-salerno-air-operations-manifest.md)

Vollständige technische Chronologie:

- [`docs/evidence/salerno-air-operations-runtime-acceptance-and-lessons-2026-08-02.md`](../../../docs/evidence/salerno-air-operations-runtime-acceptance-and-lessons-2026-08-02.md)

Abschluss-/Nachfolger-Handoff:

- [`docs/handoffs/2026-08-02-salerno-complete-state-and-next-airfield-handoff.md`](../../../docs/handoffs/2026-08-02-salerno-complete-state-and-next-airfield-handoff.md)

## Ergebnisberichte

### Parking

- [`Parking calibration PASS`](results/2026-08-02-salerno-parking-calibration-pass.md)
- [`Operational parking control FAIL / DEFERRED`](results/2026-08-02-salerno-operational-parking-control-fail-deferred.md)

### Dispatch und COMMANDER

- [`Direct dispatch with parking deferred PASS`](results/2026-08-02-salerno-direct-dispatch-parking-deferred-pass.md)
- [`COMMANDER mixed workload Stage 16 INVALID`](results/2026-08-02-salerno-commander-mixed-workload-stage16-invalid.md)
- [`COMMANDER isolated Stage 17 FAIL`](results/2026-08-02-salerno-commander-isolated-17-fail.md)
- [`COMMANDER selection Stage 18 PASS`](results/2026-08-02-salerno-commander-selection-18-pass.md)

## Chronologie

### 1. Read-only Diagnose

Airbase, Warehouse, Clients, Templates, Statics, Zone und Parkingnodes wurden vor jeder Mutation aufgelöst und gezählt.

### 2. Parking-Kalibrierung

`SAL-ME-TERMINAL-CALIBRATION-1` bestätigte:

```text
44 Runtime-Nodes
32 ME->TerminalID-Mappings
0 Fehler
PASS
```

Mission-Editor-Parkinglabels und MOOSE-TerminalIDs sind nicht identisch.

### 3. Type-spezifische Parking-Experimente

SQUADRON- und Assetpools wurden gesetzt und zwanzig registrierte Assets synchronisiert. Die internen Tabellen waren konsistent, die tatsächliche Multi-Unit-Platzierung jedoch nicht zuverlässig.

Mindestens ein Apache wurde visuell in einem erwartbar reservierten beziehungsweise geschützten Spielerbereich beobachtet. Parking wurde deshalb nicht akzeptiert.

### 4. Stage 15 – Parking deferred

`SAL-PARKING-DEFERRED-15` entfernte Parkingmutationen und Parking-Gates. Direkte CAS-, RECON- und LIFT-Aufträge bestätigten AIRWING, SQUADRONs, Capabilities und Payloads.

Der parallele Mehrfachdispatch war kein isolierter Spawn- oder Parkingtest.

### 5. Stage 16 – ungültiger Mischtest

`SAL-COMMANDER-DISPATCH-16` enthielt noch direkte CAS-/RECON-/LIFT-Aufträge. Eine Blackhawk aus dem direkten LIFT-Auftrag erschien in der Luft, während der COMMANDER-CAS-Auftrag `planned` blieb.

Ein case-sensitiver Zustandsvergleich erzeugte dafür einen falschen PASS-Marker. Der Lauf ist `INVALID`.

### 6. Stage 17 – isolierter FAIL

`SAL-COMMANDER-ISOLATED-17` entfernte alle direkten Missionen und erkannte `planned` korrekt als FAIL. Die anschließende MOOSE-/OMW-Dokumentationsprüfung zeigte, dass `commander:Start()` fehlte.

### 7. Stage 18 – korrigierter PASS

`SAL-COMMANDER-SELECTION-18` verwendete:

```text
COMMANDER:New()
COMMANDER:AddAirwing()
COMMANDER:Start()
COMMANDER:CanMission()
COMMANDER:AddMission()
COMMANDER:Status()
```

Der COMMANDER wurde `OnDuty`, wählte `AW_US_SALERNO`, rekrutierte ein AH-64-Asset und brachte den AUFTRAG bis `started`.

## MOOSE-first-Prüfung

Die entscheidende Korrektur wurde gegen folgende Quellen geprüft:

- Projekt-Governance;
- MOOSE-first-Richtlinie;
- Test-/Acceptance-Workflow;
- `docs/moose/AIR-OPERATIONS.md`;
- `docs/moose/EVENTS-AND-FSM.md`;
- `docs/moose/VERSION-AND-SOURCES.md`;
- `docs/moose/VERIFIED-METHODS.md`;
- akzeptierter Jalalabad-Startcode;
- offizieller MOOSE-Quellcode am Commit `73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`.

MOOSE-Verhalten:

1. `COMMANDER:New()` startet in `NotReadyYet`;
2. `AddAirwing()` verknüpft nur die Legion;
3. `Start()` wechselt nach `OnDuty` und startet den Statuszyklus;
4. `AddMission()` stellt den Auftrag zunächst als `PLANNED` in die Queue;
5. `onafterStatus()` ruft `CheckMissionQueue()` auf.

## Build

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File ".\tools\build-salerno-air-operations-bundle.ps1"
```

Output:

```text
mission/tests/salerno-air-operations/dist/OMW_AirOps_Salerno_Diagnostics.lua
```

Das `dist`-Bundle ist generiert und wird nicht als manuell zu pflegende Quelle behandelt.

## Mission-Editor-Integration

Nach jedem Build muss das generierte Bundle in der Mission-Startaktion `DO SCRIPT FILE` erneut ausgewählt und die Mission gespeichert werden. `Moose.lua` muss vorher geladen sein.

## Stage-18-Schlüsselmarker

```text
BOOT Version=SAL-COMMANDER-SELECTION-18
FSM beforeStart=NotReadyYet afterStart=OnDuty started=true
ELIGIBILITY commanderCanMission=true
SELECTION_TRIGGER method=COMMANDER.Status called=true ok=true
EVENT event=MissionAssign
AIRWING_EVENT event=MissionRequest
EVENT event=OpsOnMission
EVENT event=Started from=scheduled to=started
FINAL status=PASS
```

## Parking-Wiederaufnahme

Eine spätere Parking-Acceptance benötigt je Unit:

```text
mission, squadron, asset UID, group, unit, type,
configured asset IDs, configured squadron IDs,
world coordinate, nearest TerminalID, ME mapping,
in expected pool, in client pool, in static exclusion,
spawn mode
```

Ohne diese Daten bleibt Parking `DEFERRED`.

## Produktionsarchitektur

Der lokale `CMD_BLUE_AFGHANISTAN_TEST` ist ein Acceptance-Harness mit einer Legion. Die spätere Produktionsmission soll genau einen theaterweiten BLUE COMMANDER in einem separaten Modul nach den einzelnen AIRWING-Modulen laden.

Historische Testfixtures werden nicht rückwirkend umgebaut.
