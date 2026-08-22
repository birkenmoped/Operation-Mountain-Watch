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

Der M978-Konvoi ist physische Repräsentation; keine reale DCS-Fuel-Menge oder Package-per-Tanker-Kapazität wird daraus abgeleitet.

Das fehlgeschlagene Acceptance-Bundle kann der Owner aus der Mission entfernen/deaktivieren. Die neuen Fuel-/Mixed-Convoy-Templates bleiben erhalten.

Detailresultat:

```text
mission/tests/ground-resupply-execution/results/2026-08-22-ground-fuel-resupply-acceptance-1-fail-1.md
```

## 5. MOOSE-first Ersatzprüfung

Der gepinnte MOOSE-Source belegt `AUFTRAG:NewFUELSUPPLY(Zone)` primär im Kontext von `BRIGADE:AddRefuellingZone(...)`. Ein Warehouse-to-Warehouse-Roundtrip für abstrakte Fuel-Pakete ist nicht durch eine dedizierte offizielle Demo belegt.

Der stärkere generische MOOSE-Kandidat ist:

```text
WAREHOUSE:AddRequest(...)
WAREHOUSE.TransportType.SELFPROPELLED
```

MOOSE Warehouse Example 15 verwendet ausdrücklich selbstfahrende `M978`- und `M818`-Ground-Assets zwischen Warehouses. Der Source routet Ground-Assets über `_RouteGround(...)` zum anfordernden Warehouse.

Offene harte Grenze:

```text
WAREHOUSE:onafterArrived(...)
-> receiving warehouse
-> mobile group routes toward warehouse
-> __AddAsset(60, group)
```

Damit übernimmt MOOSE das Asset physisch in den Ziel-Warehouse-Stock. Ein späterer Rücktransport würde aus diesem Stock erneut materialisiert. Das muss vor Adoption gegen die OMW-Regel `no observable spawn/despawn/teleport` reconciliert werden.

Status:

```text
WAREHOUSE SELFPROPELLED: SOURCE_REVIEWED CANDIDATE
visual destination handoff: OPEN
replacement acceptance: NOT_YET_STAGED
custom/native DCS fallback: NOT_APPROVED
```

## 6. Weitere Entwicklungsstufen

```text
Stage 1C Generic Ground SUPPLY: pending same generic transport reconciliation
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
current_research: WAREHOUSE_SELFPROPELLED_GENERIC_PHYSICAL_TRANSFER
warehouse_selfpropelled_source: REVIEWED
warehouse_example_15_m978_m818: CONFIRMED_IN_PINNED_SOURCE_DOCS
warehouse_arrived_addasset_60s: CONFIRMED_IN_PINNED_SOURCE
observable_handoff_gate: OPEN
replacement_acceptance: NOT_YET_STAGED
production_runtime_implementation: NOT_YET_CREATED
next_allowed_step: RESOLVE_WAREHOUSE_VISUAL_HANDOFF_AND_SELECT_REPLACEMENT_ACCEPTANCE
```
