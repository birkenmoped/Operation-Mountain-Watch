---
document_id: OMW-TEST-TKOT-AIR-OPS-INDEX
status: DRAFT
document_class: TEST_PACKAGE_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - Tarinkot Air Operations test-package layout
  - accepted G5 read-only diagnostic result
  - accepted G6A parking-candidate dataset
  - primary combined G6B controlled-placement workflow
  - per-family G6B fallback boundary
not_authoritative_for:
  - final parking allowlists before a documented combined G6B PASS
  - AIRWING, SQUADRON, payload, AUFTRAG, COMMANDER or OPSTRANSPORT acceptance
  - merge approval or Ready-for-Review approval
scenario_period: 2010-08-01/2011-12-31
project_phase: TARINKOT_G6_PARKING_CALIBRATION
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: true
supersedes: []
superseded_by: []
---

# Tarinkot Air Operations – Test package

## Current gate state

```yaml
G0_provenance: PASS_BRANCH
G1_ORBAT_and_evidence: PASS_BRANCH
G2_object_contract: OWNER_ACCEPTED_BRANCH
G3_mission_editor: PARTIAL_FUNCTION_ZONES_PENDING
G4_MOOSE_source_review: PASS_SOURCE_REVIEW
G5_read_only_diagnostics: PASS_DCS
G6_parking_calibration: G6A_PASS_DCS_G6B_COMBINED_IMPLEMENTED_AWAITING_DCS
G7_airwing_squadron_payload: BLOCKED_BY_G6B
G8_direct_dispatch_and_transport: NOT_STARTED
G9_commander_and_operational_parking: NOT_STARTED
G10_lifecycle_results_handoff: NOT_STARTED
```

## Accepted basis

G5 confirmed:

```text
Airbase: Tarinkot / ID 9
Parking nodes: 33
Warehouse wrappers: 1
Clients: 3/3
AI seeds: 3/3
Statics: 12/12
Zones: 1 present / 10 expected missing
Name duplicates: 0
Mutations: 0
```

Hard client exclusions:

```text
TerminalID 3
TerminalID 8
TerminalID 20
```

G6A passed with:

```text
RESULT G6A_PARKING_CANDIDATE_ANALYSIS status=PASS_DATASET
parkingCount=33
modelMissing=0
candidateSetFailures=0
activePlayerClients=0
parkingMutation=0
spawns=0
```

Candidate sets:

```text
AH-64: 0,1,6,11,13,14,18,22,24,25,28,33
UH-60: 0,1,6,11,13,14,18,22,24,25,28,33
CH-47: 0,1,6,11,13,14,18,22,24,25,28,29,33
```

## Test batching decision

Technically similar airport checks are combined by default. A routine DCS cycle is not split only because several aircraft families are involved.

The standard sequence is:

```text
one bundle
one Mission Editor replacement
one DCS run
per-family result records
one aggregate result
```

Smaller tests are used only for failure isolation.

## Primary G6B test

The primary bundle is:

```text
OMW_AirOps_Tarinkot_G6B_CombinedPlacement.lua
```

It creates in one run:

```yaml
AH64:
  groups: 1
  aircraft: 2
  terminal_ids: [0, 25]
UH60:
  groups: 2
  aircraft: 2
  terminal_ids: [13, 22]
CH47:
  groups: 1
  aircraft: 1
  terminal_ids: [14]
```

Aggregate:

```text
3 families
4 groups
5 aircraft
4 spawn calls
5 unique TerminalIDs
```

The script uses only:

```lua
SPAWN:SpawnAtParkingSpot(Airbase, TerminalIDs, SPAWN.Takeoff.Cold)
```

with `InitAIOff()`.

It does not create AIRWING, SQUADRON, payload, AUFTRAG, COMMANDER or OPSTRANSPORT objects and does not apply productive parking lists.

Expected per-family markers:

```text
FAMILY_RESULT family=AH64 status=PASS_RUNTIME_PLACEMENT
FAMILY_RESULT family=UH60 status=PASS_RUNTIME_PLACEMENT
FAMILY_RESULT family=CH47 status=PASS_RUNTIME_PLACEMENT
```

Expected aggregate marker:

```text
RESULT G6B_COMBINED_CONTROLLED_PLACEMENT status=PASS_RUNTIME_PLACEMENT expectedFamilies=3 expectedGroups=4 groupsFound=4 expectedUnits=5 unitsFound=5 placementFailures=0 familyFailures=0 activePlayerClients=0 spawnCalls=4 visualConfirmationRequired=true
```

## Per-family fallback

These bundles are not routine prerequisites:

```text
OMW_AirOps_Tarinkot_G6B_AH64_Placement.lua
OMW_AirOps_Tarinkot_G6B_UH60_Placement.lua
OMW_AirOps_Tarinkot_G6B_CH47_Placement.lua
```

They are retained only when a combined failure cannot be isolated sufficiently from the combined log.

## Package layout

```text
mission/tests/tarinkot-air-operations/
├── README.md
├── expected/
│   ├── g5-read-only-diagnostics-acceptance.md
│   ├── g6a-parking-candidate-analysis-acceptance.md
│   ├── g6b-combined-placement-acceptance.md
│   └── g6b-controlled-placement-acceptance.md
├── results/
│   ├── 2026-08-03-g5-read-only-diagnostics-initial-fail.md
│   ├── 2026-08-03-g5-read-only-diagnostics-retest-pass.md
│   └── 2026-08-03-g6a-parking-candidate-analysis-pass.md
├── src/
│   ├── 01-tarinkot-g5-read-only-diagnostics.lua
│   ├── 02-tarinkot-g6a-parking-candidate-analysis.lua
│   ├── 03-tarinkot-g6b-controlled-placement.lua
│   └── 04-tarinkot-g6b-combined-placement.lua
└── dist/
    └── generated bundles only

tools/
├── build-tarinkot-air-operations-g5-diagnostics.ps1
├── build-tarinkot-air-operations-g6a-parking-analysis.ps1
├── build-tarinkot-air-operations-g6b-controlled-placement.ps1
└── build-tarinkot-air-operations-g6b-combined-placement.ps1
```

Files under `dist/` are generated locally and are not edited manually.

## G6B visual acceptance

One visual pass checks all five generated aircraft:

```text
all five aircraft present
no aircraft overlap
no static or revetment contact
all aircraft on prepared surfaces
no visible rotor contact
```

The CH-47 rotor envelope remains a visual acceptance item.

## Gate effect

A clean combined PASS authorizes G7. A combined FAIL keeps G7 blocked and triggers only the smallest necessary diagnostic fallback.
