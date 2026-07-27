---
document_id: OMW-REVIEW-TM01-TM02-MOOSE-FIRST
status: DRAFT
authoritative_for:
  - TM01 and TM02 MOOSE-first review findings
  - classification of historical test fixtures
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: review/tm01-tm02-moose-first
validated_in_dcs: false
---

# 39 – TM01/TM02 MOOSE-First Code Review

## Status

```text
IN PROGRESS
```

Governed by:

- `OMW-GOV-001` – project authority and owner approvals;
- `OMW-GOV-MOOSE-FIRST` – `docs/26-moose-first-development-policy.md`;
- `OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION` – `docs/37-campaign-architecture-and-dynamic-mission-design.md`.

This document does not authorize a merge or a non-MOOSE exception.

## Review targets

### TM01

Primary branch:

```text
feature/tm01b-convoy-caching
```

Primary runtime files:

```text
mission/tests/tm01-blue-convoy/src/convoy_cache_controller.lua
mission/tests/tm01-blue-convoy/src/convoy_proxy_controller/*.lua
mission/tests/tm01-blue-convoy/src/player_interest_monitor.lua
mission/tests/tm01-blue-convoy/src/representation_interest_monitor.lua
mission/tests/tm01-blue-convoy/src/in_memory_campaign_state.lua
mission/tests/tm01-blue-convoy/src/proxy_campaign_state.lua
mission/tests/tm01-blue-convoy/src/tm01b.lua
mission/tests/tm01-blue-convoy/src/tm01c.lua
```

### TM02

Current stacked implementation head:

```text
feature/tm02w2f-red-initial-network-fill
```

Relevant history:

```text
feature/tm02-red-side-foundation
feature/tm02-red-tree-fill
feature/tm02-red-loss-replenishment
feature/tm02-red-proxy-movement
feature/tm02w-red-network-registry
feature/tm02w2-red-source-cost-selection
feature/tm02w2-red-task-execution
feature/tm02w2f-red-initial-network-fill
```

Primary current runtime files:

```text
mission/tests/tm02-red-network/src/tm02w2f-initial-fill-planner.lua
mission/tests/tm02-red-network/src/tm02w2f-commander-scheduler.lua
mission/tests/tm02-red-network/src/tm02w2f-direct-offroad-navigation.lua
mission/tests/tm02-red-network/src/tm02w2f-transit-representation.lua
mission/tests/tm02-red-network/src/tm02w2f-transit-representation-v9.lua
mission/tests/tm02-red-network/src/tm02w2f-progress-watchdog*.lua
mission/tests/tm02-red-network/src/tm02w2f-route-reassignment-watchdog.lua
mission/tests/tm02-red-network/src/tm02w2e-combat-events-v3.lua
```

## Review method

Each custom mechanism is classified as:

```text
KEEP_CUSTOM
MOOSE_REPLACE
MOOSE_WRAP
OBSOLETE_BY_ARCHITECTURE
NEEDS_DCS_TEST
```

For every `MOOSE_REPLACE` or `MOOSE_WRAP` decision the exact MOOSE class, verified method, runtime version and DCS regression test must be recorded.

A `KEEP_CUSTOM` decision requires:

1. documented MOOSE research;
2. verified framework limitation or project-specific domain requirement;
3. smallest possible custom scope;
4. explicit project-owner approval before production adoption.

## Initial TM01 findings

### Project-owned campaign responsibilities

- authoritative convoy identity and campaign inventory;
- physical versus virtual representation state;
- survivor-slot and cargo-loss accounting;
- exposure debt and representation priority;
- prohibition of packing while observed, tracked, engaged or near players;
- persistence snapshots and restoration.

MOOSE executes and observes these operations; it does not replace the authoritative campaign ledger.

### MOOSE migration candidates

| Current custom responsibility | Review target |
|---|---|
| recurring automation and polling | `SCHEDULER` |
| movement-state transitions | `FSM` / `FSM_CONTROLLABLE` where applicable |
| runtime ground-group lifecycle | `GROUP`, `ARMYGROUP`, `OPSGROUP` |
| template spawning | `SPAWN` |
| route construction and assignment | `COORDINATE`, OPS routing methods and waypoint helpers |
| runtime group lookup | `GROUP:FindByName()` |
| player/enemy collections | `SET_CLIENT`, `SET_PLAYER`, `SET_GROUP`, `SET_UNIT` |
| proximity checks | MOOSE sets, zones and coordinates before custom loops |
| destruction/loss handling | MOOSE event handling before polling-only detection |

