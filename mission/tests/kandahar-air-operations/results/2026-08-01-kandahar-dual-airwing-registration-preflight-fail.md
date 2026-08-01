# Kandahar Dual-AIRWING Registration Preflight – Runtime Result 2026-08-01

## Result

```text
FAIL – one controlled contract violation
```

Evidence files supplied by the project owner:

```text
dcs(103).log
debrief(56).log
```

Runtime environment:

```text
DCS 2.9.28.26385 MT
Test time: 2026-08-01 15:22:11 UTC
Embedded source mission metadata: OMW_Template_v4_Kandahar(4).miz
Embedded mission SHA-256: 0732f929d4e35641c84bfb34bd75912692c3a1b7b7a0106847ce56e21aa5345c
```

## Passed preconditions

The runtime resolved both native airbases and both warehouse anchors:

```text
Main airbase: Kandahar / ID 7
Main warehouse: WH_AIR_US_KANDAHAR / container_40ft

Heliport airbase: Kandahar Heliport / ID 15
Heliport warehouse: WH_AIR_US_KANDAHAR_HELI / container_20ft
```

All nine approved physical SQUADRON templates passed their type, grouping, and inventory-arithmetic checks:

```text
16 A-10C_2
6 UH-60A representations of HH-60G
12 C-130J-30
4 RQ-1A Predator representations of MQ-1
2 MQ-9 Reaper
8 AH-64D_BLK_II
16 OH58D
16 CH-47Fbl1
32 UH-60A
```

The six-airframe MC-12 component remained deferred as designed.

## Failure

`AIRWING:New("WH_AIR_US_KANDAHAR", "AW_US_KAF_451_AEW")` automatically associated the Main AIRWING with Kandahar Heliport instead of Kandahar Main:

```text
expected airbase ID: 7
actual automatic airbase ID: 15
```

The Heliport AIRWING correctly associated with ID 15.

The resulting preflight line was:

```text
RESULT: FAIL violations=1 noStart=true noSpawn=true noMission=true noTransport=true noPayloadMutation=true noParkingMutation=true
```

Because the preflight fails closed, the nine SQUADRON constructors were not executed after the AIRWING binding violation.

## Root cause

MOOSE automatically associates a WAREHOUSE/AIRWING with an airbase inside its automatic connection radius. Kandahar Main and Kandahar Heliport are close enough that automatic selection is ambiguous for `WH_AIR_US_KANDAHAR`.

This is not a warehouse-name, warehouse-anchor, airbase-name, or airbase-ID defect. It is an automatic proximity-association ambiguity.

## Correction

The preflight now uses the native MOOSE method:

```lua
airwing:SetAirbase(expectedAirbase)
```

for both AIRWINGs immediately after construction and before SQUADRON registration. The final binding is then verified through `GetAirbase()` with a fallback to the public object field used by the installed MOOSE version.

Builder version advanced to:

```text
KAF-DUAL-AIRWING-REGISTRATION-PREFLIGHT-2
```

The builder now requires the `:SetAirbase(` token and continues to reject all Start, spawn, mission, transport, payload, and parking-mutation APIs.

## Safety result

The failed run remained inside the intended safety boundary:

```text
no AIRWING start
no Kandahar SQUADRON registration after the violation
no Kandahar asset spawn
no AUFTRAG
no OPSTRANSPORT
no payload mutation
no parking mutation
```

The `bhHook.lua` shutdown error remains an external Saved Games hook error and is unrelated to this Kandahar preflight.

## Retest requirement

Rebuild with version 2, replace the embedded preflight bundle, run the mission, and return the new `dcs.log`.

Required final result:

```text
RESULT: PASS airwings=2 squadrons=9 registeredAirframes=112 deferredMC12=6 noStart=true noSpawn=true noMission=true noTransport=true noPayloadMutation=true noParkingMutation=true
```
