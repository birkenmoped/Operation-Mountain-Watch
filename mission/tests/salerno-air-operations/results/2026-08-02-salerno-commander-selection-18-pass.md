---
document_id: OMW-SAL-CMD-TEST-018
status: ACCEPTED_TECHNICAL_BASELINE
authoritative_for:
  - Salerno AIRWING and SQUADRON construction and registration
  - Salerno AIRWING start
  - isolated COMMANDER CAS eligibility, selection, assignment and progress to started
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - OMW-SAL-CMD-TEST-017
superseded_by:
source_branch: agent/salerno-read-only-diagnostics
source_commit: dba0465afbff14fb719abdeb1f9b06e24ff24717
validated_in_dcs: true
---

# Salerno COMMANDER selection stage 18 – PASS

## 1. Test identity

```text
Date:                    2026-08-02
OMW branch:              agent/salerno-read-only-diagnostics
OMW commit:              dba0465afbff14fb719abdeb1f9b06e24ff24717
BuilderVersion:          SAL-COMMANDER-SELECTION-18
Bundle SHA-256:          75ea74cdaa60800899345924fc4eb450c15211d605bf972767d9d68e265421ee
Bundle size:             43609 bytes
Bundle GeneratedUtc:     2026-08-02T16:04:49.6355103Z
Mission:                 OMW_Template_v5_Salerno.miz
Supplied .miz SHA-256:   4c9670babced44007952a02100de07b42eecdec156046ca7d1497a6a932edfaf
DCS version:             2.9.28.26385
MOOSE commit:            73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Embedded Moose.lua SHA:  e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Embedded Moose.lua size: 9773155 bytes
Result:                  PASS
```

The supplied current mission contains the same Salerno bundle bytes as the locally hashed `dist/OMW_AirOps_Salerno_Diagnostics.lua`. The embedded bundle header records the expected OMW commit and builder version. The mission also contains the long-used `Moose.lua`; its first line records the exact upstream commit shown above.

The local repository state reported for the tested artifact was clean:

```text
git status --short -> no output
git diff --check    -> no output
```

## 2. Test objective

Validate one isolated CAS AUFTRAG submitted through a correctly started MOOSE COMMANDER, with no parallel direct Salerno AIRWING CAS, RECON or LIFT test mission.

The required chain was:

```text
COMMANDER:New()
COMMANDER:AddAirwing()
COMMANDER:Start()
COMMANDER:CanMission()
COMMANDER:AddMission()
COMMANDER:Status() -> CheckMissionQueue()
COMMANDER MissionAssign
AIRWING MissionRequest
COMMANDER/AIRWING OpsOnMission
AUFTRAG started
```

Parking control remained explicitly deferred and was not an acceptance criterion.

## 3. MOOSE-first verification

Before stage 18, the project documentation, accepted Jalalabad construction pattern, official MOOSE documentation and exact MOOSE source were checked.

The decisive MOOSE behavior is:

- `COMMANDER:New()` starts in `NotReadyYet`;
- `AddAirwing()` links a Legion but does not activate the COMMANDER FSM;
- `Start()` transitions the COMMANDER to `OnDuty` and starts its status cycle;
- `AddMission()` inserts the AUFTRAG with commander status `PLANNED`;
- `onafterStatus()` invokes `CheckMissionQueue()`, which performs selection and asset recruitment.

Stage 17 omitted `COMMANDER:Start()` and was therefore a test-harness failure. Stage 18 corrected that sequence without replacing MOOSE selection logic with project-specific logic.

## 4. Observed runtime sequence

### 4.1 COMMANDER activation

```text
Starting Commander
FSM beforeStart=NotReadyYet afterStart=OnDuty
started=true
BOUND airwing=AW_US_SALERNO
legionTableCount=1
reverseLink=true
airwingState=Running
COMPLETE status=PASS
```

### 4.2 Eligibility and queue entry

The isolated CAS mission was accepted as executable by the registered Salerno resources:

```text
commanderCanMission=true
commanderState=onduty
airwingState=running
commanderLegions=1
airwingCohorts=5
payloads=10
```

The mission was added through `COMMANDER:AddMission()` and the public `COMMANDER:Status()` event was called successfully to run the normal queue-selection path.

### 4.3 Selection, request and mission start

The runtime then recorded:

```text
COMMANDER MissionAssign -> AW_US_SALERNO
AIRWING MissionRequest
OpsOnMission -> SQ_US_SAL_AH64D_TF_TIGERSHARK_ATTACK_AID-111
AUFTRAG scheduled -> started
```

At the final snapshot:

```text
commanderState=onduty
missionState=started
commanderMissionStatus=queued
commanderQueue=1
airwingQueue=1
assigned=true
requested=true
opsOnMission=true
```

The AIRWING status independently confirmed one active mission asset:

```text
Missions=1
Assets OnMission: Total=1, Active=1
OMW-SAL-COMMANDER-CAS Assets=1/1
```

Final test decision:

```text
eligible=true
selected=true
assignedEvent=true
requestedEvent=true
opsOnMissionEvent=true
progressed=true
FINAL status=PASS
```

## 5. Cleanup and loss state

The harness cancelled the mission after the acceptance evidence was recorded. The mission transitioned to `done`, and the AIRWING subsequently returned to:

```text
Missions=0
OnMission: Total=0, Active=0, Queued=0
```

The debrief recorded:

```text
graveyard = {}
```

The later MOOSE `Mission success!` message occurred after controlled cancellation and is not accepted as evidence of tactical target destruction or objective completion.

## 6. Acceptance matrix

```yaml
airbase_resolution: PASS
warehouse_and_template_validation: PASS
squadron_construction_5_of_5: PASS
squadron_registration: PASS
registered_asset_stock_20: PASS
mission_capability_registration: PASS
payload_registration: PASS
airwing_start: PASS
commander_construction: PASS
commander_add_airwing: PASS
commander_start_to_onduty: PASS
commander_can_mission: PASS
commander_mission_selection: PASS
airwing_mission_request: PASS
ah64_asset_assignment: PASS
auftrag_progress_to_started: PASS
controlled_cleanup: PASS
loss_state_empty: PASS

parking_assignment: DEFERRED
exact_parking_compliance: NOT_ACCEPTED
cold_ground_spawn_visual_confirmation: NOT_TESTED
tactical_target_engagement: NOT_TESTED
tactical_mission_completion: NOT_TESTED
return_landing_recovery: NOT_TESTED
persistent_inventory_booking: NOT_TESTED
theater_wide_commander: NOT_IMPLEMENTED
```

## 7. Known non-blocking messages

The runtime repeatedly reported:

```text
Could not get EVENTMETA data for event ID=61
```

This did not prevent mission eligibility, assignment, request, `OpsOnMission` or progress to `started`. Its exact DCS-event meaning remains unverified and is not guessed here.

The known external shutdown messages from Saved-Games hooks are outside the Salerno bundle and did not affect acceptance.

## 8. Architectural consequence

The `CMD_BLUE_AFGHANISTAN_TEST` object in this fixture contains only the Salerno AIRWING and remains a local acceptance harness.

The production architecture should later use exactly one theater-wide BLUE COMMANDER module, loaded after the individual AIRWING modules. The historical Jalalabad and Salerno acceptance fixtures remain unchanged for reproducibility.

## 9. Final decision

```yaml
salerno_air_operations_foundation: ACCEPTED_TECHNICAL_BASELINE
salerno_commander_dispatch: PASS
additional_salerno_runtime_test_required: false
parking_work: DEFERRED
pr_merge_authorized: false
ready_for_review_authorized: false
next_airfield_work: UNBLOCKED
```
