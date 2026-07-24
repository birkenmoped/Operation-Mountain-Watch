# Jalalabad Phase 1 – operational routing and transport FAIL

## Classification

```text
Parking-pool and runtime-name corrections: PASS
OH-58D RECON operational behavior: FAIL
UH-60 TROOPTRANSPORT operational behavior: FAIL
CH-47 CARGOTRANSPORT physical behavior: PASS
CH-47 automated lifecycle classification: FAIL
Helicopter vertical operation preference: not configured in tested bundle
Overall Phase 1: FAIL / corrected retest required
```

## Tested bundle

```text
Phase 1 manifest version: JBAD-PHASE1-3
BuilderVersion: JBAD-AIR-OPS-PHASE1-3
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Mission: OMW_Jalalabad_AirOps_Phase1_Test.miz
```

The exact bundle hash and tested source commit remain recorded in the supplied test log and embedded mission evidence from the run.

## Results that remain valid

The previous correction of dynamic spawning was confirmed:

- exact AIRWING/SQUADRON runtime names were detected;
- OH-58D and AH-64D logical two-ships were represented as independent one-aircraft DCS groups;
- OH-58D spawned on its exclusive G parking pool;
- UH-60 spawned on its exclusive F parking pool;
- CH-47 spawned on its exclusive C parking pool;
- no Client group was accepted as a Phase 1 mission group;
- the former arbitrary TerminalID 26 spawn behavior was removed.

## Failure 1: OH-58D RECON

Observed:

- both OH-58D aircraft spawned, started and took off;
- the route was too long and crossed terrain unsuitable for the aircraft and AI profile;
- outbound flight used a largely uniform altitude;
- return flight degraded into terrain-following against steep mountain slopes;
- at the last objective area the aircraft performed repeated tight turns without useful reconnaissance behavior;
- both aircraft exhausted their usable fuel margin and landed away from Jalalabad.

Root cause in the tested factory:

```lua
AUFTRAG:NewRECON(zoneSet, 90, 4000, false, false, "Vee")
```

The pinned MOOSE RECON altitude parameter is feet ASL. A fixed 4,000 ft ASL mission altitude was below the terrain encountered by the route. No preflight validation existed for route distance, terrain height, leg length, total route or safe RTB profile.

## Failure 2: UH-60 troop transport

Observed:

- one UH-60 spawned on its assigned parking pool;
- it did not start, take off or fly the transport mission;
- the infantry moved away from its initial position near the base;
- the test declared the objective and released the UH-60 asset without a valid flight lifecycle.

The tested factory added a success condition based only on the ground group being inside the unload zone. It did not require engine start, takeoff, confirmed pickup, confirmed delivery or RTB before objective confirmation.

The ordinary base logistics unload zone was also unsuitable as a tactical remote transport destination. A dedicated test drop zone is required.

The pinned MOOSE `NewTROOPTRANSPORT` constructor accepts a `GROUP` or `SET_GROUP`; passing a `GROUP` was not the API defect. The correction uses an explicit `SET_GROUP` and validates the physical pickup/delivery lifecycle.

## Failure 3: CH-47 automated classification

Observed physically:

- CH-47 spawned correctly;
- cargo was transported to the destination;
- CH-47 returned to Jalalabad and landed.

The automated lifecycle still received a `CANCELLED`/`DONE`/`FAILED` terminal sequence around the custom success evaluation. The physical mission passed, but the harness classification failed.

## Failure 4: runway taxi behavior

The tested AIRWING used cold parking starts but did not set the pinned MOOSE helicopter option:

```lua
AIRWING:SetOptionPreferVerticalLanding()
```

Consequently wheeled helicopters could taxi to the runway and perform a rolling departure. The correction now requests preferred vertical takeoff and landing. DCS AI remains authoritative, so this behavior requires visual validation.

## Implemented correction

Repository branch:

```text
feature/jalalabad-airwing-phase1-functional-tests
```

Builder:

```text
JBAD-AIR-OPS-PHASE1-4
```

Implemented:

- OH-58D RECON route and terrain preflight gate;
- automatic ASL mission altitude from sampled terrain plus 350 m clearance;
- short-range route limits suitable for the functional test;
- dedicated `ZONE_TEST_US_JBAD_UH60_DROPOFF` requirement;
- troop-template route-point validation;
- load/drop distance and terrain-difference validation;
- pickup and delivery lifecycle tracking after takeoff;
- removal of transport `AddConditionSuccess` shortcuts in the corrected constructors;
- objective-driven normalization only after physical delivery is confirmed;
- MOOSE vertical helicopter takeoff/landing preference;
- builder and acceptance messages updated to Phase 1 version 4.

## Validation status

```text
Repository implementation: complete
Static source review: complete
DCS validation: pending
```

The next test must follow:

```text
expected/jalalabad-phase1-operational-safety-retest.md
```

The mission remains under the same filename. Required Mission Editor work is limited to the three RECON zone positions, one new dedicated UH-60 drop zone, and removal of any movement route from the troop template. Parking, Client groups, aircraft templates and visible Statics remain unchanged.
