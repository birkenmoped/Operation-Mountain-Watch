---
document_id: OMW-MOOSE-TOWNS-DISCOVERY
status: PLANNED
document_class: MOOSE_SOURCE_REVIEW
owning_policy: OMW-GOV-MOOSE-FIRST
authoritative_for:
  - source-reviewed MOOSE TOWNS discovery interface
  - scope boundary of historical OMW towns fixtures
not_authoritative_for:
  - production settlement classification
  - DCS runtime validation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by: []
source_branch: agent/towns-discovery
source_commit: PENDING_MERGE
validated_in_dcs: false
moose_release: 2.9.18
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
---

# MOOSE TOWNS – Discovery-Schnittstelle

## Verifizierter Source-Scope

Der gepinnte MOOSE-Source enthält `Navigation.Towns` / `TOWNS` Version `0.1.0`.

Source-verifiziert:

```text
TOWNS:NewFromTable(TownTable) -> TOWNS
TOWNS:NewFromFile(FileName) -> TOWNS | nil
TOWNS:GetCoordinate(town) -> COORDINATE
TOWNS:GetCoordRoad(town) -> COORDINATE
TOWNS:GetCoordRail(town) -> COORDINATE
TOWNS:GetConnectionRoad(townA, townB, Railroad) -> PATHLINE
```

`NewFromFile()` nutzt `UTILS.FileExists`, lädt die terrain-spezifische `towns.lua` per `dofile()` und übergibt die Tabelle an `NewFromTable()`. `NewFromTable()` erzeugt je Town eine MOOSE-`COORDINATE` sowie nächste Straßen-/Schienenpunkte über `COORDINATE:GetClosestPointToRoad()`.

Der Source weist ausdrücklich darauf hin, dass für `NewFromFile()` Dateizugriff in einer entsprechend desanitisierten Development-Umgebung erforderlich ist. Operation Mountain Watch verändert `MissionScripting.lua` nicht automatisch.

## Offizielle Beispielprüfung

Die MOOSE-Source verweist auf offizielle Demo-Missionen unter `MOOSE_MISSIONS/Navigation - Towns`. Das öffentliche Repository `FlightControl-Master/MOOSE_MISSIONS_UNPACKED` ist erreichbar. Ein konkreter aktueller TOWNS-Demopfad konnte während dieser Reconciliation nicht reproduzierbar aufgelöst werden. Daher wird kein Demo- oder Runtime-PASS behauptet.

## OMW-Nutzung

Historischer Development-Fixture:

```text
src/dev/world-data/towns_discovery.lua
mission/tests/towns-discovery/
```

Der Fixture verwendet `TOWNS:NewFromFile()` als primären Town-Datenpfad. Ergänzende native DCS-Lesezugriffe und `io`/`lfs` bleiben auf Development-/Evidence-Scope begrenzt.

Die separate Scenery-Density-Discovery bleibt `HISTORICAL_TEST_FIXTURE`. Für eine produktive Scenery-/Settlement-Klassifikation ist ein neuer MOOSE-first Gap Review erforderlich; ein verbleibender Native-DCS-Fallback benötigt ausdrückliche Owner-Freigabe.

## Status

```text
TOWNS: SOURCE_REVIEWED
OMW historical discovery fixture: HISTORICAL_TEST_FIXTURE
DCS runtime validation for current pinned scope: NOT CLAIMED
production settlement classifier: NOT APPROVED
```
