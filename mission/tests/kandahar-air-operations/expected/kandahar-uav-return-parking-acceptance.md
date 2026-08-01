# Kandahar UAV return and final-parking acceptance

Status: `V2_PREPARED_NOT_RUNTIME_ACCEPTED`

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
05   registration preflight
06   Main/Heliport parking contract
10   fixed UAV type-specific parking contract
10b  registered UAV asset parking synchronization
12   UAV return and final-parking test
12b  MOOSE no-despawn compatibility policy
```

The previously accepted cold controlled-spawn test is not run in parallel.

## V1 runtime failure and root cause

The first return-parking run successfully completed both ORBIT missions and both UAVs landed at Kandahar. Both groups were then removed immediately after the landing event, so no taxi-in, final parking or arrival event could be accepted.

The cause was the public MOOSE call:

```lua
AIRWING:SetDespawnAfterLanding(false)
```

In the embedded AIRWING v0.9.7 and SQUADRON v0.8.1 implementations, a false or omitted argument enters the `else` branch and sets `despawnAfterLanding=true`. Therefore the apparent disable call actually enabled immediate post-landing despawn.

V2 does not use that public false call as proof of a disabled policy. Source `12b` explicitly clears the instance state on:

```text
AW_US_KAF_451_AEW
SQ_US_KAF_MQ1_361_ERS
SQ_US_KAF_MQ9_361_ERS
every assigned UAV FLIGHTGROUP
```

No global MOOSE class or method is modified.

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
[OMW][AirOps.KAF.UAVNoDespawnPolicy] RESULT: PASS
```

The no-despawn line must contain:

```text
airwing=false
mq1Squadron=false
mq9Squadron=false
flightPolicyWrapped=true
publicFalseSetterUsed=false
```

For each assigned flight, the log must contain:

```text
FLIGHT_POLICY_APPLIED ... despawnAfterLanding=false ok=true
```

The Heliport AIRWING must remain stopped.

## Required per-case event chain

For both `MQ1` and `MQ9`:

```text
MISSION_QUEUED
FLIGHT_ASSIGNED
FLIGHT_POLICY_APPLIED ... despawnAfterLanding=false
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

- the no-despawn compatibility policy does not pass before flight assignment;
- the AIRWING, either UAV SQUADRON or an assigned UAV FLIGHTGROUP has `despawnAfterLanding=true`;
- either mission recruits the wrong SQUADRON or aircraft type;
- either UAV fails to start, taxi, take off or become airborne;
- either UAV fails to return and land at Kandahar Main / airbase ID 7;
- an aircraft disappears after touchdown before taxi-in and final parking;
- MQ-1 finishes outside its currently available G01-G08 pool;
- MQ-9 finishes outside its currently available G09-G11 pool;
- a final parking position is blocked or absent from the Main allowlist;
- an aircraft is dead or destroyed;
- the Heliport AIRWING starts;
- no final `ElementArrived` event is observed;
- the 2400-second overall timeout expires.

## Deliberate boundary

This increment does not accept warehouse stock restoration after arrival. The aircraft must remain physically present through taxi-in and the final parking/arrival events before any later cleanup or stock-return test.

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

Run the mission beyond both touchdown events until the final `RESULT` line appears. A landing event alone is not acceptance. The hard timeout is 2400 seconds after the test begins, so reserve up to approximately 41 minutes after mission start.

Return the current:

```text
dcs.log
debrief.log
```
