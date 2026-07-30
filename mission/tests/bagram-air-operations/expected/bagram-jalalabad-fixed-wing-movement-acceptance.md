# Bagram to Jalalabad Fixed-Wing Movement Acceptance

Status: `IMPLEMENTED_PENDING_DCS_VALIDATION`

## Purpose

This is the first larger post-HH-60G integration increment. It validates simultaneous recruitment and movement of fixed-wing assets from Bagram to Jalalabad without introducing a second `COMMANDER` or a custom DCS route implementation.

## First wave

```text
2 x F-15E two-ship groups = 4 aircraft
2 x F-16C two-ship groups = 4 aircraft
4 x C-130 single-ship groups = 4 aircraft
-------------------------------------------
8 groups                    = 12 aircraft
```

Binding source objects:

```text
SQ_US_BGRM_F15E_335_EFS
SQ_US_BGRM_F16C_121_EFS
SQ_US_BGRM_C130_774_EAS

TPL_AIR_US_BGRM_F15E_CAS_2SHIP
TPL_AIR_US_BGRM_F16_CAS_2SHIP
TPL_AIR_US_BGRM_C130_TRANSPORT_1SHIP
```

Destination:

```text
AIRBASE.Afghanistan.Jalalabad
AW_US_JALALABAD must already be OPERATIONAL
```

## MOOSE-first design decision

The MOOSE revision used by the accepted baseline does not implement a public FERRY mission constructor. The integration test therefore uses only existing MOOSE OPS functionality:

1. `AUFTRAG:NewALERT5(...)` recruits the exact Bagram assets through `AIRWING` and `SQUADRON`.
2. `AUFTRAG:SetRequiredAssets(...)`, `AssignSquadrons(...)` and `AddRequiredPayload(...)` constrain each wave component.
3. `FLIGHTGROUP:LandAtAirbase(Jalalabad)` creates the native destination route.
4. `FLIGHTGROUP:StartUncontrolled()` releases the ALERT5 readiness aircraft for taxi and takeoff.
5. Arrival is accepted only after the group was airborne and subsequently reaches `Parking` or `Arrived` at Jalalabad.
6. `OPSGROUP:ReturnToLegion()` despawns the parked transient group and books its asset back into the original Bagram legion.
7. `COHORT:CountAssets(true)` verifies stock withdrawal and restoration.

This is a movement and recovery validation. It does not relocate the complete F-15E, F-16C or C-130 cohort to Jalalabad and does not change permanent squadron ownership.

## Preconditions

- `AW_US_BAGRAM` started with exactly six squadrons and 75 logical airframes.
- Bagram parking contract is PASS.
- `AW_US_JALALABAD` is OPERATIONAL.
- The existing `OMW_BLUE_COMMANDER` is created only by the Jalalabad node.
- The Bagram test creates no second COMMANDER.
- Initial in-stock asset-group counts are:

```text
F-15E: 6
F-16C: 6
C-130: 20
```

- The active test switches are:

```text
HH60GControlledSpawn = false
FixedWingBagramToJalalabad = true
```

## Recruitment contract

Three exact ALERT5 missions are queued:

```text
F-15E: alert mission type CAS, required assets 2..2
F-16C: alert mission type CAS, required assets 2..2
C-130: alert mission type TROOPTRANSPORT, required assets 4..4
```

Each mission is bound to exactly one squadron and its registered payload.

Recruitment is polled every five seconds after an initial 30-second delay. The timeout is 300 seconds.

PASS requires:

```text
8 OPSGROUPs
12 aircraft
F-15E stock reduced 6 -> 4
F-16C stock reduced 6 -> 4
C-130 stock reduced 20 -> 16
```

Any additional group, wrong unit count, wrong squadron, missing payload or incorrect stock reduction is FAIL.

## Movement contract

The eight groups are dispatched with 30-second spacing.

For every group the harness must prove:

```text
DISPATCH
AIRBORNE_PASS
ARRIVAL_PASS ... parkingOrArrived=true
RETURN_REQUEST
RETURN_PASS
```

`ARRIVAL_PASS` is not emitted merely because DCS reports touchdown. The group must complete its landing roll and taxi into transient parking at Jalalabad.

The lifecycle timeout is 2,400 seconds from wave readiness.

## Final PASS criteria

```text
all eight groups dispatched
all eight groups became airborne
all eight groups reached Jalalabad parking/Arrived state
all eight groups returned to the Bagram legion
all mission OPSGROUP lists are empty
F-15E stock restored to 6
F-16C stock restored to 6
C-130 stock restored to 20
no second COMMANDER created
```

Expected final marker:

```text
TEST_PASS groups=8 aircraft=12 allAirborne=true allArrived=true allReturned=true stockRestored=true destination=Jalalabad
```

## FAIL and recovery behavior

The harness fails closed on:

- missing Bagram or Jalalabad node readiness;
- initial stock mismatch;
- mission-construction error;
- recruitment timeout;
- too many OPSGROUPs;
- wrong group size;
- incorrect stock withdrawal;
- missing `LandAtAirbase`, `StartUncontrolled` or `ReturnToLegion` method;
- group loss before arrival;
- lifecycle timeout;
- incomplete stock restoration.

On FAIL, queued missions are cancelled and surviving test assets are ordered back through `ReturnToLegion()`.

## Required evidence

- complete `dcs.log` section for `[OMW][AirOps.BGRAM.Test.FixedWingMove]`;
- Bagram parking-contract PASS block;
- Bagram AIRWING baseline PASS block;
- Jalalabad OPERATIONAL marker;
- all recruitment, dispatch, airborne, arrival, return and final markers;
- `debrief.log`;
- tested `.miz`;
- BuilderVersion, GitCommit and generated bundle SHA-256.

## Explicit exclusions

This increment does not validate:

- combat CAS execution;
- cargo or troop loading/unloading;
- persistent basing at Jalalabad;
- permanent cohort relocation;
- cross-node mission assignment by COMMANDER;
- aircraft losses, repair timing or replacement supply;
- player/client interaction during the wave.
