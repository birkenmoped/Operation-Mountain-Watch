---
document_id: OMW-HANDOFF-AUTOMATIC-RESPONSE-ORCHESTRATION
status: PLANNED
document_class: DEVELOPMENT_ORDER_AND_HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local development order for automatic BLUE operational reactions
  - current implementation status and development-stage tracking for this branch
  - mandatory handoff state for automatic support, resupply and CSAR orchestration
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - branch-local planning assumptions from agent/mission-demand-resupply-cas-concept
superseded_by:
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
validated_in_dcs: partial
base_branch: main
base_commit: 28d0069d5d9ec66e62f1e81ad59fc3dd4e2e249c
---

# Entwicklungsauftrag – Automatic Response Orchestration

## 1. Zweck / Arbeitsbranch

```text
branch: agent/automatic-response-orchestration
base: main @ 28d0069d5d9ec66e62f1e81ad59fc3dd4e2e249c
```

Ziel ist die geschlossene automatische BLUE-Reaktionskette aus bereits integrierten CampaignState-, MissionDemand-, Ground-, Fire-Support-, AirOps- und CSAR-Bausteinen. Bestehende MOOSE-/Production-Funktionalität wird nicht parallel neu implementiert.

## 2. Verbindliche Arbeitsregeln

Vor jeder neuen Entwicklungsstufe oder nach längerer Unterbrechung aktuelle `main`-Regeln erneut lesen:

```text
AGENTS.md
docs/00-project-governance.md
docs/22-test-mission-build-transfer-and-validation-workflow.md
docs/26-moose-first-development-policy.md
docs/DOCUMENT-METADATA-POLICY.md
docs/SUBPROJECT-REGISTRY.md
mission/tests/GOVERNANCE.md
```

MOOSE-First:

```text
MOOSE docs
-> actual pinned Moose.lua
-> signatures / returns / FSM / events / prerequisites
-> official demos/tests where relevant
-> direct MOOSE/configuration/callbacks
-> smallest adapter only if still required
```

Aufgabentrennung:

```text
ChatGPT:
Repository/Governance -> implementation/docs/tests -> diff/guards -> commit/publish -> local handoff

Project owner:
PowerShell local checks -> Mission Editor/.miz work where required -> DCS -> real console/hashes/logs/debrief/observations
```

Lokale Grenze:

```text
Lua interpreter: NOT AVAILABLE
Python: NOT AVAILABLE
local checks/builds: PowerShell only
build instructions: always code blocks
no invented local build/hash/DCS result
no CODEX
```

## 3. Current source of truth

```text
agent/mission-demand-resupply-cas-concept
= HISTORICAL REFERENCE ONLY

CURRENT SOURCE OF TRUTH
= main plus this branch-local staged/acceptance work
```

Bereits integriert:

```text
PR #114 / MissionDemand Foundation
merge: 341a65105c24807de3ac289bb18d80339111cbd1
- MissionDemand registry/state model
- RESUPPLY
- CAS_IMMEDIATE
- assignment exclusivity
- active dedupe
- snapshot/restore
- ResourceDemandPolicy

PR #115 / Ground RESUPPLY thresholds
merge: 34b1f46120f951ca2a6308cf1d9fbbb4b0a17863
- reorder = 50% of target
- critical = 25% of target

PR #112 / Fixed Fire Support / local ammo rearm
- merged
- physical MOOSE/DCS rearm PASS for documented provenance
- same-session restore settlement PASS
- external process/server persistence NOT TESTED / NOT CLAIMED
```

CampaignState bleibt alleinige strategische Ressourcenautorität.

## 4. Endziele

```text
A. FOB attacked
   -> ARTY / CAS / QRF support demand

B. Fire-support unit depleted
   -> own-site M1083 local rearm

C. Ground stock <= reorder/critical
   -> RESUPPLY demand
   -> physical transport
   -> delivery/loss settlement

D. BLUE resupply convoy attacked
   -> deduplicated support demand

E. CAS helicopter lost with surviving isolated personnel
   -> one CSARIncident
   -> Player CSAR or AICSAR
```

Architektur:

```text
CampaignState = strategic truth/resource authority
MissionDemand = demand identity/assignment state
MOOSE = operational execution
DCS groups = temporary physical representation
```

## 5. Entwicklungsstufen

### Stage 0 – Governance / Ist-Stand / MOOSE Ground reconciliation

Status: `COMPLETE FOR STAGE-1A SCOPE`

```text
current main rules reviewed
PR #114/#115/#112 reconciled
CampaignState TRANSFER lifecycle reviewed
Ground production separation reviewed
BRIGADE/PLATOON/ARMYGROUP/AUFTRAG lifecycle reviewed
Ground return lifecycle reviewed
OMW_GroundRoadSpawnAdapter confirmed as existing owner-approved exception
NewAMMOSUPPLY / NewFUELSUPPLY source-confirmed
AUFTRAG:NewOPSTRANSPORT excluded because unavailable/commented in pinned source
no new non-MOOSE exception required for Stage 1A
```

