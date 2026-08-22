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

## 1. Arbeitsbranch und Ziel

```text
branch: agent/automatic-response-orchestration
base: main @ 28d0069d5d9ec66e62f1e81ad59fc3dd4e2e249c
```

Ziel ist die geschlossene automatische BLUE-Reaktionskette aus CampaignState, MissionDemand, Ground, Fire Support, AirOps und CSAR. CampaignState bleibt alleinige strategische Ressourcenautorität; MOOSE führt die physische operative Ebene aus.

## 2. Verbindliche Arbeitsregeln

Vor jeder neuen Entwicklungsstufe prüfen:

```text
AGENTS.md
docs/00-project-governance.md
docs/22-test-mission-build-transfer-and-validation-workflow.md
docs/26-moose-first-development-policy.md
docs/DOCUMENT-METADATA-POLICY.md
docs/SUBPROJECT-REGISTRY.md
mission/tests/GOVERNANCE.md
```

MOOSE-first:

```text
MOOSE docs
-> actual pinned Moose.lua
-> signatures / returns / FSM / events / prerequisites
-> official demos/tests
-> direct MOOSE/configuration/callbacks
-> smallest adapter only if still required
```

Aufgabentrennung:

```text
ChatGPT:
Repository/Governance -> implementation/docs/tests -> diff/guards -> commit/publish -> local handoff

Project owner:
PowerShell local checks -> Mission Editor/.miz work -> DCS -> real console/hashes/logs/debrief/observations
```

Keine `.miz`-Mutation durch ChatGPT. Kein CODEX.

## 3. Bereits integrierte Grundlagen auf main

```text
PR #114 / MissionDemand Foundation
merge: 341a65105c24807de3ac289bb18d80339111cbd1

PR #115 / Ground RESUPPLY thresholds
merge: 34b1f46120f951ca2a6308cf1d9fbbb4b0a17863

PR #112 / Fixed Fire Support / local ammo rearm
merged; exact documented DCS acceptance exists
```

## 4. Endziele

```text
A. FOB attacked -> ARTY / CAS / QRF support demand
B. Fire-support unit depleted -> local M1083 rearm
C. Ground stock <= reorder/critical -> RESUPPLY demand -> physical transport -> settlement
D. BLUE resupply convoy attacked -> deduplicated support demand
E. CAS helicopter lost with survivors -> CSARIncident -> Player/AICSAR
```

## 5. Entwicklungsstufen

### Stage 0 – Governance / Ist-Stand / MOOSE reconciliation

```text
Status: COMPLETE FOR STAGE-1A/1B SCOPE
```

Source review:

```text
docs/moose/GROUND-RESUPPLY-EXECUTION-SOURCE-REVIEW.md
```

### Stage 1A – Ground AMMO Joyce -> Honaker

```text
Status: ACCEPTED_TECHNICAL_BASELINE
```

Bestätigte Kette:

```text
Honaker AMMO 40 -> consumption 20 -> REORDER
-> one MissionDemand RESUPPLY
-> CampaignState TRANSFER 20 Joyce -> Honaker
-> TPL_BLUE_CONVOY_LIGHT_06
-> BRIGADE / PLATOON / ARMYGROUP
-> AUFTRAG AMMOSUPPLY / OnRoad 27 kt
-> destination-zone proof
-> CampaignState DELIVERED
-> MissionDemand SUCCESS
-> MissionDone
-> 30 s settlement window
-> same ARMYGROUP RTZ Joyce ACCESS / OnRoad
-> Returned
-> Warehouse AddAsset
-> physical cleanup
```

Provenienz:

