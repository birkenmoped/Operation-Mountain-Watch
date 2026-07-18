# TM02W2E reserved task execution acceptance

## Status

```text
IMPLEMENTED LUA
STATIC LUA VALIDATION PENDING
DCS VALIDATION PENDING
```

TM02W2E consumes the exact seven tasks produced by the accepted TM02W2 planner. It does not replan.

## Mission Editor

Copy `OMW_TEST_TM02W2_RED_SOURCE_COST_SELECTION.miz` and save it as:

```text
OMW_TEST_TM02W2E_RED_TASK_EXECUTION.miz
```

Keep all eleven RED zones, both BLUE objective zones and the ten Late-Activation RED strength templates unchanged. Add no route groups and no route waypoints.

Replace the previous W2 script action with:

```text
1. DO SCRIPT FILE -> vendor/moose/Moose.lua
2. DO SCRIPT FILE -> mission/tests/tm02-red-network/dist/TM02W2E.lua
```

## Execution model

For each accepted task:

1. commit the reserved strength from the source inventory;
2. spawn one leader proxy in the source zone;
3. move the proxy along every node-to-node leg in the planner path;
4. replace the proxy at the target with the full physical group;
5. credit the target inventory and release its inbound reservation.

Limits:

```text
maxActiveTasks=4
maxActiveOutboundPerSource=1
proxyTestSpeedKph=120
formation=Off Road
```

The speed is a technical test acceleration for the geographically large fixture, not a production infantry rate. DCS time acceleration may be used.

## Build

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch
git fetch origin
git switch feature/tm02w2-red-task-execution
git pull --ff-only
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\build-tm02w2e-bundle.ps1
```

Generated file:

```text
mission/tests/tm02-red-network/dist/TM02W2E.lua
```

Reselect the rebuilt Lua file in the Mission Editor and save the mission because DCS embeds script files in the `.miz`.

## F10 menu

```text
F10 Other
└── OMW Tests
    └── TM02W2E RED Task Execution
        ├── Start reserved task execution
        ├── Show execution status
        ├── List task states in log
        └── Toggle task markers
```

Execution starts only through the F10 command.

## Mandatory validation

```text
event=red_task_execution_validation
configurationVersion=TM02W2E-red-reserved-task-execution-1
configurationValid=true
missionFileName=OMW_TEST_TM02W2E_RED_TASK_EXECUTION.miz
taskCount=7
totalInitialPersonnel=108
reservedInbound=18
reservedOutbound=18
maxActiveTasks=4
maxActiveOutboundPerSource=1
launchSlotCount=6
proxyTestSpeedKph=120
errorCount=0
```

Required runtime evidence:

```text
7 x event=red_task_proxy_started
one red_task_leg_started and red_task_leg_arrived pair per planned leg
7 x event=red_task_physical_materialized
7 x event=red_task_arrived
```

At least one follow-on task must start after an earlier task releases capacity.

## Accounting

At all times:

```text
currentPersonnel + inTransitPersonnel + totalLosses = 108
```

The final actual inventory at every site must match the planner projection captured before movement.

Mandatory completion:

```text
event=red_task_execution_completed
configurationVersion=TM02W2E-red-reserved-task-execution-1
missionFileName=OMW_TEST_TM02W2E_RED_TASK_EXECUTION.miz
taskCount=7
arrivedTaskCount=7
destroyedTaskCount=0
failedTaskCount=0
currentPersonnel=108
inTransitPersonnel=0
totalLosses=0
accountedPersonnel=108
totalInitialPersonnel=108
accountingValid=true
remainingReservedInbound=0
remainingReservedOutbound=0
expectedInventoryMatch=true
executionComplete=true
```

## PASS

TM02W2E passes when all seven independent task proxies traverse their configured paths, all seven full groups materialize at their targets, concurrency limits are respected, every reservation is consumed once, the final inventory matches the accepted plan, accounting remains 108, and no `[OMW][TM02W2E] level=ERROR` line appears.

Delayed reports, order budgets and commander knowledge remain TM02W3 scope.
