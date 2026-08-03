---
document_id: OMW-EVIDENCE-AIR-OPERATIONS-TEST-BATCHING-OWNER-DECISION-2026-08-03
status: BINDING_PROJECT_DECISION
document_class: OWNER_DECISION_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - batching of technically similar air-operations tests
  - default use of one integrated airport test run instead of routine per-aircraft micro-runs
  - failure-isolation boundary for follow-up runs
not_authoritative_for:
  - bypassing governance or MOOSE-first review
  - combining technically unrelated gates without an explicit acceptance contract
  - merge approval or Ready-for-Review approval
scenario_period: 2010-08-01/2011-12-31
project_phase: AIR_OPERATIONS_TEST_WORKFLOW
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit: PENDING_MERGE
decision_state: RECORDED
validated_in_dcs: false
supersedes: []
superseded_by: []
---

# Owner decision – batch similar air-operations tests

## Decision

Routine air-operations acceptance must not consume a separate full Mission Editor and DCS cycle for every aircraft family when the tests exercise the same technical mechanism and can be distinguished in one log.

The default workflow is:

```text
combine technically similar checks into one airport-level test bundle
produce per-family/per-subsystem result records inside the same log
use one Mission Editor change, one DCS run and one evidence package
split into smaller runs only after a failure requires isolation
```

## Immediate Tarinkot application

Tarinkot G6B is changed from three primary runs:

```text
AH-64 placement
UH-60 placement
CH-47 placement
```

to one primary combined run containing all three families.

The family-specific bundles remain diagnostic fallbacks and are not the normal execution path.

## Future airfield application

For later airfields and AIRWING/SQUADRON work:

- tests using the same MOOSE mechanism should be batched;
- each subsystem must retain its own unambiguous result marker;
- a combined test must preserve inventory and client-parking invariants;
- unrelated operational mechanisms are not combined merely to reduce run count;
- a failing subsystem may be retested separately without repeating already accepted independent subsystems unless interaction is suspected.

## Acceptance principle

Test granularity is driven by failure-domain separation, not by aircraft type alone.
