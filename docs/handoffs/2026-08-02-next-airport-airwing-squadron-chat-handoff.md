---
document_id: OMW-HANDOFF-NEXT-AIRPORT-AIRWING-SQUADRON-2026-08-02
status: WORKING_HANDOFF
document_class: PROJECT_HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - continuation context after completion of the Kandahar AIRWING/SQUADRON foundation
  - the unresolved selection of the next airport AIRWING/SQUADRON work package
  - required reading order for a successor ChatGPT conversation
not_authoritative_for:
  - selection of the next airport
  - AIRWING, SQUADRON, warehouse, inventory, parking or template decisions for an unselected airport
  - project governance already owned by main documentation
  - runtime acceptance beyond cited evidence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
validated_in_dcs: false
handoff_time_local: 2026-08-02T02:41:00+02:00
---

# Next airport AIRWING/SQUADRON preparation – Chat handoff

## 1. Scope correction and handoff purpose

This handoff is **not** for further Kandahar AirOps implementation.

The Kandahar AIRWING/SQUADRON foundation was completed and runtime-accepted in PR #47. The successor chat is intended to prepare the next airport that does not yet have its AIRWING/SQUADRON foundation.

The project owner has identified the remaining candidate set as:

```text
Khost / FOB Salerno
Tarinkot
Shindand
```

No airport has been selected yet. The successor chat must not infer or choose one silently.

Until the project owner explicitly selects the next airport, this handoff authorizes only:

```text
repository and documentation inventory
branch and PR inventory
comparison of existing evidence for the three candidates
identification of missing decisions and mission-editor prerequisites
proposal of a technically sensible next work package
```

It does not authorize airport-specific code, object names, inventory values, parking contracts or Mission Editor changes.

## 2. Mandatory reading before any work

The successor chat must read both the project authority on `main` and the relevant implementation/evidence branches. Chat memory is not a substitute for repository documentation.

### On `main`

```text
docs/00-project-governance.md
docs/README.md
docs/DOCUMENT-REGISTRY.md
docs/SUBPROJECT-REGISTRY.md
docs/26-moose-first-development-policy.md
docs/moose/VERSION-AND-SOURCES.md
docs/19-active-air-orbat-decisions.md
docs/20-air-orbat-mission-editor-worklist.md
docs/38-mission-editor-master-worklist.md
```

These documents define authority, working methods, MOOSE-first requirements, active ORBAT decisions, Mission Editor rules, branch status and acceptance boundaries.

### On the current air-operations integration branch

```text
branch: docs/bagram-air-operations-manifest
```

At minimum inspect:

```text
mission/air-operations/
mission/tests/
tools/
docs/evidence/
docs/handoffs/2026-08-02-next-airport-airwing-squadron-chat-handoff.md
```

The completed Bagram, Jalalabad and Kandahar work may be used as implementation and test-pattern evidence. It must not be copied mechanically to another airport.

### For the selected airport

After the project owner selects Khost/FOB Salerno, Tarinkot or Shindand, search all relevant repository branches and documentation for that exact airport before proposing names or code.

The inventory must cover at least:

```text
historical and active ORBAT decisions
existing mission-editor manifests and audits
warehouse anchors
DCS airbase name and runtime ID
client groups
late-activation templates
statics
zones and support objects
parking and taxi constraints
existing diagnostics, builders and runtime evidence
open or merged PRs affecting the airport
```

If the repository does not support a required decision, report the gap instead of filling it with general knowledge.

## 3. Current completed reference: Kandahar

PR #47 is complete and is reference material only for the next-airport work.

```text
PR:            #47
Title:         Implement and validate Kandahar AIRWING/SQUADRON foundation
Feature branch: agent/kandahar-airwing-baseline-contract
Target branch:  docs/bagram-air-operations-manifest
PR head:        dd9ea3f60ecf581b0d0a9e4a3e4ff3f4f94813d3
Merge commit:   3fdd9425c86fbbc377da386e3995c2c060068fd1
Status:         closed / merged / not draft
```

Accepted Kandahar foundation:

```text
2 AIRWINGs
9 SQUADRONs
112 registered physical airframes
6 deferred MC-12 without approved physical DCS representation
Main and Heliport Safe Parking contracts
runtime-filtered MQ-1 and MQ-9 initial-spawn parking pools
normalized OMW_AIROPS_KANDAHAR.lua
no-tasking / no-spawn runtime acceptance
```

Important limitation retained as evidence:

```text
SQUADRON:SetParkingIDs() and asset.parkingIDs were accepted for initial spawn.
They did not constrain DCS-native post-landing final stand selection.
```

Kandahar is not the continuation target unless the project owner later issues a separate Kandahar task.

## 4. Remaining airport candidates

### Khost / FOB Salerno

```text
selection status: NOT SELECTED
AIRWING/SQUADRON preparation status: TO BE INVENTORIED
```

### Tarinkot

