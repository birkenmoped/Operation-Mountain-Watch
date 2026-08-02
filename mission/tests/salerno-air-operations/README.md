# FOB Salerno AIRWING / COMMANDER diagnostics

## Status

```yaml
status: DRAFT_TEST_FIXTURE
builder_version: SAL-COMMANDER-SELECTION-18
parking_assignment: DEFERRED
commander_dispatch: PENDING_DCS_VALIDATION
```

This bundle validates the Salerno AIRWING/SQUADRON baseline and then runs one isolated COMMANDER-controlled CAS mission.

## MOOSE-first source review for stage 18

The stage follows the project MOOSE-first policy and was checked against:

- `docs/00-project-governance.md`;
- `docs/22-test-mission-build-transfer-and-validation-workflow.md`;
- `docs/26-moose-first-development-policy.md`;
- `docs/moose/AIR-OPERATIONS.md`;
- `docs/moose/EVENTS-AND-FSM.md`;
- `docs/moose/VERSION-AND-SOURCES.md`;
- `docs/moose/VERIFIED-METHODS.md`;
- the accepted Jalalabad construction/start pattern in `mission/tests/jalalabad-air-operations/src/10-validate-and-start-complete-node.lua`;
- official MOOSE `2.9.18` source: `Moose Development/Moose/Ops/Commander.lua` and `Ops/Legion.lua`.

The decisive MOOSE 2.9.18 behavior is:

1. `COMMANDER:New()` creates the FSM in state `NotReadyYet`;
2. `COMMANDER:AddAirwing()` binds the AIRWING but does not start the COMMANDER;
3. `COMMANDER:Start()` transitions the FSM to `OnDuty` and starts the recurring `Status` cycle;
4. `COMMANDER:AddMission()` only inserts the AUFTRAG into `missionqueue` with commander status `PLANNED`;
5. `COMMANDER:onafterStatus()` calls `CheckMissionQueue()`, which performs the selection/recruitment decision.

The previous `SAL-COMMANDER-ISOLATED-17` fixture omitted `COMMANDER:Start()`. The AUFTRAG therefore remained `planned`; this was a test-harness defect, not a demonstrated failure of COMMANDER asset selection.

## Current test sequence

1. Resolve Salerno AIRBASE, Warehouse, templates, clients and zones.
2. Construct and register five SQUADRONs.
3. Register mission capabilities and payloads.
4. Start the AIRWING.
5. Construct COMMANDER.
6. Add Salerno AIRWING to COMMANDER.
7. Attach documented FSM callbacks for `MissionAssign`, `MissionRequest` and `OpsOnMission`.
8. Call `COMMANDER:Start()` and require state `OnDuty`.
9. Construct one CAS AUFTRAG.
10. Log `COMMANDER:CanMission()`.
11. Add the AUFTRAG through `COMMANDER:AddMission()`.
12. Trigger the public MOOSE `COMMANDER:Status()` event so the normal `CheckMissionQueue()` selection path executes immediately.
13. Observe eligibility, assignment, AIRWING request, mission progress and cleanup.

No direct `AIRWING:AddMission()` test runs in this bundle. No RECON or LIFT mission runs in parallel.

## Build

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File ".\tools\build-salerno-air-operations-bundle.ps1"
```

Output:

```text
mission/tests/salerno-air-operations/dist/OMW_AirOps_Salerno_Diagnostics.lua
```

Expected builder marker:

```text
BuilderVersion: SAL-COMMANDER-SELECTION-18
```

## Mission Editor integration

Re-select the generated file in the Salerno `MISSION START -> DO SCRIPT FILE` action and save the mission after every rebuild.

MOOSE must be loaded before this bundle.

## Runtime

Run the mission for at least 125 seconds.

## Key markers

```text
[OMW][SALERNO][DIAG] BOOT Version=SAL-COMMANDER-SELECTION-18
[OMW][SALERNO][COMMANDER] FSM beforeStart=NotReadyYet afterStart=OnDuty expectedAfterStart=OnDuty started=true
[OMW][SALERNO][COMMANDER] COMPLETE status=PASS
[OMW][SALERNO][COMMANDER-DISPATCH] ELIGIBILITY commanderCanMission=true
[OMW][SALERNO][COMMANDER-DISPATCH] SELECTION_TRIGGER method=COMMANDER.Status called=true ok=true
[OMW][SALERNO][COMMANDER] EVENT event=MissionAssign
[OMW][SALERNO][COMMANDER-DISPATCH] DECISION eligible=true selected=true
[OMW][SALERNO][COMMANDER-DISPATCH] FINAL status=PASS
```

A PASS requires all of the following:

- COMMANDER state `OnDuty`;
- `COMMANDER:CanMission()` returns `true`;
- selection/assignment is visible through status or event telemetry;
- the AUFTRAG leaves `planned`;
- no direct AIRWING test mission is active;
- no unexpected UH-60, OH-58D or CH-47 spawn occurs.

Parking remains explicitly outside this acceptance scope.
