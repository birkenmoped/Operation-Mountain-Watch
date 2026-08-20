---
document_id: OMW-TEST-ARMY-GROUND-FOUNDATION-TODO
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - current working scope and open tasks for the Jalalabad/Kunar ARMY ground foundation
not_authoritative_for:
  - exact historical daily property-book inventories
  - final Mission Editor object state
  - DCS runtime acceptance beyond cited result documents
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# ARMY Ground Foundation – Arbeitsstand und To-do

## 1. Aktueller Scope

```text
Jalalabad / FOB Fenty
COP Fortress
FOB Joyce
FOB Wright
COP Honaker-Miracle
FOB Bostick

Dependent OPs:
Honaker-Miracle -> OP JoJo
Bostick -> OP Mustang / OP Clydesdale / OP Stallion
```

Maßgebliche Fachdateien:

```text
docs/ground/ARMY-GROUND-FORTRESS-HONAKER-2011-RESOURCE-DECISION.md
docs/ground/ARMY-GROUND-KUNAR-OPERATIONAL-DOMAIN-RECONCILIATION.md
docs/ground/ARMY-GROUND-RESOURCE-QUANTITY-AND-SETTLEMENT-BASELINE.md
docs/ground/ARMY-GROUND-RETURN-SETTLEMENT-DECISION-PREPARATION.md
```

## 2. Architekturgrenze

```text
CampaignState = sole strategic resource authority
MOOSE BRIGADE / WAREHOUSE / PLATOON / ARMYGROUP = operational lifecycle
DCS groups/statics/cargo = temporary physical representation / telemetry
```

```text
strategic resource owner != physical dispatch origin
```

## 3. Settlement – VALIDATED

Verbindliche Motorized-Patrol-Korrelation:

```text
1 M-ATV = 1 VEHICLE + 3 PERSONNEL
```

Verbindliche Settlement-Regeln:

```text
confirmed return, including damaged survivor -> immediate one-time availability credit
confirmed loss -> permanent loss
open nonterminal commitment at server stop/crash -> one-time strategic recredit at next startup
no physical DCS/MOOSE continuation or respawn
```

Acceptance 7 validated the real MOOSE Ground lifecycle plus this CampaignState settlement contract.

```text
Source commit: e049e34fe8e6de878fd390486888f3912bb179d8
Bundle SHA-256: b591ccd746896c90064fa93d9b3d42626384f55e605efc748bf304ffccb86ec7
MIZ: OMW_Template_v14_ground_test.miz
MIZ SHA-256: 88184ec180837044ff4dcef7cca264fe7ee5fcf5d55a8af19b11125c41eab94d
DCS: 2.9.28.26385 MT
Result: PASS / owner visual acceptance
```

Runtime evidence:

```text
mission/tests/army-ground-foundation/results/2026-08-20-acceptance-7-runtime.md
```

## 4. Acceptance 8 – RUNTIME PASS

Acceptance 8 validated the production-shaped single-CampaignState composition for the previously decided four Ground stock nodes while preserving AirOps and AAR stock.

```text
OMW_GND_A8 START testId=ARMY-GROUND-ACCEPTANCE-8-1
OMW_GND_A8 COMPOSITION_OK airOps=true aar=true groundResources=28
OMW_GND_A8 SETTLEMENT_OK site=JOYCE returnedVehicle=3 returnedPersonnel=9 lostVehicle=1 lostPersonnel=3
OMW_GND_A8 RESTART_OK runtimeId=ARMY-GROUND-A8-BOSTICK-OPEN-1 vehicle=4 personnel=12 exactlyOnce=true
OMW_GND_A8 RUNTIME_PASS testId=ARMY-GROUND-ACCEPTANCE-8-1 singleCampaignState=true productionBaselineMutation=false mizMutation=false
```

Acceptance 8 introduced no new MOOSE behavior and no new physical lifecycle.

## 5. Fortress / Honaker 2011 resource decision – BINDING

The remaining quantity gap is closed by:

```text
docs/ground/ARMY-GROUND-FORTRESS-HONAKER-2011-RESOURCE-DECISION.md
```

Production-stock nodes:

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

Evidence boundary:

```text
Fortress VEHICLE 18 = OMW design value supported by Sep-2011 ~16+ vehicle-sized physical footprint
Fortress PERSONNEL 160 = OMW taskable pool supported by historical 150-200 occupancy scale and overlapping 2011 MP/infantry presence
Honaker VEHICLE 18 = OMW design value supported by Jan-2010 ~17 vehicle-sized footprint plus 2011 protected-vehicle/mounted/recovery evidence
Honaker PERSONNEL 120 = OMW taskable pool supported by D Co 2-35 / TF Cacti 2011 operational presence and sustained-COP/staging role
```

