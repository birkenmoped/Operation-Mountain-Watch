# Kandahar UAV G-apron calibration – acceptance

Status: `PREPARED_NOT_RUNTIME_ACCEPTED`

## Mission Editor calibration markers

Create exactly seven one-unit aircraft groups at Kandahar Main.

Use an `RQ-1A Predator` for each group. The aircraft type is only a non-spawning coordinate carrier; these groups are not added to any AIRWING inventory.

Required settings for every group:

```text
country: USA
unit count: 1
start type: Takeoff from parking cold
Late Activation: ON
Uncontrolled: OFF
airdrome: Kandahar / ID 7
trigger activation: none
```

Required group names and selected Mission Editor parking labels:

```text
CAL_AIR_US_KAF_UAV_G01 -> G01
CAL_AIR_US_KAF_UAV_G04 -> G04
CAL_AIR_US_KAF_UAV_G05 -> G05
CAL_AIR_US_KAF_UAV_G07 -> G07
CAL_AIR_US_KAF_UAV_G08 -> G08
CAL_AIR_US_KAF_UAV_G10 -> G10
CAL_AIR_US_KAF_UAV_G11 -> G11
```

The group name must match exactly. Do not use unit names as a substitute for the group names.

The seven groups remain Late Activated and must never be activated by a trigger.

## Build

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch

git switch agent/kandahar-airwing-baseline-contract
git pull --ff-only origin agent/kandahar-airwing-baseline-contract

powershell -ExecutionPolicy Bypass -File `
  .\tools\build-kandahar-uav-g-apron-calibration.ps1
```

Generated bundle:

```text
mission\tests\kandahar-air-operations\dist\
OMW_AirOps_Kandahar_UAV_G_Apron_Calibration.lua
```

Load only this Kandahar bundle after MOOSE. It already contains the registration and parking-contract preflights.

Do not load the registration, parking-contract, controlled-case or controlled-matrix Kandahar bundles in parallel.

## Runtime boundary

Permitted:

- construct the accepted two AIRWINGs and nine SQUADRONs;
- apply the accepted Main and Heliport parking contracts;
- read seven Late Activation calibration templates;
- correlate each marker coordinate with the nearest native Kandahar Main parking node;
- assign the resulting seven runtime TerminalIDs to the MQ-1 and MQ-9 SQUADRON objects with `SQUADRON:SetParkingIDs()`.

Forbidden:

- AIRWING start;
- physical spawn;
- AUFTRAG;
- OPSTRANSPORT;
- COMMANDER or CHIEF;
- payload registration or mutation;
- client-parking override.

## Required log sequence

The existing preflights must pass first:

```text
[OMW][AirOps.KAF.RegistrationPreflight] RESULT: PASS
[OMW][AirOps.KAF.ParkingContract] RESULT: PASS
```

Then exactly seven mapping lines must appear:

```text
[OMW][AirOps.KAF.UAVGApronCalibration] MAP label=G01 ...
[OMW][AirOps.KAF.UAVGApronCalibration] MAP label=G04 ...
[OMW][AirOps.KAF.UAVGApronCalibration] MAP label=G05 ...
[OMW][AirOps.KAF.UAVGApronCalibration] MAP label=G07 ...
[OMW][AirOps.KAF.UAVGApronCalibration] MAP label=G08 ...
[OMW][AirOps.KAF.UAVGApronCalibration] MAP label=G10 ...
[OMW][AirOps.KAF.UAVGApronCalibration] MAP label=G11 ...
```

Each line must report:

```text
unique runtimeTerminalID
coordinateDelta <= 5.00 m
allowed=true
blocked=false
airdromeId=7 or nil only when DCS omits that field from the template
```

No two labels may resolve to the same runtime TerminalID.

## Required final result

```text
[OMW][AirOps.KAF.UAVGApronCalibration] RESULT: PASS labels=7 mapped=7 runtimeTerminalIDs=<seven unique IDs> mq1Restricted=true mq9Restricted=true noStart=true noSpawn=true noMission=true noTransport=true noPayloadMutation=true
```

Any missing marker, duplicate TerminalID, blocked/client position, coordinate delta above five metres, incorrect airbase, or unrestricted SQUADRON parking is a failure.

## Runtime duration and evidence

Run the mission for at least 40 seconds, then provide:

```text
dcs.log
debrief.log
```

The resulting seven-label mapping will then be committed as the binding runtime-ID contract and used by the controlled UAV spawn test.
