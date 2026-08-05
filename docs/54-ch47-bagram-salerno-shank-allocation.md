---
document_id: OMW-AIR-CH47-BAGRAM-SALERNO-SHANK-ALLOCATION
status: BINDING_PROJECT_DECISION
document_class: CROSS_BASE_AIR_ORBAT_DECISION
owning_policy: OMW-GOV-001
authoritative_for:
  - active OMW allocation of the documented 25-aircraft CH-47 pool of B Company, 7th Battalion, 158th Aviation Regiment across Bagram, FOB Salerno and FOB Shank
  - distinction between assigned inventory and aircraft visible on a single satellite image
  - inheritance of the allocation by base-specific air-operations manifests
not_authoritative_for:
  - total CH-47 strength of the United States armed forces
  - total CH-47 strength in Afghanistan
  - CH-47 aircraft assigned to other units, task forces, bases or commands
  - exact day-by-day historical aircraft location
  - maintenance status or mission-ready rates on a specific date
  - DCS or MOOSE runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - equal eight-aircraft working allocation across Bagram Salerno and Shank
  - FOB Salerno CH-47 estimates of zero to two aircraft
  - FOB Salerno active CH-47 inventory of eight aircraft
superseded_by:
source_branch: agent/document-ch47-pool-allocation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# 54 – CH-47 allocation: Bagram, FOB Salerno and FOB Shank

## 1. Scope of the 25-aircraft figure

The figure of **25 CH-47 aircraft does not describe the global CH-47 fleet, the total U.S. CH-47 inventory, or the total number of CH-47 aircraft in Afghanistan**.

It refers exclusively to the specific deployment pool documented for:

```text
B Company
7th Battalion, 158th Aviation Regiment
19 organic CH-47
+ 6 additional CH-47 assigned for the deployment
= 25 CH-47 in this specific unit/deployment pool
```

Only this unit-specific pool is distributed in this document across:

```text
Bagram Airfield
FOB Salerno
FOB Shank
```

Other CH-47 aircraft operated by different U.S. Army units, task forces, commands or coalition partners are outside this allocation and must not be counted into or inferred from the 25-aircraft figure.

Binding interpretation:

```text
25 CH-47 = B/7-158 AVN DEPLOYMENT POOL
25 CH-47 != ALL CH-47 IN AFGHANISTAN
25 CH-47 != TOTAL U.S. CH-47 INVENTORY
25 CH-47 != GLOBAL CH-47 INVENTORY
```

## 2. Binding OMW decision

Operation Mountain Watch adopts the following active allocation for this specific documented 25-aircraft deployment pool of B Company, 7-158 Aviation:

| Location | Assigned CH-47 inventory from this unit pool | Share of this unit pool |
|---|---:|---:|
| Bagram Airfield | 13 | 52 percent |
| FOB Salerno | 6 | 24 percent |
| FOB Shank | 6 | 24 percent |
| **Total B/7-158 pool** | **25** | **100 percent** |

```yaml
CH47_B_7_158_DEPLOYMENT_POOL_2011:
  unit: B Company, 7th Battalion, 158th Aviation Regiment
  organic_aircraft: 19
  additional_assigned_aircraft: 6
  total_unit_deployment_pool: 25
  allocation:
    Bagram: 13
    Salerno: 6
    Shank: 6
  classification: OMW_ACTIVE_RECONSTRUCTION
  exact_historical_distribution_explicitly_published: false
  excludes:
    - all other CH-47 units in Afghanistan
    - total U.S. Army CH-47 strength
    - coalition CH-47 and Chinook units
    - global CH-47 inventory
```

The `13/6/6` distribution is the binding campaign baseline for this specific unit pool. It is an evidence-based OMW reconstruction and must not be described as an explicitly published historical allocation table or as Afghanistan-wide CH-47 strength.

## 3. Source and reconstruction basis

The historical source documents for B Company, 7-158 Aviation:

- 19 organic CH-47 plus 6 additional aircraft assigned to the deployment, for a unit-specific pool of 25;
- distribution of this unit's aircraft and crews between Bagram, FOB Salerno and FOB Shank;
- Bagram as the ISAF-wide general-support node for this formation;
- Salerno as the headquarters detachment with brigade general-support and air-assault responsibilities;
- Shank as the forward detachment supporting Logar, Wardak and Village Stability Operations.

The available source does not state the exact integer split. The project therefore combines organizational role, operational tasking and satellite evidence. This reconstruction applies only to the described B/7-158 pool.

## 4. Satellite and tasking evidence

### 4.1 FOB Salerno

The project-evaluated satellite image dated 21 June 2011 shows four CH-47 in the Salerno heavy-lift area.

```yaml
Salerno:
  assigned_from_B_7_158_pool: 6
  satellite_visible_2011_06_21: 4
  visual_minimum: 4
```

The source also describes at least two CH-47 for brigade general support and planned air assaults, plus two CH-47 for SOTF 310 and short-notice night air assaults. Four aircraft are therefore directly represented by task allocation. The remaining two assigned aircraft provide a plausible allowance for aircraft on mission, in maintenance, held as reserve or temporarily operating away from the ramp.

### 4.2 FOB Shank

The project-evaluated satellite image dated 24 October 2010 shows six clearly identifiable CH-47 at FOB Shank.

```yaml
Shank:
  assigned_from_B_7_158_pool: 6
  satellite_visible_2010_10_24: 6
  visual_minimum: 6
```

This image predates the exact 2011 pool snapshot and therefore does not prove that every one of the same airframes remained assigned in 2011. It does, however, demonstrate that a six-aircraft CH-47 detachment was physically and operationally plausible at Shank.

### 4.3 Bagram

Bagram receives the remaining 13 aircraft from the B/7-158 deployment pool. This is consistent with its role as the central general-support, maintenance, logistics and theater-wide tasking node for this formation.

```yaml
Bagram:
  assigned_from_B_7_158_pool: 13
  allocation_basis:
    - central general-support role
    - larger logistics and maintenance capacity
    - remainder of the B/7-158 25-aircraft pool after two six-aircraft forward detachments
```

A single Bagram satellite image is not expected to show all 13 assigned aircraft simultaneously because aircraft could be on mission, forward-positioned, undergoing maintenance or operating from another site.

## 5. Assigned inventory is not visible ramp count

The following rule is binding:

```text
ASSIGNED_UNIT_INVENTORY != AIRCRAFT_VISIBLE_ON_ONE_SATELLITE_IMAGE
```

Satellite imagery establishes a visual minimum for the image date. It does not by itself determine the full assigned inventory. Aircraft may be:

- on general-support or resupply missions;
- conducting air assault or special-operations support;
- temporarily operating from an outlying FOB or combat outpost;
- in maintenance or under cover;
- held as reserve away from the photographed ramp.

Clients, late-activation templates and statics are also not additive inventories.

## 6. Required inheritance by base documentation

The following values are binding as allocations from the documented B/7-158 deployment pool and must be inherited by all affected manifests, implementation handoffs, runtime configurations and campaign-state inventories:

```text
Bagram:      13 CH-47 from the B/7-158 deployment pool
FOB Salerno:  6 CH-47 from the B/7-158 deployment pool
FOB Shank:    6 CH-47 from the B/7-158 deployment pool
```

These values do not exclude other independently documented CH-47 units at the same locations. Any additional unit must be documented separately and must not be silently merged into this 25-aircraft pool.

Any existing document that states a different active allocation for this specific B/7-158 pool is superseded for that subject by this decision and must be normalized when next edited.

This decision does not change the separately established Jalalabad CH-47 inventory, because Jalalabad represents a separate unit and inventory decision.