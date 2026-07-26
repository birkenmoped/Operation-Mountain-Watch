# Project Governance

## GOV-001 — MOOSE-first implementation and owner-controlled exceptions

### Status

Binding. This is one of the highest-priority rules of Operation Mountain Watch and applies to the entire project, every prototype, every test series, every acceptance document, and every future implementation decision.

### Binding rule

Operation Mountain Watch is a **MOOSE-first project**.

All available and applicable MOOSE classes, functions, lifecycle mechanisms, controllers, schedulers, wrappers, tasking methods, event systems, state machines, utilities, and established framework patterns **MUST be identified, evaluated, and used as the default implementation foundation**.

Project code must not bypass an applicable MOOSE capability merely because a native DCS call or a custom implementation appears shorter, more familiar, or easier to prototype.

### When a non-MOOSE alternative may be proposed

A native DCS scripting solution, a project-specific implementation, or a hybrid MOOSE/DCS/custom solution may be proposed only when the relevant MOOSE capability:

- cannot fully satisfy the operational requirement;
- introduces a documented limitation that prevents acceptance;
- creates a demonstrated technical or runtime disadvantage that is unacceptable for the project; or
- does not provide the required functionality.

The proposal must document:

1. the operational requirement;
2. the MOOSE capabilities and patterns that were evaluated;
3. the prototype or test evidence;
4. the precise limitation, disadvantage, or missing capability;
5. the proposed fallback;
6. the expected effects on lifecycle handling, persistence, performance, maintainability, compatibility, and testability.

### Decision authority

Technical discussion of MOOSE limitations, disadvantages, risks, and alternatives is explicitly permitted and expected. Such discussion does **not** authorize a deviation from MOOSE.

Only the project owner may approve:

- bypassing an applicable MOOSE capability;
- replacing a MOOSE mechanism with native DCS scripting;
- implementing project-specific functionality instead of using MOOSE;
- accepting a hybrid MOOSE/DCS/custom solution.

No contributor, document, test result, implementation, automated agent, or inferred technical necessity may grant or imply this approval.

Until the project owner has explicitly approved an exception, the accepted implementation direction remains MOOSE-first and any non-MOOSE work is exploratory only.

### Required implementation order

Every implementation and recovery design follows this order:

1. use the applicable MOOSE capability directly;
2. combine applicable MOOSE capabilities where one function alone is insufficient;
3. adapt the surrounding project workflow while retaining MOOSE as the foundation;
4. document and test the remaining MOOSE limitation;
5. present a native DCS, custom, or hybrid fallback for owner decision;
6. implement the fallback only after explicit owner approval.

### Documentation and review requirements

All active architecture documents, prototype plans, test descriptions, acceptance criteria, implementation notes, and reviews are governed by this rule.

New documents must either repeat the rule where it materially affects the subject or reference this document. Historical result records remain evidence of the implementation tested at that time; they do not override this governance rule.

Any document that can be interpreted as allowing an automatic switch from MOOSE to native DCS or custom code is superseded by GOV-001.

### Exception record

An approved exception must be recorded in an ADR or an equivalently explicit decision document and must include:

- scope of the exception;
- approving project-owner decision;
- MOOSE capabilities evaluated;
- reason for rejection or supplementation;
- approved fallback;
- constraints and required regression tests.

Approval for one narrowly defined exception does not authorize non-MOOSE implementations elsewhere in the project.
