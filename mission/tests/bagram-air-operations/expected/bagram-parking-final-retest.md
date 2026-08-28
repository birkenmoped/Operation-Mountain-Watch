---
document_id: OMW-TEST-BAGRAM-PARKING-FINAL-RETEST
status: HISTORICAL_TEST_FIXTURE
document_class: DCS_ACCEPTANCE_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - historical ALERT5 recruitment correction evidence
  - historical physical materialization observations on 2026-08-28
not_authoritative_for:
  - current production parking allocation
  - current merge acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/bagram-parking-policy-integration
source_commit: feffd02df69827ff73d68efdddd04bd70948f29f
acceptance_mission: OMW_Template_v20_BGRM_Parking_Correlation_1.miz
dcs_version: 2.9.29.27278
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
validated_in_dcs: false
---

# Historical Bagram Final Parking Retest

## Result

The repeat run corrected the missing test-side ALERT5 recruitment capability and demonstrated that all seven requested SQUADRON dispatches could be materialized through MOOSE. It did **not** validate the production aircraft-to-parking allocation.

Immutable runtime evidence:

```text
dcs.log SHA-256:
d63a8c205513ab575e5e901364a93f06973b13f16f02488b3e04de524130f537

debrief.log SHA-256:
bbadf263e273dd2e0f3eca01dfaa5e622e55d6b88e82c80fd2981dbcbe34f76d
```

The aggregate harness timed out before all physical parking observations completed. More importantly, visual inspection and the owner-authored CSV exposed that the Lua parking pools themselves had been normalized incorrectly.

Concrete contradiction:

```text
runtime F-16 position: TerminalID 148
validated ME correlation: TerminalID 148 = M22
owner CSV: M22 = F-15E / AI
old Lua pool: TerminalID 148 included in F-16 pool
```

Therefore any `ownPool=true` result from this fixture is circular with respect to the incorrect old Lua pool and is not production acceptance evidence.

## What remains technically useful

The run still provides limited evidence for the specific mechanisms it actually exercised:

```text
MOOSE ALERT5 recruitment after adding ALERT5 capability: observed
MOOSE physical materialization: observed
MOOSE NewAsset parkingIDs propagation mechanism: observed
owner-authored aircraft-to-parking allocation: not validated
```

## Superseding production direction

The project owner decided that no further DCS parking run will be performed. Production parking is now reconciled statically and 1:1 to:

```text
docs/data/bagram-parking-policy.csv
```

The production base is:

```text
scripts/air-operations/OMW_AirOps_Bagram.lua
```

and the production builder is:

```text
tools/build-bagram-air-operations-foundation.ps1
```

The builder rejects any drift between the CSV and the Lua parking labels, TerminalIDs, or non-AI blacklist.
