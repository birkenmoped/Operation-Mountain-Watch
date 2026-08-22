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

Pflichtreihenfolge:

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

Status: `ACCEPTED_TECHNICAL_BASELINE`.

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

Status: `FAILED / CLOSED FOR CURRENT OMW META-RESUPPLY USE`.

Build-/Runtime-Evidenz:

```text
BuilderVersion: GROUND-FUEL-RESUPPLY-ACCEPTANCE-1-1
Bundle SHA-256: A2C71E86244A2E6869E8A0A3D7384D917875064B11102CDA410A7DBD9C1C6922
Physical template: TPL_BLUE_CONVOY_FUEL_LIGHT_06
DCS: 2.9.28.26385 MT
ROAD_ALIGNED_WAREHOUSE_SPAWN
GROUP_MATERIALIZED
ARMY_ON_MISSION mission=FUELSUPPLY
FAIL OUTBOUND_TIMEOUT
missionExecuteCount=0
missionDoneCount=0
```

Return-Code wurde nie erreicht. `FUELSUPPLY` wird für die abstrakte OMW-Meta-Ware nicht weiter angepasst.

`GROUND_FUEL_PACKAGE` bleibt CampaignState-Meta-Ressource. Der M978 ist nur physische Repräsentation; keine reale DCS-Fuelmenge wird daraus abgeleitet.

## 5. MOOSE-first Ersatzreconciliation

### WAREHOUSE SELFPROPELLED

Source und Warehouse Example 15 belegen Ground-Warehouse-zu-Warehouse-Transfer. Der Ziel-Handoff absorbiert das physische Asset jedoch in das Ziel-Warehouse; eine Rückfahrt benötigt neue Materialisierung. Damit nicht ausgewählt für den OMW-Vertrag eines kontinuierlichen Hin-/Rückwegs mit demselben Convoy.

### AUFTRAG NOTHING

Der gepinnte Source bestätigt:

```text
AUFTRAG:NewNOTHING(RelaxZone)
AUFTRAG.Type.NOTHING
AUFTRAG.SpecialTask.NOTHING
GROUND/NAVAL categories
NOTHING execution -> ground/naval __FullStop(0.1)
TaskCancel NOTHING -> TaskDone -> MissionDone lifecycle
```

Owner-Entscheidung 22.08.2026:

```text
AUFTRAG NewNOTHING physical meta-resupply contract: APPROVED FOR ACCEPTANCE
```

## 6. Stage 1C – Generic Ground Meta RESUPPLY via NOTHING

Status: `STAGED / SOURCE_REVIEWED / OWNER BUILD PENDING / DCS_PENDING`.

Erster Fixture bleibt bewusst Fuel, damit gegenüber Stage 1B nur die physische Missionssemantik gewechselt wird:

```text
HONAKER GROUND_FUEL_PACKAGE 36
-> consume 18
-> 18 / REORDER
-> one MissionDemand RESUPPLY
-> CampaignState TRANSFER 18 Joyce -> Honaker
-> TPL_BLUE_CONVOY_FUEL_LIGHT_06
-> BRIGADE / PLATOON / ARMYGROUP
-> AUFTRAG:NewNOTHING(Honaker ACCESS)
-> OnRoad 27 kt
-> exact destination-zone proof
-> CampaignState DELIVERED
-> MissionDemand SUCCESS
-> mission cancel / MissionDone
-> 30 s settlement
-> same ARMYGROUP RTZ Joyce ACCESS / OnRoad
-> Returned
-> Warehouse AddAsset
-> physical cleanup
```

Fail-fast:

```text
OutboundTimeoutSec: 600
DestinationCheckIntervalSec: 15
DestinationExecutionGraceSec: 90
```

Nach beobachtetem Eintritt in Honaker ACCESS muss `MissionExecute` binnen 90 Sekunden folgen; andernfalls endet der Harness mit `DESTINATION_EXECUTION_TIMEOUT`.

Staged files:

```text
mission/tests/ground-resupply-execution/src/03-ground-meta-resupply-nothing-acceptance.lua
mission/tests/ground-resupply-execution/ACCEPTANCE-3.md
tools/build-ground-meta-resupply-nothing-acceptance-1.ps1
```

## 7. Weitere Entwicklungsstufen

```text
Stage 1D generic SUPPLY / other meta resources: after Stage 1C runtime evidence
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

## 8. Current handoff state

```text
current_branch: agent/automatic-response-orchestration
main_reference_checked_at: 2026-08-22
main_reference_commit: 28d0069d5d9ec66e62f1e81ad59fc3dd4e2e249c
stage_1a: ACCEPTED_TECHNICAL_BASELINE
stage_1b_fuelsupply: FAILED_CLOSED_FOR_META_RESUPPLY
fuel_meta_resource_model: RETAIN
fuel_convoy_templates: RETAIN
warehouse_selfpropelled: SOURCE_REVIEWED_NOT_SELECTED_FOR_CONTINUOUS_ROUNDTRIP
stage_1c_executor: AUFTRAG_NEWNOTHING
stage_1c_owner_contract: APPROVED_2026_08_22
stage_1c_source: STAGED
stage_1c_builder: STAGED
stage_1c_owner_build: NOT_RUN
stage_1c_dcs_runtime: NOT_RUN
production_runtime_implementation: NOT_YET_CREATED
next_allowed_step: OWNER_PULL_BUILD_HASH_GATE
```
