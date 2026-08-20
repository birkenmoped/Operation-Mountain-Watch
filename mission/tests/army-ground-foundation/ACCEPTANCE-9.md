---
document_id: OMW-TEST-ARMY-GROUND-ACCEPTANCE-9
status: PLANNED
document_class: ACCEPTANCE_TEST
owning_policy: OMW-GOV-001
scenario_period: 2010-08-01/2011-12-31
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# ARMY Ground Acceptance 9 – Fortress / Honaker Production Stock

## 1. Purpose

Acceptance 9 validates the six-node Ground initial-stock composition after the 2011 Fortress/Honaker resource decision.

It introduces no new MOOSE class, event, FSM, scheduler, native-DCS lifecycle logic or private MOOSE override.

Physical Ground behavior remains covered by Acceptance 7. Acceptance 9 is a CampaignState production-stock gate only.

## 2. Source decision

```text
docs/ground/ARMY-GROUND-FORTRESS-HONAKER-2011-RESOURCE-DECISION.md
```

Required initial values:

```text
GROUND_NODE_FORTRESS
  PERSONNEL 160
  VEHICLE    18
  SUPPLY     44
  AMMO       48
  FUEL       40
  supplyParent = GROUND_NODE_JALALABAD

GROUND_NODE_HONAKER
  PERSONNEL 120
  VEHICLE    18
  SUPPLY     40
  AMMO       40
  FUEL       36
  supplyParent = GROUND_NODE_JOYCE
```

Existing nodes must remain unchanged:

```text
GROUND_NODE_JALALABAD 480 / 48 / 120 / 100 / 120
GROUND_NODE_JOYCE     180 / 20 / 48  / 44  / 40
GROUND_NODE_WRIGHT    120 / 22 / 36  / 30  / 36
GROUND_NODE_BOSTICK   220 / 26 / 56  / 52  / 48
```

Order is `PERSONNEL / VEHICLE / SUPPLY / AMMO / FUEL`.

## 3. Test source and builder

```text
mission/tests/army-ground-foundation/src/09-army-ground-fortress-honaker-production-stock.lua
tools/build-army-ground-acceptance-9.ps1
```

Generated bundle:

```text
mission/tests/army-ground-foundation/dist/OMW_Army_Ground_Acceptance_9.lua
```

Current BuilderVersion / Test-ID:

```text
ARMY-GROUND-ACCEPTANCE-9-2
```

`ARMY-GROUND-ACCEPTANCE-9-1` is retained only as failed runtime evidence. It must not be reused.

## 4. Static/build gates

Builder must confirm:

```text
single existing AirOpsCampaignStateInitializer path
AirOpsCampaignStateInitializer node registry contains all six Ground nodes
GroundInitialStock contains all six nodes
Ground resource rows = 42
Fortress and Honaker resource IDs exist
existing GroundCampaignStateAdapter reused
existing GroundRuntimeIntegration reused
no MIST
no MissionScripting.lua mutation
no filesystem/process execution from mission code
no teleport/spawn override
no M777A2/L118 fixed-artillery assumption in the production stock/test path
```

## 5. Runtime gates

The DCS log must contain all of:

```text
OMW_GND_A9 START
OMW_GND_A9 SIX_NODE_STOCK_OK
OMW_GND_A9 FORTRESS_SETTLEMENT_OK
OMW_GND_A9 HONAKER_SETTLEMENT_OK
OMW_GND_A9 RUNTIME_PASS
```

Any `OMW_GND_A9 FAIL` or mission-script exception before `RUNTIME_PASS` fails the run.

### Fortress settlement

```text
4 VEHICLE + 12 PERSONNEL materialized/reserved
4 VEHICLE + 12 PERSONNEL returned
second return attempt is idempotent
final Fortress stock returns to 18 VEHICLE / 160 PERSONNEL
```

### Honaker settlement

```text
4 VEHICLE + 12 PERSONNEL materialized/reserved
1 VEHICLE + 3 PERSONNEL confirmed permanent loss
3 VEHICLE + 9 PERSONNEL returned
second return attempt is idempotent
final Honaker stock = 17 VEHICLE / 117 PERSONNEL
loss audit = 1 VEHICLE / 3 PERSONNEL
```

## 6. Historical correction gate

Acceptance 9 does not create or require a fixed Honaker artillery asset.

The superseded assumption

```text
2 x M777A2 at Honaker on 30.07.2011
```

must not be used by the production stock or Acceptance 9 bundle.

Current evidence contract:

```text
2011 Honaker local mortar capability = confirmed
Jan-2010 possible two-gun position = observed but type/continuity unresolved
2012 M777 evidence = outside OMW scenario period
```

## 7. Failed Acceptance-9-1 evidence

The first real DCS run on 2026-08-20 failed immediately after the A9 start marker because the existing CampaignState initializer registry did not yet contain the new Fortress node:

```text
OMW_GND_A9 START testId=ARMY-GROUND-ACCEPTANCE-9-1
[OMW][Logistics.AirOpsCampaignStateInitializer] unknown CampaignState nodeId=GROUND_NODE_FORTRESS
```

Evidence:

```text
mission/tests/army-ground-foundation/results/2026-08-20-acceptance-9-failed-node-registry.md
```

The source fix registers both `GROUND_NODE_FORTRESS` and `GROUND_NODE_HONAKER`, and the builder now statically verifies the complete six-node registry before generating the bundle.

A new real build/hash and DCS run with `ARMY-GROUND-ACCEPTANCE-9-2` are required.

## 8. Validation boundary

A successful build is not DCS validation.

`VALIDATED` requires the real generated bundle hash, tested MIZ provenance and real DCS log from the exact tested artifact.
