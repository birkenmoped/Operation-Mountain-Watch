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
validated_in_dcs: false
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

Dieses Dokument ist laufender Entwicklungsauftrag und Handoff. Nach jedem relevanten Gate sind reale Hashes, Teststatus, offene Grenzen und der nächste zulässige Schritt einzutragen.

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
= main
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

Status: `BUILD_PASS / MIZ_PREFLIGHT_PASS / OWNER_EMBEDDING_RETRY_REQUIRED`

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
-> M1083 OnRoad to Honaker ACCESS
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

Build evidence:

```text
Build GitCommit: 99ea86bf61036f2d04008b17bcb8c1d6e236b030
GeneratedUtc: 2026-08-22T16:57:51Z
BuilderVersion: GROUND-AMMO-RESUPPLY-ACCEPTANCE-1-3
Bundle SHA-256: D1E908D08DF3DA787D01E760F5B9C01771F5D17CBBD51C8545A4A00086E10676
Independent bundle SHA-256: D1E908D08DF3DA787D01E760F5B9C01771F5D17CBBD51C8545A4A00086E10676
Builder SHA-256: AEF56E16FE896854D32EAE409FC04A6C8C0BE20266EF591242DC5C866C5FB820
Acceptance source SHA-256: 38E099C801286768FD9D1D39014BB767BCF99055602D1E06EDACA48634856C83
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
Build result: PASS
```

Design boundary:

```text
CampaignState owns cargo quantity.
MOOSE AMMOSUPPLY owns physical movement only.
OPSTRANSPORT is not used in Stage 1A.
```

Delivery boundary:

```text
MissionDone alone != delivery
Delivery requires exact AMMOSUPPLY MissionExecute
AND ARMYGROUP:IsInZone(Honaker ACCESS) == true
```

#### Stage 1A MIZ preflight – PASS

Selected source MIZ:

```text
OMW_Template_v16.miz
MIZ SHA-256: 91837A67121D769145136745BBAC2F12C92F4F054ED1EADD5E937EFB9533F8A9
internal mission SHA-256: BFC50C8FA4AA953D63B8D1AAEC8B927645253996FFA6990DF6D5118F98659AF7
```

Required object contract confirmed read-only:

```text
WH_BLUE_GND_JOYCE
ZON_BLUE_GND_JOYCE_ACCESS
ZON_BLUE_GND_HONAKER_ACCESS
TPL_BLUE_GND_SUP_M1083
```

Embedded startup resources confirmed:

```text
Moose.lua
OMW_AirOps_Warehouse_Base.lua
OMW_Ground_Base.lua
```

Startup mapping confirmed:

```text
Mission Start -> Moose.lua
time > 1 s -> OMW_AirOps_Warehouse_Base.lua
time > 2 s AND OMW_WAREHOUSE_READY == 1
-> OMW_Ground_Base.lua
-> OMW.Ground.Base.Attach(existing OMW.AirOps.CampaignContext)
```

Read-only preflight result:

```text
PASS
```

#### Stage 1A owner embedding attempt – 2026-08-22

Dedicated work copy created:

```text
OMW_Template_v16_Ground_Ammo_Resupply_Acceptance_1.miz
initial SHA-256: 91837A67121D769145136745BBAC2F12C92F4F054ED1EADD5E937EFB9533F8A9
```

Expected Mission Editor mutation:

```text
one ONCE trigger
OMW_WAREHOUSE_READY == 1
OMW_GROUND_READY == 1
DO SCRIPT FILE -> OMW_Ground_Ammo_Resupply_Acceptance_1.lua
```

Returned post-mutation evidence:

```text
post-mutation MIZ SHA-256:
91837A67121D769145136745BBAC2F12C92F4F054ED1EADD5E937EFB9533F8A9

post-mutation internal mission SHA-256:
BFC50C8FA4AA953D63B8D1AAEC8B927645253996FFA6990DF6D5118F98659AF7

OMW_WAREHOUSE_READY references: 16
OMW_GROUND_READY references: 0

result:
FAIL / NO_MIZ_MUTATION_OBSERVED
```

Die beiden Hashes sind exakt identisch zur unveränderten Ausgangsmission. Deshalb ist keine Mutation der Acceptance-Arbeitskopie nachgewiesen. Es wird keine Ursache geraten. Der vorherige read-only Preflight bleibt gültig. DCS bleibt gesperrt.

Detailed acceptance record:

```text
mission/tests/ground-resupply-execution/ACCEPTANCE-1.md
```

Next Stage-1A gate:

```text
open ONLY dedicated acceptance work copy
-> add the one required trigger
-> save the mission
-> close Mission Editor
-> verify MIZ hash changed
-> verify internal mission hash changed
-> verify OMW_GROUND_READY reference exists
-> then verify resource mapping / embedded bundle / Moose / structure
-> no DCS before full post-mutation PASS
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
completed_gate: STAGE_1A_BUILD_AND_READ_ONLY_MIZ_PREFLIGHT
current_stage: STAGE_1A_GROUND_AMMO_RESUPPLY
build_status: PASS
bundle_sha256: D1E908D08DF3DA787D01E760F5B9C01771F5D17CBBD51C8545A4A00086E10676
selected_source_miz: OMW_Template_v16.miz
selected_source_miz_sha256: 91837A67121D769145136745BBAC2F12C92F4F054ED1EADD5E937EFB9533F8A9
internal_mission_sha256_source: BFC50C8FA4AA953D63B8D1AAEC8B927645253996FFA6990DF6D5118F98659AF7
miz_preflight: PASS
dedicated_acceptance_miz: OMW_Template_v16_Ground_Ammo_Resupply_Acceptance_1.miz
owner_embedding_attempt: NO_MIZ_MUTATION_OBSERVED
post_mutation_miz_sha256: 91837A67121D769145136745BBAC2F12C92F4F054ED1EADD5E937EFB9533F8A9
post_mutation_internal_mission_sha256: BFC50C8FA4AA953D63B8D1AAEC8B927645253996FFA6990DF6D5118F98659AF7
omw_ground_ready_reference_count: 0
post_mutation_preflight: FAIL
embedded_bundle_hash: UNKNOWN / NOT REACHED
dcs_test_status: NOT RUN
production_runtime_implementation: NOT YET CREATED
known_failures: initial builder marker mismatch fixed; current gate blocked because no MIZ mutation was observed
open_owner_decisions: none; repeat the already approved acceptance embedding in the dedicated work copy
next_allowed_step: repeat owner Mission Editor embedding and prove that MIZ/internal mission hashes changed before further structure checks
```

## 7. Next allowed step

Only the already approved Stage-1A owner-side MIZ embedding retry is allowed.

```text
open dedicated acceptance MIZ
-> add exactly one Acceptance trigger
-> save and close Mission Editor
-> verify changed MIZ SHA-256
-> verify changed internal mission SHA-256
-> verify OMW_GROUND_READY reference exists
-> if those pass, continue embedded resource/hash checks
-> no DCS if any check fails
```

DCS execution remains not authorized.
