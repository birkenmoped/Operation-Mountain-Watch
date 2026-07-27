# ISAF 2009–2013 – AAR Areas: Bildreferenz zu Patreon Teil 2

## 1. Status und Quellenabgrenzung

**Dokumentationsstatus:** `REFERENCE / AUSGEWERTET`

Dieses Dokument erfasst ausschließlich die am 27. Juli 2026 vom Projektinhaber bereitgestellten Abbildungen zum Beitrag:

- Graveyard of Empires: `ISAF 2009-2013 - ACO Building - Air-to-Air Refueling Areas (2/x)`  
  <https://www.patreon.com/graveyard4DCS/posts/isaf-2009-2013-2-141257957>

Die Abbildungen werden als Quellenmaterial des Beitrags behandelt. Ihre Inhalte werden hier beschrieben und gegen die bereits dokumentierten Aussagen aus Teil 2 abgegrenzt. Es werden keine fehlenden Bildunterschriften ergänzt und keine nicht sichtbaren Einstellungen rekonstruiert.

Die Originalabbildungen werden in diesem öffentlichen Repository nicht dupliziert. Dieses Dokument hält die daraus eindeutig ablesbaren Planungswerte und DCS-Beispiele fest.

## 2. Abbildungsbestand

Es wurden zehn Bilddateien bereitgestellt. Eine schematische Darstellung der AAR-Area-Abmessungen war doppelt enthalten; sie wird deshalb nur einmal als eigenständige Quelle ausgewertet.

| Referenz | Sichtbarer Inhalt | Status |
|---|---|---|
| Abbildung 1 | KC-130- und KC-135-Optimalprofile | ausgewertet |
| Abbildung 2 | DCS Mission Editor: Beispiel für `Activate TACAN` | ausgewertet |
| Abbildung 3 | Kartenbeispiel einer AAR Area mit Racetrack und Richtungsdarstellung | ausgewertet |
| Abbildung 4 | Schematische AAR-Area- und Racetrack-Abmessungen | ausgewertet |
| Abbildung 5 | Vergleich eines geplanten Racetracks mit dem erweiterten DCS-Tankerturn | ausgewertet |
| Abbildung 6 | Mehrere Tanker in Formation: 5.000-ft-Block | ausgewertet |
| Abbildung 7 | Mehrere Tanker ohne Formation: 7.000-ft-Block | ausgewertet |
| Abbildung 8 | Einzelner Tanker: 4.000-ft-Block | ausgewertet |
| Abbildung 9 | Duplikat der schematischen AAR-Area-Abmessungen | als Duplikat erkannt |
| Abbildung 10 | `Figure 2-6. Anchor Pattern` | ausgewertet |

## 3. Optimale KC-130- und KC-135-Profile

Die bereitgestellte Tabelle bestätigt die bereits in [`29-isaf-2009-2013-air-to-air-refueling.md`](29-isaf-2009-2013-air-to-air-refueling.md) und in der maschinenlesbaren CSV erfassten Werte.

### 3.1 KC-130

| Domain | Receiver | Domain-Bereich | Optimal FL | Optimal IAS |
|---|---|---|---:|---:|
| Low Speed Domain | HAAR | FL005–FL200; 105–120 kt IAS | FL080 | 115 kt |
| High Speed Domain | S-3 + V-22 | FL050–FL200; 185–250 kt IAS | FL150 | 200 kt |
| High Speed Domain | Fixed Wings AAR | FL050–FL200; 185–250 kt IAS | FL150 | 240 kt |

### 3.2 KC-135 – Boom Domain

| Receiver | Optimal FL | Optimal IAS |
|---|---:|---:|
| A-10A | FL150 | 220 kt |
| B-1B | FL210 | 320 kt |
| B-52H | FL300 | 275 kt |
| C-130 | FL080 | 200 kt |
| E-3 | FL250 | 275 kt |
| F-111 | FL220 | 305 kt |
| F-117 | FL250 | 300 kt |
| F-15 | FL200 | 300 kt |
| F-16 | FL300 | 315 kt |
| F-22 | FL250 | 310 kt |
| F-35A | FL200 | 305 kt |
| F-4 | FL300 | 315 kt |
| KC-135 | FL250 | 275 kt |

Der sichtbare Boom-Domain-Bereich lautet:

```text
FL005–FL300
IAS 200–320 kt
```

### 3.3 KC-135 – MPRS Domain

