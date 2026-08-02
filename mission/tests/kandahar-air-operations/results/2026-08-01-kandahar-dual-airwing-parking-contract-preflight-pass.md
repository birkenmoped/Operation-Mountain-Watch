# Kandahar Dual-AIRWING Parking Contract Preflight – PASS

Status: `PASS`

Test date:

```text
2026-08-01
```

## Runtime evidence

Uploaded logs:

```text
dcs(105).log
Size: 1,913,852 bytes
SHA-256: cecf85b2eb14d59cacd45365fe06fc0a525c686170b7dd41d553f8cb4aa565e7

debrief(58).log
Size: 570,976 bytes
SHA-256: 533df522eb0fcc6662088132c1d8bc8916fb3494fdd53f4289a6a0c5f7b49543
```

The DCS log is cumulative and contains older Kandahar runs. The accepted parking-contract run is the latest relevant run:

```text
Registration start: 2026-08-01 18:32:33.058 UTC
Parking contract start: 2026-08-01 18:32:41.026 UTC
Parking contract PASS: 2026-08-01 18:32:41.051 UTC
Mission stop: 2026-08-01 18:35:19.398 UTC
```

An older registration failure at `15:22:11 UTC` belongs to the previously documented pre-fix run and does not describe this retest.

## Source contract

Runtime-reported mission source:

```text
OMW_Template_v4_Kandahar(4).miz
SHA-256: 0732f929d4e35641c84bfb34bd75912692c3a1b7b7a0106847ce56e21aa5345c
```

Expected embedded MOOSE:

```text
MOOSE 2.9.18
SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Repository source and builder immediately before the test were provided by:

```text
Branch: agent/kandahar-airwing-baseline-contract
Head: bc2bf5f7bf8b29a1d046f9906abe519ed180ae7a
BuilderVersion: KAF-DUAL-AIRWING-PARKING-CONTRACT-PREFLIGHT-1
```

The generated Lua header is not emitted into `dcs.log`; therefore the generated bundle SHA-256 cannot be independently recovered from the uploaded runtime logs.

## Registration prerequisite

The included registration stage passed before parking was applied:

```text
RESULT: PASS
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

Explicit AIRWING bindings remained correct:

```text
AW_US_KAF_451_AEW
Warehouse: WH_AIR_US_KANDAHAR
Airbase: Kandahar
Airbase ID: 7
running=false

AW_US_KAF_159_CAB_TF_THUNDER
Warehouse: WH_AIR_US_KANDAHAR_HELI
Airbase: Kandahar Heliport
Airbase ID: 15
running=false
```

## Parking contract result

Final runtime result:

```text
RESULT: PASS
airwings=2
mainTotal=316
mainAllowed=301
mainBlocked=15
heliportTotal=86
heliportAllowed=59
heliportBlocked=27
clientReservations=10
statics=47
safeParking=true
noStart=true
noSpawn=true
noMission=true
noTransport=true
noPayloadMutation=true
```

Both contracts were applied while both AIRWINGs remained stopped:

```text
CONTRACT_APPLIED key=Main
  airwing=AW_US_KAF_451_AEW
  allowed=301
  blocked=15
  safeParking=true
  running=false

CONTRACT_APPLIED key=Heliport
  airwing=AW_US_KAF_159_CAB_TF_THUNDER
  allowed=59
  blocked=27
  safeParking=true
  running=false
```

No Kandahar parking-contract `VIOLATION`, `RESULT: FAIL`, mission-script error, or Lua traceback occurred in the accepted run.

## Client reservations

All ten approved client TerminalIDs were found and blocked.

### Kandahar Main

```text
92
282
287
294
```

### Kandahar Heliport

```text
4
19
23
30
47
80
```

No client-reserved ID remained in either AIRWING allowlist.

## Static classification

Exactly 47 US aircraft statics were classified:

```text
Main: 13
Heliport: 34
```

Type totals:

```text
 6 A-10C_2
 2 C-130J-30
10 UH-60A
 2 RQ-1A Predator
 1 MQ-9 Reaper
 8 AH-64D_BLK_II
 8 OH58D
10 CH-47Fbl1
----------------
47 total
```

### Main blocked TerminalIDs

```text
20   STATIC_AIR_US_KAF_A10C_04
43   STATIC_AIR_US_KAF_A10C_01
91   STATIC_AIR_US_KAF_A10C_02
92   CLIENT_RESERVED
202  STATIC_AIR_US_KAF_MQ1A_01
259  STATIC_AIR_US_KAF_HH60G_01
270  STATIC_AIR_US_KAF_A10C_06
277  STATIC_AIR_US_KAF_HH60G_02
278  STATIC_AIR_US_KAF_A10C_03
282  CLIENT_RESERVED
287  CLIENT_RESERVED
291  STATIC_AIR_US_KAF_MQ9_01
294  CLIENT_RESERVED
303  STATIC_AIR_US_KAF_MQ1A_02
313  STATIC_AIR_US_KAF_A10C_05
```

### Heliport blocked TerminalIDs