### Structural concern

`convoy_cache_controller.lua` combines too many responsibilities:

- route geometry;
- spawning;
- representation transitions;
- markers;
- loss observation;
- arrival handling;
- scheduler behavior;
- validation and reporting.

Production target separation:

```text
ConvoyCampaignEntity
ConvoyRoutePlan
ConvoyRepresentationController
ConvoyPhysicalAdapter
ConvoyInterestService
ConvoyRecoveryService
```

Accepted TM01 evidence remains useful. The existing controller is not promoted unchanged into production.

## Initial TM02 findings

### Useful retained mechanisms

- authoritative personnel accounting;
- transactional reservations;
- separation of command relationships and movement links;
- bounded command budget and concurrency;
- unique movement/task identities;
- physical/virtual invariants;
- exact survivor reconciliation;
- explicit DCS acceptance contracts.

### Superseded production doctrine

TM02A through TM02V are retained as:

```yaml
status: HISTORICAL_TEST_FIXTURE
production_architecture: false
```

The fixed relay, fixed-garrison and complete-initial-fill doctrines are not production rules.

TM02W and successors form the current production direction:

```text
weighted movement graph
multiple possible sources and alternate routes
separate command, movement and personnel networks
Guard Floor / Readiness Target / Hard Capacity
bounded command cycles
MOOSE-first physical execution
```

Production sites include:

```text
HQ
Distribution Sites
Hide Sites
Forward Caches
Candidate Sites
```

A site is not automatically a permanently manned garrison. Personnel, supplies and infrastructure are separate resources. New sites arise through purposeful construction movements and explicit state transitions.

Obsolete assumptions:

- fixed target garrison at every node;
- complete initial population of every node;
- node count equals occupied hideout count;
- permanent use of every registered site;
- movement whose only purpose is filling static target strengths.

Historical tests remain useful for accounting and concurrency validation only.

### MOOSE migration candidates

| Current custom responsibility | Review target |
|---|---|
| commander timer/cycle | `SCHEDULER`; later `COMMANDER`/`CHIEF` review |
| path search and source cost | `Core.Astar` plus OMW cost policy |
| travelling infantry runtime | `ARMYGROUP` / `OPSGROUP` |
| task lifecycle | `FSM`; `AUFTRAG` where suitable |
| site/group collections | MOOSE SET classes |
| movement and route reassignment | OPS routing methods before native task assignment |
| combat/loss events | MOOSE event handlers |
| BLUE knowledge | `INTEL`, `DETECTION`, `TARGET`, `PLAYERRECCE` |

### Navigation correction

Direct off-road navigation is not a general production default.

- road-capable vehicles use validated roads;
- steep, forested or off-road final legs use infantry;
- hybrid transport uses vehicle to a transfer point and infantry for the last leg;
- each group has source, destination, purpose and inventory transaction;
- no random contact groups are spawned solely to create activity.

### Representation correction

A fixed virtual/physical percentage is rejected.

```text
RepresentationPriority = ExposureScore + ExposureDebt + MissionCriticality
```

A minimum physical exposure floor guarantees genuine discovery opportunities. A movement may not pack while observed, tracked, attacked or within configured protection envelopes.

## Required review sequence

1. Freeze and catalogue current branches and accepted DCS evidence.
2. Review TM01 bootstrap, spawn and routing.
3. Review TM01 proxy, pack/unpack and relevance monitors.
4. Produce method-by-method MOOSE replacement matrix.
5. Review TM02 registry and planner.
6. Review TM02 execution, watchdogs and representation.
7. Mark tests retained, refactored, superseded or rejected.
8. Define successor milestones for sites, warehouses, construction, transport and HUMINT exposure.
9. Verify exact MOOSE methods against pinned source and matching documentation.
10. Obtain explicit project-owner approval for every retained non-MOOSE production mechanism.

## Preliminary successor milestones

```text
TM01R1  MOOSE scheduler and group-wrapper refactor
TM01R2  event-driven loss and engagement protection
TM01R3  adaptive exposure and production pack/unpack policy

TM02X1  site/candidate registry and infrastructure states
TM02X2  warehouse-backed personnel and supply transactions
TM02X3  MOOSE Astar movement planning and transport-mode selection
TM02X4  purposeful physical/hybrid transport execution
TM02X5  site construction, activation, abandonment and destruction
TM02X6  HUMINT/SIGINT exposure and BLUE mission generation
```

No current PR is authorized for merge by this document.
