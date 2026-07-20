# Operation Mountain Watch documentation

## Binding governance for every document in this directory

Every architecture document, design note, roadmap, prototype plan, ADR, handoff, test strategy, implementation note, and future document under `docs/` is governed by [`GOV-001`](00-project-governance.md).

Operation Mountain Watch is a **MOOSE-first project**.

All available and applicable MOOSE classes, functions, modules, lifecycle mechanisms, routing and tasking methods, schedulers, event systems, finite-state-machine patterns, wrappers, sets, zones, coordinates, detection mechanisms, utilities, CTLD, CSAR, Warehouse, Ops, AI, and other relevant framework capabilities must be identified, evaluated, and used as the implementation foundation.

Several MOOSE capabilities must be combined where one function alone does not completely satisfy a requirement.

MOOSE limitations, disadvantages, risks, and alternative approaches may always be investigated and discussed. Such discussion does not authorize a deviation from MOOSE.

Only the project owner may approve:

- bypassing an applicable MOOSE capability;
- replacing a MOOSE mechanism with native DCS scripting;
- implementing project-specific functionality instead of using MOOSE;
- accepting a hybrid MOOSE/DCS/custom solution.

Before requesting that decision, the documentation must identify the relevant MOOSE capabilities, test them where practical, record the exact remaining limitation, and describe the proposed fallback and its lifecycle, persistence, performance, maintainability, compatibility, and testing consequences.

Until the project owner has explicitly approved and recorded an exception, the accepted implementation direction remains MOOSE-first.

This directory-level rule applies even when an older individual document does not repeat it. Any older wording that could be interpreted as granting an automatic switch to native DCS or custom code is superseded by `GOV-001`.

Historical reports and test records remain unchanged evidence of what was tested at that time. They do not authorize the same implementation approach for future work.

## Primary governance and MOOSE documents

- [`00-project-governance.md`](00-project-governance.md)
- [`03-system-architecture.md`](03-system-architecture.md)
- [`23-moose-test-mission-strategy.md`](23-moose-test-mission-strategy.md)
- [`24-moose-version-and-build-policy.md`](24-moose-version-and-build-policy.md)
- [`adr/0009-use-moose-from-first-test-stage.md`](adr/0009-use-moose-from-first-test-stage.md)
- [`adr/0010-pin-moose-release-and-readable-static-build.md`](adr/0010-pin-moose-release-and-readable-static-build.md)
