# TM02W2F MOOSE-First Commander Refactor — 2026-07-26

Status: IMPLEMENTED, STATIC AND DCS REGRESSION PENDING

## Replaced

The current commander scheduler now uses MOOSE runtime services for generic orchestration:

```text
timer.scheduleFunction loops    -> SCHEDULER
custom global active gate       -> MOVEMENT
trigger.action.outText          -> MESSAGE
```

`MOVEMENT` is configured for the proxy and full-transit runtime alias prefixes and uses the former `maxActiveTransportsGlobal` value as its movement maximum.

## Retained custom policy

The following remains project-owned:

- task ordering and CampaignState identities;
- canary release and progress requirement;
- per-first-edge launch separation;
- minimum predecessor progress;
- command budget per planning cycle;
- inventory reservations and settlement;
- source, destination and mission-purpose selection.

These are campaign or test policies, not generic movement scheduling.

## Architecture warning

TM02W2F remains an initial-fill technical fixture. Its fixed target strengths and complete network population are not the production RED doctrine.

The production successor must use:

```text
HQ
Distribution Sites
Hide Sites
Forward Caches
Candidate Sites
```

with purposeful construction and supply movements, warehouse-backed resources, adaptive materialization and HUMINT/SIGINT consequences.

## Required regression

- verify `MOVEMENT` semantics against the pinned MOOSE runtime;
- determine whether its maximum is counted by units or groups for this fixture;
- verify infantry and spawned proxy handling;
- verify prefix matching for both runtime alias families;
- verify `ScheduleStart()`/`ScheduleStop()` lifecycle;
- Lua 5.1/static syntax validation;
- bundle build;
- canary PASS and FAIL paths;
- command-cycle and per-edge launch tests;
- no more than the intended amount of physically moving ground traffic;
- no accounting changes caused by MOOSE pause/resume behavior;
- pack/unpack and watchdog interaction.

## Deferred replacements

- direct off-road navigation by `PATHLINE` plus `Core.Astar` and transport-mode selection;
- travelling groups by `ARMYGROUP`/`OPSGROUP`;
- site construction by `SPAWNSTATIC`;
- task lifecycle by `FSM`/`AUFTRAG` where suitable;
- administration commands by `MARKEROPS_BASE`;
- site completion criteria by `GOAL` adapters.
