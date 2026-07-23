# Jalalabad complete Air Operations node: PASS

## Date and classification

```text
Test date: 2026-07-23 local DCS log time
Documentation date: 2026-07-24
Overall result: PASS
Jalalabad local Air Operations node: OPERATIONAL
```

## Evidence files

```text
Operation_Mountain_Watch_Jalalabad_AirOps_Test_01(6).miz
SHA256 16c607a9ffe9157779c09ad0e7557287697f91239c60e53fa33fd91d22396e8f

dcs(57).log
SHA256 1460c11af132a29421b091496702f8a1da70636c9303e4c72c82513b4e58a836

debrief(14).log
SHA256 2ae6f3e48cd0adea313b5c622226f6e965adf9b1ed51c51abcc33642d4ca12e4
```

## Embedded bundle

The uploaded `.miz` was inspected directly and contains:

```text
BuilderVersion: JBAD-AIR-OPS-COMPLETE-5
GitCommit:      6cee9a5db7abf1934d0f86bf9fdf91a0446374d0
GeneratedUtc:   2026-07-23T22:48:46.2604962Z
```

The Mission Editor resource mapping references the embedded file `l10n/DEFAULT/OMW_AirOps_Jalalabad.lua`.

## Confirmed Mission Editor configuration

The validators confirmed:

```text
6/6 required Client groups
5/5 AI template groups
20/20 aircraft statics
11/11 functional trigger zones
1/1 warehouse anchor
0 optional UH-60L Client groups, accepted
```

Required types and group sizes were correct:

```text
OH-58D:      OH58D
AH-64D:      AH-64D_BLK_II
UH-60A:      UH-60A
CH-47F:      CH-47Fbl1
```

Both UH-60 MEDEVAC templates used livery `standard`.

## SQUADRON construction

All four SQUADRONs were created and linked to `AW_US_JALALABAD`:

```text
SQ_US_JBAD_OH58D_6_6_CAV
24 aircraft / 12 two-ship asset groups / RECON

SQ_US_JBAD_AH64D_B_1_10_AVN
8 aircraft / 4 two-ship asset groups / CAS

SQ_US_JBAD_UH60_UTILITY_MEDEVAC
8 aircraft / 8 single-ship asset groups
TRANSPORT / LAND / GROUNDESCORT
MEDEVAC package model: 1 lead + 1 cover

SQ_US_JBAD_CH47_HEAVYLIFT
8 aircraft / 8 single-ship asset groups
TROOPTRANSPORT / CARGOTRANSPORT / LAND
canonical DCS type: CH-47Fbl1
```

## Intentional CH-47 static parking reservations

The four intended CH-47 static parking-node reservations were confirmed:

```text
STATIC_AIR_US_JBAD_CH47_01 -> TerminalID 49, distance 4.1 m
STATIC_AIR_US_JBAD_CH47_02 -> TerminalID 37, distance 4.4 m
STATIC_AIR_US_JBAD_CH47_03 -> TerminalID 23, distance 4.7 m
STATIC_AIR_US_JBAD_CH47_04 -> TerminalID 35, distance 5.4 m
```

Applied blacklist:

```text
23,35,37,49
```

Parking validator result:

```text
RESULT: PASS
intentionalReservationsConfirmed=4
blacklistedTerminalIDs=23,35,37,49
ch47VisualPositionsRemaining=7
unexpectedOverlaps=0
AIRWING_START_BLOCKED=false
```

All other checked aircraft statics satisfied the non-reserved eight-metre minimum. The closest non-reserved statics were the AH-64D `_03` and `_04` objects at 11.9 m and 11.6 m respectively.

## AIRWING and COMMANDER activation

The finalizer confirmed:

```text
OK MEDEVAC_MODEL
OK RAMP_MODEL
```

MOOSE then started:

```text
WAREHOUSE / AIRWING AW_US_JALALABAD
COMMANDER OMW_BLUE_COMMANDER
```

Final result:

```text
[OMW][AirOps.JBAD.COMPLETE] RESULT: COMPLETE. Jalalabad AirOps node OPERATIONAL; AIRWING started; COMMANDER linked; missionsQueued=0; spontaneousSpawns=0.
```

Final summary:

```text
inventory=OH58D:24/AH64D:8/UH60:8/CH47:8
corePlayerSlots=6
optionalUH60L=0or2
dynamicAIReserve=4
runtimeParking=10or12
templateAircraft=7nonRuntime
staticCaps=OH58D:7/AH64D:4/UH60:4/CH47:5
zones=11
templates=5
squadrons=4
medevac=twoIndependentSinglesAsOnePackage
virtualReserve=true
```

## Runtime observation

Debrief mission duration:

```text
81.562 seconds
```

Events relevant to the test:

```text
mission start
player took control of CLIENT_US_JBAD_OH58D_01-1
one unrelated existing OH-58D engine-start event at Bagram at t=78.5
mission end
```

No Jalalabad AI birth, engine-start, takeoff, landing, crash, dead or loss event was recorded. The AIRWING remained active for approximately 66 seconds after the complete-node result without creating a spontaneous Jalalabad sortie.

## Errors outside the Jalalabad bundle

No OMW Jalalabad Lua or timer error occurred.

The known shutdown error remained:

```text
Saved Games\DCS.openbeta\Scripts\Hooks\bhHook.lua:168
attempt to index upvalue 'tcp' (a nil value)
```

This occurs after `Dispatcher Stop` and is unrelated to the Jalalabad Air Operations implementation.

The DCS log also contains pre-existing DCS/module warnings and errors, including OH-58D damage-model/cockpit messages, zero-wind runway warnings, invalid ATC entries for unrelated FOBs and terrain/module resource warnings. None interrupted the Jalalabad validation or produced an OMW failure.

## Acceptance decision

The acceptance criteria for the local Jalalabad Air Operations node are fulfilled:

- complete Mission Editor object set validated;
- logical inventory `24/8/8/8` validated;
- all four SQUADRONs constructed;
- warehouse and AIRWING linked to Jalalabad;
- intentional CH-47 static parking nodes blacklisted;
- no undeclared static-to-parking overlap;
- AIRWING started;
- COMMANDER linked and started;
- zero queued missions;
- no spontaneous Jalalabad AI spawn;
- no relevant OMW Lua/timer error.

Jalalabad is therefore accepted as the validated local Air Operations baseline. This PASS does not by itself validate future tactical AUFTRAG generation, OPSTRANSPORT logistics flows, the persistent loss/ramp manager or the later runtime MEDEVAC coordinator.