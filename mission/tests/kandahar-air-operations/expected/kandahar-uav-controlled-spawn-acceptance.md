# Kandahar UAV controlled spawn – acceptance

Status: `RUNTIME_ACCEPTED`

## Accepted scope

This contract validates one controlled cold warehouse self-request for each Kandahar UAV type:

```text
1 x MQ-1 / RQ-1A Predator asset group
1 x MQ-9 Reaper asset group
```

Only the Kandahar Main AIRWING is started. Both groups remain cold, uncontrolled and on the ground. No AUFTRAG, OPSTRANSPORT, payload mutation, taxi command, route or takeoff is created.

Landing, taxi-in and final post-landing parking remain outside this acceptance increment.

## Binding parking pools

MQ-1 / RQ-1A Predator:

```text
G01 -> TerminalID 189
G02 -> TerminalID 303
G03 -> TerminalID 202
G04 -> TerminalID 224
G05 -> TerminalID 46
G06 -> TerminalID 291
G07 -> TerminalID 129
G08 -> TerminalID 143
```

MQ-9 Reaper:

```text
G09 -> TerminalID 27
G10 -> TerminalID 54
G11 -> TerminalID 263
```

Each pool is intersected at runtime with the accepted Kandahar Main AIRWING allowlist. Static-occupied, client-reserved and otherwise blocked positions are removed. There is no unrestricted Main-airfield fallback.

## MOOSE registered-asset synchronization

MOOSE copies `SQUADRON.parkingIDs` to `asset.parkingIDs` during `LEGION:onafterNewAsset`.

Because Kandahar derives the final static/client-filtered UAV pools after registration, the accepted lists must also be synchronized to the already registered warehouse assets before the Main AIRWING starts.

Implemented source:

```text
mission/tests/kandahar-air-operations/src/
10b-kandahar-uav-registered-asset-parking-sync.lua
```

Required synchronization inventory:

```text
MQ-1 registered asset groups: 4
MQ-9 registered asset groups: 2
```

## Accepted runtime evidence

Result artifact:

```text
mission/tests/kandahar-air-operations/results/
2026-08-02-kandahar-uav-controlled-spawn-pass.md
```

Evidence logs:

```text
dcs(113).log
SHA-256: 7a396dc5f7fb384190bc69187cbda9944bf52ee1965feeb8e48df6fefa5133af

debrief(66).log
SHA-256: 0a67bb535e3952865b1308566f1b0c82218b26d9d595ecb38cbc623355baedf7
```

DCS runtime:

```text
2.9.28.26385
Terrain revision 27850
```

## Accepted runtime sequence

Baseline preflights:

```text
[OMW][AirOps.KAF.RegistrationPreflight] RESULT: PASS
[OMW][AirOps.KAF.ParkingContract] RESULT: PASS
```

Filtered UAV contract:

```text
MQ-1 available: G01,G04,G05,G06,G07,G08
MQ-1 TerminalIDs: 46,129,143,189,224,291
MQ-1 unavailable: G02,G03

MQ-9 available: G09,G10,G11
MQ-9 TerminalIDs: 27,54,263
MQ-9 unavailable: none

RESULT: PASS
separatePools=true
staticFiltered=true
clientFiltered=true
noFallback=true
```

Registered asset synchronization:

```text
[OMW][AirOps.KAF.UAVAssetParkingSync]
RESULT: PASS
mq1Assets=4
mq9Assets=2
registeredAssetsSynchronized=true
```

Physical controlled spawns:

```text
MQ-1
TerminalID=291
TerminalType=104
nodeDistance=1.77
inSquadronPool=true
mainAllowed=true
blocked=false
alive=true
airborne=false
allOnGround=true
CASE_RESULT: PASS

MQ-9
TerminalID=263
TerminalType=104
nodeDistance=1.77
inSquadronPool=true
mainAllowed=true
blocked=false
alive=true
airborne=false
allOnGround=true
CASE_RESULT: PASS
```

Final accepted result:

```text
[OMW][AirOps.KAF.UAVControlledSpawn]
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

The debrief contains no engine-start, taxi, takeoff, landing, crash or dead event for the controlled UAV test. The graveyard is empty.

## Non-blocking messages

The following messages are recorded but do not invalidate this acceptance:

```text
EVENTMETA warning for DCS event ID 61
AIRWING ReturnPayloadFromAsset: asset had no payload attached
bhHook.lua shutdown error: tcp is nil
```

The payload messages belong to the deliberately payloadless warehouse self-requests. The `bhHook.lua` error occurs during DCS shutdown and is external to the Kandahar test.

## Failure conditions retained for future regression tests

The controlled-spawn contract fails if:

- synchronization does not cover exactly four MQ-1 and two MQ-9 asset groups;
- any registered UAV asset lacks the current filtered type-specific list;
- MQ-1 spawns outside an available G01-G08 position;
- MQ-9 spawns outside an available G09-G11 position;
- a blocked, static-occupied or client-reserved TerminalID is used;
- either UAV uses unrestricted Main-airfield fallback;
- the wrong template, type, group count or unit count is delivered;
- either group is airborne or not fully on the ground;
- the Heliport AIRWING starts;
- an AUFTRAG, OPSTRANSPORT, payload mutation, taxi, route or takeoff command is introduced.
