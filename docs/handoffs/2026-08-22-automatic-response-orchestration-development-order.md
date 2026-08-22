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

## 1. Zweck und Arbeitsbranch

Dieser Branch entwickelt die geschlossene automatische BLUE-Reaktionskette aus dem aktuellen `main`-Stand. Bereits integrierte CampaignState-, MissionDemand-, Ground-, Fire-Support-, AirOps- und CSAR-Bausteine werden orchestriert; akzeptierte Funktionen werden nicht parallel neu implementiert.

```text
branch: agent/automatic-response-orchestration
base: main @ 28d0069d5d9ec66e62f1e81ad59fc3dd4e2e249c
```

Dieses Dokument ist Entwicklungsauftrag und laufendes Handoff. Nach jedem relevanten Schritt sind Ist-Stand, Dateien, Tests, Hashes, offene Grenzen und der nächste zulässige Gate zu aktualisieren.

## 2. Pflichtprüfung vor jeder Entwicklungsstufe

Vor jeder neuen Stufe und nach längerer Unterbrechung müssen die aktuellen Regeln auf `main` erneut gelesen werden. Branchkopien oder alte Handoffs ersetzen dies nicht.

Mindestens:

```text
AGENTS.md
docs/00-project-governance.md
docs/22-test-mission-build-transfer-and-validation-workflow.md
docs/26-moose-first-development-policy.md
docs/DOCUMENT-METADATA-POLICY.md
docs/SUBPROJECT-REGISTRY.md
mission/tests/GOVERNANCE.md
```

Je nach Stufe zusätzlich aktuelle Fach-, Acceptance- und `docs/moose/`-Dokumente.

MOOSE-First:

```text
MOOSE documentation
-> actual pinned Moose.lua
-> signatures / returns / FSM / events / prerequisites
-> official demos/tests where relevant
-> direct MOOSE / configuration / callbacks
-> smallest adapter only if still required
```

Keine MOOSE- oder DCS-Funktion wird geraten.

## 3. Aufgabentrennung / lokale Toolgrenze

ChatGPT:

```text
Repository/Governance prüfen
-> Entwicklung erstellen
-> Diff/Guards/Dokumentation/MOOSE-First prüfen
-> selbst committen und remote veröffentlichen
-> erst danach lokale Schritte übergeben
```

Projektinhaber:

```text
PowerShell-Schritte lokal ausführen
MIZ/Mission Editor gemäß main-Governance bearbeiten
DCS-Läufe ausführen
reale Konsole / Hashes / Logs / Debrief / Beobachtungen zurückgeben
```

Lokale Entwicklungsmaschine:

```text
Lua interpreter: NOT AVAILABLE
Python: NOT AVAILABLE
```

Daher:

```text
local builds/checks: PowerShell only
build instructions: always in code blocks
no lua/luac/python/python3 assumptions
no invented local builds or hashes
no CODEX
```

## 4. Aktuelle Source of Truth

Legacy:

```text
agent/mission-demand-resupply-cas-concept
= HISTORICAL REFERENCE ONLY
```

Aktuelle Autorität ist `main`.

PR #114 – MissionDemand Foundation:

```text
merge commit: 341a65105c24807de3ac289bb18d80339111cbd1
status: MERGED
```

Integriert:

```text
MissionDemand registry/state model
RESUPPLY
CAS_IMMEDIATE
AI/player assignment exclusivity
active dedupe
snapshot/restore
ResourceDemandPolicy
```

PR #115 – Ground RESUPPLY thresholds:

```text
merge commit: 34b1f46120f951ca2a6308cf1d9fbbb4b0a17863
status: MERGED
reorder  = 50% of target
critical = 25% of target
```

PR #112 – Fixed Fire Support / local ammo rearm:

```text
status: MERGED
physical MOOSE/DCS rearm: DCS PASS for documented provenance
same-session restore settlement: PASS
external process/server persistence: NOT TESTED / NOT CLAIMED
```

CampaignState bleibt einzige strategische Ressourcenautorität.

## 5. Endziele

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

Architekturgrenze:

