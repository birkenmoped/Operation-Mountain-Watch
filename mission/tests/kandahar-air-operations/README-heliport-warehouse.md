# Kandahar Heliport Warehouse Increment

Status: `IMPLEMENTED_UNVALIDATED`

Source mission:

```text
OMW_Template_v4_Kandahar(3).miz
2,187,128 bytes
SHA-256: 15e63ef55f260ba35fb07bb4c99cc23df7193b595fbdd5be13bc4b8a9b0af0cc
```

Binding Heliport warehouse:

```text
WH_AIR_US_KANDAHAR_HELI
DCS type: container_20ft
Native airbase: AIRBASE.Afghanistan.Kandahar_Heliport / ID 15
```

Diagnostic source:

```text
src/04-kandahar-heliport-warehouse-audit.lua
```

Builder:

```text
tools/build-kandahar-heliport-warehouse-diagnostic.ps1
```

Generated bundle:

```text
dist/OMW_AirOps_Kandahar_HeliWarehouse_Diagnostic.lua
```

Acceptance:

```text
expected/kandahar-heliport-warehouse-acceptance.md
```

The diagnostic is read-only. It validates both native airbases, both warehouse anchors, exact static count, type, coalition and geometric assignment to the Heliport parking table. It creates no AIRWING, SQUADRON, asset, mission or parking mutation.

The Heliport AIRWING name and all productive Army Aviation inventories remain unresolved after this increment.