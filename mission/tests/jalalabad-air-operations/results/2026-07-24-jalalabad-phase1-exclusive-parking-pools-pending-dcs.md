# Jalalabad Phase 1 – exklusive SQUADRON-Parkplatzpools implementiert

## Status

```text
IMPLEMENTED IN REPOSITORY
STATIC VALIDATION: PASS
DCS VALIDATION: PENDING
```

## Anlass

Der erste Phase-1-Funktionslauf zeigte:

1. Laufzeitgruppen verwendeten beliebige Jalalabad-Parkplätze statt realistischer typbezogener Positionen.
2. Der provisorische Birth-Observer konnte einen Client/Testslot als erwartete AIRWING-Missionsgruppe registrieren.

## Missionsbasis

```text
OMW_Jalalabad_AirOps_Phase1_ParkingPools_Test.miz
SHA-256: 71d89a2553d502bdfb196d889aca3567d8ddca9e0073028b557f5d2dbc9e1001
```

Die fünf AIRWING-Templates stehen außerhalb funktionaler Parking-Nodes. Sechs nicht operative Static-/Templatezonen wurden entfernt; fünf Logistik-Funktionszonen und vier Phase-1-Testzonen bleiben bestehen.

## Exklusive Pools

```text
OH-58D: G01-G05 / 19,43,6,5,48
AH-64D: F04-F06 / 26,51,11
UH-60A: F01-F03 / 10,8,1
CH-47F: C03-C10 / 28,44,0,41,9,25,18,42
```

Jedes SQUADRON erhält `SetParkingIDs()` und `SetTakeoffCold()`. Ein Fallback auf den allgemeinen Airbase-Pool ist nicht vorgesehen.

## Sicherheitsprüfungen

Vor dem AIRWING-Start werden geprüft:

- TerminalID, Koordinate und Terminaltyp;
- keine Poolüberschneidung;
- keine Client- oder CH-47-Static-Position im Pool;
- mindestens 12 m Static-Abstand;
- alle sieben Templates mindestens 100 m vom nächsten Parking-Node entfernt.

Der Runtime-Observer bestätigt jeden Spawn gegen den Pool des aktiven Tests. Client-, Player- und Authoring-Births werden vor der provisorischen Gruppenerkennung verworfen.

## Statische Prüfung

```text
Lua-Syntax: PASS
Pool-/Terminal-Mapping: PASS
Pools disjunkt: PASS
Client-/Blacklist-Überschneidung: PASS
Templates off parking: PASS
SQUADRON-Harness: PASS
```

## Build

```text
Branch: feature/jalalabad-airwing-phase1-functional-tests
BuilderVersion: JBAD-AIR-OPS-PHASE1-2
```

## Noch nicht bestätigt

Erst der nächste DCS-Lauf kann bestätigen:

- tatsächliche MOOSE-Spawns innerhalb der vier Pools;
- kein allgemeiner Parkplatz-Fallback;
- vollständige fünfteilige Phase-1-Sequenz;
- Rückkehr, Freigabe und Bestandswiederherstellung.
