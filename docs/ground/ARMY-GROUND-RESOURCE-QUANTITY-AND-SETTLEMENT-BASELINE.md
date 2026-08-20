---
document_id: OMW-ARMY-GROUND-RESOURCE-QUANTITY-SETTLEMENT
status: PLANNED
document_class: DOMAIN_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - working CampaignState quantities for the current six Jalalabad/Kunar Ground Foundation nodes
  - working Ground action costs and readiness semantics
  - Ground settlement authority boundary between CampaignState and MOOSE/DCS representations
not_authoritative_for:
  - exact historical daily property-book inventories or personnel rosters
  - final Mission Editor object counts
  - final Ground-order generation
  - fixed artillery inventories not covered by a separate current decision
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - Honaker dependent-only resource model
  - Honaker 40-person child-only commitment as the complete local resource model
  - fixed M777/L118 loss-settlement clauses for Honaker
superseded_by:
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: true
---

# ARMY Ground Foundation – Resource Quantity and Settlement Baseline

## 1. Zweck

Die Ground Foundation führt konkrete CampaignState-Mengen als OMW-Designwerte. Vollständige historische lokale Property Books liegen nicht vor und werden nicht behauptet.

```text
historical evidence
-> supported role / scale
-> OMW design quantity
-> CampaignState strategic authority
-> MOOSE/DCS operational representation
```

## 2. Resource units

### PERSONNEL

`PERSONNEL` is a real strategic headcount for OMW Ground tasking. It is not the complete historical population of an installation.

### VEHICLE

`VEHICLE` is one strategic vehicle unit. Decorative/statics and transient theater convoys do not automatically increase this stock.

### SUPPLY / AMMO / FUEL

These resources use normalized CampaignState logistics units:

```text
1 SUPPLY_UNIT = one normalized general sustainment package
1 AMMO_UNIT   = one normalized Ground ammunition package
1 FUEL_UNIT   = one normalized Ground fuel package
```

They are not claims of historical tonnage or liters.

## 3. Six-node initial stock

Order: `PERSONNEL / VEHICLE / SUPPLY / AMMO / FUEL`.

```text
GROUND_NODE_JALALABAD 480 / 48 / 120 / 100 / 120
GROUND_NODE_FORTRESS  160 / 18 / 44  / 48  / 40
GROUND_NODE_JOYCE     180 / 20 / 48  / 44  / 40
GROUND_NODE_WRIGHT    120 / 22 / 36  / 30  / 36
GROUND_NODE_HONAKER   120 / 18 / 40  / 40  / 36
GROUND_NODE_BOSTICK   220 / 26 / 56  / 52  / 48
```

Support-parent contract:

```text
JALALABAD -> OFF_MAP
FORTRESS  -> JALALABAD
JOYCE     -> JALALABAD
WRIGHT    -> JALALABAD
HONAKER   -> JOYCE
BOSTICK   -> JALALABAD
```

A support parent is not a second resource authority.

Fortress/Honaker quantities are defined by `OMW-ARMY-GROUND-FORTRESS-HONAKER-2011-RESOURCE-DECISION`.

## 4. Dependent OP commitments

The dependent OP model remains separate from the six root-stock nodes.

### Bostick OPs

```text
OP Mustang     nominal PERSONNEL = 12
OP Clydesdale  nominal PERSONNEL = 12
OP Stallion    nominal PERSONNEL = 12
```

Total full-occupancy commitment:

```text
36 PERSONNEL from the Bostick strategic domain
```

Routine OP supply is abstracted unless a later logistics mission explicitly transfers resources.

### OP JoJo

```text
nominal PERSONNEL candidate = 12
activation = PROVISIONAL
active reservation = 0 until owner activation
```

COP Honaker-Miracle itself is no longer a dependent-only child resource commitment. It owns `GROUND_NODE_HONAKER` stock.

## 5. Existing protected local defense reserves

Existing working reserves for the original four nodes remain:

| Node | Personnel reserve | Vehicle reserve | Ammo reserve | Fuel reserve |
|---|---:|---:|---:|---:|
| Jalalabad | 120 | 10 | 25 | 20 |
| Joyce | 48 | 4 | 12 | 8 |
| Wright | 36 | 4 | 10 | 8 |
| Bostick | 60 | 5 | 14 | 10 |

Fortress/Honaker exact defense-reserve thresholds are not invented by Acceptance 9; they remain a later Ground-order/readiness calibration. Until then, mission generation must not silently assume their entire stock is freely taskable.

## 6. Working action costs

### Motorized Patrol

```yaml
PERSONNEL: 12
VEHICLE: 4
SUPPLY: 1
AMMO: 2
FUEL: 2
```

For the validated materialization/settlement correlation:

