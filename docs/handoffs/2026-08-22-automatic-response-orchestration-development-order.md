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

Status: `DCS FAIL / OUTBOUND ROUTING RECONCILIATION REQUIRED`.

Owner-Build-Provenienz:

```text
Source/build commit: cb32f23886e68371bf45ab4f7a1394200f542c29
BuilderVersion: GROUND-META-RESUPPLY-NOTHING-ACCEPTANCE-1-1
Bundle SHA-256: BC9A70327A456FC8718907B9701E83194303B0A5816F0EA0C309310D7118B8FE
Builder SHA-256: 68A58E3F2C0C05D79B0FFC642CEDEB70008748FE81EE56D31BE9437CDB070E37
Acceptance source SHA-256: 7B91D5DD74C874C03CB36FAF6CF9231201D45CB51FD749644EDA857A9FFD137E
GroundRoadSpawnAdapter SHA-256: 1A81FB2E5270C493373CF5BF6EC01F5AFED47004BF25C4225524121155D983E8
```

Read-only MIZ-Provenienz nach dem Lauf:

```text
Executed path from debrief: OMW_Template_v19.miz
Uploaded MIZ SHA-256: A4D04484584A04C092AAFF31981A477F9179203944B7DAAD4C7CF2D2DD8A63FF
Internal mission SHA-256: B68EDC033D9C8E2FE0F8F93C81A063425F019F1C7A38A30710833AD367BCA90A
Embedded acceptance bundle SHA-256: BC9A70327A456FC8718907B9701E83194303B0A5816F0EA0C309310D7118B8FE
Embedded Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
Trigger: ONCE / OMW_WAREHOUSE_READY=1 / OMW_GROUND_READY=1 / TIME>5
Old Ground AMMO/FUEL acceptance bundle embedded: NO
TPL_BLUE_CONVOY_FUEL_LIGHT_06: present / lateActivation=true / six vehicles
```

DCS 2.9.28.26385 MT beobachtet:

```text
START
DEMAND_RESERVED quantity=18
PHYSICAL_EXECUTION_READY physicalMission=NOTHING
BRIGADE_STARTED
MISSION_QUEUED type=NOTHING formation=OnRoad speedKt=27
ROAD_ALIGNED_WAREHOUSE_SPAWN units=6 formationLengthM=76.8 maxSnapM=2.1
GROUP_MATERIALIZED transferStatus=LOADING
ARMY_ON_MISSION mission=NOTHING transferStatus=IN_TRANSIT demandStatus=ACTIVE
WARNING TRANSPORT: CREATING PATH MAKES TOO LONG!!!!!
FAIL reason=OUTBOUND_TIMEOUT seconds=600 destinationObserved=false spawnCount=1 armyOnMissionCount=1 missionExecuteCount=0 missionDoneCount=0
```

Damit wurde weder Honaker ACCESS beobachtet noch `MissionExecute` erreicht. Delivery-, MissionDone- und RTZ-Pfade wurden nicht ausgeführt und sind für NOTHING weiterhin nicht runtime-validiert.

Log-Provenienz:

```text
dcs.log SHA-256: 23E2D0B31B66464A57D3BC5F45F92A75D4EF913413833311042CD4BC74F1AAA3
debrief.log SHA-256: 2574F8746F6D4A88E6D6F038AFC33DB5600DC4D52CC6A0E946A8E2155B0D8922
```

Detailresultat:

```text
mission/tests/ground-resupply-execution/results/2026-08-23-ground-meta-resupply-nothing-acceptance-1-fail-1.md
```

Der nächste Schritt ist ausdrücklich kein weiterer DCS-Test. Zuerst wird die Ground-Route-/Waypoint-Erzeugung von AMMOSUPPLY und NOTHING im gepinnten MOOSE-Source gegeneinander reconciliert, insbesondere im Zusammenhang mit `CREATING PATH MAKES TOO LONG!!!!!`.

## 7. Weitere Entwicklungsstufen

```text
Stage 1D generic SUPPLY / other meta resources: BLOCKED BY STAGE 1C ROUTING
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
stage_1c_owner_build: PASS
stage_1c_miz_preflight: PASS_READ_ONLY_POST_RUN
stage_1c_dcs_runtime: FAIL_OUTBOUND_TIMEOUT
stage_1c_destination_observed: false
stage_1c_mission_execute: 0
stage_1c_mission_done: 0
stage_1c_route_warning: CREATING_PATH_MAKES_TOO_LONG
production_runtime_implementation: NOT_YET_CREATED
next_allowed_step: COMPARE_AMMOSUPPLY_VS_NOTHING_GROUND_ROUTE_GENERATION
```
