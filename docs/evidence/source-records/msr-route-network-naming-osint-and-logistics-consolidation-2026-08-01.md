---
document_id: OMW-EVIDENCE-MSR-ROUTE-NETWORK-CONSOLIDATION-2026-08-01
status: BINDING
document_class: SOURCE_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - consolidated MSR and named-route research state
  - evidence hierarchy for War Diary, official, secondary and forum sources
  - route-name family analysis and limits
  - temporal-alias and overlapping-route analysis
  - Google Earth and KML working method
  - separation of strategic GLOC, MSR, local route, base access and complete convoy routing
scenario_period: 2010-08-01/2011-12-31
source_period: 2004-01-01/2012-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: main
source_commit: 6112e37853f2da11daea90c1e01745eb07ba2fa6
validated_in_dcs: false
---

# MSR-, Routennetz-, Benennungs-, OSINT- und Logistikkonsolidierung

## 1. Zweck

Diese Quellenakte konsolidiert die bisherige Arbeit zu afghanischen Main Supply Routes, regionalen und lokalen militärischen Routen, Routennamen, zeitlicher Verwendung, Quellenkritik, externer Recherche, Google-Earth-/KML-Arbeit und logistischer Einordnung.

Sie ergänzt insbesondere:

- [`OMW-MSR-ROUTE-DESIGN`](../../49-msr-routendesign-und-infrastrukturmarker.md);
- [`OMW-LOGISTICS`](../../05-logistics.md);
- [`OMW-EVIDENCE-AFGHAN-WAR-DIARY-MSR-STAGE3-2026-07-31`](afghan-war-diary-msr-stage3-source-record-2026-07-31.md);
- [`OMW-CIED-ROUTE-CLEARANCE-CONVOY-DESIGN`](../../67-afghanistan-route-clearance-counter-ied-and-convoy-design.md).

Die Akte ist keine endgültige Straßenkarte und keine DCS-`PATHLINE`-Baseline.

## 2. Verbindliche Grundbegriffe

Für OMW sind folgende Ebenen strikt zu trennen:

```text
THEATER_GLOC
→ AFGHAN_ENTRY_NODE
→ STRATEGIC_HUB
→ REGIONAL_HUB
→ MSR / ASR
→ NAMED_ROUTE / RTE
→ LOCAL_ROUTE
→ BASE_ACCESS / ECP / GATE
→ FOB_COP_DESTINATION
```

Zusätzlich ist die komplette Bewegung eines Konvois ein eigenes Objekt:

```text
CONVOY_ROUTING
= Abfolge aus Basiszufahrt, lokalen Routen, einer oder mehreren MSR/ASR,
  weiteren regionalen Routen und Zielzufahrt
```

Eine benannte Route ist daher nicht automatisch identisch mit einer einzelnen zivilen Straße. Umgekehrt kann ein physischer Straßenabschnitt gleichzeitig Teil mehrerer militärischer Designationen und kompletter Konvoiroutings sein.

## 3. Autobahnmodell als zulässige Arbeitsanalogie

Für die Analyse ist folgende Analogie zulässig:

```text
MSR/ASR              ≈ übergeordnete Autobahn oder Hauptversorgungsachse
NAMED_ROUTE/RTE       ≈ Bundes- oder Regionalstraße
LOCAL_ROUTE           ≈ Land-, Tal-, Umgehungs- oder taktische Route
BASE_ACCESS/ECP       ≈ Auffahrt, Abfahrt oder unmittelbare Basiszufahrt
CONVOY_ROUTING        ≈ vollständige Fahrt von Installation A nach Installation B
```

Die Analogie beschreibt die Stellung im militärischen Netz, nicht die bauliche Qualität. Eine afghanische MSR konnte unbefestigt, saisonal eingeschränkt, eng, steil oder nur mit Route Clearance nutzbar sein.

## 4. Strategische Zuführung nach Afghanistan

Die pakistanische Southern Distribution Network-Familie bestand aus zwei großen strategischen Zuführungsachsen:

```text
SDN TORKHAM CORRIDOR
Karachi
→ Pakistan northbound surface route
→ Peshawar / Khyber corridor
→ Torkham
→ Jalalabad
→ Kabul / Bagram logistics hub
```

