# Kandahar Heliport Warehouse Increment

Status: `RUNTIME_PASS`

Structural source mission:

```text
OMW_Template_v4_Kandahar(3).miz
2,187,128 bytes
SHA-256: 15e63ef55f260ba35fb07bb4c99cc23df7193b595fbdd5be13bc4b8a9b0af0cc
```

Runtime acceptance mission:

```text
OMW_Template_v4_Kandahar(4).miz
2,183,450 bytes
SHA-256: 0732f929d4e35641c84bfb34bd75912692c3a1b7b7a0106847ce56e21aa5345c
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
BuilderVersion: KAF-HELIPORT-WAREHOUSE-NOSPAWN-1
Builder GitCommit: 6bdc92625e6fe92bc7b0c3b29bc27193c75bdfa7
```

Generated and accepted bundle:

```text
dist/OMW_AirOps_Kandahar_HeliWarehouse_Diagnostic.lua
SHA-256: ab7ed423057712f6af8de7617330c92e4fa65576294136c98638ac105dc9278a
```

Acceptance contract:

```text
expected/kandahar-heliport-warehouse-acceptance.md
```

Accepted result:

```text
results/2026-07-31-kandahar-heliport-warehouse-pass.md
```

Runtime values:

```text
Main Airbase: Kandahar / ID 7 / Airdrome
Heliport: Kandahar Heliport / ID 15 / Helipad
Main warehouse: WH_AIR_US_KANDAHAR / container_40ft / coalition 2
Heliport warehouse: WH_AIR_US_KANDAHAR_HELI / container_20ft / coalition 2
Heliport nearest TerminalID: 60
Heliport distance: 149.63 m
Main nearest TerminalID: 90
Main distance: 722.85 m
Heliport parking count: 86
Main parking count: 316
Result: PASS
```

The diagnostic remained read-only. It constructed no AIRWING or SQUADRON, spawned no asset, created no mission and changed no parking state.

The Heliport warehouse-name and missing-anchor blockers are closed. The Heliport AIRWING identifier, productive Army Aviation inventories, Safe-Parking policy and controlled-spawn acceptance remain unresolved.
