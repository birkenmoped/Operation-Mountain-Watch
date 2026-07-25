# Jalalabad Air Operations

## Status

```text
Grundknoten:
  OPERATIONAL / ACCEPTED
  Commit: 6cee9a5db7abf1934d0f86bf9fdf91a0446374d0
  BuilderVersion: JBAD-AIR-OPS-COMPLETE-5

Taktische Phase 1:
  MOOSE-FIRST REFACTOR IMPLEMENTED
  LOCAL BUILD AND DCS VALIDATION PENDING
  BuilderVersion: JBAD-AIR-OPS-PHASE1-11-MOOSE-FIRST
  MOOSE-Pin: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
```

Die Grundknoten-Abnahme belegt AIRWING-/SQUADRON-Aufbau, Parking, Warehouse, COMMANDER und fehlerfreien Leerlauf. Sie belegt nicht automatisch die korrekte taktische Ausführung von RECON, CAS, OPSTRANSPORT, CARGOTRANSPORT oder MEDEVAC.

## Autoritative Dokumente

```text
../../../docs/21-jalalabad-air-operations-manifest.md
../../../docs/23-jalalabad-parking-template-and-medevac-model.md
../../../docs/24-jalalabad-ch47-static-parking-reservations.md
../../../docs/25-jalalabad-final-validation-and-operational-baseline.md
../../../docs/27-jalalabad-air-operations-phase1-postmortem-and-guardrails.md
../../../docs/28-jalalabad-air-operations-development-incident-log.md
../../../docs/29-jalalabad-air-operations-moose-code-review.md
../../../docs/31-jalalabad-air-operations-moose-first-refactor-implementation.md
expected/jalalabad-complete-node-acceptance.md
expected/jalalabad-phase1-package-contract.md
expected/jalalabad-phase1-architecture-regression-checklist.md
expected/jalalabad-phase1-moose-first-refactor-acceptance.md
results/2026-07-24-jalalabad-complete-node-pass.md
results/2026-07-25-jalalabad-phase1-moose-first-refactor-implemented.md
```

## Verbindliche Ebenentrennung

```text
logischer Flugzeugbestand
MOOSE-Templates als technische Kopiervorlagen
physische dynamische DCS-Gruppen / MOOSE-Assets
sichtbare statische Bestandsmaschinen
Client-Gruppen und deren Parkpositionen
taktische Pakete aus einer oder mehreren Gruppen
```

Insbesondere:

```text
Two-Ship-Template + SetGrouping(2)
= eine physische DCS-Gruppe mit zwei Luftfahrzeugen

zwei Single-Ship-Assets
= zwei unabhängige DCS-Gruppen, kein physisches Two-Ship

Static
= sichtbare Ramp-Darstellung, kein AIRWING-Asset

Template
= Authoring-Seed, keine aktive Bestandsmaschine
```

## Verbindlicher Paketvertrag

```text
OH-58D RECON
  24 Luftfahrzeuge
  12 MOOSE-Asset-Gruppen
  SetGrouping(2)
  1 physische DCS-Gruppe / 2 Luftfahrzeuge je Auftrag
  operative Autorität: AUFTRAG

AH-64D CAS
  8 Luftfahrzeuge
  4 MOOSE-Asset-Gruppen
  SetGrouping(2)
  1 physische DCS-Gruppe / 2 Luftfahrzeuge je Auftrag
  operative Autorität: AUFTRAG

UH-60
  8 Luftfahrzeuge
  8 Single-Ship-Asset-Gruppen
  SetGrouping(1)
  TROOPTRANSPORT: OPSTRANSPORT GROUP_CARGO
  späteres MEDEVAC: Lead + Guard als koordiniertes Paket

CH-47
  8 Luftfahrzeuge
  8 Single-Ship-Asset-Gruppen
  SetGrouping(1)
  Static Sling Cargo: AUFTRAG CARGOTRANSPORT
  Group-/Storage-Logistik: OPSTRANSPORT
```

Zwingend:

```text
AssetGroups × Grouping = InventoryAircraft
RequiredGroups × Grouping = RequiredAircraft
```

## MOOSE-first Laufzeitarchitektur

MOOSE ist die operative Autorität:

```text
AUFTRAG
  RECON
  CAS
  Static CARGOTRANSPORT
  FREIGHTTRANSPORT
  Abort/Cancel

OPSTRANSPORT
  Infanteriegruppen
  Fahrzeuggruppen
  andere OPSGROUP-Cargos
  STORAGE-Transfer für Fuel, Waffen und Ausrüstung

FLIGHTGROUP / OPSGROUP
  konkrete dynamische Gruppe
  RTB
  LoadingDone
  UnloadingDone
  Lifecycle-Events

AIRWING / SQUADRON / LEGION
  Mission Queue
  Asset-Bestand
  Asset-Rekrutierung
  Carrier-Zuweisung
```

Der OMW-Code besitzt nur:

```text
Paket- und ORBAT-Vertrag
Parking-/Namensassertions
taktische Routen
Watchdog
unabhängige DCS-Abnahmekriterien
Testbericht
```

## Ersetzte Eigenentwicklungen

