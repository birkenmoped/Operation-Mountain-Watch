---
document_id: OMW-HIST-AFGHANISTAN-FORCE-BASING-AVIATION
status: BINDING
document_class: HISTORICAL_RESEARCH_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-qualified historical force, basing and aviation research for Afghanistan 2010-2011
  - source-qualified operational patterns and aviation employment examples
  - source register, contradictions, exclusions and open research items for this subject
not_authoritative_for:
  - active campaign air ORBAT
  - local campaign inventory decisions
  - final Mission Editor placement
  - DCS or MOOSE technical acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: docs/afghanistan-force-aviation-source-consolidation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# 50 – Afghanistan 2010–2011: Kräfte, Basen, Army Aviation und Einsatzmuster

## 1. Zweck und Autoritätsgrenze

Dieses Dokument konsolidiert die vom Projektinhaber bereitgestellten offiziellen Publikationen, Fachtexte, Webseiten, DVIDS-Medien und Bildbeobachtungen zu:

- theaterweiter Kräfte- und Führungslage;
- US- und Koalitionsverbänden;
- Flugplätzen, FOBs, COPs, Patrol Bases und FARPs;
- OH-58D-, AH-64-, UH-60- und CH-47-Einsätzen;
- ausgewählten USAF-/USMC-Luftfahrteinheiten;
- Air-Assault-, Aufklärungs-, Escort-, FARP-, MEDEVAC- und Sustainment-Verfahren;
- Materialverschleiß, Instandsetzung und logistischen Rahmenbedingungen.

Die Quelle für die **aktive Missions-ORBAT** bleibt ausschließlich:

- [`OMW-AIR-ACTIVE-ORBAT`](19-active-air-orbat-decisions.md).

Neue historische Evidenz in diesem Dokument verändert daher nicht automatisch:

- aktive Staffeln oder Task Forces;
- lokale Kampagnenbestände;
- Spieler-Slots;
- KI-SQUADRONs;
- Statics;
- Warehouse-Bestände;
- basisbezogene Mission-Editor-Manifeste.

Eine Änderung dieser Werte benötigt eine getrennte, ausdrückliche Projektentscheidung.

## 2. Zeitmodell

Der verbindliche OMW-Recherche- und Szenariozeitraum ist:

```text
01.08.2010 bis 31.12.2011
```

Quellenbelege werden zeitlich wie folgt eingeordnet:

| Kennzeichnung | Bedeutung |
|---|---|
| `IN_PERIOD` | unmittelbar innerhalb des Szenariozeitraums |
| `PRE_PERIOD_CONTINUITY` | kurz vor dem 01.08.2010; nur als Kontinuitäts- oder Übergangsbeleg |
| `POST_PERIOD_CONTEXT` | nach dem 31.12.2011; nur technischer oder organisatorischer Vergleich |
| `BACKGROUND_ONLY` | deutlich außerhalb des Zeitraums oder nur allgemeiner Hintergrund |

OMW bildet keine automatisch wechselnde Tages-ORBAT nach. Historische Rotationen bleiben erhalten; die aktive Kampagnenbaseline ist eine getrennte, spielbare Auswahl innerhalb des Gesamtzeitraums.

## 3. Evidenzklassen

| Klasse | Verwendung |
|---|---|
| `DIRECT_OFFICIAL` | explizite Aussage in offizieller US-/NATO-/DVIDS-/CMH-Quelle |
| `CORROBORATED` | durch mehrere voneinander unabhängige Quellen gestützt |
| `SOURCE_DERIVED` | nachvollziehbare Ableitung aus einer Quelle, aber keine ausdrücklich genannte Stärke oder Zuordnung |
| `VISUAL_CONFIRMED` | auf Bild oder Video unmittelbar erkennbar |
| `VISUAL_PROBABLE` | bildlich wahrscheinlich, aber nicht zweifelsfrei identifizierbar |
| `SECONDARY` | Fach- oder Medienquelle ohne Primärquellenstatus |
| `LEAD_ONLY` | Such- oder Verlustlistenhinweis; vor Verwendung als Tatsache zu bestätigen |
| `SOURCE_CONFLICT` | Quellen widersprechen sich oder verwenden unklare Bezeichnungen |
| `EXCLUDED` | für den behaupteten Zweck nicht geeignet |

Jede Zahl bleibt mit ihrer Evidenzklasse verbunden. Eine Schätzung darf nicht als historischer Ist-Bestand ausgegeben werden.

# 4. Quellenregister

## 4.1 Offizielle und bereitgestellte Dokumente

### S01 – *The Afghan Surge: January 2009–August 2011*

- Autor: John J. Mortimer Jr.
- Herausgeber: Center of Military History, United States Army
- Jahr: 2023
- bereitgestellte Datei: `70-135.pdf`
- Quellenwert: offizielle operative Überblicksdarstellung zu Strategie, Führung, Großverbänden, Operationen und ausgewählten Standorten.
- Grenze: kein vollständiger Aviation-ORBAT und keine umfassende Flugplatzbelegung.

### S02 – *Department of the Army Historical Summary, Fiscal Year 2010*

- Autor: Thomas Boghardt
- Herausgeber: Center of Military History, United States Army
- Jahr: 2015
- bereitgestellte Datei: `101-41-1.pdf`
- Quellenwert: theaterweite Personal-, Beschaffungs-, Aviation-, UAS-, M-ATV- und National-Guard-Rahmendaten.
- Grenze: Army-weite oder theaterweite Zahlen sind nicht automatisch lokale Afghanistan-, Flugplatz- oder Einheitsbestände.

### S03 – *Fiscal Year 2011 United States Army Annual Financial Report*

- Herausgeber: United States Army
- bereitgestellte Datei: `Fiscal_Year_2011_Department_of_the_Army_Financial_Statement_and_Notes.pdf`
- Quellenwert: Modernisierung, Rapid Equipping Force, Reset, Depotdurchsatz, Instandsetzung und Materialverschleiß.
- Grenze: überwiegend Army-weite Finanz- und Leistungswerte; keine lokale Afghanistan-ORBAT. Der Bericht weist selbst erhebliche Schwächen der Finanz- und Feeder-Systeme aus.

### S04 – *Allied Participation in Operation Iraqi Freedom*

- Autor: Stephen A. Carney
- Herausgeber: Center of Military History, United States Army
- Jahr: 2011
- bereitgestellte Datei: `59-3-1.pdf`
- Quellenwert: allgemeine multinationalen C2-, Interoperabilitäts- und National-Caveat-Erfahrungen.
- Einstufung: `EXCLUDED` für Afghanistan-Einheiten, Afghanistan-Basen und Afghanistan-Stärken, da Gegenstand Irak 2003–2009 ist.

## 4.2 Fachstudie CH-47

### S05 – Peter W. Connors, *High, Hot and Heavy: The CH-47 Chinook in Combat Assault Operations in Afghanistan*

- bereitgestellter Auszug: `Eingefügter Text.txt`
- Spiegel: <https://studylib.net/doc/6794219/working-paper-high--hot-and-heavy--the-ch>
- Quellenwert: detaillierte CH-47-Stationierungen, Rotationselemente, Air-Assault-Stärken, Missionspakete, Besatzungsinterviews und After-Action-Report-Auswertung.
- Grenze: StudyLib ist ein Spiegel; wichtige Einzelangaben sollen nach Möglichkeit mit den im Working Paper genannten Primärquellen gegengeprüft werden.

## 4.3 USAF-/CENTCOM-Stichtagsliste

### S06 – GlobalSecurity, US CENTCOM Land Based Aircraft, 30 September 2011

- <https://www.globalsecurity.org/military/ops/oef_orbat_air.htm>
- Quellenwert: USAF-/AETF-A-Präsenzliste für einen Stichtag.
- Grenze: **kein vollständiger US-Luftfahrt-ORBAT**; Army Combat Aviation Brigades, Aviation Task Forces und Air Cavalry Squadrons fehlen systematisch.