```text
SDN CHAMAN CORRIDOR
Karachi
→ Quetta
→ Chaman / Weesh–Spin Boldak
→ Kandahar logistics hub
```

Die Torkham-Achse ist geografisch die östliche beziehungsweise südöstliche Zuführung, nicht die südwestliche. Die Chaman-Achse ist die südliche Zuführung nach Kandahar.

Strategische GLOC-Quellen bestimmen keine lokale MSR-Bezeichnung und keine DCS-`PATHLINE`. Nach dem Eintritt in Afghanistan musste Fracht weiterhin über regionale Hubs, Straßenkonvois, Fixed Wing oder Rotary Wing verteilt werden.

## 5. Quellen- und Evidenzhierarchie

### 5.1 Quellenklassen

| Klasse | Quelle | zulässige Verwendung |
|---|---|---|
| A | unabhängige zeitgenössische amtliche Quelle, DVIDS, ISAF/NATO, nationale Militärarchive, offizielle Bildunterschrift, Operationsbericht | Bestätigung von Name, Zeitraum, Korridor, Funktion oder Zwischenpunkt |
| B | offizielle spätere Darstellung, Award Narrative, Unit History, Lessons Learned | starke Bestätigung und Einordnung |
| C | unabhängige seriöse Forschung, Fachbuch oder hochwertige Militärpublikation | Bestätigung und Synthese |
| D | bereitgestellter Afghan-War-Diary-CSV-Datensatz | Primärdatenbestand; nur einmal zählen |
| E | Webspiegel desselben War-Diary-Bestands, Guardian War Logs, WikiLeaks-Suchindex, Scribd-Kopie | keine zusätzliche Bestätigung; nur Navigation oder Transkriptionskontrolle |
| G1 | identifizierbarer Veteran, Teilnehmer, Embedded Reporter oder Kommandeur mit Einheit, Zeitraum und Ortsbezug | starke ergänzende Evidenz |
| G2 | plausibler persönlicher Erfahrungsbericht ohne vollständig prüfbare Identität | ergänzende Evidenz |
| G3 | anonymer Forenbeitrag oder Hörensagen | Suchhinweis, nicht alleinige Bestätigung |
| F | räumliche, zeitliche oder semantische Inferenz | Hypothese, immer gesondert kennzeichnen |

### 5.2 Verbot der Selbstbestätigung

Der War-Diary-Datensatz darf nicht durch einen Webspiegel desselben Datensatzes bestätigt werden:

```text
War Diary CSV
→ WikiLeaks-/Guardian-/Forumskopie derselben Meldung
→ SAME_SOURCE_DERIVATIVE
→ kein neuer Evidenzbeleg
```

### 5.3 Forumsaussagen

Foren-, Blog- und Veteranenaussagen werden dokumentiert mit:

```text
url
username_or_author
post_date
claimed_unit
claimed_deployment_period
claimed_location
route_statement
source_class G1/G2/G3
corroborating_sources
credibility_notes
```

Sie dürfen einen War-Diary-Befund stützen, Zwischenpunkte ergänzen und neue Suchrichtungen erzeugen. Eine anonyme Einzelaussage erzeugt allein keine bestätigte Route.

## 6. Datenbeschaffung und Auswertungsworkflow

### 6.1 War-Diary-Auswertung

Der Projektbestand enthält 734 Berichte mit dem eigenständigen Suchbegriff `MSR`. Die Stufe-3-Auswertung normalisierte 52 Namen und ließ 112 Berichte ohne aufgelösten Namen. Spätere Route-/RTE-/ASR-Auswertung erweiterte den Arbeitsbestand auf 83 identifizierte Routennamen.

Verbindliche Regeln:

1. Wörter nach `MSR` werden nicht blind als Name akzeptiert.
2. Abkürzungen wie `VT`, `HI`, `NV`, `AK` oder `TX` werden nur in eindeutigem Routenkontext normalisiert.
3. Incident-Koordinaten sind keine garantierten Straßenmittelpunkte.
4. Gleichnamige Punkte in räumlich getrennten Clustern werden nicht automatisch verbunden.
5. Endpoint-definierte Korridore ohne Codename bleiben gesondert.
6. Zeiträume, Reporting Units, Regionen und gemeinsam genannte Routen werden getrennt ausgewertet.