```text
CampaignState = strategic truth/resource authority
MissionDemand = demand identity/assignment state
MOOSE = operational execution
DCS groups = temporary physical representation
```

## 6. Entwicklungsstufen

### Stage 0 – Governance / Ist-Stand / MOOSE Ground reconciliation

Status: `COMPLETE FOR STAGE-1A SCOPE`

Erledigt:

```text
current main rules reviewed
PR #114 / #115 / #112 reconciled
CampaignState TRANSFER lifecycle reviewed
Ground production separation reviewed
BRIGADE/PLATOON/ARMYGROUP/AUFTRAG lifecycle reviewed
Ground return lifecycle reviewed
OMW_GroundRoadSpawnAdapter confirmed as existing owner-approved exception
NewAMMOSUPPLY / NewFUELSUPPLY source-confirmed in pinned Moose.lua
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

Status: `BUILD_PASS / MIZ_SELECTION_NEXT`

Physical and strategic chain:

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

Staged files:

```text
docs/moose/GROUND-RESUPPLY-EXECUTION-SOURCE-REVIEW.md
mission/tests/ground-resupply-execution/README.md
mission/tests/ground-resupply-execution/ACCEPTANCE-1.md
mission/tests/ground-resupply-execution/src/01-ground-ammo-resupply-acceptance.lua
tools/build-ground-ammo-resupply-acceptance-1.ps1
```

Builder:

```text
GROUND-AMMO-RESUPPLY-ACCEPTANCE-1-3
```

Real local build evidence returned by project owner:

```text
GitCommit: 99ea86bf61036f2d04008b17bcb8c1d6e236b030
GeneratedUtc: 2026-08-22T16:57:51Z
Bundle SHA-256: D1E908D08DF3DA787D01E760F5B9C01771F5D17CBBD51C8545A4A00086E10676
Independent bundle SHA-256: D1E908D08DF3DA787D01E760F5B9C01771F5D17CBBD51C8545A4A00086E10676
Builder SHA-256: AEF56E16FE896854D32EAE409FC04A6C8C0BE20266EF591242DC5C866C5FB820
Acceptance source SHA-256: 38E099C801286768FD9D1D39014BB767BCF99055602D1E06EDACA48634856C83
MissionDemand source SHA-256: E348E75B87135B99D780E07CA6B6FB7C3C530E048E9C6DE790328D147DE32848
ResourceDemandPolicy source SHA-256: BDC20ACEDAB60F662093077B8320220EBB71C6C641CC604C4356231B8405913C
GroundRoadSpawnAdapter source SHA-256: 1A81FB2E5270C493373CF5BF6EC01F5AFED47004BF25C4225524121155D983E8
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Build result:

```text
BUILD PASS
bundle emitted: true
builder hash report matches independent bundle hash: true
DCS runtime: NOT RUN
```

Design boundary:

```text
CampaignState owns cargo quantity.
MOOSE AMMOSUPPLY owns physical movement only.
OPSTRANSPORT is not used in this first abstract-resource transfer slice.
```

Delivery gate:

```text
MissionDone alone != delivery
Delivery requires exact acceptance AMMOSUPPLY MissionExecute
AND ARMYGROUP:IsInZone(Honaker ACCESS) == true
```

Next gate:

```text
select concrete work MIZ
-> record MIZ SHA-256
-> internal mission SHA-256
-> confirm object contract
-> confirm startup resources/triggers
-> only then embed acceptance bundle
-> verify embedded bundle and Moose hashes
-> only then DCS run
```

Required MIZ objects:

```text
WH_BLUE_GND_JOYCE
ZON_BLUE_GND_JOYCE_ACCESS
ZON_BLUE_GND_HONAKER_ACCESS
TPL_BLUE_GND_SUP_M1083
```

Required startup chain:

```text
Moose.lua
OMW_AirOps_Warehouse_Base.lua
OMW_Ground_Base.lua
OMW_WAREHOUSE_READY == 1
OMW_GROUND_READY == 1
```

#### Stage 1B – Ground FUEL

Status: `PLANNED AFTER STAGE 1A`

```text
MOOSE candidate: AUFTRAG:NewFUELSUPPLY(Zone)
```

