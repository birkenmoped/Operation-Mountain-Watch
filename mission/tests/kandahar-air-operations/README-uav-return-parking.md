# Kandahar UAV return and final-parking test

Status: `V2_PREPARED_NOT_RUNTIME_ACCEPTED`

This is the next test after the accepted controlled MQ-1/MQ-9 cold-spawn contract.

## V1 result

The first full-cycle run proved:

```text
cold start
engine start
taxi-out
takeoff
orbit
RTB
landing at Kandahar Main
```

It did not prove taxi-in or final parking. Both UAVs were removed immediately after touchdown.

Root cause:

```text
AIRWING:SetDespawnAfterLanding(false)
```

In the embedded MOOSE AIRWING v0.9.7 and SQUADRON v0.8.1 code, a false argument enables `despawnAfterLanding`. V2 adds a narrowly scoped compatibility stage that explicitly clears the state on the Kandahar Main AIRWING, both UAV SQUADRONs and every assigned UAV FLIGHTGROUP. It does not modify global MOOSE classes.

## Build

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch

git switch agent/kandahar-airwing-baseline-contract
git pull --ff-only origin agent/kandahar-airwing-baseline-contract

git rev-parse HEAD

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
KAF-UAV-RETURN-PARKING-2
```

Expected compatibility output:

```text
NoDespawnCompatibility: DIRECT_INSTANCE_STATE_OVERRIDE
PublicFalseSetterUsedForAcceptance: false
MOOSEBehavior: SetDespawnAfterLanding(false) enables despawn in AIRWING v0.9.7 / SQUADRON v0.8.1
```

## Mission Editor

Keep:

- the approved operational MQ-1 and MQ-9 templates;
- the normal production aircraft statics;
- the Main and Heliport warehouse anchors;
- the current client slots.

Do not restore the eleven `CAL_AIR_US_KAF_UAV_Gxx` calibration groups.

Replace the previous return-parking bundle with the newly generated:

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
- an explicitly cleared `despawnAfterLanding` state at AIRWING, SQUADRON and FLIGHTGROUP level.

The test does not force a post-landing parking position. It records the native MOOSE/DCS selection and fails if that position is outside the UAV type's current G-apron pool.

## Required no-despawn evidence

Before either flight departs, the log must contain:

```text
[OMW][AirOps.KAF.UAVNoDespawnPolicy] RESULT: PASS
```

For both assigned flights:

```text
FLIGHT_POLICY_APPLIED case=MQ1 ... despawnAfterLanding=false ok=true
FLIGHT_POLICY_APPLIED case=MQ9 ... despawnAfterLanding=false ok=true
```

## Runtime duration

Do not stop the mission when both UAVs merely touch down. Continue until each aircraft has taxied to its final position and the final test line appears:

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