```text
Acceptance source/build commit: 2d72bcdfc113342a2180b6cd9c84486da790052c
BuilderVersion: GROUND-AMMO-RESUPPLY-ACCEPTANCE-1-5
Acceptance bundle SHA-256: 752B3E6F0B77D1B62C750421DDE36202C81B98632FEFBF6A273F913202DF8339
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
DCS: 2.9.28.26385 MT
Executed mission: OMW_Template_v18.miz
MIZ SHA-256: 2FDF31A2E07409CF392D45BFF5FC69750958C670AE3E12FF28D0B4FD8AECC90D
internal mission SHA-256: 38B207278365CD977E74FF3C9000C6A7C5B13EEE3E5B1BB154F1775055D02AF6
Result: PASS
```

### Stage 1B – Ground FUEL Joyce -> Honaker

```text
Status: SOURCE_REVIEWED / OWNER BUILD PASS / MISSION EDITOR INTEGRATION NEXT
```

MOOSE-first review confirmed in the pinned source:

```text
AUFTRAG:NewFUELSUPPLY(Zone)
AUFTRAG.Type.FUELSUPPLY
AUFTRAG.SpecialTask.FUELSUPPLY
```

Online MOOSE documentation lists `NewFUELSUPPLY(Zone)` as a Ground FUEL SUPPLY mission. Official `MOOSE_MISSIONS` and `MOOSE_MISSIONS_UNPACKED` were searched; no dedicated current `NewFUELSUPPLY` demo was found. No API or runtime behavior is inferred from a nonexistent demo.

Owner-created `OMW_Template_v19.miz` was inspected read-only:

```text
MIZ SHA-256: B89DBE7B755D25B43384B158F3D25921C70847820F71B837F12F86C5D863A8A6
internal mission SHA-256: 6B15369398C3B5989B676DB473127489C236F5948737AA3242FDB182FD515B95
```

Selected physical fixture:

```text
TPL_BLUE_CONVOY_FUEL_LIGHT_06
lateActivation=true
6 vehicles
1 CHAP_MATV
2 M978 HEMTT Tanker
3 MaxxPro_MRAP
4 M978 HEMTT Tanker
5 MaxxPro_MRAP
6 CHAP_MATV
```

Stage-1B target chain:

```text
Honaker FUEL 36
-> test-only consumption 18
-> Honaker FUEL 18 == reorder
-> one MissionDemand RESUPPLY
-> CampaignState TRANSFER 18 Joyce -> Honaker
-> TPL_BLUE_CONVOY_FUEL_LIGHT_06
-> MOOSE BRIGADE / PLATOON / ARMYGROUP
-> AUFTRAG FUELSUPPLY / OnRoad 27 kt
-> exact destination-zone delivery proof
-> CampaignState DELIVERED
-> MissionDemand SUCCESS
-> MissionDone
-> 30 s settlement window
-> same ARMYGROUP RTZ Joyce ACCESS / OnRoad
-> Returned
-> Warehouse AddAsset
-> physical cleanup
```

Expected final strategic state:

```text
JOYCE FUEL   40 -> 22
HONAKER FUEL 36 -> 18 -> 36
```

Owner-local build evidence:

```text
Build Git HEAD: 4f651829e975f42d4aba44a9bd0813969a2f2d8b
GeneratedUtc: 2026-08-22T19:25:35Z
BuilderVersion: GROUND-FUEL-RESUPPLY-ACCEPTANCE-1-1
Bundle SHA-256: A2C71E86244A2E6869E8A0A3D7384D917875064B11102CDA410A7DBD9C1C6922
Independent bundle SHA-256: A2C71E86244A2E6869E8A0A3D7384D917875064B11102CDA410A7DBD9C1C6922
Builder SHA-256: 3A8CFA93058C8595CE48E9BBE102D8F020BDC69B8D36F74DAF20E9CC439E18E4
Acceptance source SHA-256: 38FF22AE66FB5B85BFDD4096AAF4AE05D4B0E53436AD5DB4DBC882FA2D93AA1A
MissionDemand source SHA-256: E348E75B87135B99D780E07CA6B6FB7C3C530E048E9C6DE790328D147DE32848
ResourceDemandPolicy source SHA-256: BDC20ACEDAB60F662093077B8320220EBB71C6C641CC604C4356231B8405913C
GroundRoadSpawnAdapter source SHA-256: 1A81FB2E5270C493373CF5BF6EC01F5AFED47004BF25C4225524121155D983E8
Build result: PASS
```

