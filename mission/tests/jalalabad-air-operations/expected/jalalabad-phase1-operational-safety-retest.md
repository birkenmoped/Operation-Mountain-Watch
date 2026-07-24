# Jalalabad Phase 1 – operational safety retest

## Status

```text
IMPLEMENTED IN REPOSITORY
DCS VALIDATION PENDING
BuilderVersion: JBAD-AIR-OPS-PHASE1-4
Mission: OMW_Jalalabad_AirOps_Phase1_Test.miz
```

The mission file is continued under the same name. No parking, Client, Static, aircraft-template or AIRWING inventory placement is changed for this retest.

## Corrected scope

The retest validates four operational corrections:

1. OH-58D RECON is rejected before launch when the zone sequence is too distant, too steep or crosses terrain unsuitable for the configured safe altitude.
2. UH-60 troop transport uses a dedicated remote drop zone and cannot succeed merely because infantry moves near the pickup area.
3. UH-60 and CH-47 transport success requires the physical objective after takeoff; transient MOOSE `CANCELLED`/`FAILED` terminal reports are only normalized after that physical objective is confirmed.
4. The Jalalabad AIRWING requests the pinned MOOSE helicopter option `SetOptionPreferVerticalLanding()` to prefer vertical takeoff and landing instead of runway taxiing.

The MOOSE troop-transport constructor accepts both `GROUP` and `SET_GROUP`. Phase 1 now supplies an explicit `SET_GROUP` for clarity; this is not an API-compatibility workaround.

## Required Mission Editor changes

### 1. Reposition the three RECON zones

Keep the existing names:

```text
ZONE_TEST_US_JBAD_RECON_01
ZONE_TEST_US_JBAD_RECON_02
ZONE_TEST_US_JBAD_RECON_03
```

Place them in the Jalalabad valley or similarly open low terrain. The automatic preflight gate requires:

```text
maximum distance of each zone from Jalalabad: 18,000 m
minimum separation between consecutive zones: 1,500 m
maximum length of each route leg, including RTB: 11,000 m
maximum complete route length, including RTB: 42,000 m
maximum sampled terrain height on every leg: 1,300 m MSL
terrain sampling interval: 750 m
required vertical terrain clearance: 350 m AGL
maximum calculated mission altitude: 6,500 ft ASL
mission speed: 80 kt
mission range gate: 12 NM
```

The code calculates one safe RECON altitude from the highest sampled terrain point plus 350 m. A route crossing a high ridge is blocked even when all zone centres themselves are in lower terrain.

Expected log after valid placement:

```text
[OMW][AirOps.JBAD.PH1.OPSAFE] RECON_ROUTE PASS zones=3 route=... maxTerrain=... clearance=350m altitude=...ft_ASL speed=80kt
```

### 2. Add a dedicated UH-60 drop zone

Create one new normal trigger zone:

```text
Name:   ZONE_TEST_US_JBAD_UH60_DROPOFF
Radius: approximately 100–150 m
```

Placement requirements relative to `ZONE_AIR_US_JBAD_LOGISTICS_LOAD`:

```text
centre distance: 3,000–12,000 m
minimum free gap between both zone edges: 250 m
maximum terrain-height difference between both centres: 300 m
```

Use a flat, open landing area in the Jalalabad valley. Do not place it on the airfield, on a steep mountain slope or inside the existing logistics-load zone.

Expected log after valid placement:

```text
[OMW][AirOps.JBAD.PH1.OPSAFE] TROOP_ROUTE PASS ... dedicatedDropZone=ZONE_TEST_US_JBAD_UH60_DROPOFF
```

### 3. Check the troop template route

Template:

```text
TPL_GROUND_BLUE_JBAD_PHASE1_UH60_TROOPS
```

The group must have only its initial Mission Editor point and no movement waypoint or route away from the pickup area.

The automatic gate permits at most one route point. Additional route points block Phase 1 with:

```text
TROOP_ROUTE BLOCKED reason=troop template has ... route points; maximum=1
```

The group must remain inside:

```text
ZONE_AIR_US_JBAD_LOGISTICS_LOAD
```

at mission start.

## Repository and build

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch

git branch --show-current
git status --short
git fetch origin
git switch feature/jalalabad-airwing-phase1-functional-tests
git pull --ff-only
git rev-parse HEAD

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File ".\tools\build-jalalabad-air-operations-bundle.ps1"

Get-FileHash `
  .\mission\tests\jalalabad-air-operations\dist\OMW_AirOps_Jalalabad.lua `
  -Algorithm SHA256
```

The builder and `Get-FileHash` hashes must match.

## Embed into the same mission

In Mission Editor:

1. open `OMW_Jalalabad_AirOps_Phase1_Test.miz`;
2. update the three RECON zones;
3. create `ZONE_TEST_US_JBAD_UH60_DROPOFF`;
4. remove any additional route points from the troop template;
5. reselect the newly built `OMW_AirOps_Jalalabad.lua` in the existing `DO SCRIPT FILE` action;
6. save the mission under the same name.

## Recommended test order

Start a fresh mission for each transport test that consumes or relocates a one-shot object.

1. Start the mission and wait for the Phase 1 `READY` result.
2. Run `OH-58D RECON` individually.
3. Restart the mission and run `UH-60A Transport` individually.
4. Restart the mission and run `CH-47F Cargo` individually.
5. Only after all three individual tests behave correctly, restart once more and run the complete sequence.

## Required observations

### OH-58D

- both single-ship groups start and take off;
- no prolonged stationary circling or pirouettes at a zone;
- no terrain-following attempt against steep ridges;
- both aircraft return to Jalalabad with fuel reserve;
- both land at Jalalabad and are released.

### UH-60

- infantry remains at the pickup area until actual pickup;
- UH-60 starts engines and takes off before objective confirmation;
- pickup is logged;
- infantry is delivered to the dedicated drop zone;
- objective confirmation cannot occur before takeoff;
- UH-60 returns and lands at Jalalabad.

Expected physical lifecycle logs:

```text
TROOP_EVENT stage=PICKUP_CONFIRMED
OBJECTIVE_DRIVEN_SUCCESS ... troops-delivered-to-dedicated-drop-zone
```

### CH-47

- cargo is picked up and delivered as in the previous visual run;
- objective-driven success is logged only after takeoff and cargo arrival;
- a later MOOSE `CANCELLED`, `DONE` or `FAILED` report does not convert a physically completed transport into an immediate test failure;
- CH-47 returns and lands at Jalalabad.

### Vertical operation preference

Expected configuration log:

```text
AIRWING_OPTION preferVerticalTakeoffAndLanding=true taxiToRunwayAvoidance=REQUESTED
```

This is a MOOSE/DCS AI preference, not an absolute guarantee. The visual retest must confirm whether the current DCS version actually performs a vertical departure and recovery on the selected Jalalabad parking positions.

## PASS criteria

```text
RECON_ROUTE PASS
TROOP_ROUTE PASS
Phase 1 RESULT: READY
OH58D_RECON PASS with RTB and Jalalabad landings
UH60_TROOP PASS with pickup, delivery, RTB and Jalalabad landing
CH47_CARGO PASS with delivery, RTB and Jalalabad landing
no unexpected spawn
no parking violation
no loss
final inventory restored
```

Provide the new `dcs.log` after the retest. The `.miz` is additionally required if either operational route gate remains blocked despite apparently correct Mission Editor placement.
