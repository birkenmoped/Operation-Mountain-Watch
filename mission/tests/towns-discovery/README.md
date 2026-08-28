---
document_id: OMW-TEST-TOWNS-DISCOVERY
status: HISTORICAL_TEST_FIXTURE
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - historical Afghanistan TOWNS discovery fixture
not_authoritative_for:
  - production settlement classification
  - current DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by: []
source_branch: agent/towns-discovery
source_commit: e10cb1c0a4979ab7b178b51144813b0e55cc9506
validated_in_dcs: false
---

# OMW TOWNS Discovery 01

Development fixture for inventorying the Afghanistan terrain `towns.lua` through MOOSE `TOWNS`. It is preserved as historical evidence only; it is not a production settlement-classification architecture.

## MOOSE-first scope

The pinned MOOSE source contains `Navigation.Towns` and `TOWNS:NewFromFile(FileName)`. The fixture therefore uses MOOSE as the primary town-data interface. Native `land.*`, `io`, and `lfs` access in this fixture is development/evidence-only and is not approved for production use.

## Build the mission bundle

From the repository root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\tools\build-towns-discovery-bundle.ps1
```

Output:

```text
mission\tests\towns-discovery\dist\OMW_TOWNS_DISCOVERY.lua
```

The generated file contains both:

- `mission/tests/towns-discovery/config.lua`
- `src/dev/world-data/towns_discovery.lua`

Do not edit the generated bundle directly. Change the source or configuration and rebuild it.

## Optional fixed towns.lua path

Automatic path discovery is used by default. To embed the exact local terrain file path into the generated bundle:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\tools\build-towns-discovery-bundle.ps1 `
  -TownsFile "C:\Program Files\Eagle Dynamics\DCS World\Mods\terrains\Afghanistan\Map\towns.lua"
```

Steam example:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\tools\build-towns-discovery-bundle.ps1 `
  -TownsFile "C:\Program Files (x86)\Steam\steamapps\common\DCSWorld\Mods\terrains\Afghanistan\Map\towns.lua"
```

## Mission Editor integration

Create one `MISSION START` trigger with these actions in this exact order:

1. `DO SCRIPT FILE` -> current `Moose.lua`
2. `DO SCRIPT FILE` -> `mission/tests/towns-discovery/dist/OMW_TOWNS_DISCOVERY.lua`

No third script action is required because the generated bundle already contains the discovery configuration.

MOOSE must contain `Navigation.Towns`. If it does not, the mission reports `MOOSE TOWNS fehlt` and stops the discovery step.

## Minimal mission content

Use the Afghanistan map and add one `Player` or `Client` aircraft so the mission can be entered and the F10 map inspected. No ground units, trigger zones, routes, targets, or static objects are required.

Recommended mission file name:

```text
OMW_DEV_AF_TOWNS_DISCOVERY_01.miz
```

## Mission scripting access

The historical discovery step reads the DCS terrain file and can write development exports. If this fixture is intentionally rerun in a controlled development installation, the required `io`/`lfs` access must be configured manually by the operator. Operation Mountain Watch does not automatically modify `MissionScripting.lua`.

## Expected runtime output

F10 map:

- one marker for each loaded town reference
- menu `F10 Other -> OMW World Data`

Saved Games output:

```text
Saved Games\DCS\Logs\OMW-Towns-Afghanistan.csv
Saved Games\DCS\Logs\OMW-Towns-Afghanistan-fields.csv
Saved Games\DCS\Logs\OMW-Towns-Afghanistan.lua
Saved Games\DCS\Logs\OMW-Towns-Afghanistan-summary.txt
```

Diagnostic fallback:

```text
Saved Games\DCS\Logs\dcs.log
```

Search for:

```text
[OMW-TOWNS]
```

## Acceptance boundary

Merging this fixture records source-reviewed historical tooling only. No current DCS PASS, `VALIDATED` status, or production Native-DCS exception is claimed.
