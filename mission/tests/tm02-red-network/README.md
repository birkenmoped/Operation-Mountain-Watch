# TM02 RED network tests

This directory contains the staged TM02W production-network tests that follow the completed TM02V packet/proxy stage.

## Completed stage

```text
TM02W1 - RED Network Registry: DCS PASS
```

W1 result:

```text
results/2026-07-18-tm02w1-red-network-registry-v3-pass.md
```

W1 validates the representative RED registry, separate command and movement graphs, alternative paths, cross-area movement links and BLUE objective associations.

## Current stage

```text
TM02W2 - RED Source, Cost and Reservation Planning
```

TM02W2 version 2 is intentionally planner-only. It adds:

- personnel inventories at active logical nodes;
- guard floors, defensive targets and hard capacities;
- multiple candidate sources;
- weighted shortest paths over the W1 movement graph;
- source-depletion and packet-fragmentation penalties;
- transactional inbound and outbound reservations;
- guard-floor, overfill and accounting checks.

The real DCS network uses irregular site geometry. A non-nearest source selection is recorded but is not mandatory in DCS. The controlled Lua 5.1 harness explicitly requires and proves that the cost model can select a farther source when total cost is lower.

Version-1 DCS result:

```text
results/2026-07-18-tm02w2-source-cost-reservation-v1-fail.md
```

The version-1 planner reserved the complete deficit correctly but failed an overly strict geometry-dependent acceptance assertion. Version 2 corrects only that test boundary.

W2 does not yet spawn or move a proxy group. The next W2 increment will execute accepted reservation tasks using the TM02V proxy layer.

Implemented W2 files:

```text
config-tm02w2.lua
src/tm02w2.lua
expected/tm02w2-source-cost-reservation-acceptance.md
tools/test-tm02w2-static.lua
```

Build locally with:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\build-tm02w2-bundle.ps1
```

Generated local bundle:

```text
dist/TM02W2.lua
```

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
TM02W2 next increment - execute reserved tasks through TM02V proxies
TM02W3 - delayed reports and bounded command
TM02W4 - two-team attack, planned depletion and replenishment
TM02W5 - scenery-site destruction and replacement occupation
```
