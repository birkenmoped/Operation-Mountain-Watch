---
document_id: OMW-EVIDENCE-INDEX
status: BINDING
document_class: EVIDENCE_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - index of current evidence and decision records
  - navigation to source-qualified project evidence
not_authoritative_for:
  - merge approval
  - runtime acceptance beyond linked records
scenario_period: 2010-08-01/2011-12-31
project_phase: TARINKOT_MOOSE_SOURCE_REVIEW_COMPLETE
supersedes:
  - incomplete evidence index before Tarinkot reconciliation
superseded_by: []
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Evidence and Decision Records

This directory contains source-qualified evidence, audits, decisions and acceptance records. Evidence records do not become project-wide runtime acceptance merely by existing in the repository. The `authoritative_for` and `not_authoritative_for` metadata of each document define its exact scope.

## Current cross-project records

- `source-intake-audit-2026-07-28.md` – source-intake and documentation audit.
- `july-2011-orbat-source-authority.md` – authority and inheritance rules for the July 2011 ORBAT.
- `source-records/` – preserved legacy source records; not automatically current authority.

## Tarinkot – current active record set

The following records belong to Draft PR #53 and the branch `agent/tarinkot-object-contract-reconciliation`:

- `tarinkot-mission-editor-audit-omw-template-v5-salerno.md` – exact read-only audit of the current source MIZ.
- `tarinkot-2011-aviation-unit-and-aircraft-evidence.md` – contemporaneous 2011 AH-64/UH-60/CH-47 and unit evidence.
- `tarinkot-aviation-rotations-and-national-attribution-2006-2013.md` – predecessor/successor rotations and national-attribution boundaries.
- `tarinkot-post-period-aviation-and-base-layout-context-2012-2013.md` – post-period scale and base-subarea context.
- `tarinkot-farp-hot-refuel-uh60-2011.md` – September 2011 FARP/hot-refuel evidence.
- `tarinkot-source-critical-correction-task-force-attack-structure.md` – correction of unsupported organic-battalion claims.
- `tarinkot-owner-decision-active-baseline-2026-08-02.md` – owner-selected March–December 2011 historical baseline.
- `tarinkot-g2-object-contract-acceptance-checklist-2026-08-03.md` – complete technical G2 contract.
- `tarinkot-g2-owner-acceptance-2026-08-03.md` – explicit owner acceptance of the full G2 contract.
- `tarinkot-g4-moose-2-9-18-source-review.md` – exact embedded MOOSE 2.9.18 source review and G5 boundary.

Current gate state:

```yaml
G0_provenance: PASS_BRANCH
G1_ORBAT_and_evidence: PASS_BRANCH
G2_object_contract: OWNER_ACCEPTED_BRANCH
G3_mission_editor: PARTIAL
G4_MOOSE_source_review: PASS_SOURCE_REVIEW
G5_read_only_diagnostics: AUTHORIZED_NOT_STARTED
```

The older Tarinkot Draft PR #40 is retained only as `HISTORICAL_SUPERSEDED_DRAFT` and must not be used as the active Tarinkot source of truth.