#### Stage 1C – Generic Ground SUPPLY

Status: `BLOCKED FOR SEPARATE MOOSE GAP REVIEW`

Keine gleichwertige generische `AUFTRAG:NewSUPPLY(...)`-API wurde für den gepinnten Scope bestätigt. Kein PATROL-/RELOCATE-Ersatz wird missbraucht. Falls MOOSE keinen geeigneten Pfad bietet, ist vor eigenem Fallback eine Owner-Entscheidung erforderlich.

### Stage 2 – FOB attack -> support demand

Status: `PLANNED`

```text
verified attack/contact event source
-> deduplicated TacticalSupportIncident
-> capability/range/readiness/resources/ROE evaluation
-> ARTY / QRF / CAS demand
```

### Stage 3 – Fire support -> local rearm -> RESUPPLY follow-up

Status: `PLANNED / FOUNDATIONS AVAILABLE`

```text
reuse PR #112 local rearm
-> authoritative CampaignState consumption
-> ResourceDemandPolicy re-evaluation
-> exactly one RESUPPLY demand when threshold crossed
```

### Stage 4 – Convoy under attack -> support demand

Status: `PLANNED`

```text
physical convoy lifecycle as event source
-> deduplicated support incident
-> transport demand and support demand remain separate identities
```

### Stage 5 – BLUE assignment / CAS execution

Status: `BLOCKED BY BLUE COMMANDER RECONCILIATION`

```text
current COMMANDER/AIRWING/SQUADRON/AUFTRAG source review
-> selective reconciliation of historical BLUE COMMANDER work
-> exclusive player/AI assignment
-> CAS_IMMEDIATE runtime
```

### Stage 6 – Aircraft loss -> CSARIncident -> Player/AICSAR

Status: `PLANNED`

```text
final CSARIncident model/FSM
-> verified loss/ejection/survival event source
-> exactly one incident
-> Player/AICSAR exclusivity
-> persistent Rescue/Capture/Death/Expired/Recovery settlement
```

### Stage 7 – End-to-End chain

Status: `PLANNED`

```text
FOB attacked
-> support demand
-> artillery
-> fire
-> local ammo rearm
-> stock threshold crossed
-> RESUPPLY demand
-> physical convoy
-> convoy attacked
-> support demand
-> response
-> delivery/loss settlement
```

plus:

```text
CAS helicopter lost
-> one CSARIncident
-> Player CSAR or AICSAR
-> final settlement
```

### Stage 8 – Restore / restart / idempotence

Status: `PLANNED`

No duplicate demands, reservations, debits, credits or unexplained losses. External process/server restart is claimed only after real test.

### Stage 9 – Multiplayer / performance / failures

Status: `PLANNED`

Parallel demands, assignment races, destroyed carriers/responders, routing failures, aborts, reconnect and scheduler load.

### Stage 10 – Production reconciliation / merge readiness

Status: `PLANNED`

Diff, tests, MOOSE documentation, acceptance provenance, registries, no stale `PENDING_MERGE` metadata on main, and no runtime claims beyond exact tested provenance.

## 7. Aktueller Gate-Stand

```text
branch: agent/automatic-response-orchestration
stage: STAGE_1A_GROUND_AMMO_RESUPPLY
source review: COMPLETE FOR TEST SCOPE
builder: PASS
bundle hash: D1E908D08DF3DA787D01E760F5B9C01771F5D17CBBD51C8545A4A00086E10676
MIZ selected: false
MIZ object-contract smoke: NOT RUN
MIZ embedding: NOT STARTED
DCS runtime: NOT RUN
production runtime implementation: NOT YET CREATED
```

## 8. Nächster zulässiger Schritt

Nur MIZ-Auswahl und read-only Preflight gemäß Dokument 22:

```text
identify concrete current OMW work MIZ
-> record filename and SHA-256
-> record internal mission SHA-256
-> confirm required Joyce/Honaker/M1083 objects
-> confirm Moose/Warehouse/Ground startup resources and trigger order
-> stop on any mismatch
```

Erst nach diesem statischen PASS darf das Acceptance-Bundle eingebettet werden.