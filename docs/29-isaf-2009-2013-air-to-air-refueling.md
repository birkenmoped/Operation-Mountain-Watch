# ISAF 2009–2013 – Air-to-Air Refuelling und ACO-Referenz

## 1. Status

**Dokumentationsstatus:** `PARTIAL / AUSSTEHEND`

Diese Datei dokumentiert ausschließlich Inhalte, die aus den im Projekt bereitgestellten Anhängen direkt übernommen oder technisch extrahiert werden konnten.

Die folgenden vom Projektinhaber angegebenen Patreon-Quellen konnten nicht abgerufen werden und sind daher ausdrücklich als **AUSSTEHEND** markiert:

- **AUSSTEHEND:** `ISAF 2009–2013 – ACO Building`, Teil 1  
  <https://www.patreon.com/graveyard4DCS/posts/isaf-2009-2013-1-141193187?collection=833534>
- **AUSSTEHEND:** `ISAF 2009–2013 – ACO Building`, Teil 2  
  <https://www.patreon.com/graveyard4DCS/posts/isaf-2009-2013-2-141257957?collection=833534>
- **AUSSTEHEND:** `ISAF 2009–2013 – ACO Building`, Teil 3  
  <https://www.patreon.com/graveyard4DCS/posts/isaf-2009-2013-3-141708508?collection=833534>

Aus diesen drei nicht abrufbaren Beiträgen wurden **keine ergänzenden allgemeinen Aussagen, Zusammenfassungen oder Interpretationen abgeleitet**.

## 2. Verfügbare Anhänge

| Quelle | Status | Dokumentierter Inhalt |
|---|---|---|
| `AAR Areas - Afghanistan.pdf` | ausgewertet | AARA-Tabelle und Übersichtskarte |
| `Air-to-Air Refueling - Optimal Speed and Altitude.jpg` | ausgewertet | KC-130- und KC-135-Profile |
| `AAR ROZ - 2009-2013.kmz` | technisch extrahiert | Kontrollpunkte, Orbitlinien und Gebietsgeometrien |
| `AAR ROZ - 2009-2013.cf` | vorhanden | weitergehende inhaltliche Auswertung ausstehend |

## 3. AAR Areas aus dem bereitgestellten PDF

Die Quelle unterscheidet:

- **AARA (HA):** Nummer 1 bis 16
- **AARA (LA):** Nummer 17 bis 19

Die Tabellenfußnote nennt für die Safety Altitude:

```text
Safety Altitude: 1,500' Obstacle Clearance
```

| Nr. | Area | Klasse | Höhenblock | Control Point | Route | Primary BOOM | Secondary MPRS | A/A TACAN | Safety Altitude |
|---:|---|:---:|---|---|---:|---|---|---|---:|
| 1 | Barney | HA | FL200–FL250 | N30°01.10′ E065°19.90′ | 210°T | Gray 2 | Purple 4 | 41X | 5 300 ft |
| 2 | Bart | HA | FL200–FL250 | N30°21.30′ E063°49.00′ | 245°T | Maroon 10 | Cherry 9 | 46X | 5 100 ft |
| 3 | Carl | HA | FL200–FL250 | N31°12.50′ E063°02.90′ | 215°T | Carmine 14 | Coral 5 | 45X | 4 300 ft |
| 4 | Clancy | HA | FL200–FL250 | N31°48.10′ E066°46.30′ | 225°T | Turquoise 5 | Peach 13 | 60X | 10 800 ft |
| 5 | Homer | HA | FL180–FL280 | N32°56.30′ E068°13.40′ | 320°T | Green 7 | Lemon 17 | 54X;55X | 10 900 ft |
| 6 | Krusty | HA | FL180–FL280 | N33°13.60′ E068°38.10′ | 210°T | Aqua 4 | Tan 7 | 42X;43X | 11 600 ft |
| 7 | Lenny | HA | FL180–FL280 | N32°36.80′ E065°08.20′ | 245°T | White 16 | Khaki 14 | 56X;57X | 9 500 ft |
| 8 | Lisa | HA | FL180–FL280 | N33°44.90′ E061°52.90′ | 005°T | Teal 5 | Zinc 8 | 50X;51X | 6 500 ft |
| 9 | Maggie | HA | FL200–FL250 | N34°02.70′ E063°26.40′ | 265°T | Brass 2 | Crimson 16 | 40X | 12 300 ft |
| 10 | Marge | HA | FL150–FL200 | N34°55.90′ E062°03.40′ | 040°T | Iron 6 | Salmon 13 | 44X | 6 500 ft |
| 11 | Milhouse | HA | FL180–FL280 | N33°22.90′ E065°29.90′ | 065°T | Brass 15 | Green 9 | 58X;59X | 11 600 ft |
| 12 | Moe | HA | FL230–FL280 | N35°22.30′ E065°41.10′ | 245°T | Lemon 10 | Peach 4 | 52X | 14 700 ft |
| 13 | Montgomery | HA | FL200–FL250 | N37°08.00′ E065°30.60′ | 330°T | Cherry 2 | Coral 15 | 53X | 3 300 ft |
| 14 | Ned | HA | FL200–FL250 | N36°48.70′ E068°16.90′ | 245°T | Carmine 19 | Purple 7 | 49X | 5 700 ft |
| 15 | Nelson | HA | FL250–FL300 | N36°22.60′ E071°01.10′ | 010°T | Tan 18 | Iron 17 | 47X | 23 500 ft |
| 16 | Patty | HA | FL230–FL280 | N34°54.40′ E070°31.70′ | 065°T | Crimson 12 | Brass 9 | 48X | 15 800 ft |
| 17 | Selma | LA | 8 000–13 000 ft | N31°53.80′ E063°19.90′ | 270°T | N/A | White 1 | 61X | 6 100 ft |
| 18 | Seymour | LA | 10 000 ft–FL160 | N32°40.60′ E067°49.40′ | 225°T | N/A | Zinc 12 | 62X | 10 000 ft |
| 19 | Smithers | LA | 5 000–10 000 ft | N36°39.70′ E068°11.30′ | 095°T | N/A | White 10 | 63X | 2 000 ft |

