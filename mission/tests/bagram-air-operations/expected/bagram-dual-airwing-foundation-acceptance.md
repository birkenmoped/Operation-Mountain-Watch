---
document_id: OMW-TEST-BAGRAM-DUAL-AIRWING-FOUNDATION-ACCEPTANCE
status: PLANNED
document_class: DCS_ACCEPTANCE_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - Bagram dual-AIRWING foundation DCS acceptance criteria
not_authoritative_for:
  - tactical tasking
  - parking assignment compliance
  - recovery or persistence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - single-AIRWING Bagram foundation acceptance criteria
superseded_by: []
source_branch: agent/bagram-dual-airwing-foundation-rebuild
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Bagram Dual-AIRWING Foundation Acceptance

## Gate

The run passes only if the exact tested mission loads the pinned MOOSE artifact and the generated Bagram foundation bundle without Bagram foundation errors.

Required runtime structure:

```text
AW_US_BGRM_455_AEW
├── SQ_US_BGRM_F15E_335_EFS
├── SQ_US_BGRM_F16C_121_EFS
├── SQ_US_BGRM_C130_774_EAS
└── SQ_US_BGRM_HH60G_83_ERQS

AW_US_BGRM_TF_FALCON_10_CAB
├── SQ_US_BGRM_UH60_A_1_169
└── SQ_US_BGRM_CH47_B_7_158
```

## Required accounting

```text
airwings=2
squadrons=6
registeredGroups=61
representedAirframes=73
logicalAirframes=75
logicalReserve=2
rolePayloads=7
```

Inventory detail:

```text
F-15E  13 logical / 12 represented / 1 reserve
F-16C  13 logical / 12 represented / 1 reserve
C-130  20 logical / 20 represented
HH-60G  6 logical /  6 represented
UH-60   10 logical / 10 represented
CH-47   13 logical / 13 represented
```

## Required Mission Editor seeds

The helicopter foundation uses one physical seed per identical aircraft configuration:

```text
TPL_AIR_US_BGRM_HH60G_CSAR_1SHIP
TPL_AIR_US_BGRM_UH60_UTILITY_1SHIP
```

Separate `CSAR_LEAD`, `CSAR_COVER`, or `UH60_TRANSPORT` template duplicates are not required while the underlying Mission Editor aircraft configuration is identical. Role differentiation remains a MOOSE mission-capability/tasking concern and is outside this foundation-only acceptance gate.

## Required AIRWING state

Both AIRWINGs must reach `Running`:

```text
usafRunning=true
armyRunning=true
```

The two WAREHOUSE instances must resolve from distinct Mission Editor anchors:

```text
WH_AIR_US_BAGRAM
WH_AIR_US_BAGRAM_ARMY
```

Both AIRWINGs are bound to the Bagram DCS airbase.

## Foundation-only safety gate

The accepted run must show:

```text
missionsCreated=0
transportsCreated=0
commanderCreated=false
f10Controls=false
```

The source and generated bundle must not contain:

- `COMMANDER:New(...)`;
- any concrete `AUFTRAG:New...(...)`;
- `OPSTRANSPORT:New(...)`;
- `AddMission(...)`;
- test or F10 dispatch controls;
- Bagram→Jalalabad movement logic;
- project-specific parking override.

## Required provenance to record after the run

A PASS result must record the real values for:

```text
OMW source branch
OMW source commit
builder version
generated bundle SHA-256
MIZ filename
MIZ SHA-256
embedded mission SHA-256 if extracted
embedded Bagram bundle SHA-256
DCS version
MOOSE commit
embedded Moose.lua SHA-256
DCS log SHA-256
final RESULT marker
```

`VALIDATED` or `ACCEPTED_TECHNICAL_BASELINE` is forbidden until that exact DCS evidence exists.

## Out of scope

This gate does not validate:

- tactical CAS/STRIKE execution;
- C-130 transport execution;
- CSAR execution;
- helicopter cargo/troop transport execution;
- parking placement or client-space compliance;
- recovery/RTB;
- post-landing despawn/return;
- loss accounting;
- CampaignState persistence;
- multiplayer endurance.
