---
document_id: OMW-HANDOFF-AUTOMATIC-RESPONSE-ORCHESTRATION
status: PLANNED
document_class: DEVELOPMENT_ORDER_AND_HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local development order for automatic BLUE operational reactions
  - current implementation status and development-stage tracking
  - current branch-local TODO order
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
validated_in_dcs: partial
base_branch: main
base_commit: 998080da9a7a71dae7f713b9590dfeadb5ae93ba
---

# Entwicklungsauftrag – Automatic Response Orchestration

## 1. Zweck und Arbeitsgrenzen

Diese Datei ist die aktuelle branch-lokale TODO- und Entwicklungsreihenfolge für:

```text
agent/automatic-response-orchestration
```

Ziel ist eine geschlossene BLUE-Reaktionskette:

```text
Campaign event
-> MissionDemand / CSAR incident
-> MOOSE operational executor
-> physical mission
-> result
-> CampaignState settlement
```

Verbindliche Autoritätsgrenzen:

```text
CampaignState = alleinige strategische Zustands-/Ressourcenautorität
MissionDemand = Demand-/Assignment-Domäne
MOOSE = primärer operativer/physischer Runtime-Executor
DCS groups = temporäre physische Repräsentationen
```

ChatGPT mutiert keine `.miz`. Mission-Editor-Integration und Speichern erfolgen durch den Projektinhaber. Kein CODEX.

## 2. Governance- und Main-Referenz

Am 29.08.2026 geprüft und in den Branch integriert:

```text
main: 998080da9a7a71dae7f713b9590dfeadb5ae93ba
main-reconciliation merge commit: 5263fe7f2f7cb3bc358b39101200dfcc3ae513ea
internal reconciliation PR: #130
project phase: COMPLETE_FOUNDATION_BUILD_PHASE
```

Der Branch ist nach dieser Reconciliation nicht mehr hinter `main`:

```text
main -> agent/automatic-response-orchestration
status: ahead
behind_by: 0
```

Die Reconciliation wurde bewusst auf dem aktuellen `main`-Tree aufgebaut. Branch-spezifische Acceptance-/Source-Review-Dateien wurden ergänzt; ältere Branch-Versionen von gemeinsam weiterentwickelten `main`-Dateien wurden nicht zurückgespielt. Insbesondere blieben die aktuellen `main`-Fassungen von `docs/moose/PROJECT-CLASS-INDEX.md` und `docs/moose/VERIFIED-METHODS.md` erhalten.

Pflicht vor weiterer Runtime-Entwicklung:

```text
AGENTS.md
-> docs/00-project-governance.md
-> docs/26-moose-first-development-policy.md
-> aktuelle Fachbaseline auf main
-> MOOSE-Dokumentation
-> tatsächlich gepinnte Moose.lua
-> Signaturen / FSM / Events / Voraussetzungen
-> offizielle Beispiele, soweit relevant
-> kleinster MOOSE-native Pfad
-> reproduzierbare Verifikation
```

Wichtige inzwischen über `main` integrierte Grundlagen umfassen mindestens:

```text
MissionDemand Domain Foundation
Ground RESUPPLY threshold policy
Ground production foundation / six Ground nodes
Fixed Fire Support / local ammo rearm
Air Tasking reconciliation
CampaignState-MOOSE lifecycle/reconciliation governance
aktuelle AirOps-/AAR-/AWACS-/ISR-FAC-CAS-Baselines
```

## 3. Stage 1A – Ground AMMO RESUPPLY

Status:

```text
ACCEPTED_TECHNICAL_BASELINE
```

Belegter Pfad:

```text
Honaker AMMO shortage
-> MissionDemand RESUPPLY
-> CampaignState TRANSFER Joyce -> Honaker
-> TPL_BLUE_CONVOY_LIGHT_06
-> BRIGADE / PLATOON / ARMYGROUP
-> AUFTRAG:NewAMMOSUPPLY
-> destination proof
-> CampaignState DELIVERED
-> MissionDemand SUCCESS
-> MissionDone
-> return
-> Returned
-> Warehouse AddAsset
```

Maßgebliche Details und Provenienz:

```text
mission/tests/ground-resupply-execution/ACCEPTANCE-1.md
```

## 4. Stage 1B – historischer FUELSUPPLY-Versuch

Status:

```text
HISTORICAL_TEST_FIXTURE
HARNESS_TIMEOUT_CONTAMINATED
INCONCLUSIVE
```

Der alte Lauf darf nicht als Beleg gegen `FUELSUPPLY` verwendet werden. Der Harness brach nach einem harten Fahrzeit-Timeout ab.

## 5. Stage 1C – strategischer Meta-RESUPPLY via NOTHING

Status:

```text
ACCEPTED_TECHNICAL_BASELINE
```

Belegt ist für die exakt dokumentierte Provenienz:

```text
CampaignState shortage
-> MissionDemand RESUPPLY
-> one physical convoy
-> AUFTRAG:NewNOTHING
-> destination proof
-> exact-once CampaignState delivery
-> MissionDemand SUCCESS
-> same ARMYGROUP return
-> Returned
-> Warehouse AddAsset
```

