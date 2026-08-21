---
document_id: OMW-TEST-MISSION-DEMAND-FOUNDATION
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - current implementation and verification status of the MissionDemand domain foundation
  - current open blockers for automatic Ground resupply and Immediate CAS integration
not_authoritative_for:
  - DCS runtime acceptance
  - final Ground resupply threshold values
  - final ROAD_CONVOY routing implementation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/mission-demand-resupply-cas-concept
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# MissionDemand Foundation – Arbeits- und Prüfstand

## 1. Ziel

Der Branch `agent/mission-demand-resupply-cas-concept` baut die kleinste gemeinsame Domänenschicht für zwei erste dynamische Reaktionsketten:

```text
RESOURCE SHORTAGE -> RESUPPLY
TROOPS IN CONTACT -> CAS_IMMEDIATE
```

Grundregel:

```text
CampaignState = strategische Ressourcen- und Zustandsautorität
MOOSE         = operative Auswahl und Ausführung
DCS           = temporäre physische Repräsentation und Telemetrie
```

Es wird keine zweite Ressourcen-, Missions- oder Bestandsautorität aufgebaut.

## 2. Verbindlicher MOOSE-Stand

Für den Source-Review dieses Branches:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Relevante MOOSE-Kandidaten:

```text
BRIGADE / PLATOON / ARMYGROUP     documented Ground lifecycle evidence
AUFTRAG:NewAMMOSUPPLY             SOURCE_REVIEWED
AUFTRAG:NewFUELSUPPLY             SOURCE_REVIEWED
AMMOTRUCK                          SOURCE_REVIEWED / official MOOSE demo located
ARTY rearming lifecycle            SOURCE_REVIEWED
OPSTRANSPORT                       SOURCE_REVIEWED
EVENTS.Hit                         SOURCE_REVIEWED
AUFTRAG CAS / COMMANDER dispatch   SOURCE_REVIEWED
```

Kein eigener Ground-Ammo-Scheduler, Ammo-Truck-Dispatcher oder Rearm-Controller ist freigegeben oder vorgesehen, solange die vorhandenen MOOSE-Pfade ausreichen.

## 3. Phase 1 – MissionDemand Registry

Source:

```text
scripts/campaign/OMW_MissionDemand.lua
```

Typen:

```text
RESUPPLY
CAS_IMMEDIATE
```

Zustände:

```text
OPEN
PLAYER_ASSIGNED
AI_ASSIGNED
ACTIVE
SUCCESS
FAILED
EXPIRED
```

Der Registry-Vertrag enthält Deduplizierung, idempotente Create-Semantik, gegenseitig ausschließende Spieler-/KI-Zuweisung, terminale Freigabe des Dedupe-Key und Snapshot/Restore ohne MOOSE-/DCS-Objektreferenzen.

Contract-Test:

```text
tests/mission-demand/test_mission_demand.lua
```

Status:

```text
SOURCE STAGED
NOT EXECUTED WITH LUA INTERPRETER
NOT DCS VALIDATED
```

## 4. Phase 2 – ResourceDemandPolicy

Source:

```text
scripts/campaign/OMW_ResourceDemandPolicy.lua
```

Die Policy verwendet ausschließlich:

```text
target
reorder
critical
supplyParent
```

Semantik:

```text
reorder == 0
-> automatic resupply disabled

available <= critical and critical > 0
-> CRITICAL

available <= reorder
-> REORDER

requestedQuantity
= target - available
```

Die Policy reserviert nichts, mutiert CampaignState nicht und erzeugt keine MOOSE-Mission.

Contract-Test:

```text
tests/mission-demand/test_resource_demand_policy.lua
```

Status:

```text
SOURCE STAGED
NOT EXECUTED WITH LUA INTERPRETER
```

## 5. Owner-Entscheidung – Ground Ammo wird paketweise geführt

Owner-Entscheidung vom 21.08.2026:

```text
Ground ammunition in CampaignState
= standardisiertes strategisches Nachschub-/Rearm-Paket
!= einzelne DCS-Granate
!= detailliertes DCS-Truck-Inventar
```

Die bestehende Ground-Baseline verwendet bereits normalisierte `AMMO_UNIT`-Pakete. DCS-/MOOSE-Munitionszahlen dienen operativ zur Bedarfserkennung und Rearm-Bestätigung, werden aber nicht zur zweiten strategischen Ressourcenautorität.

