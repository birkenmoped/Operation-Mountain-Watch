# TM02W2E road transit and watchdog acceptance

## Status

```text
VERSION 1 DCS FAIL RECORDED
VERSION 2 LUA IMPLEMENTED
STATIC LUA VALIDATION PENDING IN GITHUB ACTIONS
DCS VALIDATION PENDING
```

TM02W2E version 2 keeps the accepted seven-task TM02W2 plan and changes only the physical navigation layer.

## Failure corrected by version 2

The first DCS execution used direct ground routing between node zones. One proxy passed the BLUE FOB and entered combat. The other active proxies became trapped in buildings or courtyards and made no useful progress. No task arrived.

Version 2 therefore requires:

- MOOSE road portals generated with `COORDINATE:GetClosestPointToRoad()`;
- MOOSE road paths generated with `COORDINATE:GetPathOnRoad()`;
- hard exclusion of road edges crossing either BLUE objective zone plus its configured buffer;
- MOOSE `ASTAR` selection of a safe logical node path;
- explicit `On Road` ground waypoints compiled from the validated MOOSE road path;
- MOOSE `ARMYGROUP:IsEngaging()` and hit tracking to suppress recovery during combat;
- a movement watchdog for stationary or circular pathfinding failures;
- route reissue before any relocation;
- relocation only along the validated road path and only for the one-man proxy.

## Mission Editor

Use the existing mission unchanged:

```text
OMW_TEST_TM02W2E_RED_TASK_EXECUTION.miz
```

Keep all eleven RED zones, both BLUE objective zones and all ten Late-Activation RED strength templates unchanged. Add no route groups and no route waypoints.

Mission-start actions:

```text
1. DO SCRIPT FILE -> vendor/moose/Moose.lua
2. DO SCRIPT FILE -> mission/tests/tm02-red-network/dist/TM02W2E.lua
```

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

Reselect the rebuilt file in the Mission Editor and save the mission because DCS embeds script files in the `.miz`.

## Version 2 configuration

```text
configurationVersion=TM02W2E-red-road-transit-watchdog-2
maxActiveTasks=4
maxActiveOutboundPerSource=1
proxyTestSpeedKph=120
roadFormation=On Road
blueObjectiveBufferMeters=250
maximumRoadSnapMeters=1500
routeWaypointSpacingMeters=100
portalArrivalRadiusMeters=100
watchdogIntervalSeconds=5
stuckWindowSeconds=30
combatCooldownSeconds=90
maxRecoveryAttempts=4
```

The proxy speed is technical test acceleration, not doctrinal infantry speed.

## Mandatory bootstrap evidence

```text
event=navigation_validation valid=true errorCount=0 portalCount=11 exclusionCount=2 movementEdgeCount=17
17 x event=road_edge_compiled
7 x event=safe_task_path_selected
event=red_task_execution_validation
configurationVersion=TM02W2E-red-road-transit-watchdog-2
configurationValid=true
taskCount=7
totalInitialPersonnel=108
reservedInbound=18
reservedOutbound=18
errorCount=0
```

A movement edge whose MOOSE road path crosses a BLUE exclusion zone must be logged with `safe=false`. Every planner task must still receive a safe ASTAR path. If no safe path exists, execution must fail closed before a proxy starts.

## Runtime and watchdog evidence

Required normal execution:

```text
7 x event=red_task_proxy_started
one red_task_leg_started and red_task_leg_arrived pair per selected logical leg
7 x event=red_task_physical_materialized
7 x event=red_task_arrived
```

Watchdog samples are logged as:

```text
event=watchdog_sample
stationary=true|false
circular=true|false
recoveryCount=<n>
```

Recovery rules:

1. First technical stall: rebuild and reassign the MOOSE road route from the current position.
2. Further technical stalls: replace only the one-man proxy 20, 40, then 60 metres farther along the validated road path.
3. During MOOSE engagement state or the 90-second hit cooldown: no route repair and no relocation.
4. After the configured maximum: stop with `navigation_blocked`; never loop indefinitely.

A firefight, hit or MOOSE engagement state must never produce `proxy_relocated_on_road` during its combat cooldown.

## Accounting and completion

At all times:

```text
currentPersonnel + inTransitPersonnel + totalLosses = 108
```

Mandatory completion:

```text
event=red_task_execution_completed
configurationVersion=TM02W2E-red-road-transit-watchdog-2
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

TM02W2E version 2 passes only when all seven accepted tasks arrive through safe MOOSE-derived road paths, no proxy traverses a BLUE exclusion zone, technical stalls are either recovered or fail closed, combat never triggers relocation, final inventories match the planner projection, accounting remains 108, and no `[OMW][TM02W2E] level=ERROR` or `[OMW][TM02W2E][NAV] level=ERROR` line appears.

Delayed intelligence, dynamically discovered enemy threat zones and bounded commander knowledge remain TM02W3 scope.
