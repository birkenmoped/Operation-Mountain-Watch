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
base_commit: cace7e888e655cfce20c9338b9e327ff45cee726
---

# Entwicklungsauftrag – Automatic Response Orchestration

## 1. Zweck und verbindliche Arbeitsgrenzen

Diese Datei ist die **aktuelle branch-lokale TODO-/Entwicklungsreihenfolge** für `agent/automatic-response-orchestration`.

Ziel ist eine geschlossene BLUE-Reaktionskette aus `CampaignState`, `MissionDemand`, Ground, Fire Support, AirOps und CSAR.

Verbindlich:

```text
CampaignState = alleinige strategische Zustands-/Ressourcenautorität
MissionDemand = Demand-/Assignment-Domäne
MOOSE = primärer physischer Runtime-Executor
DCS groups = temporäre physische Repräsentationen
```

Pflichtreihenfolge vor neuer Runtime-Logik:

```text
AGENTS.md
-> docs/00-project-governance.md
-> docs/26-moose-first-development-policy.md
-> zuständige Fachbaseline
-> MOOSE-Dokumentation
-> tatsächlich gepinnte Moose.lua
-> Signaturen/FSM/Events/Voraussetzungen
-> offizielle Beispiele soweit relevant
-> kleinster MOOSE-native Pfad
-> reproduzierbarer DCS-Acceptance-Test
```

ChatGPT mutiert keine `.miz`. Mission-Editor-Integration und Speichern erfolgen durch den Projektinhaber. Kein CODEX.

## 2. Aktuelle main-Referenz

Am 23.08.2026 erneut geprüft:

```text
main: cace7e888e655cfce20c9338b9e327ff45cee726
project phase: COMPLETE_FOUNDATION_BUILD_PHASE
```

Bereits auf `main` integrierte Grundlagen:

```text
MissionDemand Domain Foundation: merged
Ground RESUPPLY threshold policy: merged
Fixed Fire Support / local ammo rearm: merged with documented DCS acceptance
Air Tasking selective main reconciliation: merged
```

## 3. Stage 1A – Ground AMMO RESUPPLY Joyce -> Honaker

Status: `ACCEPTED_TECHNICAL_BASELINE`.

DCS-bestätigter Vertrag:

```text
Honaker AMMO shortage / REORDER
-> MissionDemand RESUPPLY
-> CampaignState TRANSFER 20 Joyce -> Honaker
-> TPL_BLUE_CONVOY_LIGHT_06
-> BRIGADE / PLATOON / ARMYGROUP
-> AUFTRAG:NewAMMOSUPPLY(...)
-> OnRoad 27 kt
-> destination-zone proof
-> CampaignState DELIVERED
-> MissionDemand SUCCESS
-> MissionDone
-> delayed explicit RTZ
-> same ARMYGROUP Joyce
-> Returned
-> Warehouse AddAsset
-> physical cleanup
```

Kernprovenienz:

```text
Acceptance source/build commit: 2d72bcdfc113342a2180b6cd9c84486da790052c
BuilderVersion: GROUND-AMMO-RESUPPLY-ACCEPTANCE-1-5
Bundle SHA-256: 752B3E6F0B77D1B62C750421DDE36202C81B98632FEFBF6A273F913202DF8339
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
DCS: 2.9.28.26385 MT
Executed mission: OMW_Template_v18.miz
Result: PASS
```

## 4. Stage 1B – FUELSUPPLY Versuch und Stage 1B2-Neutest

### 4.1 Historischer Stage-1B-Lauf

Status: `HISTORICAL_TEST_FIXTURE / INCONCLUSIVE`.

Die frühere Aussage, `FUELSUPPLY` sei für OMW runtime-seitig gescheitert, ist zurückgenommen. Der damalige Lauf wurde durch `OUTBOUND_TIMEOUT seconds=1800` beendet, bevor der reale Joyce->Honaker-Fahrweg abgeschlossen war.