Eine feinere Paket-Taxonomie wird erst eingeführt, wenn konkrete OMW-Empfängerklassen sie fachlich benötigen. Kategorien wie Artillery/Mortar/AT/Small-Arms werden nicht vorsorglich erfunden.

## 6. Resource-ID-Impact-Review

Der bisherige Ground-Stock verwendete für alle Ressourcen node-spezifische IDs, zum Beispiel:

```text
GROUND:GROUND_NODE_JOYCE:AMMO
GROUND:GROUND_NODE_HONAKER:AMMO
```

Der vorhandene CampaignState-Transfer ist dagegen bereits sauber als

```text
originNodeId + resourceId
-> TRANSFER
-> destinationNodeId + resourceId
```

modelliert. Der Ort gehört deshalb in `nodeId`, nicht zusätzlich in die ID einer fungiblen Transportressource.

Die frühere Branch-Idee, CampaignState um getrennte `originResourceId` und `destinationResourceId` zu erweitern, ist für diesen Ground-Resupply-Scope verworfen. Der generische CampaignState-Transaktionsvertrag bleibt unverändert.

## 7. Implementierte Normalisierung – kleinster notwendiger Scope

Implementiert auf diesem Branch:

```text
GROUND_SUPPLY_PACKAGE
GROUND_AMMO_PACKAGE
GROUND_FUEL_PACKAGE
```

Diese drei Ressourcen sind zwischen Ground-Nodes fungible Logistikpakete und besitzen deshalb auf allen Nodes dieselbe `resourceId`.

Bewusst unverändert bleiben vorerst:

```text
GROUND:<NODE>:PERSONNEL
GROUND:<NODE>:VEHICLE
GROUND:<NODE>:PERSONNEL_LOST
GROUND:<NODE>:VEHICLE_LOST
```

Begründung:

```text
- der aktuelle Resupply-Scope benötigt nur die fungiblen Logistikpakete;
- der akzeptierte Ground-Settlement-Vertrag korreliert PERSONNEL/VEHICLE node-lokal;
- unnötige Änderungen an validierter Settlement-Semantik werden vermieden;
- eine spätere echte Cross-Node-Personnel-/Vehicle-Verlegung erhält einen eigenen Domain-Review.
```

Damit wird nicht pauschal jede Ground-ID umbenannt, sondern nur die für den aktuellen Transferbedarf erforderliche Redundanz entfernt.

Source:

```text
scripts/logistics/OMW_GroundInitialStock.lua
SchemaVersion = OMW-GROUND-INITIAL-STOCK-2
```

## 8. Strategischer Transfer nach der Normalisierung

Beispiel:

```text
JOYCE
GROUND_AMMO_PACKAGE = 44

HONAKER
GROUND_AMMO_PACKAGE = 40
```

Ein Transfer kann mit dem bestehenden CampaignState-Vertrag erfolgen:

```text
resourceId        = GROUND_AMMO_PACKAGE
originNodeId      = GROUND_NODE_JOYCE
destinationNodeId = GROUND_NODE_HONAKER
quantity          = N packages
```

Lifecycle bleibt:

```text
RESERVED
-> LOADING
-> IN_TRANSIT
-> DELIVERED
```

oder Verlust/Abbruch über die bereits vorhandenen CampaignState-Transitions.

## 9. Snapshot-Migrationspfad

`docs/04-campaign-state.md` verlangt für persistierte Saves einen Migrationspfad. Deshalb wird kein stiller Hard-Cut auf alte Ground-Snapshots vorgenommen.

`OMW_GroundInitialStock.lua` stellt bereit:

```lua
GroundInitialStock.MigrateSnapshot(snapshot)
```

Der Migrationspfad:

```text
legacy GROUND:<NODE>:SUPPLY -> GROUND_SUPPLY_PACKAGE
legacy GROUND:<NODE>:AMMO   -> GROUND_AMMO_PACKAGE
legacy GROUND:<NODE>:FUEL   -> GROUND_FUEL_PACKAGE
```

PERSONNEL/VEHICLE und deren Loss-Audit-IDs bleiben unverändert.

Der Migration-Code mutiert den übergebenen Snapshot nicht. Enthält ein Snapshot gleichzeitig Legacy- und normalisierte ID für dieselbe Ressource, wird die Migration abgebrochen statt Mengen stillschweigend zusammenzuführen.

Ein alter `GROUND-COMMIT` auf SUPPLY/AMMO/FUEL wird ebenfalls ausdrücklich abgelehnt. Solche Commodity-Commitments gehörten nicht zum akzeptierten Foundation-Settlement, und eine stillschweigende Umdeutung wäre nicht beweissicher.

