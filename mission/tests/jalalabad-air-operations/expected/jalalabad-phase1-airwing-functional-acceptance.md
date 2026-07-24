# Jalalabad Phase 1 – AIRWING-/SQUADRON-Funktionsabnahme

## 1. Status

```text
Testpaket: IMPLEMENTED
DCS-Acceptance: PENDING
BuilderVersion: JBAD-AIR-OPS-PHASE1-2
```

Diese Stufe validiert echte, direkt an `AW_US_JALALABAD` übergebene AUFTRAG-Missionen und die verbindliche typbezogene Parkplatzwahl der vier SQUADRONs.

## 2. Teststeuerung

F10-Menü für BLUE:

```text
OMW AirOps Tests
└── Jalalabad Phase 1
    ├── Status anzeigen
    ├── Gesamtablauf starten
    ├── OH-58D RECON starten
    ├── AH-64D CAS starten
    ├── UH-60A Transport starten
    ├── CH-47F Cargo starten
    ├── Aktiven Auftrag abbrechen
    └── Testcontroller zuruecksetzen
```

Es darf immer nur ein Phase-1-Auftrag aktiv sein.

## 3. Verbindliche SQUADRON-Parkplatzpools

Die technischen AIRWING-Templates stehen außerhalb aller operativen Parkpositionen. Der Spawn erfolgt ausschließlich über diese MOOSE-TerminalIDs:

```text
OH-58D / G01-G05:
19,43,6,5,48

AH-64D / F04-F06:
26,51,11

UH-60A / F01-F03:
10,8,1

CH-47F / C03-C10:
28,44,0,41,9,25,18,42
```

Jedes SQUADRON verwendet:

```lua
SQUADRON:SetParkingIDs(...)
SQUADRON:SetTakeoffCold()
```

Ein Fallback auf andere Jalalabad-Terminals ist nicht zulässig.

Vor dem AIRWING-Start muss erscheinen:

```text
[OMW][AirOps.JBAD.PARKING-POOLS] RESULT: PASS pools=OH58D:5/AH64D:3/UH60:3/CH47:8 templatesOffParking=true poolOverlap=0 clientOverlap=0 blacklistOverlap=0 staticClearance=PASS
```

Die Prüfung bestätigt zusätzlich:

- alle TerminalIDs existieren;
- die festgeschriebenen Koordinaten stimmen;
- Terminaltypen stimmen mit dem jeweiligen Pool überein;
- kein Pool überschneidet sich mit einem anderen Pool;
- keine Poolposition ist ein Clientplatz;
- keine Poolposition ist `23`, `35`, `37` oder `49`;
- mindestens 12 Meter Abstand zu nicht reservierten Aircraft-Statics;
- alle sieben Templateflugzeuge stehen mindestens 100 Meter vom nächsten Parking-Node entfernt.

## 4. Testfälle

### OH-58D RECON

```text
SQUADRON: SQ_US_JBAD_OH58D_6_6_CAV
Luftfahrzeuge: 2
DCS-Typ: OH58D
AUFTRAG: RECON
Zulässige Spawnplätze: G01-G05 / 19,43,6,5,48
```

### AH-64D CAS

```text
SQUADRON: SQ_US_JBAD_AH64D_B_1_10_AVN
Luftfahrzeuge: 2
DCS-Typ: AH-64D_BLK_II
AUFTRAG: CAS
Zulässige Spawnplätze: F04-F06 / 26,51,11
```

Das Testziel wird aus `TPL_GROUND_RED_JBAD_PHASE1_CAS_TARGET` erzeugt.

### UH-60A TROOPTRANSPORT

```text
SQUADRON: SQ_US_JBAD_UH60_UTILITY_MEDEVAC
Luftfahrzeuge: 1
DCS-Typ: UH-60A
AUFTRAG: TROOPTRANSPORT
Zulässige Spawnplätze: F01-F03 / 10,8,1
```

