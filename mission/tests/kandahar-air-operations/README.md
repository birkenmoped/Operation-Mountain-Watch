# Kandahar Air Operations – Dual-Airbase No-Spawn Diagnostic

Status: `IMPLEMENTED_UNVALIDATED`

This test family performs the first runtime inspection of the current Kandahar Mission Editor baseline without constructing an AIRWING, registering SQUADRON inventory, mutating parking, spawning aircraft, or creating missions.

## Source mission contract

```text
OMW_Template_v4_Kandahar(1).miz
Size: 2,180,824 bytes
SHA-256: 07cc90b18bf3a09fee8c650cb9f1668c9ec6c2412a37be5f005642d216deeb8a
```

Embedded MOOSE contract:

```text
MOOSE 2.9.18 pinned file hash
e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## Purpose

The diagnostic proves the runtime-visible object contract for:

```text
AIRBASE.Afghanistan.Kandahar          / expected ID 7
AIRBASE.Afghanistan.Kandahar_Heliport / expected ID 15
WH_AIR_US_KANDAHAR
10 client groups
10 Late-Activation template groups
47 US aircraft statics
6 UN aircraft statics
ZONE_AIR_US_KAF_CSAR_UNLOAD
all parking and helipad nodes of both native airbases
```

It also records raw template payload tables and the nearest runtime parking node for each client and US aircraft static.

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

## Expected result

The current mission is expected to complete the diagnostic successfully while remaining operationally blocked:

```text
objectContract=true
parking diagnostic complete
runtimeReady=false
main warehouse present
heliport AIRWING name unapproved
heliport warehouse name unapproved
heliport warehouse anchor missing
non-A-10 inventories undecided
ISR payload decisions open
noSpawn=true
```

Detailed acceptance criteria:

```text
expected/kandahar-dual-airbase-no-spawn-acceptance.md
```

## Later increments

Not part of this test:

- second Heliport warehouse placement and naming;
- AIRWING construction;
- SQUADRON registration;
- logical inventory configuration;
- Safe Parking allow-/blocklists;
- controlled spawn;
- AUFTRAG;
- OPSTRANSPORT;
- CSAR or MEDEVAC execution;
- ISR execution;
- loss persistence.