Technical review:

```text
docs/moose/GROUND-RESUPPLY-EXECUTION-SOURCE-REVIEW.md
```

### Stage 1 – Physical RESUPPLY execution

Status: `IN DEVELOPMENT`

#### Stage 1A – Ground AMMO / Joyce -> Honaker

Status: `DCS_DELIVERY_PATH_CONFIRMED / PROTECTED_CONVOY_RETEST_BUILD_PASS`

Target chain:

```text
Honaker AMMO 40
-> test-only CampaignState CONSUMPTION 20
-> Honaker AMMO 20 == reorder
-> ResourceDemandPolicy candidate
-> one MissionDemand RESUPPLY
-> CampaignState TRANSFER 20 Joyce -> Honaker
-> MOOSE BRIGADE / PLATOON / ARMYGROUP
-> AUFTRAG AMMOSUPPLY
-> protected convoy OnRoad to Honaker ACCESS
-> exact MissionExecute + IsInZone(destination)
-> MarkDelivered
-> MissionDemand SUCCESS
-> explicit RTZ Joyce ACCESS OnRoad
-> Returned -> Warehouse AddAsset
```

Expected strategic end state:

```text
JOYCE AMMO   44 -> 24
HONAKER AMMO 40 -> 20 -> 40
```

##### Physical template decision

Der Projektinhaber hat entschieden, die bereits in der Mission vorhandenen Convoy-Templates zu verwenden:

```text
TPL_BLUE_CONVOY_LIGHT_06
TPL_BLUE_CONVOY_STANDARD_07
```

Für Stage 1A:

```text
TPL_BLUE_CONVOY_LIGHT_06
```

Noch **nicht** festgelegt:

```text
package-per-truck capacity
automatic LIGHT_06 vs STANDARD_07 selection
```

Die strategische Transfermenge bleibt CampaignState-Autorität und wird in diesem Acceptance-Slice nicht aus der Zahl der physischen Trucks abgeleitet.

##### DCS-Lauf 1

```text
MIZ: OMW_Template_v17.miz
Result: FAIL
reason: RESOURCE_DEMAND_POLICY_NO_CANDIDATE
root cause: stale embedded Ground production bundle with pre-PR-115 zero thresholds
physical AMMOSUPPLY reached: no
```

Detailed result:

```text
mission/tests/ground-resupply-execution/results/2026-08-22-ground-ammo-resupply-acceptance-1-fail-1.md
```

##### Ground production rebuild

Owner-local real build evidence:

```text
Build Git HEAD: cfc7edb4bc7db771569c54224432fd501ddeea57
BuilderVersion: OMW-GROUND-PRODUCTION-BASE-4
OMW_Ground_Base.lua SHA-256: E616D35F5EBDBDDD4275785091D47F57445348D1FF4BB4CFBE7DEE0F0B12D78E
Builder SHA-256: 3A7B61B3EC19A442D6B3C933FF467AF4671421AB30C37D801D98F481BA3BD355
GroundInitialStock SHA-256: 7F73F489D7E896C815D57FAD54A62B2185932539E44471087C2826729B6FEE66
```

##### DCS-Lauf 2

```text
MIZ: OMW_Template_v18.miz
MIZ SHA-256: 2518A950CC36110552AA962179D5D8A4674F4C73E1518009706DAA79DBF92C09
internal mission SHA-256: A94F9F4D77245A0FA6E65B7E7657E5B8B3457CFD5FCB60A528F83EA57B563F34
DCS: 2.9.28.26385
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
Ground production bundle SHA-256: E616D35F5EBDBDDD4275785091D47F57445348D1FF4BB4CFBE7DEE0F0B12D78E
Acceptance bundle SHA-256: D1E908D08DF3DA787D01E760F5B9C01771F5D17CBBD51C8545A4A00086E10676
Result: FAIL / DELIVERY PATH CONFIRMED / ROUNDTRIP INCOMPLETE
```

Observed markers:

```text
DEMAND_RESERVED
PHYSICAL_EXECUTION_READY
BRIGADE_STARTED
MISSION_QUEUED type=AMMOSUPPLY
GROUP_MATERIALIZED
ARMY_ON_MISSION
DELIVERY_CONFIRMED ... quantity=20 ... demandStatus=SUCCESS
MISSION_DONE deliveryCommitted=true
RETURN_RTZ_ACTIVE
RETURN_RTZ_ISSUED ... Joyce ... OnRoad
FAIL reason=TIMEOUT seconds=1800 ... returnedCount=0 addAssetCount=0
```

Bewertung:

