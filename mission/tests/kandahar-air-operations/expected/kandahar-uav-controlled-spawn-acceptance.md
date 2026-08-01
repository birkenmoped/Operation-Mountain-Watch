# Kandahar UAV controlled spawn – acceptance

Status: `PREPARED_NOT_RUNTIME_ACCEPTED`

## Purpose

Validate the fixed, SQUADRON-specific Kandahar UAV parking contract after removal of the eleven calibration marker groups and restoration of the normal aircraft statics.

The test performs one mission run with:

```text
1 x MQ-1 / RQ-1A Predator asset group
1 x MQ-9 Reaper asset group
```

Both aircraft remain cold and uncontrolled. The test starts only the Kandahar Main AIRWING.

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

At runtime, each list is intersected with the accepted Kandahar Main AIRWING allowlist. A position occupied by a restored aircraft static or protected client is excluded. There is no fallback to unrestricted Main-airfield parking.

At least one available TerminalID must remain in each pool.

## Mission preparation

Remove all calibration-only groups:

```text
CAL_AIR_US_KAF_UAV_G01
CAL_AIR_US_KAF_UAV_G02
CAL_AIR_US_KAF_UAV_G03
CAL_AIR_US_KAF_UAV_G04
CAL_AIR_US_KAF_UAV_G05
CAL_AIR_US_KAF_UAV_G06
CAL_AIR_US_KAF_UAV_G07
CAL_AIR_US_KAF_UAV_G08
CAL_AIR_US_KAF_UAV_G09
CAL_AIR_US_KAF_UAV_G10
CAL_AIR_US_KAF_UAV_G11
```

Restore the normal aircraft statics to their intended production positions before running this test.

Retain the operational templates:

```text
TPL_AIR_US_KAF_MQ1A_RECON_1SHIP
TPL_AIR_US_KAF_MQ9_RECON_1SHIP
```

## Build

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch

git switch agent/kandahar-airwing-baseline-contract
git pull --ff-only origin agent/kandahar-airwing-baseline-contract

powershell -ExecutionPolicy Bypass -File `
  .\tools\build-kandahar-uav-controlled-spawn.ps1
```

Generated bundle:

```text
mission\tests\kandahar-air-operations\dist\
OMW_AirOps_Kandahar_UAV_Controlled_Spawn.lua
```

Load only this Kandahar test bundle after MOOSE. It already includes:

```text
05 - registration preflight
06 - Main/Heliport parking contract
10 - fixed UAV parking contract
11 - controlled UAV spawn test
```

Do not load the calibration, general controlled-spawn, or parking-matrix bundles in parallel.

## Required log sequence

The baseline preflights must pass:

```text
[OMW][AirOps.KAF.RegistrationPreflight] RESULT: PASS
[OMW][AirOps.KAF.ParkingContract] RESULT: PASS
```

The fixed UAV contract must report separate filtered pools:

```text
[OMW][AirOps.KAF.UAVParkingContract] RESULT: PASS ... separatePools=true staticFiltered=true clientFiltered=true noFallback=true mq1Restricted=true mq9Restricted=true
```

The controlled test must then report:

```text
REQUEST_ISSUED index=1 case=MQ1 ...
SELF_REQUEST_FULFILLED index=1 case=MQ1 ...
GROUP_SPAWNED case=MQ1 ... alive=true airborne=false allOnGround=true
UNIT_PARKED case=MQ1 ... inSquadronPool=true mainAllowed=true blocked=false
CASE_RESULT: PASS index=1 case=MQ1 ...

REQUEST_ISSUED index=2 case=MQ9 ...
SELF_REQUEST_FULFILLED index=2 case=MQ9 ...
GROUP_SPAWNED case=MQ9 ... alive=true airborne=false allOnGround=true
UNIT_PARKED case=MQ9 ... inSquadronPool=true mainAllowed=true blocked=false
CASE_RESULT: PASS index=2 case=MQ9 ...
```

## Required final result

```text
[OMW][AirOps.KAF.UAVControlledSpawn] RESULT: PASS cases=2 passed=2 failed=0 assetGroups=2 units=2 mq1TerminalID=<one available G01-G08 ID> mq1Pool=G01-G08 mq9TerminalID=<one available G09-G11 ID> mq9Pool=G09-G11 separatePools=true cold=true uncontrolled=true mainAirwingStarted=true heliportAirwingStopped=true noFallback=true noAUFTRAG=true noTransport=true noPayloadMutation=true noTaxi=true noTakeoff=true
```

## Failure conditions

The test fails if:

- MQ-1 appears outside the currently available G01-G08 TerminalIDs;
- MQ-9 appears outside the currently available G09-G11 TerminalIDs;
- a blocked, static-occupied or client-reserved TerminalID is used;
- either UAV uses an unrestricted Main-airfield fallback;
- either group is airborne or not fully on the ground;
- the wrong template or DCS type is delivered;
- more or fewer than one asset group and one unit per case is delivered;
- the Heliport AIRWING starts;
- an AUFTRAG, OPSTRANSPORT, payload mutation, taxi, route, or takeoff command is introduced.

## Runtime duration and evidence

Allow at least 150 seconds after mission start and provide the current:

```text
dcs.log
debrief.log
```

Landing, taxi-in and final post-landing parking remain a separate acceptance increment after the controlled spawn contract passes.