## 4. Optimale Profile aus der bereitgestellten Grafik

### 4.1 KC-130

| Domain | Receiver | Domain-Bereich | Optimal FL | Optimal IAS |
|---|---|---|---:|---:|
| Low Speed Domain | HAAR | FL005–FL200; 105–120 kt IAS | FL080 | 115 kt |
| High Speed Domain | S-3 + V-22 | FL050–FL200; 185–250 kt IAS | FL150 | 200 kt |
| High Speed Domain | Fixed Wings AAR | FL050–FL200; 185–250 kt IAS | FL150 | 240 kt |

`HAAR` wird unverändert aus der Grafik übernommen. Eine ausgeschriebene Bedeutung ist in der bereitgestellten Quelle nicht enthalten.

### 4.2 KC-135 – Boom Domain

Domain-Bereich laut Grafik:

```text
FL005–FL300
IAS 200–320 kt
```

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

### 4.3 KC-135 – MPRS Domain

Domain-Bereich laut Grafik:

```text
FL050–FL350
IAS 220–300 kt
```

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

## 5. Maschinenlesbare Ablage

Die aus den bereitgestellten Anhängen übernommenen Daten liegen zusätzlich unter:

- [`data/air-operations/aar/isaf-2009-2013-aar-areas.csv`](../data/air-operations/aar/isaf-2009-2013-aar-areas.csv)
- [`data/air-operations/aar/isaf-2009-2013-aar-areas.geojson`](../data/air-operations/aar/isaf-2009-2013-aar-areas.geojson)
- [`data/air-operations/aar/isaf-2009-2013-aar-receiver-profiles.csv`](../data/air-operations/aar/isaf-2009-2013-aar-receiver-profiles.csv)

## 6. Projektinterne Einordnung

Dieser Abschnitt ist **keine Wiedergabe der ausstehenden Patreon-Beiträge**.

Die technische AAR-Umsetzung im Projekt bleibt in folgender vorhandener Projektdokumentation beschrieben:

- [`moose/ISR-FAC-CAS-AAR.md`](moose/ISR-FAC-CAS-AAR.md)

Die hier dokumentierten Tabellen und Geometrien sind zunächst Referenzdaten. Eine DCS- oder MOOSE-Validierung ist durch diese Quellenübernahme nicht erfolgt.

## 7. Ausstehende Arbeiten

- Inhalt der drei Patreon-Beiträge abrufen.
- Danach ausschließlich tatsächlich belegte Inhalte ergänzen.
- Abweichungen zwischen Beiträgen und Anhängen dokumentieren.
- CombatFlite-Datei separat auswerten und nur verifizierte Inhalte übernehmen.

Bis dahin bleibt das Dokument im Status:

```text
PARTIAL / AUSSTEHEND
```
