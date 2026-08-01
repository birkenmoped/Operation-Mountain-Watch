# Kandahar Automatic Controlled Parking Matrix – Acceptance

Status: `PREPARED_NOT_RUNTIME_ACCEPTED`

## Purpose

Validate all nine approved Kandahar physical SQUADRON templates in one DCS mission run. The accepted registration and parking-contract preflights execute first. Both Kandahar AIRWINGs then start, but no operational mission is created.

## Test sequence

```text
1. OH58D  – Heliport – 1 asset group / 2 units
2. AH64D  – Heliport – 1 asset group / 2 units
3. UH60   – Heliport – 1 asset group / 1 unit
4. CH47   – Heliport – 1 asset group / 1 unit
5. MQ1    – Main     – 1 asset group / 1 unit
6. MQ9    – Main     – 1 asset group / 1 unit
7. HH60G  – Main     – 1 asset group / 1 unit
8. A10C   – Main     – 1 asset group / 2 units
9. C130   – Main     – 1 asset group / 1 unit
```

Expected total:

```text
assetGroups=9
units=12
```

The spawned groups remain in place. This intentionally validates cumulative parking occupancy and requires every unit to use a unique native TerminalID within its airbase.

## Required baseline

```text
[OMW][AirOps.KAF.RegistrationPreflight] RESULT: PASS
[OMW][AirOps.KAF.ParkingContract] RESULT: PASS
```

## Required AIRWING state

```text
[OMW][AirOps.KAF.ControlledParkingMatrix] AIRWINGS_STARTED main=true heliport=true
```

Both AIRWINGs use cold takeoff and the accepted safe-parking allow-/blocklists.

## Per-case acceptance

Each case must contain:

```text
REQUEST_ISSUED index=<n> case=<case> ... expectedAssetGroups=1 expectedUnits=<n>
SELF_REQUEST_FULFILLED case=<case>
GROUP_SPAWNED case=<case> ... alive=true airborne=false allOnGround=true
UNIT_PARKED case=<case> ... allowed=true blocked=false staticClear=true
CASE_RESULT: PASS index=<n> case=<case> ... violations=0
```

Each unit must:

- match the approved DCS type;
- remain alive and on the ground;
- resolve within 12 metres of a native parking-node centre;
- use an AIRWING-allowed TerminalID;
- not use a blocked or client-reserved TerminalID;
- not reuse a TerminalID already used by an earlier matrix case on the same airbase;
- remain outside the configured clearance radius of every `STATIC_AIR_US_KAF_*` aircraft static.

## Required final result

```text
[OMW][AirOps.KAF.ControlledParkingMatrix] RESULT: PASS cases=9 passed=9 failed=0 failedCases=none assetGroups=9 units=12 bothAirwingsStarted=true cold=true uncontrolled=true cumulativeParking=true noAUFTRAG=true noTransport=true noPayloadMutation=true noClientParking=true
```

The matrix fails on any `VIOLATION`, `CASE_RESULT: FAIL`, timeout, type mismatch, blocked/client parking selection, duplicate TerminalID, excessive node distance, or static-clearance failure.

## Runtime boundary

Permitted:

- construct and start the two approved Kandahar AIRWINGs;
- register the nine approved SQUADRON inventories;
- apply the accepted parking contracts;
- issue nine sequential exact-template warehouse self-requests;
- leave all spawned groups cold and uncontrolled.

Forbidden:

- `AUFTRAG`;
- `OPSTRANSPORT`;
- `COMMANDER` or `CHIEF` integration;
- payload registration or mutation;
- taxi, takeoff, route, or operational task commands;
- spawn on client parking.

## Runtime duration

Allow at least 180 seconds after mission start. Return the current `dcs.log` and `debrief.log` from that single run.
