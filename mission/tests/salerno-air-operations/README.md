# FOB Salerno AIRWING / COMMANDER diagnostics

## Status

```yaml
status: ACCEPTED_TECHNICAL_BASELINE
builder_version: SAL-COMMANDER-SELECTION-18
commander_dispatch: PASS
parking_assignment: DEFERRED
additional_salerno_runtime_test_required: false
```

This bundle validates the Salerno AIRWING/SQUADRON baseline and one isolated COMMANDER-controlled CAS mission.

Accepted result:

- AIRWING and five SQUADRONs constructed and registered;
- twenty Warehouse assets registered;
- mission capabilities and payloads available;
- AIRWING running;
- COMMANDER started from `NotReadyYet` to `OnDuty`;
- CAS AUFTRAG accepted by `COMMANDER:CanMission()`;
- Salerno AIRWING selected;
- AH-64 mission asset requested and placed `OpsOnMission`;
- AUFTRAG progressed to `started`;
- controlled cleanup completed without a recorded loss.

Parking compliance remains outside this accepted scope.

## Accepted provenance

```text
OMW branch:              agent/salerno-read-only-diagnostics
OMW commit:              dba0465afbff14fb719abdeb1f9b06e24ff24717
BuilderVersion:          SAL-COMMANDER-SELECTION-18
Bundle SHA-256:          75ea74cdaa60800899345924fc4eb450c15211d605bf972767d9d68e265421ee
Mission:                 OMW_Template_v5_Salerno.miz
Supplied .miz SHA-256:   4c9670babced44007952a02100de07b42eecdec156046ca7d1497a6a932edfaf
DCS version:             2.9.28.26385
MOOSE commit:            73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Embedded Moose.lua SHA:  e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Acceptance report:

- [`2026-08-02-salerno-commander-selection-18-pass.md`](results/2026-08-02-salerno-commander-selection-18-pass.md)

Historical failed stage:

- [`2026-08-02-salerno-commander-isolated-17-fail.md`](results/2026-08-02-salerno-commander-isolated-17-fail.md)

## MOOSE-first source review

Stage 18 follows the project MOOSE-first policy and was checked against:

- `docs/00-project-governance.md`;
- `docs/22-test-mission-build-transfer-and-validation-workflow.md`;
- `docs/26-moose-first-development-policy.md`;
- `docs/moose/AIR-OPERATIONS.md`;
- `docs/moose/EVENTS-AND-FSM.md`;
- `docs/moose/VERSION-AND-SOURCES.md`;
- `docs/moose/VERIFIED-METHODS.md`;
- the accepted Jalalabad construction/start pattern in `mission/tests/jalalabad-air-operations/src/10-validate-and-start-complete-node.lua`;
- official MOOSE source at commit `73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`, especially `Ops/Commander.lua` and `Ops/Legion.lua`.

The decisive MOOSE behavior is:

1. `COMMANDER:New()` creates the FSM in state `NotReadyYet`;
2. `COMMANDER:AddAirwing()` binds the AIRWING but does not start the COMMANDER;
3. `COMMANDER:Start()` transitions the FSM to `OnDuty` and starts the recurring `Status` cycle;
4. `COMMANDER:AddMission()` inserts the AUFTRAG into `missionqueue` with commander status `PLANNED`;
5. `COMMANDER:onafterStatus()` calls `CheckMissionQueue()`, which performs selection and recruitment.

The previous `SAL-COMMANDER-ISOLATED-17` fixture omitted `COMMANDER:Start()`. The AUFTRAG therefore remained `planned`; this was a test-harness defect, not a demonstrated failure of COMMANDER asset selection.

## Accepted test sequence

1. Resolve Salerno AIRBASE, Warehouse, templates, clients and zones.
2. Construct and register five SQUADRONs.
3. Register mission capabilities and payloads.
4. Start the AIRWING.
5. Construct COMMANDER.
6. Add Salerno AIRWING to COMMANDER.
7. Attach FSM callbacks for `MissionAssign`, `MissionRequest` and `OpsOnMission`.
8. Call `COMMANDER:Start()` and require state `OnDuty`.
9. Construct one CAS AUFTRAG.
10. Check `COMMANDER:CanMission()`.
11. Add the AUFTRAG through `COMMANDER:AddMission()`.
12. Trigger the public `COMMANDER:Status()` event so the normal `CheckMissionQueue()` selection path executes immediately.
13. Observe eligibility, assignment, AIRWING request, `OpsOnMission`, progress to `started` and cleanup.

No direct `AIRWING:AddMission()` test, RECON mission or LIFT mission runs in parallel.

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

## Runtime acceptance markers

```text
[OMW][SALERNO][DIAG] BOOT Version=SAL-COMMANDER-SELECTION-18
[OMW][SALERNO][COMMANDER] FSM beforeStart=NotReadyYet afterStart=OnDuty expectedAfterStart=OnDuty started=true
[OMW][SALERNO][COMMANDER] COMPLETE status=PASS
[OMW][SALERNO][COMMANDER-DISPATCH] ELIGIBILITY commanderCanMission=true
[OMW][SALERNO][COMMANDER-DISPATCH] SELECTION_TRIGGER method=COMMANDER.Status called=true ok=true
[OMW][SALERNO][COMMANDER] EVENT event=MissionAssign
[OMW][SALERNO][COMMANDER] AIRWING_EVENT event=MissionRequest
[OMW][SALERNO][COMMANDER] EVENT event=OpsOnMission
[OMW][SALERNO][COMMANDER-DISPATCH] EVENT event=Started from=scheduled to=started
[OMW][SALERNO][COMMANDER-DISPATCH] FINAL status=PASS
```

## Accepted and deferred scope

```yaml
accepted:
  - AIRWING construction and start
  - SQUADRON construction and registration
  - capabilities and payloads
  - COMMANDER construction, AIRWING binding and start
  - CAS eligibility
  - COMMANDER AIRWING selection
  - mission request and AH-64 asset assignment
  - AUFTRAG progress to started
  - controlled cleanup

deferred:
  - exact parking compliance
  - cold ground spawn visual confirmation
  - tactical target engagement
  - tactical mission completion
  - return, landing and recovery
  - persistent inventory booking
  - theater-wide production COMMANDER
```
