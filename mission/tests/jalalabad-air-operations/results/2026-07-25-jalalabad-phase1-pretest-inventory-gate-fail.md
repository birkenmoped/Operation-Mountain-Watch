# Jalalabad Phase 1 – pretest inventory-gate failure

Date: 2026-07-25  
Evidence: `dcs(64).log`, `debrief(21).log`  
Result: **FAIL BEFORE TEST START / ROOT CAUSE CORRECTED / DCS RETEST PENDING**

## Observed behavior

The mission loaded normally and the Jalalabad baseline reached `OPERATIONAL`.

The following checks passed:

```text
parking pools
runtime-name contract
package contract
OH-58D squadron construction
AH-64D squadron construction
UH-60 squadron construction
CH-47 squadron construction
static parking reservations
Mission Editor object validation
Client parking resolution
AIRWING start
COMMANDER start
F10 menu creation
```

The F10 package menu reported `READY`, but the Phase-1 controller remained in:

```text
State: WAITING_FOR_BASELINE
Overall: NOT_RUN
Active: none
Queue: 0
```

The blocking reason was:

```text
OH58D total=24 available=24 busy=0 expectedAssetGroups=12
```

The same mismatch would subsequently have occurred for AH-64D:

```text
actual squadron.assets entries=8
contract AssetGroups=4
```

No test mission was created or queued. No Jalalabad runtime AID group spawned. The debrief therefore contains no `SQ_US_JBAD_*_AID-*` group.

## Root cause

The package contract correctly defined:

```text
OH58D 12 asset groups x grouping 2 = 24 aircraft
AH64D  4 asset groups x grouping 2 =  8 aircraft
UH60   8 asset groups x grouping 1 =  8 aircraft
CH47   8 asset groups x grouping 1 =  8 aircraft
```

The SQUADRON constructors nevertheless used the aircraft inventory as the second parameter:

```lua
SQUADRON:New(templateName, cfg.Inventory.OH58D, squadronName) -- 24
SQUADRON:New(templateName, cfg.Inventory.AH64D, squadronName) -- 8
```

For MOOSE `SQUADRON:New(template, Nassets, name)`, `Nassets` is the number of asset groups. `SetGrouping(2)` defines two aircraft per spawned group; it does not divide the constructor count by two.

The resulting MOOSE stock therefore contained:

```text
OH58D 24 asset groups instead of 12
AH64D  8 asset groups instead of 4
```

The readiness controller compared the actual `squadron.assets` count against the correct contract count and blocked before any test could start.

## Corrective changes

All four SQUADRON constructors now use:

```lua
local assetGroupCount = contract.AssetGroups
local squadron = SQUADRON:New(templateName, assetGroupCount, squadronName)
squadron:SetGrouping(contract.Grouping)
```

For UH-60 and CH-47 the numerical count remains eight, but the constructor now uses the same unambiguous contract field.

The package contract now states explicitly:

```text
SQUADRON constructor count = MOOSE asset groups
Grouping = aircraft per physical DCS group
InventoryAircraft = AssetGroups * Grouping
```

Builder version:

```text
JBAD-AIR-OPS-PHASE1-8
```

## Expected startup after correction

Before any test is selected, the next DCS log must contain inventory snapshots equivalent to:

```text
OH58D total=12 available=12 busy=0
AH64D total=4 available=4 busy=0
UH60 total=8 available=8 busy=0
CH47 total=8 available=8 busy=0
```

The controller must then transition from:

```text
WAITING_FOR_BASELINE
```

to:

```text
READY
```

Only after that transition may the OH-58D RECON test be started.

## Classification

This was not:

- a Mission Editor object failure;
- a parking failure;
- a route failure;
- a DCS AI failure;
- an AUFTRAG execution failure.

It was a MOOSE stock-construction semantics error detected by the new package-aware readiness gate.

The gate behaved correctly by preventing a test from running against an overstated squadron stock.
