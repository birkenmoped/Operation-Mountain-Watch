---
document_id: OMW-TEST-ARMY-GROUND-ACCEPTANCE-9-FAILED-NODE-REGISTRY
status: HISTORICAL_TEST_FIXTURE
document_class: TEST_RESULT
owning_policy: OMW-GOV-001
scenario_period: 2010-08-01/2011-12-31
source_branch: agent/army-ground-foundation-reconciliation
source_commit: 60a4931403405d01b1147f6beb6cc71e011c5406
validated_in_dcs: false
authoritative_for:
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
---

# ARMY Ground Acceptance 9 – failed runtime: CampaignState node registry

## Tested artifact

```text
Test-ID: ARMY-GROUND-ACCEPTANCE-9-1
Source commit: 60a4931403405d01b1147f6beb6cc71e011c5406
Bundle SHA-256: 3ad34e253cd36bd755379d1d94638dff1be3f002cdfdbe2eea5bdd51a6deaad1
Test MIZ: OMW_Template_v14_ground_test.miz
Uploaded MIZ SHA-256: 31b51da96b465ef483cf062a685904764652a0e4434eb9d73280149efddec64b
Embedded bundle SHA-256: 3ad34e253cd36bd755379d1d94638dff1be3f002cdfdbe2eea5bdd51a6deaad1
Embedded Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
DCS: 2.9.28.26385 MT
```

The embedded bundle hash exactly matched the locally built Acceptance-9-1 bundle. The run therefore failed against the intended tested artifact, not because of a stale or different embedded bundle.

## Runtime result

The DCS log reached:

```text
OMW_GND_A9 START testId=ARMY-GROUND-ACCEPTANCE-9-1
```

and then failed immediately during `AirOpsCampaignStateInitializer.CreateStore(...)`:

```text
[OMW][Logistics.AirOpsCampaignStateInitializer] unknown CampaignState nodeId=GROUND_NODE_FORTRESS
```

The required runtime gates were not reached:

```text
OMW_GND_A9 SIX_NODE_STOCK_OK
OMW_GND_A9 FORTRESS_SETTLEMENT_OK
OMW_GND_A9 HONAKER_SETTLEMENT_OK
OMW_GND_A9 RUNTIME_PASS
```

Result:

```text
FAILED
```

## Root cause

`OMW_GroundInitialStock.lua` correctly contained the new Fortress and Honaker stock rows, but `scripts/logistics/OMW_AirOpsCampaignStateInitializer.lua` still whitelisted only the earlier four Ground nodes in `Initializer.NodeAirbaseName`.

The initializer validates every stock row against that registry before creating CampaignState. Therefore the first Fortress row was rejected before the six-node store could be constructed.

This is a project adapter/registry defect. It is not a MOOSE/DCS lifecycle defect and does not invalidate Acceptance 7.

## Corrective action

The branch is corrected by:

```text
- registering GROUND_NODE_FORTRESS in AirOpsCampaignStateInitializer
- registering GROUND_NODE_HONAKER in AirOpsCampaignStateInitializer
- hardening the Acceptance 9 builder so all six Ground nodes must exist in the initializer registry
- bumping Acceptance 9 BuilderVersion/Test-ID to ARMY-GROUND-ACCEPTANCE-9-2
```

A new real local build/hash and DCS rerun are required. No pass or VALIDATED status may be inferred from the source correction alone.
