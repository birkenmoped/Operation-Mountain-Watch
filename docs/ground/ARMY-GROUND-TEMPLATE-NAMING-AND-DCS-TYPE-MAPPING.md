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

Site-bound fire-support templates are Mission Editor representations of local capability. They do not become independent strategic resource authorities.

## 7. Observed/approved DCS type names

Relevant type strings observed in the current mission or pinned source include:

```text
CHAP_MATV
MaxxPro_MRAP
CHAP_M1083
Hummer
L118_Unit
2B11 mortar
Soldier M4
Soldier M249
M 818
MLRS FDDM
M978 HEMTT Tanker
```

`CHAP_*` remains a mod/content dependency. `M978 HEMTT Tanker` is present as an exact type string in the pinned MOOSE source and remains subject to actual mission availability/behavior checks where used.

`MLRS FDDM` is not part of the current owner-created Fortress/Bostick fire-support templates. It is therefore not required by the current Ground Foundation template contract.

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
| Fortress 105-mm fire-support representation | `L118_Unit` | `PLANNED_PROXY` | one local 105-mm capability is source-supported; exact historical gun model is not asserted |
| Bostick artillery representation | `L118_Unit` | `PLANNED_PROXY` | historical M777 capability is documented; L118 is a DCS proxy and not an identity claim |
| Honaker local mortar representation | `2B11 mortar` | `PLANNED_PROXY` | 2011 local mortar capability is confirmed; exact historical mortar model/caliber is not asserted |

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

The current owner-created Ground test MIZ additionally contains:

```text
TPL_BLUE_GND_PATROL_MIXED_4
  3 x CHAP_MATV
  1 x MaxxPro_MRAP

TPL_BLUE_GND_PATROL_MIXED_3
  2 x CHAP_MATV
  1 x MaxxPro_MRAP

TPL_BLUE_GND_INF_RIFLE_SQUAD_9
  7 x Soldier M4
  2 x Soldier M249
```

`TPL_BLUE_GND_INF_RIFLE_SQUAD_9` is a nine-person DCS abstraction of a U.S. Army rifle squad. It is suitable as a reusable physical representation for foot patrol, local security, OP relief/return and later dismount tasks. It does not claim one-to-one DCS representation of every historical weapon role.

The mixed patrol templates are additional representations only. They do not invalidate the Acceptance-7 correlation for the specific four-M-ATV test package and do not by themselves define a universal personnel-per-vehicle rule.

## 10. Site-bound fire-support templates

Current owner-created Mission Editor templates:

```text
TPL_BLUE_GND_FORTRESS_FS_ARTY_L118_1
  1 x L118_Unit

TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2
  2 x L118_Unit

TPL_BLUE_GND_HONAKER_FS_MORTAR_2B11_2
  2 x 2B11 mortar
```

Naming rule:

```text
reusable/mobile:
TPL_BLUE_GND_<ROLE>_<VARIANT>

site-bound fire support:
TPL_BLUE_GND_<SITE>_FS_<CATEGORY>_<TYPE>_<WEAPON_COUNT>
```

The trailing count is the number of named weapon systems, not the total number of support vehicles in a battery/platoon representation.

Evidence boundaries:

```text
FORTRESS
  local 105-mm capability = supported
  current OMW representation = 1 x L118_Unit proxy
  exact historical gun model = not asserted

BOSTICK
  historical M777 capability = documented
  current OMW representation = 2 x L118_Unit proxy
  L118 identity = not asserted historically

HONAKER
  2011 local mortar capability = confirmed
  current OMW representation = 2 x 2B11 mortar proxy
  exact historical mortar model/caliber = not asserted
  Jan-2010 possible two-gun artillery position is not carried forward as a 2011 artillery hard fact
```

The superseded Honaker mapping `TPL_BLUE_GND_FIRE_SUPPORT_L118_PROXY_2 -> 2 x L118_Unit representing 2 x M777A2` remains rejected.

## 11. Current owner MIZ inspection

Read-only inspection of the owner-provided current test mission:

```text
file: OMW_Template_v14_ground_test(5).miz
SHA-256: 675b98648b6a2f4aa7d03c3bf7c08efab30e36777991ee5cecb1f7433372852a
```

Confirmed Mission Editor group contents:

```text
TPL_BLUE_GND_FORTRESS_FS_ARTY_L118_1
  1 x L118_Unit

TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2
  2 x L118_Unit

TPL_BLUE_GND_HONAKER_FS_MORTAR_2B11_2
  2 x 2B11 mortar

TPL_BLUE_GND_PATROL_MIXED_4
  3 x CHAP_MATV + 1 x MaxxPro_MRAP

TPL_BLUE_GND_PATROL_MIXED_3
  2 x CHAP_MATV + 1 x MaxxPro_MRAP

TPL_BLUE_GND_INF_RIFLE_SQUAD_9
  7 x Soldier M4 + 2 x Soldier M249
```

One Mission Editor naming defect remains in this exact MIZ and must be corrected by the project owner before the template set is considered clean:

```text
group: TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2
unit 1: TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2_01
unit 2: TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_3_02   <- stale suffix
required unit 2 name:
TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2_02
```

This is a naming defect only; no runtime behavior is inferred from the read-only inspection.

## 12. MOOSE source basis

Pinned MOOSE provenance used by the Ground Foundation:

```text
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Ground lifecycle behavior is validated separately by Acceptance 7. Acceptance 9 introduces no new MOOSE lifecycle behavior.

## 13. Runtime-test boundary

Creating or renaming Mission Editor templates does not by itself require a dedicated DCS acceptance when no new runtime mechanism is introduced.

If later Ground work introduces new runtime behavior such as:

```text
infantry embark/disembark from convoy carriers
OPSTRANSPORT-based relief or reinforcement
new fire-support tasking/control behavior
new mixed-template lifecycle behavior that differs from the validated Ground lifecycle
```

it must be tested only as part of a bundled Ground integration/collection mission. No new single-feature DCS acceptance is planned for these Foundation additions.

## 14. Later scope

Still separate from this naming/type baseline:

```text
exact Fortress/Honaker vehicle-family split
specialized recovery vehicle decision
Ground-order generation
OPSTRANSPORT-based infantry transport/dismount behavior
final production patrol/observation geometry
```
