# Bagram to Jalalabad fixed-wing movement - partial pass

## Status

```text
PARTIAL PASS - movement proven / destination capacity insufficient
```

## Test scope

- source: Bagram;
- destination: Jalalabad;
- 2 x F-15E two-ship groups;
- 2 x F-16C two-ship groups;
- 4 x C-130 one-ship groups;
- total: 8 groups / 12 aircraft.

## Proven behavior

The run proved that the Bagram AIRWING could recruit the intended multi-squadron wave, create eight groups with twelve aircraft, reduce the corresponding warehouse stock, start the aircraft and dispatch them toward Jalalabad.

Visible mission behavior confirmed that multiple groups taxied, departed Bagram, flew the route and entered the Jalalabad arrival sequence. At least one F-16 landed and parked. Its wingman was on short final when the test cleanup removed all remaining test aircraft.

## Destination-capacity finding

Jalalabad was not an appropriate destination for a wave of this size.

Observed and mission-design constraints:

- short runway for heavy or high-performance arrivals;
- no practical parallel taxiway system for the tested flow;
- a landed aircraft may need to backtrack along most or all of the active runway;
- the runway remains unavailable to following traffic during the backtrack;
- limited suitable transient parking;
- insufficient parking capacity for all twelve arriving aircraft;
- go-arounds and extended sequencing are therefore expected.

The first F-15E lead went around immediately before touchdown. The exact DCS AI reason was not conclusively logged. Runway occupancy, remaining stopping distance, traffic sequencing and parking availability are all plausible contributors and must not be reduced to one unproven cause.

## Group-arrival finding

No complete two-ship group had finished the arrival contract when cleanup occurred.

```text
F-15E lead: go-around before touchdown
first F-16: landed and parked
second F-16 of that group: short final
complete arrived groups: 0
```

The harness value `arrived=0` was therefore compatible with the observed group-level situation.

## Harness defect

The harness reached its global lifecycle timeout while several aircraft were still conducting normal arrival operations. Its fail-cleanup then called the return-to-legion path for every surviving test group. This despawned all airborne, inbound, landing and taxiing aircraft at once.

This was not normal AIRWING behavior and was not triggered by one completed group. It was a destructive test-harness cleanup at timeout.

Required correction before reuse:

- timeout must become a diagnostic state rather than immediate global despawn;
- airborne, inbound, landing and taxiing groups must not be removed automatically;
- takeoff, airborne, landing, parking and group-complete status must be recorded per aircraft and per group;
- go-around must be treated as a valid intermediate state;
- mass-transfer tests must use destinations with adequate runway, taxiway and parking capacity.

## Test classification

```yaml
multi_squadron_recruitment: PASS
wave_size_8_groups_12_aircraft: PASS
warehouse_stock_reduction: PASS
bagram_spawn_and_dispatch: PASS
movement_toward_destination: PASS
at_least_one_aircraft_landed: PASS
complete_group_arrival: NOT_REACHED
full_wave_recovery: NOT_REACHED
destination_capacity_for_wave: FAIL
harness_timeout_cleanup: FAIL
final_status: PARTIAL_PASS
```

## Follow-up

- retain Jalalabad for small arrival tests only;
- use one two-ship fighter group or a small number of transports for later Jalalabad acceptance;
- reserve the larger 8-group / 12-aircraft transfer test for Bagram to Kandahar or another sufficiently capable airfield;
- implement and validate Kandahar before attempting that mass-transfer acceptance;
- correct the timeout cleanup before any repeat.

## Evidence supplied by project owner

- `dcs(100).log`;
- `debrief(53).log`;
- direct visual observations of the F-15E go-around, first F-16 landing and second F-16 short final.

This result does not claim a complete Bagram to Jalalabad transfer PASS.