These are OMW design quantities, not claims of exact historical daily inventories.

## 6. Honaker artillery correction

The earlier Foundation assumption

```text
2 x M777A2 at Honaker on 30.07.2011
```

is superseded for the OMW scenario baseline.

Current contract:

```text
2011 local mortar capability = confirmed
Jan-2010 possible two-gun position = observed; type/continuity unresolved
2012 M777 evidence = outside scenario period
no fixed M777/L118 production requirement from the superseded July-2011 assumption
```

Older Ground documents containing the superseded assumption must be reconciled before merge to main.

## 7. Current Gate – Acceptance 9 corrected rerun

Acceptance 9 validates:

```text
single CampaignState with six Ground stock nodes
Fortress exact design values
Honaker exact design values
existing Jalalabad/Joyce/Wright/Bostick values unchanged
AirOps and AAR stock preserved
existing exactly-once Ground settlement adapter on Fortress and Honaker
no new MOOSE/DCS lifecycle behavior
```

### Failed first runtime

The real `ARMY-GROUND-ACCEPTANCE-9-1` run on 2026-08-20 failed immediately after:

```text
OMW_GND_A9 START testId=ARMY-GROUND-ACCEPTANCE-9-1
```

with:

```text
[OMW][Logistics.AirOpsCampaignStateInitializer] unknown CampaignState nodeId=GROUND_NODE_FORTRESS
```

Tested artifact provenance:

```text
Source commit: 60a4931403405d01b1147f6beb6cc71e011c5406
Bundle SHA-256: 3ad34e253cd36bd755379d1d94638dff1be3f002cdfdbe2eea5bdd51a6deaad1
Uploaded/tested MIZ SHA-256: 31b51da96b465ef483cf062a685904764652a0e4434eb9d73280149efddec64b
Embedded bundle SHA-256: 3ad34e253cd36bd755379d1d94638dff1be3f002cdfdbe2eea5bdd51a6deaad1
Embedded Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
DCS: 2.9.28.26385 MT
Result: FAILED
```

Failure evidence:

```text
mission/tests/army-ground-foundation/results/2026-08-20-acceptance-9-failed-node-registry.md
```

### Root cause and correction

The Ground stock contained Fortress/Honaker, but `AirOpsCampaignStateInitializer.NodeAirbaseName` still registered only the earlier four Ground nodes.

Corrected branch state:

```text
GROUND_NODE_FORTRESS registered
GROUND_NODE_HONAKER registered
Acceptance 9 builder statically verifies all six initializer node-registry entries
BuilderVersion/Test-ID bumped to ARMY-GROUND-ACCEPTANCE-9-2
```

Files:

```text
scripts/logistics/OMW_AirOpsCampaignStateInitializer.lua
mission/tests/army-ground-foundation/ACCEPTANCE-9.md
mission/tests/army-ground-foundation/src/09-army-ground-fortress-honaker-production-stock.lua
tools/build-army-ground-acceptance-9.ps1
```

Required runtime markers for the corrected rerun:

```text
OMW_GND_A9 START testId=ARMY-GROUND-ACCEPTANCE-9-2
OMW_GND_A9 SIX_NODE_STOCK_OK
OMW_GND_A9 FORTRESS_SETTLEMENT_OK
OMW_GND_A9 HONAKER_SETTLEMENT_OK
OMW_GND_A9 RUNTIME_PASS testId=ARMY-GROUND-ACCEPTANCE-9-2
```

No success is inferred from the source correction. A real rebuilt bundle hash and a new DCS run are required.

## 8. After Acceptance 9

If corrected Acceptance 9 passes:

```text
reconcile superseded Fortress/Honaker clauses in older Ground baseline documents
-> production activation/integration of the six-node Ground CampaignState foundation
-> Ground-order generation remains a separate later scope
```

Still open and not decided by Acceptance 9:

```text
exact July-2011 Joyce company distribution
exact July-2011 Bostick maneuver company/platoon distribution
exact July-2011 Wright artillery assignment
Jalalabad exact ground QRF/base-defense formation
OPSTRANSPORT
general cross-domain persistence architecture
```

No local build, hash or DCS behavior is assumed. Only real console output, real artifact hashes and real DCS evidence advance the gate.
