# Kandahar UAV controlled spawn — runtime PASS

Date: 2026-08-02

Status: `RUNTIME_ACCEPTED`

Branch:

```text
agent/kandahar-airwing-baseline-contract
```

DCS runtime:

```text
DCS 2.9.28.26385
Terrain revision 27850
```

Evidence supplied by the project owner:

```text
dcs(113).log
size: 583744 bytes
SHA-256: 7a396dc5f7fb384190bc69187cbda9944bf52ee1965feeb8e48df6fefa5133af

debrief(66).log
size: 561191 bytes
SHA-256: 0a67bb535e3952865b1308566f1b0c82218b26d9d595ecb38cbc623355baedf7
```

## Accepted runtime sequence

Registration preflight:

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
clientReservations=10
statics=47
safeParking=true
```

Filtered UAV parking contract:

```text
MQ-1 available labels: G01,G04,G05,G06,G07,G08
MQ-1 TerminalIDs: 46,129,143,189,224,291
MQ-1 unavailable labels: G02,G03

MQ-9 available labels: G09,G10,G11
MQ-9 TerminalIDs: 27,54,263
MQ-9 unavailable labels: none

RESULT: PASS
separatePools=true
staticFiltered=true
clientFiltered=true
noFallback=true
```

Registered warehouse asset synchronization:

```text
MQ-1 asset groups synchronized: 4
MQ-9 asset groups synchronized: 2
registeredAssetsSynchronized=true
RESULT: PASS
```

## Physical controlled spawn results

MQ-1 / RQ-1A Predator:

```text
group: SQ_US_KAF_MQ1_361_ERS_AID-27
asset groups: 1
units: 1
TerminalID: 291
TerminalType: 104
nodeDistance: 1.77 m
inSquadronPool=true
mainAllowed=true
blocked=false
alive=true
airborne=false
allOnGround=true
CASE_RESULT: PASS
```

MQ-9 Reaper:

```text
group: SQ_US_KAF_MQ9_361_ERS_AID-31
asset groups: 1
units: 1
TerminalID: 263
TerminalType: 104
nodeDistance: 1.77 m
inSquadronPool=true
mainAllowed=true
blocked=false
alive=true
airborne=false
allOnGround=true
CASE_RESULT: PASS
```

Final controlled-spawn result:

```text
RESULT: PASS
cases=2
passed=2
failed=0
assetGroups=2
units=2
mq1TerminalID=291
mq9TerminalID=263
separatePools=true
cold=true
uncontrolled=true
mainAirwingStarted=true
heliportAirwingStopped=true
noFallback=true
noAUFTRAG=true
noTransport=true
noPayloadMutation=true
noTaxi=true
noTakeoff=true
```

## Debrief cross-check

The debrief event table contains:

```text
50 x group change option
1 x mission start
1 x took control
1 x under control
1 x mission end
```

It contains no engine-start, taxi, takeoff, landing, crash or dead event for the two test UAVs. The graveyard is empty.

## Non-blocking runtime messages

The following messages did not invalidate the controlled-spawn acceptance:

```text
EVENTMETA warning for DCS event ID 61
AIRWING ReturnPayloadFromAsset: asset had no payload attached
bhHook.lua shutdown error: tcp is nil
```

The two payload messages occurred after the deliberately payloadless warehouse self-requests. The `bhHook.lua` error occurred during DCS shutdown and is external to the Kandahar AIRWING test.

## Accepted boundary

This result accepts only:

```text
initial controlled cold spawn
correct type-specific G-apron allocation
static/client filtering
registered asset parking synchronization
no unrestricted Main-airfield fallback
```

This result does not accept:

```text
engine start
taxi-out
takeoff
mission execution
landing
taxi-in
final post-landing parking
warehouse return after landing
```

Landing and final parking remain a separate runtime acceptance increment.
