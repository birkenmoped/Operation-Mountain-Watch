# Jalalabad Phase 1 – operational safety retest

## Status

```text
IMPLEMENTED IN REPOSITORY
DCS VALIDATION PENDING
BuilderVersion: JBAD-AIR-OPS-PHASE1-5
Mission: OMW_Jalalabad_AirOps_Phase1_Test.miz
```

The mission file remains under the same name. ChatGPT changes only Lua, builder and repository documentation. The user owns all Mission Editor changes and bundle embedding.

## Corrected scope

Phase 1 now separates global baseline readiness from readiness of each individual test.

Global readiness validates only:

- Jalalabad AIRWING operational;
- static parking reservations;
- exclusive squadron parking pools;
- exact runtime-name contract;
- required Mission Editor objects;
- Client parking resolution;
- clean 24/8/8/8 single-ship asset inventory;
- empty AIRWING queue.

A RECON configuration can no longer block AH-64D CAS, UH-60 transport or CH-47 cargo.

## RECON route policy

The previous values below are no longer blocking limits:

```text
18,000 m zone distance
11,000 m leg distance
42,000 m total route
1,300 m sampled terrain
6,500 ft mission altitude
```

They were not derived from a validated OH-58D fuel model. They remain advisory telemetry only.

Hard RECON errors are limited to:

- missing airbase or RECON zone;
- unavailable coordinate or terrain data;
- consecutive RECON zones less than 250 m apart;
- failure to construct the MOOSE mission.

Expected readiness log:

```text
[OMW][AirOps.JBAD.PH1.READINESS] RECON_PROFILE READY ... warnings=... blockingFuelModel=false
```

Warnings document demanding distance, terrain or altitude values but do not block the test.

The MOOSE mission range is calculated from the farthest RECON zone plus a 5 NM margin and constrained to 20–50 NM.

## Empirical OH-58D fuel telemetry

While `OH58D_RECON` is active, the bundle records fuel every 60 seconds and when an aircraft enters each RECON zone or RTB is observed:

```text
RECON_FUEL ... stage=PERIODIC
RECON_FUEL ... stage=ZONE_1
RECON_FUEL ... stage=ZONE_2
RECON_FUEL ... stage=ZONE_3
RECON_FUEL ... stage=RTB_OBSERVED
```

Each entry contains:

- exact unit name;
- fuel percentage reported by DCS;
- altitude MSL;
- terrain height MSL;
- mission time.

No fuel-based mission limit will be introduced until these DCS measurements support one.

## UH-60 troop readiness

The dedicated drop zone remains required:

```text
ZONE_TEST_US_JBAD_UH60_DROPOFF
```

Hard errors are limited to:

- missing load or drop zone;
- overlapping load and drop zones;
- unavailable terrain data;
- more than one route point on the troop template.

Load/drop distance and terrain difference are logged but are not arbitrary blocking limits.

Expected log:

```text
[OMW][AirOps.JBAD.PH1.READINESS] TROOP_PROFILE READY ... heuristicDistanceBlocks=false
```

The transport lifecycle still requires helicopter takeoff, observed troop pickup and later troop presence in the dedicated drop zone.

## Vertical helicopter operation preference

The AIRWING continues to request:

```lua
AIRWING:SetOptionPreferVerticalLanding()
```

Failure to expose that optional MOOSE method is logged as a warning and no longer blocks all Phase-1 tests. Visual DCS behavior remains authoritative.

## Repository and build

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch

git branch --show-current
git status --short
git fetch origin
git switch feature/jalalabad-airwing-phase1-functional-tests
git pull --ff-only
git rev-parse HEAD

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File ".\tools\build-jalalabad-air-operations-bundle.ps1"

Get-Item `
  ".\mission\tests\jalalabad-air-operations\dist\OMW_AirOps_Jalalabad.lua" |
  Select-Object FullName, Length, LastWriteTime

Get-FileHash `
  ".\mission\tests\jalalabad-air-operations\dist\OMW_AirOps_Jalalabad.lua" `
  -Algorithm SHA256
```

The builder output and independent `Get-FileHash` result must match.

## Mission Editor procedure

1. Open `OMW_Jalalabad_AirOps_Phase1_Test.miz`.
2. Do not move RECON zones merely to satisfy the former 18 km gate.
3. Keep `ZONE_TEST_US_JBAD_UH60_DROPOFF` and the troop template without movement waypoints.
4. Reselect the locally built `OMW_AirOps_Jalalabad.lua` in the existing `DO SCRIPT FILE` action.
5. Save the mission under the same name.

## Recommended test order

1. Start mission and confirm global `READY`.
2. Run `OH-58D RECON` individually and collect the complete fuel telemetry.
3. Restart and run `UH-60A Transport` individually.
4. Restart and run `CH-47F Cargo` individually.
5. Only after these tests pass, run the complete sequence.

## Required results

```text
ME_OBJECTS PASS baseObjects=true routeSpecificChecks=DEFERRED_PER_TEST
READY globalGate=BASELINE_ONLY perTestReadiness=true heuristicRangeFuelBlocks=false
RECON_PROFILE READY ... blockingFuelModel=false
TROOP_PROFILE READY ... heuristicDistanceBlocks=false
```

Provide the new `dcs.log` after each individual retest. The `.miz` is required only when the log indicates a missing or contradictory Mission Editor object.
