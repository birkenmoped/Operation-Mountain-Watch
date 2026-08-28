---
document_id: OMW-TEST-ARMY-GROUND-ACCEPTANCE-9
status: ACCEPTED_TECHNICAL_BASELINE
document_class: ACCEPTANCE_TEST
owning_policy: OMW-GOV-001
authoritative_for:
  - six-node Ground initial-stock composition on the documented acceptance branch and commit
  - Fortress and Honaker CampaignState initial-stock values on the documented acceptance branch and commit
  - existing exactly-once Ground settlement adapter behavior on Fortress and Honaker in the documented test
not_authoritative_for:
  - repository-wide authority before merge to main
  - new MOOSE Ground lifecycle behavior beyond Acceptance 7
  - Ground order generation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - failed ARMY-GROUND-ACCEPTANCE-9-1 runtime attempt as the current Acceptance 9 result
superseded_by:
source_branch: agent/army-ground-foundation-reconciliation
source_commit: 998080da9a7a71dae7f713b9590dfeadb5ae93ba
acceptance_branch: agent/army-ground-foundation-reconciliation
acceptance_commit: 45d916217c0085728082c3ef2efcd582d736caae
acceptance_mission: OMW_Template_v14_ground_test.miz
acceptance_mission_sha256: 29587060d630d53303d4e858c1fd5a898ea3e09d51dec36ff130d3d0ac6e3ef3
acceptance_bundle: mission/tests/army-ground-foundation/dist/OMW_Army_Ground_Acceptance_9.lua
acceptance_bundle_sha256: 35cc922581da980f558733433e487b025e083859b943641276672b6c168b4d6a
dcs_version: 2.9.28.26385 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
validated_in_dcs: true
---

# ARMY Ground Acceptance 9 – Fortress / Honaker Production Stock

## 1. Purpose

Acceptance 9 validates the six-node Ground initial-stock composition after the 2011 Fortress/Honaker resource decision.

It introduces no new MOOSE class, event, FSM, scheduler, native-DCS lifecycle logic or private MOOSE override. Physical Ground behavior remains covered by Acceptance 7. Acceptance 9 is a CampaignState production-stock gate only.

## 2. Source decision

```text
docs/ground/ARMY-GROUND-FORTRESS-HONAKER-2011-RESOURCE-DECISION.md
```

Required initial values:

```text
GROUND_NODE_FORTRESS
  PERSONNEL 160
  VEHICLE    18
  SUPPLY     44
  AMMO       48
  FUEL       40
  supplyParent = GROUND_NODE_JALALABAD

GROUND_NODE_HONAKER
  PERSONNEL 120
  VEHICLE    18
  SUPPLY     40
  AMMO       40
  FUEL       36
  supplyParent = GROUND_NODE_JOYCE
```

Existing nodes remain unchanged:

```text
GROUND_NODE_JALALABAD 480 / 48 / 120 / 100 / 120
GROUND_NODE_JOYCE     180 / 20 / 48  / 44  / 40
GROUND_NODE_WRIGHT    120 / 22 / 36  / 30  / 36
GROUND_NODE_BOSTICK   220 / 26 / 56  / 52  / 48
```

Order is `PERSONNEL / VEHICLE / SUPPLY / AMMO / FUEL`.

## 3. Test source and builder

```text
mission/tests/army-ground-foundation/src/09-army-ground-fortress-honaker-production-stock.lua
tools/build-army-ground-acceptance-9.ps1
```

Generated bundle:

```text
mission/tests/army-ground-foundation/dist/OMW_Army_Ground_Acceptance_9.lua
```

Accepted BuilderVersion / Test-ID:

```text
ARMY-GROUND-ACCEPTANCE-9-2
```

`ARMY-GROUND-ACCEPTANCE-9-1` is retained only as failed runtime evidence and must not be reused.

## 4. Static/build gates

The accepted builder confirmed:

```text
single existing AirOpsCampaignStateInitializer path
AirOpsCampaignStateInitializer node registry contains all six Ground nodes
GroundInitialStock contains all six nodes
Ground resource rows = 42
Fortress and Honaker resource IDs exist
existing GroundCampaignStateAdapter reused
existing GroundRuntimeIntegration reused
no MIST
no MissionScripting.lua mutation
no filesystem/process execution from mission code
no teleport/spawn override
no M777A2/L118 fixed-artillery assumption in the production stock/test path
```

