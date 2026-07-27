# ISAF 2009–2013 – Air-to-Air Refuelling und ACO-Referenz

## 1. Status und Zweck

**Status:** `REFERENCE` / missionsgestalterische ACO- und AAR-Datenbasis; noch nicht als DCS-/MOOSE-Laufzeitkonfiguration validiert.

Dieses Dokument übernimmt die im Projekt bereitgestellten und aus den Anhängen direkt extrahierbaren Inhalte zur dreiteiligen Reihe **„ISAF 2009–2013 – ACO Building“** von *Graveyard of Empires* sowie die dazugehörigen Dateien:

- `AAR Areas - Afghanistan.pdf`, Version 1.0 vom 15. Oktober 2025,
- `AAR ROZ - 2009-2013.kmz`,
- `AAR ROZ - 2009-2013.cf`,
- `Air-to-Air Refueling - Optimal Speed and Altitude.jpg`, Version 1.0 vom 15. Oktober 2025.

Der direkte Webabruf der drei Patreon-Beiträge war zum Dokumentationszeitpunkt nicht möglich. Deshalb gelten die bereitgestellten PDF-, KMZ-, CombatFlite- und Grafikdateien als Primärbasis dieser Übernahme. Nicht in diesen Anhängen enthaltener Patreon-Fließtext ist nicht als vollständig übernommen oder verifiziert zu betrachten.

Die Referenz liefert für **Operation Mountain Watch**:

- 19 vorbereitete Air-to-Air Refuelling Areas (AARA),
- Höhenblöcke, Kontrollpunkte und wahre Kursachsen,
- getrennte BOOM- und MPRS-Callsigns,
- TACAN-Kanäle und Safety Altitudes,
- optimale Tanker-/Receiver-Profile für KC-130 und KC-135,
- georeferenzierte Punkt-, Orbit- und Gebietsgeometrien aus dem KMZ,
- eine belastbare Grundlage für ACO, ATO, Tankerplanung, Kneeboard, F10-Menüs und spätere MOOSE-Konfiguration.

Die Daten sind **Planungsdaten**. Sie belegen nicht, dass alle 19 Bereiche gleichzeitig aktiv waren oder für jede konkrete Mission unverändert übernommen werden müssen.

## 2. Quellenlage und technische Prüfung

Die bereitgestellte PDF enthält auf Seite 1 die vollständige AARA-Tabelle und auf Seite 2 die geographische Übersicht. Das KMZ enthält für jeden der 19 Bereiche:

- einen Kontrollpunkt,
- eine Orbit-/Racetrack-Geometrie,
- ein zugehöriges AARA-Polygon.

Die CombatFlite-Datei ist ein ZIP-basiertes Projektarchiv mit `mission.xml` und drei Kartenebenen. In `mission.xml` ist als Container-Theater `PersianGulf` eingetragen. Das ist als technische CombatFlite-Projektbasis zu behandeln und **nicht** als Aussage, dass die Koordinaten zur DCS-Persian-Gulf-Karte gehören; sämtliche AAR-Geometrien liegen in Afghanistan.

Die extrahierten maschinenlesbaren Daten befinden sich unter:

- [`data/air-operations/aar/isaf-2009-2013-aar-areas.csv`](../data/air-operations/aar/isaf-2009-2013-aar-areas.csv)
- [`data/air-operations/aar/isaf-2009-2013-aar-areas.geojson`](../data/air-operations/aar/isaf-2009-2013-aar-areas.geojson)
- [`data/air-operations/aar/isaf-2009-2013-aar-receiver-profiles.csv`](../data/air-operations/aar/isaf-2009-2013-aar-receiver-profiles.csv)

## 3. Systematik der AAR Areas

Die Quelle unterscheidet:

- **AARA (HA)**: High-Altitude-AAR-Bereiche, Nummer 1 bis 16;
- **AARA (LA)**: Low-Altitude-AAR-Bereiche, Nummer 17 bis 19.

Jeder Bereich besitzt mindestens:

- einen eindeutigen Namen,
- einen vertikalen Block,
- einen Kontrollpunkt,
- eine Route beziehungsweise Orbitachse in Grad True,
- einen primären BOOM-Callsign,
- einen sekundären MPRS-Callsign,
- einen oder mehrere TACAN-Kanäle,
- eine Safety Altitude.