Der zentrale Initializer stellt zusätzlich bereit:

```lua
OMW_AirOpsCampaignStateInitializer.MigrateSnapshot(...)
OMW_AirOpsCampaignStateInitializer.RestoreStore(...)
```

Damit können Stock-Module ihre migrationsspezifische Logik vor `CampaignState.Restore()` anwenden, ohne Ground-Sonderlogik in den generischen CampaignState einzubauen.

Initializer-Schema:

```text
OMW-AIROPS-CAMPAIGNSTATE-INITIALIZER-5
```

## 10. Neuer Contract-Test

Neu:

```text
tests/mission-demand/test_ground_resource_normalization.lua
```

Der Test prüft source-seitig:

```text
- gemeinsame AMMO-ID in Joyce und Honaker;
- bestehender CampaignState TRANSFER Joyce -> Honaker ohne Schemaerweiterung;
- origin debit / destination credit;
- Legacy-Snapshot-Migration für SUPPLY/AMMO/FUEL;
- PERSONNEL-/VEHICLE-IDs bleiben unverändert.
```

Der gemeinsame Runner enthält den Test:

```text
tests/mission-demand/run.lua
```

Aktueller Ausführungsstatus:

```text
TEST SOURCE STAGED
NOT EXECUTED WITH LUA INTERPRETER
NOT DCS VALIDATED
```

Ein DCS-Lauf ist für diese reine Domain-/Snapshotlogik nicht erforderlich. Vor Abschluss des Branches bleibt jedoch ein ausführbarer Lua-Contract-Test erforderlich.

## 11. Ground-Rearm-Ausführung – noch nicht implementiert

Die Resource-ID-Normalisierung entscheidet nicht, welcher MOOSE-Pfad die physische Versorgung übernimmt.

Weiter zu vergleichen:

```text
ARTY RearmingGroup / RearmingPlace
AMMOTRUCK
BRIGADE + AUFTRAG:NewAMMOSUPPLY()
```

Die Auswahl muss vom konkreten Empfänger- und Missionsmodell abhängen. Kein eigener Ammo-Monitor oder Dispatcher wird parallel entwickelt.

Für den späteren OMW-DCS-Test sind insbesondere zu erfassen:

```text
konkreter Empfänger / Template
DCS/MOOSE Ammo-Zustand vor Rearm
physische Truck-/Supply-Bewegung
Rearm-Completion
Rückkehr / Lifecycle
CampaignState Settlement genau einmal
```

## 12. BLUE COMMANDER / CAS Dependency

Für CAS wird kein zweiter COMMANDER entwickelt.

Vorhandener separater Branch:

```text
agent/blue-commander-foundation
```

Vor CAS-Runtime muss dieser gegen den dann aktuellen `main` reconciled und gemäß eigener Acceptance-/Merge-Grenze integriert werden.

Danach:

```text
MOOSE Hit
-> TacticalSupportIncident
-> AIR_SUPPORT_REQUEST
-> CAS_IMMEDIATE MissionDemand
-> AIR_TASKING_PLAN
-> AUFTRAG
-> BLUE COMMANDER
```

## 13. Nächste Gates

```text
GATE 1  MissionDemand Registry                         STAGED
GATE 2  ResourceDemandPolicy                          STAGED
GATE 3  transferable Ground resource-ID normalization IMPLEMENTED / TEST SOURCE STAGED
GATE 4  package taxonomy beyond generic packages      ONLY IF REQUIRED BY REAL OMW CONSUMERS
GATE 5  MOOSE Ground ammo execution selection         OPEN
GATE 6  BLUE COMMANDER reconciliation                  OPEN
GATE 7  Hit -> TacticalSupportIncident -> CAS          OPEN
GATE 8  CAS AUFTRAG dispatch / DCS acceptance          OPEN
```

## 14. Aktuelle Validierungsgrenze

```text
MissionDemand contract test source             STAGED / NOT EXECUTED
ResourceDemandPolicy contract test source       STAGED / NOT EXECUTED
Ground resource normalization test source       STAGED / NOT EXECUTED
Ground legacy snapshot migration                SOURCE IMPLEMENTED / NOT EXECUTED
MOOSE Ground rearm review                       SOURCE_REVIEWED / NOT OMW-DCS-VALIDATED
MOOSE/DCS runtime                               NOT STARTED
```

Kein Eintrag dieses Branches wird allein durch Source-Review oder Contract-Test-Source als `VALIDATED` bezeichnet.
