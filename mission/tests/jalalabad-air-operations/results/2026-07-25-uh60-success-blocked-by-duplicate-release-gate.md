# UH-60 operational success blocked by duplicate release gate

Date: 2026-07-25

## Result

The UH-60 troop transport completed successfully at the native MOOSE and physical DCS levels, but the OMW acceptance controller remained `ACTIVE / NOT_RUN`.

This was not an OPSTRANSPORT failure and not an AIRWING recovery failure. It was an OMW test-controller defect.

## Observed successful lifecycle

The runtime log proved all required operational events:

```text
START testId=UH60_TROOP authority=OPSTRANSPORT nativeTerminal=DELIVERED
NATIVE_CARGO event=Loaded
NATIVE_CARGO event=Unloaded
NATIVE_STATE state=DELIVERED
LOGISTICS_OBJECTIVE PASS physicalCargoAtDeploy=true
RTB_REQUESTED
LAND_AT_JALALABAD_EXACT
EXPECTED_FINAL_DESPAWN classification=NON_LOSS
AIRWING_EVENT event=LEGION_ASSET_RETURNED returnedGroups=1 expectedGroups=1 source=MOOSE_LEGION_FSM
```

After all these events, the controller still reported:

```text
State: ACTIVE
Overall: NOT_RUN
Native state: DELIVERED
Birth/Engine/TO/Land: 1/1/1/1
Objective/RTB: true/true
Pending: none
UH60_TROOP: NOT_RUN
```

## Root cause

`controller:PollActive()` required two independent release mechanisms before PASS:

1. the authoritative MOOSE lifecycle already emitted `AIRWING:OnAfterLegionAssetReturned(...)`;
2. a project-specific inventory/mission-queue equality poll still had to remain stable for several polls.

The second mechanism blocked PASS even though MOOSE had already confirmed return of the expected asset group.

It also produced an earlier false release edge before the asset spawned because the untouched baseline inventory naturally matched itself.

## Official MOOSE semantics

Loaded MOOSE commit:

```text
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
```

In `Ops/Legion.lua`, a returned asset is first handled through `LEGION:onafterNewAsset`. For an existing cohort asset, MOOSE identifies it as returned and then triggers:

```lua
self:LegionAssetReturned(cohort, asset)
```

The `LEGION:onafterLegionAssetReturned` callback is documented as:

```text
Triggered when an asset group returned to its legion.
```

Its implementation then stops the flight group, returns its payload and TACAN channel, and sets `Asset.Treturned`.

Therefore, `LegionAssetReturned` is the authoritative lifecycle edge. A second inventory-stability poll is not required to prove successful return.

Official references:

- https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.Airwing.html
- https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.FlightGroup.html
- `Moose Development/Moose/Ops/Legion.lua` at the loaded MOOSE commit

## Correction

Commit:

```text
4ee9f5e3e7e9f246feab993e49c4610f3313f75e
```

`mission/tests/jalalabad-air-operations/src/14-phase1-test-controller.lua` now applies the following contract:

### Successful sortie

PASS requires:

- configured native terminal reached;
- physical objective satisfied when required;
- expected DCS birth/takeoff/RTB/landing evidence;
- `LegionAssetReturnedCount >= ExpectedGroups`.

The MOOSE `LegionAssetReturned` edge is the release authority.

### Inventory polling

Inventory and mission-queue equality are retained only as:

- non-blocking post-return diagnostics;
- cleanup fallback after a real failure.

They no longer:

- mark an untouched pre-spawn baseline as released;
- block PASS after an authoritative MOOSE return event.

## Expected corrected terminal log

```text
AIRWING_EVENT event=LEGION_ASSET_RETURNED returnedGroups=1 expectedGroups=1 source=MOOSE_LEGION_FSM
ACCEPTANCE event=ASSET_RELEASED authority=MOOSE_LEGION_FSM returnedGroups=1 expectedGroups=1 ... inventoryDiagnosticNonBlocking=true
RESULT testId=UH60_TROOP classification=PASS reason=native-operation-independent-acceptance-and-MOOSE-asset-return-complete authority=OPSTRANSPORT nativeState=DELIVERED released=true births=1 takeoffs=1 objective=true rtb=true landings=1
```

## Status

Code correction committed. DCS revalidation pending.

The branch remains draft and unmerged.