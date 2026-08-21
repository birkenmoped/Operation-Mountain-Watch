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
ARTY rearming lifecycle            SOURCE_REVIEWED / preferred fixed-battery path
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

## 10. Contract-Tests

Vorhanden:

```text
tests/mission-demand/test_ground_resource_normalization.lua
tests/mission-demand/test_ground_ammo_rearm_adapter.lua
```

Der Normalisierungstest prüft source-seitig:

```text
- gemeinsame AMMO-ID in Joyce und Honaker;
- bestehenden CampaignState TRANSFER Joyce -> Honaker ohne Schemaerweiterung;
- origin debit / destination credit;
- Legacy-Snapshot-Migration für SUPPLY/AMMO/FUEL;
- PERSONNEL-/VEHICLE-IDs bleiben unverändert.
```

Der neue Rearm-Adapter-Test prüft source-seitig:

```text
- lokale CONSUMPTION-Reservation vor ARTY-Rearm;
- Consume im öffentlichen ARTY OnBeforeRearm-Hook;
- keine physische Freigabe bei fehlgeschlagener Consumption;
- Cancel ohne Verbrauch bei von ARTY abgelehntem Rearm;
- idempotente Wiederholung derselben transactionId;
- Rearmed-Callback ohne zweite Ressourcenbuchung.
```

Der gemeinsame Runner enthält beide Tests:

```text
tests/mission-demand/run.lua
```

Aktueller Ausführungsstatus:

```text
TEST SOURCE STAGED
NOT EXECUTED WITH LUA INTERPRETER
NOT DCS VALIDATED
```

## 11. Ground-Rearm-Ausführung – korrigierte Source-Entscheidung

Die weitergehende Prüfung des gepinnten `ARTY`-FSM ergibt für die festen OMW-Feuerunterstützungsgruppen einen saubereren MOOSE-First-Pfad als die zuvor bevorzugte `AMMOTRUCK`-Klasse:

```text
PREFERRED FOR FIXED OMW FIRE-SUPPORT GROUPS:
ARTY + SetRearmingGroup(...)

SECONDARY / POOL SERVICE:
AMMOTRUCK

GENERIC ZONE SUPPLY:
BRIGADE + AUFTRAG:NewAMMOSUPPLY()
```

Begründung:

```text
ARTY
- akzeptiert eine konkrete RearmingGroup;
- prüft im internen onbeforeRearm, ob Rearm überhaupt nötig und möglich ist;
- erlaubt OnBeforeRearm als öffentlichen OMW-Kopplungspunkt vor physischer Bewegung;
- besitzt mit Rearmed einen Vollrearm-Completion-Pfad;
- schickt die RearmingGroup danach an ihre Ausgangsposition zurück.

AMMOTRUCK
- ist ein autonomer Pool-Monitor/Dispatcher;
- quittiert TruckReturning bereits oberhalb des Schwellenwertes, nicht zwingend erst bei Vollrearm;
- erzeugt im geprüften Unloading-Pfad zusätzliche sichtbare ammo_cargo-Statics;
- bleibt für spätere Pool-Szenarien relevant, ist aber nicht der kleinste erste Fixed-Battery-Pfad.
```

Kein eigener Ammo-Monitor, Truck-Dispatcher oder Rearm-Controller wird entwickelt.

## 12. Read-only v15 Template Review / M1083-Kandidat

Vom Projektinhaber bereitgestellte Mission:

```text
Mission artifact: OMW_Template_v15(1).miz
SHA-256: e7bb9fbafd70174f76944e7a5e84f25ef5263b426c9834ef38bc03c026bde051
Inspection: read-only
```

Bestätigte Gruppen/TypeNames:

```text
TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2
  2 x L118_Unit
  mission-start present

TPL_BLUE_GND_SUP_M1083
  1 x CHAP_M1083
  lateActivation = true

TPL_BLUE_GND_SUP_M939_1
  1 x M 818
  lateActivation = true

TPL_BLUE_GND_SUP_TANKER_1
  1 x M978 HEMTT Tanker
  lateActivation = true

ZON_BLUE_GND_BOSTICK_ACCESS
  present
```

Die Screenshots des Projektinhabers zeigen beim M1083 und beim M939 denselben Mission-Editor-Versorgungsring. Das ist starke DCS-Editor-Evidenz dafür, dass `CHAP_M1083` als Versorgungseinheit konfiguriert ist, ersetzt aber keinen DCS-Runtime-Rearm-Test.

Der gepinnte MOOSE-Helper `UNIT:IsAmmoSupply()` kennt `M 818` hartcodiert, nicht `CHAP_M1083`. Der für diesen Vertical Slice bevorzugte `ARTY:SetRearmingGroup(group)`-Pfad verlangt jedoch eine konkrete `GROUP` und führt an dieser Stelle keine `UNIT:IsAmmoSupply()`-Prüfung aus.

Damit gilt:

```text
preferred OMW runtime candidate = TPL_BLUE_GND_SUP_M1083
reference/fallback candidate    = TPL_BLUE_GND_SUP_M939_1
M1083 DCS rearm capability      = DCS RUNTIME CONFIRMATION REQUIRED
```

