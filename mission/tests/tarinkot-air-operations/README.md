---
document_id: OMW-TEST-TKOT-AIR-OPS-INDEX
status: DRAFT
document_class: TEST_PACKAGE_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - Tarinkot Air Operations test-package layout
  - accepted G5 read-only diagnostics
  - accepted G6 parking mapping and controlled placement
  - current combined G7 AIRWING/SQUADRON/payload foundation workflow
  - airport-level batching and failure-isolation boundary
not_authoritative_for:
  - G7 runtime acceptance before a documented DCS PASS
  - tactical AUFTRAG, vertical departure, COMMANDER or OPSTRANSPORT acceptance
  - return, landing, recovery, loss or persistence acceptance
  - merge approval or Ready-for-Review approval
scenario_period: 2010-08-01/2011-12-31
project_phase: TARINKOT_G7_FOUNDATION
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: partial
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
G6A_geometric_dataset: PASS_DCS_SCOPE_TOO_BROAD_FOR_PRODUCTIVE_LISTS
G6A2_ME_MOOSE_mapping: PASS_DCS
G6B_first_combined_run: FAIL_VISUAL_WRONG_APRON
G6B_final_free_spots: PASS_DCS_OWNER_VISUAL_ACCEPTED
G7_airwing_squadron_payload: IMPLEMENTED_AWAITING_DCS
G8_direct_dispatch_vertical_departure: BLOCKED_BY_G7
G9_commander: BLOCKED_BY_G8
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
Zones: 1 present / 10 pending
Name duplicates: 0
Mutations: 0
```

Hard client exclusions:

```text
TerminalID 3
TerminalID 8
TerminalID 20
```

G6A proved the geometric dataset but used a broad `HelicopterUsable` class that also admitted type-104 general apron positions. Those candidates are not productive Tarinkot helicopter parking.

G6A2 mapped all 33 Mission Editor positions to MOOSE TerminalIDs:

```text
RESULT G6A2_ME_PARKING_MAP status=PASS_MAP anchors=30 mapped=30 rejected=0 ambiguous=0 duplicates=0 parkingCount=33 clientReferences=3
```

The first combined G6B type-104 run failed visual acceptance:

```text
FAIL_VISUAL_WRONG_APRON
```

The final combined type-40 run passed runtime and owner visual acceptance:

```text
RESULT G6B_HELICOPTER_APRON_COMBINED
status=PASS_RUNTIME_PLACEMENT
expectedGroups=7
groupsFound=7
expectedUnits=8
unitsFound=8
placementFailures=0
familyFailures=0
spawnCalls=7
expectedTerminalType=HelicopterOnly
```

Accepted operational pools:

```yaml
AH64:
  ME: [C04-H, C18-H]
  TerminalIDs: [21, 4]
UH60:
  ME: [C14-H, C12-H, C11-H]
  TerminalIDs: [30, 27, 23]
CH47:
  ME: [C08-H, C09-H, C10-H]
  TerminalIDs: [32, 29, 10]
```

G6B remains a placement-only proof. The invalid direct-UNIT and standalone-FLIGHTGROUP departure experiments were withdrawn. No additional G6B run is required.

## Test batching decision

Technically similar airport checks are combined by default:

```text
one bundle
one Mission Editor replacement
one DCS run
per-subsystem result records
one aggregate result
```

Smaller runs are created only when the combined log cannot isolate a failure.

## Current G7 test

Builder:

```text
tools/build-tarinkot-air-operations-g7-foundation.ps1
```

Generated bundle:

```text
mission/tests/tarinkot-air-operations/dist/OMW_AirOps_Tarinkot_G7_Foundation.lua
```

Builder version:

```text
TKOT-G7-AIRWING-FOUNDATION-1
```

The combined bundle constructs:

```text
AIRWING:
AW_US_TKOT_TF_ATTACK_3_101_AVN

SQUADRONs:
SQ_US_TKOT_AH64D_3_101_AVN
SQ_US_TKOT_UH60_TF_ATTACK
SQ_US_TKOT_CH47_B_1_52_AVN
```

Registered inventory:

```yaml
AH64:
  groups: 2
  grouping: 2
  aircraft: 4
UH60:
  groups: 2
  grouping: 1
  aircraft: 2
CH47:
  groups: 1
  grouping: 1
  aircraft: 1
aggregate:
  groups: 5
  aircraft: 7
```

G7 applies the accepted SQUADRON parking pools, registers three role payloads and verifies the three automatic `RELOCATECOHORT` payloads created by `AIRWING:AddSquadron()`.

The vertical-helicopter policy is applied in the accepted order:

```lua
airwing:SetOptionPreferVerticalLanding()
airwing:Start()
```

The bundle creates no operational mission and expects no spawn. A real vertical departure belongs to G8 native AIRWING/AUFTRAG dispatch.

Expected final marker:

```text
RESULT G7_AIRWING_SQUADRON_PAYLOAD_FOUNDATION
status=PASS
violations=0
airwingRunning=true
squadrons=3
registeredGroups=5
registeredAircraft=7
stock=5
rolePayloads=3
totalPayloads=6
parkingPools=3
parkingIDs=8
missionQueue=0
transportQueue=0
requestQueue=0
opsGroups=0
safeParking=true
verticalPolicy=true
takeoffCold=true
activePlayerClients=0
commanderCreated=0
auftragCreated=0
opsTransportCreated=0
deliberateSpawns=0
```

Detailed contract:

```text
expected/g7-airwing-squadron-payload-foundation-acceptance.md
```

## Package layout

```text
mission/tests/tarinkot-air-operations/
├── README.md
├── expected/
│   ├── g5-read-only-diagnostics-acceptance.md
│   ├── g6a-parking-candidate-analysis-acceptance.md
│   ├── g6b-combined-placement-acceptance.md
│   ├── g6b-controlled-placement-acceptance.md
│   ├── g6b-helicopter-apron-retest-acceptance.md
│   └── g7-airwing-squadron-payload-foundation-acceptance.md
├── results/
│   ├── 2026-08-03-g5-read-only-diagnostics-initial-fail.md
│   ├── 2026-08-03-g5-read-only-diagnostics-retest-pass.md
│   ├── 2026-08-03-g6a-parking-candidate-analysis-pass.md
│   ├── 2026-08-03-g6b-combined-placement-fail-wrong-apron.md
│   └── 2026-08-04-g6b-final-free-spots-pass-and-departure-scope-correction.md
├── src/
│   ├── 01-tarinkot-g5-read-only-diagnostics.lua
│   ├── 02-tarinkot-g6a-parking-candidate-analysis.lua
│   ├── 03-tarinkot-g6b-controlled-placement.lua
│   ├── 04-tarinkot-g6b-combined-placement.lua
│   ├── 05-tarinkot-g6b-helicopter-apron-retest.lua
│   ├── 06-tarinkot-g6a2-me-parking-map.lua
│   └── 07-tarinkot-g7-airwing-squadron-payload-foundation.lua
└── dist/
    └── generated bundles only
```

Files under `dist/` are generated locally and never edited manually.

## Gate effect

A clean G7 PASS authorizes the first isolated G8 native AIRWING/AUFTRAG dispatch. A G7 FAIL keeps G8 blocked and triggers only the smallest necessary diagnostic follow-up.
