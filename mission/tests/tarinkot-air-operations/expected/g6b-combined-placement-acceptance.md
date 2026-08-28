---
document_id: OMW-TEST-TKOT-G6B-COMBINED-PLACEMENT-ACCEPTANCE
status: PLANNED
document_class: TEST_ACCEPTANCE_SPECIFICATION
owning_policy: OMW-GOV-001
authoritative_for:
  - primary Tarinkot G6B parking-placement test
  - one-run combined placement acceptance for AH-64, UH-60 and CH-47
  - fallback boundary for per-family isolation only after a combined-test failure
not_authoritative_for:
  - productive SQUADRON parking lists before a documented combined G6B PASS
  - engine-start, taxi, takeoff, landing or recovery acceptance
  - AIRWING, SQUADRON, payload, AUFTRAG, COMMANDER or OPSTRANSPORT acceptance
  - merge approval or Ready-for-Review approval
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit: 585f3c46d4ff0a4b167c984d427bcdb356138e69
validated_in_dcs: false
supersedes: []
superseded_by: []
---

# Tarinkot G6B – Combined Controlled Placement Acceptance

## 1. Owner-directed batching rule

The primary G6B path is one combined DCS run, not three routine family runs.

```text
one branch update
one bundle build
one Mission Editor replacement
one DCS mission start
one dcs.log and debrief.log package
one combined evaluation
```

Separate AH-64, UH-60 or CH-47 bundles remain diagnostic fallbacks only. They are used solely when the combined run identifies a family-specific failure that cannot be isolated from the combined log.

## 2. Source basis

G6A passed on commit:

```text
a58fdfb82082bb7e9043f314e1c483a9a6ba3775
```

with:

```text
RESULT G6A_PARKING_CANDIDATE_ANALYSIS status=PASS_DATASET
parkingCount=33
modelMissing=0
candidateSetFailures=0
activePlayerClients=0
parkingMutation=0
spawns=0
```

The exact embedded MOOSE source provides:

```lua
SPAWN:SpawnAtParkingSpot(Airbase, TerminalIDs, SPAWN.Takeoff.Cold)
```

G6B uses this exact-terminal path with `InitAIOff()`.

## 3. Combined test configuration

```yaml
AH64:
  template: TPL_AIR_US_TKOT_AH64D_CAS_2SHIP
  expected_type: AH-64D_BLK_II
  groups: 1
  aircraft: 2
  terminal_ids: [0, 25]

UH60:
  template: TPL_AIR_US_TKOT_UH60_MEDEVAC_1SHIP
  expected_type: UH-60A
  groups: 2
  aircraft: 2
  terminal_ids: [13, 22]

CH47:
  template: TPL_AIR_US_TKOT_CH47_HEAVYLIFT_1SHIP
  expected_type: CH-47Fbl1
  groups: 1
  aircraft: 1
  terminal_ids: [14]
```

Aggregate expectation:

```yaml
families: 3
groups: 4
aircraft: 5
spawn_calls: 4
unique_terminal_ids: 5
```

## 4. Geometric separation

The selected positions are all G6A candidates.

Within-family center distances:

```text
AH-64 Terminal 0 to 25: 31.679 m
UH-60 Terminal 13 to 22: 31.548 m
```

The smallest cross-family spacing is greater than 63 m. Terminal 14 is approximately 950 to 1080 m from the AH-64/UH-60 probe area. The families therefore do not need separate routine runs for geometric isolation.

## 5. Mutation boundary

The combined test may create only four controlled SPAWN groups.

It must not:

```text
construct AIRWING or SQUADRON
register payloads
construct AUFTRAG, COMMANDER or OPSTRANSPORT
set SQUADRON or Warehouse parking IDs
change Airbase parking white-/blacklists
change safe-parking configuration
allow client-parking spawns
activate the original template groups
randomize position or route
modify CampaignState, MIZ or user flags
```

The generated aircraft remain AI-off.

## 6. Test execution

Use only:

```text
OMW_AirOps_Tarinkot_G6B_CombinedPlacement.lua
```

Do not load G5, G6A or the three family-specific G6B bundles in the same mission.

No Tarinkot player client may be occupied.

The script timeline is:

```text
T+12 s: preflight
T+14 s: all four groups spawned
T+22 s: automated placement inspection and result
```

A mission duration of 30 to 35 seconds is sufficient.

## 7. Automated acceptance

Per family:

```text
FAMILY_RESULT family=AH64 status=PASS_RUNTIME_PLACEMENT
FAMILY_RESULT family=UH60 status=PASS_RUNTIME_PLACEMENT
FAMILY_RESULT family=CH47 status=PASS_RUNTIME_PLACEMENT
```

Aggregate:

```text
RESULT G6B_COMBINED_CONTROLLED_PLACEMENT
status=PASS_RUNTIME_PLACEMENT
expectedFamilies=3
expectedGroups=4
groupsFound=4
expectedUnits=5
unitsFound=5
placementFailures=0
familyFailures=0
activePlayerClients=0
spawnCalls=4
visualConfirmationRequired=true
```

Any family-specific failure is visible in the same log through its `FAMILY_RESULT` and `UNIT_PLACEMENT` records.

## 8. Single visual inspection

One visual pass must confirm all five generated aircraft:

```text
2 x AH-64 present on the requested pair
2 x UH-60 present as independent one-ship groups
1 x CH-47 present on its requested terminal
no aircraft-aircraft overlap
no static/revetment contact
all aircraft on prepared surfaces
no visible rotor contact
```

The CH-47 rotor envelope remains a visual acceptance item because the DCS bounding box does not fully represent rotor extent.

## 9. Failure isolation rule

A separate family run is authorized only when:

```text
the combined test fails or is ambiguous
and
the combined log cannot identify the affected family and cause sufficiently
```

A clean failure limited to one `FAMILY_RESULT` does not automatically require rerunning the other two families.

## 10. Gate effect

```yaml
combined_G6B_PASS:
  G6_parking_calibration: PASS_DCS
  G7_airwing_squadron_payload: AUTHORIZED

combined_G6B_FAIL:
  G6_parking_calibration: FAIL_OR_PARTIAL
  G7_airwing_squadron_payload: BLOCKED
```

A G6B PASS still does not prove engine start, taxi, takeoff, return or productive SQUADRON parking compliance.

## 11. Files

```text
mission/tests/tarinkot-air-operations/src/04-tarinkot-g6b-combined-placement.lua
mission/tests/tarinkot-air-operations/dist/OMW_AirOps_Tarinkot_G6B_CombinedPlacement.lua
tools/build-tarinkot-air-operations-g6b-combined-placement.ps1
```