Die v15-Supply-Gruppen sind reine Late-Activation-Templates an Template-Koordinaten. Der Rearm-Adapter materialisiert sie nicht selbst. Ein lebendes M1083-GROUP-Objekt muss zuerst über den bestehenden Ground-/MOOSE-Materialisierungslifecycle bereitgestellt werden.

## 13. Owner-Entscheidung – RESUPPLY und REARM sind getrennte Buchungen

Owner-Bestätigung vom 21.08.2026:

```text
INTER-NODE RESUPPLY
= CampaignState TRANSFER
= Zieldepotbestand steigt

LOCAL REARM
= CampaignState CONSUMPTION am lokalen Node
= danach autorisierter MOOSE/DCS-Rearm
```

Ein physischer Direktkonvoi darf beide Vorgänge unmittelbar nacheinander darstellen. Strategisch bleiben Transfer und Consumption getrennte idempotente Transaktionen. Dadurch kann ein Paket nicht gleichzeitig eine Batterie nachladen und zusätzlich im Zieldepotbestand verbleiben.

Der neue Adapter setzt diese Grenze absichtlich so um:

```text
ReserveResource(CONSUMPTION)
-> ARTY:Rearm()
-> built-in ARTY onbeforeRearm validates battery/rearming-group preconditions
-> OMW OnBeforeRearm consumes exactly once
-> erst danach ARTY onafterRearm starts physical movement
-> ARTY Rearmed confirms operational full-rearm completion
```

Wenn ARTY den Rearm bereits vor dem OMW-OnBefore-Hook ablehnt, wird die Reservation wieder storniert und es findet kein strategischer Verbrauch statt.

## 14. Implementierter Adapter-Scope

Neu:

```text
scripts/ground/OMW_GroundAmmoRearmAdapter.lua
SchemaVersion = OMW-GROUND-AMMO-REARM-ADAPTER-1
```

Der Adapter:

```text
- besitzt keinen eigenen Store;
- reserviert/verbraucht nur über den übergebenen CampaignState;
- erzeugt keine DCS-/MOOSE-Gruppen;
- wählt keinen Supply-Node;
- materialisiert keinen Truck;
- entwickelt keinen eigenen Dispatcher/Scheduler;
- erhält bereits materialisierte artilleryGroup/rearmingGroup-MOOSE-GROUPs;
- erzeugt/konfiguriert ARTY über eine injizierte Factory;
- nutzt ausschließlich den öffentlichen ARTY-Rearm-FSM als operative Ausführung.
```

Runtime-Status:

```text
SOURCE IMPLEMENTED
CONTRACT TEST SOURCE STAGED
NOT EXECUTED WITH LUA INTERPRETER
NOT DCS VALIDATED
```

## 15. BLUE COMMANDER / CAS Dependency

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

## 16. Nächste Gates

```text
GATE 1  MissionDemand Registry                         STAGED
GATE 2  ResourceDemandPolicy                          STAGED
GATE 3  transferable Ground resource-ID normalization IMPLEMENTED / TEST SOURCE STAGED
GATE 4  package taxonomy beyond GROUND_AMMO_PACKAGE    DEFERRED UNTIL ACTUAL NEED
GATE 5  MOOSE Ground ammo execution selection         SOURCE_DECIDED: ARTY FOR FIXED BATTERIES
GATE 6  concrete BLUE ammo-supply truck/template       M1083 CANDIDATE PRESENT / DCS REARM TEST REQUIRED
GATE 7  strategic RESUPPLY-vs-REARM booking boundary   OWNER APPROVED
GATE 8  Ground ammo runtime adapter                    SOURCE IMPLEMENTED / DCS INTEGRATION OPEN
GATE 9  M1083 + Bostick L118 DCS integration           OPEN
GATE 10 BLUE COMMANDER reconciliation                  OPEN
GATE 11 Hit -> TacticalSupportIncident -> CAS          OPEN
GATE 12 CAS AUFTRAG dispatch / DCS acceptance          OPEN
```

## 17. Aktuelle Validierungsgrenze

```text
MissionDemand contract test source             STAGED / NOT EXECUTED
ResourceDemandPolicy contract test source       STAGED / NOT EXECUTED
Ground resource normalization test source       STAGED / NOT EXECUTED
Ground legacy snapshot migration                SOURCE IMPLEMENTED / NOT EXECUTED
ARTY / AMMOTRUCK Ground rearm review            SOURCE_REVIEWED / NOT OMW-DCS-VALIDATED
Ground ammo executor selection                  SOURCE_DECIDED: ARTY FIXED-BATTERY PATH
M1083 ammo-supply role                          EDITOR EVIDENCE / DCS RUNTIME OPEN
RESUPPLY-vs-REARM booking boundary              OWNER APPROVED
Ground ammo rearm adapter                       SOURCE IMPLEMENTED / TEST SOURCE STAGED
MOOSE/DCS runtime                               NOT STARTED
```

Kein Eintrag dieses Branches wird allein durch Source-Review oder Contract-Test-Source als `VALIDATED` bezeichnet.