```text
ResourceDemand: PASS for run-2 scope
MissionDemand reservation: PASS for run-2 scope
CampaignState IN_TRANSIT debit: PASS for run-2 scope
physical AMMOSUPPLY outbound: PASS for run-2 scope
destination-zone delivery proof: PASS for run-2 scope
CampaignState DELIVERED: PASS for run-2 scope
MissionDemand SUCCESS: PASS for run-2 scope
RTZ accepted: PASS for run-2 scope
Returned: NOT TESTED TO COMPLETION
Warehouse AddAsset: NOT TESTED TO COMPLETION
Stage 1A overall: NOT PASS
```

Detailed result:

```text
mission/tests/ground-resupply-execution/results/2026-08-22-ground-ammo-resupply-acceptance-1-fail-2.md
```

##### Acceptance correction after run 2

Der vorherige Harness hatte einen einzigen 1800-s-Timeout ab Teststart. Der Rückweg begann erst kurz vor dessen Ablauf. Außerdem plante der Harness die finale Prüfung nur 3 s nach `Returned`, während der gepinnte MOOSE-Source in `ARMYGROUP:onafterReturned` erst `legion:__AddAsset(10, group, 1)` plant.

Aktualisierter Vertrag:

```text
physical template: TPL_BLUE_CONVOY_LIGHT_06
OUTBOUND_TIMEOUT_SEC = 1800
RETURN_TIMEOUT_SEC = 1800, starts only after accepted RTZ
RETURN_SETTLEMENT_DELAY_SEC = 12
```

Source/build files:

```text
mission/tests/ground-resupply-execution/src/01-ground-ammo-resupply-acceptance.lua
tools/build-ground-ammo-resupply-acceptance-1.ps1
BuilderVersion: GROUND-AMMO-RESUPPLY-ACCEPTANCE-1-4
```

Owner-local real build evidence:

```text
Build Git HEAD: 0c082407c6d35f094037ecdf118f84c29bacf2bc
GeneratedUtc: 2026-08-22T17:45:47Z
BuilderVersion: GROUND-AMMO-RESUPPLY-ACCEPTANCE-1-4
Bundle SHA-256: 3B42E2D3B302B489BBB567B2DC4AD6DEA393C0867ECE73C8107F856A1E016854
Independent bundle SHA-256: 3B42E2D3B302B489BBB567B2DC4AD6DEA393C0867ECE73C8107F856A1E016854
Builder SHA-256: 4922E8167C74B649C40369BFD73D811F8011FB7DCC8B203DE02BF8C6A609F045
Acceptance source SHA-256: 21A5CFEBB5ED6747A5E71A78D977C71CE4B4D9E0B8139A510276F7F5EE800DD2
MissionDemand source SHA-256: E348E75B87135B99D780E07CA6B6FB7C3C530E048E9C6DE790328D147DE32848
ResourceDemandPolicy source SHA-256: BDC20ACEDAB60F662093077B8320220EBB71C6C641CC604C4356231B8405913C
GroundRoadSpawnAdapter source SHA-256: 1A81FB2E5270C493373CF5BF6EC01F5AFED47004BF25C4225524121155D983E8
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
Build result: PASS
```

Detailed acceptance plan:

```text
mission/tests/ground-resupply-execution/ACCEPTANCE-1.md
```

#### Stage 1B – Ground FUEL

Status: `PLANNED AFTER STAGE 1A`

```text
MOOSE candidate: AUFTRAG:NewFUELSUPPLY(Zone)
```

#### Stage 1C – Generic Ground SUPPLY

Status: `BLOCKED FOR SEPARATE MOOSE GAP REVIEW`

No equivalent generic `AUFTRAG:NewSUPPLY(...)` API is confirmed for the pinned MOOSE scope. No unrelated mission type may be used as a hidden substitute. Any fallback requires a documented gap and owner decision.

### Stage 2 – FOB attack -> support demand

Status: `PLANNED`

```text
verified attack/contact source
-> deduplicated TacticalSupportIncident
-> capability/range/readiness/resources/ROE
-> ARTY / QRF / CAS demand
```

### Stage 3 – Fire support -> local rearm -> RESUPPLY follow-up

Status: `PLANNED / FOUNDATIONS AVAILABLE`

```text
reuse PR #112 local rearm
-> CampaignState consumption
-> ResourceDemandPolicy reevaluation
-> exactly one RESUPPLY demand when threshold crossed
```

### Stage 4 – Convoy under attack -> support demand

Status: `PLANNED`

```text
physical convoy lifecycle as event source
-> deduplicated support incident
-> transport demand and support demand remain separate
```

### Stage 5 – BLUE assignment / CAS execution

Status: `BLOCKED BY BLUE COMMANDER RECONCILIATION`

