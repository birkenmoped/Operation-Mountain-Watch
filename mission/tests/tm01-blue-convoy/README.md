# TM01 Blue Convoy Tests

TM01 contains the convoy development and regression line for Operation Mountain Watch.

## Current active increment: TM01M

TM01M is the clean MOOSE-native physical convoy baseline. It uses Mission Editor MSR drawings through MOOSE `PATHLINE`, road projection and connectors through MOOSE `COORDINATE`, individual road-aligned vehicle placement through `SPAWN:InitSetUnitAbsolutePositions()`, route assignment through `GROUP:Route()`, one shared MOOSE `SCHEDULER` for supervision and delayed silent cleanup through `GROUP:Destroy(false, 60)`.

The accepted single-convoy and five-convoy baselines are documented under:

```text
results/2026-07-26-tm01m-msr-pathline-v1-pass.md
results/2026-07-26-tm01m-five-convoy-50kph-pass.md
```

The current renamed-endpoint and cleanup regression is documented under:

```text
notes/2026-08-01-tm01m-msr-endpoint-renaming.md
expected/tm01m-moose-native-physical-acceptance.md
```

## Current configuration

```text
TM01M-moose-native-five-convoys-3
```

```text
5 simultaneous convoys
6 vehicles per convoy
30 total vehicles
50 km/h
On Road
1 shared Mission Editor template
6 unchanged internal Mission Editor PATHLINE objects
10 renamed Mission Editor start/target zones
60-second post-arrival dwell
```

## Current routes

```text
MSR HORSESHOE
MSR_HORSESHOE_START_BAGRAM
→ MSR_EAST_E03
→ MSR_HORSESHOE_E3_TARGET_KABUL

MSR ILLINOIS-E2
MSR_ILLINOIS_E2_START_KABUL
→ MSR_EAST_E02
→ MSR_ILLINOIS_E2_TARGET_JALALABAD

MSR ILLINOIS-E1
MSR_ILLINOIS_E1_START_TORKHAM
→ MSR_EAST_E01
→ MSR_ILLINOIS_E1_TARGET_JALALABAD

MSR CALIFORNIA-C1
MSR_CALIFORNIA-C1_START_JALALABAD
→ MSR_KUNAR_K01
→ MSR_CALIFORNIA-C1_TARGET_ASADABAD

MSR CALIFORNIA-C2/C3
MSR_CALIFORNIA-C2_START_ASADABAD
→ MSR_CAL_C01
→ MSR_CAL_C02
→ MSR_CALIFORNIA-C03_TARGET_FOB_BOSTIK
```

The internal PATHLINE names are retained because the Mission Editor objects themselves were not renamed. Only the start and target trigger-zone names changed.

## Build

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File ".\tools\build-tm01m-bundle.ps1"
```

After every rebuild, reselect `mission/tests/tm01-blue-convoy/dist/TM01M.lua` in the Mission Editor `DO SCRIPT FILE` action and save the mission. `vendor/moose/Moose.lua` must be loaded first. A previously embedded script inside a `.miz` is not updated automatically by building the repository bundle.

## Important

TM01B and TM01C remain historical comparison and evidence fixtures. TM01M does not load their proxy, caching, virtual movement, pack/unpack, reveal-window, watchdog, recovery or teleport architecture.
