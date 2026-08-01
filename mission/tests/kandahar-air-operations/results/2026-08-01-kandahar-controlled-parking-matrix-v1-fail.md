# Kandahar Controlled Parking Matrix v1 – Runtime Result

Date: 2026-08-01

Status: `FAIL_DYNAMIC_TERMINAL_REUSE`

## Baseline

The accepted construction and parking-contract stages passed:

```text
[OMW][AirOps.KAF.RegistrationPreflight] RESULT: PASS
airwings=2 squadrons=9 registeredAirframes=112 deferredMC12=6

[OMW][AirOps.KAF.ParkingContract] RESULT: PASS
mainTotal=316 mainAllowed=301 mainBlocked=15
heliportTotal=86 heliportAllowed=59 heliportBlocked=27
clientReservations=10 statics=47 safeParking=true
```

Both AIRWINGs started successfully.

## Physical spawn result

All nine requested asset groups and all twelve expected aircraft were physically created with the correct DCS types. Every observed unit was alive, on the ground, on a base allowlisted and non-blocked TerminalID, within 1.62–1.77 metres of its native parking-node centre, and clear of all configured `STATIC_AIR_US_KAF_*` aircraft statics.

```text
OH58D  -> 66,82      PASS
AH64D  -> 66,82      FAIL duplicate matrix terminals
UH60   -> 82         FAIL duplicate matrix terminal
CH47   -> 82         FAIL duplicate matrix terminal
MQ1    -> 317        PASS
MQ9    -> 281        PASS
HH60G  -> 317        FAIL duplicate matrix terminal
A10C   -> 316,317    FAIL duplicate matrix terminal 317
C130   -> 281        FAIL duplicate matrix terminal
```

Final v1 result:

```text
RESULT: FAIL
cases=9
passed=3
failed=6
failedCases=AH64D,UH60,CH47,HH60G,A10C,C130
assetGroups=9
units=12
```

## Finding

The initial static/client allow-/blocklist remained valid, but `AIRWING:SetSafeParkingOn()` plus the unchanged initial `AIRWING:SetParkingIDs()` list did not prevent later self-requests from reusing TerminalIDs already selected by earlier matrix cases.

This is not a type, template, AIRWING binding, client-parking, static-clearance, or node-resolution failure. It is a dynamic parking-reservation gap exposed by the cumulative matrix.

## Corrective action

Matrix v2 retains the MOOSE warehouse self-request mechanism and updates each AIRWING's valid parking-ID list before every subsequent request using the native:

```text
AIRWING:SetParkingIDs(remainingAllowedIDs)
```

Previously used TerminalIDs are removed from that AIRWING's runtime list. The v2 test also rechecks that earlier spawned groups remain alive and on the ground before issuing the next request.

No custom spawn placement, AUFTRAG, OPSTRANSPORT, payload mutation, COMMANDER, CHIEF, taxi, route, or client-parking override is introduced.

## Additional observation

After each payload-less self-request MOOSE logged:

```text
AIRWING.ReturnPayloadFromAsset: ERROR: asset had no payload attached!
```

The message did not prevent any requested group from spawning and is tracked as a separate AIRWING/self-request diagnostic side effect. No DCS scripting exception, crash, aircraft death, or graveyard entry was produced by the matrix run.
