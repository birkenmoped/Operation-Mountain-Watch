# Jalalabad CH-47 static parking reservation decision

## Date

2026-07-24

## Decision

The four CH-47 statics detected within 4.1 to 5.4 metres of functional DCS parking-node centres are not placement errors.

The Jalalabad heavy-lift ramp does not provide credible alternative free-placement areas for all visible CH-47 aircraft. The affected parking nodes are therefore intentionally and permanently assigned to visible CH-47 statics.

## Superseded instruction

The previous result report instructed the Mission Editor author to move:

```text
STATIC_AIR_US_JBAD_CH47_01
STATIC_AIR_US_JBAD_CH47_02
STATIC_AIR_US_JBAD_CH47_03
STATIC_AIR_US_JBAD_CH47_04
```

away from parking-node centres. That instruction is withdrawn.

No CH-47 static must be moved for the next test.

## Reserved terminal IDs

```text
STATIC_AIR_US_JBAD_CH47_01 -> TerminalID 49
STATIC_AIR_US_JBAD_CH47_02 -> TerminalID 37
STATIC_AIR_US_JBAD_CH47_03 -> TerminalID 23
STATIC_AIR_US_JBAD_CH47_04 -> TerminalID 35
```

Runtime blacklist:

```text
23, 35, 37, 49
```

## Capacity decision

```text
C01-C14 visual heavy-lift positions: 14
visible CH-47 statics:               5
CH-47 Client positions:              2
remaining visual positions:          7
maximum concurrent support AI:       4
```

Seven remaining positions are accepted as sufficient for the locked Jalalabad operating limits.

## Technical correction

The test bundle now:

- blacklists Terminal IDs `23,35,37,49` through the Jalalabad AIRBASE wrapper;
- enables AIRWING safe parking for Client positions;
- validates the four known Static-to-Terminal assignments as intentional reservations;
- continues to reject undeclared Static overlaps elsewhere;
- blocks final activation if a declared reservation no longer matches its expected terminal ID.

## Retest requirement

Only the bundle must be rebuilt and re-embedded. The `.miz` aircraft placement remains unchanged.

Expected parking result:

```text
[OMW][AirOps.JBAD.PARKING] RESULT: PASS intentionalReservationsConfirmed=4 blacklistedTerminalIDs=23,35,37,49 ch47VisualPositionsRemaining=7 unexpectedOverlaps=0 AIRWING_START_BLOCKED=false
```