```text
selection status: NOT SELECTED
AIRWING/SQUADRON preparation status: TO BE INVENTORIED
```

### Shindand

```text
selection status: NOT SELECTED
AIRWING/SQUADRON preparation status: TO BE INVENTORIED
```

The candidate list does not itself define:

```text
which airport should be next
historical units
active units
inventories
client limits beyond project-wide policy
AIRWING or SQUADRON identifiers
warehouse identifiers or anchors
parking IDs
DCS model substitutions
payloads
```

Those values must come from the authoritative documentation and explicit project-owner decisions for the selected airport.

## 5. Required first response in the successor chat

The successor chat should begin with a concise inventory, not code.

Required output:

1. confirm that Kandahar is completed reference material, not the new work target;
2. confirm that the candidate set is Khost/FOB Salerno, Tarinkot and Shindand;
3. report which relevant `main` and integration-branch documents were read;
4. report any already existing airport-specific branches, PRs, manifests or evidence found for each candidate;
5. identify which candidate appears most ready for AIRWING/SQUADRON preparation and why;
6. ask the project owner to make or confirm the airport selection if it is still unspecified;
7. make no code or Mission Editor change before that selection.

## 6. Workflow after airport selection

After the project owner explicitly selects the airport:

1. establish the authoritative branch and exact base commit;
2. create a new, airport-specific branch rather than reusing the completed Kandahar feature branch;
3. document the current Mission Editor object contract before constructing MOOSE objects;
4. verify DCS airbase identity, warehouse anchor and parking topology;
5. reconcile historical evidence with active ORBAT decisions;
6. obtain explicit approval for any unresolved identifiers, substitutions or inventory values;
7. implement the smallest no-spawn diagnostic first;
8. proceed incrementally through registration, parking, controlled spawn and normalized no-tasking foundation;
9. record every decision and runtime result in the repository;
10. keep the PR Draft and unmerged until the project owner explicitly authorizes otherwise.

A branch name should be chosen only after airport selection, for example:

```text
agent/<airport>-airwing-squadron-baseline
```

This is a naming pattern, not a preapproved exact branch name.

## 7. Binding working agreements

The successor chat must derive the working method from repository documentation. The following summary is non-exhaustive:

- MOOSE-first: before writing project-specific Lua, check the official documentation and source matching the embedded MOOSE version;
- do not invent object names, units, inventories, parking IDs, contracts or historical assignments;
- separate logical inventory, Mission Editor templates, statics, client reservations and active dynamic groups;
- do not treat visible statics as inventory without documented provenance;
- separate diagnostics and acceptance harnesses from production-facing Lua;
- claim runtime acceptance only for the exact tested branch, commit, mission, bundle, DCS and MOOSE state;
- use existing accepted AIRWING/SQUADRON objects rather than constructing duplicates;
- document decisions and evidence promptly;
- do not set a PR Ready for Review or merge it without explicit project-owner authorization.

## 8. Copyable successor-chat prompt

```text
You are taking over the next AIRWING/SQUADRON airport work package for Operation Mountain Watch.

Repository:
birkenmoped/Operation-Mountain-Watch

Local path:
P:\DCS-DEV\Operation-Mountain-Watch

This is not a continuation of Kandahar AirOps implementation. Kandahar PR #47 is completed reference material:
- feature branch: agent/kandahar-airwing-baseline-contract
- target branch: docs/bagram-air-operations-manifest
- merge commit: 3fdd9425c86fbbc377da386e3995c2c060068fd1

The next airport has not yet been selected. Remaining candidates are exactly:
- Khost / FOB Salerno
- Tarinkot
- Shindand

Before any change, read the project authority on main and the current air-operations integration branch. At minimum inspect:
- docs/00-project-governance.md
- docs/README.md
- docs/DOCUMENT-REGISTRY.md
- docs/SUBPROJECT-REGISTRY.md
- docs/26-moose-first-development-policy.md
- docs/moose/VERSION-AND-SOURCES.md
- docs/19-active-air-orbat-decisions.md
- docs/20-air-orbat-mission-editor-worklist.md
- docs/38-mission-editor-master-worklist.md
- docs/handoffs/2026-08-02-next-airport-airwing-squadron-chat-handoff.md
- relevant files under mission/air-operations, mission/tests, tools and docs/evidence on docs/bagram-air-operations-manifest

Working methods and agreements must be taken from the repository documentation, not reconstructed from chat memory.

Begin with a repository and branch inventory for Khost/FOB Salerno, Tarinkot and Shindand. Report existing documentation, manifests, mission-editor preparation, branches, PRs, historical/active ORBAT decisions and blockers for each candidate.

Do not choose the airport silently. If the project owner has not selected one in the new conversation, present the evidence-based readiness comparison and ask for the selection.

Do not write Lua, create branches, change Mission Editor objects or invent AIRWING/SQUADRON names, inventories, warehouse anchors or parking IDs before the selected airport and its source-of-truth documents are confirmed.
```
