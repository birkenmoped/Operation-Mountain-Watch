# 24 – Jalalabad: dauerhafte CH-47-Static-Parkplatzreservierungen

## Status

Dieses Dokument ist für die CH-47-Ramp in Jalalabad verbindlich und ersetzt die pauschale Vorgabe aus älteren Arbeitsständen, nach der alle sichtbaren Luftfahrzeug-Statics außerhalb funktionaler DCS-Parking-Nodes stehen müssten.

## Entscheidung

Auf der in DCS abgebildeten CH-47-Ramp stehen nicht genügend glaubwürdige freie Apronflächen zur Verfügung, um alle fünf sichtbaren CH-47-Statics außerhalb der funktionalen Parkpositionen zu platzieren.

Daher dürfen und sollen CH-47-Statics echte DCS-Parkpositionen dauerhaft belegen.

Diese Positionen werden technisch aus dem dynamischen MOOSE-Parkplatzpool entfernt. Sie stehen danach weder Spielern noch dynamisch erzeugter KI noch zurückkehrenden Luftfahrzeugen zur Verfügung.

## Kapazität

Der visuelle Bereich C01-C14 umfasst 14 CH-47-Positionen:

```text
5 sichtbare CH-47-Statics
2 CH-47-Clientpositionen
7 verbleibende Positionen
```

Die sieben verbleibenden Positionen sind für den festgelegten Betrieb ausreichend. Das Projekt erlaubt gleichzeitig höchstens vier KI-Unterstützungsluftfahrzeuge. Zusätzlich werden Clientpositionen durch MOOSE Safe Parking geschützt.

## Aktuelle DCS-Terminalreservierungen

Die Auswertung der Testmission `Operation_Mountain_Watch_Jalalabad_AirOps_Test_01(5).miz` ergab folgende Zuordnung:

```text
STATIC_AIR_US_JBAD_CH47_01 -> TerminalID 49
STATIC_AIR_US_JBAD_CH47_02 -> TerminalID 37
STATIC_AIR_US_JBAD_CH47_03 -> TerminalID 23
STATIC_AIR_US_JBAD_CH47_04 -> TerminalID 35
```

Diese Terminal-IDs werden beim Aufbau des Jalalabad-Airbase-Wrappers blacklisted:

```lua
airbase:SetParkingSpotBlacklist({ 23, 35, 37, 49 })
```

Der fünfte Static:

```text
STATIC_AIR_US_JBAD_CH47_05
```

liegt im aktuellen Missionsstand nicht auf einem funktionalen DCS-Parking-Node und benötigt daher keinen Blacklist-Eintrag.

## Validierungsregel

Die automatische Prüfung bewertet die vier Nähetreffer nicht mehr als Kollision, sondern als beabsichtigte Reservierungen.

PASS setzt voraus:

- jeder deklarierte Static liegt innerhalb von 8 Metern um den vorgesehenen TerminalID-Mittelpunkt;
- alle vier Terminal-IDs sind in der Blacklist enthalten;
- kein anderer Jalalabad-Aircraft-Static liegt unbeabsichtigt innerhalb von 8 Metern um einen nicht reservierten Parking-Node;
- sieben visuelle CH-47-Positionen bleiben nach fünf Statics und zwei Clients verfügbar;
- `AIRWING:SetSafeParkingOn()` schützt die vorhandenen Clientpositionen.

Erwartete Logmeldung:

```text
[OMW][AirOps.JBAD.PARKING] RESULT: PASS intentionalReservationsConfirmed=4 blacklistedTerminalIDs=23,35,37,49 ch47VisualPositionsRemaining=7 unexpectedOverlaps=0 AIRWING_START_BLOCKED=false
```

## Konsequenz für den Missionseditor

Die CH-47-Statics `_01` bis `_04` werden **nicht verschoben**.

Die frühere Retest-Anweisung, diese vier Statics von den DCS-Parking-Nodes wegzusetzen, ist aufgehoben.

Geändert werden muss ausschließlich das eingebettete Testbundle. Die bestehende `.miz`-Platzierung bleibt gültig.

## Abgrenzung

Diese Ausnahme gilt derzeit nur für die dokumentierten CH-47-Statics in Jalalabad.

Für OH-58D-, AH-64D- und UH-60-Statics gilt weiterhin:

- bevorzugt freie Apronplatzierung;
- keine unbeabsichtigte Überlagerung funktionaler DCS-Parking-Nodes;
- eine echte Parking-Belegung ist nur nach ausdrücklicher Dokumentation und technischer Blacklist zulässig.