Daher gilt:

```text
FUELSUPPLY strategic meta-resupply suitability: NOT PROVEN / NOT DISPROVEN
FailureClass: HARNESS_TIMEOUT_CONTAMINATED
```

Architekturgrenze bleibt:

```text
GROUND_FUEL_PACKAGE = CampaignState meta resource
M978 = physical representation only
1 M978 != defined number of packages
```

### 4.2 Stage 1B2 – MOOSE-native RefuellingZone/FUELSUPPLY Acceptance

Projektinhaberentscheidung 23.08.2026:

```text
Before Stage 1D, test the normal MOOSE fuel path again.
If it works, prefer MOOSE FUELSUPPLY for Fuel and stop using NOTHING as the Fuel executor.
```

Der Source-Review bestätigt für den gepinnten Stand:

```text
BRIGADE:AddRefuellingZone(zone)
-> BRIGADE creates AUFTRAG:NewFUELSUPPLY(zone)
-> compatible FUELSUPPLY PLATOON / ARMYGROUP
-> FUELSUPPLY mission lifecycle
```

Stage 1B2 testet deshalb bewusst **nicht** erneut den OMW-direkten Konstruktorpfad aus Stage 1B, sondern den nativen BRIGADE-RefuellingZone-Pfad.

Zusätzlich wird kein expliziter OMW-RTZ-Override verwendet. Nach exact-once Delivery wird die offene FUELSUPPLY-Mission beendet und der normale MOOSE-`ReturnToLegion`-Lifecycle beobachtet.

Verbindliche Harness-Grenze:

```text
Hard outbound travel timeout: NONE
Hard return travel timeout: NONE
Acceptance completion: event-driven
```

Acceptance:

```text
mission/tests/ground-resupply-execution/ACCEPTANCE-4.md
```

Builder:

```text
tools/build-ground-fuel-refuelling-zone-acceptance-2.ps1
BuilderVersion: GROUND-FUEL-REFUELLING-ZONE-ACCEPTANCE-2-1
```

Entscheidungsregel:

```text
PASS
-> reconcile GROUND_FUEL_PACKAGE physical execution toward MOOSE RefuellingZone/FUELSUPPLY
-> Stage 1C NOTHING remains accepted evidence but ceases to be the preferred Fuel executor

FAIL with clean non-timeout evidence
-> analyze actual MOOSE/DCS failure before any fallback decision

INCONCLUSIVE
-> no architecture change
```

## 5. Stage 1C – Generic Ground Meta RESUPPLY via AUFTRAG NOTHING

Status: `ACCEPTED_TECHNICAL_BASELINE` für die exakt dokumentierte Provenienz.

### 5.1 Finaler Testvertrag

```text
HONAKER GROUND_FUEL_PACKAGE 36
-> test-only consume 18
-> HONAKER 18 / REORDER
-> MissionDemand RESUPPLY
-> CampaignState TRANSFER 18 Joyce -> Honaker
-> TPL_BLUE_CONVOY_FUEL_LIGHT_06
-> BRIGADE / PLATOON / ARMYGROUP
-> AUFTRAG:NewNOTHING(Honaker ACCESS)
-> OnRoad 27 kt
-> destination-zone proof
-> CampaignState DELIVERED
-> MissionDemand SUCCESS
-> mission cancel / MissionDone
-> 30 s delayed RTZ issue
-> same ARMYGROUP Joyce ACCESS / OnRoad
-> Returned
-> Warehouse AddAsset
-> physical cleanup
```

Finale strategische Werte:

```text
JOYCE FUEL   40 -> 22
HONAKER FUEL 36 -> 18 -> 36
```

### 5.2 Harness-Korrektur

Die früher eingebauten harten Fahrzeit-Gates waren eine zusätzliche Fehlerquelle und sind ab Build 1-4 entfernt.

