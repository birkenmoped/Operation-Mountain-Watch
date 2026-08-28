---
document_id: OMW-TEST-TKOT-G6B-COMBINED-WRONG-APRON-FAIL-2026-08-03
status: BINDING
document_class: TEST_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - classification of the first combined Tarinkot G6B runtime run
  - rejection of TerminalType 104 as the productive Tarinkot helicopter parking pool
  - authorization of one combined HelicopterOnly retest
not_authoritative_for:
  - final productive SQUADRON parking lists
  - AIRWING, SQUADRON, payload, AUFTRAG, COMMANDER or OPSTRANSPORT acceptance
  - merge approval or Ready-for-Review approval
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit: 585f3c46d4ff0a4b167c984d427bcdb356138e69
validated_in_dcs: true
supersedes: []
superseded_by: []
---

# Tarinkot G6B combined placement – FAIL: wrong apron

## Result

```yaml
runtime_coordinate_assignment: PASS
requested_group_count: PASS
requested_unit_count: PASS
visual_designated_apron_acceptance: FAIL
formal_gate_result: FAIL_VISUAL_WRONG_APRON
G7_authorized: false
retest_required: true
```

The combined bundle placed all five aircraft close to the requested terminal coordinates and logged:

```text
RESULT G6B_COMBINED_CONTROLLED_PLACEMENT status=PASS_RUNTIME_PLACEMENT
```

This runtime marker is not a G6B acceptance because visual inspection showed that none of the spawned helicopters was located on the designated Tarinkot helicopter parking area.

## Root cause

All selected terminals were `TerminalType 104`:

```text
AH-64: TerminalIDs 0 and 25
UH-60: TerminalIDs 13 and 22
CH-47: TerminalID 14
```

`104` is a general OpenBig parking class. The first combined test inherited the G6A `HelicopterUsable` acceptance, which also admits general apron positions. That criterion was too broad for the Tarinkot project requirement.

The designated helicopter parking cluster uses:

```text
AIRBASE.TerminalType.HelicopterOnly
numeric value: 40
```

Therefore exact coordinate placement on a type-104 node is insufficient.

## Corrective contract

The regular retest must:

- use exactly one combined DCS run;
- reject every terminal whose type is not exactly `40`;
- keep client TerminalIDs `3`, `8` and `20` excluded;
- use only currently unreserved type-40 nodes;
- retain separate family result markers in the common log;
- require visual confirmation that all five aircraft stand on the designated helicopter area;
- keep productive AIRWING/SQUADRON parking lists empty until PASS.

Retest probe set:

```yaml
AH64:
  terminal_ids: [4, 23]
UH60:
  terminal_ids: [21, 30]
CH47:
  terminal_ids: [29]
```

These nodes are part of the type-40 helicopter cluster and are not client reservations or directly occupied by the named aircraft statics in the G5/G6A evidence. Existing revetment geometry still requires visual rotor and structure-clearance acceptance.

## Gate state

```yaml
G5_read_only_diagnostics: PASS_DCS
G6A_geometric_dataset: PASS_DCS_BUT_HELICOPTERUSABLE_SCOPE_TOO_BROAD
G6B_first_combined_run: FAIL_VISUAL_WRONG_APRON
G6B_helicopter_apron_retest: AUTHORIZED
G7_airwing_squadron_payload: BLOCKED_BY_G6B
```
