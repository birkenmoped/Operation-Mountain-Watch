# OMW TOWNS Discovery 01

Development mission step for inventorying the Afghanistan terrain `towns.lua` through MOOSE `TOWNS`.

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

The discovery step reads the DCS terrain file and writes development exports. The local development installation therefore requires the relevant `MissionScripting.lua` restrictions for `io` and `lfs` to be disabled.

Keep a backup of `MissionScripting.lua` and use this only in the controlled development environment.

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