```text
OutboundTravelTimeoutSec: none
ReturnTravelTimeoutSec: none
AcceptanceCompletion: event-driven
DestinationCheckIntervalSec: 15
DestinationExecutionGraceSec: 90
ReturnIssueDelaySec: 30
ReturnSettlementDelaySec: 12
```

`DestinationExecutionGraceSec=90` beginnt erst nach bestätigtem Eintritt in die Zielzone und ist kein Travel-Timeout.

### 5.3 Build-/DCS-Provenienz

```text
Acceptance branch: agent/automatic-response-orchestration
Acceptance commit: 8803505edf07120bc6d1673b41f69067e8db0211
BuilderVersion: GROUND-META-RESUPPLY-NOTHING-ACCEPTANCE-1-4
Bundle SHA-256: C881C82C3F699914E18FFE64DE73E650E20AF82B55B3F486154C40059F44CB65
Builder SHA-256: 9F7E3DFAE967BA39C373190A11495EC5AFD39357B0C1001A12F952606816B636
Acceptance source SHA-256: 21A54365C6138425CF5CDF4965F9E6F3396889477708B37A23BCBCFD77897C0C
GroundRoadSpawnAdapter SHA-256: 1A81FB2E5270C493373CF5BF6EC01F5AFED47004BF25C4225524121155D983E8
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
DCS: 2.9.28.26385 MT
Executed mission: OMW_Template_v19.miz
Executed MIZ SHA-256: D788AF36535D3ACD1866D15FFB5D354B2C44B5F8EE40D4BAF6FD1D97B7C0F8A5
dcs.log SHA-256: 7F89D79C10C8C61BB7994CE762C2554124212501FC019E83F5A34C87C54A67DD
debrief.log SHA-256: 21D917BC43A00F429A22B1EE697E64A62EC9B487254D330F5A7B1F574A253FA2
Result: PASS
```

Runtime-Endmarker:

```text
PASS originFinal=22 destinationFinal=36 transferQuantity=18 template=TPL_BLUE_CONVOY_FUEL_LIGHT_06 physicalMission=NOTHING demandStatus=SUCCESS spawnCount=1 returnedCount=1 warehouseAddAssetCount=1
```

Damit ist für diesen exakten Scope bestätigt:

```text
CampaignState shortage
-> MissionDemand RESUPPLY
-> one physical convoy
-> AUFTRAG NOTHING Joyce -> Honaker
-> delivery exact-once
-> MissionDemand SUCCESS
-> same ARMYGROUP RTZ Joyce
-> Returned
-> Warehouse AddAsset
-> physical cleanup
```

Nicht daraus abzuleiten:

```text
production generic RESUPPLY executor already exists
convoy combat/loss handling
restart/replay behavior
M978 package capacity
real DCS fuel quantity authority
operational FUELSUPPLY behavior
```

Stage 1C bleibt auch während Stage 1B2 eine akzeptierte technische Baseline. Ein erfolgreicher Stage-1B2-Lauf würde nur die **bevorzugte Fuel-Ausführung** ändern; er löscht die Stage-1C-Provenienz nicht.

## 6. Aktuelle TODO-Reihenfolge

Diese Liste ist die maßgebliche branch-lokale TODO-Liste.