## 4.4 OH-58D-Biografie und offizielle Medien

### S07 – STRASAM, Ryan Robicheaux

- <https://strasam.org/en/defense/land-weapons-and-systems/afghanistan-memories-of-oh-58d-kiowa-pilot-ryan-robicheaux-3003>
- Quellenwert: persönlicher Einsatzbericht und zeitliche Einordnung.
- Grenze: sekundäre Ortsbezeichnungen wie „Kabul“ sind nicht automatisch eine präzise Stationierungsangabe; offizielle Ortsbelege werden bevorzugt.

### S08 – DVIDS, Übergabe TF Lighthorse an TF Shooter

- <https://www.dvidshub.net/news/60556/tf-shooter-takes-over-aviation-ops>
- Quellenwert: offizieller Verbands-, Standort-, Zeit- und Leistungsnachweis für Jalalabad/FOB Fenty.

### S09 – DVIDS, BAF Hunter

- <https://www.dvidshub.net/audio/24773/baf-hunter-radio-package>
- zugehörige Nutzerquelle: <https://www.dvidshub.net/video/86399/baf-hunter-package-long-version>
- Quellenwert: OH-58D-Sicherungs- und Aufklärungsbetrieb im Raum Bagram am 27.05.2010.
- Einordnung: `PRE_PERIOD_CONTINUITY`.

### S10 – DVIDS, Task Force Destiny OH-58D Test Fire

- <https://www.dvidshub.net/image/363031/101st-cab-kiowa-warriors>
- Datum: 31.01.2011
- Ort: Kandahar Airfield / Red Desert
- Quellenwert: offizieller Bild- und Konfigurationsbeleg.

### S11 – Defense Media Network, OH-58D-Flottenartikel

- <https://www.defensemedianetwork.com/stories/army-focuses-on-oh-58d-kiowa-warrior-fleet/>
- Quellenwert: sekundärer Artikel und Reproduktion des S10-Fotos.
- Quellenkonflikt: Bildunterschrift nennt 31.01.2010; DVIDS-VIRIN `110131` und DVIDS-Metadaten belegen 31.01.2011.

### S12 – DVIDS, 2-17 CAV / Task Force Destiny in Kandahar

- <https://www.dvidshub.net/news/52782/pfc-david-stout-profile-task-force-destiny-soldier>
- <https://www.dvidshub.net/news/52790/profile-destiny-officer-1st-lt-christopher-hess>
- <https://www.dvidshub.net/image/299563/pfc-david-stout-profile-task-force-destiny-soldier>
- Quellenwert: OH-58D-Piloten und -Instandhaltung von Delta Troop, 2-17 CAV, in Kandahar im Mai/Juli 2010.
- Einordnung: `PRE_PERIOD_CONTINUITY` unmittelbar vor Kampagnenbeginn.

### S13 – DVIDS, FOB Wilson FARP / 2-17 CAV

- <https://www.dvidshub.net/video/95599/farp-soldiers-keep-aircraft-fueled-and-armed-short-package>
- <https://www.dvidshub.net/video/95600/farp-soldiers-keep-aircraft-fueled-and-armed-long-package>
- Quellenwert: Forward Arming and Refueling Point auf FOB Wilson am 17.09.2010; E Troop, 2-17 CAV.

### S14 – U.S. Army, Banshee Detachment auf FOB Wolverine

- <https://www.army.mil/article/42209/adopting_a_troop_of_warriors>
- <https://www.army.mil/article/49316/scouts_honor>
- Quellenwert: OH-58D-Detachment ab Anfang Juni 2010 sowie ein Scout Weapons Team aus zwei OH-58D am 06.11.2010.

### S15 – DVIDS, Kiowa Maintainers auf FOB Wolverine

- <https://www.dvidshub.net/video/126076/kiowa-maintainers-enduring-freedom>
- <https://www.dvidshub.net/video/126079/kiowa-maintainers>
- Quellenwert: OH-58D einschließlich lokaler Wartungs- und Bewaffnungsfunktionen auf FOB Wolverine.
- Quellenkonflikt: Video 126076 nennt 20.08.2011; Video 126079 und die gemeinsame VIRIN `110920-M-KN493-001` stützen 20.09.2011 als Paketdatum.

### S16 – DVIDS, Task Force Saber bei Jalalabad, März 2012

- <https://www.dvidshub.net/video/139056/oh-58-kiowa-warriors-long>
- Quellenwert: Konfigurations- und Bewaffnungsvergleich nach dem OMW-Zeitraum.
- Einordnung: `POST_PERIOD_CONTEXT`; nicht rückwirkend auf 2010/2011 anzuwenden.

### S17 – ArmyAircrews Kiowa-Verlustliste

- <http://www.armyaircrews.com/kiowa.html>
- Quellenwert: Recherchehinweise zu Unfällen und Verlusten.
- Einstufung: `LEAD_ONLY`; keine Bestands- oder Stationierungsquelle. Jeder Eintrag benötigt eine unabhängige offizielle Bestätigung.

### S18 – DVIDS, Echo Troop 3-17 CAV und Camp Wright FARP

- <https://www.dvidshub.net/news/44181/echo-troop-3-17-cavalry-regiment-makes-mission-happen>
- <https://www.dvidshub.net/image/240989/farp-they-never-stop>
- Quellenwert: Camp Wright FARP im Januar 2010, Echo Troop 3-17 CAV, ungefähr ein Dutzend Soldaten, 24/7-Betrieb sowie Betankung und Wiederbewaffnung von Task-Force-Lighthorse-Luftfahrzeugen.
- Einordnung: `PRE_PERIOD_CONTINUITY`; FARP-Struktur stützt die spätere Task-Force- und Missionsmodellierung.

### S19 – DVIDS, Craig Joint Theater Hospital auf Bagram

- <https://www.dvidshub.net/video/92479/baf-hospital-cares-injured-afghans-package-short>
- Quellenwert: medizinischer Theaterknoten auf Bagram; die Quelle berichtet für Juli 2010 nahezu 3.000 behandelte US- und afghanische Patienten.
- Einordnung: `PRE_PERIOD_CONTINUITY` unmittelbar vor Kampagnenbeginn.

# 5. Theaterweite Lage und Kräfteansatz

## 5.1 Kräftehöhe

| Datum/Zeitraum | Aussage | Evidenz | Quelle |
|---|---|---|---|
| 21.09.2010 | 65.950 U.S.-Army-Soldaten in Afghanistan | `DIRECT_OFFICIAL` | S02 |
| Mai 2011 | US-Truppenstärke erreicht im Surge nahezu 100.000 | `DIRECT_OFFICIAL`, Diagramm-/Überblickswert | S01 |
| FY 2010 | 11.760 Army-National-Guard-Soldaten zur Unterstützung von OEF eingesetzt | `DIRECT_OFFICIAL`; OEF nicht vollständig auf Afghanistan begrenzt | S02 |
| FY 2010 | 58 Army-/Air-National-Guard-Angehörige in einer Agribusiness Development Task Force in Afghanistan | `DIRECT_OFFICIAL` | S02 |

Diese Zahlen sind **theaterweit**. Sie dürfen weder auf RC-East noch auf einen einzelnen Flugplatz oder eine FOB heruntergerechnet werden.

## 5.2 Geografie und Mobilität

S01 beschreibt Afghanistan als stark segmentierten Operationsraum:

- mehr als die Hälfte der Straßen war unbefestigt;
- Highway 1/Ring Road war die zentrale überregionale Verkehrsachse;
- abgelegene Außenposten waren häufig auf Luftversorgung angewiesen;
- Gebirge, Täler, schlechte Straßen und IED-Bedrohung erhöhten den Bedarf an Rotary-Wing-Transport und Air Assault;
- Witterung, Höhe und Temperatur beeinflussten verfügbare Nutzlast und Flugplanung.

Für OMW folgt daraus:

- `ROAD_CONVOY` und Lufttransport sind komplementär;
- abgelegene FOBs/COPs benötigen abgestufte Versorgungspfade;
- CH-47-Verfügbarkeit ist ein operativer Engpass und kein unbegrenztes Teleportmittel;
- PZ/HLZ, FARP, Nachtflug, Escort und Wetter müssen missionsrelevant sein.

## 5.3 Führungsrahmen

### RC-East

Während des früheren Kampagnenabschnitts führte die 101st Airborne Division als CJTF-101 RC-East. S01 nennt als wesentliche Task Forces:

| Großverband | Task-Force-Bezeichnung | Raum/Funktion | Quelle |
|---|---|---|---|
| 1st BCT, 101st Airborne Division | Task Force Bastogne | RC-East | S01 |
| 173d Airborne Brigade Combat Team | Task Force Bayonet | RC-East | S01 |
| 4th BCT, 101st Airborne Division | Task Force Currahee | RC-East | S01 |
| 3d BCT, 101st Airborne Division | Task Force Rakkasan | RC-East | S01 |
| 3d BCT, 25th Infantry Division | Nachfolger von TF Bastogne ab April 2011 | Nuristan, Nangarhar, Kunar | S01 |
| 2d Battalion, 35th Infantry Regiment | Task Force Cacti | Pech-/Watapur-Planung 2011 | S01 |

Der spätere Führungswechsel zu CJTF-1 bleibt gemäß Dokument 09 Teil des Kampagnenrahmens. Eine Einzelmission darf nur eine in sich konsistente Führungsbaseline verwenden.

### RC-South und RC-Southwest

Die Teilung im Juni 2010 führte zu:

- RC-South: Kandahar, Daykundi, Uruzgan, Zabul;
- RC-Southwest: Helmand, Nimroz und Teile Farahs.

Im November 2010 übernahm die 10th Mountain Division RC-South. Die Trennung ist im Missionsdesign für Zuständigkeiten, Lufttasking, Logistik und Basiszuordnung zu beachten. Quelle: S01.

### RC-North

S01 belegt:

- 1st BCT, 10th Mountain Division;
- 1st Battalion, 87th Infantry Regiment auf FOB Kunduz und FOB Pul-e-Khumri;
- Unterstützung von rund 1.200 deutschen Soldaten und afghanischen Kräften.

Die Zahl 1.200 beschreibt die unterstützten deutschen Kräfte im genannten Kontext, nicht die Garnison jedes Standorts.

# 6. Historischer Standortkatalog

## 6.1 Strategische und regionale Luftfahrtknoten

| Standort | Belegte Funktion im Zeitraum | Evidenz | Quellen |
|---|---|---|---|
| Bagram Airfield | strategischer Luft-, Logistik-, Rescue-, Transport-, medizinischer und Army-Aviation-Knoten; OH-58D-Sicherungsbetrieb bereits Mai 2010; CH-47- und weitere Aviation-Elemente im Zeitraum | `CORROBORATED` | S05, S06, S09, S19 |
| Jalalabad Airfield / FOB Fenty | regionaler multifunktionaler Army-Aviation-Hub für Nangarhar, Nuristan, Kunar und Laghman; TF Lighthorse bis Nov. 2010, danach TF Shooter | `DIRECT_OFFICIAL` | S08, S05 |
| Kandahar Airfield | großer USAF- und Army-Aviation-Knoten; Task Force Destiny/101st CAB; 2-17 CAV OH-58D; CH-47-Pool; A-10, C-130, MQ-1/MQ-9 und Rescue am Stichtag 30.09.2011 | `CORROBORATED` | S05, S06, S10, S12 |
| FOB Salerno / Khost | RC-East Aviation- und CH-47-Detachment-Standort; B/7-158-Hauptquartier ab April 2011 laut Working Paper | `SECONDARY`, primärquellenbasiertes Working Paper | S05 |
| FOB Shank | kleiner, intensiv genutzter CH-47-Detachment-Standort; später Teil der B/7-158-Verteilung | `SECONDARY`, detailliert belegt | S05 |
| FOB Sharana | CH-47-/Army-Aviation-Standort beziehungsweise Detachment; Übergang auf 6-6 CAV im Dezember 2010 laut Working Paper | `SECONDARY` | S05 |
| FOB Wolverine | OH-58D-Detachment ab Juni 2010; zwei OH-58D im Nov. 2010 direkt belegt; CH-47-Platoon ab 2011; lokale Kiowa-Wartung 2011 | `CORROBORATED` | S05, S14, S15 |
| Tarinkot / Tarin Kowt | vorgeschobener CH-47-Platoon-/Detachment-Standort ab 2011; Bestandteil des Kandahar-Regionalpools | `SECONDARY`, detailliert belegt | S05 |
| Shindand Air Base | USAF-Air-Advisor-Struktur am 30.09.2011; 438 AEW, 838 AEAG, 444 AEAS | `SECONDARY` für Stichtagsliste; keine Army-Aviation-Stärke daraus | S06 |
| Kabul | AETF-A-Hauptquartier und Air-Advisor-/Supportstrukturen; politischer und logistischer Rückraum | `SECONDARY` für Stichtagsliste | S06 |
| Herat | Air-Advisor-Detachment; Transport-/Koalitionsknoten | `SECONDARY` | S06 |
| Mazar-e Sharif | Air-Advisor-Detachment | `SECONDARY` | S06 |

## 6.2 FOBs, COPs, Patrol Bases und FARPs

| Standort | Historische Aussage | Missionsrelevanz | Quellen |
|---|---|---|---|
| COP Stout | im Arghandab-Raum als Teil der Hamkari-/Dragon-Strike-Operationen eingerichtet | Außenposten, Sicherung, IED-/Infanteriedruck | S01 |
| Außenposten bei Babur | nach COP Stout weiter nördlich eingerichtet; Name in S01 nicht genannt | kleiner vorgeschobener Stützpunkt | S01 |
| Patrol Base Dakota | Marine-Stützpunkt im Marjah-Hold-/Build-Kontext | Patrol Base, lokale Sicherung | S01 |
| FOB Kunduz | Standort von 1-87 Infantry | RC-North-Basis | S01 |
| FOB Pul-e-Khumri | Standort von 1-87 Infantry | RC-North-Basis | S01 |
| FOB Blessing | Ende Feb./Anfang März 2011 aufgegeben beziehungsweise an afghanische Kräfte übergeben | Übergabe-, Evakuierungs- und Folgeoperationsszenarien | S01 |
| COP Honaker-Miracle | trotz Pech Realignment gehalten; Schutz Asadabads und Sperre gegen Infiltration | isolierter COP, Belagerung/Resupply/QRF | S01 |
| Camp Wright | FARP von Echo Troop, 3-17 CAV; ungefähr ein Dutzend Soldaten, 24/7-Betrieb, AH-64-Betankung/-Bewaffnung | FARP, Munition, Kraftstoff, Turnaround | S18 |
| FOB Wilson | Forward Arming and Refueling Point von E Troop, 2-17 CAV am 17.09.2010 | FARP für RC-South | S13 |
| FOB Howz-e Madad | Battalion-FOB im Dragon-Strike-Kontext; durch CH-47-Operationen unterstützt | Bodenbasis/Ziel-/Versorgungsknoten; kein alleiniger Beweis dauerhafter CH-47-Stationierung | S01, S05 |
| COP Sayed Abad | Aufnahme-/Startbereich für Talon-Purge-Kräfte | PZ/FOB-Unterstützung; nicht automatisch permanenter CH-47-Bestand | S05 |

## 6.3 Stationierung versus Nutzung

Ein Standort wird nur dann als dauerhafter oder längerfristiger Aviation-Standort klassifiziert, wenn mindestens eines der folgenden Merkmale belegt ist:

- lokale Einheit oder Detachment ausdrücklich genannt;
- Wartungs-, Bewaffnungs- oder Crew-Chief-Personal vor Ort;
- längere split-based-Zuordnung;
- Hauptquartier oder regelmäßiger Direct-Support-Auftrag;
- wiederholte lokale Nutzung mit dokumentiertem Bestandsbezug.

