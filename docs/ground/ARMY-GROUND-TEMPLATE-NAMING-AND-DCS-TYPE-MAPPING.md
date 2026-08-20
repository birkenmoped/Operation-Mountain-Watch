---
document_id: OMW-ARMY-GROUND-TEMPLATE-NAMING-TYPE-MAPPING
status: PLANNED
document_class: DOMAIN_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - working naming scheme for BLUE Ground templates, MOOSE operational domains, warehouse mirrors and access zones
  - source-qualified mapping from approved OMW vehicle families to DCS type names
  - separation between strategic installation IDs, Ground nodes, reusable templates and runtime groups
not_authoritative_for:
  - final Mission Editor object placement
  - exact Fortress/Honaker vehicle-family split
  - fixed Honaker artillery proxy
  - accepted DCS behavior beyond cited acceptance results
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - Honaker M777A2-to-L118 fixed proxy decision
  - four-node-only Ground naming examples
superseded_by:
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: true
---

# ARMY Ground Foundation – Template Naming and DCS Type Mapping

## 1. Identity layers

The identity layers remain separate:

```text
CampaignState installation
!= Ground Node
!= MOOSE warehouse / brigade / platoon
!= reusable DCS template
!= runtime DCS group / ARMYGROUP
```

## 2. Strategic installation IDs

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

`BLUE_GROUND_FOB_FORTRESS` is not used for new work; the canonical OMW class is COP.

## 3. Ground nodes

```text
GROUND_NODE_JALALABAD
GROUND_NODE_FORTRESS
GROUND_NODE_JOYCE
GROUND_NODE_WRIGHT
GROUND_NODE_HONAKER
GROUND_NODE_BOSTICK
```

## 4. MOOSE operational names

```text
WH_BLUE_GND_<NODE>
BDE_BLUE_GND_<NODE>
PLT_BLUE_GND_<NODE>_<ROLE>[_<VARIANT>]
```

Current six operational domains:

```text
BDE_BLUE_GND_JALALABAD
BDE_BLUE_GND_FORTRESS
BDE_BLUE_GND_JOYCE
BDE_BLUE_GND_WRIGHT
BDE_BLUE_GND_HONAKER
BDE_BLUE_GND_BOSTICK
```

`BDE_` denotes a MOOSE operational domain and does not assert a historical brigade formation.

## 5. ACCESS zones

```text
ZON_BLUE_GND_FENTY_ACCESS
ZON_BLUE_GND_FORTRESS_ACCESS
ZON_BLUE_GND_JOYCE_ACCESS
ZON_BLUE_GND_WRIGHT_ACCESS
ZON_BLUE_GND_HONAKER_ACCESS
ZON_BLUE_GND_BOSTICK_ACCESS
```

Rules:

```text
outside active FOB/COP geometry
preferably on or directly beside a validated usable road
shared materialization / departure / return / handoff boundary
no observable spawn/despawn transition
```

Dependent OPs do not automatically receive their own warehouse or strategic stock.

## 6. Materialization classes

```text
FIXED INSTALLATION DEFENSE
-> physical at mission start where required
-> not demand-time spawned into exact defensive positions

MOBILE OPERATIONAL ASSETS
-> CampaignState reservation first
-> materialize at validated ACCESS boundary
-> MOOSE operational lifecycle

REINFORCEMENT / LOGISTICS TRANSPORT
-> same ACCESS/handoff model
-> strategic ownership changes only by explicit CampaignState settlement
```

There is no current Foundation requirement for a fixed Honaker artillery proxy.

## 7. Observed/approved DCS type names

Relevant type strings observed in the current mission or pinned source include:

```text
CHAP_MATV
MaxxPro_MRAP
CHAP_M1083
Hummer
2B11 mortar
Soldier M4
Soldier M249
M 818
MLRS FDDM
M978 HEMTT Tanker
```

`CHAP_*` remains a mod/content dependency. `M978 HEMTT Tanker` is present as an exact type string in the pinned MOOSE source and remains subject to actual mission availability/behavior checks where used.

## 8. Current family mappings

| OMW family / role | DCS type | Foundation status | Boundary |
|---|---|---|---|
| M-ATV class | `CHAP_MATV` | `PLANNED_MAPPING` | observed in current mission; mod dependency |
| MaxxPro/MRAP class | `MaxxPro_MRAP` | `PLANNED_MAPPING` | observed in current mission |
| FMTV/M1083 class | `CHAP_M1083` | `PLANNED_MAPPING` | observed in current mission; mod dependency |
| utility/HMMWV class | `Hummer` | `PLANNED_MAPPING` | observed in current mission |
| Fenty fuel support | `M978 HEMTT Tanker` | `PLANNED_MAPPING` | exact type string source-verified; mission behavior still separate |
| Wright engineer/route-support security | `MaxxPro_MRAP` | `PLANNED_ABSTRACTION` | protected escort role; no mine-clearing capability asserted |
| Bostick recovery/support | `CHAP_M1083` | `PLANNED_ABSTRACTION` | support/recovery representation; no towing asserted |

No M777/L118 mapping is part of the current Honaker Foundation contract.

## 9. Reusable mobile template baseline

```text
TPL_BLUE_GND_PATROL_MATV_4
  4 x CHAP_MATV

TPL_BLUE_GND_PATROL_MRAP_4
  4 x MaxxPro_MRAP

TPL_BLUE_GND_QRF_MIXED_4
  2 x CHAP_MATV
  2 x MaxxPro_MRAP

TPL_BLUE_GND_SECURITY_MRAP_2
  2 x MaxxPro_MRAP

TPL_BLUE_GND_ENGINEER_SUPPORT_MRAP_2
  2 x MaxxPro_MRAP

TPL_BLUE_GND_LOG_M1083_2
  2 x CHAP_M1083

TPL_BLUE_GND_FUEL_M978_2
  2 x M978 HEMTT Tanker

TPL_BLUE_GND_UTILITY_HMMWV_2
  2 x Hummer

TPL_BLUE_GND_OP_REINFORCEMENT_MRAP_3
  3 x MaxxPro_MRAP
```

`TPL_BLUE_GND_PATROL_MATV_4` is the template used by the validated Ground lifecycle acceptance and by the documented CampaignState correlation:

```text
4 M-ATV = 4 VEHICLE + 12 PERSONNEL
```

## 10. Honaker artillery correction

The previous Foundation mapping:

```text
TPL_BLUE_GND_FIRE_SUPPORT_L118_PROXY_2
2 x L118_Unit
representing 2 x M777A2
```

is superseded and must not be treated as a production requirement.

Current evidence contract:

```text
2011 local mortar capability = confirmed
Jan-2010 possible two-gun position = observed; type/continuity unresolved
2012 M777 evidence = outside scenario period
```

A later artillery decision may introduce a source-verified system, but it is not part of the current GROUNDBASE closure.

## 11. MOOSE source basis

Pinned MOOSE provenance used by the Ground Foundation:

```text
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Ground lifecycle behavior is validated separately by Acceptance 7. Acceptance 9 introduces no new MOOSE lifecycle behavior.

## 12. Later scope

Still separate from this naming/type baseline:

```text
exact Fortress/Honaker vehicle-family split
specialized recovery vehicle decision
any future artillery mapping
Ground-order generation
final production patrol/observation geometry
```
