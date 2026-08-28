---
document_id: OMW-ARMY-GROUND-RESOURCE-READINESS-CONTRACT
status: PLANNED
document_class: DOMAIN_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - resource-class contract for the six current ARMY Ground Foundation stock nodes
  - readiness semantics derived from Ground resource availability
  - capability impact of Ground resource loss and supply failure
not_authoritative_for:
  - exact Fortress/Honaker defense-reserve thresholds
  - final historical company or platoon strengths
  - final Ground-order generation
  - fixed Honaker artillery proxy
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - four-root-only readiness model
  - owner-decision-required quantities now closed by current stock baselines
  - Honaker child-only resource treatment
superseded_by:
source_branch: agent/army-ground-foundation-reconciliation
source_commit: 998080da9a7a71dae7f713b9590dfeadb5ae93ba
validated_in_dcs: true
---

# ARMY Ground Foundation – Ressourcen- und Readiness-Vertrag

## 1. Authority

```text
CampaignState resource contract
-> reservation / transfer / settlement
-> MOOSE operational representation
-> DCS physical representation
-> observed result
-> CampaignState settlement
```

MOOSE `BRIGADE`, `PLATOON`, `WAREHOUSE`, `ARMYGROUP`, CTLD and DCS Warehouses do not independently own or replenish these strategic stocks.

## 2. Strategic resource classes

Each current Ground stock node exposes:

```text
PERSONNEL
VEHICLE
SUPPLY
AMMO
FUEL
PERSONNEL_LOST audit
VEHICLE_LOST audit
```

`PERSONNEL` is strategic taskable manpower, not a one-to-one count of visible DCS infantry.

`VEHICLE` is strategic Ground mobility/support capacity, not a DCS type string.

`SUPPLY`, `AMMO` and `FUEL` are normalized Ground logistics units.

## 3. Six current Ground nodes

```text
GROUND_NODE_JALALABAD
GROUND_NODE_FORTRESS
GROUND_NODE_JOYCE
GROUND_NODE_WRIGHT
GROUND_NODE_HONAKER
GROUND_NODE_BOSTICK
```

Current initial values, ordered `PERSONNEL / VEHICLE / SUPPLY / AMMO / FUEL`:

```text
GROUND_NODE_JALALABAD 480 / 48 / 120 / 100 / 120
GROUND_NODE_FORTRESS  160 / 18 / 44  / 48  / 40
GROUND_NODE_JOYCE     180 / 20 / 48  / 44  / 40
GROUND_NODE_WRIGHT    120 / 22 / 36  / 30  / 36
GROUND_NODE_HONAKER   120 / 18 / 40  / 40  / 36
GROUND_NODE_BOSTICK   220 / 26 / 56  / 52  / 48
```

Fortress/Honaker values are governed by `OMW-ARMY-GROUND-FORTRESS-HONAKER-2011-RESOURCE-DECISION`.

## 4. Resource IDs

Schema:

```text
GROUND:<groundNodeId>:<resourceClass>
```

Examples:

```text
GROUND:GROUND_NODE_FORTRESS:PERSONNEL
GROUND:GROUND_NODE_FORTRESS:VEHICLE
GROUND:GROUND_NODE_HONAKER:PERSONNEL
GROUND:GROUND_NODE_HONAKER:VEHICLE
GROUND:GROUND_NODE_HONAKER:VEHICLE_LOST
```

Resource IDs are strategic bookkeeping addresses and are independent of DCS/MOOSE names.

## 5. Capability contracts

Common capabilities may require:

| Capability | PERSONNEL | VEHICLE | SUPPLY | AMMO | FUEL |
|---|---|---|---|---|---|
| Base Defense | required | supporting | sustainment | required | supporting |
| Foot Patrol | required | optional | sustainment | required | optional |
| Motorized Patrol | required | required | sustainment | required | required |
| Ground QRF | required | required | supporting | required | required |
| Ground Logistics / Resupply | required | required | payload | supporting | required |
| OP/Child Support | required | supporting | payload/sustainment | payload | supporting |