| Receiver | Optimal FL | Optimal IAS |
|---|---:|---:|
| AMX | FL150 | 250 kt |
| E-2 | FL150 | 220 kt |
| EA-6B | FL250 | 275 kt |
| EF-2000 | FL200 | 255 kt |
| F-14 | FL250 | 270 kt |
| F-18 | FL250 | 270 kt |
| F-35B/C | FL200 | 255 kt |
| Gripen | FL230 | 280 kt |
| Harrier | FL180 | 275 kt |
| Hawk | FL150 | 240 kt |
| Jaguar | FL200 | 270 kt |
| Mirage 2000 | FL250 | 290 kt |
| Mirage F1 | FL250 | 290 kt |
| Rafale | FL250 | 290 kt |
| S-3 | FL200 | 235 kt |
| Su-30 | FL220 | 275 kt |
| Tornado | FL150 | 270 kt |

Der sichtbare MPRS-Domain-Bereich lautet:

```text
FL050–FL350
IAS 220–300 kt
```

Es ergeben sich aus dieser Abbildung keine Änderungen an der bestehenden Profildatei:

- [`data/air-operations/aar/isaf-2009-2013-aar-receiver-profiles.csv`](../data/air-operations/aar/isaf-2009-2013-aar-receiver-profiles.csv)

## 4. DCS Mission Editor – sichtbares TACAN-Beispiel

Die Abbildung zeigt eine Advanced Waypoint Action des Typs:

```text
Perform Command → Activate TACAN
```

Eindeutig sichtbare Beispielwerte:

| Feld | Sichtbarer Wert |
|---|---|
| Name | `Texaco` |
| Channel Mode | `Y` |
| Channel | `13` |
| Callsign | `TEX` |
| Unit | `Pilot #007` |
| Bearing | nicht aktiviert |
| Enable Task | aktiviert |

Die Aktionsliste zeigt sinngemäß einen aktivierten TACAN `13Y` für den Tanker `Texaco` beziehungsweise die Unit `Pilot #007`.

Im selben Screenshot sind für den ausgewählten Wegpunkt sichtbar:

| Feld | Sichtbarer Beispielwert |
|---|---:|
| Waypoint | 0 von 2 |
| Type | Turning point |
| Altitude | 20.000 ft MSL |
| Speed | 230 kt GS |
| Start | 17:30:00 |

Diese Werte sind ein **konkretes Editorbeispiel der Quelle**. Sie werden nicht als allgemeingültige Einstellung für alle Tanker oder AAR Areas übernommen.

## 5. Horizontale Geometrie

### 5.1 ATP-Anchor-Pattern

Die bereitgestellte Abbildung `Figure 2-6. Anchor Pattern` zeigt:

```text
Länge: 50 NM minimum
Breite: 7–20 NM
```

Zusätzlich sind dargestellt:

- `Inbound Course`,
- `Anchor Point`,
- ein langgestreckter Racetrack mit zwei 180°-Kurven.

Damit bestätigt die Abbildung die im Beitrag genannte ATP-Referenz von mindestens 50 NM Länge und 7 bis 20 NM Breite.

### 5.2 Schematische AAR-Area-Abmessungen

Die zweite schematische Darstellung enthält folgende Werte:

| Element | Sichtbarer Bereich |
|---|---:|
| Länge eines geraden Legs | 35–55 NM |
| Kurvenradius | 5–10 NM |
| Gesamtlänge der AAR Area | 50–70 NM |
| Gesamtbreite der AAR Area | 25–30 NM |

Der `ARCP` ist an einem Ende des unteren geraden Legs eingezeichnet.

Diese Abbildung war in den bereitgestellten Dateien zweimal identisch enthalten. Sie wird nur einmal als Quelle gewertet.

### 5.3 Abgrenzung der verschiedenen Dimensionsangaben

Die Quellen enthalten mehrere, jeweils getrennt zu behandelnde Angaben:

| Quelle beziehungsweise Aussage | Länge | Breite |
|---|---:|---:|
| ATP-Abbildung | mindestens 50 NM | 7–20 NM |
| schematische AAR-Area-Abbildung | 50–70 NM | 25–30 NM |
| Empfehlung im Beitragstext | 50 NM | 25 NM |

Diese Werte werden nicht stillschweigend vereinheitlicht. Die ATP-Abbildung beschreibt das Anchor Pattern, die größere gestrichelte Box der zweiten Abbildung den dafür vorgesehenen AAR-Luftraum einschließlich zusätzlicher Puffer.

## 6. Vertikale Staffelung

### 6.1 Einzelner Tanker

Die Abbildung `Single tanker` zeigt einen vertikalen Block von:

