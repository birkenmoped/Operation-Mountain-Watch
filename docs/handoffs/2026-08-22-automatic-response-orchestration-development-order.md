---
document_id: OMW-HANDOFF-AUTOMATIC-RESPONSE-ORCHESTRATION
status: PLANNED
document_class: DEVELOPMENT_ORDER_AND_HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local development order for automatic BLUE operational reactions
  - current implementation status and development-stage tracking
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
validated_in_dcs: partial
base_branch: main
base_commit: 28d0069d5d9ec66e62f1e81ad59fc3dd4e2e249c
---

# Entwicklungsauftrag – Automatic Response Orchestration

## 1. Ziel und Regeln

Ziel ist die geschlossene BLUE-Reaktionskette aus CampaignState, MissionDemand, Ground, Fire Support, AirOps und CSAR. CampaignState bleibt alleinige strategische Ressourcenautorität; MOOSE führt die physische operative Ebene aus.

Pflichtreihenfolge vor neuen Pfaden:

```text
AGENTS.md / Governance / MOOSE-first policy
-> aktuelle Fachbaseline
-> MOOSE docs
-> actual pinned Moose.lua
-> signatures / FSM / events / prerequisites
-> official examples
-> smallest MOOSE-native path
-> DCS acceptance
```

Keine `.miz`-Mutation durch ChatGPT. Kein CODEX.

## 2. Bereits integrierte Grundlagen auf main

```text
MissionDemand Foundation: merged
Ground RESUPPLY thresholds: merged
Fixed Fire Support / local ammo rearm: merged with documented DCS acceptance
```

## 3. Stage 1A – Ground AMMO Joyce -> Honaker

```text
Status: ACCEPTED_TECHNICAL_BASELINE
```

DCS-bestätigt:

```text
Honaker AMMO shortage / REORDER
-> MissionDemand RESUPPLY
-> CampaignState TRANSFER 20 Joyce -> Honaker
-> TPL_BLUE_CONVOY_LIGHT_06
-> BRIGADE / PLATOON / ARMYGROUP
-> AUFTRAG AMMOSUPPLY / OnRoad 27 kt
-> destination-zone proof
-> CampaignState DELIVERED
-> MissionDemand SUCCESS
-> 30 s post-MissionDone settlement
-> same ARMYGROUP RTZ Joyce
-> Returned
-> Warehouse AddAsset
-> physical cleanup
```

Provenienz:

```text
Source/build commit: 2d72bcdfc113342a2180b6cd9c84486da790052c
BuilderVersion: GROUND-AMMO-RESUPPLY-ACCEPTANCE-1-5
Bundle SHA-256: 752B3E6F0B77D1B62C750421DDE36202C81B98632FEFBF6A273F913202DF8339
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
DCS: 2.9.28.26385 MT
Executed mission: OMW_Template_v18.miz
Result: PASS
```

## 4. Stage 1B – Ground FUEL / FUELSUPPLY

```text
Status: FAILED / CLOSED FOR CURRENT OMW META-RESUPPLY USE
```

Build-Provenienz:

```text
Build Git HEAD: 4f651829e975f42d4aba44a9bd0813969a2f2d8b
BuilderVersion: GROUND-FUEL-RESUPPLY-ACCEPTANCE-1-1
Bundle SHA-256: A2C71E86244A2E6869E8A0A3D7384D917875064B11102CDA410A7DBD9C1C6922
Physical template: TPL_BLUE_CONVOY_FUEL_LIGHT_06
DCS: 2.9.28.26385 MT
Executed mission path: OMW_Template_v19.miz
```

Runtime:

```text
ROAD_ALIGNED_WAREHOUSE_SPAWN
GROUP_MATERIALIZED
ARMY_ON_MISSION mission=FUELSUPPLY
FAIL OUTBOUND_TIMEOUT
spawnCount=1
armyOnMissionCount=1
missionExecuteCount=0
missionDoneCount=0
```

Damit wurde der Return-Code nie erreicht. `FUELSUPPLY` wird nicht weiter durch Timer-/Radius-Raten angepasst.

`GROUND_FUEL_PACKAGE` bleibt bestehen als:

```text
CampaignState meta resource / count
```

Der M978-Konvoi ist physische Repräsentation; keine reale DCS-Fuel-Menge oder Package-per-Tanker-Kapazität wird daraus abgeleitet. Das fehlgeschlagene Acceptance-Bundle kann aus der Owner-Mission entfernt/deaktiviert werden; die Fuel-/Mixed-Convoy-Templates bleiben erhalten.

Detailresultat:

```text
mission/tests/ground-resupply-execution/results/2026-08-22-ground-fuel-resupply-acceptance-1-fail-1.md
```

## 5. MOOSE-first Ersatzprüfung

### 5.1 Kandidat A – WAREHOUSE SELFPROPELLED

Der gepinnte Source und die eingebettete Warehouse-Dokumentation belegen:

```text
WAREHOUSE:AddRequest(...)
WAREHOUSE.TransportType.SELFPROPELLED
```

