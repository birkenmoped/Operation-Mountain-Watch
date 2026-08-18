---
document_id: OMW-ARMY-GROUND-TEMPLATE-NAMING-TYPE-MAPPING
status: PLANNED
document_class: DOMAIN_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - working naming scheme for reusable BLUE ground templates, MOOSE ground pools, warehouse mirrors and access zones
  - source-qualified candidate mapping from approved OMW vehicle families to DCS type names already observed in the current mission artifact
  - separation between strategic installation IDs, operational nodes, reusable templates and runtime groups
not_authoritative_for:
  - final Mission Editor object placement
  - final DCS proxy approval for historically unavailable systems
  - final MOOSE BRIGADE or PLATOON topology
  - final physical group sizes
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# ARMY Ground Foundation – Template Naming and DCS Type Mapping

## 1. Purpose

This document fixes the working naming boundary for Ground Foundation assets before Mission Editor templates and MOOSE ground pools are multiplied across the Jalalabad/Kunar network.

The identity layers remain separate:

```text
CampaignState installation
!= Ground Node
!= MOOSE warehouse / brigade / platoon
!= reusable DCS template
!= runtime DCS group / ARMYGROUP
```

A vehicle family can therefore be reused at several installations without encoding the site name into the generic template.

## 2. Stable naming scheme

### 2.1 Strategic installation IDs

Existing schema:

```text
BLUE_GROUND_<CLASS>_<NAME>
```

Examples:

```text
BLUE_GROUND_HUB_JALALABAD_FENTY
BLUE_GROUND_FOB_JOYCE
BLUE_GROUND_COP_HONAKER_MIRACLE
BLUE_GROUND_FOB_WRIGHT
BLUE_GROUND_FOB_BOSTICK
BLUE_GROUND_OP_MUSTANG
```

These are CampaignState identities and must never be derived from DCS group names.

### 2.2 Ground Node IDs

```text
GROUND_NODE_<NAME>
```

Current scope:

```text
GROUND_NODE_JALALABAD
GROUND_NODE_JOYCE
GROUND_NODE_WRIGHT
GROUND_NODE_BOSTICK
```

### 2.3 MOOSE operational objects

Working naming pattern:

```text
WH_BLUE_GND_<NODE>
BDE_BLUE_GND_<NODE>
PLT_BLUE_GND_<NODE>_<ROLE>
```

Examples:

```text
WH_BLUE_GND_BOSTICK
BDE_BLUE_GND_BOSTICK
PLT_BLUE_GND_BOSTICK_PATROL
PLT_BLUE_GND_BOSTICK_QRF
PLT_BLUE_GND_BOSTICK_LOGISTICS
PLT_BLUE_GND_BOSTICK_FIRE_SUPPORT
```

`BDE_` remains an operational MOOSE-node name and does not assert a historical brigade formation.

### 2.4 Reusable Mission Editor templates

The existing project template rule remains:

```text
TPL_<COALITION>_<ROLE>_<VARIANT>
```

For Ground Foundation templates the working specialization is:

```text
TPL_BLUE_GND_<ROLE>_<VARIANT>
```

Site names are not encoded into generic reusable templates unless site geometry itself makes the template non-reusable.

Examples:

```text
TPL_BLUE_GND_PATROL_MATV_4
TPL_BLUE_GND_PATROL_MRAP_4
TPL_BLUE_GND_QRF_MIXED_4
TPL_BLUE_GND_LOG_M1083_2
TPL_BLUE_GND_SECURITY_INF_LIGHT
TPL_BLUE_GND_REINFORCEMENT_INF_LIGHT
```

The character `#` is not used in project-owned template or alias names because MOOSE uses suffixing conventions of its own.

### 2.5 Runtime names

Runtime DCS group names and MOOSE aliases are transient implementation identifiers. They must correlate to stable CampaignState IDs and reservation/mission IDs but never replace them as persistent keys.

## 3. Ground access-zone naming

The previous multi-zone concept (`SPAWN`, `ASSEMBLY`, `RETURN`) is intentionally collapsed.

Per root Ground Node, the normal working model uses one operational handoff/access zone:

```text
ZON_BLUE_GND_<NODE>_ACCESS
```

Current expected set:

```text
ZON_BLUE_GND_JALALABAD_ACCESS
ZON_BLUE_GND_JOYCE_ACCESS
ZON_BLUE_GND_WRIGHT_ACCESS
ZON_BLUE_GND_BOSTICK_ACCESS
```

The same access zone may serve as:

```text
mobile ground asset materialization point
return / handoff boundary
convoy departure point
convoy arrival point
reinforcement departure/arrival point
supply transfer handoff
```

The zone is to be positioned outside the active installation, preferably immediately on or beside a verified usable road so DCS ground AI is not required to navigate through FOB internal geometry.

A separate assembly zone is not required by default.

## 4. Dependent OP boundary

Dependent OPs do not receive normal independent ground access zones, warehouses or materialization points.

```text
OP
-> no independent warehouse
-> no independent strategic stock
-> no standard spawn zone
-> no AIR sustainment
-> ROAD / FOOT / ROAD_FOOT only
```

Routine rotation, food, water and ammunition are abstracted with the OP personnel occupancy. Explicit replenishment is limited to personnel losses/understrength state and always originates from the direct parent.

The parent chain may not be skipped.

Example:

```text
JALALABAD
-> BOSTICK
-> MUSTANG
```

not:

```text
JALALABAD -> MUSTANG
```

## 5. Materialization classes

Ground assets are separated into four planned materialization classes.