```text
interne missionqueue-Auswertung
  -> AIRWING:CountMissionsInQueue

squadron.assets und eigene requested/spawned/reserved-Zählung
  -> SQUADRON:CountAssets + AIRWING:CountAssetsOnMission

AID-Namenssuche und mission.groupdata
  -> AIRWING:OnAfterFlightOnMission + OPSTRANSPORT:GetCarriers

eigene operative Mission-FSM
  -> AUFTRAG-/OPSTRANSPORT-FSM

eigene Erfolgspoller
  -> AUFTRAG:AddConditionSuccess + native OPSTRANSPORT delivery

UH-60-spezifischer Cargo-Workaround
  -> generischer MOOSE-native Logistikadapter
```

## Generische Logistikprofile

```text
GROUP_CARGO
  OPSTRANSPORT Loaded / Unloaded / Delivered
  Carrier LoadingDone / UnloadingDone
  Infanterie, Fahrzeuge und andere OPSGROUPs

STORAGE_CARGO
  OPSTRANSPORT:AddCargoStorage
  Fuel, Waffen, Ausrüstung und Warehouse-Storage
  Carrier-Rekrutierung über LEGION.RecruitCohortAssets

STATIC_SLING_CARGO
  AUFTRAG:NewCARGOTRANSPORT
  native AUFTRAG-Zustände plus Static-in-Drop-Zone

STATIC_FREIGHT_CARGO
  AUFTRAG FREIGHTTRANSPORT

DYNAMIC_CARGO
  EVENTS.DynamicCargoLoaded
  EVENTS.DynamicCargoUnloaded
  EVENTS.DynamicCargoRemoved
```

Static Sling Cargo erzeugt keine OPSTRANSPORT-Gruppen-Cargo-Ereignisse. Dafür werden keine künstlichen Loaded-/Unloaded-Zustände erfunden.

## Despawn-Regel

In der gepinnten MOOSE-Version aktiviert

```lua
SQUADRON:SetDespawnAfterLanding(false)
```

das Despawnen trotzdem.

Deshalb gilt:

```text
UH-60 und CH-47:
  squadron-weites SetDespawnAfterLanding bleibt ungesetzt

nach nativer Delivery plus physischer Zielbestätigung:
  exaktes FLIGHTGROUP:SetDespawnAfterLanding()

Pickup-/Deploy-Landung:
  kein Despawn

folgende finale RTB-Landung:
  Despawn und Asset-Rückgabe erlaubt
```

Der Builder blockiert die erneute Verwendung des fehlerhaften `false`-Aufrufs.

## Entfernte Override-Dateien

```text
14a-phase1-lifecycle-corrections.lua
14b-phase1-sequence-finalization.lua
16-phase1-moose-compatibility.lua
17-phase1-operational-safety.lua
18-phase1-readiness-and-recon-telemetry.lua
19-phase1-oh58-formation-recovery-counting.lua
20-phase1-uh60-transport-lifecycle.lua
```

Kanonische Phase-1-Quellen:

```text
11-phase1-test-manifest.lua
12-phase1-runtime-observer.lua
12a-phase1-moose-logistics.lua
13-phase1-mission-factory.lua
14-phase1-test-controller.lua
15-phase1-f10-and-acceptance.lua
16-phase1-moose-first-readiness-routing.lua
```

## Validierte Grundknoten-Baseline

```text
24 OH-58D
 8 AH-64D
 8 UH-60
 8 CH-47

6 verpflichtende Clientgruppen
5 Late-Activation-KI-Templategruppen
20 sichtbare Luftfahrzeug-Statics
11 Funktionszonen
1 Warehouse-Anker
```

DCS-Typen:

```text
OH58D
AH-64D_BLK_II
UH-60A
CH-47Fbl1
```

Parking:

```text
6 Clientpositionen
4 dynamische KI-Reservepositionen
4 absichtlich belegte CH-47-Static-Parkknoten: 23,35,37,49
AIRWING:SetSafeParkingOn schützt Clientpositionen
```

## Repository- und Missionseditor-Workflow

Arbeitsgrenze:

```text
Assistent:
  Lua
  Builder
  Dokumentation
  GitHub-Commit
  Logauswertung

Projektinhaber:
  lokaler Pull
  lokaler Build
  DO SCRIPT FILE
  Missionseditor
  .miz
  DCS-Test
```

Ohne ausdrücklichen Auftrag erstellt oder verändert der Assistent keine `.miz`.

Lokaler Build:

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch

git branch --show-current
git status --short
git fetch origin
git switch feature/jalalabad-airwing-phase1-functional-tests
git pull --ff-only
git rev-parse HEAD

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File ".\tools\build-jalalabad-air-operations-bundle.ps1"
```

Nach jedem Neubau muss `OMW_AirOps_Jalalabad.lua` in der bestehenden `DO SCRIPT FILE`-Aktion erneut ausgewählt und die Mission unter demselben Namen gespeichert werden.

## Nächste Abnahmereihenfolge

```text
1. UH-60 OPSTRANSPORT GROUP_CARGO
2. CH-47 AUFTRAG STATIC_SLING_CARGO
3. OH-58D RECON physical two-ship
4. AH-64D CAS physical two-ship
5. UH-60 Abort/Release
6. Gesamtablauf
```

Der UH-60-Test steht zuerst, weil der wiederholte Despawn an der Pickup-Landung der unmittelbar zu beseitigende Fehler war.

## Freigabegrenze

```text
IMPLEMENTED ist kein DCS PASS.
```

Weitere Flugplätze, dynamische Spieleranforderungen und das vollständige MEDEVAC-Paket bleiben gesperrt, bis der lokale Build und alle DCS-Abnahmen bestanden sind.