Die Safety Altitude basiert laut Quellblatt auf **1.500 ft obstacle clearance**. Sie ist nicht automatisch mit einer DCS-Minimum-Safe-Altitude, einer MSA aus einer Instrumentenanflugkarte oder einem universell gültigen Mindestflugniveau gleichzusetzen.

## 4. Vollständige AARA-Liste

| Nr. | Area | Klasse | Höhenblock | Control Point | Route | Primary BOOM | Secondary MPRS | A/A TACAN | Safety Altitude |
|---:|---|:---:|---|---|---:|---|---|---|---:|
| 1 | Barney | HA | FL200–FL250 | N30°01.10′ E065°19.90′ | 210°T | Gray 2 | Purple 4 | 41X | 5 300 ft |
| 2 | Bart | HA | FL200–FL250 | N30°21.30′ E063°49.00′ | 245°T | Maroon 10 | Cherry 9 | 46X | 5 100 ft |
| 3 | Carl | HA | FL200–FL250 | N31°12.50′ E063°02.90′ | 215°T | Carmine 14 | Coral 5 | 45X | 4 300 ft |
| 4 | Clancy | HA | FL200–FL250 | N31°48.10′ E066°46.30′ | 225°T | Turquoise 5 | Peach 13 | 60X | 10 800 ft |
| 5 | Homer | HA | FL180–FL280 | N32°56.30′ E068°13.40′ | 320°T | Green 7 | Lemon 17 | 54X | 10 900 ft |
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
| 17 | Selma | LA | 8000 ft–13000 ft | N31°53.80′ E063°19.90′ | 270°T | N/A | White 1 | 61X | 6 100 ft |
| 18 | Seymour | LA | 10000 ft–FL160 | N32°40.60′ E067°49.40′ | 225°T | N/A | Zinc 12 | 62X | 10 000 ft |
| 19 | Smithers | LA | 5000 ft–10000 ft | N36°39.70′ E068°11.30′ | 095°T | N/A | White 10 | 63X | 2 000 ft |

### 4.1 Hinweise zur Tabelleninterpretation

- Die in der Quelle zweizeilig dargestellten Flight Levels werden hier als Unter- bis Obergrenze wiedergegeben.
- Mehrere TACAN-Kanäle werden im Datensatz mit Semikolon getrennt.
- `N/A` beim BOOM-Callsign der LA-Bereiche bedeutet, dass die Quelle dort keinen primären BOOM-Callsign vorsieht.
- Kurswerte sind **True**, nicht Magnetic.
- Die Kontrollpunkte sind aus Grad/Minuten zusätzlich als Dezimalgrade in der CSV enthalten.

## 5. Optimale Tanker- und Receiver-Profile

### 5.1 KC-130

Die Quelle unterscheidet einen Low-Speed- und einen High-Speed-Bereich:

| Receiver | Domain | Optimal FL | Optimal IAS |
|---|---:|---:|---:|
| HAAR | LOW SPEED DOMAIN (FL005-FL200; 105-120 kt IAS) | FL080 | 115 kt |
| S-3 + V-22 | HIGH SPEED DOMAIN (FL050-FL200; 185-250 kt IAS) | FL150 | 200 kt |
| Fixed Wings AAR | HIGH SPEED DOMAIN (FL050-FL200; 185-250 kt IAS) | FL150 | 240 kt |

`HAAR` wird quellennah übernommen. Die Grafik liefert dafür kein ausgeschriebenes Langformat; eine projektspezifische Umdeutung ist daher nicht zulässig.

### 5.2 KC-135 – Boom Domain

Allgemeiner BOOM-Bereich: **FL005–FL300**, **200–320 kt IAS**.