### 6.2 Zeit- und Aliasprüfung

Für jedes Namenspaar werden mindestens geprüft:

```text
first_seen
last_seen
temporal_overlap
same_report_count
same_day_count
spatial_overlap
reporting_unit_overlap
route_order
origin_destination_context
```

Zulässige Klassifikationen:

```text
SUCCESSIVE_NAME
CONCURRENT_ALIAS
OVERLAPPING_ROUTE_DESIGNATIONS
ADJACENT_SEGMENTS
LOCAL_NAME_REUSE
NO_SUPPORTED_RELATION
INSUFFICIENT_DATA
```

Wichtige Ergebnisse:

- `Bottle` und `Horseshoe` überlappten zeitlich und werden ausdrücklich an einer Kreuzung gemeinsam genannt. Eine einfache Umbenennung ist ausgeschlossen.
- `Honda` und `Volkswagen` überlappten zeitlich und erscheinen gemeinsam in Bewegungsberichten. Sie sind wahrscheinlich benachbarte oder zusammengesetzte Segmente.
- `Illinois` und `Nevada` erscheinen gemeinsam in langen Fenty–Kabul–Bagram-Bewegungen und sind aufeinanderfolgende MSR-Abschnitte, keine Synonyme.
- `Oregon` und `Bear` überlappten zeitlich. Ein reines Früher-/Später-Modell ist ausgeschlossen; wahrscheinlich liegen überlagerte Bezeichnungsebenen oder Teilabschnitte vor.

### 6.3 Externe OSINT-Suche

Je Route werden mehrere Suchformen verwendet:

```text
"MSR <NAME>" Afghanistan
"Main Supply Route <NAME>" Afghanistan
"Route <NAME>" Afghanistan
site:dvidshub.net "<NAME>"
site:army.mil "<NAME>" Afghanistan
site:marines.mil "<NAME>" Afghanistan
site:defense.gov "<NAME>" Afghanistan
filetype:pdf Afghanistan "<NAME>"
```

Danach werden bekannte Orte, Einheiten, FOBs, COPs und Zeiträume ergänzt. Bildunterschriften, Fotogalerien, Unit Histories, Award Narratives, Engineer Journals, nationale Militärarchive, Veteranenblogs und öffentlich zugängliche Foren sind ausdrücklich einzubeziehen.

### 6.4 Google Earth und KML

Google Earth Pro dient als Prüf- und Digitalisierungsoberfläche. KML ist Arbeits- und Versionsformat; KMZ ist Austauschformat.

Verbindliche Layerstruktur:

```text
REFERENCE_SITES
SOURCE_EVIDENCE_POINTS
CONFIRMED_ROUTE_NAMES
PROBABLE_CORRIDORS
UNRESOLVED_CORRIDORS
COORDINATE_CONFLICTS
DCS_ROUTE_CANDIDATES
```

Keine Linie darf durch automatisches Verbinden von Incident-Punkten entstehen. Vor einer belastbaren Linie sind erforderlich:

```text
Name belegt
+ Endpunkte oder Knoten belegt
+ historische/aktuelle Straßenachse geprüft
+ zeitliche Gültigkeit bewertet
+ Alternativrouten und Namensüberlagerung geprüft
+ DCS-Straße separat validiert
```

KML-Beschreibungen führen mindestens Name, Klasse, Zeitraum, Quellen, Confidence, Geometriequelle, Konflikte und DCS-Status.

## 7. Benennungsfamilien

### 7.1 US-Bundesstaaten

Bundesstaatennamen treten im untersuchten Bestand besonders häufig ausdrücklich als MSR auf. Beispiele:

```text
California
Vermont
Illinois
Nevada
Ohio
Utah
Virginia
Iowa
Rhode Island
Oregon
Florida
Idaho
Montana
Nebraska
Hawaii
Alaska
Georgia
```

Dies ist ein starker Hinweis auf übergeordnete oder regionale Hauptachsen, aber keine ausnahmslose Straßenklassenregel.

### 7.2 Automarken und Fahrzeugmodelle