Maßgebliche Details und Provenienz:

```text
mission/tests/ground-resupply-execution/ACCEPTANCE-3.md
mission/tests/ground-resupply-execution/results/2026-08-23-ground-meta-resupply-nothing-acceptance-1-pass-1.md
```

Stage 1C bleibt technische Evidenz. Für Fuel ist NOTHING nach dem spezialisierten FUELSUPPLY-Nachweis nicht mehr der bevorzugte Executor.

## 6. Stage 1B2 – One-Shot MOOSE FUELSUPPLY

### 6.1 Source-/Lifecycle-Ergebnis

`BRIGADE:AddRefuellingZone(...)` wurde source-seitig und in Build 2-2 als persistente Service-Registrierung erkannt. Für einen einzelnen CampaignState-Transfer ist daher der MOOSE-native One-Shot-Pfad maßgeblich:

```text
AUFTRAG:NewFUELSUPPLY(destinationZone)
-> BRIGADE:AddMission(mission)
```

Build 2-3:

```text
Build commit: 2bd930729ed12a073f5364dc139281b60151acf0
BuilderVersion: GROUND-FUEL-REFUELLING-ZONE-ACCEPTANCE-2-3
Bundle SHA-256: 8CBDFA12B1A052517D82CB20A460CA665415353FE38ED2F1C50928BE6C7966A0
Builder SHA-256: BD5C8657B759A8915F471AC54B56C375DCC7865B745EA208AC7B3DF822B6A023
Acceptance source SHA-256: 8FAD1F29E2054C5CE621549AA167BFF2A6DE45EE7C39EAEDF57AD3E234029287
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

### 6.2 Reale DCS-Beobachtung

Der Projektinhaber führte Build 2-3 in DCS aus. Beobachtet wurde der vollständige Lifecycle:

```text
MISSION_QUEUED
-> ROAD_ALIGNED_WAREHOUSE_SPAWN
-> GROUP_MATERIALIZED
-> ARMY_ON_MISSION FUELSUPPLY
-> DESTINATION_ZONE_ENTERED
-> MISSION_EXECUTE_OBSERVED
-> DELIVERY_CONFIRMED
-> MISSION_DONE
-> MOOSE ReturnToLegion
-> RETURNED_HANDOFF
-> RETURN_RTZ_ACTIVE
-> WAREHOUSE_ADD_ASSET
-> PASS
```

Terminaler Zustand:

```text
originFinal=22
destinationFinal=36
transferQuantity=18
physicalMission=ONESHOT_FUELSUPPLY
demandStatus=SUCCESS
spawnCount=1
missionExecuteCount=1
destinationObserved=true
missionDoneCount=1
returnedCount=1
warehouseAddAssetCount=1
```

Runtime-Umgebung:

```text
DCS: 2.9.28.26385 MT
Mission name: OMW_Template_v19.miz
Bundle SHA-256: 8CBDFA12B1A052517D82CB20A460CA665415353FE38ED2F1C50928BE6C7966A0
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

### 6.3 Formale Acceptance-Grenze

Der Runtime-PASS ist dokumentiert. Für `ACCEPTED_TECHNICAL_BASELINE` fehlt weiterhin genau ein Provenienzbaustein:

```text
SHA-256 der exakt im Build-2-3-Lauf ausgeführten und nach Einbindung gespeicherten OMW_Template_v19.miz
```

Daher aktuell:

```text
runtime_result: PASS
validated_in_dcs: true
formal_acceptance: BLOCKED_BY_MISSING_EXECUTED_MIZ_SHA256
```

Kein anderer MIZ-Hash darf dafür substituiert werden.

### 6.4 Fuel-Executor-Entscheidung

Die owner-approved Entscheidungsregel ist erfüllt:

```text
GROUND_FUEL_PACKAGE
-> CampaignState remains sole strategic authority
-> preferred physical executor = one-shot MOOSE FUELSUPPLY
-> AUFTRAG:NewFUELSUPPLY
-> BRIGADE:AddMission
-> no persistent BRIGADE:AddRefuellingZone for one-shot transfer
-> MOOSE ReturnToLegion
```

Maßgebliche Dokumente:

```text
mission/tests/ground-resupply-execution/ACCEPTANCE-4.md
docs/moose/GROUND-FUEL-REFUELLING-ZONE-SOURCE-REVIEW.md
```

## 7. Main-Reconciliation – abgeschlossen

Ausgangslage:

```text
old branch HEAD: 1fa6fe5b87bbed0794219daa460063ef2ebe6df2
main HEAD:       998080da9a7a71dae7f713b9590dfeadb5ae93ba
ahead: 109
behind: 195
status: diverged
```

Reconciliation:

```text
PR #130: main -> agent/automatic-response-orchestration
merge commit: 5263fe7f2f7cb3bc358b39101200dfcc3ae513ea
result: merged
```

Nach Reconciliation:

```text
behind_by: 0
main is an ancestor of the working branch
```

Konfliktregel war ausdrücklich:

```text
current main governance and current main BINDING baselines win
branch-only acceptance evidence is retained
shared files are not rolled back to stale branch revisions
```

## 8. TODO-Reaudit nach aktueller main-Integration

Die alte lineare Liste wurde gegen den integrierten Main-Stand neu bewertet.

```text
Stage 1D – generic meta-resource/SUPPLY executor
  STILL_REQUIRED
  Fuel is removed from the generic NOTHING target scope.
  Existing Stage-1C evidence does not itself create a production-generic executor.

Stage 2 – FOB attacked -> support demand
  STILL_REQUIRED
  Current binding architecture defines MissionDemand and FOB campaign objects,
  but no accepted automatic FOB-attack -> support-demand runtime path was found.

Stage 3 – fire support -> local rearm -> strategic resupply closure
  PARTIALLY_COVERED_ON_MAIN
  Fixed Fire Support and local ammo-rearm foundations are already merged and accepted.
  The automatic end-to-end closure from depletion/rearm demand into strategic
  MissionDemand RESUPPLY still requires explicit production reconciliation.

Stage 4 – convoy attacked -> support demand
  STILL_REQUIRED
  No accepted automatic convoy-under-attack -> support-demand runtime path was found.

Stage 5 – BLUE assignment / CAS reconciliation
  PARTIALLY_COVERED_ON_MAIN
  Newer Air Tasking and ISR/FAC/CAS foundations substantially cover the air-side
  assignment/CAS machinery. The missing scope is the automatic-response adapter
  from MissionDemand/event input into the current main air-tasking contract.

Stage 6 – aircraft loss -> CSAR incident / MOOSE CSAR-first execution
  STILL_REQUIRED
  The current BINDING CSAR index explicitly states that technical MOOSE CSAR/AICSAR
  acceptance, CSARIncident data model, dedicated-server/reconnect and restart tests
  are still required.

Stage 7 – end-to-end automatic response chain
  STILL_REQUIRED
  Depends on the remaining event-to-demand and executor bridges.

Stage 8 – restart / restore / idempotence reconciliation
  PARTIALLY_COVERED_ON_MAIN
  CampaignState/Ground lifecycle reconciliation infrastructure exists on main.
  Automatic-response-specific in-flight demands, executor state and exact-once
  recovery still require an end-to-end audit/test.

Stage 9 – multiplayer / performance / failure acceptance
  STILL_REQUIRED

Stage 10 – production reconciliation / PR / merge readiness
  BLOCKED
  Not entered until the genuinely remaining stages and provenance gates are closed.
```

## 9. Unmittelbare Arbeitsreihenfolge ab jetzt

```text
DONE  Bring branch documentation current.
DONE  Reconcile current main 998080da... into the branch without restoring stale baselines.
DONE  Record Stage 1B2 real runtime PASS and preferred Fuel executor.
DONE  Re-audit old Stages 1D–9 against reconciled main.

BLOCKED  Close Stage 1B2 formal acceptance.
         Need exact executed Build-2-3 MIZ SHA-256 from owner evidence.

NEXT  Reconcile Stage 1D production scope.
      Then implement only genuinely missing automatic-response bridges in the
      re-audited order above.

FINAL  Full diff, available tests/builders, documentation validator,
       MOOSE indexes, DOCUMENT-REGISTRY, SUBPROJECT-REGISTRY, handoff,
       PENDING_MERGE cleanup, feature PR, Ready for Review.
```

## 10. Aktueller Branchstatus

```text
current_branch: agent/automatic-response-orchestration
main_reference_commit: 998080da9a7a71dae7f713b9590dfeadb5ae93ba
main_reconciliation_commit: 5263fe7f2f7cb3bc358b39101200dfcc3ae513ea
main_reconciliation_pr: 130
main_behind_by: 0
stage_1a_ammo: ACCEPTED_TECHNICAL_BASELINE
stage_1b_historical_fuelsupply: HISTORICAL_TEST_FIXTURE_INCONCLUSIVE
stage_1c_meta_resupply_nothing: ACCEPTED_TECHNICAL_BASELINE
stage_1b2_one_shot_fuelsupply_runtime: PASS
stage_1b2_formal_acceptance: BLOCKED_BY_MISSING_EXECUTED_MIZ_SHA256
fuel_preferred_physical_executor: MOOSE_ONE_SHOT_FUELSUPPLY
stage_1d: STILL_REQUIRED
stage_2: STILL_REQUIRED
stage_3: PARTIALLY_COVERED_ON_MAIN
stage_4: STILL_REQUIRED
stage_5: PARTIALLY_COVERED_ON_MAIN
stage_6: STILL_REQUIRED
stage_7: STILL_REQUIRED
stage_8: PARTIALLY_COVERED_ON_MAIN
stage_9: STILL_REQUIRED
ready_for_review: false
merge_to_main: false
next_gate: STAGE_1B2_PROVENANCE_THEN_STAGE_1D
```