Nicht ausreichend sind allein:

- einzelne Landung;
- Betankungsstopp;
- Verkehrsaufkommen;
- vorhandene DCS-Parkpositionen;
- ein einmaliger Air Assault;
- allgemeine Zuständigkeit eines übergeordneten Verbands.

# 7. OH-58D Kiowa Warrior

## 7.1 Jalalabad / FOB Fenty – TF Lighthorse und TF Shooter

S08 belegt:

```text
TF Lighthorse
3rd Squadron, 17th Cavalry Aviation Regiment
Stationierung: Jalalabad / FOB Fenty
Einsatz: November 2009 bis Übergabe am 18.11.2010
Unterstützte Räume: Nangarhar, Nuristan, Kunar, Laghman
```

Die Task Force war ausdrücklich multifunktional und umfasste:

- OH-58D Kiowa Warrior;
- AH-64D Apache Longbow;
- UH-60 Black Hawk einschließlich MEDEVAC;
- CH-47 Chinook.

Für die Rotation nennt S08:

- mehr als 30.000 Flugstunden;
- mehr als 130 Engagements;
- mehr als 1.000 Security- und Reconnaissance-Missionen;
- mehr als 30.000 bewegte Personen;
- 400 Combat Air Movements und Air Assaults.

Diese Werte sind **Rotationssummen der gesamten multifunktionalen Task Force**, keine OH-58D-Einzelwerte und keine gleichzeitig aktiven Flugzeugzahlen.

Am 18.11.2010 übernahm:

```text
Task Force Shooter
6th Squadron, 6th Cavalry Aviation Regiment
10th Combat Aviation Brigade
```

Die aktive OMW-Jalalabad-Baseline steht weiterhin ausschließlich in Dokument 19.

## 7.2 Bagram

S09 belegt am 27.05.2010 OH-58D-gestützte Sicherungs- und Aufklärungsflüge über Bagram Airfield und Umgebung. Dieser Nachweis liegt unmittelbar vor dem Szenariobeginn und belegt operative Nutzung, aber keine exakte lokale Stückzahl.

Die STRASAM-Erinnerung S07 verwendet für den ersten Einsatz teilweise die grobe Bezeichnung „Kabul“, erwähnt im Operationsbericht jedoch Bagram. Für präzise Basenzuordnung wird der offizielle Bagram-Beleg S09 bevorzugt.

## 7.3 Kandahar / Task Force Destiny

S12 belegt für Mai/Juli 2010:

- Delta Troop, 2nd Squadron, 17th Cavalry Regiment;
- OH-58D-Piloten;
- lokale Avionik-, Bewaffnungs- und Instandhaltungsfunktionen;
- Kandahar als Standort.

S10 belegt am 31.01.2011 ein OH-58D von Task Force Destiny/101st CAB bei einem Testschießen über dem Red Desert.

Damit ist OH-58D-Präsenz im Kandahar-Raum für den Übergang in den Szenariozeitraum und für Januar 2011 direkt belegt. Eine exakte Squadron-Gesamtstärke folgt daraus nicht.

## 7.4 FOB Wolverine

S14 belegt:

- Ankunft des Banshee-Detachments von Task Force Saber Anfang Juni 2010;
- Auftrag: Schutz der FOB, Unterstützung der Bodentruppen, Aufklärung und Sicherung der Hauptverkehrsroute in Zabul;
- am 06.11.2010 ein Scout Weapons Team aus **zwei OH-58D** beim Einsatz von FOB Wolverine.

S15 zeigt 2011 außerdem Crew Chiefs und Bewaffnungs-/Wartungsarbeit an Kiowas auf Wolverine. Das ist stärker als ein reiner Transitnachweis und stützt einen regulären Detachment- beziehungsweise Einsatzstandort.

Die genaue Squadron-Zuordnung des S15-Medienpakets wird nicht allein aus den Videometadaten abgeleitet.

## 7.5 Typische Zweierformation

S14 und weitere offizielle Kiowa-Berichte stützen das Scout Weapons Team als Zweierteam:

```text
2 × OH-58D
```

Für OMW ist dies der historische Standardansatz für bewaffnete Aufklärung, Route Reconnaissance, Screen, Escort und leichte Feuerunterstützung. Single-Ship-Einsätze sind nicht ausgeschlossen, dürfen aber nicht automatisch als bevorzugtes Standardpaket angenommen werden.

## 7.6 Selbstschutz und Konfiguration

### 31.01.2011, Kandahar

Die visuelle Prüfung von S10 zeigt:

| Merkmal | Bewertung |
|---|---|
| AN/ALQ-144-Familie, charakteristischer IR-Störsender hinter dem Triebwerksbereich | `VISUAL_CONFIRMED` |
| kurzer Siebenrohr-Raketenbehälter, plausibel M260 mit 70-mm-Raketen | `VISUAL_CONFIRMED` auf Systemfamilienebene |
| gegenüberliegender Zweifachträger mit zwei langgestreckten Flugkörpern, plausibel AGM-114 Hellfire | `VISUAL_PROBABLE` |
| genaue Hellfire-Untervariante | nicht bestimmbar |

Das Bild belegt eine reale Test-Fire-Konfiguration, aber nicht deren Häufigkeit als Standard-Einsatzbeladung.

### März 2012, Jalalabad

S16 zeigt zwei OH-58D von Task Force Saber ohne sichtbaren AN/ALQ-144. Da der Nachweis nach dem OMW-Zeitraum liegt, gilt nur:

> Spätestens im März 2012 sind OH-58D im Raum Jalalabad ohne sichtbaren AN/ALQ-144 dokumentiert.

Daraus folgt **nicht**, dass der Störsender 2010/2011 generell entfernt war.

## 7.7 Quellenfehler beim Test-Fire-Foto

S11 nennt in der Bildunterschrift den 31.01.2010. S10 führt:

- Datum 31.01.2011;
- VIRIN `110131-O-9999C-269`;
- Kandahar Airfield;
- Task Force Destiny / 101st CAB.

Für OMW gilt daher 31.01.2011. Die Jahreszahl 2010 in S11 wird als Übertragungsfehler dokumentiert.

## 7.8 ArmyAircrews-Verlustliste

S17 darf nur als Rechercheindex genutzt werden. Die Zahl der dort aufgeführten Verlustereignisse ist **keine stationierte Stückzahl**. Ein Verlustort ist nicht automatisch Heimatbasis; ein Verlustdatum belegt nicht die volle Dauer einer Stationierung.

# 8. CH-47 Chinook

## 8.1 RC-East – September 2010, Operation Talon Purge

S05 beschreibt im Chak District/Wardak:

- knapp 350 US-Fallschirmjäger und afghanische Kommandos;
- fünf HLZs;
- 4 × CH-47;
- 2 × UH-60;
- zwei CH-47 aus dem Shank-/168th-Aviation-Element;
- zwei CH-47 von B Company, 2-3 Aviation, aus Bagram;
- Shank-Paar: je fünf Umläufe;
- Bagram-Paar: je drei Umläufe;
- ungefähr 30 Passagiere je CH-47 und Umlauf.

Dies ist ein direkter Planungsmaßstab für große, mehrwellige Air Assaults. Die 350 Personen waren nicht gleichzeitig in vier Chinooks geladen, sondern wurden über mehrere Turns und mehrere HLZs eingesetzt.

## 8.2 FOB Shank

S05 nennt für 2010:

- zwei CH-47 am Standort;
- 30 Tage ununterbrochener Tag-/Nachtbetrieb in einer beschriebenen Phase;
- FOB-Höhe ungefähr 6.600 ft;
- etwa 90 Prozent der angeflogenen HLZs mindestens 6.000 ft;
- wiederkehrenden Ablauf aus Infiltration, Versorgung und Exfiltration.

