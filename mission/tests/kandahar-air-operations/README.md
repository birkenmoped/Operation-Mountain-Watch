# Kandahar Air Operations Test Family

Status: `DUAL_AIRWING_PARKING_CONTRACT_PASS`

## Current validated source mission

```text
OMW_Template_v4_Kandahar(4).miz
Size: 2,183,450 bytes
SHA-256: 0732f929d4e35641c84bfb34bd75912692c3a1b7b7a0106847ce56e21aa5345c
```

Embedded MOOSE contract:

```text
MOOSE 2.9.18
SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## Validated architecture

```text
AW_US_KAF_451_AEW
├── WH_AIR_US_KANDAHAR
└── AIRBASE.Afghanistan.Kandahar / ID 7

AW_US_KAF_159_CAB_TF_THUNDER
├── WH_AIR_US_KANDAHAR_HELI
└── AIRBASE.Afghanistan.Kandahar_Heliport / ID 15
```

Both AIRWINGs require explicit `SetAirbase()` binding because the Main warehouse is otherwise initially associated with the nearby Heliport.

## Validated runtime increments

### 1. Dual-airbase no-spawn diagnostic

Accepted:

```text
Main parking nodes: 316
Heliport parking nodes: 86
Clients: 10
Templates: 10
US aircraft statics: 47
UN aircraft statics: 6
noSpawn=true
```

Result:

```text
results/2026-07-31-kandahar-dual-airbase-no-spawn-pass.md
```

### 2. Heliport warehouse diagnostic

Accepted:

```text
WH_AIR_US_KANDAHAR_HELI
DCS type: container_20ft
coalition: blue / 2
nearest Heliport TerminalID: 60
nearest distance: 149.63 m
```

Result:

```text
results/2026-07-31-kandahar-heliport-warehouse-pass.md
```

### 3. Dual-AIRWING registration preflight

Accepted:

```text
airwings=2
squadrons=9
registeredAirframes=112
deferredMC12=6
noStart=true
noSpawn=true
noMission=true
noTransport=true
noPayloadMutation=true
noParkingMutation=true
```

Results:

```text
results/2026-08-01-kandahar-dual-airwing-registration-preflight-fail.md
results/2026-08-01-kandahar-dual-airwing-registration-preflight-pass.md
```

The earlier failure proved the automatic Main-airbase ambiguity. The accepted retest uses explicit `SetAirbase()` binding.

### 4. Dual-AIRWING parking contract preflight

Accepted runtime result:

```text
Main: total=316 allowed=301 blocked=15
Heliport: total=86 allowed=59 blocked=27
clientReservations=10
statics=47
safeParking=true
noStart=true
noSpawn=true
noMission=true
noTransport=true
noPayloadMutation=true
```

Result:

```text
results/2026-08-01-kandahar-dual-airwing-parking-contract-preflight-pass.md
```

The deterministic contract now applies:

```text
AIRBASE:SetParkingSpotBlacklist()
AIRWING:SetParkingIDs()
AIRWING:SetSafeParkingOn()
```

No spawn on client parking is enabled.

## Current SQUADRON inventory contract

### AW_US_KAF_451_AEW

```text
SQ_US_KAF_A10C_74_EFS          16 A-10C_2
SQ_US_KAF_HH60G_26_ERQS         6 UH-60A as HH-60G representation
SQ_US_KAF_C130_772_EAS         12 C-130J-30
SQ_US_KAF_MQ1_361_ERS           4 RQ-1A Predator
SQ_US_KAF_MQ9_361_ERS           2 MQ-9 Reaper
```

### AW_US_KAF_159_CAB_TF_THUNDER

```text
SQ_US_KAF_AH64_4_227_AVN        8 AH-64D_BLK_II
SQ_US_KAF_OH58D_7_17_CAV       16 OH58D
SQ_US_KAF_CH47_7_101_GSAB      16 CH-47Fbl1
SQ_US_KAF_UH60_7_101_GSAB      32 UH-60A
```

Deferred:

```text
361st ERS MC-12 component: 6
Reason: no approved DCS template or technical SQUADRON identifier
```

## Current client reservations

Kandahar Main:

```text
92
282
287
294
```

Kandahar Heliport:

```text
4
19
23
30
47
80
```

## Offset statics requiring controlled-spawn validation

Fifteen statics do not overlap a native parking-node centre within the configured clearance radius:

```text
Main:
2 C-130J-30 statics

Heliport:
5 CH-47Fbl1 statics
8 OH58D statics
```

They are intentionally not assigned an arbitrary nearest-node blacklist entry. Their compatibility is a controlled-spawn test concern, not a preflight failure.

## Builders

Read-only dual-airbase diagnostic:

```text
tools/build-kandahar-air-operations-diagnostic.ps1
```

Heliport warehouse diagnostic:

```text
tools/build-kandahar-heliport-warehouse-diagnostic.ps1
```

Dual-AIRWING registration preflight:

```text
tools/build-kandahar-dual-airwing-registration-preflight.ps1
```

Dual-AIRWING parking contract preflight:

```text
tools/build-kandahar-dual-airwing-parking-contract-preflight.ps1
```

Generated parking bundle:

```text
mission/tests/kandahar-air-operations/dist/
OMW_AirOps_Kandahar_DualAirwing_Parking_Contract_Preflight.lua
```

## Current runtime boundary

Accepted source may:

- construct the two approved AIRWINGs;
- register the nine approved physical SQUADRONs;
- register logical Warehouse asset inventory;
- bind each AIRWING explicitly to its approved Airbase;
- apply deterministic parking allow/block sets;
- enable MOOSE safe parking.

It may not yet:

- start either Kandahar AIRWING;
- physically spawn a Kandahar SQUADRON asset except in a separately approved isolated test;
- register payload stock;
- create AUFTRAG or OPSTRANSPORT missions;
- connect Kandahar to COMMANDER or CHIEF;
- mutate campaign persistence.

## Next increment

```text
Kandahar Controlled Single-Airframe Parking Matrix
```

Test order:

```text
Heliport:
OH-58D -> AH-64D -> UH-60 -> CH-47

Main:
MQ-1 -> MQ-9 -> HH-60G representation -> A-10C -> C-130J-30
```

Each case must use the accepted parking contract, capture the selected TerminalID, verify client/static clearance, and remain isolated from operational mission assignment.