# UH-60 troop transport: missing PASS and unsafe random landing points

Date: 2026-07-25

## Tested build

- DCS: 2.9.28.26283
- Mission: `OMW_Jalalabad_AirOps_Phase1_Test.miz`
- Tested Git commit: `797e60e2d065d2a15856f750eea6e3657cf1d4be`
- MOOSE pin: `73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`

## Observed operational result

The UH-60 completed the complete transport operation:

1. spawned from the Jalalabad AIRWING;
2. started and took off;
3. landed in the pickup area;
4. loaded the infantry cargo;
5. flew to the deployment area;
6. landed and unloaded the infantry;
7. reached native `OPSTRANSPORT` state `DELIVERED`;
8. satisfied the independent physical logistics objective;
9. returned to Jalalabad;
10. landed at the exact Jalalabad airbase;
11. was intentionally despawned after the final landing.

The run nevertheless remained `ACTIVE` and `UH60_TROOP: NOT_RUN` until the mission was stopped.

## Root cause 1: invalid release edge

The controller evaluated the untouched pre-spawn inventory as already restored. It emitted:

```text
ACCEPTANCE event=ASSET_RELEASED stablePolls=3
```

before the actual UH-60 `FLIGHTGROUP` had been bound. This is not a valid asset return. It is only the unchanged baseline before MOOSE has committed and spawned the carrier asset.

After the actual final return, the controller had no authoritative MOOSE return event and depended solely on repeated inventory polling. Consequently the successful operation did not produce a timely final `PASS`.

## MOOSE-first correction

MOOSE already provides the required authoritative lifecycle event:

```lua
LEGION:OnAfterLegionAssetReturned(...)
```

The Phase-1 routing layer now:

- attaches to `AIRWING:OnAfterLegionAssetReturned`;
- accepts only an asset whose `spawngroupname` exactly matches a bound active `FLIGHTGROUP`;
- resets any premature pre-spawn release state when the real flight group is bound;
- records the native `LEGION_ASSET_RETURNED` event;
- re-arms and immediately re-runs the existing inventory/queue acceptance check;
- preserves the independent inventory-clean and mission-queue-clean validation before final `PASS`.

Expected completion sequence:

```text
EXPECTED_FINAL_DESPAWN ... classification=NON_LOSS
AIRWING_EVENT ... event=LEGION_ASSET_RETURNED ... source=MOOSE_LEGION_FSM
ACCEPTANCE event=ASSET_RELEASED
RESULT testId=UH60_TROOP classification=PASS ... released=true
```

## Root cause 2: unsafe pickup and deployment geometry

The original factory passed the large Mission Editor pickup/deployment trigger zones directly to `OPSTRANSPORT`. MOOSE may choose operational coordinates within those zones. The actual helicopter touchdown point therefore changed between runs.

Observed consequences included:

- touchdown directly on the infantry group, potentially killing cargo units and preventing loading;
- touchdown on a static HESCO wall, damaging the UH-60;
- inconsistent pickup locations between otherwise identical test runs.

## MOOSE-first landing correction

The factory now uses public MOOSE zone and transport APIs:

```lua
ZONE_RADIUS:New(...)
COORDINATE:Translate(...)
OPSTRANSPORT:SetEmbarkZone(...)
OPSTRANSPORT:SetDisembarkZone(...)
```

The runtime geometry is separated as follows:

- broad Mission Editor pickup zone: cargo eligibility and objective context;
- 5 m MOOSE pickup landing zone at the designed zone centre: carrier touchdown;
- infantry spawn position offset up to 45 m from the landing point;
- 5 m MOOSE deployment landing zone at the designed deployment centre;
- separate infantry disembark position offset up to 45 m from the helicopter.

This prevents the carrier and infantry from sharing the same point and removes the broad random landing area that included walls and other static objects.

## Required retest evidence

The next UH-60 run must show:

```text
GROUP_TRANSPORT_GEOMETRY ... pickupRadius=5m ... infantryOffset=45m ... deployRadius=5m ... disembarkOffset=45m
ACCEPTANCE_RESET ... reason=asset-now-committed
LOGISTICS_OBJECTIVE PASS
LOGISTICS_FINAL_DESPAWN armedFlightGroups=1
EVENT ... stage=LAND_AT_JALALABAD_EXACT
EXPECTED_FINAL_DESPAWN ... classification=NON_LOSS
AIRWING_EVENT ... event=LEGION_ASSET_RETURNED
ACCEPTANCE event=ASSET_RELEASED
RESULT testId=UH60_TROOP classification=PASS ... released=true
```

Final UH-60 inventory must be:

```text
total=8
stock=8
spawned=0
onMission=0
```

The following must not occur for a successful return:

```text
TERMINAL_LOSS
ABORT_REQUEST ... reason=terminal-aircraft-loss
RESULT testId=UH60_TROOP classification=FAIL
```
