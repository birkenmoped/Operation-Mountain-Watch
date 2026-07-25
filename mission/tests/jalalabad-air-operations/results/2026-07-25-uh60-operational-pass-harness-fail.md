# UH-60 GROUP_CARGO test: operational success, harness false FAIL

Date: 2026-07-25  
Test: `UH60_TROOP`  
Tested source commit: `5c8c9a20d07a93dd6f7837736bf8d6117ed8fcaf`  
DCS: `2.9.28.26283`  
Runtime result: **OPERATIONAL PASS / HARNESS FAIL**  
Correction status: **IMPLEMENTED / DCS RETEST PENDING**

## Result summary

The UH-60 completed the native MOOSE `OPSTRANSPORT` group-cargo operation successfully:

- the assigned UH-60 spawned and received the vertical takeoff/landing option;
- engine start and takeoff were observed;
- the troop group was loaded at the pickup zone;
- the troop group was unloaded alive in the deploy zone;
- `OPSTRANSPORT` reached `DELIVERED` with `1/1` cargo delivered;
- the independent physical objective passed;
- the exact FLIGHTGROUP was armed with `SetDespawnAfterLanding()` only after delivery;
- the UH-60 returned to Jalalabad and landed at the exact home airbase;
- MOOSE then performed the intended final despawn.

The test harness nevertheless classified the run as FAIL because it treated the resulting `FLIGHTGROUP:OnAfterDead` callback as an aircraft loss. The debrief contains no UH-60 crash or physical dead event.

## Authoritative event sequence

```text
17:35:22  NATIVE_CARGO event=Unloaded
17:35:40  NATIVE_STATE state=DELIVERED
17:35:40  LOGISTICS_OBJECTIVE PASS
17:35:40  LOGISTICS_FINAL_DESPAWN armedFlightGroups=1
17:36:03  FLIGHTGROUP_EVENT stage=RTB_REQUESTED
17:38:46  EVENT stage=LAND_AT_JALALABAD_EXACT
17:38:46  FLIGHTGROUP OnAfterDead from intended final despawn
17:38:46  erroneous TERMINAL_LOSS / TransportCancel / RESULT FAIL
```

## Root cause

The observer and routing finalizer used `FLIGHTGROUP:OnAfterDead` as an unconditional loss signal. In the pinned MOOSE lifecycle, the same callback also occurs when `FLIGHTGROUP:SetDespawnAfterLanding()` removes a successfully recovered aircraft after landing.

The false loss path then called `AIRWING:TransportCancel()` on an already delivered transport and finalized the test with `released=false`, preventing the normal controller path from waiting for stable AIRWING inventory restoration.

## Correction

The routing finalizer now distinguishes the intended MOOSE final despawn from a real aircraft loss.

An `OnAfterDead` callback is classified as `EXPECTED_FINAL_DESPAWN` only when all of the following are true for the exact bound FLIGHTGROUP:

- final despawn was explicitly armed after objective completion;
- the independent physical objective is satisfied;
- the native operation reached its configured terminal state;
- RTB was observed;
- every expected unit of that FLIGHTGROUP completed the final Jalalabad landing;
- no scoped DCS `Crash` or `Dead` event was recorded for that FLIGHTGROUP.

In this case the observer-generated `flightgroup-dead-*` hard failure is cleared, no transport cancellation is issued, and the controller remains active until MOOSE reports stable asset release and restored inventory.

All other `FLIGHTGROUP:OnAfterDead` callbacks remain immediate terminal failures. Scoped DCS `Crash` and `Dead` events remain authoritative physical-loss evidence, including after cargo delivery.

## Required retest evidence

The next UH-60 run must contain:

```text
LOGISTICS_OBJECTIVE PASS
LOGISTICS_FINAL_DESPAWN armedFlightGroups=1
EVENT ... stage=LAND_AT_JALALABAD_EXACT
EXPECTED_FINAL_DESPAWN ... classification=NON_LOSS waitForAssetRelease=true
ACCEPTANCE event=ASSET_RELEASED
RESULT testId=UH60_TROOP classification=PASS ... released=true
```

It must not contain:

```text
TERMINAL_LOSS ... group=<successful UH-60>
ABORT_REQUEST ... reason=terminal-aircraft-loss
RESULT testId=UH60_TROOP classification=FAIL
```

Final UH-60 inventory must return to the baseline:

```text
total=8
stock=8
spawned=0
onMission=0
```

A separate destructive regression remains required to prove that a genuine UH-60 crash or dead event still produces immediate FAIL, even after the cargo objective has already been completed.
