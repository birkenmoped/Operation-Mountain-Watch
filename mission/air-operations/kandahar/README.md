# OMW Kandahar AirOps foundation

Status: `SMOKE_RETEST_REQUIRED_AFTER_BUILDER_ASSEMBLY_FIX`

## Purpose

This directory provides the normalized Kandahar AirOps foundation after the isolated registration, parking and controlled-spawn tests.

Generated mission file:

```text
mission/air-operations/dist/OMW_AIROPS_KANDAHAR.lua
```

The file contains the accepted foundation only:

- two explicitly bound AIRWING instances;
- nine physical SQUADRON instances;
- 112 registered physical airframes;
- six deferred MC-12 airframes without physical DCS representation;
- Main and Heliport client/static parking exclusions;
- Safe Parking for both AIRWINGs;
- MQ-1 initial-spawn pool restricted to the currently available positions from G01-G08;
- MQ-9 initial-spawn pool restricted to the currently available positions from G09-G11;
- synchronization of those filtered UAV pools to the registered Warehouse asset records;
- both AIRWINGs started and exposed under `OMW.AirOps.Kandahar`.

## Deliberately absent

```text
AUFTRAG
payload registration
OPSTRANSPORT
COMMANDER
CHIEF
Warehouse self-requests
direct SPAWN calls
test missions
taxi/takeoff/landing callbacks
post-landing parking workaround
```

The file therefore creates no mission and requests no aircraft by itself.

## Build

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch

git switch agent/kandahar-airwing-baseline-contract
git pull --ff-only origin agent/kandahar-airwing-baseline-contract

powershell -ExecutionPolicy Bypass -File `
  .\tools\build-omw-airops-kandahar.ps1
```

Expected builder version:

```text
OMW-AIROPS-KANDAHAR-FOUNDATION-2
```

Expected assembly result:

```text
Assembly: PASS (explicit string list; no nested PowerShell object arrays)
```

Builder version 1 assembled the source-file pipeline as a nested PowerShell object array. The generated Lua therefore contained an object-type string and DCS rejected it at line 13 with:

```text
unexpected symbol near ']'
```

Version 2 uses an explicit `List[string]`, appends every source as a string, rejects `System.Object[]` and related object-string corruption tokens, verifies all required tokens after assembly, writes the file and reads it back for equality.

## Mission Editor load order

```text
1. Moose.lua
2. OMW_AIROPS_KANDAHAR.lua
```

Do not load any Kandahar calibration, controlled-spawn, parking-matrix or return-parking test bundle in parallel.

## Expected normalized runtime result

After approximately 32 seconds:

```text
[OMW][AirOps.KAF.Foundation] RESULT: READY
airwings=2
squadrons=9
registeredAirframes=112
deferredMC12=6
mainRunning=true
heliportRunning=true
missionsCreated=0
payloadsRegistered=0
commanderAttached=false
transportCreated=false
directSpawnRequested=false
uavInitialSpawnRestricted=true
uavFinalParkingRestricted=false
```

No dynamic aircraft should appear because the foundation does not create or assign a mission and does not issue a Warehouse request.

## Runtime API exposed to later modules

```lua
OMW.AirOps.Kandahar.Airwings.Main
OMW.AirOps.Kandahar.Airwings.Heliport
OMW.AirOps.Kandahar.Squadrons
OMW.AirOps.Kandahar.Parking.Main
OMW.AirOps.Kandahar.Parking.Heliport
OMW.AirOps.Kandahar.UAVParking.MQ1
OMW.AirOps.Kandahar.UAVParking.MQ9
OMW.AirOps.Kandahar.Inventory
OMW.AirOps.Kandahar.KnownLimitations
```

Later mission providers must consume these objects instead of constructing duplicate AIRWING or SQUADRON instances.

## Accepted versus open scope

Accepted foundation components:

```text
AIRWING construction and explicit airbase binding
SQUADRON construction, grouping and inventory registration
Main/Heliport Safe Parking and client/static exclusions
MQ-1/MQ-9 type-specific initial-spawn parking
registered UAV asset parking synchronization
controlled initial UAV spawn
```

Final normalized bundle acceptance remains pending one successful version-2 smoke run.

Still open:

```text
post-landing UAV stand selection within the type-specific G pool
Warehouse stock return/reconciliation after landing
tactical AUFTRAG profiles
payload catalogue
OPSTRANSPORT
COMMANDER integration
persistent loss/recovery state
MC-12 physical representation
```