Quellenkonflikt:

- Haupttext: `D Company, 1-169 AVN`;
- Fußnote 53: `B Company, 1-169 GSAB`, 4-3 AVN zugeordnet.

OMW übernimmt die Standort- und Stärkeaussage, aber schreibt die Company-Bezeichnung nicht ohne weitere Primärquelle endgültig fest.

## 8.3 Jalalabad und Bagram – B/3-10 GSAB

S05 beschreibt für den späteren Teil 2010 eine Aufteilung:

- Jalalabad: Direct Support für 1st BCT, 101st Airborne Division;
- Bagram: General Support für RC-East.

Die Quelle nennt „several“ CH-47 in Jalalabad, jedoch keine exakte lokale Zahl. Die Besatzungen flogen mindestens 200 Air Assaults während der betrachteten Rotation.

Ein häufiges Paket war:

```text
2 × CH-47F
2 × AH-64 Escort
Nachtinsertion
```

## 8.4 Dezember 2010 – Übergang Jalalabad/Sharana

S05 beschreibt, dass CH-47-Elemente von 6-6 CAV im Dezember 2010 Elemente von 3-17 CAV an Jalalabad und FOB Sharana ersetzten.

Da beide Cavalry Squadrons primär als multifunktionale Task-Force-Hauptquartiere zu verstehen sind, wird daraus **keine organische Chinook-TOE** dieser Squadrons abgeleitet. Die CH-47 waren wahrscheinlich angegliederte beziehungsweise task-organisierte Elemente.

## 8.5 März/April 2011 – Bullwhip und B/7-158 AVN

S05 beschreibt:

- gemeinsame CH-47-Unterstützung durch 6-6 CAV und 3-10 GSAB bei Operation Bullwhip im Galuch Valley/Laghman;
- Ankunft von B Company, 7-158 AVN im April 2011;
- 19 organische CH-47;
- zusätzlich 6 CH-47 mit Besatzungen von B Company, 2-135 GSAB;
- Gesamtpool: 25 CH-47;
- Verteilung auf Bagram, FOB Salerno und FOB Shank;
- Salerno als Company-Hauptquartier;
- Bagram für ISAF-weite General-Support-Aufgaben;
- Shank für 1st BCT/10th Mountain Division und Village Stability Operations.

Die genaue Verteilung der 25 Flugzeuge auf die drei Standorte wird nicht genannt und bleibt offen.

Die späteren Rotationssummen von 12.300 Flugstunden und 478 deliberate/hasty combat assaults dürfen nicht vollständig auf die Monate bis April/Mai 2011 zurückgerechnet werden.

## 8.6 RC-South – Dragon Strike

S05 nennt für September 2010:

- 21 CH-47 aus B/6-101 AVN, B/5-158 AVN und einem australischen Rotary-Wing-Detachment;
- 24 Air Assaults im ersten Monat;
- acht durch Feindfeuer getroffene Chinooks in der ersten Woche;
- vier Chinooks pro Nacht für Nachschubaufträge;
- zeitweise vier für sechs Wochen dem 2d BCT zugewiesene Chinooks.

Diese Werte belegen:

- hohe Feindbedrohung gegen An- und Abflugkorridore;
- außergewöhnlich hohen Bedarf an Nachttransport;
- getrennte Pools für Assault und Sustainment;
- Notwendigkeit von Battle-Damage-, Ersatz- und Maintenance-Reserven.

## 8.7 Februar 2011 – 159th CAB

S05 beschreibt den Übergang von der 101st CAB auf die 159th CAB und nennt:

| Einheit | Muster |
|---|---|
| B Company, 7-101 AVN | CH-47F |
| B Company, 1-171 AVN, Hawaii ARNG | CH-47D |
| B Company, 1-52 AVN, Alaska | CH-47D |

Die Mehrheit der Chinooks lag in Kandahar. Je ein Platoon wurde Tarinkot und FOB Wolverine zugeordnet.

Für B/1-52 AVN beschreibt die Quelle:

- ungefähr die Hälfte in Kandahar;
- übrige Maschinen zwischen Wolverine und Tarinkot geteilt;
- sofortige Direct-Support-Aufträge an allen drei Orten.

Typischer Night Cordon and Search:

```text
2 × CH-47
ungefähr 70 Soldaten gesamt
2–5 Tage Bodeneinsatz
anschließende Exfiltration
```

## 8.8 B/1-171 AVN – Quellenkonflikt

Eine Fußnote in S05 nennt B/1-171 AVN split-based in:

- Bagram;
- Kandahar;
- FOB Salerno;
- FOB Shank.

Der Haupttext vereinfacht dagegen die RC-South-Verteilung. OMW dokumentiert beide Aussagen und nimmt ohne weitere Primärquellen keine exakte lokale Aufteilung vor.

# 9. AH-64 Apache

## 9.1 Multifunktionale Task Forces

S08 belegt AH-64D als Bestandteil von TF Lighthorse in Jalalabad. Die Task Force verband Aufklärung, Attack, Utility/MEDEVAC und Heavy Lift unter einem lokalen Aviation-Hauptquartier.

## 9.2 Escort

S05 belegt AH-64 als typischen Escort für CH-47-Nacht-Air-Assaults:

```text
2 × CH-47
2 × AH-64
```

Bei größeren Operationen waren zusätzliche ISR- und Fixed-Wing-Assets vorgesehen.

## 9.3 FARP-Nutzung

S18 belegt am Camp Wright FARP die schnelle Betankung und Wiederbewaffnung von AH-64 der Task Force Lighthorse. Das stützt:

- vorgeschobene Fuel-/Ammo-Knoten;
- kurze Turnaround-Zeiten;
- Wiedereinsatz nach Refuel/Rearm;
- kleine, rund um die Uhr arbeitende FARP-Teams.

## 9.4 Operation Bulldog Bite

S01 nennt für 12.–25.11.2010 im Watapur District/Kunar:

- AH-64 Apache;
- OH-58D Kiowa;
- weitere Hubschrauber;
- USAF-Unterstützung;
- Alaska Air National Guard, 212th Rescue Squadron;
- F/A-18.

Apaches und Kiowas verschossen ihre mitgeführte Munition und wurden durch weitere Hubschrauber abgelöst. Danach erfolgte ein F/A-18-Angriff mit einer 2.000-lb-Bombe danger close.

Für OMW ergibt sich:

- Munitionsausdauer ist begrenzt;
- FARP oder Rotation ist einsatzentscheidend;
- ein Feuerunterstützungspaket kann von Rotary-Wing-Fires zu Fixed-Wing-CAS übergehen;
- Ablösung und Tank-/Munitionszustand müssen in längeren Gefechten modelliert werden.

# 10. UH-60, MEDEVAC und medizinische Knoten

## 10.1 Logar

S03 zeigt einen U.S.-Army-UH-60 im Flug über der Provinz Logar. Einheit, Datum, Basis und Mission werden nicht genannt. Der Beleg erlaubt daher nur:

> U.S.-Army-UH-60-Betrieb über Logar ist fotografisch dokumentiert.

Eine Stationierung auf FOB Shank, Bagram, Kabul oder einem anderen Platz folgt daraus nicht.

## 10.2 Talon Purge

S05 nennt 2 × UH-60 zusätzlich zu 4 × CH-47 bei Operation Talon Purge. Die konkrete Rolle der beiden Black Hawks ist im bereitgestellten Auszug nicht vollständig aufgeschlüsselt; eine automatische Einstufung als MEDEVAC wäre daher unzulässig.

## 10.3 MEDEVAC-Grundmodell

S08 belegt MEDEVAC-UH-60 innerhalb der multifunktionalen Jalalabad-Task-Force. Die konkrete OMW-Two-Ship-Regel ist eine Projektentscheidung in Dokument 18/19 und darf nicht fälschlich als allgemeine historische TOE-Aussage ausgegeben werden.

## 10.4 Craig Joint Theater Hospital

