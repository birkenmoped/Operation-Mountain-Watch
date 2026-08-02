# Kandahar normalized AirOps foundation smoke test V2

Status: `PASS`

Date: `2026-08-02`

## Runtime artifacts

```text
dcs(119).log
Size: 2,487,128 bytes
SHA-256: d6f0e7049e233123a205ef454f30a8d97346efe9aaf1ecf9df0e5fa27a6b8839

debrief(72).log
Size: 556,862 bytes
SHA-256: eb4a078f4b5cbf0defff5daf4504631fec5c5e75cac31aef4a78f0829587a40c
```

DCS runtime:

```text
DCS 2.9.28.26385
Application revision 266385
Renderer revision 26305
Terrain revision 27850
Afghanistan terrain revision 7067
Build number 541
```

## Authoritative V2 run

The cumulative `dcs.log` also contains the earlier V1 assembly failure at `2026-08-02 00:03:23`. That historical entry is not the result of this retest.

The authoritative V2 run begins with the Kandahar registration phase at `2026-08-02 00:12:35` and reaches the normalized foundation result at `00:12:59`.

## Registration result

```text
[OMW][AirOps.KAF.RegistrationPreflight] RESULT: PASS

airwings=2
squadrons=9
registeredAirframes=112
deferredMC12=6
noStart=true
noSpawn=true
noMission=true
noTransport=true
noPayloadMutation=true
noParkingMutation=true
```

## General parking result

```text
[OMW][AirOps.KAF.ParkingContract] RESULT: PASS

airwings=2
mainTotal=316
mainAllowed=302
mainBlocked=14
heliportTotal=86
heliportAllowed=59
heliportBlocked=27
clientReservations=10
statics=47
safeParking=true
noStart=true
noSpawn=true
noMission=true
noTransport=true
noPayloadMutation=true
```

The Main result reflects the restored production statics. MQ-1 G02/terminal 303 and G03/terminal 202 are occupied by the two MQ-1 statics and therefore excluded dynamically.

## UAV initial-spawn parking result

```text
[OMW][AirOps.KAF.UAVParkingContract] RESULT: PASS

MQ-1 labels: G01-G08
available labels: G01,G04,G05,G06,G07,G08
available terminal IDs: 46,129,143,189,224,291
unavailable labels: G02,G03

MQ-9 labels: G09-G11
available labels: G09,G10,G11
available terminal IDs: 27,54,263
unavailable labels: none

separatePools=true
staticFiltered=true
clientFiltered=true
noFallback=true
mq1Restricted=true
mq9Restricted=true
```

## Registered Warehouse asset synchronization

```text
[OMW][AirOps.KAF.UAVAssetParkingSync] RESULT: PASS

mq1Assets=4
mq1TerminalIDs=46,129,143,189,224,291
mq9Assets=2
mq9TerminalIDs=27,54,263
registeredAssetsSynchronized=true
noStart=true
noSpawn=true
noMission=true
noTransport=true
noPayloadMutation=true
```

## Normalized foundation result

```text
[OMW][AirOps.KAF.Foundation] RESULT: READY

airwings=2
squadrons=9
registeredAirframes=112
deferredMC12=6
mainRunning=true
heliportRunning=true
missionsCreated=0
payloadsRegistered=0
commanderAttached=false
transportCreated=false
directSpawnRequested=false
uavInitialSpawnRestricted=true
uavFinalParkingRestricted=false
```

Explicit runtime bindings:

```text
Main:
AW_US_KAF_451_AEW
Kandahar
Airbase ID 7

Heliport:
AW_US_KAF_159_CAB_TF_THUNDER
Kandahar Heliport
Airbase ID 15
```

## No-tasking and no-spawn evidence

The debrief covers `120.785` seconds. The player controlled the existing Mission Editor client `CLIENT_US_KAF_CH47F_02_UNIT_01`.

The debrief contains:

```text
graveyard = {}
no Birth event
no SQ_US_KAF dynamic group or unit name
```

The RQ-1A Predator and MQ-9 Reaper strings in `world_state` describe existing Mission Editor templates/statics and are not dynamic birth events.

No Kandahar mission, payload, transport, commander or direct-spawn request was created by the normalized foundation.

## Unrelated shutdown entry

After mission stop, the external Saved Games hook reports:

```text
bhHook.lua:168: attempt to index upvalue 'tcp' (a nil value)
```

This occurs after the accepted Kandahar result and is outside the OMW mission bundle.

## Acceptance decision

```text
Normalized OMW_AIROPS_KANDAHAR foundation: ACCEPTED
AIRWING foundation: ACCEPTED
SQUADRON foundation: ACCEPTED
General parking contract: ACCEPTED
UAV type-specific initial-spawn parking: ACCEPTED
No-tasking/no-spawn behavior: ACCEPTED
```

Still not accepted and explicitly outside this foundation:

```text
UAV type-specific final stand after landing
Warehouse stock return/reconciliation after landing
tactical AUFTRAG profiles
payload catalogue
OPSTRANSPORT
COMMANDER integration
persistent loss/recovery state
MC-12 physical representation
```