Beispiele:

```text
Audi
BMW
Civic
Corvette
Dodge
Excel
Ferrari
Honda
Jeep
Miata
Nissan
Volkswagen
Yukon
```

Diese Namen bilden besonders im Paktika-/Paktia-/Orgune-/Zerok-/Bermel-Raum ein dichtes regionales Routennetz. Die Familie spricht für kontrollierte Codewortlisten. Automarken sind jedoch nicht automatisch untergeordnete Straßen; `MSR Honda` und `MSR Audi` zeigen Ausnahmen.

### 7.3 Tiere, Objekte, Formen, Farben und weitere Themen

Beispiele:

```text
Bear, Chicken, Duck, Hyena, Mule, Viper, Whale
Bottle, Horseshoe, Chainsaw, Summit, Torch, Stetson
Blue, Brown, Pink, Violet
Gemini, Libra, Pluto, Uranus, Zodiac
Lithium, Onyx, Topaz
```

Die Namen sind zunächst als militärische Designatoren zu behandeln. Semantische Erklärungen wie `Bottle = Bottleneck`, `Horseshoe = hufeisenförmiger Verlauf` oder `Bear = Bärensichtung` bleiben ohne direkte Quelle Hypothesen. Route Bear ist durch unabhängige Quellen als große Kandahar–Tarin-Kowt-Achse belegt und widerlegt die einfache Regel `Tiername = lokale Nebenstraße`.

### 7.4 Geografische und technische Namen

`Alingar`, `Highway 4`, `Line 8`, `L8`, `Route A`, `Route D` und ähnliche Namen können geografische, zivile oder technische Bezeichnungen sein und sind getrennt von Themenlisten zu behandeln.

## 8. Korridore mit mindestens ungefähr 70 Prozent Arbeitsconfidence

Die Prozentwerte sind methodische Arbeitswerte und keine statistisch berechneten Wahrscheinlichkeiten. Sie bewerten Namen, Korridor und Funktion; sie bestätigen keine exakte Straßenmittellinie.

| Name | Arbeitsconfidence | wahrscheinlicher Start-/Eintrittsknoten | wahrscheinlicher Ziel-/Austrittsknoten | Zwischenpunkte und Route | Status |
|---|---:|---|---|---|---|
| MSR California | 95 % | Asadabad / südlicher Kunar-Knoten | Naray / FOB Bostick | Asadabad → Asmar/COP Monti → Shal-/Dab-Sektor → COP Pirtle-King → Naray/Bostick | unabhängig sehr stark bestätigt |
| MSR Vermont | 92 % | Naghlu Lake / südlicher Surobi-Anschluss | FOB Tagab; nördliche Fortsetzung Richtung Nijrab/Mahmud-e Raqi teilweise belegt | Naghlu → Kora-Pass → Maktab/Landakhel → Tagab; Route-Clearance- und Brückenbelege | unabhängig sehr stark bestätigt |
| MSR Illinois | 88 % | Jalalabad / FOB Fenty-Raum | Kabul-Übergangsraum | Fenty/JAF → Laghman-/Mehtar-Lam-Sektor → Kabul | intern stark; externe Namensbestätigung offen |
| MSR Nevada | 88 % | Kabul-Übergangsraum | Bagram-ECP-/BAF-Raum | Kabul → Bagram-/Shomali-Routennetz; Übergänge zu lokalen Routen | intern stark; externe Namensbestätigung offen |
| Route Bottle | 86 % | Kabul-/Camp-Phoenix-/Eggers-Raum | Bagram Village / BAF-Raum | Kabul–Qarah-Bagh-/Kalakan-Sektor–Bagram; Kreuzung mit Horseshoe | intern stark; Geometrie offen |
| MSR Horseshoe | 82 % | Kabul / Camp-Eggers-Raum | Bagram Village / Bagram-Raum | Old Kabul Road, Estalef-/Shomali-Bezüge, Bagram–Eggers-Bewegung | intern belegt; vollständige Geometrie offen |
| MSR Oregon / Route Bear | 90 % für Korridor | KAF/Kandahar/Highway-1-Anschluss | Tarin Kowt | Arghandab River Valley → Serband Bridge/Checkpoint 18 → FOB Frontenac → Shah Wali Kot → Tarin Kowt | Korridor unabhängig sehr stark; Namensrelation noch getrennt führen |
| MSR Honda / Volkswagen-System | 80 % | FOB Orgun-E | Zerok/Bermel | Orgun-E → Honda → Zerok-Sektor → Volkswagen → Bermel | intern stark; getrennte regionale Honda-Verwendungen beachten |
| MSR Virginia | 78 % | Ghazni-Raum | Gardez-Raum | wahrscheinliche regionale Hauptverbindung | intern stark; externe Vertiefung offen |
| MSR Rhode Island | 75 % | FOB Blessing | Abad-/angrenzender Korridor | lokales Kunar-/Nuristan-nahes Routennetz | intern mittel bis hoch |
| MSR Iowa | 72 % | Kalagush-/Laghman-Raum | Mehtar Lam-/östlicher Laghman-Raum | Kreuzungsbezüge zu Nebraska; genaue Knoten offen | intern mittel bis hoch |
| MSR Alaska | 70 % | Bagram-/Khost-regional je Cluster | regionale Anschlüsse | Name möglicherweise lokal wiederverwendet; Cluster strikt trennen | Name stark, einzelne Geometrie offen |
| MSR Ohio | 92 % für Ghazni-Korridor | Wardak/Sayed-Abad-/FOB-Airborne-Zulauf | südlicher Ghazni-Korridor | Highway-1-Achse → FOB Ghazni → Qarabagh → Ab Band/Andar | physische Highway-1-Ausrichtung starke Inferenz; Namensgrenzen offen |
| MSR Utah | 75 % | Kabul-/Logar-Raum | Gardez/Zurmat-/Sharana-Anschluss | Teilabschnitt längerer Süd-/Südostbewegungen | intern stark; genaue Grenzen offen |