S19 belegt Bagram als großen medizinischen Aufnahmeknoten. Die Quelle nennt für Juli 2010 nahezu 3.000 behandelte US- und afghanische Patienten. Dies stützt Bagram als MEDEVAC-/CASEVAC-Ziel und medizinischen Kampagnenknoten, ohne daraus eine vollständige medizinische ORBAT abzuleiten.

# 11. USAF-/USMC-Stichtag 30.09.2011

S06 liefert eine **AETF-A-/USAF-zentrierte Präsenzliste**. Sie ist keine vollständige Joint-Air-ORBAT.

## 11.1 Bagram

| Einheit | Muster/Funktion | Quelle |
|---|---|---|
| 455th Air Expeditionary Wing | übergeordneter USAF-Verband | S06 |
| 774th Expeditionary Airlift Squadron | C-130J/J-30 | S06 |
| 41st Expeditionary Electronic Combat Squadron | EC-130H | S06 |
| 492nd Expeditionary Fighter Squadron | F-15E | S06 |
| 510th Expeditionary Fighter Squadron | F-16C | S06 |
| 4th Expeditionary Reconnaissance Squadron | MC-12W | S06 |
| 56th Expeditionary Rescue Squadron | HH-60G | S06 |
| VMAQ-3, USMC | EA-6B | S06 |

Die Liste enthält keine Stückzahlen.

## 11.2 Kandahar

| Einheit | Muster/Funktion | Quelle |
|---|---|---|
| 451st Air Expeditionary Wing / Operations Group | übergeordnete Struktur | S06 |
| 702nd Expeditionary Airlift Squadron | C-27J | S06 |
| 772nd Expeditionary Airlift Squadron | C-130J/J-30 | S06 |
| 42nd Expeditionary Attack Squadron | MQ-9 | S06 |
| 75th Expeditionary Fighter Squadron | A-10C | S06 |
| 62nd Expeditionary Reconnaissance Squadron | MQ-1B | S06 |
| 26th Expeditionary Rescue Squadron | HH-60G | S06 |
| 46th Expeditionary Rescue Squadron | HH-60G | S06 |
| 651st Air Expeditionary Group | geteilter Standort Kandahar/Camp Bastion seit 29.06.2011 | S06 |

Auch hier fehlen Stückzahlen.

S06 führt unter Kandahar außerdem `455th Expeditionary Maintenance Group` beziehungsweise eine entsprechende Mission-Support-Bezeichnung. Dies steht im Verdacht eines Übertragungsfehlers, da die 451st-Struktur am Standort belegt ist. OMW markiert dies als Quellenanomalie und korrigiert den Eintrag nicht ohne gesonderten offiziellen Nachweis im Datensatz.

## 11.3 Jalalabad, Kabul, Herat, Mazar-e Sharif und Shindand

S06 nennt Air-Advisor-Strukturen:

- Jalalabad: 438 AEW / 438 AEAG / Detachment 1;
- Kabul: 438 AEW/AEAG und mehrere Advisory Squadrons sowie AETF-A-Hauptquartier;
- Herat: 838 AEAG Detachment 1;
- Mazar-e Sharif: 438 AEAG Detachment 3;
- Shindand: 838 AEAG und 444 AEAS.

Diese Einträge belegen Advisory-/Support-Präsenz, nicht automatisch permanente US-Kampfstaffeln.

# 12. Operationen und Missionsmuster

## 12.1 Operation Hamkari / Dragon Strike

S01 beschreibt den Zeitraum 13.09.–06.12.2010 mit Schwerpunkten in Arghandab, Zharey und Panjwa’i.

Belegte Verbände und Funktionen:

| Verband | Raum/Funktion | Quelle |
|---|---|---|
| 1-320 Field Artillery | provisorische Infanterierolle, Arghandab | S01 |
| 1-502 Infantry | östliches Zharey / Makuan | S01 |
| 1-75 Cavalry | zentrales Zharey / Highway 1 | S01 |
| 2-502 Infantry | westliches Zharey / Sangisar | S01 |
| 1-187 Infantry | Panjwa’i | S01 |
| ANA- und Commando-Elemente | Partnerkräfte | S01 |

Missionsrelevante Lage:

- ungefähr 50 gegnerische Angriffe pro Woche im August 2010, etwa 15 pro Woche im Oktober;
- mehr als 100 geräumte IEDs durch Kräfte Abdul Raziqs;
- ungefähr 300 m tiefer IED-Gürtel bei Makuan;
- befestigte Ortschaften, Bunker, Waffenlager und vorbereitete Kampfstellungen;
- ein außergewöhnlicher Luftschlag am 06.10.2010 mit 20 × 2.000 lb und 50 × 500 lb.

Der Großangriff ist **kein Standard-CAS-Loadout**, sondern ein außergewöhnliches, vorbereitendes Ereignis.

Kartografisch benannte Objectives und Räume umfassen unter anderem:

- Columbia;
- Franklin 1 und 2;
- Mississippi;
- Alabama;
- Georgia;
- Lynchburg;
- Nashville;
- Horn of Panjwa’i;
- Mushan;
- Talukan;
- Zangabad;
- Nari Kariz;
- Howz-e Madad;
- Sangisar;
- Pashmul;
- Highway 1.

## 12.2 Operation Bulldog Bite

Zeitraum und Raum:

```text
12.–25.11.2010
Watapur District, Kunar
```

Bodenkräfte laut S01:

- 1-327 Infantry;
- 1-75 Ranger Regiment;
- 2-75 Ranger Regiment;
- afghanische Kräfte.

Luftunterstützung:

- AH-64;
- OH-58D;
- weitere Hubschrauber;
- USAF;
- 212th Rescue Squadron, Alaska ANG;
- F/A-18.

Die Operation eignet sich als Vorlage für mehrtägige, hochintensive Air-Assault-/Raid-Missionen mit Munitionsrotation, Rescue-Standby und Fixed-Wing-CAS.

## 12.3 Pech Realignment

S01 belegt:

- Genehmigung am 15.02.2011;
- Rückzug aus dem Pech Valley ungefähr eine Woche später;
- Aufgabe/Übergabe von FOB Blessing;
- Fortbestand von COP Honaker-Miracle;
- formale Übergabe am 04.03.2011;
- erneute Lageverschlechterung und Aufklärungs-/Operationsplanung im April 2011;
- Kur Bagh als identifizierter Ausgangsraum für Angriffe gegen Honaker-Miracle.

Mögliche OMW-Missionen:

- geordnete Räumung und Rückverlegung;
- Sicherung einer Basisübergabe;
- Nachschub eines isolierten COP;
- ISR und Target Development nach Sicherheitsverschlechterung;
- QRF/MEDEVAC unter indirektem Feuer;
- erneute Vorbereitung einer Air-Assault-Operation.

## 12.4 Jalalabad und Operation Neptune Spear

S01 nennt Jalalabad Airfield am 02.05.2011 als Ausgangspunkt der eingesetzten Spezialkräfte. Die Quelle nennt 23 Navy SEALs, aber keine vollständige Aviation-Einheit, keinen dauerhaften Bestand und keine genaue lokale Stationierung der beteiligten Spezialfluggeräte.

Daraus folgt nur:

> Jalalabad war am 02.05.2011 Ausgangspunkt einer hochklassifizierten US-Spezialoperation.

# 13. Quellenbasierte Aviation-TTPs

## 13.1 Standardpakete

### Light Air Assault

```text
2 × CH-47
2 × AH-64 Escort
optional ISR
optional Fixed-Wing-CAS
Nachtinsertion
```

Quelle: S05.

### Large Air Assault

```text
4 × CH-47
mehrere Turns möglich
mehrere HLZs
Escort
HLZ-ISR
Fire-Support-Plan
Fixed-Wing-Overwatch
```

Quelle: S05.

### Night Cordon and Search

```text
2 × CH-47
ungefähr 70 Soldaten gesamt
mehrere HLZs/PZs möglich
2–5 Tage am Boden
geplante Exfiltration
```

