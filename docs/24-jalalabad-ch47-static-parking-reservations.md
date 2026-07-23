# 24 – Jalalabad: dauerhafte CH-47-Static-Parkplatzreservierungen

## Status

```text
Status: VALIDATED / PASS
Finaler DCS-Lauf: Operation_Mountain_Watch_Jalalabad_AirOps_Test_01(6).miz
BuilderVersion: JBAD-AIR-OPS-COMPLETE-5
Source-Commit: 6cee9a5db7abf1934d0f86bf9fdf91a0446374d0
```

Dieses Dokument ist für die CH-47-Ramp in Jalalabad verbindlich. Es ersetzt die pauschale ältere Vorgabe, nach der alle sichtbaren Luftfahrzeug-Statics außerhalb funktionaler DCS-Parking-Nodes stehen müssten.

## Entscheidung

Auf der in DCS abgebildeten CH-47-Ramp stehen nicht genügend glaubwürdige freie Apronflächen zur Verfügung, um alle fünf sichtbaren CH-47-Statics außerhalb der funktionalen Parkpositionen zu platzieren.

Daher dürfen und sollen vier CH-47-Statics echte DCS-Parkpositionen dauerhaft belegen.

Diese Positionen werden technisch aus dem dynamischen MOOSE-Parkplatzpool entfernt. Sie stehen danach weder Spielern noch dynamisch erzeugter KI noch zurückkehrenden Luftfahrzeugen zur Verfügung.

## Kapazität

Der visuelle Bereich C01-C14 umfasst 14 CH-47-Positionen:

```text
5 sichtbare CH-47-Statics
2 CH-47-Clientpositionen
7 verbleibende Positionen
```

Die sieben verbleibenden Positionen sind für den festgelegten Betrieb ausreichend:

```text
maximal gleichzeitig aktive KI-Unterstützungsluftfahrzeuge: 4
verbleibende CH-47-Positionen: 7
rechnerische Reserve: 3
```

Clientpositionen werden zusätzlich durch MOOSE Safe Parking geschützt.

## Validierte DCS-Terminalreservierungen

Die finale Testmission bestätigte:

```text
STATIC_AIR_US_JBAD_CH47_01 -> TerminalID 49 -> Abstand 4.1 m
STATIC_AIR_US_JBAD_CH47_02 -> TerminalID 37 -> Abstand 4.4 m
STATIC_AIR_US_JBAD_CH47_03 -> TerminalID 23 -> Abstand 4.7 m
STATIC_AIR_US_JBAD_CH47_04 -> TerminalID 35 -> Abstand 5.4 m
```

MOOSE-Blacklist:

```lua
airbase:SetParkingSpotBlacklist({ 23, 35, 37, 49 })
```

Der fünfte Static:

```text
STATIC_AIR_US_JBAD_CH47_05
```

liegt mit 33.5 m Abstand zum nächsten Parking-Mittelpunkt nicht auf einem funktionalen DCS-Parking-Node und benötigt keinen Blacklist-Eintrag.

## Safe Parking

Zusätzlich wird für das AIRWING aktiviert:

```lua
airwing:SetSafeParkingOn()
```

Damit berücksichtigt MOOSE unbesetzte Clientpositionen bei der dynamischen Parkplatzwahl.

## Validierungsregel

Für deklarierte Reservierungen gilt:

- exakter Static-Name,
- erwarteter TerminalID,
- maximal 8 m Abstand vom vorgesehenen Terminalmittelpunkt,
- TerminalID muss in der Blacklist stehen.

Für alle nicht deklarierten Jalalabad-Aircraft-Statics gilt:

- mindestens 8 m Abstand zum nächsten funktionalen Parking-Mittelpunkt,
- andernfalls Abschlussblockade als unerwartete Überlagerung.

PASS setzt außerdem voraus:

- vier deklarierte Reservierungen bestätigt,
- alle vier IDs blacklisted,
- sieben visuelle CH-47-Positionen verbleiben,
- Safe Parking aktiv,
- keine weitere unbeabsichtigte Static-Parking-Überlagerung.

## Final bestätigtes Ergebnis

```text
[OMW][AirOps.JBAD.PARKING] RESULT: PASS intentionalReservationsConfirmed=4 blacklistedTerminalIDs=23,35,37,49 ch47VisualPositionsRemaining=7 unexpectedOverlaps=0 AIRWING_START_BLOCKED=false
```

Damit ist die Entscheidung nicht mehr nur geplant, sondern im vollständigen DCS-Abschlusslauf bestätigt.

## Konsequenz für den Missionseditor

Die CH-47-Statics `_01` bis `_04` bleiben auf ihren validierten DCS-Parking-Nodes stehen.

```text
Nicht verschieben.
Nicht durch freie Apron-Positionen ersetzen.
Terminalzuordnung nicht ändern, ohne Blacklist und Validator gleichzeitig anzupassen.
```

`STATIC_AIR_US_JBAD_CH47_05` bleibt frei auf der Ramp platziert.

Eine spätere Änderung der CH-47-Staticpositionen erfordert:

1. erneute Ermittlung der nächsten TerminalIDs,
2. Aktualisierung der Reservierungstabelle,
3. Aktualisierung der Blacklist,
4. neuen vollständigen Parking-Regressionstest.

## Abgrenzung

Diese Ausnahme gilt derzeit nur für die dokumentierten CH-47-Statics in Jalalabad.

Für OH-58D-, AH-64D- und UH-60-Statics gilt weiterhin:

- bevorzugt freie Apronplatzierung,
- keine unbeabsichtigte Überlagerung funktionaler DCS-Parking-Nodes,
- echte Parking-Belegung nur nach ausdrücklicher Dokumentation, Blacklist und Validierung.

## Nachweise

```text
docs/21-jalalabad-air-operations-manifest.md
docs/23-jalalabad-parking-template-and-medevac-model.md
docs/25-jalalabad-final-validation-and-operational-baseline.md
mission/tests/jalalabad-air-operations/results/2026-07-24-jalalabad-complete-node-pass.md
```