```text
4.000 ft
```

Dargestellte Ebenen:

- Blockuntergrenze: `BL - 2.000 ft`,
- Receiver: `BL - 1.000 ft`,
- Tanker: `Base Level`,
- Receiver: `BL + 1.000 ft`,
- Blockobergrenze: `BL + 2.000 ft`.

### 6.2 Mehrere Tanker ohne Formation

Die Abbildung `Multiple tankers (not in formation)` zeigt einen vertikalen Block von:

```text
7.000 ft
```

Dargestellte Ebenen:

- Blockuntergrenze: `BL - 2.000 ft`,
- Receiver: `BL - 1.000 ft`,
- Tanker 1: `Base Level`,
- Receiver: `BL + 1.000 ft`,
- Receiver: `BL + 2.000 ft`,
- Tanker 2: `BL + 3.000 ft`,
- Receiver: `BL + 4.000 ft`,
- Blockobergrenze: `BL + 5.000 ft`.

### 6.3 Mehrere Tanker in Formation

Die Abbildung `Multiple tankers (in formation)` zeigt einen vertikalen Block von:

```text
5.000 ft
```

Dargestellte Ebenen:

- Blockuntergrenze: `BL - 2.000 ft`,
- Receiver: `BL - 1.000 ft`,
- Tanker 1: `Base Level`,
- Tanker 2: `BL + 1.000 ft`,
- Receiver: `BL + 2.000 ft`,
- Blockobergrenze: `BL + 3.000 ft`.

Die Abbildung zeigt damit für die dargestellte Formation einen vertikalen Abstand von 1.000 ft zwischen den beiden Tankern.

## 7. DCS-spezifisches Racetrack-Verhalten

Eine Abbildung vergleicht einen engen geplanten Racetrack mit einem deutlich weiter ausgreifenden Tankerturn. Sichtbar sind:

- ein schmaler, langgestreckter Soll-Racetrack,
- eine wesentlich größere äußere Kurve,
- ein Tankersymbol außerhalb beziehungsweise unterhalb des schmalen Tracks,
- eine eingeblendete Messung von `21,43 nm`,
- ein eingeblendeter Winkel beziehungsweise Kurswert von `173,2°`.

Die Abbildung stützt die Aussage aus Teil 2, dass der DCS-Tanker während laufender Betankung deutlich weitere Kurven fliegen kann als im normalen Orbit. Die sichtbaren Einzelwerte werden nicht als allgemeine feste DCS-Parameter behandelt.

## 8. Kartenbeispiel

Eine weitere Abbildung zeigt:

- eine blau umrandete AAR Area,
- einen darin liegenden Racetrack,
- Pfeile für die Flugrichtung,
- einen markierten Punkt an einem Ende des Tracks,
- angrenzende Karten-, Grid- und Luftraumgrenzen.

Die Abbildung dient als visuelles Beispiel für die Einbettung eines Tankertracks in die umgebende Luftraumstruktur. Aus dem Bild allein werden keine zusätzlichen Koordinaten, Frequenzen oder Area-Namen abgeleitet.

## 9. Projektverwendung

Die Abbildungen konkretisieren die bereits in Dokument 29 erfassten Aussagen. Für die spätere DCS-Testmission sind daraus als **quellenbasierte Prüfpunkte** festzuhalten:

1. 4.000-ft-Block für das dargestellte Einzeltanker-Schema,
2. 7.000-ft-Block für das dargestellte Mehrtanker-Schema ohne Formation,
3. 5.000-ft-Block für das dargestellte Formationstanker-Schema,
4. getrennte Betrachtung von Pattern-Abmessung und gepufferter AAR-Area-Abmessung,
5. `Bearing` im gezeigten TACAN-Beispiel deaktiviert,
6. breiteres DCS-Kurvenverhalten während der Betankung in der Testmission prüfen,
7. ARCP, Hot Leg, Cold Leg und angrenzende Luftraumgrenzen gemeinsam bewerten.

Diese Prüfpunkte ersetzen keine MOOSE- oder DCS-Validierung.

## 10. Verknüpfte Dokumente

- [`ISAF 2009–2013 – Air-to-Air Refuelling und ACO-Referenz`](29-isaf-2009-2013-air-to-air-refueling.md)
- [`Afghanistan TAD- und Color-Net-Frequenzplan`](28-afghanistan-tad-color-nets.md)
- [`ISR-, FAC-, AFAC-, JTAC-, CAS- und AAR-Architektur`](moose/ISR-FAC-CAS-AAR.md)
