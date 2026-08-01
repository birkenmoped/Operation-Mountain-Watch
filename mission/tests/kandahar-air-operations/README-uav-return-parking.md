# Kandahar UAV return and final-parking test

Status: `PREPARED_NOT_RUNTIME_ACCEPTED`

This is the next test after the accepted controlled MQ-1/MQ-9 cold-spawn contract.

## Build

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch

git switch agent/kandahar-airwing-baseline-contract
git pull --ff-only origin agent/kandahar-airwing-baseline-contract

powershell -ExecutionPolicy Bypass -File `
  .\tools\build-kandahar-uav-return-parking.ps1
```

Generated bundle:

```text
mission\tests\kandahar-air-operations\dist\
OMW_AirOps_Kandahar_UAV_Return_Parking.lua
```

Expected builder version:

```text
KAF-UAV-RETURN-PARKING-1
```

## Mission Editor

Keep:

- the approved operational MQ-1 and MQ-9 templates;
- the normal production aircraft statics;
- the Main and Heliport warehouse anchors;
- the current client slots.

Do not restore the eleven `CAL_AIR_US_KAF_UAV_Gxx` calibration groups.

Replace the previous controlled-spawn test file with:

```text
OMW_AirOps_Kandahar_UAV_Return_Parking.lua
```

Load it once after MOOSE. Do not load the calibration, controlled-spawn or general parking-matrix bundles in parallel.

## Runtime behavior

The bundle creates two MOOSE `AUFTRAG:NewORBIT()` missions:

```text
MQ-1: 10,000 ft / 110 kt / 180 seconds
MQ-9: 12,000 ft / 160 kt / 180 seconds
```

The orbit is approximately 8 NM south of Kandahar. The MQ-9 mission is queued 45 seconds after the MQ-1 mission.

Both missions use:

- the exact approved SQUADRON;
- one asset group;
- the approved operational template as payload source;
- cold start;
- straight-in landing;
- `SetDespawnAfterLanding(false)` so final taxi-in and parking remain observable.

The test does not force a post-landing parking position. It records the native MOOSE/DCS selection and fails if that position is outside the UAV type's current G-apron pool.

## Runtime duration

Run until the final line appears:

```text
[OMW][AirOps.KAF.UAVReturnParking] RESULT: PASS
```

or:

```text
[OMW][AirOps.KAF.UAVReturnParking] RESULT: FAIL
```

The hard timeout is 2400 seconds after the return-parking test begins. Reserve up to approximately 41 minutes after mission start.

## Required evidence

Return the current:

```text
dcs.log
debrief.log
```

Acceptance definition:

```text
expected/kandahar-uav-return-parking-acceptance.md
```

Warehouse stock restoration after final arrival is deliberately not accepted by this increment and remains the next separate test.
