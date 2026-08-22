---
document_id: OMW-GROUND-AMMO-RESUPPLY-ACCEPTANCE-1-FAIL-1
status: TEST_RESULT
document_class: ACCEPTANCE_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - exact DCS result of the first Stage-1A Ground AMMO RESUPPLY runtime attempt on 2026-08-22
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Ground AMMO RESUPPLY Acceptance 1 – Lauf 1 – FAIL

## Provenienz

```text
TestId: GROUND-AMMO-RESUPPLY-ACCEPTANCE-1
MIZ: OMW_Template_v17.miz
DCS: 2.9.28.26385
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
Acceptance bundle SHA-256: D1E908D08DF3DA787D01E760F5B9C01771F5D17CBBD51C8545A4A00086E10676
```

Owner returned:

```text
dcs(20260822-171940).log
debrief(20260822-171941).log
```

## Ergebnis

```text
Classification: FAIL
Runtime reached physical MOOSE execution: false
Strategic transfer created: false
Vehicle materialized: false
Delivery/RTZ tested: false
```

DCS marker:

```text
[OMW][GROUND-AMMO-RESUPPLY-ACCEPTANCE-1] START testId=GROUND-AMMO-RESUPPLY-ACCEPTANCE-1 origin=GROUND_NODE_JOYCE destination=GROUND_NODE_HONAKER resource=GROUND_AMMO_PACKAGE
[OMW][GROUND-AMMO-RESUPPLY-ACCEPTANCE-1] FAIL reason=RESOURCE_DEMAND_POLICY_NO_CANDIDATE
```

## Root Cause

The acceptance logic correctly created the test-only Honaker consumption down to quantity 20, then called `ResourceDemandPolicy.Evaluate(...)`. The selected MIZ, however, embeds an older `OMW_Ground_Base.lua` production bundle built from Ground initial-stock data where transferable Ground rows still carry `reorder = 0` and `critical = 0`.

Embedded Ground bundle header in `OMW_Template_v17.miz`:

```text
BuilderVersion: OMW-GROUND-PRODUCTION-BASE-4
GitCommit: 49f43a856c1f8bc32ca64835af856119a295640e
```

The current repository Ground initial-stock source on main contains the later PR-115 threshold baseline:

```text
InitialStock.ResupplyThresholds.reorderRatio = 0.50
InitialStock.ResupplyThresholds.criticalRatio = 0.25
```

For Honaker AMMO target 40 this means:

```text
reorder = 20
critical = 10
```

`ResourceDemandPolicy` intentionally returns `nil` when `row.reorder <= 0`. Therefore the observed `RESOURCE_DEMAND_POLICY_NO_CANDIDATE` is expected for the stale embedded Ground production bundle and does not yet test MOOSE AMMOSUPPLY execution.

## Correction / next gate

No acceptance-runtime workaround is permitted. The production Ground bundle must first be rebuilt from the current repository source and owner-embedded in the next test MIZ, preserving CampaignState as the sole strategic authority.

```text
build current tools/build-ground-production-base.ps1
-> record generated OMW_Ground_Base.lua SHA-256
-> owner replaces only the Ground production DO SCRIPT FILE resource in next MIZ revision
-> retain the already verified acceptance bundle unchanged
-> verify embedded Ground bundle hash + acceptance hash + Moose hash
-> rerun Stage-1A acceptance
```

This result does not validate or invalidate:

```text
MOOSE AMMOSUPPLY routing
M1083 materialization
Joyce -> Honaker pathfinding
destination-zone delivery proof
CampaignState transfer debit/credit
RTZ / Returned / Warehouse AddAsset
```

Those paths were not reached in this run.
