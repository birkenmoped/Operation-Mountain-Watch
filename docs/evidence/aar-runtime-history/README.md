---
document_id: OMW-EVIDENCE-AAR-RUNTIME-HISTORY
status: HISTORICAL_TEST_FIXTURE
document_class: EVIDENCE_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - index and scope boundary for preserved AAR runtime branch-history artifacts
not_authoritative_for:
  - current AAR architecture
  - current production acceptance status
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/aar-runtime-finalization
source_commit: 2e9cbe6104f2e23bc3031821459e1f16309a946b
validated_in_dcs: false
---

# AAR runtime branch history

This directory preserves the historical planning and acceptance artifacts from `agent/aar-rc-east-runtime-scope` during its reconciliation into `main`.

These files are evidence snapshots. They are **not** current project authority and must not override the consolidated `main` baseline in `docs/29-isaf-2009-2013-air-to-air-refueling.md`, current `docs/moose/` documentation, or current production-facing AAR data.

In particular, planning states, receiver scope, candidate areas, acceptance status, accelerated FuelLow thresholds, or unfinished Acceptance-6 wording contained in the preserved snapshots describe the branch at the time of capture. Current validated runtime conclusions and owner decisions are recorded in the consolidated main documentation.

The branch history itself is retained through the reconciliation merge ancestry. Runtime test source and the PowerShell builder remain under `mission/tests/aar-kc135-runtime/` and `tools/` as historical/reproducibility fixtures; they are not production tanker control code.
