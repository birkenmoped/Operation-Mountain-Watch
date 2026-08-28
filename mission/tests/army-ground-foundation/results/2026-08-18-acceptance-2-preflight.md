---
document_id: OMW-TEST-ARMY-GROUND-ACCEPTANCE-2-PREFLIGHT
status: HISTORICAL_TEST_FIXTURE
document_class: TEST_EVIDENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - local build provenance for ARMY Ground Acceptance 2 before DCS execution
not_authoritative_for:
  - DCS runtime acceptance
  - visual formation acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/army-ground-foundation-reconciliation
source_commit: 26a3b961e6ed73a97ce2cb6fef3f464432b5fc8c
validated_in_dcs: false
supersedes:
superseded_by:
---

# ARMY Ground Acceptance 2 – Local Build Preflight

## Real owner-provided console evidence

```text
Source commit:
26a3b961e6ed73a97ce2cb6fef3f464432b5fc8c

BuilderVersion:
ARMY-GROUND-ACCEPTANCE-2-1

TestId:
ARMY-GROUND-ACCEPTANCE-2-1

GeneratedUtc:
2026-08-18T19:42:08Z

GroundNode:
GROUND_NODE_JOYCE

Warehouse:
WH_BLUE_GND_JOYCE

Brigade:
BDE_BLUE_GND_JOYCE

Platoon:
PLT_BLUE_GND_JOYCE_PATROL

Template:
TPL_BLUE_GND_PATROL_MATV_4

AccessZone:
ZON_BLUE_GND_JOYCE_ACCESS

ObservationZone:
ZON_BLUE_GND_JOYCE_PATROL_TEST_01

Mission1:
ARMOREDGUARD / On Road / 10 kt

Mission2:
ARMOREDGUARD / Vee / 8 kt

ApproachStandoffM:
1500

MinimumTacticalLegM:
1050

HoldStabilitySec:
20

ReturnToLegion:
false

CampaignStateAuthority:
PRESERVED_TEST_BOOKKEEPING_ONLY

VisualAcceptanceRequired:
true

MizMutation:
false

MOOSE commit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

Moose.lua SHA-256:
e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915

Bundle SHA-256:
71156d5c368d29797450cf00ee7d59540343c16865fa9f84850e135074963300
```

The owner also independently confirmed the same bundle hash with `Get-FileHash`.

## Gate

The build provenance is accepted for the exact source commit and generated bundle above.

This record does **not** claim DCS runtime acceptance. The next required step is owner-side Mission Editor embedding and a real DCS run with visual confirmation of:

```text
On Road movement
-> no duplicate materialization
-> tactical transition
-> Vee deployment
-> stable armored guard halt
-> no visible teleport/despawn
```