A fire-support capability is only active where separately supported by current evidence and a current technical contract. No fixed Honaker M777/L118 capability is active in this Foundation baseline.

## 6. Readiness states

```text
AVAILABLE
CONSTRAINED
CRITICAL
UNAVAILABLE
```

Working numeric baseline:

```text
AVAILABLE     >= 60%
CONSTRAINED   >= 35% and < 60%
CRITICAL      > 0% and < 35%
UNAVAILABLE   = 0% or required minimum cannot be met
```

A capability inherits the worst state of its required resources. Supporting/sustainment resources may degrade eligibility according to the current mission contract.

## 7. Mission eligibility boundary

Readiness never overrides hard resource availability or protected reserve rules.

```text
percentage state appears sufficient
but mission reservation would violate applicable defense reserve
-> mission is not eligible
```

Existing working protected reserves remain defined for Jalalabad, Joyce, Wright and Bostick in `OMW-ARMY-GROUND-RESOURCE-QUANTITY-SETTLEMENT`.

Exact Fortress/Honaker protected reserve thresholds are intentionally not invented by Acceptance 9. They belong to later Ground-order/readiness calibration.

## 8. Motorized patrol correlation

Validated correlation:

```text
1 M-ATV = 1 VEHICLE + 3 PERSONNEL
4 M-ATV patrol = 4 VEHICLE + 12 PERSONNEL
```

This is the accepted resource correlation for the validated patrol path, not a universal family composition rule for every Ground vehicle.

## 9. Resource-loss effects

A strategic loss occurs only when correlated to an authoritative commitment or transfer.

```text
physical event
-> correlate to stable mission/resource identity
-> classify terminal outcome
-> idempotent settlement
-> update CampaignState once
-> recalculate readiness
```

Examples:

```text
confirmed correlated VEHICLE loss
-> VEHICLE decreases exactly once
-> VEHICLE_LOST audit increases exactly once

uncorrelated decorative DCS destruction
-> no arbitrary strategic debit

failed/lost resupply transfer
-> only committed manifest resources are lost
```

## 10. Return and restart effects

Binding Ground settlement rules:

```text
confirmed return, including damaged survivor
-> immediate one-time availability credit

confirmed loss
-> permanent loss

open nonterminal commitment at server stop/crash
-> one-time strategic recredit at next startup
-> no physical continuation or respawn of the old DCS/MOOSE group
```

Readiness is recalculated from the resulting CampaignState state.

## 11. OP support

Dependent OPs may reserve resources from their parent/supporting domain, but the OP does not automatically become a new root-stock authority.

Current dependent identities:

```text
Honaker -> OP JoJo
Bostick -> OP Mustang / OP Clydesdale / OP Stallion
```

COP Honaker-Miracle itself is a full strategic stock node and is not treated as a child-only resource record.

## 12. Honaker artillery correction

Superseded:

```text
2 x M777A2 at Honaker on 30.07.2011 as current hard fact
L118 fixed technical proxy as Foundation requirement
Joyce AMMO reservation solely for that fixed pair
```

Current evidence contract:

```text
2011 local mortar capability = confirmed
Jan-2010 possible two-gun position = observed; type/continuity unresolved
2012 M777 evidence = outside scenario period
```

## 13. Accepted technical evidence

Acceptance 7 validates the physical Ground lifecycle and settlement rules. Acceptance 8 validates production-shaped single-CampaignState composition. Acceptance 9-2 validates all six stock nodes and the Fortress/Honaker settlement path.

```text
Acceptance 9 commit: 45d916217c0085728082c3ef2efcd582d736caae
Bundle SHA-256: 35cc922581da980f558733433e487b025e083859b943641276672b6c168b4d6a
MIZ SHA-256: 29587060d630d53303d4e858c1fd5a898ea3e09d51dec36ff130d3d0ac6e3ef3
DCS: 2.9.28.26385 MT
Result: PASS
```

## 14. Later scope

```text
Fortress/Honaker exact protected defense reserves
Ground-order generation
exact remaining ORBAT allocations
OPSTRANSPORT
cross-domain persistence architecture
```
