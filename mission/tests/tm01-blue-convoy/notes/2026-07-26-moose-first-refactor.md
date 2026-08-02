# TM01 MOOSE-First Refactor — 2026-07-26

Status: IMPLEMENTED, DCS REGRESSION PENDING

## Replaced

The representation-interest monitor no longer wraps the convoy controller's existing tick and no longer performs native DCS player/group scans.

Replacements:

```text
wrapped controller tick        -> MOOSE SCHEDULER
coalition.getPlayers           -> SET_CLIENT
Group.getByName enemy loop     -> GROUP:FindByName + SET_GROUP
manual coordinate arithmetic   -> COORDINATE:Get2DDistance
normal runtime notification    -> MESSAGE
```

## Retained campaign policy

The following remains project-owned because it is OMW campaign policy rather than generic runtime orchestration:

- player and enemy unpack radii;
- hysteresis bands;
- continuous-clear pack delay;
- unpack retry delay;
- prohibition of packing while player/enemy relevance is present;
- CampaignState representation state and timestamps;
- controller `pack()` and `unpack()` transactions.

## Files

```text
mission/tests/tm01-blue-convoy/src/representation_interest_monitor.lua
mission/tests/tm01-blue-convoy/src/moose_representation_interest_service.lua
```

The second file is retained as the isolated implementation source during the migration. The active bundle continues to load `representation_interest_monitor.lua`, which now contains the MOOSE implementation.

## Required regression

- Lua 5.1/static syntax validation;
- bundle build;
- player-only enter/hysteresis/exit test;
- enemy-only enter/hysteresis/exit test;
- simultaneous player and enemy relevance;
- pack-delay cancellation;
- automatic unpack retry;
- destruction during scheduled service;
- verification that the MOOSE scheduler stops after a fatal service failure;
- no duplicate materialization or dematerialization.

## Completed after this note

- TM01M route-anchor zones were replaced by Mission Editor `PATHLINE` objects `MSR_EAST_E03` and `MSR_EAST_E02`.
- TM01M spawn placement now uses MOOSE `SPAWN:InitSetUnitAbsolutePositions()` with individual road positions and headings.
- Details are documented in `notes/2026-07-26-tm01m-msr-pathline-routing.md`.

## Deferred replacements

- physical group wrapper by `ARMYGROUP`/`OPSGROUP`;
- event-driven loss/engagement protection;
- runtime arrival `GOAL` adapter;
- remaining direct `trigger.action.outText` calls outside the interest service.
