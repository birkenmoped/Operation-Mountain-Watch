# TM02 RED network tests

This directory contains the staged TM02W production-network tests that follow the completed TM02V packet/proxy stage.

## Current stage

```text
TM02W1 – RED Network Registry
```

Implemented files:

```text
config-tm02w1.lua
src/tm02w1.lua
expected/tm02w1-dcs-mission-setup-and-acceptance.md
```

Build locally with:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\build-tm02w1-bundle.ps1
```

Generated local bundle:

```text
dist/TM02W1.lua
```

TM02W1 uses a representative test fixture with:

```text
11 RED locations
3 command areas: CENTRAL, LEFT and RIGHT
10 directed command links
17 bidirectional movement links
2 BLUE objective zones
```

The fixture size is not a production minimum or maximum.

The command graph and movement graph are deliberately separate. A RED site may report through one command area while personnel later move through another area when that route is cheaper or operationally preferable.

The ten existing TM02V personnel-strength templates remain unchanged. No Mission Editor route groups or route waypoints are required for W1.

W1 validates registry, command hierarchy, movement connectivity, alternative paths, cross-area movement links and BLUE objective associations. It does not move personnel, choose a source, issue orders or use scenery buildings yet.

Planned successors:

```text
TM02W2 – multiple sources and cost selection
TM02W3 – delayed reports and bounded command
TM02W4 – two-team attack, planned depletion and replenishment
TM02W5 – scenery-site destruction and replacement occupation
```