```text
1 M-ATV = 1 VEHICLE + 3 PERSONNEL
4-vehicle patrol = 4 VEHICLE + 12 PERSONNEL
```

### Ground QRF

```yaml
PERSONNEL: 16
VEHICLE: 4
SUPPLY: 1
AMMO: 3
FUEL: 3
```

### Local Logistics / Resupply Convoy

```yaml
PERSONNEL: 6
VEHICLE: 2
SUPPLY: payload-defined
AMMO: payload-defined
FUEL: 2 plus payload-defined fuel transfer
```

### OP personnel reinforcement

```yaml
PERSONNEL: requested replacement count
VEHICLE: transport-method dependent
SUPPLY: 0
AMMO: 0
FUEL: transport-method dependent
```

No fixed Honaker artillery fire-mission cost is part of this baseline.

## 7. Readiness thresholds

Working resource state:

```text
AVAILABLE     >= 60%
CONSTRAINED   >= 35% and < 60%
CRITICAL      > 0% and < 35%
UNAVAILABLE   = 0% or required minimum cannot be met
```

A mission remains ineligible if its action cost would violate an applicable protected reserve even when the percentage state appears sufficient.

Capability baseline:

```text
PATROL
  required: PERSONNEL, AMMO
  motorized additionally: VEHICLE, FUEL

QRF
  required: PERSONNEL, VEHICLE, AMMO, FUEL

LOGISTICS
  required: PERSONNEL, VEHICLE, FUEL
  plus payload resource

CHILD SUPPORT
  required: PERSONNEL
  plus transport resources where applicable
```

## 8. Settlement contract

Physical DCS state is telemetry/evidence until correlated to an authoritative CampaignState commitment.

```text
CampaignState reservation approved
-> MOOSE operational asset selected/materialized
-> physical mission executes
-> observed return/loss/open state
-> adapter submits idempotent settlement
-> CampaignState mutates exactly once
```

Validated rules:

```text
confirmed return, including damaged survivor
-> immediate one-time availability credit

confirmed loss
-> permanent loss

open nonterminal commitment at server stop/crash
-> one-time strategic recredit at next startup

physical DCS/MOOSE group from the previous session
-> no continuation / no respawn
```

### Vehicle loss

```text
confirmed loss of one correlated strategic vehicle
-> VEHICLE -1 exactly once
-> VEHICLE_LOST audit +1 exactly once
```

### Personnel loss

Personnel settlement follows the mission/resource correlation. Visible DCS soldiers are not automatically one-to-one persistent personnel.

### Supply / Ammo / Fuel loss

Only explicitly correlated physical cargo/storage representations or mission manifests may produce strategic loss. Decorative destruction does not create arbitrary resource debits.

## 9. Honaker artillery correction

The former clauses for:

```text
2 x M777A2 fixed Honaker assets
2 x L118_Unit proxy slots
fixed-fire-support loss settlement
```

are superseded.

Current contract:

```text
2011 local mortar capability = confirmed
Jan-2010 possible two-gun position = observed; type/continuity unresolved
2012 M777 evidence = outside scenario period
no fixed M777/L118 production resource or loss-settlement contract
```

## 10. CampaignState <-> MOOSE authority

```text
CampaignState
= sole strategic authority

MOOSE WAREHOUSE / BRIGADE / PLATOON / ARMYGROUP
= operational selection and lifecycle representation

DCS groups / statics / cargo / warehouses
= physical representation and telemetry
```

Forbidden reverse authority includes:

```text
MOOSE Warehouse count -> overwrite CampaignState
DCS warehouse quantity -> overwrite CampaignState
DCS despawn -> automatic strategic return
uncorrelated DCS destroy -> strategic debit
CTLD delivery -> automatic strategic credit
```

## 11. Accepted technical evidence

Acceptance 7 validates the physical MOOSE Ground lifecycle and settlement behavior. Acceptance 8 validates production-shaped single-CampaignState integration. Acceptance 9-2 validates all six Ground stock nodes and the existing Fortress/Honaker settlement path.

Acceptance 9-2 provenance:

```text
acceptance commit: 45d916217c0085728082c3ef2efcd582d736caae
bundle SHA-256: 35cc922581da980f558733433e487b025e083859b943641276672b6c168b4d6a
MIZ SHA-256: 29587060d630d53303d4e858c1fd5a898ea3e09d51dec36ff130d3d0ac6e3ef3
DCS: 2.9.28.26385 MT
result: PASS
```

## 12. Later scope

Not closed by this Foundation baseline:

```text
Fortress/Honaker exact defense-reserve calibration
exact Fortress/Honaker vehicle-family split
Ground-order generation
OPSTRANSPORT
general cross-domain persistence
```
