---
document_id: OMW-AAR-ISAF-ACO
status: BINDING
document_class: SOURCE_DERIVED_DESIGN_REFERENCE
source_status: SOURCE_CAPTURE_COMPLETE
owning_policy: OMW-GOV-001
authoritative_for:
  - OMW AAR-area and ACO mission-design reference for Afghanistan 2009-2013
  - source-derived tanker-area geometry, callsign, altitude and configuration planning constraints
  - OMW tanker mission-data requirements
not_authoritative_for:
  - historical operational ACO authenticity
  - guaranteed historical callsign-to-airframe assignment for every sortie
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - REFERENCE used as governance document status
superseded_by:
source_branch: agent/document-ato-asr-aar-buddy-lasing
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# 29 - ISAF 2009-2013: Air-to-Air Refuelling und ACO-Referenz

## 1. Einordnung

Dieses Dokument ist die verbindliche quellenbasierte Planungsreferenz für AAR Areas, Tanker-Orbits und ACO-bezogene Missionsgestaltung in **Operation Mountain Watch**. Die AAR-Geometrien für den OMW-Szenariozeitraum 2010-2011 werden vorrangig aus der späteren ISAF-Serie 2009-2013 abgeleitet. Frühere OEF-Beispiele dienen als historischer und prozeduraler Kontext, nicht als automatisch gültige OMW-Geometrie.

Der vollständige Quellen-, Tabellen-, KMZ- und CombatFlite-Auswertungstext der ISAF-Serie bleibt unverändert erhalten:

- [`Legacy-AAR-/ACO-Quellenfassung`](evidence/source-records/legacy-29-isaf-aar-aco-source-capture.md)

**Credits für Recherche und Quellenzusammenstellung: Graveyard of Empires - <https://www.patreon.com/cw/graveyard4DCS>**

## 2. Quellenstatus

```yaml
source_author: Graveyard of Empires
isaf_2009_2013_patreon_parts_available: 3/3
pdf_table: evaluated
kmz_geometry: extracted
combatflite_cf: present_but_full_analysis_pending
additional_tanker_articles_evaluated:
  - Tankers Callsigns List
  - Tankers Refueling Altitudes
  - Air Tasking Order - Tankers Configurations
  - Tankers ROZ Locations
  - Air Tasking Order - Example 3 - Air to Air Refueling
source_status: SOURCE_CAPTURE_COMPLETE
```

Die Aussagen sind als Wiedergabe und Projektableitung der bereitgestellten Quellen zu behandeln. Eine vollständige unabhängige historische Verifikation jeder AAR Area, jeder Missionshöhe oder jeder Callsign-Zuordnung wird nicht behauptet.

## 3. Verbindliche Missionsdesign-Grundsätze

- AAR Areas werden als klar benannte, räumlich definierte Gebiete mit Racetrack, Kontrollpunkten und Höhenblock geführt.
- Tankertyp, Receiver-Domain, optimale Höhe, Geschwindigkeit, TACAN, Frequenz, Callsign und Refuelling-System werden getrennt dokumentiert.
- Mehrere Tanker benötigen definierte vertikale Staffelung und Konfliktfreiheit.
- DCS-Turnradien, Orbitverhalten, Geschwindigkeit und tatsächliche Höhenhaltung müssen gegen die geplante Geometrie geprüft werden.
- AAR-Gebiete sind keine automatisch freigegebenen historischen Originalräume; ihre Nutzung ist eine quellenbasierte OMW-Planungsentscheidung.
- Die AAR-Mission wird im ATO-/Mission-Register geführt und gegen die aktive ACO geprüft.
- Receiver-Zuweisung, Air Refuelling Control Time und geplanter Offload werden als eigene Daten geführt.
- Ein Tanker wird nicht allein über Callsign, TACAN oder DCS-Gruppenname identifiziert; er erhält eine stabile Missions-ID.

## 4. Tanker-Callsigns

