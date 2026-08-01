# Kandahar UAV return and final-parking V2 runtime result

Status: `FAIL_POST_LANDING_PARKING_OUTSIDE_TYPE_POOL`

Date: 2026-08-02 local / 2026-08-01 UTC

## Runtime evidence

```text
dcs(117).log
Size: 1,557,523 bytes
SHA-256: c6e438edacd869ddf127318150a712651a0f141058ca0adbd56b2e54b62a077c

debrief(70).log
Size: 567,313 bytes
SHA-256: 564734f53a732ba897458612513870c32de3dee299be85b0213451353f07e2e8

DCS: 2.9.28.26385
Mission: OMW_Template_v4_Kandahar.miz
```

## Baseline stages

The required preconditions passed:

```text
Kandahar parking contract: PASS
UAV fixed parking contract: PASS
UAV registered-asset parking synchronization: PASS
UAV no-despawn compatibility policy: PASS
```

The no-despawn policy explicitly cleared `despawnAfterLanding` on:

```text
AW_US_KAF_451_AEW
SQ_US_KAF_MQ1_361_ERS
SQ_US_KAF_MQ9_361_ERS
both assigned UAV FLIGHTGROUP instances
```

The immediate post-touchdown despawn from V1 did not recur.

## Full flight cycle

Both assigned UAVs completed:

```text
cold start
taxi-out
takeoff
airborne
AUFTRAG ORBIT
RTB
landing at Kandahar Main / airbase ID 7
post-landing taxi movement
arrival at a parking position
engine shutdown
```

Debrief evidence:

```text
MQ-9 Reaper
  takeoff:         t=333.923
  landing:         t=1637.523
  engine shutdown: t=1989.183

RQ-1A Predator
  takeoff:         t=260.444
  landing:         t=1842.644
  engine shutdown: t=2112.464
```

The elapsed time between landing and engine shutdown confirms that both aircraft remained present and taxied after landing. The MOOSE `ElementArrived` events supplied the final native TerminalIDs.

## Final parking result

### MQ-9

```text
Assigned type pool: G09-G11
Allowed TerminalIDs: 27,54,263
Observed final TerminalID: 81
mainAllowed=true
blocked=false
inTypePool=false
```

### MQ-1

```text
Assigned type pool: G01-G08 after runtime filtering
Allowed TerminalIDs: 46,129,143,189,224,291
Observed final TerminalID: 157
mainAllowed=true
blocked=false
inTypePool=false
```

Final test result:

```text
RESULT: FAIL
cases=2
mq1Ready=false
mq9Ready=false
violations=4
mq1FinalTerminalID=nil
mq9FinalTerminalID=nil
```

Violations:

```text
FINAL_PARKING_OUTSIDE_TYPE_POOL case=MQ9 terminalID=81
FINAL_PARKING_OUTSIDE_TYPE_POOL case=MQ1 terminalID=157
CASE_INCOMPLETE case=MQ9 finalParking=false
CASE_INCOMPLETE case=MQ1 finalParking=false
```

## Technical conclusion

The accepted `SQUADRON:SetParkingIDs()` and synchronized warehouse `asset.parkingIDs` successfully constrain initial spawning. They did not constrain DCS's native post-landing parking selection in this runtime.

MOOSE observed and reported the native parking positions through `ElementArrived`, but no approved MOOSE-first mechanism in the tested implementation assigned either aircraft to a requested final TerminalID after landing.

Therefore:

```text
initial UAV parking contract: PASS
no-despawn correction: PASS
flight, RTB and landing: PASS
post-landing taxi and arrival: PASS
required G-apron final parking: FAIL
warehouse stock return: NOT TESTED
productive UAV activation: BLOCKED
```

## Binding boundary

The project-owner requirement remains unchanged: MQ-1 and MQ-9 may not use arbitrary Kandahar Main stands for return, taxi-in, final parking or storage.

The following are not accepted as silent workarounds:

- accepting TerminalID 81 or 157 merely because they are generally allowed Main-airfield positions;
- re-enabling immediate despawn after touchdown;
- claiming `SQUADRON:SetParkingIDs()` also controls final parking;
- restoring warehouse stock before compliant final parking has been proven;
- inventing or guessing another parking-ID mapping.

A separate design decision and proof are required before another full-cycle acceptance run. The PR remains Draft, open and unmerged.