Quelle: S05.

### Kiowa Scout Weapons Team

```text
2 × OH-58D
Route Reconnaissance / Armed Reconnaissance / Screen / Escort / Fire Support
```

Quelle: S14 und weitere offizielle SWT-Belege.

## 13.2 Planungsschritte

S05 beschreibt folgende wiederkehrende Planungselemente:

- Ground Tactical Plan;
- vorläufiger Infiltration Plan;
- Luftkorridore;
- HLZ-Auswahl;
- Air Mission Request;
- HLZ-ISR;
- Apache Escort Request;
- Fixed-Wing Request;
- Pre-Assault Fire Support Plan;
- Electronic-Warfare-Ziele, falls erforderlich;
- Rehearsal;
- Passagier- und Turn-Berechnung;
- Resupply-Plan;
- Exfiltration-Plan;
- gelegentliche False Insertions zur Täuschung.

Diese Schritte sollen in OMW-Briefing, Auftragserzeugung und Missionslogik sichtbar werden, ohne jedes Verfahren unnötig zu mikrosimulieren.

## 13.3 Begrenzte Munitions- und Flugzeitausdauer

S01, S05, S13 und S18 zeigen:

- Rotary-Wing-Fires können ihre Munition während eines langen Gefechts vollständig verbrauchen;
- Ablösung durch frische Luftfahrzeuge war erforderlich;
- FARP-, Rearm-, Refuel- und Battle-Damage-Zyklen waren operativ entscheidend;
- Nacht- und Dauerbetrieb führten zu hoher technischer Belastung.

# 14. Logistik, Material und Einsatzbereitschaft

## 14.1 M-ATV und geschützte Mobilität

S02 belegt:

- M-ATV speziell für Afghanistans schwieriges Gelände ausgelegt;
- mehr als 5.000 M-ATV bis Ende September 2010 nach Afghanistan geliefert.

Daraus folgt für US-Bodeneinheiten im OMW-Zeitraum:

- M-ATV/MRAP sind häufige Patrouillen-, QRF-, Route-Security- und Convoy-Fahrzeuge;
- HMMWV bleiben vorhanden, dürfen aber nicht überall als einziges oder dominierendes geschütztes Fahrzeug dienen;
- genaue lokale Fahrzeugzahlen benötigen standort- oder einheitsspezifische Quellen.

## 14.2 Zusätzlicher Aviation-Bedarf

S02 belegt, dass der hohe Aviation-Bedarf in Afghanistan zur Genehmigung einer zusätzlichen Combat Aviation Brigade führte. Diese wurde durch Konsolidierung vorhandener Aviation Assets gebildet, nicht durch einen vollständigen neuen Materialkauf.

Missionsrelevante Konsequenz:

- Aviation Task Forces konnten task-organisiert und aus mehreren Herkunftseinheiten zusammengesetzt sein;
- Squadron-/Battalion-Bezeichnungen allein bestimmen nicht immer den gesamten lokalen Flugzeugmix;
- angegliederte Detachments müssen im CampaignState vom Parent-Pool abgezogen werden.

## 14.3 UAS

S02 nennt für 2011 mehr als 1.000 Army-UAS „in theater“ und nahezu eine Million Flugstunden. Die Formulierung ist nicht eindeutig Afghanistan-exklusiv und darf nicht als lokale Afghanistan-Stärke verwendet werden.

Genannte Systemfamilien:

- Gray Eagle/Extended Range Multi-Purpose;
- Hunter;
- Shadow;
- Raven.

Der Bericht zeigt außerdem das Triclops-Konzept mit drei unabhängig bedienbaren Sensor-Payloads. Das stützt parallele ISR-Unterstützung mehrerer Bedarfsträger, belegt aber keinen konkreten OMW-Standort oder lokalen Bestand.

### Quellenanomalie MQ-1C

S02 druckt eine Beschaffungszahl von `876 MQ-1C Gray Eagle`. Diese Zahl ist im Verhältnis zum Programm und zu den übrigen Angaben offenkundig unplausibel. OMW bewahrt die Quellenangabe als Anomalie, verwendet sie jedoch **nicht** als Flotten- oder Theaterbestand.

## 14.4 Rapid Equipping Force

S03 nennt für FY 2011:

- mehr als 221 verschiedene Ausrüstungstypen;
- 34.245 einzelne Ausrüstungsgegenstände;
- vorgeschobene Teams zur Ermittlung und kurzfristigen Schließung von Fähigkeitslücken.

Folgerung:

- gleichartige Einheiten können unterschiedliche lokale Sonderausstattung besitzen;
- die Mission darf ausgewählte Sensor-, Schutz- oder Kommunikationsvarianten darstellen, wenn deren Herkunft und Zweck dokumentiert sind;
- dies rechtfertigt keine beliebige, anachronistische Ausrüstung.

## 14.5 Reset und Aviation-Instandsetzung

S03 nennt bis 31.07.2011:

- mehr als 80.000 auf Depotebene bearbeitete Ausrüstungsgegenstände;
- mehr als 290 durch das Aviation Special Technical Inspection and Repair Program wieder gefechtsbereit gemachte Starr- und Drehflügler;
- FY2011-Depotdurchsatz von 101 Luftfahrzeugen und 760 Hubschraubertriebwerken;
- 2,9 Mrd. USD Reset-Aufträge, ungefähr 39 Prozent der neuen Industrial-Operations-Aufträge.

Die Zahlen sind Army-weit, nicht Afghanistan-only. Sie belegen dennoch die Größenordnung des Verschleiß- und Reparaturproblems.

## 14.6 Materialverschleiß

S03 verbindet hohe Belastung mit:

- hohem OPTEMPO;
- rauen Wüsten- und Gebirgsbedingungen;
- begrenzter Depotinstandsetzung im Theater;
- schnellerer Alterung der Flotten als ursprünglich vorgesehen.

Für OMW muss daher getrennt werden:

```text
nominalInventory
missionReadyInventory
maintenanceInventory
damagedInventory
destroyedInventory
```

Ein nominell vorhandenes Luftfahrzeug ist nicht automatisch sofort mission-ready.

# 15. Multinationale Kräfte und Caveats

S04 wird nicht als Afghanistan-ORBAT genutzt. Die dort beschriebenen allgemeinen Erkenntnisse sind jedoch als Planungsprinzip relevant:

- Koalitionspartner besitzen unterschiedliche Rules of Engagement und nationale Caveats;
- manche Kräfte dürfen nur begrenzte Missionen oder Operationsräume übernehmen;
- Fähigkeiten müssen durch andere Partner ergänzt werden;
- gemeinsame C2-, Kommunikations- und Interoperabilitätsplanung ist erforderlich.

Für OMW gilt:

- alliierte Kräfte werden nicht beliebig austauschbar eingesetzt;
- nationale Verantwortungsräume und Missionsbeschränkungen werden in Briefing und Auftrag berücksichtigt;
- diese allgemeinen Lehren ersetzen keine Afghanistan-spezifische Einheitsquelle.

# 16. Verbindliche Quellen- und Widerspruchsregeln

## 16.1 GlobalSecurity ist kein Army-Aviation-Negativnachweis

Das Fehlen von OH-58D, AH-64, UH-60 oder CH-47 in S06 beweist keine Nichtstationierung. Die Tabelle ist USAF-/AETF-A-zentriert.

## 16.2 Bild und Testschießen beweisen keine Standardhäufigkeit

S10 beweist eine fliegbare und verwendete Konfiguration am Testtag. Es beweist nicht:

- häufigstes Combat Loadout;
- Bestandszahl der Einheit;
- flächendeckenden Selbstschutzstandard;
- genaue Hellfire-Untervariante.

## 16.3 Wartungspersonal ist ein starker Standortbeleg

Crew Chiefs, Armament/Missile Repairer und lokale Wartung stützen eine längerfristige Aviation-Präsenz stärker als ein einzelner Tankstopp. Sie liefern dennoch nicht automatisch die volle Detachment-Stärke.

