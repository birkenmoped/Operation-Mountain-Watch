---
document_id: OMW-GROUND-AMMO-RESUPPLY-ACCEPTANCE-1-FAIL-1
status: HISTORICAL_TEST_FIXTURE
document_class: ACCEPTANCE_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - historical DCS evidence for the first Stage-1A Ground AMMO RESUPPLY attempt
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
  - OMW-GROUND-AMMO-RESUPPLY-ACCEPTANCE-1
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
validated_in_dcs: true
---

# Ground AMMO RESUPPLY Acceptance 1 – Lauf 1 – Historical FAIL

## Ergebnis

```text
Classification: FAIL
Runtime reached physical MOOSE execution: false
Strategic transfer created: false
Vehicle materialized: false
Delivery/RTZ tested: false
Failure: RESOURCE_DEMAND_POLICY_NO_CANDIDATE
```

## Provenienz

```text
TestId: GROUND-AMMO-RESUPPLY-ACCEPTANCE-1
MIZ: OMW_Template_v17.miz
DCS: 2.9.28.26385
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
Acceptance bundle SHA-256: D1E908D08DF3DA787D01E760F5B9C01771F5D17CBBD51C8545A4A00086E10676
```

## Root Cause

Die Mission enthielt einen älteren Ground-Production-Stand mit `reorder = 0` und `critical = 0` für transferierbare Ground-Ressourcen. `ResourceDemandPolicy` verweigerte deshalb korrekt die Candidate-Erzeugung. Der Lauf testete MOOSE AMMOSUPPLY noch nicht.

Die spätere Stage-1A-Acceptance ersetzt diesen historischen Fehlversuch als technische Aussage.
