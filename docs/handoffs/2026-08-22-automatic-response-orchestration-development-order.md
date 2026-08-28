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

Am 29.08.2026 geprüft:

```text
main: 998080da9a7a71dae7f713b9590dfeadb5ae93ba
project phase: COMPLETE_FOUNDATION_BUILD_PHASE
```

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

Wichtige inzwischen auf `main` vorhandene Grundlagen umfassen mindestens:

```text
MissionDemand Domain Foundation
Ground RESUPPLY threshold policy
Ground production foundation / six Ground nodes
Fixed Fire Support / local ammo rearm
Air Tasking reconciliation
CampaignState-MOOSE lifecycle/reconciliation governance
aktuelle AirOps-/AAR-/AWACS-/ISR-FAC-CAS-Baselines
```

Die branch-lokale Architektur darf keine neuere `main`-Baseline zurücksetzen.

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

Maßgebliche Details und Provenienz stehen in:

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

Maßgebliche Details und Provenienz stehen in:

```text
mission/tests/ground-resupply-execution/ACCEPTANCE-3.md
mission/tests/ground-resupply-execution/results/2026-08-23-ground-meta-resupply-nothing-acceptance-1-pass-1.md
```

Stage 1C bleibt technische Evidenz. Für Fuel ist NOTHING nach erfolgreichem spezialisierten FUELSUPPLY-Nachweis nicht mehr der bevorzugte Executor.

## 6. Stage 1B2 – One-Shot MOOSE FUELSUPPLY

### 6.1 Build- und Source-Ergebnis

Die erste native Variante mit:

```text
BRIGADE:AddRefuellingZone(...)
```

war für den OMW-One-Shot-Transfer ungeeignet, weil die registrierte RefuellingZone eine persistente Service-Anforderung ist und nach Missionsende erneut FUELSUPPLY erzeugt.

Der kleinste MOOSE-first One-Shot-Pfad wurde deshalb auf:

```text
AUFTRAG:NewFUELSUPPLY(destinationZone)
-> BRIGADE:AddMission(mission)
```

korrigiert.

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

Der Projektinhaber hat Build 2-3 anschließend in DCS ausgeführt. Der beobachtete Runtime-Lifecycle erreichte vollständig:

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

Beobachteter Endzustand:

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

Der DCS-PASS ist real beobachtet, aber die vollständige Governance-Provenienz ist noch nicht geschlossen, weil der SHA-256 der **exakt ausgeführten und nach Einbindung von Build 2-3 gespeicherten MIZ** noch nicht dokumentiert ist.

Daher gilt bis zur realen Hash-Rückmeldung:

```text
runtime_result: PASS_OBSERVED
validated_in_dcs: true
formal_acceptance: PROVENANCE_INCOMPLETE
missing: executed MIZ SHA-256 for exact Build-2-3 run
```

Es ist ausdrücklich unzulässig, den Stage-1C-MIZ-Hash oder einen später veränderten MIZ-Stand hierfür zu übernehmen.

### 6.4 Fuel-Executor-Entscheidung

Die owner-approved Entscheidungsregel ist erfüllt:

```text
GROUND_FUEL_PACKAGE
-> CampaignState remains strategic authority
-> preferred physical executor = one-shot MOOSE FUELSUPPLY
-> AUFTRAG:NewFUELSUPPLY
-> BRIGADE:AddMission
-> no persistent BRIGADE:AddRefuellingZone for one-shot transfer
-> MOOSE ReturnToLegion
```

Stage 1C NOTHING bleibt als technische Fallback-/Meta-Resource-Evidenz erhalten, ist aber nicht mehr der bevorzugte Fuel-Executor.

Maßgebliches Acceptance-Dokument:

```text
mission/tests/ground-resupply-execution/ACCEPTANCE-4.md
```

## 7. Reconciliation-Gate gegen aktuellen main

Vor weiterer Stage-Entwicklung wird der Branch gegen den aktuellen `main` reconciliert.

Ausgangslage vor Reconciliation am 29.08.2026:

