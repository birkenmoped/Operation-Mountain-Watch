# Kandahar UAV G-apron calibration

Status: `PREPARED_NOT_RUNTIME_ACCEPTED`

## Objective

Map the owner-approved Kandahar UAV parking labels

```text
G01, G04, G05, G07, G08, G10, G11
```

to the exact native DCS/MOOSE runtime TerminalIDs of the current Kandahar mission.

## One-time Mission Editor preparation

At Kandahar Main create seven one-unit `RQ-1A Predator` groups:

```text
CAL_AIR_US_KAF_UAV_G01 -> parking G01
CAL_AIR_US_KAF_UAV_G04 -> parking G04
CAL_AIR_US_KAF_UAV_G05 -> parking G05
CAL_AIR_US_KAF_UAV_G07 -> parking G07
CAL_AIR_US_KAF_UAV_G08 -> parking G08
CAL_AIR_US_KAF_UAV_G10 -> parking G10
CAL_AIR_US_KAF_UAV_G11 -> parking G11
```

For every group:

```text
Takeoff from parking cold
Late Activation ON
Uncontrolled OFF
one unit
no activation trigger
```

They are calibration markers only. They are not inventory and never spawn.

## Build

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch

git switch agent/kandahar-airwing-baseline-contract
git pull --ff-only origin agent/kandahar-airwing-baseline-contract

powershell -ExecutionPolicy Bypass -File `
  .\tools\build-kandahar-uav-g-apron-calibration.ps1
```

Generated file:

```text
mission\tests\kandahar-air-operations\dist\
OMW_AirOps_Kandahar_UAV_G_Apron_Calibration.lua
```

Replace the previous Kandahar matrix bundle with this file. Do not load any other Kandahar preflight or matrix bundle in parallel.

## Run

Allow at least 40 seconds. Return the current:

```text
dcs.log
debrief.log
```

The accepted runtime mapping will then be committed and used for the MQ-1/MQ-9 spawn restriction. A separate later test remains required for landing, taxi-in and final parking on the same G-apron pool.
