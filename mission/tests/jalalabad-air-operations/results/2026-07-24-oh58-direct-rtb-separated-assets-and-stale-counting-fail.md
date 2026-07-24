# Jalalabad Phase 1 OH-58D operational failure and corrective design

## Status

`FAIL CONFIRMED / PHASE1-6 IMPLEMENTED / DCS RETEST PENDING`

The test mission remains under Mission Editor ownership. No `.miz` was created or modified by the code change.

## Evidence

The Phase1-5 DCS run proved that both independent OH-58D single-ship groups spawned, started, took off, reached all three reconnaissance zones and landed at Jalalabad. It also exposed three separate design defects.

### Independent aircraft were not a two-ship

The two helicopters were recruited as two independent one-aircraft DCS groups. Their reconnaissance progress differed by many minutes and they flew several miles apart. A MOOSE request for two assets does not turn two independent DCS groups into one tactical formation.

### Return route was unsafe

The generated route profile was:

```text
Jalalabad -> RECON_01 -> RECON_02 -> RECON_03 -> Jalalabad
```

The final direct leg from `RECON_03` to Jalalabad was approximately 33.5 km and crossed the highest sampled terrain of the route. DCS therefore returned in terrain-following flight rather than retracing the safe outbound corridor.

### Status displayed a stale landing error

The log recorded both landing events and the counters showed `2/2`, but `LastPendingCriterion` still displayed `landing-count-mismatch`. The actual landing count was correct; the displayed pending reason had not been cleared while the controller waited for inventory release.

## Phase1-6 correction

### Physical two-ship

OH-58D now uses:

```text
SQUADRON:SetGrouping(2)
required asset groups: 1
required aircraft:     2
exact units:           <group>-01 and <group>-02
```

This delegates tactical formation keeping to one physical DCS group instead of attempting to coordinate two unrelated single-ship groups.

### Explicit reverse recovery corridor

The recovery route is now explicitly constructed with MOOSE mechanisms:

```text
RECON_03 -> RECON_02 -> RECON_01 -> Jalalabad
```

`AUFTRAG:SetMissionEgressCoord()` sets `RECON_02` as the egress point. After MOOSE creates the FLIGHTGROUP route, `FLIGHTGROUP:AddWaypoint()` inserts `RECON_01` directly after the egress waypoint and before the existing Jalalabad landing waypoint. `FLIGHTGROUP:UpdateRoute()` then activates the completed route.

A missing or unapplied recovery corridor is a test failure; direct return from the last reconnaissance point is no longer accepted.

### Landing/status correction

Both exact unit names are registered before event evaluation. Landing events remain deduplicated per unit. Once the complete lifecycle is satisfied, the pending status changes to `awaiting-inventory-release` instead of retaining a stale `landing-count-mismatch` message.

## Expected retest evidence

```text
OH58PhysicalTwoShip=true
expectedGroups=1
expectedAircraft=2
RECOVERY_CORRIDOR_CONFIGURED
RECOVERY_CORRIDOR_APPLIED
RECOVERY_CORRIDOR_READY
RECOVERY_ROUTE_PUSHED
Birth/Engine/TO/Land: 2/2/2/2
Pending: awaiting-inventory-release
RESULT testId=OH58D_RECON classification=PASS
```

The DCS retest must additionally confirm visually that the two aircraft remain in a usable formation and that the return flight follows `RECON_02` and `RECON_01` before Jalalabad.
