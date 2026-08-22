---
document_id: OMW-TEST-GROUND-RESUPPLY-EXECUTION
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local test package for physical MissionDemand-driven Ground RESUPPLY execution
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# Ground RESUPPLY Execution

## Zweck

Dieses Testpaket prüft die MissionDemand-/CampaignState-gekoppelten physischen Ground-RESUPPLY-Pfade über MOOSE BRIGADE / PLATOON / ARMYGROUP / AUFTRAG.

## Stage 1A – AMMO

```text
GROUND_NODE_HONAKER
GROUND_AMMO_PACKAGE
40 -> 20 -> 40
CampaignState TRANSFER 20 from GROUND_NODE_JOYCE
TPL_BLUE_CONVOY_LIGHT_06
AUFTRAG AMMOSUPPLY
OnRoad 27 kt
30 s MissionDone -> RTZ settlement window
Returned -> Warehouse AddAsset -> physical cleanup
```

Status:

```text
ACCEPTED_TECHNICAL_BASELINE
```

Details:

```text
src/01-ground-ammo-resupply-acceptance.lua
ACCEPTANCE-1.md
results/2026-08-22-ground-ammo-resupply-acceptance-1-pass-1.md
tools/build-ground-ammo-resupply-acceptance-1.ps1
```

## Stage 1B – FUEL

```text
GROUND_NODE_HONAKER
GROUND_FUEL_PACKAGE
36 -> 18 -> 36
CampaignState TRANSFER 18 from GROUND_NODE_JOYCE
TPL_BLUE_CONVOY_FUEL_LIGHT_06
AUFTRAG FUELSUPPLY
OnRoad 27 kt
30 s MissionDone -> RTZ settlement window
Returned -> Warehouse AddAsset -> physical cleanup
```

Status:

```text
SOURCE_REVIEWED / STAGED / DCS_PENDING
```

Owner-created `OMW_Template_v19.miz` was inspected read-only. The selected Stage-1B fixture contains six vehicles:

```text
1 CHAP_MATV
2 M978 HEMTT Tanker
3 MaxxPro_MRAP
4 M978 HEMTT Tanker
5 MaxxPro_MRAP
6 CHAP_MATV
```

The physical convoy remains only a representation of the strategic CampaignState transfer. No `GROUND_FUEL_PACKAGE`-per-tanker capacity is defined by this test.

Files:

```text
src/02-ground-fuel-resupply-acceptance.lua
ACCEPTANCE-2.md
dist/OMW_Ground_Fuel_Resupply_Acceptance_1.lua   # generated locally
tools/build-ground-fuel-resupply-acceptance-1.ps1
```

## MOOSE-First

Technical review:

```text
docs/moose/GROUND-RESUPPLY-EXECUTION-SOURCE-REVIEW.md
```

Pinned MOOSE:

```text
MOOSE 2.9.18
commit 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256 E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

No custom convoy dispatcher, no MIST, no native-DCS event layer, no `OPSTRANSPORT`, no alternate strategic resource authority, and no `.miz` mutation by ChatGPT are introduced.

## Current status

```text
Stage 1A AMMO: ACCEPTED_TECHNICAL_BASELINE
Stage 1B FUEL source: STAGED ON BRANCH
Stage 1B builder: STAGED ON BRANCH
Stage 1B local owner build: NOT RUN
Stage 1B bundle SHA-256: UNKNOWN UNTIL OWNER BUILD
Stage 1B Mission Editor integration: NOT STARTED
Stage 1B DCS runtime: NOT RUN
```