### CH-47F CARGOTRANSPORT

```text
SQUADRON: SQ_US_JBAD_CH47_HEAVYLIFT
Luftfahrzeuge: 1
DCS-Typ: CH-47Fbl1
AUFTRAG: CARGOTRANSPORT
Zulässige Spawnplätze: C03-C10 / 28,44,0,41,9,25,18,42
```

Das native DCS-Slingload-Cargo muss von der Pickup- in die Drop-Zone gelangen.

### UH-60A Abbruchtest

Ein zweiter UH-60A-TROOPTRANSPORT wird nach dem ersten bestätigten Birth-Ereignis automatisch abgebrochen. Das Asset muss vollständig freigegeben werden.

## 5. Birth- und Parking-Prüfung

Für jedes erwartete Luftfahrzeug wird der nächstgelegene Jalalabad-Terminal ermittelt. PASS setzt voraus:

```text
Parking-Distanz zum Terminalmittelpunkt <= 30 m
TerminalID gehört zum ParkingPoolKey des aktiven Tests
TerminalID ist kein Clientplatz
TerminalID ist nicht 23,35,37,49
Abstand zum nächsten nicht reservierten Aircraft-Static >= 12 m
```

Erwartete positive Meldung:

```text
[OMW][AirOps.JBAD.PH1.PARKING] SPAWN_POOL_CONFIRMED ...
```

Jede Meldung `SPAWN_OUTSIDE_SQUADRON_POOL` ist ein harter FAIL.

Client-, Player- und technische Template-Birth-Ereignisse dürfen nicht als AIRWING-Missionsgruppe übernommen werden. Insbesondere darf `TEST_TM01A_CLIENT_01` nicht mehr als provisorische OH-58D-Missionsgruppe registriert werden.

## 6. Bestands- und Lebenszyklusprüfung

Erwartete MOOSE-Asset-Gruppen:

```text
OH-58D: 12
AH-64D: 4
UH-60A: 8
CH-47F: 8
```

Ein regulärer Test ist nur PASS, wenn vollständig erkannt wurden:

```text
QUEUED
REQUESTED
SCHEDULED
Birth/Spawn
EngineStartup
Takeoff
STARTED
EXECUTING
fachliches Missionsziel
SUCCESS
RTB
Land in Jalalabad
Asset release
```

Nach jedem Test müssen drei aufeinanderfolgende Polls bestätigen:

```text
Queue = 0
requested = 0
spawned = 0
isReserved = 0
Bestand entspricht dem Vorher-Snapshot
```

## 7. Gesamt-PASS

Erwartete Abschlussmeldung:

```text
[OMW][AirOps.JBAD.PH1] RESULT: PASS testsPassed=5/5 abortRelease=PASS unexpectedSpawns=0 parkingViolations=0 losses=0 blockedAssets=0 finalInventoryRestored=true
```

Zusätzliche Bedingungen:

- Grundknoten bleibt `OPERATIONAL`;
- Static-Parking-Validator bleibt PASS;
- SQUADRON-Parking-Pool-Validator bleibt PASS;
- keine spontane oder zusätzliche KI-Gruppe;
- keine falsche Gruppengröße oder falscher DCS-Typ;
- kein relevanter OMW-Lua-/Timerfehler;
- kein dauerhaft blockiertes Asset.

## 8. Klassifikation

```text
PASS:
alle fünf Tests vollständig bestanden

PARTIAL:
Testlauf verwertbar, aber mindestens ein Teil nicht sicher bewertbar

FAIL:
falscher Typ, falsches SQUADRON, Spawn außerhalb des typbezogenen Pools,
Parking-Verstoß, Verlust, Lua-Fehler, unbeabsichtigter Spawn,
Mission FAIL/CANCEL oder nicht freigegebener Bestand
```

Jeder DCS-Lauf erhält einen eigenen Bericht unter `results/`.
