# Kandahar Heliport Warehouse No-Spawn Diagnostic – PASS

Date: 2026-07-31

Status: `PASS`

## Mission identity

```text
File: OMW_Template_v4_Kandahar(4).miz
Size: 2,183,450 bytes
SHA-256: 0732f929d4e35641c84bfb34bd75912692c3a1b7b7a0106847ce56e21aa5345c
```

The mission embeds:

```text
Bundle: OMW_AirOps_Kandahar_HeliWarehouse_Diagnostic.lua
Bundle SHA-256: ab7ed423057712f6af8de7617330c92e4fa65576294136c98638ac105dc9278a
BuilderVersion: KAF-HELIPORT-WAREHOUSE-NOSPAWN-1
Builder GitCommit: 6bdc92625e6fe92bc7b0c3b29bc27193c75bdfa7
SourceMission: OMW_Template_v4_Kandahar(3).miz
SourceMissionSha256: 15e63ef55f260ba35fb07bb4c99cc23df7193b595fbdd5be13bc4b8a9b0af0cc
ExpectedMooseSha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

The embedded MOOSE resource has the expected SHA-256:

```text
e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## Mission delta from revision (3)

The Mission Editor object contract is unchanged between revisions `(3)` and `(4)`:

```text
1,576 groupId entries in both missions
1,615 unitId entries in both missions
identical named-object multiset
identical group-ID set
identical unit-ID set
```

Revision `(4)` replaces the previously embedded broad Kandahar diagnostic with the isolated Heliport warehouse diagnostic. The archive contains:

```text
ResKey_Action_99 = OMW_AirOps_Kandahar_HeliWarehouse_Diagnostic.lua
```

The following embedded resources remain byte-identical to revision `(3)`:

```text
Moose.lua
TM01M.lua
OMW_AirOps_Jalalabad.lua
OMW_AirOps_Bagram.lua
warehouses
options
theatre
```

## Runtime result

Required begin marker observed:

```text
[OMW][AirOps.KAF.HeliWarehouse] BEGIN noSpawn=true noParkingMutation=true runtimeReady=false
```

Both native airbases resolved correctly:

```text
AIRBASE_OK role=MAIN name=Kandahar id=7 category=Airdrome
AIRBASE_OK role=HELIPORT name=Kandahar Heliport id=15 category=Helipad
```

Both warehouse anchors resolved exactly once with the required type and coalition:

```text
WAREHOUSE_OK role=MAIN name=WH_AIR_US_KANDAHAR type=container_40ft coalition=2
WAREHOUSE_OK role=HELIPORT name=WH_AIR_US_KANDAHAR_HELI type=container_20ft coalition=2
```

Runtime coordinates:

```text
Main warehouse:
x=-270272.8 y=1013.3 z=-30290.2

Heliport warehouse:
x=-269017.4 y=1016.0 z=-30083.8
```

Runtime association:

```text
Heliport nearest TerminalID: 60
Heliport TerminalType: 40
Heliport distance: 149.63 m
Heliport parking count: 86

Main nearest TerminalID: 90
Main TerminalType: 72
Main distance: 722.85 m
Main parking count: 316
```

The geometric result confirms that `WH_AIR_US_KANDAHAR_HELI` belongs to Kandahar Heliport, is not positioned on a parking node, and is substantially farther from Kandahar Main parking.

Required final marker observed:

```text
[OMW][AirOps.KAF.HeliWarehouse] RESULT: PASS warehouseContract=true mainWarehouse=true heliportWarehouse=true heliportWarehouseName=WH_AIR_US_KANDAHAR_HELI heliportNearestTerminalID=60 heliportDistance=149.63 noSpawn=true noParkingMutation=true runtimeReady=false remainingBlocker=HELIPORT_AIRWING_NAME_UNAPPROVED
```

## Negative checks

```text
0 Kandahar HeliWarehouse RESULT: FAIL
0 Kandahar HeliWarehouse violations
0 Lua, timer or MOOSE errors caused by this diagnostic
0 AIRWING constructions
0 SQUADRON registrations
0 asset spawns
0 AUFTRAG or OPSTRANSPORT creation
0 parking mutations
```

The returned debrief contains no evidence contradicting the diagnostic no-spawn boundary.

## External and pre-existing errors

The log contains errors unrelated to the Kandahar warehouse diagnostic, including:

```text
A-10C_2 corrupt damage model
OH58D corrupt damage model
several DCS/module texture and ATC warnings
bhHook.lua:168 attempt to index upvalue 'tcp' (a nil value) during shutdown
```

These occur outside the diagnostic contract and do not invalidate the warehouse PASS. The OH-58D/module errors remain relevant for later controlled-spawn testing.

## Accepted contract

The following is now runtime-validated and binding:

```text
Kandahar Main Airfield
AIRBASE.Afghanistan.Kandahar
DCS airbase ID 7
Warehouse: WH_AIR_US_KANDAHAR
Type: container_40ft

Kandahar Heliport / Mustang Ramp
AIRBASE.Afghanistan.Kandahar_Heliport
DCS airbase ID 15
Warehouse: WH_AIR_US_KANDAHAR_HELI
Type: container_20ft
Nearest runtime TerminalID: 60
Warehouse-to-terminal distance: 149.63 m
```

## Remaining blockers

```text
Kandahar Heliport AIRWING identifier
regional Kandahar/RC-South Army Aviation parent inventory
Tarinkot and other forward-detachment deductions
productive AH-64D, OH-58D, CH-47F and UH-60A inventories
OH-58D APKWS period decision
Safe-Parking allow-/blocklists
controlled-spawn acceptance
```

No AIRWING start or SQUADRON inventory is authorized by this PASS alone.