Die Callsign-Quelle rekonstruiert aus mehreren offenen Hinweisen eine wahrscheinliche Liste für Tanker, die ISAF zwischen 2004 und 2014 unterstützten. Sie warnt ausdrücklich, dass operative Callsigns von Friedens-Callsigns abweichen können und die frühe OEF-Lage nicht unverändert auf spätere ISAF-Jahre übertragen werden darf.

| Callsign-Stamm | In der Quelle zugeordnete Plattform/Nation | OMW-Einordnung |
|---|---|---|
| `ESSO` | britische VC-10 | quellenbasierter historischer Kandidat |
| `PITSTOP` / `POSTMAN` | britische Tristar | quellenbasierter historischer Kandidat |
| `SHELL` | britische KC-135 | quellenbasierter historischer Kandidat; Zuordnung missionsspezifisch prüfen |
| `PYTHON` | US KC-135 | quellenbasierter historischer Kandidat |
| `TEXACO` | US KC-10 | quellenbasierter historischer Kandidat |
| `WHISTLER` | US KC-10 | durch mehrere Hinweise gestützter Kandidat |
| `TOTAL` | französische C-135FR | quellenbasierter historischer Kandidat; auch im ATO-Beispiel verwendet |

Frühe OEF-Hinweise nennen zusätzlich unter anderem `TREVOR` für eine US KC-135 und `FREDDY` für eine britische Tristar. Diese Namen werden nicht ohne missions- und zeitbezogene Entscheidung in die aktive OMW-ATO übernommen.

### 4.1 OMW-Nutzungsregel

1. Callsign-Stämme werden aus der historisch plausiblen Liste ausgewählt.
2. Nummern werden pro ATO-Tag und Tanker eindeutig vergeben.
3. Callsign, Tanker-Mission-ID, DCS-Gruppe, TACAN und Frequenz müssen im Register auf denselben Tanker zeigen.
4. Eine Quellenzuordnung wie `WHISTLER = KC-10` ist eine Planungsreferenz, kein Nachweis für jede einzelne historische Sortie.
5. Bereits in [`OMW-C2-AIRCRAFT-TACTICAL-CALLSIGNS`](47-aircraft-tactical-callsigns.md) definierte projektweite Regeln bleiben verbindlich.

## 5. Refuelling-Systeme und ATO-Codes

Das ATO-Set `REFTSK` beschreibt im ersten Feld das Refuelling-System. Die ausgewertete Quelle führt folgende Codes auf:

| Code | System |
|---|---|
| `BDA` | Boom Drogue Adapter |
| `BOM` | ausschließlich Boom |
| `BWD` | Boom und Wingtip Drogues |
| `CBD` | Boom und Centerline Drogue |
| `CDT` | Centerline und Wingtip Drogues |
| `CLD` | ausschließlich Centerline Drogue |
| `WTD` | Wingtip Drogues |

Die Bezeichnung beschreibt die verfügbare Tankerkonfiguration, nicht automatisch die DCS-Funktionalität. Vor Einsatz wird je Tanker-/Receiver-Paar geprüft:

- Boom- oder Probe-and-Drogue-Kompatibilität;
- Anzahl gleichzeitig bedienbarer Receiver;
- DCS-Modul- beziehungsweise KI-Unterstützung;
- reale und simulierte Offload-Leistung;
- notwendige Adapter- oder Pod-Konfiguration;
- Abweichung zwischen historischer Plattform und verfügbarem DCS-Ersatzmuster.

Weitere relevante Begriffe:

| Kürzel | Bedeutung |
|---|---|
| `ARCT` | Air Refuelling Control Time |
| `ARCP` | Air Refuelling Control Point |
| `ARIP` | Air Refuelling Initial Point |
| `AP` | Anchor Point |
| `ARP` | Air Refuelling Plan |
| `HDU` | Hose Drum Unit |
| `MPRS` | Multi-Point Refuelling System |
| `WARP` | Wing Air Refuelling Pod |
| `FUELREQ` | Fuel Requirement Message |

## 6. Höhenplanung

### 6.1 Spätere ISAF-Baseline 2009-2013

Für OMW ist die in der ausgewerteten 2009-2013-Serie dokumentierte Planung maßgeblich:

