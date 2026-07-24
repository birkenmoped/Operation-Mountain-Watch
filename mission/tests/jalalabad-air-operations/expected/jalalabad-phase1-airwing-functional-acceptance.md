# Jalalabad Phase 1 – AIRWING-/SQUADRON-Funktionsabnahme

## 1. Status

```text
Testpaket: IMPLEMENTED
DCS-Acceptance: PENDING
BuilderVersion: JBAD-AIR-OPS-PHASE1-3
```

Phase 1 validiert echte AUFTRAG-Missionen, exklusive typbezogene Parkpositionen, exakte MOOSE-Laufzeitnamen und die vollständige Rückgabe der AIRWING-Assets.

## 2. Verbindliche Laufzeitidentität

Eine Luftfahrzeuggruppe gehört nur dann zum aktiven Test, wenn alle Merkmale stimmen:

```text
Gruppenname beginnt exakt mit:
<SQUADRON-NAME>_AID-

Einheitenname bei Single-Ship-Gruppe:
<GRUPPENNAME>-01

DCS-Typ entspricht dem Testmanifest.
```

Eine Erkennung allein über den DCS-Typ ist verboten. Client-, Player-, Template- und sonstige Missionseditorgruppen werden über ihre eindeutigen Gruppen- und Einheitennamen ausgeschlossen.

Insbesondere darf folgende Test-/Clientgruppe niemals als OH-58D-AIRWING-Gruppe registriert werden:

```text
TEST_TM01A_CLIENT_01
```

## 3. Physisches Gruppenmodell

Alle vier SQUADRONs erzeugen ausschließlich Single-Ship-DCS-Gruppen:

```text
OH-58D RECON: 2 unabhängige Gruppen mit je 1 Luftfahrzeug
AH-64D CAS:   2 unabhängige Gruppen mit je 1 Luftfahrzeug
UH-60A:       1 Gruppe mit 1 Luftfahrzeug
CH-47F:       1 Gruppe mit 1 Luftfahrzeug
```

OH-58D und AH-64D bilden damit ein logisches Two-Ship-Paket aus zwei unabhängig landenden und freizugebenden DCS-Gruppen. Eine gemeinsame DCS-Gruppe mit Lead und Wingman ist nicht mehr zulässig.

## 4. SQUADRON-Konfiguration

Jedes SQUADRON verwendet:

```lua
squadron:SetGrouping(1)
squadron:SetParkingIDs(...)
squadron:SetTakeoffCold()
squadron:SetDespawnAfterLanding(true)
```

`SetDespawnAfterLanding(true)` muss jede gelandete Single-Ship-Gruppe nach dem Land-Ereignis entfernen, damit die Landefläche freigegeben und das Asset an das AIRWING/Warehouse zurückgegeben werden kann.

## 5. Exklusive Spawnpools

```text
OH-58D: G01-G05 / TerminalIDs 19,43,6,5,48
AH-64D: F04-F06 / TerminalIDs 26,51,11
UH-60A: F01-F03 / TerminalIDs 10,8,1
CH-47F: C03-C10 / TerminalIDs 28,44,0,41,9,25,18,42
```

Ein Spawn außerhalb des zum SQUADRON gehörenden Pools ist ein harter FAIL.

## 6. Erwartete Assetbestände

Da alle Assets Single-Ship-Gruppen sind, werden folgende vollständige Bestände erwartet:

```text
OH-58D: 24 Assetgruppen
AH-64D: 8 Assetgruppen
UH-60A: 8 Assetgruppen
CH-47F: 8 Assetgruppen
```

Vor und nach jedem Test müssen alle Bestände vollständig frei sein.

## 7. Getrennte Zeitfenster

Die Teststeuerung verwendet getrennte Fristen:

```text
SpawnTimeout
ExecutionTimeout
RecoveryTimeout
ReleaseTimeout
```

Ein fachlich erfolgreicher Auftrag darf nicht mehr wegen des früher gemeinsam verwendeten Gesamt-Timeouts fehlschlagen, während die Luftfahrzeuge ordnungsgemäß zum Heimatflugplatz zurückkehren.

## 8. Testfälle

```text
OH58D_RECON: 2 Gruppen / 2 Luftfahrzeuge
AH64D_CAS:   2 Gruppen / 2 Luftfahrzeuge
UH60_TROOP:  1 Gruppe  / 1 Luftfahrzeug
CH47_CARGO:  1 Gruppe  / 1 Luftfahrzeug
UH60_ABORT:  1 Gruppe  / 1 Luftfahrzeug
```

Für reguläre Tests werden geprüft:

- QUEUED, REQUESTED und SCHEDULED;
- exakte Laufzeitnamen;
- korrekte Gruppe und korrekter DCS-Typ;
- Spawn im typbezogenen Parkplatzpool;
- Engine Start und Takeoff;
- STARTED und EXECUTING;
- fachliches Missionsziel;
- SUCCESS;
- RTB und Landung in Jalalabad;
- Despawn nach Landung;
- vollständige Assetfreigabe.

## 9. Erwartete Vorprüfungen

```text
[OMW][AirOps.JBAD.NAMES] RESULT: PASS ...
[OMW][AirOps.JBAD.PARKING-POOLS] RESULT: PASS ...
[OMW][AirOps.JBAD.PARKING] RESULT: PASS ...
[OMW][AirOps.JBAD.COMPLETE] RESULT: COMPLETE ...
[OMW][AirOps.JBAD.PH1.MENU] RESULT: READY ...
```

## 10. Gesamt-PASS

```text
[OMW][AirOps.JBAD.PH1] RESULT: PASS testsPassed=5/5 abortRelease=PASS unexpectedSpawns=0 parkingViolations=0 losses=0 blockedAssets=0 finalInventoryRestored=true
```

DCS-Acceptance bleibt bis zu einem realen, dokumentierten Testlauf `PENDING`.