| Receiver | Domain | Optimal FL | Optimal IAS |
|---|---:|---:|---:|
| A-10A | BOOM DOMAIN (FL005-FL300; 200-320 kt IAS) | FL150 | 220 kt |
| B-1B | BOOM DOMAIN (FL005-FL300; 200-320 kt IAS) | FL210 | 320 kt |
| B-52H | BOOM DOMAIN (FL005-FL300; 200-320 kt IAS) | FL300 | 275 kt |
| C-130 | BOOM DOMAIN (FL005-FL300; 200-320 kt IAS) | FL080 | 200 kt |
| E-3 | BOOM DOMAIN (FL005-FL300; 200-320 kt IAS) | FL250 | 275 kt |
| F-111 | BOOM DOMAIN (FL005-FL300; 200-320 kt IAS) | FL220 | 305 kt |
| F-117 | BOOM DOMAIN (FL005-FL300; 200-320 kt IAS) | FL250 | 300 kt |
| F-15 | BOOM DOMAIN (FL005-FL300; 200-320 kt IAS) | FL200 | 300 kt |
| F-16 | BOOM DOMAIN (FL005-FL300; 200-320 kt IAS) | FL300 | 315 kt |
| F-22 | BOOM DOMAIN (FL005-FL300; 200-320 kt IAS) | FL250 | 310 kt |
| F-35A | BOOM DOMAIN (FL005-FL300; 200-320 kt IAS) | FL200 | 305 kt |
| F-4 | BOOM DOMAIN (FL005-FL300; 200-320 kt IAS) | FL300 | 315 kt |
| KC-135 | BOOM DOMAIN (FL005-FL300; 200-320 kt IAS) | FL250 | 275 kt |

### 5.3 KC-135 – MPRS Domain

Allgemeiner MPRS-Bereich: **FL050–FL350**, **220–300 kt IAS**.

| Receiver | Domain | Optimal FL | Optimal IAS |
|---|---:|---:|---:|
| AMX | MPRS DOMAIN (FL050-FL350; 220-300 kt IAS) | FL150 | 250 kt |
| E-2 | MPRS DOMAIN (FL050-FL350; 220-300 kt IAS) | FL150 | 220 kt |
| EA-6B | MPRS DOMAIN (FL050-FL350; 220-300 kt IAS) | FL250 | 275 kt |
| EF-2000 | MPRS DOMAIN (FL050-FL350; 220-300 kt IAS) | FL200 | 255 kt |
| F-14 | MPRS DOMAIN (FL050-FL350; 220-300 kt IAS) | FL250 | 270 kt |
| F-18 | MPRS DOMAIN (FL050-FL350; 220-300 kt IAS) | FL250 | 270 kt |
| F-35B/C | MPRS DOMAIN (FL050-FL350; 220-300 kt IAS) | FL200 | 255 kt |
| Gripen | MPRS DOMAIN (FL050-FL350; 220-300 kt IAS) | FL230 | 280 kt |
| Harrier | MPRS DOMAIN (FL050-FL350; 220-300 kt IAS) | FL180 | 275 kt |
| Hawk | MPRS DOMAIN (FL050-FL350; 220-300 kt IAS) | FL150 | 240 kt |
| Jaguar | MPRS DOMAIN (FL050-FL350; 220-300 kt IAS) | FL200 | 270 kt |
| Mirage 2000 | MPRS DOMAIN (FL050-FL350; 220-300 kt IAS) | FL250 | 290 kt |
| Mirage F1 | MPRS DOMAIN (FL050-FL350; 220-300 kt IAS) | FL250 | 290 kt |
| Rafale | MPRS DOMAIN (FL050-FL350; 220-300 kt IAS) | FL250 | 290 kt |
| S-3 | MPRS DOMAIN (FL050-FL350; 220-300 kt IAS) | FL200 | 235 kt |
| Su-30 | MPRS DOMAIN (FL050-FL350; 220-300 kt IAS) | FL220 | 275 kt |
| Tornado | MPRS DOMAIN (FL050-FL350; 220-300 kt IAS) | FL150 | 270 kt |

### 5.4 Verbindliche Nutzung der Profile

Die Werte sind als **Planungs- und Startwerte** zu verwenden, nicht als garantierte DCS-AI-Kompatibilität. Für jede tatsächlich eingesetzte Kombination sind separat zu testen:

- Tankermodell und Refuelling-System,
- Receiver-Modul beziehungsweise AI-Typ,
- IAS/TAS-Verhalten in der gewählten Höhe,
- Join-up und Pre-contact,
- Warteschlangen mit mehreren Receivern,
- Abbruch, Rejoin und Recovery,
- Rückkehr in den ursprünglichen Auftrag.

