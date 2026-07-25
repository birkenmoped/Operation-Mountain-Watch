# CH-47/AH-64 false-negative scoring and AH-64 mountain recovery

## Scope

This report covers the DCS run from 2026-07-25 recorded in `dcs(80).log` and `debrief(34).log`.

OMW branch:

```text
feature/jalalabad-airwing-phase1-functional-tests
```

Pinned MOOSE revision:

```text
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
```

The pull request remains draft and was not merged or marked ready for review.

## CH-47 observation

The visible sortie completed the following physical lifecycle:

- CH-47 spawned from a valid Jalalabad parking position;
- engine start and vertical takeoff were observed;
- the slingload was picked up and later released;
- the aircraft returned to Jalalabad;
- DCS emitted an exact Jalalabad landing event;
- MOOSE emitted `LEGION_ASSET_RETURNED`;
- the CH-47 inventory was restored and the mission queue was empty.

The controller nevertheless emitted:

```text
RESULT testId=CH47_CARGO classification=FAIL
reason=unexpected-native-cancellation
nativeState=FAILED released=true
objective=false rtb=true landings=1
```

### Important build finding

This run did **not** contain the marker introduced by the current CH-47 task adapter:

```text
CARGOTRANSPORT_TASK_BOUND
```

The loaded factory banner also did not contain:

```text
CH47SlingTaskAdapter=INNER_DCS_TASK_PARAMETERS
```

Therefore this run used an older generated bundle. It did not test the current adapter which copies the MOOSE-derived `groupId` and `zoneId` into the inner DCS `CargoTransportation` task.

The physical cargo release seen by the observer is not sufficient to reclassify this specific old-bundle run as a native MOOSE success because the old AUFTRAG evaluation ended in `FAILED`. The corrected bundle must be retested before changing the CH-47 objective semantics further.

## AH-64 observation

The two-ship CAS sortie physically and natively achieved the mission objective:

- two AH-64D aircraft spawned and took off;
- the target group was destroyed;
- MOOSE logged the CAS mission as successful;
- the AUFTRAG reached native state `SUCCESS`;
- the controller had `objective=true`;
- the debrief recorded both aircraft returning without a combat loss.

The controller nevertheless emitted:

```text
RESULT testId=AH64D_CAS classification=FAIL
reason=unexpected-native-cancellation; inventory-busy-AH64D-stock3-spawned1-onMission0
nativeState=SUCCESS released=false
births=2 takeoffs=2 objective=true rtb=false landings=0
```

## Root cause 1: incorrect AUFTRAG cancellation semantics

The pinned MOOSE AUFTRAG implementation uses a success/failure condition to cancel the running DCS task and then evaluates the result. The observed normal success sequence was:

```text
CANCELLED -> DONE -> SUCCESS
```

The OMW controller incorrectly treated every `CANCELLED` event as an immediate permanent failure unless the test explicitly expected `CANCELLED`. This caused a false negative even though the same mission later reached `SUCCESS`.

### Correction

For normal AUFTRAG missions:

- `CANCELLED` is now recorded as a non-blocking intermediate result-evaluation state;
- an expected abort test can still use `CANCELLED` as its native terminal state;
- only a real `FAILED` state before the expected native terminal state becomes a mission failure.

Expected marker:

```text
NATIVE_TRANSITION event=CANCELLED role=INTERMEDIATE_RESULT_EVALUATION nonBlocking=true
```

## Root cause 2: operation and recovery shared one deadline

The previous controller used one deadline for:

- mission execution;
- target engagement;
- RTB;
- mountain transit;
- landing;
- MOOSE asset return.

The AH-64 mission reached `SUCCESS`, but the controller finalized the test while the helicopters were still returning. This is why the result contained `nativeState=SUCCESS`, `objective=true`, but `rtb=false`, `landings=0` and `released=false`.

### Correction

The controller now separates:

1. `OperationDeadline`: time to reach the expected native MOOSE terminal state;
2. `RecoveryDeadline`: additional time after the terminal state for RTB, landing and `LEGION_ASSET_RETURNED`.

Expected marker:

```text
RECOVERY_WINDOW_ARMED testId=AH64D_CAS nativeTerminal=SUCCESS
```

## Root cause 3: terrain-unaware default recovery