- mindestens **4.000 ft vertikaler Block** für einen einzelnen Tanker;
- wenn möglich zusätzliche **1.000 bis 2.000 ft** Flexibilität;
- etwa **7.000 ft Block** für zwei Tanker im selben Gebiet;
- generell **5.000 bis 10.000 ft** vertikaler Luftraum für eine AAR Area;
- als allgemeine Mindesthöhe **10.000 ft AGL**, soweit Terrain, ACO und Verfahren dies zulassen.

Die spätere ISAF-Planung muss zusätzlich die dichte zivile und militärische Luftraumnutzung berücksichtigen. AAR Areas werden zwischen beziehungsweise neben Airways, kontrollierten Flugplatzlufträumen, UAV-Gebieten, Artillerie-ROZ und anderen ACMs eingepasst.

### 6.2 Frühere OEF-Heuristik

Der frühere Artikel zu Tankerhöhen nennt als Ausgangspunkte:

- Upper Airways ungefähr FL310-FL390;
- Lower Airways je nach Route ungefähr FL150-FL290;
- Schutz oberhalb der erwarteten MANPADS-/ungelenkten AAA-Bedrohung durch etwa 10.000 ft AGL;
- Terrain- und Maximum-Elevation-Figure-Prüfung;
- typischer Arbeitsbereich häufig zwischen FL200 und FL290;
- in tiefem südlichem Gelände gegebenenfalls niedrigere Planungswerte um FL160/FL170.

Die Quelle erläutert außerdem einen prozeduralen Mindestbedarf von etwa 3.000 ft um den Tanker für Joining und Leaving. Diese frühe Mindestheuristik wird für OMW **nicht** als vollständiger AAR-Area-Block übernommen, weil die spätere 2009-2013-Quelle größere Blöcke und eine komplexere ACO-Lage dokumentiert.

### 6.3 OMW-Höhenregel

```text
Base Level
= max(
    terrain/MFE plus Sicherheitsmarge,
    Bedrohungsmindesthöhe,
    ACO-/Airway-Deconfliction,
    DCS-stabile Tankerhöhe,
    Receiver-Leistungsgrenzen
  )
```

Der Top Level ergibt sich aus dem benötigten vertikalen Block. Eine veröffentlichte Höhe wird nicht allein aus einem historischen Einzelbeispiel abgeleitet.

## 7. Lage und Zweck von AAR Areas

### 7.1 Operative Funktionen

Die Quellen unterscheiden zwei Hauptzwecke:

1. **Range/Reach:** Betankung von Kräften, die aus dem Arabischen Meer, dem Mittleren Osten, Zentralasien oder Pakistan in den afghanischen Einsatzraum einfliegen.
2. **Endurance:** Aufrechterhaltung längerer CAS-, ISR- und Support-Präsenz in der Nähe der jeweiligen Working Areas.

### 7.2 Frühe OEF-Lagehinweise

Für 2001-2002 werden wahrscheinliche Tankerbereiche beschrieben:

- südlich beziehungsweise unmittelbar nach dem Eintritt aus Pakistan;
- nördlich nach Eintritt aus Tadschikistan oder Usbekistan;
- in Reichweite der Schwerpunkte Nordafghanistan, Kandahar/Helmand und Khost/Jalalabad;
- bei Endurance-Unterstützung als grobe Heuristik nicht wesentlich mehr als etwa 15 Minuten vom Arbeitsgebiet entfernt.

Zusätzliche Faktoren:

- geeignete Notlandeplätze;
- Erreichbarkeit durch CSAR-Kräfte;
- Vermeidung sehr hoher zentraler und nordöstlicher Gebirgsräume, wenn Terrain, Aircraft Ceiling oder Rettungsreichweite den Risikozuwachs nicht rechtfertigen;
- keine vollständige Abdeckungslücke im Theater, soweit dies ohne ACO-Konflikt möglich ist.

### 7.3 OMW-Regel für 2010-2011