`Start` und `Ziel` sind nur eine einheitliche Leserichtung. Die Routen wurden in beiden Richtungen genutzt und müssen nicht offiziell an einer Installation beginnen oder enden.

## 9. Unabhängig vertiefte Routen

### 9.1 MSR California

Unabhängige Quellen belegen:

- Nord-Süd-Verlauf parallel zum Kunar River;
- Verbindung Asadabad–Asmar–Naray/FOB Bostick;
- alleinige bodengebundene Versorgungsachse für Northern Kunar/FOB Bostick;
- COP Pirtle-King als Zwischenknoten;
- Shal Mountain, Shal Valley und Dab Valley als dominierendes Gelände und insurgente Zuführungsräume.

Quellen:

- https://valor.militarytimes.com/recipient/recipient-84896/
- https://achh.army.mil/regiment/silverstar-oifoef-oifoef1/
- https://www.armyupress.army.mil/Journals/NCO-Journal/Muddy-Boots/Reaching-the-Finish-Line/

### 9.2 MSR Vermont

Unabhängige amtliche und militärhistorische Quellen belegen:

- Naghlu-/Surobi-Anschluss bis Tagab;
- Kora-Pass;
- Maktab und Landakhel;
- Checkpoints 5/6 als zeitgenössische Route-Bezüge;
- Engineer-/IED-Reconnaissance und anschließende Konvoifreigabe;
- Brückenwiederaufbau im OMW-Zeitraum;
- nördliche Route-Clearance zwischen Nijrab und Mahmud-e Raqi als ergänzende Evidenz.

Quellen:

- https://www.dvidshub.net/image/75194/checkpoint
- https://imagesdefense.gouv.fr/fr/operation-road-again.html
- https://imagesdefense.gouv.fr/fr/reconnaissance-du-genie-avec-le-gtia-kapisa.html
- https://www.dvidshub.net/news/68420/prt-welcomes-new-governor-kapisa
- Christophe Lafaye, *L’armée française en Afghanistan. Le Génie au combat. 2001–2012*.

### 9.3 MSR Oregon und Route Bear

`MSR Oregon` ist für 2008 als KAF–Tarin-Kowt-Korridor belegt. Unabhängige Quellen zu `Route Bear` bestätigen denselben übergeordneten Stadt-zu-Stadt-Korridor und zusätzliche Zwischenpunkte:

