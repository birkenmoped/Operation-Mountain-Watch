---
document_id: OMW-DOC-VALIDATION-MAIN-CLEANUP-PLAN
status: PLANNED
document_class: CLEANUP_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - documentation-metadata cleanup scope required to restore validator compliance on current main
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/documentation-validation-main-cleanup
source_commit: ba77bf4a65d8247854926ccec45f60c90786fecf
validated_in_dcs: false
---

# Documentation Validation Main Cleanup

## Scope

This branch repairs metadata-only documentation debt already present on `main` before PR #131.

The cleanup is intentionally separated from Ground RESUPPLY feature work. It does not alter DCS runtime logic, MOOSE behavior, CampaignState behavior, mission files, or accepted test observations.

The validator debt falls into two classes:

1. current files with invalid or incomplete frontmatter under the newer metadata policy;
2. files already present on `main` that still carry `source_commit: PENDING_MERGE`.

For the latter, the current `main` snapshot `998080da9a7a71dae7f713b9590dfeadb5ae93ba` is used as the concrete repository commit demonstrably containing the documented source state before this metadata migration.

Acceptance frontmatter is populated only where the exact branch, commit, mission hash, DCS version and MOOSE provenance are already present in the document or its directly linked runtime evidence. No hashes or runtime results are invented.

## Validation target

The branch must satisfy both:

```text
python3 tools/validate_documentation.py .
python3 tools/validate_documentation.py --main .
```

before it can be proposed for merge.

## Completed validation

The ordinary pull-request validator passed after the inherited metadata normalization.

A one-shot branch cleanup then replaced the remaining inherited `source_commit: PENDING_MERGE` placeholders only in files that were already present on `main` at commit `998080da9a7a71dae7f713b9590dfeadb5ae93ba`.

Before committing those replacements, the cleanup workflow executed both required commands successfully:

```text
python3 tools/validate_documentation.py .
python3 tools/validate_documentation.py --main .
```

The one-shot workflow removed itself in the same resulting commit, so no temporary automation remains in the final branch tree.

Final inherited-provenance cleanup commit:

```text
92a523d51df7bbc95f165de029dc8ae1d2fb7592
```

No `.miz`, Lua runtime, MOOSE behavior, CampaignState behavior or DCS test result was changed by this cleanup.
