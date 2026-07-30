---
document_id: OMW-EVIDENCE-BAGRAM-CH47-ALLOCATION-ADDENDUM
status: BINDING_PROJECT_DECISION
document_class: BASE_MANIFEST_EXTENSION
owning_policy: OMW-GOV-001
authoritative_for:
  - Bagram allocation from the documented B Company 7-158 Aviation CH-47 deployment pool
  - extension of the Bagram air-operations manifest beyond the previously unresolved non-fighter inventory
not_authoritative_for:
  - total CH-47 strength at Bagram from all possible units
  - total CH-47 strength in Afghanistan
  - total U.S. or global CH-47 inventory
  - exact daily aircraft location
  - DCS or MOOSE runtime acceptance
scenario_period: 2010-08-01/2011-12-31
supersedes:
  - unresolved Bagram allocation from the B/7-158 CH-47 deployment pool on this branch
superseded_by:
source_branch: docs/bagram-air-operations-manifest
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Bagram CH-47 allocation addendum

## Scope

The 25-aircraft figure used here refers exclusively to the deployment pool of:

```text
B Company, 7th Battalion, 158th Aviation Regiment
19 organic CH-47 + 6 additional assigned CH-47 = 25
```

It is not the total number of CH-47 aircraft in Afghanistan, the total U.S. inventory, or the global CH-47 fleet. Other units and their aircraft are outside this pool.

## Binding Bagram allocation

Bagram receives the following allocation from this specific B/7-158 deployment pool:

```text
13 CH-47
```

This resolves the previously open Bagram non-fighter decision for this CH-47 unit pool only. C-130, UH-60 Utility and HH-60G inventories remain separate decisions.

## Cross-base allocation of the B/7-158 pool

| Location | Assigned CH-47 inventory from this unit pool |
|---|---:|
| Bagram | 13 |
| FOB Salerno | 6 |
| FOB Shank | 6 |
| **Total B/7-158 pool** | **25** |

The central decision is maintained in `OMW-AIR-CH47-BAGRAM-SALERNO-SHANK-ALLOCATION` and proposed for `main` by Draft PR #45.

## Basis

Bagram receives the largest share because it functioned as the central general-support, logistics, maintenance and theater-wide tasking node for this formation. The two forward detachments are each set at six aircraft:

- four CH-47 are visible on the project-evaluated FOB Salerno image dated 21 June 2011, while six assigned aircraft allow for mission, maintenance and reserve status;
- six CH-47 are visible on the project-evaluated FOB Shank image dated 24 October 2010.

The resulting distribution within this unit pool is:

```text
13 / 6 / 6
```

This is an evidence-based OMW reconstruction. The historical source establishes the B/7-158 25-aircraft deployment pool and the three locations, but does not publish the exact integer split.

## Implementation consequence

The later Bagram AIRWING, SQUADRON, warehouse and CampaignState implementation representing this B/7-158 component must use a logical inventory of 13 CH-47 aircraft.

Clients, late-activation templates and statics are representations of the same logical inventory and are not additive.

Additional independently documented CH-47 units at Bagram, if any, must be represented separately and must not be silently merged into this 13-aircraft allocation.

A single satellite image is not expected to show all 13 B/7-158 aircraft at once because aircraft may be on general-support missions, forward-positioned, undergoing maintenance or temporarily operating from another location.