Real local build evidence before the DCS run:

```text
Git commit: 45d916217c0085728082c3ef2efcd582d736caae
BuilderVersion: ARMY-GROUND-ACCEPTANCE-9-2
Bundle SHA-256: 35cc922581da980f558733433e487b025e083859b943641276672b6c168b4d6a
InitializerNodeRegistryGate: true
```

## 5. Runtime result – PASS

The real DCS log contains all required markers:

```text
OMW_GND_A9 START testId=ARMY-GROUND-ACCEPTANCE-9-2
OMW_GND_A9 SIX_NODE_STOCK_OK fortressVehicle=18 fortressPersonnel=160 honakerVehicle=18 honakerPersonnel=120
OMW_GND_A9 FORTRESS_SETTLEMENT_OK returnedVehicle=4 returnedPersonnel=12 exactlyOnce=true
OMW_GND_A9 HONAKER_SETTLEMENT_OK returnedVehicle=3 returnedPersonnel=9 lostVehicle=1 lostPersonnel=3 exactlyOnce=true
OMW_GND_A9 RUNTIME_PASS testId=ARMY-GROUND-ACCEPTANCE-9-2 sixGroundNodes=true productionBaselineMutation=false mizMutation=false
```

No `OMW_GND_A9 FAIL` occurs in the accepted run.

### Fortress settlement

```text
4 VEHICLE + 12 PERSONNEL materialized/reserved
4 VEHICLE + 12 PERSONNEL returned
second return attempt idempotent
final Fortress stock = 18 VEHICLE / 160 PERSONNEL
```

### Honaker settlement

```text
4 VEHICLE + 12 PERSONNEL materialized/reserved
1 VEHICLE + 3 PERSONNEL confirmed permanent loss
3 VEHICLE + 9 PERSONNEL returned
second return attempt idempotent
final Honaker stock = 17 VEHICLE / 117 PERSONNEL
loss audit = 1 VEHICLE / 3 PERSONNEL
```

## 6. Runtime provenance

```text
Acceptance branch:
agent/army-ground-foundation-reconciliation

Acceptance commit:
45d916217c0085728082c3ef2efcd582d736caae

Tested mission:
OMW_Template_v14_ground_test.miz

Mission SHA-256:
29587060d630d53303d4e858c1fd5a898ea3e09d51dec36ff130d3d0ac6e3ef3

Acceptance bundle SHA-256:
35cc922581da980f558733433e487b025e083859b943641276672b6c168b4d6a

DCS:
2.9.28.26385 MT

MOOSE commit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

Moose.lua SHA-256:
e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

The DCS log itself reports the same MOOSE commit and SHA-256 through the existing OMW runtime provenance logging.

## 7. Historical correction gate

Acceptance 9 does not create or require a fixed Honaker artillery asset.

The superseded assumption

```text
2 x M777A2 at Honaker on 30.07.2011
```

is not used by the production stock or Acceptance 9 bundle.

Current evidence contract:

```text
2011 Honaker local mortar capability = confirmed
Jan-2010 possible two-gun position = observed but type/continuity unresolved
2012 M777 evidence = outside OMW scenario period
```

## 8. Failed Acceptance-9-1 evidence

The first real DCS run on 2026-08-20 failed immediately after the A9 start marker because the CampaignState initializer registry did not yet contain the new Fortress node:

```text
OMW_GND_A9 START testId=ARMY-GROUND-ACCEPTANCE-9-1
[OMW][Logistics.AirOpsCampaignStateInitializer] unknown CampaignState nodeId=GROUND_NODE_FORTRESS
```

Evidence:

```text
mission/tests/army-ground-foundation/results/2026-08-20-acceptance-9-failed-node-registry.md
```

The correction registered both `GROUND_NODE_FORTRESS` and `GROUND_NODE_HONAKER` and added a static six-node initializer-registry gate to the builder. The accepted `ARMY-GROUND-ACCEPTANCE-9-2` run proves the corrected path.

## 9. Acceptance boundary

Acceptance 9 proves the six-node Ground CampaignState stock composition and existing Ground settlement adapter behavior for the exact provenance above.

It does not create a new physical Ground lifecycle. Acceptance 7 remains the accepted physical MOOSE Ground lifecycle evidence. Ground-order generation, detailed final ORBAT allocation and cross-domain persistence remain separate later scopes.
