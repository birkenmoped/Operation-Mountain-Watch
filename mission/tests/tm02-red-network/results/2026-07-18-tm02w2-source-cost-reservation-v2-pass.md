# TM02W2 source, cost and reservation planner v2 - DCS PASS

Date: 2026-07-18

Mission:

```text
OMW_TEST_TM02W2_RED_SOURCE_COST_SELECTION.miz
```

Configuration:

```text
TM02W2-red-source-cost-reservation-2
buildTimestamp=2026-07-18T15:03:22Z
```

## Result

```text
PASS
```

The real, irregular Afghanistan fixture produced a complete and valid reservation plan without moving any physical group.

Initial plan:

```text
configurationValid=true
inventoryCount=11
initialDeficit=18
plannedTaskCount=7
candidateEvaluationCount=47
multiCandidateDecisionCount=7
multiHopTaskCount=3
crossAreaTaskCount=3
nonNearestSelectionCount=0
reservationInfluenceCount=18
totalReservedOutbound=18
totalReservedInbound=18
unresolvedDeficit=0
errorCount=0
warningCount=0
movementExecuted=false
```

`nonNearestSelectionCount=0` is valid for the real fixture because the nearest viable source also had the lowest total cost for every selected task. The separate controlled Lua 5.1 harness continues to require and prove a non-nearest selection.

## Deterministic reset and replan

The F10 `Reset and replan` action was executed twice. Plan generations 2 and 3 reproduced the same valid result:

```text
plannedTaskCount=7
candidateEvaluationCount=47
totalReservedOutbound=18
totalReservedInbound=18
unresolvedDeficit=0
errorCount=0
configurationValid=true
```

No previous reservation accumulated into a later generation.

## Inventory invariants

- every source remained at or above its guard floor;
- no target exceeded hard capacity;
- no task exceeded six personnel;
- inbound and outbound reservation totals matched exactly;
- all 18 missing personnel were reserved exactly once;
- no RED group spawned or moved.

## External shutdown error

The recurring `bhHook.lua:168` TCP error occurred after mission stop. It is outside TM02W2 and did not affect the completed planner validation.

## Conclusion

TM02W2 planner-only scope is accepted and frozen. The next isolated increment executes the accepted reserved tasks through independent TM02V-derived proxy groups. Delayed reports and bounded command cycles remain TM02W3 scope.
