# UH-60 MOOSE-first zone correction

Date: 2026-07-25

Branch: `feature/jalalabad-airwing-phase1-functional-tests`

## Observed regression

The test aborted before spawning a UH-60 with:

```text
RESULT testId=UH60_TROOP classification=FAIL reason=operation-create-failed: UH-60 logistics zone too small for separated landing/cargo geometry
```

No Mission Editor trigger, trigger condition, zone name or mission object had changed. The failure was introduced by project code in `13-phase1-mission-factory.lua`.

The removed `safeOffset()` helper imposed an undocumented minimum source-zone radius. Existing mission zones smaller than that derived threshold were rejected before `OPSTRANSPORT` could be created.

## MOOSE-first review

The correction was made only after reviewing:

1. Official MOOSE Develop documentation:
   - `Ops.OpsTransport`
   - `Core.Zone`
2. Pinned MOOSE source commit:
   - `73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`
   - `OpsTransport.lua`
   - `OpsGroup.lua`
   - `Zone.lua`
   - `Utils.lua`

The review established these authoritative responsibilities:

- `OPSTRANSPORT:SetPickupZone()` controls the carrier pickup location.
- `OPSTRANSPORT:SetDeployZone()` controls the carrier deploy location.
- `OPSTRANSPORT:SetEmbarkZone()` controls where cargo is accepted for embarkation.
- `OPSTRANSPORT:SetDisembarkZone()` controls where cargo is placed after unloading.
- `ZONE_RADIUS:GetClearZonePositions()` is the existing MOOSE function for finding positions clear of terrain objects and obstructions.

The earlier implementation incorrectly tried to control the helicopter landing point with `SetEmbarkZone()`. Pinned MOOSE `OPSGROUP:onafterPickup()` and `OPSGROUP:onafterTransport()` actually choose the helicopter waypoint from `PickupZone` and `DeployZone` respectively.

## Correction

The project-specific zone-radius requirement and manual fixed-bearing offset were removed.

The existing Mission Editor zones remain unchanged and are used as MOOSE search and objective areas.

For each source zone, MOOSE now:

1. Calls `ZONE_RADIUS:GetClearZonePositions()` to find obstruction-free candidates.
2. Selects one clear coordinate for the carrier landing point.
3. Selects a separate clear coordinate for troop embarkation or disembarkation.
4. Creates small runtime `ZONE_RADIUS` carrier zones around the selected landing coordinates.
5. Applies only public `OPSTRANSPORT` APIs:
   - `SetPickupZone()`
   - `SetEmbarkZone()`
   - `SetDeployZone()`
   - `SetDisembarkZone()`

The constructor still receives the original Mission Editor zones so that MOOSE can register the cargo transport combination correctly. The public setters then separate carrier movement from cargo placement.

## Trigger contract

No Mission Editor trigger changes are required.

No existing zone is renamed, resized, moved or replaced by this commit.

## Static validation

`13-phase1-mission-factory.lua` passed:

```text
texluac -p
```

The GitHub compare for the code correction contains only:

```text
mission/tests/jalalabad-air-operations/src/13-phase1-mission-factory.lua
```

## Required DCS retest evidence

At operation creation:

```text
MOOSE_CLEAR_GEOMETRY role=PICKUP
MOOSE_CLEAR_GEOMETRY role=DROPOFF
GROUP_TRANSPORT_GEOMETRY ... authority=OPSTRANSPORT:SetPickupZone/SetEmbarkZone/SetDeployZone/SetDisembarkZone
```

The obsolete failure must not appear:

```text
UH-60 logistics zone too small for separated landing/cargo geometry
```

The operational completion contract remains:

```text
LOGISTICS_OBJECTIVE PASS
EVENT ... stage=LAND_AT_JALALABAD_EXACT
EXPECTED_FINAL_DESPAWN ... classification=NON_LOSS
AIRWING_EVENT ... event=LEGION_ASSET_RETURNED
ACCEPTANCE event=ASSET_RELEASED
RESULT testId=UH60_TROOP classification=PASS ... released=true
```
