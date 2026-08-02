# Kandahar UAV return/final-parking V1 — controlled failure

Status: `FAIL_IMMEDIATE_POST_LANDING_DESPAWN`

Date: `2026-08-02`

## Evidence

```text
dcs.log
Size: 1,070,824 bytes
SHA-256: 9f563d254be45677ecba656314a040baaf9e0db9f30fcd167948944d11786688

debrief.log
Size: 567,111 bytes
SHA-256: 071ef25423ba07ef554b471d63af61c60eb9fac6316a69233a661298af2dc871
```

DCS runtime:

```text
DCS 2.9.28.26385
MOOSE commit dfe4db25ae05c2b40e3bfbb287d377c8775da217
AIRWING v0.9.7
SQUADRON v0.8.1
```

## Baseline contracts

The run passed:

```text
KandaharRegistrationPreflight
KandaharParkingContractPreflight
KandaharUAVParkingContract
KandaharUAVAssetParkingSync
```

Accepted runtime UAV pools were:

```text
MQ-1: TerminalIDs 46,129,143,189,224,291
MQ-9: TerminalIDs 27,54,263
```

## Successful flight stages

Both missions completed the following chain:

```text
MISSION_QUEUED
FLIGHT_ASSIGNED
ENGINE_ON
TAXI_OUT
TAKEOFF
AIRBORNE
AUFTRAG ORBIT success
RTB
LANDED at Kandahar / airbase ID 7
```

Observed landing events:

```text
MQ-9 Reaper
23:18:33.994
Kandahar / airbase ID 7

RQ-1A Predator
23:18:57.286
Kandahar / airbase ID 7
```

The debrief recorded both `land` events at Kandahar and no UAV loss. The graveyard remained empty.

## Missing acceptance stages

Neither aircraft produced:

```text
TAXI_IN
FINAL_PARKING_CHECK
FINAL_PARKED
ARRIVED
```

Both physical groups disappeared immediately after touchdown. The mission was stopped at `23:19:14.946`, approximately 17 seconds after the second landing, with no final result from the return-parking test.

## Root cause

V1 attempted to disable post-landing despawn with:

```lua
runtime.MainAirwing:SetDespawnAfterLanding(false)
```

The embedded MOOSE AIRWING v0.9.7 implementation is effectively:

```lua
function AIRWING:SetDespawnAfterLanding(Switch)
  if Switch then
    self.despawnAfterLanding = Switch
  else
    self.despawnAfterLanding = true
  end
end
```

Therefore a false argument sets the state to `true`. The same argument semantics exist in SQUADRON v0.8.1. FLIGHTGROUP then executes its post-landing despawn branch when the inherited state is true.

This was a test-harness/API-semantics error, not evidence that Kandahar parking or the UAV G-apron pools are invalid.

## Result

```text
flight launch and mission execution: PASS
RTB and landing at Kandahar Main: PASS
taxi-in: NOT OBSERVED
final type-specific parking: NOT OBSERVED
warehouse reconciliation: NOT TESTED
overall return-parking V1: FAIL
```

## Corrective action

Builder V2 adds:

```text
12b-kandahar-uav-no-despawn-policy.lua
```

The compatibility stage explicitly clears `despawnAfterLanding` on the Kandahar Main AIRWING, both UAV SQUADRON instances and every assigned UAV FLIGHTGROUP. It does not monkeypatch global MOOSE classes.

A new runtime run is required before landing/final-parking acceptance can be granted.