```text
current COMMANDER/AIRWING/SQUADRON/AUFTRAG review
-> selective reconciliation
-> exclusive player/AI assignment
-> CAS_IMMEDIATE runtime
```

### Stage 6 – Aircraft loss -> CSARIncident -> Player/AICSAR

Status: `PLANNED`

```text
final CSARIncident model/FSM
-> verified loss/ejection/survival event source
-> one incident
-> Player/AICSAR exclusivity
-> persistent final settlement
```

### Stage 7 – End-to-End chain

Status: `PLANNED`

```text
FOB attacked
-> support demand
-> artillery
-> fire
-> local ammo rearm
-> stock threshold
-> RESUPPLY demand
-> physical convoy
-> convoy attacked
-> support demand
-> response
-> delivery/loss settlement
```

plus CSAR chain after CAS aircraft loss.

### Stage 8 – Restore / restart / idempotence

Status: `PLANNED`

No duplicate demands, reservations, debits, credits or unexplained losses. External process/server restart only after real test.

### Stage 9 – Multiplayer / performance / failures

Status: `PLANNED`

Parallel demands, assignment races, destroyed carriers/responders, routing failures, aborts, reconnect and scheduler load.

### Stage 10 – Production reconciliation / merge readiness

Status: `PLANNED`

Full diff, tests, MOOSE docs, exact acceptance provenance, registries, no stale `PENDING_MERGE` on `main`, no runtime claims beyond tested scope.

## 6. Current handoff state

```text
current_branch: agent/automatic-response-orchestration
main_reference_checked_at: 2026-08-22
main_reference_commit: 28d0069d5d9ec66e62f1e81ad59fc3dd4e2e249c
current_stage: STAGE_1A_GROUND_AMMO_RESUPPLY
completed_runtime_gate: DCS_RUN_2_DELIVERY_AND_RTZ_ACCEPTANCE
stage_1a_overall: NOT_PASS
run_1: FAIL_RESOURCE_DEMAND_POLICY_STALE_GROUND_BUNDLE
run_2: FAIL_GLOBAL_TIMEOUT_AFTER_DELIVERY_AND_RTZ
run_2_delivery: PASS_FOR_DOCUMENTED_SCOPE
run_2_rtz_acceptance: PASS_FOR_DOCUMENTED_SCOPE
run_2_returned: NOT_REACHED_BEFORE_TIMEOUT
run_2_add_asset: NOT_REACHED_BEFORE_TIMEOUT
selected_physical_template_next_run: TPL_BLUE_CONVOY_LIGHT_06
standard_template_available: TPL_BLUE_CONVOY_STANDARD_07
package_per_truck_capacity: NOT_DEFINED
automatic_convoy_class_selection: NOT_DEFINED
acceptance_builder_version_next: GROUND-AMMO-RESUPPLY-ACCEPTANCE-1-4
new_acceptance_build: PASS
new_acceptance_build_git_head: 0c082407c6d35f094037ecdf118f84c29bacf2bc
new_acceptance_bundle_sha256: 3B42E2D3B302B489BBB567B2DC4AD6DEA393C0867ECE73C8107F856A1E016854
new_acceptance_builder_sha256: 4922E8167C74B649C40369BFD73D811F8011FB7DCC8B203DE02BF8C6A609F045
new_acceptance_source_sha256: 21A5CFEBB5ED6747A5E71A78D977C71CE4B4D9E0B8139A510276F7F5EE800DD2
production_ground_bundle_sha256: E616D35F5EBDBDDD4275785091D47F57445348D1FF4BB4CFBE7DEE0F0B12D78E
production_runtime_implementation: NOT YET CREATED
next_allowed_step: owner Mission Editor replacement of Acceptance DO SCRIPT FILE resource in new MIZ revision, then static preflight
```

## 7. Next allowed step

Der neue Acceptance-Build ist reproduzierbar nachgewiesen. Als nächstes darf der Projektinhaber im Mission Editor ausschließlich die Acceptance-Ressource aktualisieren:

```text
base MIZ: OMW_Template_v18.miz
-> save as next MIZ revision
-> keep Moose.lua unchanged
-> keep OMW_AirOps_Warehouse_Base.lua unchanged
-> keep current OMW_Ground_Base.lua unchanged
-> keep Acceptance trigger and conditions unchanged
-> replace only DO SCRIPT FILE resource OMW_Ground_Ammo_Resupply_Acceptance_1.lua
   with local bundle SHA-256 3B42E2D3B302B489BBB567B2DC4AD6DEA393C0867ECE73C8107F856A1E016854
-> save/close Mission Editor
-> static MIZ/resource/hash preflight
-> no DCS run before preflight PASS
```

Keine `.miz`-Mutation durch ChatGPT. Kein DCS-Lauf vor neuem Bundle-/MIZ-Provenienzgate.