```text
 1  STATIC_AIR_US_KAF_UH60_06
 4  CLIENT_RESERVED
 5  STATIC_AIR_US_KAF_CH47_10
 6  STATIC_AIR_US_KAF_UH60_07
 9  STATIC_AIR_US_KAF_UH60_01
19  CLIENT_RESERVED
20  STATIC_AIR_US_KAF_AH64_03
22  STATIC_AIR_US_KAF_UH60_02
23  CLIENT_RESERVED
25  STATIC_AIR_US_KAF_CH47_06
28  STATIC_AIR_US_KAF_AH64_06
29  STATIC_AIR_US_KAF_AH64_02
30  CLIENT_RESERVED
32  STATIC_AIR_US_KAF_UH60_05
35  STATIC_AIR_US_KAF_AH64_08
45  STATIC_AIR_US_KAF_CH47_08
47  CLIENT_RESERVED
48  STATIC_AIR_US_KAF_CH47_09
49  STATIC_AIR_US_KAF_AH64_04
50  STATIC_AIR_US_KAF_AH64_05
58  STATIC_AIR_US_KAF_CH47_07
61  STATIC_AIR_US_KAF_UH60_03
65  STATIC_AIR_US_KAF_UH60_08
75  STATIC_AIR_US_KAF_AH64_01
78  STATIC_AIR_US_KAF_AH64_07
80  CLIENT_RESERVED
84  STATIC_AIR_US_KAF_UH60_04
```

## Statics without native-node overlap

Fifteen statics did not cover a native parking-node centre within their configured clearance radius. In accordance with the acceptance contract, no arbitrary nearest TerminalID was blacklisted for them.

### Main

```text
STATIC_AIR_US_KAF_C130_01 | nearest 55.19 m | radius 32 m
STATIC_AIR_US_KAF_C130_02 | nearest 56.88 m | radius 32 m
```

### Heliport

```text
STATIC_AIR_US_KAF_CH47_01 | nearest 90.19 m | radius 30 m
STATIC_AIR_US_KAF_CH47_02 | nearest 87.62 m | radius 30 m
STATIC_AIR_US_KAF_CH47_03 | nearest 90.64 m | radius 30 m
STATIC_AIR_US_KAF_CH47_04 | nearest 90.19 m | radius 30 m
STATIC_AIR_US_KAF_CH47_05 | nearest 94.56 m | radius 30 m

STATIC_AIR_US_KAF_OH58D_01 | nearest 39.68 m | radius 14 m
STATIC_AIR_US_KAF_OH58D_02 | nearest 38.61 m | radius 14 m
STATIC_AIR_US_KAF_OH58D_03 | nearest 39.58 m | radius 14 m
STATIC_AIR_US_KAF_OH58D_04 | nearest 40.52 m | radius 14 m
STATIC_AIR_US_KAF_OH58D_05 | nearest 38.49 m | radius 14 m
STATIC_AIR_US_KAF_OH58D_06 | nearest 38.77 m | radius 14 m
STATIC_AIR_US_KAF_OH58D_07 | nearest 39.37 m | radius 14 m
STATIC_AIR_US_KAF_OH58D_08 | nearest 40.38 m | radius 14 m
```

These objects remain an explicit controlled-spawn validation concern. The PASS proves that the deterministic allow/block contract was applied as designed; it does not yet prove per-aircraft taxi, rotor, wingtip, or return-parking clearance.

## No-spawn evidence

The debrief contains:

```text
graveyard = {}
```

Event summary:

```text
44 group change option
1 mission start
1 took control
1 engine startup
1 mission end
```

The sole aircraft event is an `A-10C_2` engine startup at Kandahar at `t=22.5`, attributable to the existing player/client slot. There is no AI aircraft birth or mission event attributable to the Kandahar parking-contract bundle.

MOOSE `New asset with id=...` messages are logical Warehouse asset registrations and not physical DCS spawns.

## External/non-OMW error

The known Saved-Games shutdown hook error occurred after mission stop:

```text
Saved Games\DCS.openbeta\Scripts\Hooks\bhHook.lua:168
attempt to index upvalue 'tcp' (a nil value)
```

It is outside the Kandahar test bundle and did not affect the PASS.

## Accepted scope

Accepted:

- both approved AIRWINGs and nine SQUADRONs remain constructible;
- explicit Main/Heliport Airbase bindings;
- all 402 native parking nodes discovered;
- all ten client TerminalIDs reserved;
- all 47 US aircraft statics classified;
- deterministic Main and Heliport block/allow sets;
- `SetParkingSpotBlacklist()` applied to both native airbases;
- `SetParkingIDs()` applied to both AIRWINGs;
- `SetSafeParkingOn()` enabled for both AIRWINGs;
- both AIRWINGs remain stopped;
- no Kandahar spawn, mission, transport, or payload mutation.

Not yet accepted:

- per-type parking geometry under physical spawn;
- CH-47 and OH-58D offset-static clearance under runtime spawn;
- C-130 stand, wingtip, taxi, and runway access;
- simultaneous/multi-aircraft parking behavior;
- AIRWING start;
- payload registration;
- AUFTRAG or OPSTRANSPORT execution;
- return, repair, loss, or persistence behavior.

## Next increment

```text
Kandahar Controlled Single-Airframe Parking Matrix
```

Recommended sequence:

```text
Heliport: OH-58D -> AH-64D -> UH-60 -> CH-47
Main: MQ-1 -> MQ-9 -> HH-60G representation -> A-10C -> C-130J-30
```

Each case must use the accepted allow/block contract, record the selected TerminalID, prove no client/static collision, and remain isolated from operational mission assignment.