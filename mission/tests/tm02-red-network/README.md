# TM02 RED network tests

This directory contains the staged TM02W production-network tests that follow the completed TM02V packet/proxy stage.

## Completed stages

```text
TM02W1 - RED Network Registry: DCS PASS
TM02W2 planner - RED Source, Cost and Reservation Planning v2: DCS PASS
```

Result records:

```text
results/2026-07-18-tm02w1-red-network-registry-v3-pass.md
results/2026-07-18-tm02w2-source-cost-reservation-v1-fail.md
results/2026-07-18-tm02w2-source-cost-reservation-v2-pass.md
```

W1 validates the representative RED registry, separate command and movement graphs, alternative paths, cross-area movement links and BLUE objective associations.

The accepted TM02W2 planner validates:

- personnel inventories at active logical nodes;
- guard floors, defensive targets and hard capacities;
- multiple candidate sources;
- weighted shortest paths over the W1 movement graph;
- source-depletion and packet-fragmentation penalties;
- transactional inbound and outbound reservations;
- guard-floor, overfill and accounting checks;
- deterministic reset and replan.

The real DCS network uses irregular site geometry. A non-nearest source selection is recorded but is not mandatory in DCS. The controlled Lua 5.1 harness explicitly requires and proves that the cost model can select a farther source when total cost is lower.

The accepted planner is intentionally movement-free:

```text
movementExecuted=false
```

## Current stage

```text
TM02W2 execution - execute accepted reservation tasks through independent RED proxies
```

This increment must preserve the accepted W2 plan while physically executing each task. It remains separate from delayed reports and bounded commander cycles, which belong to W3.

## Shared fixture

W1 and W2 use the same Mission Editor network fixture:

```text
11 RED locations
3 command areas: CENTRAL, LEFT and RIGHT
10 directed command links
17 bidirectional movement links
2 BLUE objective zones
10 existing TM02V personnel-strength templates
0 route groups
0 route waypoints
```

The fixture size is not a production minimum or maximum. The command graph and movement graph remain separate. A RED site may report through one command area while personnel move through another area when that route is cheaper or operationally preferable.

## Planned successors

```text
TM02W2 execution - reserved-task proxy movement and accounting
TM02W3 - delayed reports and bounded command
TM02W4 - two-team attack, planned depletion and replenishment
TM02W5 - scenery-site destruction and replacement occupation
```
