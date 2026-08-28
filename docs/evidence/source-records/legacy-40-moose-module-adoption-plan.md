---
document_id: OMW-PLAN-TM01-TM02-MOOSE-ADOPTION
status: PLANNED
authoritative_for:
  - proposed MOOSE adoption order for TM01 and TM02
  - module replacement matrix
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: review/tm01-tm02-moose-first
validated_in_dcs: false
---

# 40 – MOOSE Module Adoption Plan for TM01 and TM02

## Status

```text
IMPLEMENTATION PLANNING STARTED
```

This document extends `OMW-REVIEW-TM01-TM02-MOOSE-FIRST` in `docs/39-tm01-tm02-moose-first-code-review.md`.

No module is considered production-adopted until API presence, source signature, DCS behavior and regression results are verified against the pinned MOOSE runtime.

## Binding rule

Project-owned code remains responsible for campaign-specific policy and persistent state. MOOSE is responsible for runtime orchestration wherever an applicable class exists.

A remaining custom mechanism is not approved merely because it is technically necessary. Production use requires explicit project-owner approval under `OMW-GOV-001` and `OMW-GOV-MOOSE-FIRST`.

Mandatory review targets:

- `Functional.Movement`;
- `Core.MarkerOps_Base`;
- `Core.Goal`;
- `Core.Message`;
- `Core.Pathline`;
- `Core.SpawnStatic`;
- `Core.Scheduler`;
- `Core.Fsm`;
- `Core.Astar`;
- `Wrapper.Group`, `Ops.ArmyGroup`, `Ops.OpsGroup`;
- MOOSE `SET_*` collections and event handling.

## Functional.Movement

`MOVEMENT` is the first-choice runtime limiter for simultaneously moving RED ground groups that share configured prefixes.

It replaces project code whose only purpose is to:

- enforce a global moving-ground limit;
- pause excess matching groups;
- periodically release waiting groups;
- react to births and losses for that limit.

It does not replace RED campaign planning. CampaignState and the RED Director still select source, destination, personnel, cargo, transport mode, route policy, mission purpose and strategic consequence.

Separate custom limits may remain only where `MOVEMENT` demonstrably cannot express required policy, for example per-edge launch separation, construction-team uniqueness or safety interlocks. Every retained limit needs documented evidence and owner approval.

## Core.Pathline

`PATHLINE` is the preferred representation for designer-approved route geometry.

### TM01

```text
PATH_BLUE_<SOURCE>_<DESTINATION>
```

The existing zone-anchor route remains only as a historical regression fixture until the PATHLINE fixture passes DCS validation.

### TM02

```text
PATH_RED_VEHICLE_<SOURCE>_<DESTINATION>
PATH_RED_FOOT_<SOURCE>_<DESTINATION>
PATH_RED_TRANSFER_<SOURCE>_<TRANSFER_POINT>
```

`PATHLINE` provides geometry and terrain metadata. `Core.Astar` selects among graph edges; OMW policy supplies cost and suitability rules.

## Core.Message

`MESSAGE` replaces normal runtime use of `trigger.action.outText*`.

Standard categories:

```text
OMW COMMAND
OMW LOGISTICS
OMW INTEL
OMW CSAR
OMW CIVIL SUPPORT
OMW TEST
OMW DEBUG
```

A protected native DCS emergency reporter may remain only for failures before MOOSE initialization. This narrow fallback requires an explicitly documented and owner-approved exception.

## Core.Goal

`GOAL` is used for runtime success criteria and contribution tracking where applicable.

```text
MissionDemand  persistent strategic requirement
PLAYERTASK     player execution contract
AUFTRAG        AI execution contract
GOAL           runtime completion criterion and contribution record
```

Initial candidates:

- TM01 arrival;
- humanitarian delivery;
- CSAR recovery;
- reconnaissance confirmation;
- RED-site confirmation, abandonment or destruction.

## Core.SpawnStatic

`SPAWNSTATIC` is the first-choice mechanism for runtime-visible infrastructure and cargo representations:

- RED hide-site construction objects;
- forward-cache crates and supplies;
- humanitarian-delivery objects;
- destroyed and rebuilt site states;
- visible warehouse anchors where required.

A spawned static is never the authoritative inventory. CampaignState and warehouse records remain authoritative.

## Core.MarkerOps_Base

`MARKEROPS_BASE` is reserved for controlled administrator, developer and mission-designer commands, for example:

```text
#OMW SITE INSPECT
#OMW PATH INSPECT
#OMW WAREHOUSE STATUS
#OMW EXPOSURE SHOW
#OMW SETTLEMENT REGISTER
#OMW DELIVERYPOINT REGISTER
```

It is not the normal player interface and may not expose hidden RED information to unrestricted players.

## TM01 replacement matrix

| Existing mechanism | Planned MOOSE-first replacement |
|---|---|
| direct runtime messages | `MESSAGE` |
| timer scheduling / wrapped ticks | `SCHEDULER` |
| native player scan | `SET_CLIENT` / `SET_PLAYER` |
| native enemy lookup loops | `SET_GROUP` / `SET_UNIT` |
| native group lookup | `GROUP:FindByName()` |
| route-anchor zone chain | `PATHLINE` after fixture validation |
| physical group wrapper | `ARMYGROUP` / `OPSGROUP` suitability test |
| destruction and combat polling | MOOSE events; reconciliation polling only where proven necessary |
| arrival state | `GOAL` or CampaignState-backed goal adapter |

## TM02 replacement matrix

| Existing mechanism | Planned MOOSE-first replacement |
|---|---|
| global moving-ground limiter | `MOVEMENT` |
| project timer loops | `SCHEDULER` |
| custom graph traversal | `Core.Astar` with OMW cost policy |
| route geometry arrays | `PATHLINE` |
| travelling ground wrappers | `ARMYGROUP` / `OPSGROUP` |
| direct messages | `MESSAGE` |
| task-state machinery | `FSM`; `AUFTRAG` where suitable |
| site visual construction | `SPAWNSTATIC` |
| test/admin map commands | `MARKEROPS_BASE` |
| site/group collections | MOOSE `SET_*` classes |
| loss and combat observation | MOOSE events |

TM02A through TM02V remain `HISTORICAL_TEST_FIXTURE`. TM02W and successors are the production-architecture line.

## Implementation order

1. Replace normal runtime messages with `MESSAGE`; isolate emergency reporter.
2. Replace TM01 wrapped-tick monitoring with `SCHEDULER` and MOOSE sets.
3. Add PATHLINE fixtures and retain anchor fixtures only for regression.
4. Add TM02 `MOVEMENT` limiter and remove equivalent global custom gate.
5. Replace TM02 custom timers with `SCHEDULER`.
6. Introduce `ARMYGROUP`/`OPSGROUP` wrappers.
7. Replace graph search with `Core.Astar` while retaining OMW costs and CampaignState reservations.
8. Introduce `SPAWNSTATIC` site-state tests.
9. Add `GOAL` adapters and `MARKEROPS_BASE` admin tools.
10. Document and request owner approval for every remaining custom production mechanism.

## Validation requirement

Every migration requires:

- API presence check against pinned MOOSE runtime;
- method signature and source review;
- static Lua validation;
- generated-bundle validation;
- dedicated DCS regression test;
- comparison with the accepted historical fixture;
- evidence that campaign accounting and no-double-representation invariants remain intact;
- explicit owner approval for any retained non-MOOSE fallback.

No existing draft PR is authorized for merge by this document.