```text
Kandahar / Highway 1
→ Arghandab River Valley
→ Serband Bridge / Checkpoint 18
→ FOB Frontenac
→ Shah Wali Kot District Center
→ Tarin Kowt
```

Route Bear war eine wichtige Nord-Süd-Verbindung, wurde von mehreren Koalitionsnationen genutzt und war Gegenstand großer Ausbau-, Culvert- und Low-Water-Crossing-Arbeiten.

Die Namen dürfen weiterhin nicht automatisch gleichgesetzt werden. Zulässige Modelle sind:

- `MSR Oregon` als militärischer Gesamtversorgungskorridor und `Route Bear` als physische beziehungsweise regionale Straßenbezeichnung;
- teilweise Überlagerung;
- Bear als großer Teilabschnitt des Oregon-Routings.

Quellen:

- https://voaweb.nl/afghanistan-2008-main-supply-route-msr-oregon/
- https://www.usace.army.mil/Media/News/Article/475345/usace-completes-major-section-of-route-bear-highway/
- https://www.dvidshub.net/news/72760/afghan-national-police-take-another-step-secure-future
- https://www.stripes.com/news/2010-09-02/troops-gingerly-trace-wire-in-kandahar-1950030.html1
- https://michaelyon.com/dispatches/battle-for-kandahar/
- https://www.army.mil/article/50711/the_first_100_daysa_story_of_sustainment
- https://2001-2009.state.gov/r/pa/ei/pix/b/sa/af/36146.htm

### 9.4 MSR Ohio

War-Diary-Evidenz konzentriert Ohio auf den Wardak-/Ghazni-Nord-Süd-Korridor. Unabhängige Army-Quellen bestätigen Highway 1 als zentrale FOB-Airborne-/Wardak–FOB-Ghazni- und Kabul–Kandahar-Hauptachse.

Zulässige starke Inferenz:

```text
physical_road: Afghanistan Highway 1 through Wardak and Ghazni
military_designation: MSR Ohio for a regional military section
probable_core: Sayed Abad / northern Ghazni approach
               → FOB Ghazni
               → Qarabagh
               → Ab Band / Andar
```

Nicht unabhängig bewiesen sind die exakten militärischen Namensgrenzen und die Fortführung bis Kandahar.

Quellen zur physischen Achse:

- https://www.armyupress.army.mil/Journals/Military-Review/English-Edition-Archives/July-August-2024/Light-Infantry-Logistics/
- https://www.armyupress.army.mil/Journals/NCO-Journal/Archives/2013/July/07-01-Welder/

## 10. Wichtige Netzrelationen

### 10.1 Fenty–Kabul–Bagram

```text
FOB Fenty / Jalalabad
→ MSR Illinois
→ Kabul transition area
→ MSR Nevada
→ Bagram access network / ECP
```

Illinois und Nevada sind gleichzeitig verwendete, aufeinanderfolgende Abschnitte eines längeren Routings.

### 10.2 Bottle und Horseshoe

Beide Namen existierten gleichzeitig. Ein Bericht nennt ausdrücklich die Kreuzung beider Routen bei Bagram Village. Horseshoe ist mindestens einmal mit der Old Kabul Road verknüpft und wurde für eine Bagram–Camp-Eggers-Bewegung verwendet.

Zulässige Arbeitshypothese:

```text
Bagram access network
├── Bottle corridor
└── Horseshoe / Old Kabul Road corridor
    → Kabul access network
```

Nicht belegt sind eine vollständige Ost-/West-Zuordnung oder die Namensherkunft.

### 10.3 Orgun-E–Zerok–Bermel

```text
FOB Orgun-E
→ Route/MSR Honda
→ Zerok sector
→ Route Volkswagen
→ Bermel
```

Honda, Volkswagen, Nissan, Yukon, BMW, Ferrari, Dodge und weitere Fahrzeugnamen bilden wahrscheinlich ein regionales, thematisch benanntes Routennetz. Gleichnamige Honda-Nennungen im Pech-/Kunar-Raum müssen separat bleiben.

## 11. Datenmodell für Route, Straße und Routing

Die folgenden Objekte sind getrennt zu führen:

