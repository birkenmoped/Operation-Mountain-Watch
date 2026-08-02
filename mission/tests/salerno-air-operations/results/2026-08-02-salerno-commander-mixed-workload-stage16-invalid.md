---
document_id: OMW-SAL-COMMANDER-MIXED-016
status: HISTORICAL_TEST_FIXTURE
authoritative_for:
  - invalidity of the mixed direct-dispatch and COMMANDER Stage-16 test
  - source attribution of the observed airborne Blackhawk
  - false-positive PASS caused by mission-state comparison
not_authoritative_for:
  - COMMANDER dispatch acceptance
  - parking or start-mode acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
  - OMW-SAL-CMD-TEST-017
  - SAL-COMMANDER-SELECTION-18
source_branch: agent/salerno-read-only-diagnostics
source_commit: 90a4c3a51fe63a1f3ae6bd6a76952c15772c1da5
validated_in_dcs: true
---

# Salerno COMMANDER Stage 16 – INVALID

## Intended objective

Validate one CAS mission added through `COMMANDER:AddMission()` after the Salerno AIRWING/SQUADRON baseline.

## Test contamination

The bundle still contained direct AIRWING missions:

```text
direct CAS
direct RECON
direct LIFT
```

These requests were still active or progressing when the COMMANDER stage began. The test therefore used two independent dispatch paths against the same AIRWING, Warehouse, SQUADRONs and limited Salerno operating area.

## Airborne Blackhawk

A UH-60/Blackhawk appeared directly in the air. Timeline analysis showed:

```text
direct LIFT mission -> Started
COMMANDER CAS mission -> remained planned
```

The Blackhawk was therefore attributable to the direct LIFT workload, not to the COMMANDER CAS mission.

The airborne spawn was not an intended acceptance result and remains a failure of the direct LIFT spawn/start expectation in that mixed run. It cannot be used to judge the COMMANDER path.

## False-positive PASS

The final logic excluded only the exact string `Planned`, while the MOOSE state was returned as lowercase `planned`.

As a result:

```text
mission state: planned
actual progress: false
reported final marker: PASS
```

The marker was invalid.

## Correct classification

```yaml
stage: SAL-COMMANDER-DISPATCH-16
test_isolation: false
blackhawk_source: DIRECT_LIFT
commander_mission_state: planned
commander_progress: false
reported_pass: false_positive
overall_result: INVALID
```

## Corrections introduced afterward

- direct AIRWING missions removed from the COMMANDER bundle;
- COMMANDER test moved earlier and isolated;
- mission states normalized to lowercase;
- `planned` and `unknown` explicitly treated as no progress;
- positive eligibility, selection and progress criteria introduced;
- Stage 17 correctly reported FAIL;
- Stage 18 added the missing COMMANDER start and passed.

## Lessons

1. Do not mix direct and COMMANDER dispatch when validating selection.
2. Correlate all mission timelines before attributing a visible aircraft.
3. A CAS request should not silently explain a UH-60 spawn.
4. Normalize FSM state strings before evaluation.
5. A PASS marker is not authoritative when the underlying state sequence contradicts it.
