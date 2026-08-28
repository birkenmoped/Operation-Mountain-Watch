---
document_id: OMW-TEST-BAGRAM-PARKING-FINAL-ACCEPTANCE
status: HISTORICAL_TEST_FIXTURE
document_class: DCS_ACCEPTANCE_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - historical Bagram parking materialization test design
not_authoritative_for:
  - current production parking allocation
  - current merge acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/bagram-parking-policy-integration
source_commit: GIT_HISTORY
validated_in_dcs: false
supersedes:
superseded_by:
---

# Historical Bagram Final Parking Acceptance Fixture

This fixture is retained only to document the development path. It is not a current acceptance contract.

The test was built against an incorrect parking normalization that replaced the project owner's per-row CSV allocation with invented contiguous parking blocks. That invalidates the fixture as evidence for aircraft-to-parking correctness.

Example of the invalid assumption:

```text
old implementation: F-16C -> M13-M24
owner CSV: M22 -> TerminalID 148 -> F-15E -> AI
```

The test therefore compared runtime parking against the same incorrect Lua pool and could report `ownPool=true` while violating the owner-authored allocation.

Current production authority is:

```text
docs/data/bagram-parking-policy.csv
scripts/air-operations/OMW_AirOps_Bagram.lua
tools/build-bagram-air-operations-foundation.ps1
```

The project owner decided that no additional DCS parking run will be performed for the corrected CSV reconciliation. The corrected production base is statically reconciled to the CSV and must not be described as newly DCS-validated.