## 6. Missionsdesign für Operation Mountain Watch

### 6.1 Auswahl eines Bereichs

Ein AARA wird nicht allein nach räumlicher Nähe gewählt. Mindestens zu bewerten sind:

1. unterstützte Mission und Receiver-Typen,
2. Transitzeit zwischen Einsatzraum und Tanker,
3. Höhenblock und Terrain,
4. Safety Altitude,
5. zivile und militärische Airspace-Konflikte,
6. Nähe zu Recovery- und Divert-Flugplätzen,
7. Bedrohungslage und notwendiger Standoff,
8. CSAR-/Personnel-Recovery-Erreichbarkeit,
9. BOOM- oder MPRS-Bedarf,
10. verfügbare Tanker, Offload-Menge und Ablösung.

### 6.2 Relevanz für den östlichen Kampagnenschwerpunkt

Für Jalalabad, Nangarhar, Laghman, Kunar und die angrenzenden östlichen Einsatzräume ist **Patty (AARA 16)** aufgrund seiner Lage der naheliegende Ausgangskandidat. **Nelson (AARA 15)** liegt weiter nordöstlich und ist wegen des hohen Safety-Altitude-Werts von 23.500 ft gesondert zu bewerten. **Homer**, **Krusty** und **Seymour** liegen weiter südwestlich und können für Operationen im südöstlichen beziehungsweise zentralöstlichen Raum relevant werden.

Diese Zuordnung ist eine geographische Projektbewertung aus Karte und Koordinaten, keine Behauptung einer historisch ständig aktiven regionalen Zuständigkeit.

### 6.3 Callsigns und TACAN

Die Callsigns sind Bestandteil des ACO-/SPINS-Datensatzes. Für eine Mission gilt:

- BOOM- und MPRS-Callsign nicht vertauschen,
- Callsign-Nummern quellennah beibehalten, sofern kein Konflikt besteht,
- TACAN-Kanal innerhalb der Mission eindeutig halten,
- bei mehreren Tankern in einer Area zusätzliche Kennungen nur dokumentiert vergeben,
- Frequenz, Callsign, TACAN und Tankersystem als getrennte Datenfelder führen.

### 6.4 Höhen- und Geschwindigkeitsplanung

Der AARA-Höhenblock begrenzt die zulässige Planung. Das optimale Receiver-Profil muss innerhalb dieses Blocks liegen. Liegt das quellenseitige Optimum außerhalb des gewählten Blocks, sind folgende Optionen zu prüfen:

1. anderer AARA,
2. anderer Tanker oder anderes System,
3. koordinierte abweichende Höhe innerhalb des Blocks,
4. missionsspezifischer ad-hoc AAR-Bereich.

Ein optimaler Wert darf nicht stillschweigend außerhalb des ACO-Höhenblocks verwendet werden.

## 7. ACO-/ATO-Datenmodell

Für die spätere Konfiguration soll ein Tankerauftrag mindestens folgende Felder besitzen:

```text
area_id
area_name
area_class
control_point
route_true_deg
lower_altitude
upper_altitude
safety_altitude_ft
refueling_system
callsign
callsign_number
tacan_channel
radio_frequency
radio_modulation
tanker_type
receiver_types
on_station_from
on_station_until
offload_planned
relief_tanker
activation_state
source_status
```

Nicht in der Quelle enthalten und deshalb missionsspezifisch zu ergänzen sind insbesondere:

- Funkfrequenzen,
- Tankertyp je aktivierter Area,
- On-Station-Zeiten,
- Fuel-Offload,
- Receiver-Sequenz und ARCT,
- IFF/SIF,
- Ausweich- und Abbruchverfahren,
- konkrete ROE beziehungsweise Bedrohungsgrenzen.

## 8. MOOSE-Integration

Die technische Architektur ist in [`moose/ISR-FAC-CAS-AAR.md`](moose/ISR-FAC-CAS-AAR.md) beschrieben. Verbindlich gilt weiterhin **MOOSE first**.

Vor eigenem Lua-Code sind insbesondere zu prüfen:

- `COMMANDER`-Tanker- beziehungsweise Refuelling-Zonen,
- Tanker-Aufträge über `AUFTRAG`, `AIRWING` und `SQUADRON`,
- `FLIGHTGROUP`-Fuel-Low-/Fuel-Critical-Verhalten,
- vorhandene Refuelling- und Mission-Resume-Funktionen,
- offizielle MOOSE-Demo-/Testmissionen für Tanker und AAR.

Die AARA-Geometrien sind zunächst **Daten**, keine neue parallele Tankerlogik. Eigenentwicklung ist nur für nachgewiesene Lücken zulässig, etwa für projektspezifische ACO-Aktivierung, Persistenz, Konfliktprüfung oder Player-Ausgabe.

## 9. Validierungsplan

Vor produktiver Nutzung sind mindestens folgende Teststufen erforderlich:

1. Geometrieabgleich der GeoJSON-/KMZ-Daten mit der DCS-Afghanistan-Karte.
2. Mission-Editor-Anlage eines Tankers in einer ausgewählten AARA.
3. BOOM-Test mit einem kompatiblen Receiver.
4. MPRS-Test mit einem kompatiblen Receiver.
5. Test der veröffentlichten Optimalhöhe und Optimal-IAS.
6. Test an Unter- und Obergrenze des AARA-Blocks.
7. Mehrfach-Receiver und Warteschlange.
8. Player- und AI-Receiver getrennt.
9. Fuel-Low → AAR → Rückkehr zum ursprünglichen CAS-/Strike-Auftrag.
10. Tankerverlust, Divert, Relief und AAR-Abbruch.
11. TACAN-, Funk- und Callsign-Konflikte im Multiplayer.
12. Performance und Verhalten bei mehreren gleichzeitig aktiven AARAs.

Ein erfolgreicher Kartendarstellungs- oder CombatFlite-Test reicht nicht für den Status `VALIDATED`.

## 10. Projektentscheidungen

Für den aktuellen Stand gelten:

- Die 19 AARAs werden als **historisch orientierte Referenzbibliothek aus dem bereitgestellten ACO-Material** übernommen.
- Es werden nicht automatisch alle Bereiche gleichzeitig aktiviert.
- AARA 16 **Patty** ist der erste Kandidat für einen Test im östlichen Kampagnenschwerpunkt.
- BOOM und MPRS werden als getrennte Fähigkeit modelliert.
- Quellseitige Optimalprofile werden als Startwerte, nicht als DCS-Garantie behandelt.
- Safety Altitudes und ACO-Höhenblöcke dürfen nicht durch eine globale Standardhöhe ersetzt werden.
- Callsigns, TACAN, Frequenz und interne Objekt-ID bleiben getrennte Felder.
- Die bereitgestellten Geometrien werden nicht manuell nachgezeichnet, sondern aus dem KMZ übernommen.
- Eine Implementierung erfolgt erst nach MOOSE-Prüfung und in einer eigenen reproduzierbaren Testmission.

## 11. Quellen

- Graveyard of Empires: *ISAF 2009–2013 – ACO Building*, Teil 1: <https://www.patreon.com/graveyard4DCS/posts/isaf-2009-2013-1-141193187?collection=833534>
- Graveyard of Empires: *ISAF 2009–2013 – ACO Building*, Teil 2: <https://www.patreon.com/graveyard4DCS/posts/isaf-2009-2013-2-141257957?collection=833534>
- Graveyard of Empires: *ISAF 2009–2013 – ACO Building*, Teil 3: <https://www.patreon.com/graveyard4DCS/posts/isaf-2009-2013-3-141708508?collection=833534>
- Projektseitig bereitgestellte PDF-, KMZ-, CombatFlite- und Grafikdateien, Stand 15. Oktober 2025.
- Ergänzende historische Planungsreferenz: *Tankers ROZ Locations*, Graveyard of Empires, 19. November 2024.

## 12. Attribution und Nutzungsgrenze

Die übernommenen Tabellenwerte und Geometrien stammen aus dem bereitgestellten Material von **Graveyard of Empires – A Project for DCS World**. Diese Projektdokumentation dient der internen, nichtkommerziellen Missionsentwicklung. Quellenangabe und Urheberzuordnung sind bei weitergegebenen Ableitungen beizubehalten.
