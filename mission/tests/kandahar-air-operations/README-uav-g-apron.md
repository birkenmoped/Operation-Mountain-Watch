# Kandahar UAV G-apron contract

Status: `CALIBRATION_PASS_CONTROLLED_SPAWN_PREPARED`

## Binding split

```text
MQ-1 / RQ-1A Predator -> G01-G08
MQ-9 Reaper           -> G09-G11
```

Only positions still allowed by the current Kandahar Main parking contract are passed to the applicable SQUADRON. Static-occupied, client-reserved or otherwise blocked positions are excluded. There is no unrestricted Main-airfield fallback.

## Accepted runtime mapping

Calibration artifact:

```text
OMW_Template_v4_Kandahar(9).miz
Size: 2,191,639 bytes
SHA-256: 47657b2ae532f98185a9f7c33b04f1ec9fc99ee1264496b44e93184d5ac39f1c
DCS: 2.9.28.26385
```

Accepted mapping:

```text
MQ-1 pool
G01 -> 189
G02 -> 303
G03 -> 202
G04 -> 224
G05 -> 46
G06 -> 291
G07 -> 129
G08 -> 143

MQ-9 pool
G09 -> 27
G10 -> 54
G11 -> 263
```

Runtime result:

```text
RESULT: PASS
labels=11
mapped=11
mq1Available=8
mq1TerminalIDs=46,129,143,189,202,224,291,303
mq9Available=3
mq9TerminalIDs=27,54,263
unavailableLabels=none
mq1Restricted=true
mq9Restricted=true
noStart=true
noSpawn=true
```

Result evidence:

```text
results/2026-08-01-kandahar-uav-g-apron-calibration-pass.md
```

## Calibration assets

The eleven groups named `CAL_AIR_US_KAF_UAV_G01` through `CAL_AIR_US_KAF_UAV_G11` have completed their purpose. Remove them from the mission before the physical controlled-spawn test.

Restore the normal aircraft statics to their intended production positions. The fixed contract filters the two UAV pools through the resulting Main AIRWING allowlist.

The operational templates remain:

```text
TPL_AIR_US_KAF_MQ1A_RECON_1SHIP
TPL_AIR_US_KAF_MQ9_RECON_1SHIP
```

## Controlled spawn build

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch

git switch agent/kandahar-airwing-baseline-contract
git pull --ff-only origin agent/kandahar-airwing-baseline-contract

powershell -ExecutionPolicy Bypass -File `
  .\tools\build-kandahar-uav-controlled-spawn.ps1
```

Generated file:

```text
mission\tests\kandahar-air-operations\dist\
OMW_AirOps_Kandahar_UAV_Controlled_Spawn.lua
```

This bundle already contains:

```text
05 - Kandahar registration preflight
06 - Kandahar Main/Heliport parking contract
10 - fixed UAV parking contract
11 - controlled MQ-1/MQ-9 spawn test
```

Do not load the old calibration or general parking-matrix bundles in parallel.

## Controlled spawn run

Allow at least 150 seconds and provide:

```text
dcs.log
debrief.log
```

Required outcome:

```text
MQ-1 uses one currently available G01-G08 TerminalID
MQ-9 uses one currently available G09-G11 TerminalID
RESULT: PASS cases=2 passed=2 failed=0 assetGroups=2 units=2
```

Acceptance details:

```text
expected/kandahar-uav-controlled-spawn-acceptance.md
```

Landing, taxi-in and final post-landing parking remain a separate acceptance increment after controlled spawn passes.