Warehouse Example 15 verwendet `M978` und `M818` als selbstfahrende Ground-Assets zwischen Warehouses. Das ist ein echter MOOSE-native Ground-Transfer-Anwendungsfall.

Die harte Grenze ist jedoch ebenfalls source-seitig eindeutig:

```text
Arrived
-> RouteGroundTo(receiving warehouse coordinate)
-> receivingWarehouse:__AddAsset(60, group)
-> physical group removed into warehouse stock
```

Ein späterer Rücktransport materialisiert das Asset aus dem Ziel-Warehouse erneut. Ein öffentlicher Schalter zum Erhalt desselben physischen Groups nach Ankunft wurde nicht gefunden. `SetSpawnZone(...)` verändert nur die Spawnposition, nicht diesen Arrival-Handoff.

Daher:

```text
WAREHOUSE SELFPROPELLED
= source-reviewed native Warehouse transfer
= requires absorb/rematerialize lifecycle
= only compatible with OMW visibility rule if handoff areas are deliberately non-observable
```

Ob diese verdeckte Handoff-Variante gewollt ist, ist eine Owner-Designentscheidung.

### 5.2 Kandidat B – AUFTRAG NOTHING

Der gepinnte Source enthält:

```lua
AUFTRAG:NewNOTHING(RelaxZone)
```

Dokumentiert als Ground/Naval-Mission für Assets, die in einer Zielzone „do nothing“ sollen. Source-seitig bestätigt:

```text
GROUND supported
zone target
normal OPSGROUP/ARMYGROUP RouteToMission
public SetMissionSpeed(...)
public SetFormation(...)
SpecialTask.NOTHING -> FullStop at mission execution
TaskCancel -> done=true
```

Damit existiert ein MOOSE-native neutraler Move-and-Wait-Pfad:

```text
same physical convoy
-> move to destination zone
-> NOTHING executes / group stops
-> OMW validates exact arrival and settles CampaignState meta resource
-> cancel mission
-> MissionDone
-> same ARMYGROUP can RTZ to origin
```

Das vermeidet eine falsche Fuel-/Cargo-Semantik und behält CampaignState als alleinige Warenautorität. In den offiziellen `MOOSE_MISSIONS`-/`MOOSE_MISSIONS_UNPACKED`-Suchen wurde jedoch kein dediziertes `NewNOTHING`-Beispiel gefunden; daher bleibt der Pfad `SOURCE_REVIEWED / DCS_PENDING`.

### 5.3 Entscheidungsgrenze

```text
A) WAREHOUSE SELFPROPELLED
   Warehouse-owned transfer
   destination absorption/despawn
   later rematerialized return

B) AUFTRAG NOTHING
   neutral move-and-wait
   same physical convoy
   explicit CampaignState delivery settlement
   same-group RTZ
```

Für die bisherige OMW-Anforderung „keine beobachtbaren Spawn-/Despawn-Vorgänge“ ist B der kleinere fachliche Fit. Das ist noch keine stillschweigende Projektentscheidung und noch kein DCS-PASS.

## 6. Weitere Entwicklungsstufen

```text
Stage 1C Generic Ground SUPPLY: pending same generic transport decision
Stage 2 FOB attack -> support demand: PLANNED
Stage 3 fire support -> local rearm -> resupply: FOUNDATIONS AVAILABLE
Stage 4 convoy under attack -> support demand: PLANNED
Stage 5 BLUE assignment / CAS: BLOCKED BY BLUE COMMANDER RECONCILIATION
Stage 6 aircraft loss -> CSAR: PLANNED
Stage 7 end-to-end chain: PLANNED
Stage 8 restore/restart/idempotence: PLANNED
Stage 9 multiplayer/performance/failures: PLANNED
Stage 10 production reconciliation/merge readiness: PLANNED
```

## 7. Current handoff state

```text
current_branch: agent/automatic-response-orchestration
main_reference_checked_at: 2026-08-22
main_reference_commit: 28d0069d5d9ec66e62f1e81ad59fc3dd4e2e249c
stage_1a: ACCEPTED_TECHNICAL_BASELINE
stage_1b_fuelsupply: FAILED_CLOSED_FOR_META_RESUPPLY
stage_1b_test_lua_in_owner_mission: MAY_BE_REMOVED
fuel_meta_resource_model: RETAIN
fuel_convoy_templates: RETAIN
warehouse_selfpropelled_source: REVIEWED
warehouse_example_15_m978_m818: CONFIRMED_IN_PINNED_SOURCE_DOCS
warehouse_arrived_addasset_60s: CONFIRMED_IN_PINNED_SOURCE
warehouse_same_group_roundtrip: NOT_PROVIDED
auftrag_nothing_source: REVIEWED
auftrag_nothing_official_demo: NOT_FOUND_IN_CURRENT_SEARCH
auftrag_nothing_same_group_candidate: YES_SOURCE_SIDE
replacement_acceptance: NOT_YET_STAGED
production_runtime_implementation: NOT_YET_CREATED
next_allowed_step: OWNER_SELECTS_PHYSICAL_CONTRACT_A_OR_B
```
