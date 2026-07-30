# Bagram AIRWING/SQUADRON Baseline – First DCS Run

Date: 2026-07-30
Mission: `OMW_Template_v4_Bagram.miz`
DCS: `2.9.28.26385`
Status: `FAIL_CORRECTED_PENDING_RETEST`

## Runtime evidence

The warehouse anchor and Bagram AIRWING were constructed successfully:

```text
[OMW][AirOps.BGRAM] AIRWING ready. name=AW_US_BAGRAM airbase=Bagram inventory=13/13/20/6/10/13 excluded=OH58D,MC12W,EC130H,EA6B,SEPARATE_ARMY_MEDEVAC.
```

SQUADRON construction did not complete:

```text
[OMW][AirOps.BGRAM.Squadrons] WAITING: TPL_AIR_US_BGRM_HH60G_CSAR_LEAD_1SHIP template missing
[OMW][AirOps.BGRAM.Squadrons] WAITING: TPL_AIR_US_BGRM_HH60G_CSAR_COVER_1SHIP template missing
[OMW][AirOps.BGRAM.Squadrons] WAITING: TPL_AIR_US_BGRM_UH60_TRANSPORT_1SHIP template missing
[OMW][AirOps.BGRAM.Squadrons] ERROR: Bagram squadron construction failed: ... attempt to call method 'AddMissionCapability' (a nil value)
[OMW][AirOps.BGRAM.Finalize] WAITING: required squadron missing: F15E
```

No final PASS or ACCOUNTING line was produced.

## Root cause

The Runtime configuration expected three Mission Editor templates that do not exist in the tested mission:

```text
TPL_AIR_US_BGRM_HH60G_CSAR_LEAD_1SHIP
TPL_AIR_US_BGRM_HH60G_CSAR_COVER_1SHIP
TPL_AIR_US_BGRM_UH60_TRANSPORT_1SHIP
```

The mission actually contains:

```text
TPL_AIR_US_BGRM_HH60G_CSAR_1SHIP
TPL_AIR_US_BGRM_UH60_UTILITY_1SHIP
```

A Lua table containing validation results omitted keys whose values were `nil`. The subsequent `pairs()` validation therefore did not detect every missing template. A SQUADRON constructor was reached with an invalid template name, which surfaced inside MOOSE at `SQUADRON:New()` as the misleading `AddMissionCapability` nil-method error.

This was an OMW validation defect, not evidence that the MOOSE `COHORT:AddMissionCapability()` API is absent. The same MOOSE bundle successfully constructed the Jalalabad SQUADRONs during the same mission run.

## Correction

The Bagram runtime now:

- uses the exact existing HH-60G and UH-60 Mission Editor template names;
- requires only one HH-60G seed and one UH-60 seed for the no-tasking construction baseline;
- validates every required template through an ordered list;
- fails closed before any SQUADRON constructor if any template is absent or has the wrong group size;
- checks `_DATABASE:GetGroupTemplate()` when available;
- constructs SQUADRONs in deterministic order;
- logs `CONSTRUCT`, `SQUADRON OK`, and the exact failing key for every SQUADRON.

Dedicated HH-60G lead/cover package behavior remains a later CSAR test. It is not required to prove the six-SQUADRON AIRWING inventory baseline.

## Retest acceptance

The next run must produce:

```text
TEMPLATE OK key=F15E
TEMPLATE OK key=F16C
TEMPLATE OK key=C130
TEMPLATE OK key=HH60G
TEMPLATE OK key=UH60
TEMPLATE OK key=CH47
SQUADRON OK key=F15E
SQUADRON OK key=F16C
SQUADRON OK key=C130
SQUADRON OK key=HH60G
SQUADRON OK key=UH60
SQUADRON OK key=CH47
SQUADRONS ready: F15E=6x2+1reserve F16C=6x2+1reserve C130=20x1 HH60G=6x1 UH60=10x1 CH47=13x1.
PASS: AW_US_BAGRAM started with exactly 6 squadrons and 75 logical airframes.
ACCOUNTING: MOOSE-managed=73 fighterLogicalReserve=2 total=75.
```

No merge, Ready-for-Review transition or operational acceptance is authorized by this result.