### 11.1 Physischer Straßenabschnitt

```text
roadSegmentId
geometry
civilRoadName
roadType
surface
bridgeOrCrossing
pass
settlement
seasonalLimit
```

### 11.2 Militärische Designation

```text
designationId
name
class: MSR | ASR | ROUTE | RTE | LOCAL_ROUTE | BASE_ACCESS
validFrom
validTo
responsibleCommand
sourceIds
nameConfidence
corridorConfidence
```

### 11.3 Zuordnung Designation zu Straßenabschnitt

```text
designationId
roadSegmentId
sequence
direction
usage
geometryConfidence
```

### 11.4 Komplettes Konvoirouting

```text
routingId
originInstallation
destinationInstallation
orderedDesignations
orderedRoadSegments
vehicleClass
routeClearanceRequirement
validFrom
validTo
```

Damit kann derselbe physische Abschnitt gleichzeitig Teil von `MSR Nevada`, `Route Bottle` und einem `CLP Fenty–Bagram`-Routing sein.

## 12. Confidence und Kartendarstellung

Mindestens drei Confidence-Arten sind getrennt zu führen:

```text
nameConfidence
corridorConfidence
geometryConfidence
```

Empfohlene Darstellung:

```text
CONFIRMED NAME + VALIDATED GEOMETRY      durchgezogen, hohe Breite
CONFIRMED NAME + APPROXIMATE GEOMETRY    durchgezogen, mittlere Breite
PROBABLE CORRIDOR                        gestrichelt oder transparent
UNRESOLVED GEOGRAPHY                     Fläche oder gepunktete Umrandung
SOURCE POINT                             eigenes Symbol; keine Linienableitung
COORDINATE CONFLICT                      X/forbidden, aus Geometrie ausgeschlossen
```

Farben allein reichen nicht aus; Linientyp, Breite, Symbol und Ordnerstruktur müssen die Unterscheidung unterstützen.

## 13. DCS-Überführung

Historische Route und DCS-Route sind getrennte Layer:

```text
historical_route_segment
dcs_route_candidate
```

DCS-Statuswerte:

```text
NOT_TESTED
EDITOR_ALIGNED
AI_ROUTE_ACCEPTED
CONVOY_TEST_PASSED
REJECTED
```

Ein historisch plausibler Abschnitt wird erst nach Hin-/Rückfahrt, Brücken-, Kreuzungs-, Fahrzeugklassen-, Stuck-/Watchguard- und Convoy-Test als DCS-tauglich geführt.

## 14. Offene Arbeitsaufträge

1. externe unabhängige Vertiefung von Illinois, Nevada, Utah, Virginia, Iowa, Nebraska, Florida, Rhode Island und Alaska;
2. kartografische Rekonstruktion Bottle/Horseshoe ohne Punktverbindungsfehler;
3. exakte Übergangsknoten Illinois–Nevada und lokale Bagram-ECP-Routen;
4. Oregon/Bear-Segmentkonkordanz und Namensgrenzen;
5. Ohio/Highway-1-Geltungsgrenzen;
6. getrennte Clusterprüfung wiederverwendeter Namen, besonders Honda, Alaska und Ohio;
7. Google-Earth-Digitalisierung ausschließlich entlang geprüfter Straßenachsen;
8. anschließende DCS-`PATHLINE`- und Convoy-Acceptance.

## 15. Nicht zulässige Schlussfolgerungen

- War-Diary-Webspiegel als unabhängige zweite Quelle zählen;
- alle Punkte desselben Namens automatisch verbinden;
- aus dem Wortinhalt eines Codenamens ohne Quelle eine Namensherkunft ableiten;
- alle Automarken als lokale Straßen oder alle Tiernamen als Nebenstraßen einstufen;
- `MSR Oregon` und `Route Bear` ohne Konkordanz als identisch behandeln;
- `MSR Ohio` ohne ausdrücklichen Beleg mit dem gesamten Highway 1 gleichsetzen;
- strategische SDN-/NDN-Korridore als lokale MSRs oder DCS-`PATHLINE`s verwenden;
- eine Route allein wegen sichtbarer Google-Earth-Straße als historisch belegt oder DCS-befahrbar einstufen.