Capacity remains intentionally undefined:

```text
1 M978 = X GROUND_FUEL_PACKAGE      NOT_DEFINED
FUEL_LIGHT_06 capacity              NOT_DEFINED
FUEL_STD_07 capacity                NOT_DEFINED
automatic convoy class selection    NOT_DEFINED
```

No new MOOSE exception is introduced. The existing owner-approved road-spawn adapter is reused unchanged.

### Stage 1C – Generic Ground SUPPLY

```text
Status: BLOCKED FOR SEPARATE MOOSE GAP REVIEW
```

Keine gleichwertige generische öffentliche `AUFTRAG:NewSUPPLY(...)`-API ist bestätigt. Kein Ersatzmissionstyp ohne dokumentierten MOOSE-Gap und Owner-Entscheidung.

### Stage 2 – FOB attack -> support demand

```text
Status: PLANNED
```

### Stage 3 – Fire support -> local rearm -> RESUPPLY follow-up

```text
Status: PLANNED / FOUNDATIONS AVAILABLE
```

### Stage 4 – Convoy under attack -> support demand

```text
Status: PLANNED
```

### Stage 5 – BLUE assignment / CAS execution

```text
Status: BLOCKED BY BLUE COMMANDER RECONCILIATION
```

### Stage 6 – Aircraft loss -> CSARIncident -> Player/AICSAR

```text
Status: PLANNED
```

### Stage 7 – End-to-End chain

```text
Status: PLANNED
```

### Stage 8 – Restore / restart / idempotence

```text
Status: PLANNED
```

### Stage 9 – Multiplayer / performance / failures

```text
Status: PLANNED
```

### Stage 10 – Production reconciliation / merge readiness

```text
Status: PLANNED
```

## 6. Current handoff state

```text
current_branch: agent/automatic-response-orchestration
main_reference_checked_at: 2026-08-22
main_reference_commit: 28d0069d5d9ec66e62f1e81ad59fc3dd4e2e249c
stage_1a_overall: ACCEPTED_TECHNICAL_BASELINE
current_stage: STAGE_1B_GROUND_FUEL_RESUPPLY
stage_1b_moose_docs: REVIEWED
stage_1b_pinned_source: REVIEWED
stage_1b_official_demos: REVIEWED_NO_DEDICATED_FUELSUPPLY_DEMO_FOUND
stage_1b_v19_template_preflight: PASS_READ_ONLY
stage_1b_selected_template: TPL_BLUE_CONVOY_FUEL_LIGHT_06
stage_1b_expected_transfer_quantity: 18
stage_1b_accepted_speed_fixture_kt: 27
stage_1b_return_issue_delay_sec: 30
stage_1b_return_settlement_delay_sec: 12
stage_1b_builder_version: GROUND-FUEL-RESUPPLY-ACCEPTANCE-1-1
stage_1b_local_owner_build: PASS
stage_1b_build_git_head: 4f651829e975f42d4aba44a9bd0813969a2f2d8b
stage_1b_bundle_sha256: A2C71E86244A2E6869E8A0A3D7384D917875064B11102CDA410A7DBD9C1C6922
stage_1b_mission_editor_integration: NOT_STARTED
stage_1b_dcs_runtime: NOT_RUN
production_runtime_implementation: NOT_YET_CREATED
next_allowed_step: OWNER_MISSION_EDITOR_INTEGRATION_THEN_STATIC_PREFLIGHT
```

## 7. Nächster erlaubter Schritt

Der Owner integriert ausschließlich das gebaute Stage-1B-Acceptance-Bundle in eine neue Mission-Editor-Revision, speichert und schließt die Mission. Danach folgt ein statischer read-only MIZ-/Ressourcen-/Hash-Preflight. Kein DCS-Lauf vor diesem Preflight-PASS.
