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

`GROUND_FUEL_PACKAGE` bleibt CampaignState-Meta-Ressource. Der M978 ist nur physische Repräsentation; keine reale DCS-Fuelmenge wird daraus abgeleitet.

Der `FUELSUPPLY`-Versuch erreichte `ARMY_ON_MISSION`, aber kein MissionExecute/MissionDone/RTZ und wird für diesen OMW-Meta-Warenpfad nicht weiter angepasst.

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

### Run 1 – gültige Provenienz, aber Harness-FALSE-FAIL

Owner-Build-Provenienz:

```text
Source/build commit: cb32f23886e68371bf45ab4f7a1394200f542c29
BuilderVersion: GROUND-META-RESUPPLY-NOTHING-ACCEPTANCE-1-1
Bundle SHA-256: BC9A70327A456FC8718907B9701E83194303B0A5816F0EA0C309310D7118B8FE
```

Read-only MIZ-Provenienz:

```text
Executed path from debrief: OMW_Template_v19.miz
Uploaded MIZ SHA-256: A4D04484584A04C092AAFF31981A477F9179203944B7DAAD4C7CF2D2DD8A63FF
Internal mission SHA-256: B68EDC033D9C8E2FE0F8F93C81A063425F019F1C7A38A30710833AD367BCA90A
Embedded acceptance bundle SHA-256: BC9A70327A456FC8718907B9701E83194303B0A5816F0EA0C309310D7118B8FE
Embedded Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Runtime bis zum Harness-FAIL:

```text
ROAD_ALIGNED_WAREHOUSE_SPAWN
GROUP_MATERIALIZED
ARMY_ON_MISSION mission=NOTHING
FAIL reason=OUTBOUND_TIMEOUT seconds=600 destinationObserved=false missionExecuteCount=0 missionDoneCount=0
```

Owner-Beobachtung danach:

```text
Convoy physically reached Honaker
Convoy did not return
```

Die ursprüngliche Diagnose `OUTBOUND ROUTING FAILURE` ist verworfen. Joyce-ACCESS -> Honaker-ACCESS beträgt rund 16,9 km Luftlinie. Bei 27 kt (~50 km/h) ist die theoretische Mindestfahrzeit bereits rund 1.218 s. Der 600-s-Timeout war daher zu kurz.

Nach dem Timeout setzte der Harness `state.failed=true`; spätere MissionExecute-/MissionDone-/RTZ-Callbacks wurden damit absichtlich ignoriert. Das erklärt, warum der Convoy physisch weiterfuhr und später nicht zurückgeschickt wurde.

Klassifikation:

```text
HARNESS_FALSE_FAIL_OUTBOUND_TIMEOUT_TOO_SHORT
NewNOTHING runtime acceptance: NOT YET PROVEN
```

Der DCS-Marker `CREATING PATH MAKES TOO LONG!!!!!` bleibt als Diagnosehinweis, ist aber nicht als Root Cause des fehlenden Returns belegt.

### Korrigierter Stage-1C-Harness

```text
OUTBOUND_TIMEOUT_SEC = 1800
DESTINATION_CHECK_INTERVAL_SEC = 15
DESTINATION_EXECUTION_GRACE_SEC = 90
RETURN_TIMEOUT_SEC = 1800
RETURN_ISSUE_DELAY_SEC = 30
RETURN_SETTLEMENT_DELAY_SEC = 12
```

Der Fail-fast-Schutz bleibt erhalten: Nach tatsächlichem Eintritt in Honaker ACCESS muss MissionExecute binnen 90 Sekunden folgen.

Korrigierte Remote-Commits:

```text
7cb6c4a07788543da5840af6ac73ff4729749f1d  Restore viable outbound timeout for meta resupply acceptance
e0ac65f447b193ea8152bdb5984c5344de346ba9  Bump meta resupply builder after timeout correction
```

BuilderVersion:

```text
GROUND-META-RESUPPLY-NOTHING-ACCEPTANCE-1-2
```

Detailresultat des ersten Laufs:

```text
mission/tests/ground-resupply-execution/results/2026-08-23-ground-meta-resupply-nothing-acceptance-1-fail-1.md
```

## 7. Weitere Entwicklungsstufen

```text
Stage 1D generic SUPPLY / other meta resources: BLOCKED UNTIL CORRECTED STAGE 1C RETEST
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
main_reference_checked_at: 2026-08-23
main_reference_commit: 28d0069d5d9ec66e62f1e81ad59fc3dd4e2e249c
stage_1a: ACCEPTED_TECHNICAL_BASELINE
stage_1b_fuelsupply: FAILED_CLOSED_FOR_META_RESUPPLY
fuel_meta_resource_model: RETAIN
fuel_convoy_templates: RETAIN
warehouse_selfpropelled: SOURCE_REVIEWED_NOT_SELECTED_FOR_CONTINUOUS_ROUNDTRIP
stage_1c_executor: AUFTRAG_NEWNOTHING
stage_1c_owner_contract: APPROVED_2026_08_22
stage_1c_run1_provenance: PASS
stage_1c_run1_classification: HARNESS_FALSE_FAIL_OUTBOUND_TIMEOUT_TOO_SHORT
stage_1c_newnothing_runtime_validation: PENDING
stage_1c_corrected_outbound_timeout_sec: 1800
stage_1c_builder_version: GROUND-META-RESUPPLY-NOTHING-ACCEPTANCE-1-2
production_runtime_implementation: NOT_YET_CREATED
next_allowed_step: OWNER_PULL_BUILD_HASH_GATE
```
