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
calibration_mission: OMW_Template_v4_Kandahar(9).miz
calibration_sha256: 47657b2ae532f98185a9f7c33b04f1ec9fc99ee1264496b44e93184d5ac39f1c
runtime_dcs_build: 2.9.28.26385
supersedes:
  - unrestricted Main-airfield parking for SQ_US_KAF_MQ1_361_ERS
  - unrestricted Main-airfield parking for SQ_US_KAF_MQ9_361_ERS
  - shared seven-position MQ-1/MQ-9 G-apron pool
---

# Kandahar UAV parking restriction decision

## Binding type-specific split

```text
SQ_US_KAF_MQ1_361_ERS -> G01-G08
SQ_US_KAF_MQ9_361_ERS -> G09-G11
```

The MQ-9 may use only G09-G11. G01-G08 are reserved for the smaller MQ-1/RQ-1A representation.

A listed position is usable only while it is not occupied or excluded by:

- an accepted aircraft static;
- a client reservation;
- another Main-airfield parking blacklist reason;
- an active parking reservation.

Static-occupied positions are removed from the applicable type pool. They are not reassigned to the other UAV type.

Neither UAV SQUADRON may use unrestricted Kandahar Main AIRWING parking.

## Accepted native TerminalID mapping

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

Calibration evidence:

```text
mission/tests/kandahar-air-operations/results/
2026-08-01-kandahar-uav-g-apron-calibration-pass.md
```

## MOOSE-first implementation

The type-specific parking lists are applied at SQUADRON level:

```lua
SQ_US_KAF_MQ1_361_ERS:SetParkingIDs(MQ1_AVAILABLE_G01_TO_G08_TERMINAL_IDS)
SQ_US_KAF_MQ9_361_ERS:SetParkingIDs(MQ9_AVAILABLE_G09_TO_G11_TERMINAL_IDS)
```

Each list is intersected with the current Kandahar Main AIRWING allowlist.

Because MOOSE copies `SQUADRON.parkingIDs` to `asset.parkingIDs` during asset registration, the final filtered lists are also synchronized to all already registered UAV asset records before the Main AIRWING starts.

Implemented sources:

```text
mission/tests/kandahar-air-operations/src/
10-kandahar-uav-fixed-parking-contract.lua
10b-kandahar-uav-registered-asset-parking-sync.lua
11-kandahar-uav-controlled-spawn-test.lua
```

## Physically accepted initial spawn

Runtime evidence:

```text
mission/tests/kandahar-air-operations/results/
2026-08-02-kandahar-uav-controlled-spawn-pass.md
```

Accepted filtered pools during the run:

```text
MQ-1 available: G01,G04,G05,G06,G07,G08
MQ-1 TerminalIDs: 46,129,143,189,224,291
MQ-1 static-blocked: G02,G03

MQ-9 available: G09,G10,G11
MQ-9 TerminalIDs: 27,54,263
```

Registered asset synchronization:

```text
MQ-1 asset groups synchronized: 4
MQ-9 asset groups synchronized: 2
RESULT: PASS
```

Physical spawn observations:

```text
MQ-1 / RQ-1A Predator
TerminalID=291
TerminalType=104
nodeDistance=1.77 m
inSquadronPool=true
mainAllowed=true
blocked=false
alive=true
airborne=false
allOnGround=true

MQ-9 Reaper
TerminalID=263
TerminalType=104
nodeDistance=1.77 m
inSquadronPool=true
mainAllowed=true
blocked=false
alive=true
airborne=false
allOnGround=true
```

Final result:

```text
RESULT: PASS
cases=2
passed=2
failed=0
separatePools=true
cold=true
uncontrolled=true
mainAirwingStarted=true
heliportAirwingStopped=true
noFallback=true
noAUFTRAG=true
noTransport=true
noPayloadMutation=true
noTaxi=true
noTakeoff=true
```

## Calibration asset disposition

The eleven `CAL_AIR_US_KAF_UAV_G01` through `CAL_AIR_US_KAF_UAV_G11` groups have completed their purpose and may be removed.

The normal aircraft statics may remain in their production positions. Any restored static that blocks one of the eleven TerminalIDs removes that position from the applicable SQUADRON pool at runtime.

Operational templates remain:

```text
TPL_AIR_US_KAF_MQ1A_RECON_1SHIP
TPL_AIR_US_KAF_MQ9_RECON_1SHIP
```

## Landing and final parking

Initial spawn acceptance is not proof of return, landing, taxi-in or final parking.

A separate runtime increment must demonstrate that each UAV type:

1. lands at Kandahar Main;
2. taxis without entering blocked or client positions;
3. stops only in its own type-specific G-pool;
4. is not returned to warehouse stock before final parking is confirmed.

Silent fallback to arbitrary Kandahar parking remains prohibited.

## Current status

```text
Policy decision: BINDING
Mission structural mapping: RECORDED
Runtime TerminalID mapping: ACCEPTED
Calibration marker groups: REMOVABLE
Fixed SQUADRON parking contract: ACCEPTED
Registered asset parking synchronization: ACCEPTED
Controlled MQ-1/MQ-9 initial spawn: RUNTIME ACCEPTED
Landing/final-parking restriction: NOT YET RUNTIME ACCEPTED
Operational UAV activation: PARTIALLY UNBLOCKED FOR INITIAL SPAWN ONLY
```
