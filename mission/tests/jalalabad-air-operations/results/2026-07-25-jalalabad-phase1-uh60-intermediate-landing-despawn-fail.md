# Jalalabad Phase 1 – UH-60 pickup landing / premature despawn failure

Date: 2026-07-25  
Classification: **DCS FAIL**  
Mission: `OMW_Jalalabad_AirOps_Phase1_Test.miz`  
Evidence: `dcs(65).log`, `debrief(22).log`

## Observed sequence

The UH-60 transport asset:

1. spawned at Jalalabad;
2. started its engine;
3. departed Jalalabad;
4. flew to the troop pickup location;
5. landed at the pickup location;
6. was removed after that intermediate landing;
7. never transported the infantry to the dedicated drop-off zone;
8. never returned to Jalalabad.

The debrief contains an engine start, one takeoff from Jalalabad and one landing without an airbase assignment. It contains no second takeoff, no drop-off landing and no final Jalalabad landing.

## Root causes

### 1. Squadron-wide automatic despawn after every landing

The UH-60 squadron used:

```lua
squadron:SetDespawnAfterLanding(true)
```

That setting is incompatible with a transport profile containing intermediate pickup and drop-off landings. The pickup landing was treated as a despawn opportunity before the transport lifecycle was complete.

### 2. False pickup inference

The previous objective observer inferred pickup when the infantry group was no longer alive or no longer located inside the pickup zone:

```lua
if not runtime.TroopsPickedUpObserved and (not alive or not atPickup) then
  runtime.TroopsPickedUpObserved = true
end
```

This is not proof of boarding. MOOSE may temporarily hide, deactivate or otherwise change the runtime representation of cargo. The log therefore produced a pickup confirmation immediately after the initial takeoff, before the helicopter had physically landed at the pickup location.

### 3. Broad-radius landing classification

The generic observer classified every landing within the large Jalalabad RTB radius as a final base landing. The pickup landing, approximately 867 metres from the airbase reference coordinate, was consequently counted as `LAND_AT_JALALABAD` even though the DCS debrief did not associate the landing with Jalalabad.

### 4. Native mission terminal state was not rejected early enough

A `DONE`, `SUCCESS`, `FAILED` or `CANCELLED` state before verified pickup and unload could be deferred instead of immediately invalidating the transport test. This allowed MOOSE terminal behaviour and the physical transport result to diverge.

## Corrective implementation in PHASE1-9

### Intermediate landings

The UH-60 squadron now uses:

```lua
squadron:SetDespawnAfterLanding(false)
```

Automatic final despawn is armed on the active FLIGHTGROUP only after MOOSE reports a completed unload. Pickup and drop-off landings therefore cannot destroy the carrier.

### Native MOOSE transport lifecycle

The test now observes the active FLIGHTGROUP callbacks:

```text
OnAfterLoadingDone
OnAfterUnloaded
OnAfterUnloadingDone
```

The disappearance or movement of the infantry group is no longer accepted as proof of pickup.

### Strict physical sequence

The objective requires all of the following:

```text
initial takeoff
pickup landing observed inside the load zone
MOOSE LoadingDone
second takeoff after pickup
landing inside the dedicated drop-off zone
MOOSE Unloaded
MOOSE UnloadingDone
infantry alive inside the dedicated drop-off zone
```

Only after all conditions are true can objective-driven success be set.

### Exact final base landing

For `UH60_TROOP`, the broad five-kilometre RTB radius is disabled. Final RTB and landing are confirmed only when the DCS landing event identifies Jalalabad as the actual place.

Pickup and drop-off landings are recorded separately as operational intermediate landings and do not increment the final landing count.

### Premature terminal states

Any native mission terminal state before the strict physical objective is complete produces a hard test failure:

```text
transport-terminal-before-verified-dropoff-done
transport-terminal-before-verified-dropoff-success
transport-terminal-before-verified-dropoff-failed
transport-terminal-before-verified-dropoff-cancelled
```

A carrier that disappears before verified unload similarly fails with:

```text
transport-carrier-despawned-before-verified-dropoff
```

## Required retest evidence

Expected chronological markers:

```text
TROOP_LIFECYCLE_CONFIGURED
CARRIER_CALLBACKS_ATTACHED
DEPART_BASE
PICKUP_LANDING_OBSERVED
LOADING_DONE
DEPART_PICKUP
DROPOFF_LANDING_OBSERVED
CARGO_UNLOADED
UNLOADING_DONE
FINAL_LANDING_DESPAWN_ARMED
PHYSICAL_OBJECTIVE_CONFIRMED
DEPART_DROPOFF
LAND_AT_JALALABAD_EXACT
ASSET_RELEASED
RESULT ... classification=PASS
```

The order is mandatory. Missing or reordered lifecycle stages remain a DCS FAIL.

## Status

```text
Implementation: PHASE1-9
Static repository update: complete
DCS runtime validation: pending
```
