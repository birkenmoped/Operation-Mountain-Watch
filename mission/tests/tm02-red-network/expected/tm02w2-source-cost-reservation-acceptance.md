# TM02W2 - Source, cost and reservation acceptance

## Status

```text
IMPLEMENTED LUA
STATIC LUA VALIDATION REQUIRED
DCS VALIDATION PENDING FOR VERSION 2
```

TM02W2 version 2 validates source selection, weighted paths and transactional reservations before physical proxy groups are started.

The DCS mission uses real, irregularly spaced locations. A non-nearest source selection is therefore logged but is not a mandatory DCS outcome. A controlled Lua harness separately requires and proves that the cost model can prefer a farther source when depletion and fragmentation make it cheaper.

## Mission fixture

```text
Mission: OMW_TEST_TM02W2_RED_SOURCE_COST_SELECTION.miz
11 RED location zones
2 BLUE objective zones
10 existing RED personnel templates
0 route groups
0 route waypoints
```

Reuse the accepted W1 mission. Do not move, rename, add or remove network zones to force a planner result.

Only the script action changes:

```text
remove/disable: mission/tests/tm02-red-network/dist/TM02W1.lua
add:            mission/tests/tm02-red-network/dist/TM02W2.lua
```

MOOSE remains the first `DO SCRIPT FILE` action.

## Planner scope

Implemented:

- personnel at all eleven logical nodes;
- guard floors, defensive targets and hard capacities;
- multiple candidate sources;
- weighted shortest paths over the W1 movement graph;
- distance and cross-command-area path cost;
- source-depletion and packet-fragmentation penalties;
- maximum packet strength six;
- inbound and outbound reservations;
- guard-floor, overfill and accounting validation;
- deterministic target priority.

Not implemented:

- proxy spawning or movement;
- applying reservations to actual inventories;
- transit losses;
- delayed reports and commander cycles;
- attacks and operational depletion.

## Personnel fixture

```text
Site                         Current  Guard  Target  Capacity
OMW_RED_HQ_Main                   30     12      24        40
OMW_RED_SUBHQ_Left                10      8      10        18
OMW_RED_SUBHQ_Right               10      8      10        18
OMW_RED_SITE_Central_01           10      4       8        16
OMW_RED_SITE_Central_02           10      4       8        16
OMW_RED_SITE_Central_03           12      4      10        16
OMW_RED_SITE_Central_04           12      4      10        16
OMW_RED_SITE_Left_01               2      2       8        12
OMW_RED_SITE_Left_02               4      2       8        12
OMW_RED_SITE_Right_01              2      2       8        12
OMW_RED_SITE_Right_02              6      2       8        12
```

Initial deficit:

```text
Left_01=6 Left_02=4 Right_01=6 Right_02=2 Total=18
```

## Cost and reservations

```text
weightedPathCost
+ sourceDepletionPenalty
+ packetFragmentationPenalty
= totalCost
```

```text
max packet strength: 6
distance weight: 1
cross-area penalty per edge: 750
depletion penalty per person below target: 1800
fragmentation penalty per missing person: 2500
```

A selected task reserves personnel without immediately changing current personnel:

```text
source.reservedOutbound += strength
target.reservedInbound  += strength
```

Later evaluations see those reservations, preventing double assignment, guard-floor violations and target overfill.

## Build and trigger

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch
git fetch origin
git switch feature/tm02w2-red-source-cost-selection
git pull --ff-only
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\build-tm02w2-bundle.ps1
```

Generated file:

```text
mission/tests/tm02-red-network/dist/TM02W2.lua
```

After rebuilding, reselect `TM02W2.lua` in the Mission Editor and save the mission.

Trigger actions:

```text
1. DO SCRIPT FILE -> vendor/moose/Moose.lua
2. DO SCRIPT FILE -> mission/tests/tm02-red-network/dist/TM02W2.lua
```

No RED group may spawn or move.

## Mandatory DCS summary

```text
event=red_source_cost_plan_summary
configurationVersion=TM02W2-red-source-cost-reservation-2
configurationValid=true
inventoryCount=11
initialDeficit=18
plannedTaskCount>=4
candidateEvaluationCount>plannedTaskCount
multiCandidateDecisionCount>=1
multiHopTaskCount>=1
reservationInfluenceCount>=1
totalReservedOutbound=18
totalReservedInbound=18
unresolvedDeficit=0
errorCount=0
warningCount=0
movementExecuted=false
```

Informational in DCS:

```text
nonNearestSelectionCount>=0
```

A zero value is valid when the nearest viable source also has the lowest total cost for every decision in the real network.

Additional DCS evidence:

```text
11 x event=red_personnel_inventory
>=4 x event=red_reinforcement_task_reserved
>plannedTaskCount x event=red_source_candidate_evaluated
```

## Controlled non-nearest proof

The Lua 5.1 harness uses fixed synthetic geometry and overrides:

```lua
config.planning.requireNonNearestSelection = true
```

It must prove:

```text
configurationValid=true
nonNearestSelectionCount>=1
multiHopTaskCount>=1
reservationInfluenceCount>=1
unresolvedDeficit=0
```

This is the mandatory proof that total cost can reject the nearest viable source.

## PASS

Version 2 passes when all 18 missing personnel are reserved exactly once, source guard floors and target capacities remain valid, multiple candidates and at least one multi-hop path are evaluated, reservations affect later decisions, accounting balances, no physical movement occurs, the static harness proves a non-nearest selection, and the version-2 DCS run contains no `[OMW][TM02W2] level=ERROR` line.
