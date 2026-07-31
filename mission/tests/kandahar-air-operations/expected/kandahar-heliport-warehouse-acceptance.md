# Kandahar Heliport Warehouse No-Spawn Diagnostic – Acceptance

## Scope

This test validates only the new Kandahar Heliport warehouse anchor. It does not authorize AIRWING or SQUADRON construction.

## Mission and builder

```text
Mission: OMW_Template_v4_Kandahar(3).miz
Size: 2,187,128 bytes
Mission SHA-256: 15e63ef55f260ba35fb07bb4c99cc23df7193b595fbdd5be13bc4b8a9b0af0cc

Builder: tools/build-kandahar-heliport-warehouse-diagnostic.ps1
BuilderVersion: KAF-HELIPORT-WAREHOUSE-NOSPAWN-1
Bundle: mission/tests/kandahar-air-operations/dist/OMW_AirOps_Kandahar_HeliWarehouse_Diagnostic.lua
```

The bundle must be loaded after `Moose.lua`. It may replace the previously embedded Kandahar no-spawn diagnostic for this isolated test.

## Required runtime duration

Run for at least 15 seconds after mission start.

## Required markers

```text
[OMW][AirOps.KAF.HeliWarehouse] BEGIN noSpawn=true noParkingMutation=true runtimeReady=false

AIRBASE_OK role=MAIN name=Kandahar id=7 category=Airdrome
AIRBASE_OK role=HELIPORT name=Kandahar Heliport id=15 category=Helipad

WAREHOUSE_OK role=MAIN name=WH_AIR_US_KANDAHAR type=container_40ft coalition=2
WAREHOUSE_OK role=HELIPORT name=WH_AIR_US_KANDAHAR_HELI type=container_20ft coalition=2

ASSOCIATION_OK warehouse=WH_AIR_US_KANDAHAR_HELI
```

The association marker must include:

```text
heliportTerminalID
heliportDistance
mainTerminalID
mainDistance
heliportParking
mainParking
```

Expected geometry from the prior accepted parking table is approximately:

```text
nearest Heliport TerminalID: 60
Heliport distance: about 150 m
nearest Main terminal: about 723 m away
```

Small coordinate differences are acceptable. The runtime contract, not the structural estimate, is authoritative.

## Required final marker

```text
[OMW][AirOps.KAF.HeliWarehouse] RESULT: PASS
```

It must include:

```text
warehouseContract=true
mainWarehouse=true
heliportWarehouse=true
heliportWarehouseName=WH_AIR_US_KANDAHAR_HELI
noSpawn=true
noParkingMutation=true
runtimeReady=false
remainingBlocker=HELIPORT_AIRWING_NAME_UNAPPROVED
```

## Failure criteria

The test fails on any of the following:

- missing or duplicate `WH_AIR_US_KANDAHAR_HELI`;
- Heliport warehouse is not a STATIC object;
- wrong type; expected `container_20ft`;
- wrong coalition; expected Blue / 2;
- Kandahar Main is not ID 7;
- Kandahar Heliport is not ID 15;
- no parking table for either native airbase;
- warehouse is within 25 m of a Heliport parking node;
- warehouse is more than 500 m from every Heliport parking node;
- warehouse is closer to Main-Airfield parking than Heliport parking;
- any Kandahar HeliWarehouse `RESULT: FAIL` marker;
- Lua, timer or MOOSE error caused by this diagnostic;
- any asset spawn, parking mutation or mission creation.

## Evidence to return

```text
Saved Games\DCS...\Logs\dcs.log
```

The `.miz` is not required again unless the runtime result contradicts the structural audit.