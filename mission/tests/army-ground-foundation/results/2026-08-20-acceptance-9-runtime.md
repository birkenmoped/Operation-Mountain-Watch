---
document_id: OMW-RESULT-ARMY-GROUND-ACCEPTANCE-9-RUNTIME-2026-08-20
status: ACCEPTED_TECHNICAL_BASELINE
document_class: TEST_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - runtime result of ARMY-GROUND-ACCEPTANCE-9-2 for the exact documented provenance
not_authoritative_for:
  - repository-wide authority before merge to main
  - physical Ground lifecycle beyond Acceptance 7
  - Ground-order generation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_MERGE
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

# ARMY Ground Acceptance 9 – Runtime Result 2026-08-20

## Result

```text
PASS
Test-ID: ARMY-GROUND-ACCEPTANCE-9-2
```

Acceptance 9-2 successfully validates the six-node Ground CampaignState stock composition and the existing exactly-once Ground settlement adapter on the new Fortress and Honaker nodes.

## Provenance

```text
Branch:
agent/army-ground-foundation-reconciliation

Commit:
45d916217c0085728082c3ef2efcd582d736caae

Mission:
OMW_Template_v14_ground_test.miz

Mission SHA-256:
29587060d630d53303d4e858c1fd5a898ea3e09d51dec36ff130d3d0ac6e3ef3

Bundle:
mission/tests/army-ground-foundation/dist/OMW_Army_Ground_Acceptance_9.lua

Bundle SHA-256:
35cc922581da980f558733433e487b025e083859b943641276672b6c168b4d6a

DCS:
2.9.28.26385 MT

MOOSE commit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

Moose.lua SHA-256:
e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

The uploaded mission artifact hash was calculated from the exact tested MIZ supplied after the successful run. The DCS log independently reports the same MOOSE commit and artifact SHA-256 through the existing OMW provenance logging.

## Required runtime markers

The real DCS log contains:

```text
OMW_GND_A9 START testId=ARMY-GROUND-ACCEPTANCE-9-2
OMW_GND_A9 SIX_NODE_STOCK_OK fortressVehicle=18 fortressPersonnel=160 honakerVehicle=18 honakerPersonnel=120
OMW_GND_A9 FORTRESS_SETTLEMENT_OK returnedVehicle=4 returnedPersonnel=12 exactlyOnce=true
OMW_GND_A9 HONAKER_SETTLEMENT_OK returnedVehicle=3 returnedPersonnel=9 lostVehicle=1 lostPersonnel=3 exactlyOnce=true
OMW_GND_A9 RUNTIME_PASS testId=ARMY-GROUND-ACCEPTANCE-9-2 sixGroundNodes=true productionBaselineMutation=false mizMutation=false
```

No `OMW_GND_A9 FAIL` occurs in the accepted run.

## Validated stock composition

Order: `PERSONNEL / VEHICLE / SUPPLY / AMMO / FUEL`.

```text
GROUND_NODE_JALALABAD 480 / 48 / 120 / 100 / 120
GROUND_NODE_FORTRESS  160 / 18 / 44  / 48  / 40
GROUND_NODE_JOYCE     180 / 20 / 48  / 44  / 40
GROUND_NODE_WRIGHT    120 / 22 / 36  / 30  / 36
GROUND_NODE_HONAKER   120 / 18 / 40  / 40  / 36
GROUND_NODE_BOSTICK   220 / 26 / 56  / 52  / 48
```

AirOps and AAR resources remained present in the same CampaignState store during the test.

## Settlement observations

### Fortress

```text
materialized/reserved: 4 VEHICLE + 12 PERSONNEL
returned:              4 VEHICLE + 12 PERSONNEL
duplicate return:      idempotent
final:                 18 VEHICLE / 160 PERSONNEL
```

### Honaker

```text
materialized/reserved: 4 VEHICLE + 12 PERSONNEL
confirmed loss:        1 VEHICLE + 3 PERSONNEL
returned:              3 VEHICLE + 9 PERSONNEL
duplicate return:      idempotent
final:                 17 VEHICLE / 117 PERSONNEL
loss audit:            1 VEHICLE / 3 PERSONNEL
```

## Historical correction gate

The accepted bundle contains no fixed Honaker M777/L118 production assumption. Current project evidence remains:

```text
2011 local mortar capability = confirmed
Jan-2010 possible two-gun position = observed; type/continuity unresolved
2012 M777 evidence = outside OMW scenario period
```

## Boundary

This result validates the CampaignState production-stock composition and existing settlement integration only. Acceptance 7 remains the physical MOOSE Ground lifecycle acceptance. The test does not validate new Ground-order generation, new MOOSE lifecycle behavior, OPSTRANSPORT, or general cross-domain persistence.