```text
DONE  Stage 1A: AMMO RESUPPLY technical baseline
DONE  Stage 1B: FUELSUPPLY experiment reclassified as timeout-contaminated/inconclusive
DONE  Stage 1C: strategic meta-resource RESUPPLY via AUFTRAG NOTHING accepted

NEXT  Stage 1B2: MOOSE-native RefuellingZone/FUELSUPPLY acceptance
      - BRIGADE:AddRefuellingZone(...) is the mission source
      - BRIGADE/MOOSE creates AUFTRAG FUELSUPPLY itself
      - no hard outbound/return travel-time failure gate
      - CampaignState remains sole strategic fuel authority
      - no M978/package-capacity authority
      - after exact-once delivery, observe normal MOOSE ReturnToLegion
      - DCS result determines whether Fuel keeps NOTHING or moves to FUELSUPPLY

DEFERRED UNTIL 1B2 RESULT  Stage 1D: reconcile generic meta-resource/SUPPLY execution scope
      - determine which non-Fuel meta resources can use a generic NOTHING executor
      - if Stage 1B2 PASS, remove Fuel from the intended generic NOTHING scope
      - no physical cargo-capacity authority
      - no new parallel resource ownership
      - MOOSE-first source review before production code

PLANNED Stage 2: FOB attacked -> support demand
PLANNED Stage 3: fire support -> local rearm -> strategic resupply closure
PLANNED Stage 4: convoy attacked -> support demand
PLANNED Stage 5: BLUE assignment / CAS reconciliation against current main Air Tasking/COMMANDER baseline
PLANNED Stage 6: aircraft loss -> CSAR incident / MOOSE CSAR-first execution
PLANNED Stage 7: end-to-end automatic response chain
PLANNED Stage 8: restart / restore / idempotence reconciliation
PLANNED Stage 9: multiplayer / performance / failure acceptance
PLANNED Stage 10: production reconciliation, PR, merge readiness
```

No stage may silently introduce a non-MOOSE/native-DCS replacement or duplicate CampaignState authority.

## 7. Branch-relevante Dokumente

Pflicht-/Governance:

```text
AGENTS.md
docs/00-project-governance.md
docs/26-moose-first-development-policy.md
docs/DOCUMENT-METADATA-POLICY.md
docs/22-test-mission-build-transfer-and-validation-workflow.md
```

Branch-/Architektur-/MOOSE-Dokumente:

```text
docs/handoffs/2026-08-22-automatic-response-orchestration-development-order.md
docs/moose/MISSION-DEMAND-RESUPPLY-CAS-SOURCE-REVIEW.md
docs/moose/GROUND-RESUPPLY-EXECUTION-SOURCE-REVIEW.md
docs/moose/PROJECT-CLASS-INDEX.md
docs/moose/VERIFIED-METHODS.md
```

Ground RESUPPLY Acceptance:

```text
mission/tests/ground-resupply-execution/ACCEPTANCE-1.md
mission/tests/ground-resupply-execution/ACCEPTANCE-2.md
mission/tests/ground-resupply-execution/ACCEPTANCE-3.md
mission/tests/ground-resupply-execution/ACCEPTANCE-4.md
mission/tests/ground-resupply-execution/results/2026-08-23-ground-meta-resupply-nothing-acceptance-1-pass-1.md
```

Aktueller Chat-Handoff:

```text
docs/handoffs/2026-08-23-automatic-response-orchestration-current-state-and-next-chat-handoff.md
```

## 8. Aktueller Branchstatus

```text
current_branch: agent/automatic-response-orchestration
main_reference_commit: cace7e888e655cfce20c9338b9e327ff45cee726
stage_1a: ACCEPTED_TECHNICAL_BASELINE
stage_1b_fuelsupply: HISTORICAL_TEST_FIXTURE_INCONCLUSIVE
stage_1b2_refuelling_zone_fuelsupply: STAGED_NOT_RUN
stage_1c_newnothing: ACCEPTED_TECHNICAL_BASELINE
stage_1c_acceptance_commit: 8803505edf07120bc6d1673b41f69067e8db0211
stage_1c_miz_sha256: D788AF36535D3ACD1866D15FFB5D354B2C44B5F8EE40D4BAF6FD1D97B7C0F8A5
fuel_meta_resource_model: RETAIN_CAMPAIGNSTATE_AUTHORITY
fuel_convoy_templates: RETAIN_PHYSICAL_REPRESENTATION
fuel_preferred_physical_executor: PENDING_STAGE_1B2
production_generic_executor: NOT_YET_CREATED
next_development_gate: STAGE_1B2_DCS_ACCEPTANCE
```
