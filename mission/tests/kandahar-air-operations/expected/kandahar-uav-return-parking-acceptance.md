# Kandahar UAV return and final-parking acceptance

Status: `PREPARED_NOT_RUNTIME_ACCEPTED`

## Purpose

Validate the first complete MOOSE-managed flight cycle for the two Kandahar UAV types:

```text
MQ-1 / RQ-1A Predator
MQ-9 Reaper
```

The test uses `AIRWING`, `SQUADRON`, approved operational payload templates and two `AUFTRAG:NewORBIT()` missions. It observes rather than overrides the post-landing parking choice.

## Binding parking pools

```text
MQ-1: available positions from G01-G08
MQ-9: available positions from G09-G11
```

The fixed runtime mapping remains:

```text
G01 -> 189
G02 -> 303
G03 -> 202
G04 -> 224
G05 -> 46
G06 -> 291
G07 -> 129
G08 -> 143

G09 -> 27
G10 -> 54
G11 -> 263
```

Statics, clients and the Main-airfield parking blacklist remove positions from the applicable pool at runtime. There is no unrestricted Kandahar Main fallback.

## Included stages

The generated bundle contains:

```text
05  registration preflight
06  Main/Heliport parking contract
10  fixed UAV type-specific parking contract
10b registered UAV asset parking synchronization
12  UAV return and final-parking test
```

The previously accepted cold controlled-spawn test is not run in parallel.

## MOOSE-first mission model

For each UAV type, the test:

1. adds `AUFTRAG.Type.ORBIT` capability to the approved SQUADRON;
2. registers an unlimited test payload from the approved operational template;
3. creates one `AUFTRAG:NewORBIT()` mission;
4. constrains the mission to the exact SQUADRON and payload;
5. requires exactly one asset group;
6. runs the orbit for 180 seconds;
7. allows MOOSE to command RTB, landing and taxi-in;
8. validates the final parking event against the type-specific runtime pool.

The MQ-9 mission is queued 45 seconds after the MQ-1 mission.

## Required baseline results

```text
[OMW][AirOps.KAF.RegistrationPreflight] RESULT: PASS
[OMW][AirOps.KAF.ParkingContract] RESULT: PASS
[OMW][AirOps.KAF.UAVParkingContract] RESULT: PASS
[OMW][AirOps.KAF.UAVAssetParkingSync] RESULT: PASS
```

The Heliport AIRWING must remain stopped.

## Required per-case event chain

For both `MQ1` and `MQ9`:

```text
MISSION_QUEUED
FLIGHT_ASSIGNED
ENGINE_ON
TAXI_OUT
TAKEOFF ... airbaseID=7
AIRBORNE
LANDED ... airbaseID=7
TAXI_IN and/or post-landing parking event
FINAL_PARKING_CHECK ... inTypePool=true mainAllowed=true blocked=false
FINAL_PARKED
ARRIVED ... airbaseID=7 finalParking=true
```

Initial parking events before takeoff are informational only and must not satisfy final-parking acceptance.

## Required final result

```text
[OMW][AirOps.KAF.UAVReturnParking] RESULT: PASS
cases=2
passed=2
failed=0
mq1FinalTerminalID=<available G01-G08 TerminalID>
mq1Pool=G01-G08
mq9FinalTerminalID=<available G09-G11 TerminalID>
mq9Pool=G09-G11
engineStart=true
taxiOut=true
takeoff=true
airborne=true
orbit=true
rtb=true
landing=true
taxiIn=true
finalParking=true
separatePools=true
noFallback=true
mainAirwingStarted=true
heliportAirwingStopped=true
auftrag=true
payloadsFromApprovedTemplates=true
despawnAfterLanding=false
warehouseReturnNotClaimed=true
```

## Failure conditions

The test fails if any of the following occurs:

- either mission recruits the wrong SQUADRON or aircraft type;
- either UAV fails to start, taxi, take off or become airborne;
- either UAV fails to return and land at Kandahar Main / airbase ID 7;
- MQ-1 finishes outside its currently available G01-G08 pool;
- MQ-9 finishes outside its currently available G09-G11 pool;
- a final parking position is blocked or absent from the Main allowlist;
- an aircraft is dead or destroyed;
- the Heliport AIRWING starts;
- no final `ElementArrived` event is observed;
- the 2400-second overall timeout expires.

## Deliberate boundary

This increment does not accept warehouse stock restoration after arrival. `SetDespawnAfterLanding(false)` is used so final taxi-in and parking can be observed before any later cleanup or stock-return test.

Therefore:

```text
spawn contract: already accepted
full flight and final parking: tested here
warehouse asset return/reconciliation: separate later increment
```

## Mission preparation

Keep the normal production statics in place. Do not restore any calibration marker groups.

Load only:

```text
OMW_AirOps_Kandahar_UAV_Return_Parking.lua
```

after MOOSE. Do not load the controlled-spawn, calibration or parking-matrix bundles in parallel.

## Runtime and evidence

Run the mission until the final `RESULT` line appears. The hard timeout is 2400 seconds after the test begins, so reserve up to approximately 41 minutes after mission start.

Return the current:

```text
dcs.log
debrief.log
```
