---
document_id: OMW-EVIDENCE-BAGRAM-CH47-ALLOCATION-ADDENDUM
status: BINDING_PROJECT_DECISION
document_class: BASE_MANIFEST_EXTENSION
owning_policy: OMW-GOV-001
authoritative_for:
  - Bagram active CH-47 inventory
  - extension of the Bagram air-operations manifest beyond the previously unresolved non-fighter inventory
not_authoritative_for:
  - exact daily aircraft location
  - DCS or MOOSE runtime acceptance
scenario_period: 2010-08-01/2011-12-31
supersedes:
  - unresolved Bagram CH-47 inventory on this branch
superseded_by:
source_branch: docs/bagram-air-operations-manifest
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Bagram CH-47 allocation addendum

## Binding Bagram inventory

The active Bagram CH-47 inventory is:

```text
13 CH-47
```

This resolves the previously open Bagram non-fighter inventory decision for CH-47 only. C-130, UH-60 Utility and HH-60G inventories remain separate decisions.

## Cross-base allocation

The Bagram value is part of the binding OMW reconstruction of the documented 25-aircraft pool:

| Location | Assigned CH-47 inventory |
|---|---:|
| Bagram | 13 |
| FOB Salerno | 6 |
| FOB Shank | 6 |
| **Total** | **25** |

The central decision is maintained in `OMW-AIR-CH47-BAGRAM-SALERNO-SHANK-ALLOCATION` and proposed for `main` by Draft PR #45.

## Basis

Bagram receives the largest share because it functioned as the central general-support, logistics, maintenance and theater-wide tasking node. The two forward detachments are each set at six aircraft:

- four CH-47 are visible on the project-evaluated FOB Salerno image dated 21 June 2011, while six assigned aircraft allow for mission, maintenance and reserve status;
- six CH-47 are visible on the project-evaluated FOB Shank image dated 24 October 2010.

The resulting distribution is:

```text
13 / 6 / 6
```

This is an evidence-based OMW reconstruction. The historical source establishes the 25-aircraft pool and three locations, but does not publish the exact integer split.

## Implementation consequence

The later Bagram AIRWING, SQUADRON, warehouse and CampaignState implementation must use a logical inventory of 13 CH-47 aircraft.

Clients, late-activation templates and statics are representations of the same logical inventory and are not additive.

A single satellite image is not expected to show all 13 Bagram aircraft at once because aircraft may be on general-support missions, forward-positioned, undergoing maintenance or temporarily operating from another location.