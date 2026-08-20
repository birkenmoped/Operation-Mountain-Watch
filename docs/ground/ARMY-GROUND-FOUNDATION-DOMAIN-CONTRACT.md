---
document_id: OMW-ARMY-GROUND-DOMAIN-CONTRACT
status: PLANNED
document_class: DOMAIN_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - stable CampaignState identities for the current ARMY Ground Foundation installation scope
  - current parent/support relationships between Ground installations
  - separation of installation identity from historical formation, MOOSE domain and physical DCS group identity
not_authoritative_for:
  - exact historical daily garrison strengths
  - exact vehicle-family property books
  - final Ground-order generation
  - final Mission Editor object state
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - four-root-only Ground domain model
  - dependent-only Honaker strategic-resource model
  - FOB-class Fortress identity for new work
superseded_by:
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: true
---

# ARMY Ground Foundation – CampaignState-Domainvertrag

## 1. Identity boundary

```text
CampaignState strategic installation identity
!= historical formation identity
!= MOOSE BRIGADE / PLATOON identity
!= physical DCS GROUP / UNIT identity
```

Stable installation IDs are persistent campaign-domain keys. Runtime group names, MOOSE aliases and Mission Editor names may reference them but do not replace them.

## 2. Canonical Ground installation IDs

```text
BLUE_GROUND_HUB_JALALABAD_FENTY
BLUE_GROUND_COP_FORTRESS
BLUE_GROUND_FOB_JOYCE
BLUE_GROUND_FOB_WRIGHT
BLUE_GROUND_COP_HONAKER_MIRACLE
BLUE_GROUND_FOB_BOSTICK

BLUE_GROUND_OP_JOJO
BLUE_GROUND_OP_MUSTANG
BLUE_GROUND_OP_CLYDESDALE
BLUE_GROUND_OP_STALLION
```

Canonical classes:

```text
Jalalabad / FOB Fenty = HUB
Fortress               = COP
Joyce                  = FOB
Wright                 = FOB
Honaker-Miracle        = COP
Bostick / Naray        = FOB
```

Historical naming variants do not create additional CampaignState installations.

## 3. Six strategic Ground stock nodes

```text
GROUND_NODE_JALALABAD
GROUND_NODE_FORTRESS
GROUND_NODE_JOYCE
GROUND_NODE_WRIGHT
GROUND_NODE_HONAKER
GROUND_NODE_BOSTICK
```

Each node owns its local Ground strategic resources in the single authoritative CampaignState.

```text
CampaignState node stock
!= MOOSE Warehouse inventory authority
!= visible DCS object count
```

## 4. Support-parent contract

```text
GROUND_NODE_JALALABAD
  supplyParent = OFF_MAP

GROUND_NODE_FORTRESS
  supplyParent = GROUND_NODE_JALALABAD

GROUND_NODE_JOYCE
  supplyParent = GROUND_NODE_JALALABAD

GROUND_NODE_WRIGHT
  supplyParent = GROUND_NODE_JALALABAD

GROUND_NODE_HONAKER
  supplyParent = GROUND_NODE_JOYCE

GROUND_NODE_BOSTICK
  supplyParent = GROUND_NODE_JALALABAD
```

A `supplyParent` is a strategic sustainment relationship, not a requirement that every physical mission depart from that parent.

```text
strategic resource owner != physical dispatch origin
```

## 5. Dependent OPs

```text
BLUE_GROUND_COP_HONAKER_MIRACLE
`-- BLUE_GROUND_OP_JOJO

BLUE_GROUND_FOB_BOSTICK
+-- BLUE_GROUND_OP_MUSTANG
+-- BLUE_GROUND_OP_CLYDESDALE
`-- BLUE_GROUND_OP_STALLION
```

These OPs do not automatically receive independent root-stock nodes.

Current personnel planning:

```text
Mustang     nominal 12 PERSONNEL
Clydesdale  nominal 12 PERSONNEL
Stallion    nominal 12 PERSONNEL
JoJo        candidate 12 PERSONNEL; activation remains provisional
```

