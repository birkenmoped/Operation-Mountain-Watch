# Kandahar UAV G-apron calibration

Status: `TYPE_SPECIFIC_11_POSITION_CALIBRATION_PREPARED`

## Binding split

```text
MQ-1 / RQ-1A Predator -> G01-G08
MQ-9 Reaper           -> G09-G11
```

Only positions still allowed by the Kandahar Main parking contract are passed to the applicable SQUADRON. Static-occupied or otherwise blocked positions are excluded. There is no unrestricted Main-airfield fallback.

## Supplied calibration mission

```text
OMW_Template_v4_Kandahar(9).miz
Size: 2,191,639 bytes
SHA-256: 47657b2ae532f98185a9f7c33b04f1ec9fc99ee1264496b44e93184d5ac39f1c
```

The mission contains all eleven G-positions:

```text
G01-G08 occupied by RQ-1A Predator markers
G09-G11 occupied by MQ-9 Reaper markers
```

The code uses each unit's actual `parking_id` as the authoritative G-label. It does not assume that the calibration group's name suffix matches the assigned stand.

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

Replace the previous Kandahar matrix/calibration bundle with this file. Do not load another Kandahar preflight or matrix bundle in parallel.

## Run

Allow at least 40 seconds and return:

```text
dcs.log
debrief.log
```

Expected calibration result for the supplied static-cleared mission:

```text
labels=11
mapped=11
mq1Available=8
mq9Available=3
unavailableLabels=none
RESULT: PASS
```

A separate later test remains required for physical MQ-1/MQ-9 spawn and for landing, taxi-in and final parking.
