# Kandahar Dual-AIRWING Registration Preflight – Runtime Result 2026-08-01

## Result

```text
PASS – explicit dual-airbase binding and all nine SQUADRON registrations validated
```

Evidence files supplied by the project owner:

```text
dcs(104).log
debrief(57).log
```

Runtime environment:

```text
DCS 2.9.28.26385 MT
Successful test time: 2026-08-01 15:32:40 UTC
Embedded source mission metadata: OMW_Template_v4_Kandahar(4).miz
Embedded mission SHA-256: 0732f929d4e35641c84bfb34bd75912692c3a1b7b7a0106847ce56e21aa5345c
Expected embedded MOOSE SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

The supplied `dcs(104).log` also contains the earlier failed run at 15:22:11 UTC. This result evaluates the later corrected run beginning at 15:32:40 UTC.

## Airbase and warehouse validation

Both native airbases and warehouse anchors resolved exactly as required:

```text
Main airbase: Kandahar / ID 7 / category Airdrome
Main warehouse: WH_AIR_US_KANDAHAR / container_40ft / coalition blue

Heliport airbase: Kandahar Heliport / ID 15 / category Helipad
Heliport warehouse: WH_AIR_US_KANDAHAR_HELI / container_20ft / coalition blue
```

## Explicit AIRWING binding validation

The Main AIRWING constructor initially selected Kandahar Heliport through automatic proximity association, reproducing the previously diagnosed ambiguity:

```text
AW_US_KAF_451_AEW
initialID=15
expectedID=7
```

The version-2 preflight then explicitly rebound the AIRWING through native MOOSE `SetAirbase()` and verified the final result:

```text
AIRWING_AIRBASE_BOUND key=Main airwing=AW_US_KAF_451_AEW initialID=15 expectedID=7 actualID=7 explicit=true
AIRWING_CONSTRUCTED key=Main name=AW_US_KAF_451_AEW warehouse=WH_AIR_US_KANDAHAR airbase=Kandahar airbaseID=7 running=false
```

The Heliport AIRWING remained correctly associated with ID 15 and was also explicitly verified:

```text
AIRWING_AIRBASE_BOUND key=Heliport airwing=AW_US_KAF_159_CAB_TF_THUNDER initialID=15 expectedID=15 actualID=15 explicit=true
AIRWING_CONSTRUCTED key=Heliport name=AW_US_KAF_159_CAB_TF_THUNDER warehouse=WH_AIR_US_KANDAHAR_HELI airbase=Kandahar Heliport airbaseID=15 running=false
```

Neither AIRWING was started.

## SQUADRON registration validation

All nine approved physical SQUADRON objects registered under the correct AIRWING:

### AW_US_KAF_451_AEW

```text
SQ_US_KAF_A10C_74_EFS
8 asset groups x 2 = 16 A-10C_2

SQ_US_KAF_HH60G_26_ERQS
6 asset groups x 1 = 6 UH-60A representations of HH-60G

SQ_US_KAF_C130_772_EAS
12 asset groups x 1 = 12 C-130J-30

SQ_US_KAF_MQ1_361_ERS
4 asset groups x 1 = 4 RQ-1A Predator representations of MQ-1

SQ_US_KAF_MQ9_361_ERS
2 asset groups x 1 = 2 MQ-9 Reaper
```

### AW_US_KAF_159_CAB_TF_THUNDER

```text
SQ_US_KAF_AH64_4_227_AVN
4 asset groups x 2 = 8 AH-64D_BLK_II

SQ_US_KAF_OH58D_7_17_CAV
8 asset groups x 2 = 16 OH58D

SQ_US_KAF_CH47_7_101_GSAB
16 asset groups x 1 = 16 CH-47Fbl1

SQ_US_KAF_UH60_7_101_GSAB
32 asset groups x 1 = 32 UH-60A
```

MOOSE emitted internal `New asset` records while the SQUADRONs were added to the AIRWING warehouses. These are logical warehouse asset records created by registration, not spawned DCS world units.

## Deferred component

The MC-12 component remained deferred exactly as designed:

```text
361st Expeditionary Reconnaissance Squadron
Type: MC-12
Airframes: 6
Reason: NO_APPROVED_DCS_TEMPLATE_OR_SQUADRON_IDENTIFIER
```

## Final result line

```text
RESULT: PASS airwings=2 squadrons=9 registeredAirframes=112 deferredMC12=6 noStart=true noSpawn=true noMission=true noTransport=true noPayloadMutation=true noParkingMutation=true
```

No `VIOLATION` line occurred in the corrected run.

## Negative evidence and safety boundary

The corrected run remained inside the approved preflight boundary:

```text
no AIRWING start transition
no SQUADRON/Cohort start transition
no DCS aircraft spawn caused by the Kandahar preflight
no AUFTRAG construction or queueing
no OPSTRANSPORT construction or queueing
no COMMANDER or CHIEF construction
no payload-stock creation or mutation
no parking allowlist, blocklist, or safe-parking mutation
```

The debrief contains no birth events attributable to the preflight and the graveyard remained empty. The only aircraft-control events are the project-owner client-control events.

## External log findings

The known Saved Games shutdown-hook error remains present:

```text
bhHook.lua:168: attempt to index upvalue 'tcp' (a nil value)
```

It occurs outside the Kandahar preflight and does not affect this acceptance result. The DCS installation also reports unrelated module and asset-definition warnings during application initialization.

## Acceptance boundary

This PASS validates:

```text
both warehouse anchors;
both native airbase identities;
explicit AIRWING-to-airbase binding;
construction of both AIRWING objects;
registration of all nine approved physical SQUADRON objects;
112 logical MOOSE airframes;
continued deferral of six MC-12;
non-running AIRWING state;
absence of productive mission, transport, payload, parking, or spawn behavior.
```

This PASS does not authorize:

```text
AIRWING:Start();
payload registration;
mission capability registration;
AUFTRAG or OPSTRANSPORT;
physical asset spawning;
safe-parking configuration;
COMMANDER integration;
productive loss, return, repair, or persistence logic.
```
