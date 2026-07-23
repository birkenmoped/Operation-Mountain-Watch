# Jalalabad complete Mission Editor state: configuration PASS, bundle/finalizer and static-parking FAIL

## Date

2026-07-23

## Classification

```text
Mission Editor names/types/counts/zones: PASS
UH-60 livery correction: PASS
SQUADRON construction: PASS
AIRWING/COMMANDER activation: NOT TESTED
Bundle finalizer selection: FAIL
Static-to-parking clearance: FAIL
Overall: PARTIAL / retest required
```

## Evidence files

```text
Operation_Mountain_Watch_Jalalabad_AirOps_Test_01(5).miz
SHA256 5306781424561f7ec7fed8df772ed3c5d5be22df8dc8625a0f64924daad1ebfd

dcs(56).log
SHA256 1080ddfa0c76236e1fef0da8b1613bc9e08f9ba48c3f982eccb80e58afe1c6fb

debrief(13).log
SHA256 8a56cb93097303437b9010e9f387980bef65e328fe098fc2288a88e70e474ba1
```

Embedded bundle:

```text
BuilderVersion JBAD-AIR-OPS-COMPLETE-2
GitCommit     1780081b6f67a0e2d78d2b0600535bf9e500c27f
GeneratedUtc  2026-07-23T22:26:09.9209444Z
SHA256        9095b6291fe99d6feb3762ddffe900003051e6211eeb6a469b606ac0ed8d29c4
```

## Confirmed Mission Editor state

The mission contains and DCS/MOOSE recognizes:

```text
6/6 required Client groups
5/5 AI template groups
20/20 aircraft statics
11/11 functional trigger zones
1/1 warehouse anchor
```

The UH-60 templates both use the required livery:

```text
TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP  livery=standard
TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP livery=standard
```

All four SQUADRON objects were constructed successfully:

```text
SQ_US_JBAD_OH58D_6_6_CAV
24 aircraft / 12 two-ship asset groups

SQ_US_JBAD_AH64D_B_1_10_AVN
8 aircraft / 4 two-ship asset groups

SQ_US_JBAD_UH60_UTILITY_MEDEVAC
8 aircraft / 8 single-ship asset groups

SQ_US_JBAD_CH47_HEAVYLIFT
8 aircraft / 8 single-ship asset groups
canonical type CH-47Fbl1
```

The 11 zones were found by both the template validator and the final complete-node validator.

The uploaded `.miz` was inspected directly:

- all seven OH-58D statics are inside `ZONE_AIR_US_JBAD_STATIC_OH58D`;
- all four AH-64D statics are inside `ZONE_AIR_US_JBAD_STATIC_AH64D`;
- all four UH-60A statics are inside `ZONE_AIR_US_JBAD_STATIC_UH60`;
- all five CH-47 statics are inside `ZONE_AIR_US_JBAD_STATIC_CH47`;
- both UH-60 MEDEVAC template positions are inside `ZONE_AIR_US_JBAD_MEDEVAC_READY`;
- the CH-47 heavy-lift template is inside `ZONE_AIR_US_JBAD_CH47_READY`.

The smaller radii chosen in the Mission Editor are sufficient for the currently intended objects. The remaining load/unload zones are present but their later mission behavior is not yet runtime-tested.

## Failure 1: builder embedded the obsolete finalizer

The bootstrap in the embedded bundle correctly used the revised runtime model:

```text
clients=6+2optional
dynamicAIReserve=4
runtimeDemand=10+2optional
templateAircraft=7(non-runtime)
```

The finalizer embedded by the builder still checked the obsolete fields:

```text
AITemplateSeedPositions=7
CoreOperationalDemand=13
OperationalDemandWithUH60L=15
```

This produced the only complete-node configuration error:

```text
ERROR: Parking model does not match the locked 36-position Jalalabad plan.
RESULT: INCOMPLETE. AIRWING and COMMANDER remain unstarted.
```

Root cause:

`tools/build-jalalabad-air-operations-bundle.ps1` still included:

```text
09-finalize-jalalabad-node.lua
```

instead of the already corrected source:

```text
10-validate-and-start-complete-node.lua
```

Corrective repository actions:

- builder now includes `10-validate-and-start-complete-node.lua`;
- obsolete `09-finalize-jalalabad-node.lua` was deleted;
- builder version raised to `JBAD-AIR-OPS-COMPLETE-4`;
- a static-to-parking clearance gate was added before final activation.

## Failure 2: four CH-47 statics overlap functional parking nodes

Direct comparison of `.miz` static coordinates with the 50 MOOSE parking coordinates found:

```text
STATIC_AIR_US_JBAD_CH47_01  nearest TerminalID 49  distance 4.1 m
STATIC_AIR_US_JBAD_CH47_02  nearest TerminalID 37  distance 4.5 m
STATIC_AIR_US_JBAD_CH47_03  nearest TerminalID 23  distance 4.7 m
STATIC_AIR_US_JBAD_CH47_04  nearest TerminalID 35  distance 5.4 m
STATIC_AIR_US_JBAD_CH47_05  nearest parking distance 33.5 m
```

DCS reports the first four parking nodes as `Free=true` because a free-placed static does not reserve a DCS parking node. MOOSE could therefore select one of these apparently free positions and create a collision or blocked spawn.

Required correction:

Move `STATIC_AIR_US_JBAD_CH47_01` through `_04` so each static center is at least eight metres from every functional parking-node center. A larger practical clearance is preferred where the apron permits it. `STATIC_AIR_US_JBAD_CH47_05` is already clear.

A new automatic gate now checks every Jalalabad aircraft static against all 50 parking nodes and blocks final activation when the center distance is below eight metres.

## Runtime evidence

The test ran for 97.243 seconds.

The Jalalabad AIRWING and COMMANDER were not started because the obsolete finalizer rejected the parking manifest. Therefore this run does not validate post-start stability or spontaneous-spawn behavior.

The debrief contains:

- mission start;
- player control of `CLIENT_US_JBAD_OH58D_01-1`;
- an unrelated existing Bagram OH-58D engine-start event at 78.8 seconds;
- mission end at 97.243 seconds.

No Jalalabad AI takeoff, landing, crash or loss event was recorded.

## Non-OMW side findings

The latest mission run contains no OMW timer-function error, Lua stack traceback or AirOps script exception.

Separate DCS/module messages were present and did not cause the AirOps result:

```text
OH58D: Corrupt damage model
OH-58D cockpit/device and sound prototype warnings
CH-47Fbl1 effect-preset warning during DCS initialization
Saved Games hook bhHook.lua: tcp is nil during mission shutdown
```

These messages are external to the Jalalabad AirOps bundle. The `bhHook.lua` error occurs after mission termination and has already been observed independently in prior tests.

## Retest requirements

1. Pull the corrected branch.
2. Rebuild bundle version `JBAD-AIR-OPS-COMPLETE-4`.
3. Reselect the generated bundle in Mission Editor `DO SCRIPT FILE`.
4. Move CH-47 statics `_01` through `_04` away from functional parking-node centers.
5. Save the `.miz`.
6. Run at least 60 seconds.
7. Confirm parking-clearance PASS, complete-node PASS, AIRWING start, COMMANDER link and no spontaneous Jalalabad spawn.

No group, unit, static or zone name must be changed.
