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
supersedes:
superseded_by:
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: true
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

## 2. Zielstatus GROUNDBASE

Der technische Ground-Foundation-/GROUNDBASE-Zielzustand ist auf diesem Branch erreicht:

```text
CampaignState = sole strategic resource authority
MOOSE BRIGADE / WAREHOUSE / PLATOON / ARMYGROUP = operational lifecycle
DCS groups/statics/cargo = temporary physical representation / telemetry
strategic resource owner != physical dispatch origin
```

Erreicht sind:

```text
six operational Ground domains
six strategic Ground stock nodes
single CampaignState composition with AirOps + AAR + Ground
validated physical MOOSE Ground lifecycle
validated return/loss/restart settlement
Fortress/Honaker permanent stock decision
Fortress/Honaker stock integration into production source modules
```

Nicht Teil dieses abgeschlossenen Foundation-Ziels sind Ground-order generation, vollständige Detail-ORBAT jeder Garnison, OPSTRANSPORT oder allgemeine cross-domain persistence.

## 3. Settlement – ACCEPTED TECHNICAL BASELINE

Verbindliche Motorized-Patrol-Korrelation:

```text
1 M-ATV = 1 VEHICLE + 3 PERSONNEL
```

Settlement-Regeln:

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

## 4. Production-shaped CampaignState integration

Acceptance 8 validated the single-CampaignState integration of AirOps, AAR and the original four Ground nodes while preserving the existing Ground settlement adapter.

```text
OMW_GND_A8 COMPOSITION_OK
OMW_GND_A8 SETTLEMENT_OK
OMW_GND_A8 RESTART_OK
OMW_GND_A8 RUNTIME_PASS
```

Production source modules:

```text
scripts/logistics/OMW_GroundInitialStock.lua
scripts/ground/OMW_GroundCampaignStateAdapter.lua
scripts/ground/OMW_GroundRuntimeIntegration.lua
scripts/logistics/OMW_AirOpsCampaignStateInitializer.lua
```

No second CampaignState store, MOOSE resource authority or DCS Warehouse resource authority is introduced.

## 5. Fortress / Honaker resource decision – BINDING

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

These are OMW design quantities, not claims of exact historical daily inventories.

Current Honaker artillery evidence contract:

```text
2011 local mortar capability = confirmed
Jan-2010 possible two-gun position = observed; type/continuity unresolved
2012 M777 evidence = outside scenario period
no fixed M777/L118 production requirement
```

## 6. Acceptance 9-2 – ACCEPTED TECHNICAL BASELINE

Accepted runtime provenance:

```text
Acceptance commit:
45d916217c0085728082c3ef2efcd582d736caae

Test-ID:
ARMY-GROUND-ACCEPTANCE-9-2

Bundle SHA-256:
35cc922581da980f558733433e487b025e083859b943641276672b6c168b4d6a

MIZ:
OMW_Template_v14_ground_test.miz

MIZ SHA-256:
29587060d630d53303d4e858c1fd5a898ea3e09d51dec36ff130d3d0ac6e3ef3

DCS:
2.9.28.26385 MT

MOOSE commit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

Moose.lua SHA-256:
e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Real runtime markers:

```text
OMW_GND_A9 START testId=ARMY-GROUND-ACCEPTANCE-9-2
OMW_GND_A9 SIX_NODE_STOCK_OK fortressVehicle=18 fortressPersonnel=160 honakerVehicle=18 honakerPersonnel=120
OMW_GND_A9 FORTRESS_SETTLEMENT_OK returnedVehicle=4 returnedPersonnel=12 exactlyOnce=true
OMW_GND_A9 HONAKER_SETTLEMENT_OK returnedVehicle=3 returnedPersonnel=9 lostVehicle=1 lostPersonnel=3 exactlyOnce=true
OMW_GND_A9 RUNTIME_PASS testId=ARMY-GROUND-ACCEPTANCE-9-2 sixGroundNodes=true productionBaselineMutation=false mizMutation=false
```

Result document:

```text
mission/tests/army-ground-foundation/results/2026-08-20-acceptance-9-runtime.md
```

The failed `ARMY-GROUND-ACCEPTANCE-9-1` run remains preserved as regression evidence only.

## 7. Branch closeout status

Abgeschlossen:

```text
1. Acceptance 9-2 runtime provenance documented
2. Fortress/Honaker superseded quantity and artillery clauses reconciled in the Ground domain contracts
3. six-node CampaignState production source contract documented
4. restart contract reconciled to strategic one-time recredit with no physical continuation
5. no new MOOSE/DCS lifecycle code introduced after the accepted runtime commit
```

Noch vor Review/Merge erforderlich:

```text
1. repository documentation validator
2. complete branch diff review against main
3. owner decision whether to open/advance the branch PR and merge
```

No Acceptance 10 is planned merely to repeat Acceptance 7/8/9 behavior.

## 8. Separate later scopes

These items are intentionally not blockers for closing the GROUNDBASE foundation:

```text
exact July-2011 Joyce company distribution
exact July-2011 Bostick maneuver company/platoon distribution
exact July-2011 Wright artillery assignment
Jalalabad exact ground QRF/base-defense formation
Ground-order generation / ATO-equivalent Ground tasking structure
OPSTRANSPORT
general cross-domain persistence architecture
production patrol/observation mission geometry beyond validated Foundation behavior
```

They require their own later decisions and/or branches.

## 9. Verification rule

No local build, hash or DCS behavior is assumed. Only real console output, real artifact hashes and real DCS evidence advance an acceptance gate.
