# Kandahar UAV G-apron calibration – acceptance

Status: `PREPARED_NOT_RUNTIME_ACCEPTED`

## Binding parking split

```text
MQ-1 / RQ-1A Predator: G01-G08 only
MQ-9 Reaper:           G09-G11 only
```

A position is usable only while it remains present in the accepted Kandahar Main AIRWING allowlist. Any G-position blocked by a static aircraft, client reservation or other accepted parking exclusion is removed from the applicable SQUADRON pool.

No UAV may silently fall back to unrestricted Kandahar Main parking.

## Calibration source

```text
Artifact: OMW_Template_v4_Kandahar(9).miz
Size:     2,191,639 bytes
SHA-256:  47657b2ae532f98185a9f7c33b04f1ec9fc99ee1264496b44e93184d5ac39f1c
Airbase:  Kandahar / ID 7
```

The Mission Editor source contains eleven one-unit Late Activation calibration groups. The actual stand assignment is determined from each unit's `parking_id`, not from the suffix of its group name. This is required because several group-name suffixes do not match their assigned stand labels in the supplied artifact.

## Required physical fit markers

```text
G01-G08: one RQ-1A Predator each
G09-G11: one MQ-9 Reaper each
```

The marker aircraft are calibration-only objects. They are not AIRWING inventory and must never be activated.

## Mission-derived parking fields

```text
Label | Marker type       | mission parking
G01   | RQ-1A Predator    | 189
G02   | RQ-1A Predator    | 303
G03   | RQ-1A Predator    | 202
G04   | RQ-1A Predator    | 224
G05   | RQ-1A Predator    | 46
G06   | RQ-1A Predator    | 291
G07   | RQ-1A Predator    | 129
G08   | RQ-1A Predator    | 143
G09   | MQ-9 Reaper       | 27
G10   | MQ-9 Reaper       | 54
G11   | MQ-9 Reaper       | 263
```

These mission-file values are structural evidence only. Runtime acceptance still requires correlation with native MOOSE/DCS `TerminalID` values.

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

## Runtime boundary

Permitted:

- construct the accepted two AIRWINGs and nine SQUADRONs;
- apply the accepted Main and Heliport parking contracts;
- read eleven Late Activation marker templates;
- resolve the actual G-label from `parking_id`;
- correlate each marker coordinate with the nearest native Kandahar Main parking node;
- intersect each type-specific G-pool with the accepted Main AIRWING allowlist;
- assign G01-G08 to `SQ_US_KAF_MQ1_361_ERS`;
- assign G09-G11 to `SQ_US_KAF_MQ9_361_ERS`.

Forbidden:

- AIRWING start;
- physical spawn;
- AUFTRAG;
- OPSTRANSPORT;
- COMMANDER or CHIEF;
- payload registration or mutation;
- client-parking override;
- fallback to unrestricted Main parking.

## Required log sequence

The existing preflights must pass first:

```text
[OMW][AirOps.KAF.RegistrationPreflight] RESULT: PASS
[OMW][AirOps.KAF.ParkingContract] RESULT: PASS
```

Then exactly eleven mapping lines must appear, one for every label G01-G11:

```text
[OMW][AirOps.KAF.UAVGApronCalibration] MAP label=Gxx ...
```

Each line must report:

```text
correct marker type for the label
unique runtimeTerminalID
missionParking equal to runtimeTerminalID for this DCS terrain revision
coordinateDelta <= 5.00 m
airdromeId=7
allowed=true/false
blocked=true/false
available=true only when allowed and not blocked
```

## Required final result for the supplied test mission

Because the statics were temporarily moved away for this calibration run, all eleven positions are expected to remain available:

```text
[OMW][AirOps.KAF.UAVGApronCalibration] RESULT: PASS labels=11 mapped=11 mq1Labels=8 mq1Available=8 mq1TerminalIDs=<eight IDs> mq9Labels=3 mq9Available=3 mq9TerminalIDs=<three IDs> unavailableLabels=none mq1Restricted=true mq9Restricted=true noStart=true noSpawn=true noMission=true noTransport=true noPayloadMutation=true
```

In a later operational mission with statics restored, blocked G-positions may be excluded without changing the type split, provided at least one valid position remains for each UAV type.

## Runtime duration and evidence

Run the mission for at least 40 seconds, then provide:

```text
dcs.log
debrief.log
```

After this calibration passes, the next test is a controlled MQ-1/MQ-9 spawn test using their separate pools. Landing, taxi-in and final parking remain a separate acceptance step.