## 16.4 Keine Doppelzählung von Detachments

Split-based- oder vorgeschobene Platoons werden vom Parent-Pool abgezogen. Tarinkot-, Wolverine-, Salerno-, Shank- oder andere Detachments sind keine zusätzlichen Theaterflugzeuge.

## 16.5 Quellenkonflikte bleiben sichtbar

Aktuell dokumentierte Konflikte:

1. Defense Media Network 2010 versus DVIDS 2011 beim Kiowa-Test-Fire-Foto;
2. Wolverine-Video August versus September 2011;
3. D Company versus B Company bei 1-169 AVN auf Shank;
4. vereinfachte RC-South- versus theaterweite Split-Basing-Angabe für B/1-171 AVN;
5. STRASAM-Ortslabel „Kabul“ versus offizielle Bagram-Einsatzangabe;
6. gedruckte, unplausible Zahl `876 MQ-1C` in S02;
7. verdächtige `455th`-Maintenance-/Mission-Support-Bezeichnung unter Kandahar in S06.

Keiner dieser Konflikte wird stillschweigend aufgelöst.

# 17. Konsequenzen für den Missionseditor und CampaignState

## 17.1 Basisdarstellung

Jeder relevante Aviation-Standort benötigt je nach historischer Rolle:

- Park-/Spawnflächen;
- Warehouse-Anker;
- Kraftstoff- und Munitionsfunktion;
- Maintenance-/Repair-Bereich;
- Crew-/Operationsbereich;
- FARP- oder Rapid-Turnaround-Funktion;
- definierte PZ/HLZ;
- sichere und bedrohte An-/Abflugkorridore;
- QRF-/MEDEVAC-/CSAR-Anbindung.

Nicht jeder Standort benötigt ein eigenes AIRWING. Maßgeblich sind dauerhafte Bestände und die Regeln aus Dokument 18.

## 17.2 Aviation-Zustände

Mindestens erforderlich:

```text
RESERVE
STATIC
PLAYER_RESERVED
PLAYER_ACTIVE
AI_RESERVED
AI_ACTIVE
MAINTENANCE
DAMAGED
DESTROYED
```

Die Quellen zu hoher Flugbelastung und Instandsetzung rechtfertigen zusätzliche planbare Zustände wie:

```text
TURNAROUND_REFUEL
TURNAROUND_REARM
AOG_WAITING_PARTS
FIELD_REPAIR
DEPOT_REPAIR
```

Eine technische Einführung benötigt weiterhin MOOSE-First-Prüfung und Acceptance.

## 17.3 Missionsbedarf

Quellenbasierte MissionDemand-Typen:

- `ARMED_RECONNAISSANCE`;
- `ROUTE_RECONNAISSANCE`;
- `SCOUT_WEAPONS_TEAM`;
- `AIR_ASSAULT_LIGHT`;
- `AIR_ASSAULT_LARGE`;
- `NIGHT_CORDON_SEARCH`;
- `ESCORT_ROTARY_WING`;
- `FARP_RESUPPLY`;
- `REARM_REFUEL_TURNAROUND`;
- `AOG_PARTS_DELIVERY`;
- `DOWNED_AIRCRAFT_RECOVERY`;
- `MEDEVAC`;
- `CSAR_SUPPORT`;
- `COP_EMERGENCY_RESUPPLY`;
- `BASE_TRANSFER_SECURITY`;
- `ISR_TARGET_DEVELOPMENT`.

## 17.4 KI- und Performancegrenzen

Historische Operationen mit vier oder mehr CH-47 und mehreren Escort-/ISR-/CAS-Assets überschreiten möglicherweise die aktuelle globale KI-Sicherheitsgrenze aus Dokument 18. Historische Größe wird deshalb nicht einfach durch gleichzeitig aktive KI erzwungen.

Zulässige Darstellungsformen:

- gestaffelte Wellen;
- virtuelle Vor- oder Nachläufe;
- Spieler als Teil des Pakets;
- begrenzte aktive Escort-Komponente;
- CampaignState-Abbildung nicht sichtbarer Turns;
- isolierte Performance-Tests vor Anhebung einer Grenze.

# 18. Nicht aus den Quellen ableitbar

Trotz der breiten Quellenlage bleiben ohne weitere Belege offen:

- vollständige lokale Stückzahlen aller Army-Aviation-Verbände;
- Mission-Ready-Raten je Basis und Tag;
- genaue Company-/Platoon-Verteilung aller split-based CH-47-Verbände;
- vollständige OH-58D-Stärke auf Bagram, Kandahar oder Wolverine;
- genaue Hellfire-Untervariante auf dem Test-Fire-Foto;
- flächendeckender Ausrüstungsstand mit AN/ALQ-144 oder CMWS;
- konkrete Tail Numbers der meisten lokalen Bestände;
- genaue FOB-Garnisonsstärken;
- endgültige DCS-Parkpositionen und statische Objektverteilung;
- vollständige USAF-/USMC-/Army-Joint-ORBAT aus S06;
- genaue Afghanistan-Anteile vieler Army-weiter FY2011-Zahlen.

# 19. Forschungsbedarf

Priorisierte nächste Schritte:

1. Primärquellenprüfung der in S05 zitierten Interviews und After-Action Reports;
2. exakte B/1-169-Company-Bezeichnung auf FOB Shank;
3. exakte B/1-171-Verteilung zwischen Bagram, Kandahar, Salerno und Shank;
4. lokale Stückzahlen des B/7-158-Pools auf Bagram, Salerno und Shank;
5. vollständige 2-17-CAV-/Task-Force-Destiny-Verteilung in RC-South;
6. genaue OH-58D-Detachment-Stärke auf FOB Wolverine;
7. genaue OH-58D-/AH-64-/UH-60-/CH-47-Aufteilung von TF Lighthorse und TF Shooter;
8. datumsbezogene ALQ-144-/CMWS-Konfigurationen der OH-58D;
9. verifizierte Kiowa-Loadout-Häufigkeiten jenseits einzelner Test-/Einsatzfotos;
10. ArmyAircrews-Ereignisse einzeln gegen DVIDS, Army-Meldungen und Unfallberichte prüfen;
11. GlobalSecurity-Stichtagsliste gegen offizielle USAF-Factsheets und DVIDS-Einheitsmeldungen prüfen;
12. basenbezogene Satellitenbild- und Mission-Editor-Abgleiche getrennt dokumentieren.

# 20. Kurzfassung für die Missionsgestaltung

Historisch besonders belastbar und unmittelbar nutzbar sind:

- Jalalabad/FOB Fenty als multifunktionaler Army-Aviation-Hub;
- Ablösung TF Lighthorse durch TF Shooter im November 2010;
- OH-58D als Scout Weapons Team im Zweierpaket;
- Bagram, Jalalabad, Salerno, Shank, Sharana, Kandahar, Tarinkot und Wolverine als CH-47-/Army-Aviation-relevante Knoten mit unterschiedlicher Evidenzstärke;
- zwei CH-47 plus zwei AH-64 als häufiges Nacht-Air-Assault-Paket;
- vier CH-47 und mehrere Turns für größere Insertionen;
- mehrere HLZs/PZs, ISR, Escort, Fixed-Wing-Overwatch und False Insertions;
- FARP-, Rearm-, Refuel- und Maintenance-Zyklen als operative Notwendigkeit;
- getrennte nominale, mission-ready, wartende, beschädigte und verlorene Bestände;
- M-ATV/MRAP als prägende geschützte Mobilität;
- FOB Blessing, COP Honaker-Miracle, COP Stout, Howz-e Madad, FOB Wilson und Camp Wright als konkrete Szenarioanker;
- Bagram als medizinischer Theaterknoten;
- erhebliche saisonale und operative Intensität während des Surge;
- sichtbare Quellenkonflikte statt künstlicher Scheingenauigkeit.
