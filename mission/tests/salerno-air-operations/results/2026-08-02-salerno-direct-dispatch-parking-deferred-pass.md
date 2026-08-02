---
document_id: OMW-SAL-DIRECT-DISPATCH-PARKING-DEFERRED-015
status: ACCEPTED_TECHNICAL_BASELINE
authoritative_for:
  - Salerno AIRWING/SQUADRON direct-dispatch baseline with parking disabled
  - capability and payload availability for controlled CAS RECON and lift requests
not_authoritative_for:
  - isolated spawn attribution
  - COMMANDER dispatch
  - parking or cold-start compliance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
  - SAL-COMMANDER-SELECTION-18 for COMMANDER selection testing
source_branch: agent/salerno-read-only-diagnostics
source_commit: GIT_HISTORY
validated_in_dcs: true
---

# Salerno Direct Dispatch with Parking Deferred – PASS

## Test stage

```text
Version: SAL-PARKING-DEFERRED-15
Parking control: disabled/deferred
Direct missions: CAS, RECON, LIFT
COMMANDER: not tested in this stage
```

## Result

The Salerno foundation loaded successfully:

- AIRBASE, Warehouse, clients, templates, statics and zone found;
- `AW_US_SALERNO` constructed and started;
- five SQUADRONs constructed and registered;
- twenty Warehouse asset groups registered;
- five capability areas and required payloads registered;
- direct CAS, RECON and LIFT requests added;
- all three missions showed runtime progress;
- final direct-dispatch harness result passed;
- no Salerno-specific Lua error was observed;
- no loss was recorded in the debrief.

## Acceptance boundary

This was a functional multi-mission AIRWING integration test. It was not a causal spawn test because several independent missions used the same AIRWING, Warehouse and Salerno parking area concurrently.

It therefore does not prove:

```text
which visible aircraft belonged to which request without timeline correlation
exact parking or spawn terminal
client-space exclusion
cold ground start
COMMANDER selection
```

## Lesson

Parallel dispatch is useful for broad integration and stock/capability pressure testing. It is unsuitable for answering a narrow question such as:

```text
Which exact mission caused this exact aircraft to spawn at this exact position?
```

Later COMMANDER acceptance therefore removed all direct CAS, RECON and LIFT requests from the bundle.
