---
document_id: OMW-EVID-KAF-UAV-PARKING-2026-08-01
status: BINDING
approved_by: project_owner
approval_date: 2026-08-01
authoritative_for:
  - Kandahar MQ-1 spawn parking
  - Kandahar MQ-9 spawn parking
  - Kandahar MQ-1 and MQ-9 landing and post-landing parking
  - Kandahar UAV apron runtime acceptance
source_branch: agent/kandahar-airwing-baseline-contract
source_mission: OMW_Template_v4_Kandahar(9).miz
source_sha256: 47657b2ae532f98185a9f7c33b04f1ec9fc99ee1264496b44e93184d5ac39f1c
runtime_dcs_build: 2.9.28.26385
supersedes:
  - unrestricted Main-airfield parking for SQ_US_KAF_MQ1_361_ERS
  - unrestricted Main-airfield parking for SQ_US_KAF_MQ9_361_ERS
  - shared seven-position MQ-1/MQ-9 G-apron pool
---

# Kandahar UAV parking restriction decision

## Binding type-specific parking split

```text
SQ_US_KAF_MQ1_361_ERS -> G01, G02, G03, G04, G05, G06, G07, G08
SQ_US_KAF_MQ9_361_ERS -> G09, G10, G11
```

The MQ-9 physically fits only on G09-G11 in the validated Mission Editor layout. G01-G08 are reserved for the smaller MQ-1/RQ-1A representation.

A listed position is usable only while it is not occupied or excluded by:

- an accepted aircraft static;
- a client reservation;
- another Main-airfield parking blacklist reason;
- an active parking reservation.

Static-occupied positions are removed from the applicable type pool. They are not reassigned to the other UAV type.

## Scope

The split applies to:

- initial spawn;
- cold or hot start;
- return to Kandahar;
- landing;
- post-landing taxi;
- final parking and storage.

Neither UAV SQUADRON may use the unrestricted Kandahar Main AIRWING parking pool.

## Runtime-accepted mapping

Calibration source artifact:

```text
OMW_Template_v4_Kandahar(9).miz
Size: 2,191,639 bytes
SHA-256: 47657b2ae532f98185a9f7c33b04f1ec9fc99ee1264496b44e93184d5ac39f1c
DCS: 2.9.28.26385
Terrain revision: 27850
```

All eleven marker coordinates resolved to native Kandahar Main parking nodes with:

```text
coordinateDelta=0.00
terminalType=104
airdromeId=7
allowed=true
blocked=false
available=true
```

Accepted mapping:

```text
G01 -> TerminalID 189 -> RQ-1A Predator
G02 -> TerminalID 303 -> RQ-1A Predator
G03 -> TerminalID 202 -> RQ-1A Predator
G04 -> TerminalID 224 -> RQ-1A Predator
G05 -> TerminalID 46  -> RQ-1A Predator
G06 -> TerminalID 291 -> RQ-1A Predator
G07 -> TerminalID 129 -> RQ-1A Predator
G08 -> TerminalID 143 -> RQ-1A Predator

G09 -> TerminalID 27  -> MQ-9 Reaper
G10 -> TerminalID 54  -> MQ-9 Reaper
G11 -> TerminalID 263 -> MQ-9 Reaper
```

Sorted pools:

```text
MQ-1: 46,129,143,189,202,224,291,303
MQ-9: 27,54,263
```

Calibration result:

```text
RESULT: PASS
labels=11
mapped=11
mq1Available=8
mq9Available=3
unavailableLabels=none
mq1Restricted=true
mq9Restricted=true
noStart=true
noSpawn=true
```

Result evidence:

```text
mission/tests/kandahar-air-operations/results/
2026-08-01-kandahar-uav-g-apron-calibration-pass.md
```

## MOOSE-first spawn implementation

```lua
SQ_US_KAF_MQ1_361_ERS:SetParkingIDs(MQ1_AVAILABLE_G01_TO_G08_TERMINAL_IDS)
SQ_US_KAF_MQ9_361_ERS:SetParkingIDs(MQ9_AVAILABLE_G09_TO_G11_TERMINAL_IDS)
```

Each list is the intersection of its type-specific G-pool with the accepted Kandahar Main AIRWING allowlist.

The fixed runtime implementation is:

```text
mission/tests/kandahar-air-operations/src/
10-kandahar-uav-fixed-parking-contract.lua
```

## Calibration asset disposition

The eleven `CAL_AIR_US_KAF_UAV_G01` through `CAL_AIR_US_KAF_UAV_G11` groups have completed their purpose. They may and should be removed before the physical spawn test.

The normal aircraft statics may be restored to their production positions. Any restored static that blocks one of the eleven TerminalIDs removes that position from the applicable SQUADRON pool at runtime.

The operational templates remain unchanged:

```text
TPL_AIR_US_KAF_MQ1A_RECON_1SHIP
TPL_AIR_US_KAF_MQ9_RECON_1SHIP
```

## Landing and final parking

Squadron spawn parking alone is not accepted as proof of post-landing stand selection.

A dedicated runtime test must demonstrate that each type:

1. lands at Kandahar Main;
2. taxis without entering blocked/client positions;
3. stops only in its own type-specific G-pool;
4. is not returned to stock before the final parking position is confirmed.

Silent fallback to arbitrary Kandahar parking is prohibited.

## Acceptance criteria

```text
all eleven G labels mapped to unique runtime TerminalIDs
G01-G08 validated with RQ-1A markers
G09-G11 validated with MQ-9 markers
MQ-1 spawn and final parking only in available G01-G08 positions
MQ-9 spawn and final parking only in available G09-G11 positions
static-blocked positions excluded
client-reserved positions excluded
no cross-use between MQ-1 and MQ-9 pools
no unrestricted Main-airfield fallback
```

## Current status

```text
Policy decision: BINDING
Mission structural mapping: RECORDED
Runtime TerminalID mapping: ACCEPTED
Calibration marker groups: REMOVABLE
Fixed SQUADRON parking contract: IMPLEMENTED, NOT YET PHYSICALLY SPAWN-ACCEPTED
Controlled MQ-1/MQ-9 spawn test: PREPARED
Landing/final-parking restriction: NOT YET RUNTIME ACCEPTED
Operational UAV activation: BLOCKED
```
