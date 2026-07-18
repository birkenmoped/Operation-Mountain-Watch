# TM02W2 v1 DCS result

Date: 2026-07-18
Mission: `OMW_TEST_TM02W2_RED_SOURCE_COST_SELECTION.miz`
Configuration: `TM02W2-red-source-cost-reservation-1`
Outcome: FAIL

Observed summary:

```text
configurationValid=false
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
errorCount=1
warningCount=0
movementExecuted=false
```

The only failed assertion was `NON_NEAREST_SELECTION_NOT_PROVEN`.

The planner completed all reservations correctly. The real mission geometry simply made the nearest viable source the lowest-cost source for every selected task. Version 2 therefore keeps the non-nearest count informational in DCS and requires that capability in the controlled static Lua test instead.

No Mission Editor geometry change is required.
