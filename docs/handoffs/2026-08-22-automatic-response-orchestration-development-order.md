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
Status: COMPLETE FOR STAGE-1A SCOPE
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
Honaker AMMO 40
-> consumption 20
-> ResourceDemandPolicy REORDER
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

Finaler strategischer Zustand:

```text
JOYCE AMMO   44 -> 24
HONAKER AMMO 40 -> 20 -> 40
```

#### Stage-1A PASS-Provenienz

```text
Acceptance source/build commit: 2d72bcdfc113342a2180b6cd9c84486da790052c
BuilderVersion: GROUND-AMMO-RESUPPLY-ACCEPTANCE-1-5
Acceptance bundle SHA-256: 752B3E6F0B77D1B62C750421DDE36202C81B98632FEFBF6A273F913202DF8339
Ground production bundle SHA-256: E616D35F5EBDBDDD4275785091D47F57445348D1FF4BB4CFBE7DEE0F0B12D78E
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
DCS: 2.9.28.26385 MT
Executed mission: OMW_Template_v18.miz
MIZ SHA-256: 2FDF31A2E07409CF392D45BFF5FC69750958C670AE3E12FF28D0B4FD8AECC90D
internal mission SHA-256: 38B207278365CD977E74FF3C9000C6A7C5B13EEE3E5B1BB154F1775055D02AF6
dcs.log SHA-256: 0C0B5784A0AA1C67E0BE57CEEF90006FBEEE40805D7A589D8EF8DC6DC3BFDFDF
debrief.log SHA-256: C9EA7398241DEA3323B39FAD8F28D97D27B5A1CB1EE05A79433BA26896666DEB
Result: PASS
```

Result file:

```text
mission/tests/ground-resupply-execution/results/2026-08-22-ground-ammo-resupply-acceptance-1-pass-1.md
```

#### Stage-1A wichtige Erkenntnisse

```text
protected physical template: TPL_BLUE_CONVOY_LIGHT_06
speed in accepted run: 27 kt
package-per-truck capacity: NOT_DEFINED
automatic LIGHT_06/STANDARD_07 selection: NOT_DEFINED
```

Der 30-s-Delay nach `MissionDone` ist für diesen Pfad Teil der akzeptierten Lifecycle-Koordination. Ein 2-s-Delay reproduzierte zuvor eine Race-Condition: RTZ wurde angenommen, aber der Convoy blieb am Ziel und lief in RETURN_TIMEOUT.

### Stage 1B – Ground FUEL

```text
Status: PLANNED / NEXT NATURAL RESUPPLY SLICE
MOOSE candidate: AUFTRAG:NewFUELSUPPLY(Zone)
```

Vor Implementierung erneut gegen Dokumentation, gepinnte `Moose.lua` und offizielle Beispiele prüfen. Kein stillschweigendes Kopieren von AMMO-Semantik ohne Source-Abgleich.

### Stage 1C – Generic Ground SUPPLY

```text
Status: BLOCKED FOR SEPARATE MOOSE GAP REVIEW
```

Keine gleichwertige generische öffentliche `AUFTRAG:NewSUPPLY(...)`-API ist bestätigt. Kein Ersatzmissionstyp ohne dokumentierten MOOSE-Gap und Owner-Entscheidung.

### Stage 2 – FOB attack -> support demand

```text
Status: PLANNED
verified contact source
-> deduplicated TacticalSupportIncident
-> capability/range/readiness/resources/ROE
-> ARTY / QRF / CAS demand
```

### Stage 3 – Fire support -> local rearm -> RESUPPLY follow-up

```text
Status: PLANNED / FOUNDATIONS AVAILABLE
reuse PR #112 local rearm
-> CampaignState consumption
-> ResourceDemandPolicy reevaluation
-> exactly one RESUPPLY demand when threshold crossed
```

### Stage 4 – Convoy under attack -> support demand

```text
Status: PLANNED
physical convoy lifecycle as event source
-> deduplicated support incident
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
FOB attacked
-> support demand
-> artillery
-> local rearm
-> stock threshold
-> RESUPPLY demand
-> physical convoy
-> convoy attacked
-> support demand
-> response
-> settlement
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
current_stage: STAGE_1A_GROUND_AMMO_RESUPPLY
stage_1a_overall: ACCEPTED_TECHNICAL_BASELINE
run_1: FAIL_STALE_GROUND_THRESHOLDS
run_2: FAIL_GLOBAL_TIMEOUT_AFTER_DELIVERY
run_3: FAIL_2S_RETURN_RACE
run_4: PASS_FULL_ROUNDTRIP
run_4_delivery: PASS
run_4_return: PASS
run_4_returned: PASS
run_4_add_asset: PASS
run_4_cleanup: PASS
selected_physical_template: TPL_BLUE_CONVOY_LIGHT_06
accepted_speed_kt_for_stage_1a_fixture: 27
package_per_truck_capacity: NOT_DEFINED
automatic_convoy_class_selection: NOT_DEFINED
production_runtime_implementation: NOT_YET_CREATED
next_natural_stage: STAGE_1B_GROUND_FUEL
owner_decision_required_before_skipping_or_reordering_stages: true
```

## 7. Entscheidungsgrenze

Stage 1A ist technisch abgeschlossen. Der nächste natürliche Schritt der bestehenden Reihenfolge ist Stage 1B Ground FUEL. Eine andere Priorisierung bleibt Owner-Entscheidung.
