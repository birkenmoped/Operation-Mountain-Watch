# Kandahar Dual-Airbase No-Spawn Diagnostic – Acceptance

## Scope

This test validates runtime discovery and logging only. A PASS does not authorize an AIRWING start or any asset activation.

## Mission and bundle prerequisites

```text
Mission: OMW_Template_v4_Kandahar(1).miz
Mission SHA-256: 07cc90b18bf3a09fee8c650cb9f1668c9ec6c2412a37be5f005642d216deeb8a
Builder: tools/build-kandahar-air-operations-diagnostic.ps1
BuilderVersion: KAF-DUAL-AIRBASE-NOSPAWN-1
Bundle: mission/tests/kandahar-air-operations/dist/OMW_AirOps_Kandahar_Diagnostic.lua
```

The diagnostic bundle must be loaded after `Moose.lua`. Existing Jalalabad, TM01M and Bagram triggers may remain in their current order. No other Kandahar runtime script may be present.

## Required runtime duration

Run the mission for at least 20 seconds after mission start.

## Required configuration marker

```text
[OMW][AirOps.KAF.Diagnostic] CONFIGURED
```

The marker must include:

```text
sourceMission=OMW_Template_v4_Kandahar(1).miz
sourceSha256=07cc90b18bf3a09fee8c650cb9f1668c9ec6c2412a37be5f005642d216deeb8a
expectedMooseSha256=e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
noSpawn=true
```

## Object-contract acceptance

Required airbase markers:

```text
AIRBASE_OK key=Main name=Kandahar id=7
AIRBASE_OK key=Heliport name=Kandahar Heliport id=15
```

Required warehouse markers:

```text
WAREHOUSE_OK role=MAIN name=WH_AIR_US_KANDAHAR type=container_40ft coalition=2
BLOCKER code=HELIPORT_WAREHOUSE_NAME_UNAPPROVED
BLOCKER code=HELIPORT_WAREHOUSE_ANCHOR_MISSING
```

Required object totals:

```text
10 CLIENT_OK markers
10 TEMPLATE_BEGIN markers
10 TEMPLATE_END markers
5 OBSOLETE_TEMPLATE_ABSENT markers
STATIC_SUMMARY label=US_AIR total=47
STATIC_SUMMARY label=UN_AIR total=6
ZONE_OK name=ZONE_AIR_US_KAF_CSAR_UNLOAD
STATIC_OK role=CSAR_MEDIC name=STATIC_GND_US_KAF_M113_MEDIC
```

The template-unit markers must include raw payload serialization for every template unit.

Required object-audit result:

```text
[OMW][AirOps.KAF.ObjectAudit] RESULT: PASS objectContract=true runtimeReady=false
```

It must also contain:

```text
noSpawn=true
HELIPORT_AIRWING_NAME_UNAPPROVED
HELIPORT_WAREHOUSE_NAME_UNAPPROVED
HELIPORT_WAREHOUSE_ANCHOR_MISSING
NON_A10_LOGICAL_INVENTORIES_UNDECIDED
ISR_PAYLOAD_DECISIONS_OPEN
```

## Parking diagnostic acceptance

Required begin markers:

```text
AIRBASE_BEGIN key=Main
AIRBASE_BEGIN key=Heliport
```

For every parking node, one `SPOT` marker must be emitted with:

```text
TerminalID
TerminalID0
TerminalType
Free
TOAC
OccupiedBy
DistToRwy
coordinates
```

Required association markers:

```text
10 CLIENT_NEAREST markers
47 STATIC_NEAREST markers
```

Required final marker:

```text
[OMW][AirOps.KAF.ParkingDump] RESULT: PASS diagnosticComplete=true objectContract=true
```

The final marker must include non-zero `mainParking` and `heliportParking` counts plus:

```text
noBlacklistMutation=true
noSpawn=true
runtimeReady=false
```

## Failure criteria

The test fails if any of the following occur:

- `RESULT: FAIL` under a Kandahar diagnostic tag;
- any `VIOLATION` marker;
- missing or wrong native airbase ID;
- missing Main warehouse anchor;
- unexpected Kandahar runtime namespace;
- missing client or template;
- wrong template group size or type;
- template not marked Late Activation;
- template marked Uncontrolled;
- unexpected obsolete template present;
- US or UN static count mismatch;
- missing CSAR unload zone or M113 medic static;
- missing parking table for either airbase;
- a Kandahar diagnostic source creates an asset or changes a blacklist;
- Lua runtime error, timer error or MOOSE error caused by the diagnostic.

## Evidence to return

Standard handoff:

```text
Saved Games\DCS...\Logs\dcs.log
```

The `.miz` is required only if:

- the embedded bundle cannot be confirmed;
- object names differ from the documented mission;
- the runtime result contradicts the structural audit;
- a corrected Mission Editor version is saved.
