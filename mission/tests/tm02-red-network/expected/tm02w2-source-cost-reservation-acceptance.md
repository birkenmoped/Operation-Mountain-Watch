# TM02W2 – Source, cost and reservation acceptance

## Status

```text
IMPLEMENTED LUA
DCS VALIDATION PENDING
```

TM02W2 version 1 is the first planner increment. It deliberately validates source selection, weighted path choice and transactional reservations **before** physical proxy groups are started.

This is still part of the W2 family. A later W2 increment will execute the accepted tasks with the TM02V proxy layer.

## Mission

```text
OMW_TEST_TM02W2_RED_SOURCE_COST_SELECTION.miz
```

Start from the accepted W1 mission:

```text
OMW_TEST_TM02W1_RED_NETWORK_REGISTRY.miz
```

Save a copy under the W2 filename. Do not move, rename, add or remove any network zone.

The Mission Editor fixture remains:

```text
11 RED location zones
2 BLUE objective zones
10 existing RED personnel templates
0 route groups
0 route waypoints
```

## What changes from W1

Only the script action changes:

```text
remove/disable: mission/tests/tm02-red-network/dist/TM02W1.lua
add:            mission/tests/tm02-red-network/dist/TM02W2.lua
```

MOOSE remains the first `DO SCRIPT FILE` action.

## W2 version 1 scope

Implemented:

- personnel inventory at all eleven active logical nodes;
- independent `guardFloor`, `defensiveTarget` and `hardCapacity` bands;
- multiple candidate sources for every deficit;
- shortest weighted movement path over the validated W1 graph;
- direct distance and cross-command-area path cost;
- source-depletion penalty;
- packet-fragmentation penalty;
- maximum packet strength of six;
- transactional inbound and outbound reservations;
- guard-floor, overfill and accounting validation;
- deterministic target priority;
- evidence that the selected source need not be the physically nearest source.

Not implemented in this increment:

- spawning or moving proxy groups;
- applying the reservation to actual personnel inventories;
- losses in transit;
- delayed reports or commander cycles;
- attacks or planned operational depletion.

## Personnel fixture

The planner uses the following fixed W2 test inventory:

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

Initial deficits:

```text
Left_01   6
Left_02   4
Right_01  6
Right_02  2
----------------
Total     18
```

The other seven nodes are candidate personnel sources.

## Cost model

For each candidate source and target, W2 calculates:

```text
weightedPathCost
+ sourceDepletionPenalty
+ packetFragmentationPenalty
= totalCost
```

Configured values:

```text
maximum packet strength:                 6
movement distance weight:                1
cross-command-area penalty per edge:   750
penalty per person below source target: 1800
penalty per missing person in packet:  2500
```

The fragmentation penalty makes it possible for a slightly more distant source that can supply a complete group to be cheaper than the nearest source that can provide only a small fragment.

## Reservations

A selected task does not immediately change `currentPersonnel`. Instead it reserves:

```text
source.reservedOutbound += task.strength
target.reservedInbound  += task.strength
```

Every later candidate evaluation sees those reservations. This prevents:

- assigning the same source personnel twice;
- sending multiple tasks into already reserved target capacity;
- dropping a source below its guard floor;
- filling a target beyond its defensive target or hard capacity.

## Build

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch

git fetch origin
git switch feature/tm02w2-red-source-cost-selection
git pull --ff-only

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\tools\build-tm02w2-bundle.ps1
```

Generated file:

```text
mission/tests/tm02-red-network/dist/TM02W2.lua
```

After every rebuild, reselect `TM02W2.lua` in the Mission Editor and save the mission.

## DCS trigger

```text
MISSION START
Condition: none
```

Actions in this order:

```text
1. DO SCRIPT FILE -> vendor/moose/Moose.lua
2. DO SCRIPT FILE -> mission/tests/tm02-red-network/dist/TM02W2.lua
```

## Expected behaviour

At mission start no RED group may spawn or move. W2 automatically builds one complete reservation plan.

Expected screen summary:

```text
TM02W2 PASS
initialDeficit=18
reserved=18
unresolved=0
errors=0
```

The exact number of tasks and the exact selected sources may depend on the actual zone geometry because path distance is part of the cost model. The following invariants are mandatory.

## Mandatory log summary

```text
event=red_source_cost_plan_summary
configurationVersion=TM02W2-red-source-cost-reservation-1
configurationValid=true
inventoryCount=11
initialDeficit=18
plannedTaskCount>=4
candidateEvaluationCount>plannedTaskCount
multiCandidateDecisionCount>=1
multiHopTaskCount>=1
nonNearestSelectionCount>=1
reservationInfluenceCount>=1
totalReservedOutbound=18
totalReservedInbound=18
unresolvedDeficit=0
errorCount=0
warningCount=0
movementExecuted=false
```

Additional required evidence:

```text
11 x event=red_personnel_inventory
>=1 x event=red_non_nearest_source_selected
>=4 x event=red_reinforcement_task_reserved
>plannedTaskCount x event=red_source_candidate_evaluated
```

## F10 menu

```text
F10 Other
└── OMW Tests
    └── TM02W2 RED Source Cost
        ├── Show plan summary
        ├── List inventories
        ├── List reserved tasks
        └── Reset and replan
```

`Reset and replan` must reproduce a valid plan from the unchanged starting inventory without accumulating old reservations.

## PASS

TM02W2 version 1 passes when:

- the inherited W1 registry is valid;
- all eleven inventories are registered;
- all 18 missing personnel are reserved exactly once;
- every source remains at or above its guard floor;
- no target is overfilled;
- no task exceeds six personnel;
- candidate costs are compared before selection;
- at least one multi-hop task is produced;
- at least one source selection differs from the physically nearest viable source because total cost is lower;
- existing reservations influence later candidate evaluations;
- inbound and outbound reservation totals are equal;
- no physical movement occurs;
- no `[OMW][TM02W2] level=ERROR` appears.

After this planner acceptance, the next W2 increment applies the reserved tasks to real TM02V proxy movements. W3 remains reserved for delayed information and bounded command cycles.
