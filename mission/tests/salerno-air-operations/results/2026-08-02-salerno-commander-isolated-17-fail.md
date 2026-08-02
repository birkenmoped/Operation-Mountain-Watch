---
document_id: OMW-SAL-CMD-TEST-017
status: HISTORICAL_TEST_FIXTURE
authoritative_for:
  - SAL-COMMANDER-ISOLATED-17 runtime result
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
  - SAL-COMMANDER-SELECTION-18
source_branch: agent/salerno-read-only-diagnostics
source_commit: 439f8efe0859bd0672fa50e5647be2a5250f4dcf
validated_in_dcs: true
---

# Salerno COMMANDER isolated stage 17 – FAIL

## Test identity

```text
Date:            2026-08-02
OMW branch:      agent/salerno-read-only-diagnostics
OMW commit:      439f8efe0859bd0672fa50e5647be2a5250f4dcf
BuilderVersion:  SAL-COMMANDER-ISOLATED-17
Mission:         OMW_Template_v5_Salerno.miz
MOOSE release:   2.9.18 project baseline
Result:          FAIL
```

## Test objective

Validate one isolated CAS AUFTRAG submitted through `COMMANDER:AddMission()` with no parallel direct `AIRWING:AddMission()` CAS, RECON or LIFT workload.

## Observed behavior

- AIRWING/SQUADRON baseline constructed and started.
- COMMANDER object constructed.
- Salerno AIRWING added to COMMANDER.
- One CAS AUFTRAG added through `COMMANDER:AddMission()`.
- Mission remained `planned` at all observed snapshots.
- No aircraft spawned.
- Corrected test logic reported `FINAL status=FAIL`.
- Cleanup cancelled the planned mission.
- Debrief graveyard remained empty.

## Root cause

The stage constructed the COMMANDER and called `AddAirwing()`, but never called:

```lua
commander:Start()
```

MOOSE 2.9.18 `COMMANDER:New()` initializes the FSM in `NotReadyYet`. `AddAirwing()` only links the legion. The recurring `Status` cycle that invokes `CheckMissionQueue()` is started by `COMMANDER:Start()`.

`COMMANDER:AddMission()` itself only inserts the mission into `missionqueue` and marks its commander status as `PLANNED`. Because the COMMANDER FSM never entered `OnDuty`, the selection/recruitment cycle did not run.

The result therefore does not demonstrate that Salerno AIRWING assets were ineligible. It demonstrates a test-harness activation defect.

## Documentation and source cross-check

The missing start call contradicts the established OMW Jalalabad pattern and project documentation:

```lua
commander = COMMANDER:New(...)
commander:AddAirwing(airwing)
commander:Start()
```

Checked sources:

- `docs/00-project-governance.md`;
- `docs/26-moose-first-development-policy.md`;
- `docs/moose/AIR-OPERATIONS.md`;
- `docs/moose/EVENTS-AND-FSM.md`;
- `docs/moose/VERSION-AND-SOURCES.md`;
- `docs/moose/VERIFIED-METHODS.md`;
- Jalalabad complete-node activation source;
- official MOOSE 2.9.18 `Ops/Commander.lua` and `Ops/Legion.lua`.

## Correction

Stage `SAL-COMMANDER-SELECTION-18`:

- calls `COMMANDER:Start()`;
- requires FSM state `OnDuty`;
- logs `COMMANDER:CanMission()`;
- triggers the public `COMMANDER:Status()` event;
- observes documented `MissionAssign`, `MissionRequest` and `OpsOnMission` callbacks;
- retains strict isolation from direct AIRWING missions;
- keeps parking deferred.

## Still-valid findings

- The previous Blackhawk air spawn was caused by the parallel direct LIFT test and is absent from the isolated stage.
- AIRWING/SQUADRON construction, registration, capabilities, payloads and direct dispatch baseline remain separately established.
- COMMANDER construction and AIRWING linkage succeeded, but COMMANDER dispatch was not tested correctly until the start defect was corrected.

## Invalidated assumption

```text
COMMANDER:New() + AddAirwing() is sufficient to process AddMission().
```

Correct sequence:

```text
COMMANDER:New()
COMMANDER:AddAirwing()
COMMANDER:Start()
COMMANDER:AddMission()
COMMANDER Status/CheckMissionQueue cycle
```
