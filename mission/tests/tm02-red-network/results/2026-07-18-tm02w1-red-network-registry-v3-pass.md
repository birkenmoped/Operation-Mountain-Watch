# TM02W1 RED Network Registry v3 – DCS PASS

## Test identification

```text
Mission: OMW_TEST_TM02W1_RED_NETWORK_REGISTRY.miz
Configuration: TM02W1-red-network-command-movement-3
Bundle build timestamp: 2026-07-18T14:10:04Z
DCS: 2.9.27.25340 MT
Terrain: Afghanistan
Test date: 2026-07-18
```

## Result

```text
TM02W1 PASS
configurationValid=true
errorCount=0
warningCount=0
```

## Registry

```text
redLocationCount=11
headquartersCount=1
subHeadquartersCount=2
ordinarySiteCount=8
activeNodeCount=3
nodeAreaCount=0
```

Only the main HQ and both sub-HQs had active nodes. The eight ordinary sites remained available and unoccupied.

## Command graph

```text
commandAreaCount=3
commandLinkCount=10
commandReachableFromHqCount=11
commandAcyclic=true
```

All RED locations were reachable from the main HQ through the command hierarchy. The command graph contained no cycle.

## Movement graph

```text
movementLinkCount=17
movementComponentCount=1
movementReachableFromHqCount=11
movementHasCycle=true
movementCrossAreaLinkCount=5
```

The physical movement graph formed one connected component, contained alternative paths and included cross-area links independent of command ownership.

## BLUE objectives

```text
objectiveCount=2
objectiveAssociationCount=4
```

Both BLUE objectives were registered with two associated RED sites each. Objective associations did not create command or movement links.

## Event counts

```text
11 x event=red_network_location_registered
10 x event=red_command_link_registered
17 x event=red_movement_link_registered
 2 x event=blue_objective_registered
```

## Scope confirmation

No personnel group was activated, generated or moved. No source selection, cost calculation, proxy lifecycle or commander decision was executed. TM02W1 therefore remained a pure registry and graph-validation stage.

## Notes

The same DCS log also contained an earlier run of the superseded seven-location configuration `TM02W1-red-network-registry-2`. That run is not part of this acceptance. The accepted run is uniquely identified by `TM02W1-red-network-command-movement-3` and the counts documented above.

A mission-exit error in `Saved Games/DCS.openbeta/Scripts/Hooks/bhHook.lua` occurred after the W1 validation had completed. It was unrelated to TM02W1.

## Acceptance

```text
TM02W1 RED Network Registry v3: PASS
```

TM02W1 is complete and may be used as the base for TM02W2. This result does not authorize merging any pull request.