Für OMW werden die tatsächlich aus der ISAF-Serie 2009-2013 extrahierten AAR Areas und Geometrien als Primärreferenz verwendet. Die frühen OEF-Lagehinweise helfen bei Plausibilitätsprüfung und Reserveplanung, ersetzen aber weder KMZ-/CombatFlite-Daten noch ACO-Abgleich.

Bei jeder Area werden mindestens geprüft:

- zivile und militärische Airways;
- Class-C-/Class-D-/Class-E-Lufträume;
- Flugplatzan- und -abflugrouten;
- Artillerie-, Schießplatz-, UAV-, ISR- und Trainings-ROZ;
- Terrain und MFE;
- Receiver-Entfernung zu den geplanten Working Areas;
- Ausweichflugplätze und CSAR-Reichweite;
- DCS-Kartengrenzen und KI-Verhalten.

## 8. ATO-Darstellung einer Tankermission

Die ausgewertete ATO-Beispielmission beschreibt:

```text
Mission 1AT101
1 x C-135FR TOTAL31
Abflug/Recovery UCFM Manas
AAR-Orbit RUSH
1330Z-1900Z
FL260
BDA
5.000 lb geplanter Offload
Receiver 1AT204 / RAGE51
2 x Mirage 2000D
4.800 lb Receiver-Offload
ARCT 1415Z
```

Relevante ATO-Sets:

| Set | Funktion |
|---|---|
| `AMSNDAT` | Mission, Rolle, Abflug und Recovery |
| `MSNACFT` | Tankertyp, Anzahl, Callsign, Konfiguration und IFF |
| `AMSNLOC` | Orbit, Zeitfenster und Höhe |
| `REFTSK` | Refuelling-System, Gesamt-/Contingency-Offload, Frequenzen und TACAN |
| `5REFUEL` | Receiver-Mission, Callsign, Anzahl, Typ, Offload und ARCT |
| `CONTROLA` | Kontrollstelle, Callsign, Frequenzen und Report-in Point |

Die vollständige ATO-Struktur steht in [`OMW-C2-ATO-ACO-SPINS`](54-air-tasking-order-aco-spins.md).

## 9. Verbindliche OMW-Datenstruktur

```yaml
TankerMission:
  missionId:
  atoPeriod:
  tankerType:
  tankerCount:
  callsign:
  departureLocation:
  recoveryLocation:
  aarAreaId:
  orbitName:
  orbitGeometry:
  baseLevel:
  topLevel:
  plannedAltitude:
  speed:
  startTime:
  endTime:
  refuellingSystem:
  fuelType:
  plannedTotalOffload:
  contingencyOffload:
  tacan:
  primaryFrequency:
  secondaryFrequency:
  controlAuthority:
  receiverAssignments:
  warehouseSource:
  status:
  source:

ReceiverAssignment:
  receiverMissionId:
  receiverCallsign:
  receiverType:
  receiverCount:
  requestedOffload:
  arct:
  sequence:
  refuellingSystemRequired:
  status:
```

## 10. Technische Zielartefakte

- maschinenlesbares AAR-Area-Register;
- Mission-Editor-Zonen, Kontrollpunkte und Orbitlinien;
- Tanker-Templates und MOOSE-`AUFTRAG`-/AIRWING-Konfiguration;
- Receiver-Kompatibilitätsmatrix;
- ATO-/Kneeboard- und Briefingtabellen;
- Konfliktprüfung gegen Flugplätze, Airways, Trainingsräume, ROZ und Missionsziele;
- Callsign-, Frequenz-, TACAN- und Mission-ID-Konsistenzprüfung;
- Warehouse- und Fuel-Offload-Modell.

## 11. Noch erforderliche Validierung

- vollständige technische Auswertung der `.cf`-Datei;
- Geometrieabgleich KMZ, DCS und Mission Editor;
- Tankerturns, Trackhaltung und Höhenstabilität;
- Boom-/Drogue-Eignung je Receiver;
- reale DCS-Offload- und Recovery-Logik;
- Multiplayer-, TACAN- und Funkverhalten;
- mehrere gleichzeitig aktive Tanker und vertikale Staffelung;
- Retasking und Receiver-Queue;
- Performance- und Persistenzverhalten.
