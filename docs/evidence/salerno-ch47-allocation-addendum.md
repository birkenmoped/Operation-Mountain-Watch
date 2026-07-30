---
document_id: OMW-EVIDENCE-SALERNO-CH47-ALLOCATION-ADDENDUM
status: BINDING_PROJECT_DECISION
document_class: BASE_MANIFEST_CORRECTION
owning_policy: OMW-GOV-001
authoritative_for:
  - FOB Salerno active CH-47 inventory
  - correction of conflicting Salerno CH-47 values on this branch
not_authoritative_for:
  - exact daily aircraft location
  - DCS or MOOSE runtime acceptance
scenario_period: 2010-08-01/2011-12-31
supersedes:
  - eight CH-47D in docs/19-active-air-orbat-decisions.md on this branch
  - eight CH-47D in docs/51-salerno-air-operations-manifest.md on this branch
  - eight CH-47D in docs/53-salerno-air-operations-implementation-handoff.md on this branch
superseded_by:
source_branch: agent/document-salerno-air-operations
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# FOB Salerno CH-47 allocation correction

## Binding correction

The active FOB Salerno CH-47 inventory is:

```text
6 CH-47D
```

This value replaces every active Salerno value of eight CH-47D on the current branch.

## Cross-base allocation

The correction is part of the binding OMW reconstruction of the documented 25-aircraft pool:

| Location | Assigned CH-47 inventory |
|---|---:|
| Bagram | 13 |
| FOB Salerno | 6 |
| FOB Shank | 6 |
| **Total** | **25** |

The central decision is maintained in `OMW-AIR-CH47-BAGRAM-SALERNO-SHANK-ALLOCATION` and proposed for `main` by Draft PR #45.

## Salerno evidence

The project-evaluated satellite image dated 21 June 2011 shows four CH-47 in the Salerno heavy-lift area.

```yaml
Salerno_CH47:
  assigned_inventory: 6
  satellite_visible_2011_06_21: 4
  visual_minimum: 4
```

Historical tasking evidence accounts for at least four aircraft:

- at least two for brigade general support and planned air assaults;
- two for SOTF 310 and short-notice night air assaults.

The difference between six assigned aircraft and four visible aircraft is operationally plausible because aircraft could be on mission, in maintenance, held as reserve or temporarily operating away from the photographed ramp.

## Implementation consequence

All later Salerno AIRWING, SQUADRON, warehouse and CampaignState implementations must use:

```text
SQ_US_SAL_CH47_TF_TIGERSHARK_MEDIUM_LIFT
logical inventory: 6 aircraft
```

Clients, late-activation templates and statics remain representations of the same six-aircraft logical inventory and are not added to it.

Until the larger branch documents are normalized directly, this addendum has subject-specific precedence for the Salerno CH-47 inventory.