## 6. Resource ownership rules

The strategic authority invariant is:

```text
CampaignState = sole strategic authority
```

Operational systems may mirror or materialize approved resources, but they do not create independent strategic stock.

```text
CampaignState reservation
-> operational MOOSE selection/materialization
-> DCS physical execution
-> observed result
-> idempotent CampaignState settlement
```

Forbidden examples:

```text
MOOSE Warehouse count -> automatic CampaignState stock
DCS Warehouse count -> automatic CampaignState stock
physical despawn -> automatic return
uncorrelated destruction -> automatic strategic loss
```

## 7. Six-node stock snapshot

Order: `PERSONNEL / VEHICLE / SUPPLY / AMMO / FUEL`.

```text
GROUND_NODE_JALALABAD 480 / 48 / 120 / 100 / 120
GROUND_NODE_FORTRESS  160 / 18 / 44  / 48  / 40
GROUND_NODE_JOYCE     180 / 20 / 48  / 44  / 40
GROUND_NODE_WRIGHT    120 / 22 / 36  / 30  / 36
GROUND_NODE_HONAKER   120 / 18 / 40  / 40  / 36
GROUND_NODE_BOSTICK   220 / 26 / 56  / 52  / 48
```

The Fortress/Honaker design values are governed by `OMW-ARMY-GROUND-FORTRESS-HONAKER-2011-RESOURCE-DECISION`.

## 8. MOOSE operational-domain mapping

```text
BLUE_GROUND_HUB_JALALABAD_FENTY
-> BDE_BLUE_GND_JALALABAD / WH_BLUE_GND_FENTY

BLUE_GROUND_COP_FORTRESS
-> BDE_BLUE_GND_FORTRESS / WH_BLUE_GND_FORTRESS

BLUE_GROUND_FOB_JOYCE
-> BDE_BLUE_GND_JOYCE / WH_BLUE_GND_JOYCE

BLUE_GROUND_FOB_WRIGHT
-> BDE_BLUE_GND_WRIGHT / WH_BLUE_GND_WRIGHT

BLUE_GROUND_COP_HONAKER_MIRACLE
-> BDE_BLUE_GND_HONAKER / WH_BLUE_GND_HONAKER

BLUE_GROUND_FOB_BOSTICK
-> BDE_BLUE_GND_BOSTICK / WH_BLUE_GND_BOSTICK
```

`BDE_` is an operational MOOSE domain label, not a claim of historical formation size.

## 9. Settlement and restart boundary

Validated Ground contract:

```text
confirmed return, including damaged survivor -> one-time availability credit
confirmed loss -> permanent loss
open nonterminal commitment at server stop/crash -> one-time strategic recredit at next startup
no physical DCS/MOOSE continuation or respawn across sessions
```

The test correlation used by the accepted motorized patrol path is:

```text
1 M-ATV = 1 VEHICLE + 3 PERSONNEL
```

## 10. Honaker artillery correction

No fixed M777/L118 resource identity belongs to the current domain contract.

```text
2011 local mortar capability = confirmed
Jan-2010 possible two-gun position = observed; type/continuity unresolved
2012 M777 evidence = outside scenario period
```

## 11. Accepted technical evidence

Acceptance 7 validates the physical MOOSE Ground lifecycle and settlement behavior. Acceptance 8 validates single-CampaignState production-shaped integration. Acceptance 9-2 validates the six-node Ground stock including Fortress and Honaker.

```text
Acceptance 9 commit: 45d916217c0085728082c3ef2efcd582d736caae
Bundle SHA-256: 35cc922581da980f558733433e487b025e083859b943641276672b6c168b4d6a
MIZ SHA-256: 29587060d630d53303d4e858c1fd5a898ea3e09d51dec36ff130d3d0ac6e3ef3
DCS: 2.9.28.26385 MT
Result: PASS
```

## 12. Later scope

```text
exact Fortress/Honaker vehicle-family split
Ground-order generation
OPSTRANSPORT
cross-domain persistence architecture
exact remaining formation/ORBAT allocations
```
