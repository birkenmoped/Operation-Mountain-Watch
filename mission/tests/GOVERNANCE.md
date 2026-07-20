# Binding governance for all Operation Mountain Watch test missions

This document applies to every test family, test stage, implementation note, acceptance contract, status report, result interpretation, and future test document under `mission/tests/`.

The complete project rule is [`docs/00-project-governance.md`](../../docs/00-project-governance.md).

## MOOSE-first rule

Every test must use all available and applicable MOOSE capabilities as its technical foundation.

Before native DCS scripting, project-specific code, or a hybrid solution may be considered, the test documentation must identify and evaluate the relevant MOOSE:

- classes and wrappers;
- spawn, respawn, teleport, and lifecycle methods;
- routing and tasking functions;
- schedulers and finite-state-machine patterns;
- events and detection mechanisms;
- sets, zones, coordinates, menus, messages, and utilities;
- CTLD, CSAR, Warehouse, Ops, AI, and other applicable framework modules.

Several MOOSE functions may be combined when one function alone does not completely satisfy the requirement.

## Decision boundary

MOOSE limitations, disadvantages, runtime behavior, and alternative approaches may always be investigated and discussed.

That discussion is not authorization to use a non-MOOSE implementation.

Only the project owner decides whether a documented MOOSE limitation justifies:

- a native DCS implementation;
- a project-specific implementation;
- a hybrid MOOSE/DCS/custom solution;
- bypassing or replacing an applicable MOOSE mechanism.

Until this approval is explicit and recorded, the accepted test direction remains MOOSE-first.

## Test acceptance consequence

A test implementation that uses native DCS or custom code without the required MOOSE evaluation and project-owner approval cannot receive final acceptance, even if its runtime behavior appears successful.

Every new acceptance contract must verify either:

1. that the tested mechanism is based on the applicable MOOSE capability; or
2. that the exact non-MOOSE exception has been explicitly approved and recorded.

Historical result records remain evidence of the implementation tested at that time. They do not override this rule and do not authorize the same implementation approach for later stages.