```text
branch HEAD: 1fa6fe5b87bbed0794219daa460063ef2ebe6df2
main HEAD:   998080da9a7a71dae7f713b9590dfeadb5ae93ba
branch ahead of main: 109 commits
branch behind main:    195 commits
status: diverged
```

Reconciliation-Regeln:

```text
- current main governance wins
- current main BINDING/BINDING_PROJECT_DECISION baselines win
- branch acceptance evidence is retained only for exact provenance
- do not restore superseded main code/docs
- MissionDemand/CampaignState/Ground/AirOps interfaces must be re-read after integration
- no old branch hash is reused for a new reconciled build
```

## 8. Neubewertung der alten Stages 1D–9

Die alte lineare TODO-Liste wird nicht unverändert fortgeschrieben. Erst nach Main-Reconciliation wird jeder Punkt gegen den tatsächlich auf `main` vorhandenen Stand klassifiziert.

Vorläufige Klassifikation:

```text
Stage 1D generic meta-resource/SUPPLY executor
  OPEN / REQUIRES RECONCILIATION
  Fuel is removed from generic NOTHING target scope.

Stage 2 FOB attacked -> support demand
  OPEN UNTIL MAIN AUDIT

Stage 3 fire support -> local rearm -> strategic resupply closure
  PARTIALLY COVERED ON MAIN
  Fixed Fire Support and local ammo-rearm foundation exist;
  automatic end-to-end closure still requires explicit audit.

Stage 4 convoy attacked -> support demand
  OPEN UNTIL MAIN AUDIT

Stage 5 BLUE assignment / CAS reconciliation
  PARTIALLY/SUBSTANTIALLY COVERED BY NEWER MAIN AIR TASKING / ISR-FAC-CAS WORK
  exact remaining automatic-response adapter scope must be determined after reconciliation.

Stage 6 aircraft loss -> CSAR
  OPEN UNTIL MAIN AUDIT
  do not assume current CSAR production integration without explicit evidence.

Stage 7 end-to-end automatic response chain
  OPEN

Stage 8 restart / restore / idempotence
  PARTIALLY COVERED BY CURRENT CAMPAIGNSTATE/GROUND RECONCILIATION WORK
  automatic-response-specific end-to-end behavior still requires audit.

Stage 9 multiplayer / performance / failure acceptance
  OPEN

Stage 10 production reconciliation / PR / merge readiness
  BLOCKED until the preceding reconciliation and evidence gates are closed.
```

## 9. Unmittelbare Arbeitsreihenfolge

```text
1. Reconcile branch with current main 998080da...
2. Re-read current main governance and affected interfaces.
3. Complete Stage 1B2 provenance with the exact executed-MIZ SHA-256.
4. Re-audit Stages 1D–9 against reconciled main.
5. Implement only genuinely missing production behavior.
6. Run available builders/tests and documentation validator.
7. Review full diff against current main.
8. Update DOCUMENT-REGISTRY / SUBPROJECT-REGISTRY / handoff as required.
9. Remove merge-blocking PENDING_MERGE metadata before main integration.
10. Create PR only when the branch is actually merge-ready.
```

## 10. Aktueller Branchstatus

```text
current_branch: agent/automatic-response-orchestration
branch_head_before_main_reconciliation: 1fa6fe5b87bbed0794219daa460063ef2ebe6df2
main_reference_commit: 998080da9a7a71dae7f713b9590dfeadb5ae93ba
stage_1a_ammo: ACCEPTED_TECHNICAL_BASELINE
stage_1b_historical_fuelsupply: HISTORICAL_TEST_FIXTURE_INCONCLUSIVE
stage_1c_meta_resupply_nothing: ACCEPTED_TECHNICAL_BASELINE
stage_1b2_one_shot_fuelsupply_runtime: PASS_OBSERVED
stage_1b2_formal_acceptance: PROVENANCE_INCOMPLETE_EXECUTED_MIZ_SHA256
fuel_preferred_physical_executor: MOOSE_ONE_SHOT_FUELSUPPLY
production_generic_executor: NOT_YET_RECONCILED
next_gate: MAIN_RECONCILIATION
ready_for_review: false
merge_to_main: false
```
