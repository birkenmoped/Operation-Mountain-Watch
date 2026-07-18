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

TM02W1 registers Mission Editor sites and routes, validates graph connectivity and verifies that the test topology is not restricted to a tree. It does not move personnel, choose a source, issue orders or use scenery buildings yet.

Planned successors:

```text
TM02W2 – multiple sources and cost selection
TM02W3 – delayed reports and bounded command
TM02W4 – two-team attack, planned depletion and replenishment
TM02W5 – scenery-site destruction and replacement occupation
```
