# Kandahar UAV controlled spawn — controlled failure

Status: `FAIL_ROOT_CAUSE_IDENTIFIED_CORRECTION_COMMITTED_RETEST_REQUIRED`

## Evidence

```text
dcs(112).log
Size: 4,869,725 bytes
SHA-256: 6a193cea1e21285a16ca20eeae1f880ac646121c2993a5e59ff7fb99672af169

debrief(65).log
Size: 562,039 bytes
SHA-256: b4ed302c581bcee0f91ba6c9771dfe46c9ff79bdb5f5e8f2a5b5d3d8dc179b2a
```

Authoritative current run:

```text
2026-08-01 22:32:31Z through 22:33:08Z
DCS 2.9.28.26385
```

The DCS log is cumulative. Older Kandahar test entries are not authoritative for this result.

## Passed prerequisites

Registration:

```text
RESULT: PASS
airwings=2
squadrons=9
registeredAirframes=112
deferredMC12=6
```

Main/Heliport parking contract:

```text
RESULT: PASS
mainTotal=316
mainAllowed=302
mainBlocked=14
heliportTotal=86
heliportAllowed=59
heliportBlocked=27
```

Fixed UAV pool evaluation:

```text
RESULT: PASS

MQ-1 available labels:
G01,G04,G05,G06,G07,G08

MQ-1 available TerminalIDs:
46,129,143,189,224,291

MQ-1 unavailable because of restored statics:
G02 -> TerminalID 303
G03 -> TerminalID 202

MQ-9 available labels:
G09,G10,G11

MQ-9 available TerminalIDs:
27,54,263
```

The static/client filtering and the accepted G-apron mapping were correct.

## Controlled spawn failure

MQ-1:

```text
Group: SQ_US_KAF_MQ1_361_ERS_AID-27
Type: RQ-1A Predator
TerminalID: 317
Node distance: 1.76 m
Main allowlist: true
Blocked: false
SQUADRON pool: false
CASE_RESULT: FAIL
```

MQ-9:

```text
Group: SQ_US_KAF_MQ9_361_ERS_AID-31
Type: MQ-9 Reaper
TerminalID: 281
Node distance: 1.76 m
Main allowlist: true
Blocked: false
SQUADRON pool: false
CASE_RESULT: FAIL
```

Final result:

```text
RESULT: FAIL
cases=2
passed=0
failed=2
violations=2
mq1TerminalID=317
mq9TerminalID=281
```

Both aircraft were alive, on the ground and not airborne. No taxi, takeoff, route, AUFTRAG or OPSTRANSPORT was introduced.

The debrief records the two generated warehouse group hold flags and an empty graveyard. It does not contain a takeoff or combat sequence for either UAV.

## Root cause

The first implementation called:

```lua
squadron:SetParkingIDs(filteredTerminalIDs)
```

after the SQUADRON assets had already been registered in the AIRWING warehouse.

MOOSE source behavior at the pinned develop source used for verification:

```text
FlightControl-Master/MOOSE
commit dfe4db25ae05c2b40e3bfbb287d377c8775da217
Moose Development/Moose/Ops/Legion.lua
```

During `LEGION:onafterNewAsset`, MOOSE performs:

```lua
asset.parkingIDs = cohort.parkingIDs
```

The warehouse parking validator later evaluates the registered asset field:

```lua
WAREHOUSE:_CheckParkingAsset(spot, asset)
asset.parkingIDs
```

Consequently, changing only `squadron.parkingIDs` after registration did not update the six existing UAV warehouse asset records. Their `asset.parkingIDs` remained unrestricted, so the allocator legitimately selected broad Main AIRWING positions 317 and 281.

The test therefore exposed a registration-order synchronization defect in the Kandahar implementation. It did not invalidate the calibrated TerminalIDs.

## Correction

Added:

```text
mission/tests/kandahar-air-operations/src/
10b-kandahar-uav-registered-asset-parking-sync.lua
```

The correction runs after the filtered UAV contract and before the Main AIRWING starts. It:

1. verifies the SQUADRON-level filtered IDs;
2. synchronizes those IDs to every already registered UAV `asset.parkingIDs` record;
3. requires exactly four MQ-1 asset groups and two MQ-9 asset groups;
4. fails closed by invalidating the UAV contract if synchronization fails;
5. performs no start, spawn, mission, transport, payload, taxi or takeoff action.

Builder updated to:

```text
KAF-UAV-CONTROLLED-SPAWN-2
```

## Acceptance status

```text
G-apron calibration: PASS
Static/client filtering: PASS
SQUADRON-level fixed pool: PASS
First controlled physical spawn: FAIL
Root cause: IDENTIFIED
Correction: COMMITTED
Corrected controlled spawn: RETEST REQUIRED
Landing/taxi-in/final parking: NOT TESTED
Operational UAV activation: BLOCKED
```
