# Kandahar Air Operations – Dual-Airbase No-Spawn Diagnostic

Status: `DUAL_AIRBASE_NOSPAWN_PASS`

This test family performs the first runtime inspection of the current Kandahar Mission Editor baseline without constructing an AIRWING, registering SQUADRON inventory, mutating parking, spawning aircraft, or creating missions.

## Source mission contract

Underlying authoring source:

```text
OMW_Template_v4_Kandahar(1).miz
Size: 2,180,824 bytes
SHA-256: 07cc90b18bf3a09fee8c650cb9f1668c9ec6c2412a37be5f005642d216deeb8a
```

Accepted test artifact after diagnostic embedding:

```text
OMW_Template_v4_Kandahar(2).miz
Size: 2,187,049 bytes
SHA-256: 2d790ec62639037802200c6a8bfacd2a6ab6a2c8f44d8d4d8f64add3717aed81
```

Embedded MOOSE contract:

```text
MOOSE 2.9.18 pinned file hash
e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## Purpose

The diagnostic proves the runtime-visible object contract for:

```text
AIRBASE.Afghanistan.Kandahar          / ID 7
AIRBASE.Afghanistan.Kandahar_Heliport / ID 15
WH_AIR_US_KANDAHAR
10 client groups
10 Late-Activation template groups
47 US aircraft statics
6 UN aircraft statics
ZONE_AIR_US_KAF_CSAR_UNLOAD
all parking and helipad nodes of both native airbases
```

It also records raw template payload tables and the nearest runtime parking node for each client and US aircraft static.

## Accepted result

```text
objectContract=true
runtimeReady=false
mainParking=316
heliportParking=86
noBlacklistMutation=true
noSpawn=true
```

Accepted runtime quantities:

```text
10 CLIENT_OK
10 TEMPLATE_BEGIN
10 TEMPLATE_END
5 OBSOLETE_TEMPLATE_ABSENT
47 US aircraft statics
6 UN aircraft statics
10 CLIENT_NEAREST
47 STATIC_NEAREST
```

Binding client TerminalIDs:

```text
Kandahar Main:
282 CLIENT_US_KAF_A10C_01
287 CLIENT_US_KAF_A10C_02
294 CLIENT_US_KAF_C130_01
 92 CLIENT_US_KAF_C130_02

Kandahar Heliport:
30 CLIENT_US_KAF_AH64D_01
19 CLIENT_US_KAF_AH64D_02
80 CLIENT_US_KAF_OH58D_01
23 CLIENT_US_KAF_OH58D_02
 4 CLIENT_US_KAF_CH47F_01
47 CLIENT_US_KAF_CH47F_02
```

Parking classes:

```text
Kandahar Main:
316 total
257 type 104
 34 type 40
 25 type 72

Kandahar Heliport:
86 total
86 type 40
```

Full result:

```text
results/2026-07-31-kandahar-dual-airbase-no-spawn-pass.md
```

## Explicit no-spawn boundary

The source files do not:

- construct an AIRWING;
- construct a SQUADRON;
- create SPAWN objects;
- create AUFTRAG or OPSTRANSPORT objects;
- set parking blacklists;
- reserve parking;
- start assets;
- mutate campaign inventory.

The build script rejects source bundles containing the corresponding forbidden constructor or blacklist tokens.

## Runtime source files

```text
src/01-kandahar-diagnostic-bootstrap.lua
src/02-kandahar-object-contract-audit.lua
src/03-kandahar-dual-airbase-parking-dump.lua
```

## Builder

```text
tools/build-kandahar-air-operations-diagnostic.ps1
```

Generated bundle:

```text
mission/tests/kandahar-air-operations/dist/OMW_AirOps_Kandahar_Diagnostic.lua
```

Builder version:

```text
KAF-DUAL-AIRBASE-NOSPAWN-1
```

Detailed acceptance criteria:

```text
expected/kandahar-dual-airbase-no-spawn-acceptance.md
```

## Remaining architecture blockers

Expected blockers remain:

```text
heliport AIRWING name unapproved
heliport warehouse name unapproved
heliport warehouse anchor missing
non-A-10 inventories undecided
ISR payload decisions open
OH-58D period-correct payload approval open
```

These blockers prevent productive AIRWING/SQUADRON registration but do not invalidate the accepted diagnostic.

## Later increments

Not yet accepted:

- second Heliport warehouse placement and naming;
- final Safe Parking allow-/blocklists;
- AIRWING construction;
- SQUADRON registration;
- logical inventory configuration;
- controlled spawn;
- AUFTRAG;
- OPSTRANSPORT;
- CSAR or MEDEVAC execution;
- ISR execution;
- loss persistence.
