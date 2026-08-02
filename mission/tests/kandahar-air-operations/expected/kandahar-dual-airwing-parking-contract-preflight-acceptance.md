# Kandahar Dual-AIRWING Parking Contract Preflight – Acceptance

## Scope

This test extends the validated dual-AIRWING registration preflight with a parking contract only.

It may:

- construct both approved AIRWINGs and nine approved SQUADRONs;
- bind both AIRWINGs explicitly to Kandahar Main and Kandahar Heliport;
- read all native runtime parking nodes;
- reserve the ten validated client TerminalIDs;
- classify all 47 `STATIC_AIR_US_KAF_` aircraft statics by nearest native airbase;
- block native parking-node centres that lie within the configured static clearance radius;
- apply `AIRBASE:SetParkingSpotBlacklist()`;
- apply `AIRWING:SetParkingIDs()`;
- apply `AIRWING:SetSafeParkingOn()`.

It must not:

- start either AIRWING;
- start or spawn any SQUADRON asset;
- create SPAWN, AUFTRAG, OPSTRANSPORT, COMMANDER, or CHIEF objects;
- register payload stock;
- allow AI spawning on client parking;
- create any operational mission.

## Required object baseline

```text
AW_US_KAF_451_AEW
WH_AIR_US_KANDAHAR
AIRBASE.Afghanistan.Kandahar / ID 7

AW_US_KAF_159_CAB_TF_THUNDER
WH_AIR_US_KANDAHAR_HELI
AIRBASE.Afghanistan.Kandahar_Heliport / ID 15
```

The registration stage must first produce:

```text
RESULT: PASS airwings=2 squadrons=9 registeredAirframes=112 deferredMC12=6
```

## Required client reservations

Kandahar Main:

```text
92
282
287
294
```

Kandahar Heliport:

```text
4
19
23
30
47
80
```

Every listed TerminalID must exist on its assigned native airbase and must be present in the final blocked set and absent from the AIRWING allowlist.

## Required static processing

Exactly 47 US aircraft statics with prefix `STATIC_AIR_US_KAF_` must be classified.

For every static, the log must contain:

```text
STATIC_CLASSIFIED name=<name> type=<type> airbaseKey=<Main|Heliport> nearestDistance=<m> clearanceRadius=<m> blockedNodes=<n>
```

`blockedNodes=0` is permitted when the static is not geometrically overlapping a native parking-node centre. Such objects are reported in `staticsWithoutParkingOverlap`; they must not cause an arbitrary nearest-node blacklist entry.

## Required parking contract

Runtime totals must remain:

```text
Kandahar Main: 316
Kandahar Heliport: 86
```

For both airbases:

```text
allowed + blocked = total
allowed intersection blocked = empty
all blocked IDs exist on that airbase
all allowed IDs exist on that airbase
all client reservations are blocked
```

Each blocked TerminalID must be logged with at least one reason:

```text
BLOCKED key=<Main|Heliport> terminalID=<id> reasons=<CLIENT_RESERVED|STATIC:name,...>
```

## Required MOOSE state

For both AIRWINGs:

```text
parkingIDs exactly equals the computed allowed TerminalID set
safeparking == true
IsRunning() == false
```

The log must contain:

```text
CONTRACT_APPLIED key=Main ... safeParking=true running=false
CONTRACT_APPLIED key=Heliport ... safeParking=true running=false
```

## Required final result

```text
[OMW][AirOps.KAF.ParkingContract] RESULT: PASS airwings=2 mainTotal=316 mainAllowed=<n> mainBlocked=<n> heliportTotal=86 heliportAllowed=<n> heliportBlocked=<n> clientReservations=10 statics=47 safeParking=true noStart=true noSpawn=true noMission=true noTransport=true noPayloadMutation=true
```

No line with either of the following may occur for this test:

```text
[OMW][AirOps.KAF.ParkingContract] VIOLATION
[OMW][AirOps.KAF.ParkingContract] RESULT: FAIL
```

## Runtime evidence to return

Return the current:

```text
dcs.log
debrief.log
```

The debrief must contain no aircraft birth caused by this bundle. Logical warehouse asset registration messages are not physical DCS spawns.
