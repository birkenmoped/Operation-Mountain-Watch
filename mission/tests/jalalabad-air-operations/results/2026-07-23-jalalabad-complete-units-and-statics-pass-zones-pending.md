# Jalalabad complete-node acceptance – units/statics PASS, zones pending

## Status

```text
PARTIAL PASS
```

The corrected Jalalabad `24/8/8/8` package was executed in DCS. All required player groups, all AI templates, all visible aircraft statics, the warehouse anchor and all four MOOSE SQUADRON constructions passed. The final activation gate correctly remained closed because all eleven functional zones were still absent.

A separate Mission Editor configuration defect was found: the UH-60 MEDEVAC cover template used the `Egyptian Air Force` livery while the lead template used `standard`. The run therefore proves type and SQUADRON construction, but the livery must be corrected before final acceptance.

## Test environment

```text
DCS version: 2.9.28.26283 MT
Mission: Operation_Mountain_Watch_Jalalabad_AirOps_Test_01.miz
Mission duration: 41.85 seconds
```

The debrief contained mission start, took control and mission end only. No aircraft birth, takeoff, landing, loss or combat event was recorded.

## Confirmed PASS results

### Airbase and warehouse

```text
Jalalabad Airbase ID: 19
Warehouse anchor: WH_AIR_US_JALALABAD
DCS warehouse: available
MOOSE storage: available
AIRWING construction: successful
Explicit Jalalabad association: successful
```

### Required player groups

```text
present=6
missing=0
```

Confirmed:

```text
CLIENT_US_JBAD_OH58D_01   type=OH58D          size=1
CLIENT_US_JBAD_OH58D_02   type=OH58D          size=1
CLIENT_US_JBAD_AH64D_01   type=AH-64D_BLK_II  size=1
CLIENT_US_JBAD_AH64D_02   type=AH-64D_BLK_II  size=1
CLIENT_US_JBAD_CH47_01    type=CH-47Fbl1       size=1
CLIENT_US_JBAD_CH47_02    type=CH-47Fbl1       size=1
```

### Required AI templates

```text
present=5
missing=0
```

Confirmed:

```text
TPL_AIR_US_JBAD_OH58D_RECON_2SHIP          type=OH58D          size=2
TPL_AIR_US_JBAD_AH64D_CAS_2SHIP            type=AH-64D_BLK_II  size=2
TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP    type=UH-60A         size=1
TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP   type=UH-60A         size=1
TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP       type=CH-47Fbl1      size=1
```

The canonical DCS type of the available CH-47F was confirmed as:

```text
CH-47Fbl1
```

### Optional UH-60L player slots

```text
present=0
missing=2
accepted=true
coreMissionUnaffected=true
```

This is the intended mod-free core configuration.

### Visible aircraft statics

```text
present=20
missing=0
```

Confirmed static counts and types:

```text
7 x OH58D
4 x AH-64D_BLK_II
4 x UH-60A
5 x CH-47Fbl1
```

### MOOSE SQUADRON construction

```text
SQ_US_JBAD_OH58D_6_6_CAV
24 aircraft / 12 two-ship asset groups / RECON

SQ_US_JBAD_AH64D_B_1_10_AVN
8 aircraft / 4 two-ship asset groups / CAS

SQ_US_JBAD_UH60_UTILITY_MEDEVAC
8 aircraft / 8 single-ship asset groups / TRANSPORT, LAND, GROUNDESCORT
MEDEVAC package 1 lead + 1 cover

SQ_US_JBAD_CH47_HEAVYLIFT
8 aircraft / 8 single-ship asset groups / TROOPTRANSPORT, CARGOTRANSPORT, LAND
```

### Ramp and inventory model

```text
logical inventory: 24 OH-58D / 8 AH-64D / 8 UH-60 / 8 CH-47
player aircraft per type at Jalalabad: 2
static caps: 7 / 4 / 4 / 5
core operational positions: 13
optional UH-60L positions: 2
comparable helicopter positions: 36
virtual reserve: enabled
```

## Outstanding blocker: all eleven zones missing

```text
ZONE_AIR_US_JBAD_STATIC_OH58D
ZONE_AIR_US_JBAD_STATIC_AH64D
ZONE_AIR_US_JBAD_STATIC_UH60
ZONE_AIR_US_JBAD_STATIC_CH47
ZONE_AIR_US_JBAD_MEDEVAC_READY
ZONE_AIR_US_JBAD_CH47_READY
ZONE_AIR_US_JBAD_HEAVYLIFT_LOAD
ZONE_AIR_US_JBAD_LOGISTICS_LOAD
ZONE_AIR_US_JBAD_LOGISTICS_UNLOAD
ZONE_AIR_US_JBAD_SLING_PICKUP
ZONE_AIR_US_JBAD_C130_UNLOAD
```

Validator summary:

```text
ZONE present=0 missing=11
```

Correct finalizer response:

```text
RESULT: INCOMPLETE. AIRWING and COMMANDER remain unstarted; correct all preceding ERROR/MISSING lines.
```

This is fail-safe behavior and is therefore a PASS for the activation gate itself.

## Mission Editor defect: UH-60 cover livery

Observed:

```text
MEDEVAC Lead:  livery=standard
MEDEVAC Cover: livery=Egyptian Air Force
```

Required correction:

```text
TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP
livery: standard
```

Both UH-60A MEDEVAC templates must use the `standard` livery.

The repository code was tightened after this run. `08-construct-uh60-squadron.lua` now validates the livery of both templates and refuses UH-60 SQUADRON construction if either differs from `standard`.

## Unrelated log entry

At mission shutdown, the existing Saved Games hook again produced:

```text
bhHook.lua:168: attempt to index upvalue 'tcp' (a nil value)
```

This occurs after Dispatcher stop and is unrelated to the Jalalabad AirOps bundle.

## Required retest

1. Correct the MEDEVAC cover livery to `standard`.
2. Add all eleven named trigger zones.
3. Pull the latest branch commit.
4. Rebuild `OMW_AirOps_Jalalabad.lua`.
5. Reselect it in Mission Editor `DO SCRIPT FILE` and save the `.miz`.
6. Run the mission for at least 45 seconds.
7. Verify that the finalizer reports `RESULT: COMPLETE` and that no spontaneous aircraft spawn occurs.
8. Provide the new `dcs.log`; the `.miz` is not required unless the log remains inconsistent.
