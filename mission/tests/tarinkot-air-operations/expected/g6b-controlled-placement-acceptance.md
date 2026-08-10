---
document_id: OMW-TEST-TKOT-G6B-CONTROLLED-PLACEMENT-ACCEPTANCE
status: PLANNED
document_class: TEST_ACCEPTANCE_SPECIFICATION
owning_policy: OMW-GOV-001
authoritative_for:
  - Tarinkot G6B per-family diagnostic fallback tests
  - family-specific isolation after a combined G6B failure
not_authoritative_for:
  - primary routine G6B execution
  - final productive parking allowlists
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

# Tarinkot G6B – Per-family controlled placement fallback

## Status

This specification is no longer the primary routine execution path.

Primary G6B acceptance is defined in:

```text
mission/tests/tarinkot-air-operations/expected/g6b-combined-placement-acceptance.md
```

The combined test runs AH-64, UH-60 and CH-47 placement in one mission and emits separate `FAMILY_RESULT` records plus one aggregate result.

## Authorized use

The family-specific bundles may be used only when the combined test:

- fails or produces ambiguous evidence; and
- does not isolate the affected family and cause sufficiently from its own log.

A clean combined PASS requires no per-family reruns.

## Preserved diagnostic bundles

```text
OMW_AirOps_Tarinkot_G6B_AH64_Placement.lua
OMW_AirOps_Tarinkot_G6B_UH60_Placement.lua
OMW_AirOps_Tarinkot_G6B_CH47_Placement.lua
```

They remain available for fault isolation and regression diagnosis. They do not define the default workflow.
