# Bagram Parking Contract Validation — PASS

Date: 2026-07-30
Mission: `OMW_Template_v4_Bagram.miz`
DCS: 2.9.28.26385

## Result

The Bagram parking contract passed and the AIRWING started only after successful parking validation.

Accepted markers:

```text
[OMW][AirOps.BGRAM.ParkingContract] RESULT: PASS clients=8 blacklistCount=30 terminalIDs=4,11,12,16,21,25,26,27,35,42,44,64,71,72,81,82,85,88,106,111,119,120,121,125,126,128,141,142,149,185 AIRWING_START_BLOCKED=false
[OMW][AirOps.BGRAM.Finalize] PASS: AW_US_BAGRAM started with exactly 6 squadrons and 75 logical airframes.
[OMW][AirOps.BGRAM.Finalize] ACCOUNTING: MOOSE-managed=73 fighterLogicalReserve=2 total=75.
[OMW][AirOps.BGRAM.Finalize] PARKING: contract validated blacklistCount=30 terminalIDs=4,11,12,16,21,25,26,27,35,42,44,64,71,72,81,82,85,88,106,111,119,120,121,125,126,128,141,142,149,185
```

## Validated client reservations

```text
128 CLIENT_US_BGRM_F15E_01
 42 CLIENT_US_BGRM_F15E_02
119 CLIENT_US_BGRM_F16_01
 12 CLIENT_US_BGRM_F16_02
 21 CLIENT_US_BGRM_C130_01
111 CLIENT_US_BGRM_C130_02
 88 CLIENT_US_BGRM_CH47F_01
 85 CLIENT_US_BGRM_CH47F_02
```

All eight client groups matched their expected parking nodes with a recorded distance of `0.00 m`.

## Static reservations

The contract identified 22 additional DCS parking nodes occupied by Bagram static aircraft. Together with the eight client nodes, the effective blacklist contains 30 TerminalIDs.

The contract therefore protects:

- all eight player/client parking nodes;
- all parking nodes geometrically occupied by Bagram static aircraft;
- the six off-ramp Late Activation templates from accidental use as operational parking representations.

## Classification

```text
AIRWING baseline: PASS
Parking dump: PASS
Client reservation contract: PASS
Static overlap reservation: PASS
Blacklist application: PASS
Fail-closed AIRWING start gate: PASS
Spontaneous tasking: none
```

This result closes the Bagram no-tasking inventory and parking-contract baseline. The next increment is an isolated controlled spawn/despawn validation by aircraft class.