### 5.1 Fixed installation defense

Examples:

```text
gate/security positions
selected perimeter infantry
selected tower/bunker positions
```

Rules:

```text
physical at mission start
no demand-time spawn into an occupied FOB/COP/OP
no same-session magic replacement into exact fixed positions
losses settle to CampaignState
reconstitution is a separate campaign/restart process
```

### 5.2 Fixed fire support

Confirmed example:

```text
COP Honaker-Miracle
2 x M777A2 on 2011-07-30
```

Rules:

```text
physical at mission start where the artillery presence is approved
fire mission generated dynamically
weapon itself does not spawn merely because a fire mission exists
destroyed weapon is not automatically regenerated in place
```

### 5.3 Mobile operational assets

Examples:

```text
patrol
QRF
mobile security
local logistics
```

Rules:

```text
CampaignState reservation first
operational/MOOSE materialization second
materialize at root-node ACCESS zone outside installation
route from a verified road anchor / validated route
no arbitrary spawn inside active FOB/COP geometry
```

### 5.4 Reinforcement and logistics transport

Examples:

```text
personnel replacement
vehicle transfer
supply convoy
recovery/support mission
```

These use the same root-node access/handoff concept. Arrival at an installation does not by itself transfer strategic vehicle ownership; CampaignState settlement remains explicit.

## 6. DCS type names already observed in the current mission artifact

Read-only inspection of the current mission artifact established the following relevant DCS unit type names as actually present in that mission environment:

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
```

This list proves only that these type names occur in the current mission. It is not a complete catalog of the user's installed DCS/mod environment.

`CHAP_*` entries imply a mod/content dependency and must retain that dependency in later template metadata.

## 7. Working vehicle-family to DCS-type candidate mapping

The following mapping is approved only as a working candidate because each DCS type name is already observed in the current mission artifact.

| OMW vehicle family | Candidate DCS type | Mapping status | Boundary |
|---|---|---|---|
| protected light mobility / M-ATV class | `CHAP_MATV` | `SOURCE_CONFIRMED_TYPE / CANDIDATE_MAPPING` | mod dependency; DCS runtime/template acceptance still required |
| protected MRAP / MaxxPro class | `MaxxPro_MRAP` | `SOURCE_CONFIRMED_TYPE / CANDIDATE_MAPPING` | exact variant/configuration still template-specific |
| medium logistics / FMTV-M1083 class | `CHAP_M1083` | `SOURCE_CONFIRMED_TYPE / CANDIDATE_MAPPING` | mod dependency; cargo/transport semantics still separate |
| utility / HMMWV class | `Hummer` | `SOURCE_CONFIRMED_TYPE / CANDIDATE_MAPPING` | exact HMMWV variant and armament must be selected per role |

No other DCS vehicle type is inferred from these mappings.

## 8. Artillery/proxy boundary

The current mission contains `L118_Unit`, but this does **not** make it a historically equivalent M777A2.

```text
historical system: M777A2
observed DCS type: L118_Unit
```

Therefore:

```text
L118_Unit != automatically approved M777 proxy
```

A proxy decision requires explicit owner approval after comparison of role, range, ammunition behavior, visual impact and DCS/MOOSE fire-mission behavior.

The same rule applies to any later mortar, recovery, engineer or route-clearance proxy.

## 9. Current vehicle-baseline application

The working quantities from `OMW-ARMY-GROUND-VEHICLE-BASELINE` can now be expressed as template-family demand without pretending that every vehicle must be visible or active simultaneously.

```text
JOYCE 20
  8  -> M-ATV family -> CHAP_MATV candidate
  6  -> MaxxPro family -> MaxxPro_MRAP candidate
  4  -> M1083/FMTV family -> CHAP_M1083 candidate
  2  -> HMMWV/utility family -> Hummer candidate

WRIGHT 22
  8  -> M-ATV family -> CHAP_MATV candidate
  6  -> MaxxPro family -> MaxxPro_MRAP candidate
  4  -> M1083/FMTV family -> CHAP_M1083 candidate
  2  -> HMMWV/utility family -> Hummer candidate
  2  -> engineer/route-support -> TYPE OPEN

BOSTICK 26
  10 -> M-ATV family -> CHAP_MATV candidate
  8  -> MaxxPro family -> MaxxPro_MRAP candidate
  5  -> M1083/FMTV family -> CHAP_M1083 candidate
  2  -> HMMWV/utility family -> Hummer candidate
  1  -> recovery/support -> TYPE OPEN

FENTY 48
  16 -> M-ATV family -> CHAP_MATV candidate
  14 -> MaxxPro family -> MaxxPro_MRAP candidate
  10 -> M1083/FMTV family -> CHAP_M1083 candidate
  4  -> HMMWV/utility family -> Hummer candidate
  4  -> heavy logistics/fuel-support -> TYPE OPEN
```

The open allocations remain deliberately open instead of being silently mapped to an available but historically/functionally inappropriate DCS type.

## 10. Immediate next verification gates

Before Mission Editor build instructions are issued:

```text
1. decide/verify Wright engineer and route-support vehicle families
2. decide/verify Bostick recovery/support vehicle family
3. decide/verify Fenty heavy logistics/fuel-support vehicle families
4. decide the M777A2 DCS proxy or approved abstraction
5. define reusable group compositions and roles from the approved family pool
6. verify road-side ACCESS-zone positions in the Mission Editor
7. DCS-test spawn, pathfinding, tasking, return and visibility behavior
```

No item above is `VALIDATED` by this design document.
