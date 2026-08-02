# TM01 Blue Convoy Tests

TM01 contains the convoy development and regression line for Operation Mountain Watch.

## Current active increment: TM01M

TM01M is the clean MOOSE-native physical convoy baseline. It uses Mission Editor MSR drawings through MOOSE `PATHLINE`, road projection and connectors through MOOSE `COORDINATE`, individual road-aligned vehicle placement through `SPAWN:InitSetUnitAbsolutePositions()`, route assignment through `GROUP:Route()`, one shared MOOSE `SCHEDULER` for supervision and delayed silent cleanup through `GROUP:Destroy(false, 60)`.

The accepted single-convoy and five-convoy baselines remain documented under:

```text
results/2026-07-26-tm01m-msr-pathline-v1-pass.md
results/2026-07-26-tm01m-five-convoy-50kph-pass.md
```

Those reports retain the former six-vehicle HMMWV-based test template as historical evidence of the exact tested state.

The current shared-node, seven-vehicle template and cleanup regression is documented under:

```text
expected/tm01m-moose-native-physical-acceptance.md
```

## Current configuration

```text
TM01M-moose-native-five-convoys-5
```

```text
5 simultaneous convoys
7 vehicles per convoy
35 total vehicles
50 km/h
On Road
active template: TPL_BLUE_CONVOY_STANDARD_07
6 unchanged internal Mission Editor PATHLINE objects
6 shared OMW_LOG_NODE locations
60-second post-arrival dwell
```

## Active convoy template

```text
TPL_BLUE_CONVOY_STANDARD_07
```

| Position | Vehicle | Role |
|---:|---|---|
| 1 | M-ATV | Lead Security |
| 2 | M1083 | Cargo 1 |
| 3 | MaxxPro | Convoy Commander / C2 |
| 4 | M1083 | Cargo 2 |
| 5 | MaxxPro | Mid-column Security / Support |
| 6 | M1083 | Cargo 3 |
| 7 | M-ATV | Rear Security |

The additional library template is present for a later randomized-template increment:

```text
TPL_BLUE_CONVOY_LIGHT_06
```

MOOSE 2.9.18 provides `SPAWN:InitRandomizeTemplate()`. Random selection is not active in configuration version 5 because the two variants have different unit counts and require a dedicated runtime and DCS regression. Version 5 deliberately establishes the seven-vehicle standard template first.

The obsolete template must be removed from the current Mission Editor template library:

```text
TPL_TEST_BLUE_CONVOY_STANDARD_01
```

## Current routes

```text
MSR HORSESHOE
OMW_LOG_NODE_BAGRAM
→ MSR_EAST_E03
→ OMW_LOG_NODE_KABUL

MSR ILLINOIS-E2
OMW_LOG_NODE_KABUL
→ MSR_EAST_E02
→ OMW_LOG_NODE_JALALABAD

MSR ILLINOIS-E1
OMW_LOG_NODE_TORKHAM
→ MSR_EAST_E01
→ OMW_LOG_NODE_JALALABAD

MSR CALIFORNIA-C1
OMW_LOG_NODE_JALALABAD
→ MSR_KUNAR_K01
→ OMW_LOG_NODE_ASADABAD

MSR CALIFORNIA-C2/C3
OMW_LOG_NODE_ASADABAD
→ MSR_CAL_C01
→ MSR_CAL_C02
→ OMW_LOG_NODE_BOSTICK
```

A location node is intentionally reusable as both origin and destination. Kabul, Jalalabad and Asadabad therefore no longer require separate start and target zones. The internal PATHLINE names remain unchanged because the Mission Editor route drawings themselves were not renamed.

## Build

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File ".\tools\build-tm01m-bundle.ps1"
```

After every rebuild, reselect `mission/tests/tm01-blue-convoy/dist/TM01M.lua` in the Mission Editor `DO SCRIPT FILE` action and save the mission. `vendor/moose/Moose.lua` must be loaded first. A previously embedded script inside a `.miz` is not updated automatically by building the repository bundle.

## Important

TM01B and TM01C remain historical comparison and evidence fixtures. TM01M does not load their proxy, caching, virtual movement, pack/unpack, reveal-window, watchdog, recovery or teleport architecture.