The AH-64 telemetry showed very small terrain clearances during the return flight, including approximately:

```text
1656 m MSL over 1586 m terrain = 70 m AGL
1184 m MSL over 1131 m terrain = 53 m AGL
917 m MSL over 882 m terrain = 35 m AGL
630 m MSL over 602 m terrain = 28 m AGL
```

This produced an inefficient valley-following return with repeated steep climbs over ridgelines.

### MOOSE-first correction

Before dispatching the AH-64 CAS AUFTRAG, OMW now:

1. samples terrain from the CAS zone through `ZONE_TEST_US_JBAD_RECON_01` to Jalalabad;
2. determines the highest sampled terrain point;
3. adds 500 m recovery clearance;
4. configures the AUFTRAG egress with:

```lua
mission:SetMissionEgressCoord(egressCoordinate, altitudeFeetASL, 100)
```

Expected markers:

```text
CAS_RECOVERY_PROFILE READY ... clearance=500m
MOUNTAIN_RECOVERY_APPLIED testId=AH64D_CAS ... authority=AUFTRAG:SetMissionEgressCoord
```

The final DCS runtime behavior remains to be validated.

## Rotor formation decision

DCS/MOOSE does not expose the US Army doctrinal labels `Combat Cruise`, `Combat Cruise Left/Right` or `Combat Spread` as direct rotary-wing formation values.

The pinned MOOSE enumerations provide:

- Column;
- Wedge;
- Front Left/Right;
- Echelon Left/Right;
- fixed spacing variants of 70, 300 or 600 feet depending on formation.

For the OH-58D and AH-64D two-ship tests, OMW now uses:

```lua
ENUMS.Formation.RotaryWing.EchelonRight.D300
```

through:

```lua
mission:SetFormation(...)
```

This is explicitly an **approximation** of Combat Cruise Right within the formations DCS actually supports. It is not documented as doctrinal equivalence.

Expected marker:

```text
TACTICAL_FORMATION_APPLIED ... doctrineApproximation=COMBAT_CRUISE_RIGHT
```

## Vertical takeoff observation

`FLIGHTGROUP:SetOptionPreferVertical()` was applied successfully to both CH-47 and AH-64 flight groups.

Observed behavior differed:

- CH-47 took off vertically;
- AH-64 two-ship taxied to the runway.

The method is therefore treated as a DCS preference, not as a guaranteed takeoff mode. It remains enabled, but the test must not fail solely because DCS chooses a taxi/runway departure.

## Changed OMW sources

```text
mission/tests/jalalabad-air-operations/src/11-phase1-test-manifest.lua
mission/tests/jalalabad-air-operations/src/14-phase1-test-controller.lua
mission/tests/jalalabad-air-operations/src/16-phase1-moose-first-readiness-routing.lua
```

The already committed CH-47 adapter remains in:

```text
mission/tests/jalalabad-air-operations/src/13-phase1-mission-factory.lua
```

## Validation status

Completed:

- source inspection against pinned MOOSE;
- current-log lifecycle analysis;
- Lua syntax checks for the changed controller and routing blocks;
- branch commits created;
- no mission-editor object or geometry changes;
- no PR merge or readiness-state change.

Not yet completed:

- DCS runtime validation of the regenerated bundle;
- CH-47 native `SUCCESS` with `CARGOTRANSPORT_TASK_BOUND` present;
- AH-64 PASS after the non-blocking cancellation change;
- AH-64 terrain-safe egress behavior;
- runtime confirmation of the Echelon Right 300 formation.

## Required next-run markers

```text
JBAD-PHASE1-13
CH47SlingTaskAdapter=INNER_DCS_TASK_PARAMETERS
CARGOTRANSPORT_TASK_BOUND
cancellationSemantics=AUFTRAG_INTERMEDIATE_NONBLOCKING
operationAndRecoveryDeadlines=SEPARATE
TACTICAL_FORMATION_APPLIED
CAS_RECOVERY_PROFILE READY
MOUNTAIN_RECOVERY_APPLIED
RECOVERY_WINDOW_ARMED
```

A PASS may only be accepted after the expected native terminal state, physical objective, required flight events and authoritative `LEGION_ASSET_RETURNED` are all present.
