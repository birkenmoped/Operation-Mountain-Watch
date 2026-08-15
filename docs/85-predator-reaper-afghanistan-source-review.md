---
document_id: OMW-HIST-PREDATOR-REAPER-AFGHANISTAN-SOURCE-REVIEW
status: BINDING
document_class: HISTORICAL_SOURCE_REVIEW
owning_policy: OMW-GOV-001
authoritative_for:
  - source-qualified review of the newly supplied Predator/Reaper publications
  - MQ-1/MQ-9 type, endurance, armament and Afghanistan-use evidence from those publications
  - reconciliation of those secondary sources with existing OMW 2010-2011 RPA evidence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by:
source_branch: docs/rpa-source-review-2011
source_commit: dfe34543401d36edb16e78d0408a8e595ded5b52
validated_in_dcs: false
---

# Predator und Reaper in Afghanistan - Quellenreview

## 1. Zweck und Autoritaetsgrenze

Dieses Dokument wertet drei neu vom Projektinhaber bereitgestellte Publikationen zum Thema unbemannte Luftfahrzeuge aus und gleicht sie mit den bereits vorhandenen OMW-Quellen zu MQ-1 Predator und MQ-9 Reaper ab.

Neu bereitgestellte Quellen:

1. Bill Yenne, *Drone Strike! UCAVs and Unmanned Aerial Warfare in the 21st Century*, Specialty Press, 2017.
2. Martin J. Dougherty, *Drones: An Illustrated Guide to the Unmanned Aircraft That Are Filling Our Skies*, Amber Books / Metro Books, 2015.
3. Bill Yenne, *Attack of the Drones: A History of Unmanned Aerial Combat*, Zenith Press, 2004.

Eine Suche nach exakten Titeln und Autoren auf `main` ergab vor dieser Aufnahme keine vorhandene OMW-Dokumentation dieser drei Werke. OMW besass jedoch bereits andere, teilweise hoeherwertige MQ-1-/MQ-9-Evidenz, insbesondere USAF-/AFCENT-Quellen, den Juli-2011-ORBAT-Snapshot sowie Air-Ops-Logistik-Referenzen. Die neuen Werke sind daher **neue Quellen**, aber viele ihrer technischen Angaben wirken in OMW primaer als **Sekundaerbestaetigung** und nicht als neue autoritative Typbaseline.

Die historische Quellenhierarchie aus `OMW-GOV-001` bleibt unveraendert: aktuelle BINDING-Projektentscheidungen und direkte offizielle Quellen haben Vorrang vor spaeteren populaerhistorischen oder illustrierten Sekundaerwerken.

## 2. Quellenbewertung

| ID | Quelle | Publikationsstand | OMW-Wert | Hauptgrenze |
|---|---|---:|---|---|
| `YENNE-DRONE-STRIKE-2017` | Bill Yenne, *Drone Strike!* | 2017 | **hoch** fuer anschauliche MQ-1/MQ-9-Betriebs-, Sensor-, Kommunikations- und Kandahar-Nachweise | post-period; viele Fotos und Beispiele liegen nach 2011 |
| `DOUGHERTY-DRONES-2015` | Martin J. Dougherty, *Drones: An Illustrated Guide* | 2015 | **hoch** als kompakte Typ-/Bewaffnungs-/Leistungsreferenz fuer Predator und Reaper | Sekundaerwerk; keine belastbare 2011er Staffel- oder Bestandsquelle |
| `YENNE-ATTACK-2004` | Bill Yenne, *Attack of the Drones* | 2004 | **mittel** fuer Predator-Entwicklung, fruehe OEF-Nutzung und Systemarchitektur | komplett vor OMW-Zeitraum; beschreibt fruehe Predator-Konfigurationen, nicht die 2011er MQ-1B-/MQ-9-Baseline |

Fuer die Auswertung gelten folgende Evidenzklassen:

- `IN_PERIOD_SECONDARY`: Aussage bezieht sich direkt auf 01.08.2010-31.12.2011.
- `PRE_PERIOD_CONTINUITY`: unmittelbar vorausgehende Technik oder Einsatzpraxis mit plausibler Kontinuitaet.
- `POST_PERIOD_CONFIRMATION`: spaetere Quelle bestaetigt Standort, Rollen oder technische Eigenschaften, beweist aber nicht automatisch den Zustand 2010-2011.
- `TYPE_REFERENCE`: technische oder funktionale Typreferenz ohne konkrete OMW-ORBAT-Wirkung.
- `BACKGROUND_ONLY`: historischer Entwicklungskontext ausserhalb des Kampagnenzeitraums.
- `SOURCE_CONFLICT_OR_VARIANT`: Werte unterscheiden sich wegen Variante, Zeitstand oder Sekundaerquellenlage und duerfen nicht stillschweigend vereinheitlicht werden.

## 3. Bereits vorhandene OMW-Evidenz vor diesem Quellenbatch

Vor Aufnahme der drei Werke war in OMW bereits dokumentiert:

- MQ-1: USAF-Typreferenz mit **665 lb / 100 US gal** Treibstoffkapazitaet.
- MQ-1: Air Combat Command identifiziert **AVGAS** als Kraftstoff; MQ-1 darf daher nicht als JP-8-Verbraucher behandelt werden.
- MQ-1: offizielle Afghanistan-Referenz nennt **mehr als 24 Stunden Endurance**.
- MQ-9: USAF-Baseline mit **4,000 lb / 602 US gal** Treibstoffkapazitaet; spaetere ER-Werte werden fuer 2010-2011 nicht ohne Periodennachweis verwendet.
- MQ-9: offizielle Typreferenz nennt **bis zu 14 Stunden voll beladen**.
- OMW fuehrt zusaetzlich quellenabgeleitete MQ-9-Planungsraten aus der bereits dokumentierten Endurance-Evidenz: **33.44 US gal/h bewaffnet** und **20.07 US gal/h unbewaffnet**. Diese Werte sind Planungsraten, **keine gemessenen Fuel-Flow-Werte**.
- AFCENT dokumentiert fuer die 62nd ERS am Kandahar Airfield einen gemischten MQ-1/MQ-9-Betrieb und einen stark gestiegenen RPA-Flugbetrieb bereits bis Juni 2010.
- Der OMW-Juli-2011-ORBAT-Snapshot fuehrt die **361st Expeditionary Reconnaissance Squadron** in Kandahar mit MC-12 sowie MQ-1/MQ-9 und die **62nd Expeditionary Reconnaissance Squadron** als MQ-1/MQ-9-Verband.

Diese vorhandenen direkten beziehungsweise zeitnaeheren Belege bleiben fuer OMW staerker als die drei hier neu ausgewerteten Sekundaerwerke.

## 4. MQ-1 Predator

### 4.1 Entwicklung und Einsatzrolle

Dougherty beschreibt den Predator als aus dem RQ-1 hervorgegangenes MALE-System. Der Erstflug wird auf **1994**, der Produktionsbeginn auf **1997** datiert. Das System wurde zunaechst als Aufklaerungsplattform entwickelt und spaeter bewaffnet. Der Autor betont, dass die Mehrzahl der Einsaetze nicht aus Schlagmissionen, sondern aus langer Ueberwachung, Aufklaerung und Informationsgewinnung bestand. Quelle: Dougherty, S. 79-83.

Yenne beschreibt die Entwicklungslinie ebenfalls vom unbewaffneten Aufklaerer zum bewaffneten Predator und nennt den Einsatz bewaffneter Predator bereits 2001/2002 gegen al-Qaida-Ziele. Quelle: Yenne, *Attack of the Drones*, S. 59-67; Yenne, *Drone Strike!*, S. 48-57.

OMW-Klassifikation: `TYPE_REFERENCE` beziehungsweise `BACKGROUND_ONLY` fuer die fruehen Einsatzbeispiele.

### 4.2 Abmessungen und Leistung

Doughertys Typkasten nennt fuer RQ-1/MQ-1 Predator:

```text
Length:                  8.2 m / 27 ft
Wingspan:               14.8 m / 48 ft 6 in
Height:                  2.1 m / 6 ft 9 in
Engine:                  Rotax 914, 4-cylinder, 4-stroke, turbocharged
Maximum takeoff weight:  1,020 kg / 2,249 lb
Maximum speed:           129 km/h / 80 mph
Range:                    730 km / 454 miles
Ceiling:                 7,620 m / 25,000 ft
```

Quelle: Dougherty, S. 83.

Diese Werte sind eine `TYPE_REFERENCE`. Fuer OMW-Treibstoff- und Missionsplanung bleiben die vorhandenen direkten USAF-Werte massgeblich.

### 4.3 Bewaffnung

Dougherty nennt fuer den MQ-1:

```text
2 x AGM-114 Hellfire laser-guided anti-tank missiles
optional/alternative reference: AIM-92 Stinger short-range air-to-air missiles
```

Quelle: Dougherty, S. 82-83.

Das Werk beschreibt ausserdem die Integration des Multi-Spectral Targeting System (MTS) mit IR-/TV-Sensorik und Laserdesignator und stellt die Kombination aus Sensor, Zielidentifikation und Hellfire-Einsatz als Kern des bewaffneten Predator-Konzepts dar. Quelle: Dougherty, S. 82.

Fuer OMW gilt: **AGM-114 Hellfire ist als historische Predator-Bewaffnung bestaetigt.** Die Stinger-Angabe wird nur als Typ-/Integrationsreferenz festgehalten und erzeugt keine automatische OMW-Loadout-Entscheidung.

### 4.4 Sensorik und ISR

Dougherty beschreibt:

- Forward Looking Infrared;
- TV-Kameras;
- Synthetic Aperture Radar;
- MTS mit Laserdesignator;
- optionale SIGINT-/Signals-Intelligence-Pakete;
- lange Loiter-Zeit als Hauptvorteil gegenueber bemannten Plattformen fuer persistente Ueberwachung.

Quelle: Dougherty, S. 79-83.

Yenne beschreibt fuer den Predator ebenfalls EO/IR-Sensorik, SAR und satellitengestuetzte Datenuebertragung. Quelle: Yenne, *Attack of the Drones*, S. 60-67.

OMW-Designwert: Predator/MQ-1 ist nicht als reiner Strike-Airframe zu modellieren. Die historische Hauptrolle liegt in **persistenter ISR, Target Development, Overwatch und bei Bedarf Strike**.

### 4.5 Endurance und Treibstoff

Die drei neuen Werke liefern **keinen belastbaren gemessenen MQ-1-Treibstoffverbrauch fuer Afghanistan 2010-2011**.

Yennes 2004er Werk nennt fuer fruehe Predator-Konfigurationen Werte bis etwa **40 Stunden Endurance**, gleichzeitig aber andere Gewichte, Payloads und Entwicklungsstaende. Quelle: Yenne, *Attack of the Drones*, S. 60-67. Diese Angabe wird als `SOURCE_CONFLICT_OR_VARIANT` gegenueber der spaeteren USAF-MQ-1B-Typreferenz behandelt und **nicht** fuer OMW-Fuel-Planung verwendet.

Massgeblich bleibt daher die bereits vorhandene OMW-Direktevidenz:

```text
MQ-1 fuel capacity: 100 US gal / 665 lb
fuel type: AVGAS
endurance: >24 h
```

Die daraus ableitbare Groesse `100 gal / 24 h = 4.17 US gal/h` bleibt lediglich ein **capacity/endurance proxy**, kein gemessener Verbrauch.

## 5. MQ-9 Reaper / Predator B

### 5.1 Entwicklung und Einfuehrung

Dougherty beschreibt den MQ-9 als Weiterentwicklung des Predator-B-Konzepts. Die Reaper-Entwicklung wird ab **2005** beschrieben; erste Sky-Warrior-/Predator-B-Verwandte wurden 2008 im Irak eingesetzt. Das Werk nennt **2008** als Jahr, in dem die USAF den MQ-9 Reaper in Afghanistan in Betrieb nahm. Quelle: Dougherty, S. 84-86.

Yenne beschreibt den Reaper als groessere, schnellere und staerker bewaffnete Weiterentwicklung des Predator. Quelle: Yenne, *Drone Strike!*, insbesondere S. 17-25, 42-56.

OMW-Klassifikation: `PRE_PERIOD_CONTINUITY` fuer die Einfuehrung; direkte 2011er Einheitszuordnungen werden weiterhin aus zeitnahen ORBAT-/AFCENT-Quellen genommen.

### 5.2 Abmessungen und Leistung

Doughertys Typkasten nennt fuer MQ-9 Reaper:

```text
Length:                  11 m / 36 ft 1 in
Wingspan:               20.1 m / 65 ft 9 in
Height:                  11 ft / 3.36 m
Engine:                  1 x Honeywell TPE331-10GD turboprop
Maximum takeoff weight:  4,760 kg / 10,500 lb
Maximum speed:           370 km/h / 230 mph
Range:                   1,852 km / 1,150 miles
Ceiling:                 15,240 m / 50,000 ft
```

Quelle: Dougherty, S. 88.

Dougherty beschreibt den Reaper ausserdem mit einem rund **950 hp / 708 kW** starken Turboprop und deutlich hoeherer Geschwindigkeit und Nutzlast gegenueber dem Predator. Quelle: Dougherty, S. 84-85.

Diese Werte dienen OMW als `TYPE_REFERENCE`, nicht als Ersatz fuer direkt offizielle USAF-Daten.

### 5.3 Bewaffnung

Dougherty nennt im MQ-9-Typkasten folgende Waffenfamilien:

```text
AGM-114 Hellfire
GBU-12 Paveway II
GBU-38 JDAM
```

Quelle: Dougherty, S. 88.

Das Werk zeigt und beschreibt den Reaper als bewaffnete ISR-/Strike-Plattform, bei der die hoehere Nutzlast die Kombination mehrerer Waffen ermoeglicht. Quelle: Dougherty, S. 84-88.

Yennes *Drone Strike!* zeigt spaetere Afghanistan-Konfigurationen, darunter RAF-Reaper am Kandahar Airfield mit AGM-114 Hellfire und GBU-12 Paveway II. Die betreffenden Bildbelege stammen jedoch aus der post-period Zeit und sind daher nur `POST_PERIOD_CONFIRMATION`, nicht automatisch ein Nachweis fuer exakt dieselbe Konfiguration 2011. Quelle: Yenne, *Drone Strike!*, S. 61-64.

OMW-Folge: Fuer historische 2010-2011-Loadouts sind **AGM-114, GBU-12 und GBU-38 technisch und historisch plausibel**, aber konkrete OMW-Waffenbestands- oder Standardloadout-Entscheidungen muessen weiterhin mit periodengerechter Evidenz und dem bestehenden Weapon-Store-Vertrag abgeglichen werden.

### 5.4 Sensorik und Missionsrollen

Die drei Werke bestaetigen wiederkehrend folgende Rollen:

- persistent ISR / surveillance;
- target development und pattern-of-life;
- route/area overwatch;
- laser designation;
- precision strike nach Freigabe;
- digitale beziehungsweise satellitengestuetzte Weitergabe des Sensorbilds;
- Remote-Pilot-/Sensor-Operator-Betrieb ueber grosse Distanz.

Dougherty betont, dass UAVs einen grossen Teil ihrer Zeit mit Ueberwachung verbringen und Schlagmissionen nur einen Teil der Aktivitaet darstellen. Quelle: Dougherty, S. 79-88.

Yenne beschreibt die Entscheidungs- und Datenkette zwischen Sensoroperator, Remote Crew, Kommunikationssystem, Freigabe und Waffenwirkung. Quelle: Yenne, *Drone Strike!*, S. 33-46.

### 5.5 Endurance und Treibstoff

Die drei neuen Quellen liefern **keinen hinreichend belastbaren, gemessenen MQ-9-Fuel-Flow fuer Afghanistan 2010-2011**.

Dougherty nennt in seinem kompakten MQ-9-Typkasten keinen Treibstoffvorrat und keine belastbare bewaffnete/unbewaffnete Endurance-Zahl. Yennes *Drone Strike!* beschreibt Ausdauer und Langzeitbetrieb qualitativ, liefert in den fuer OMW relevanten Afghanistan-Passagen aber ebenfalls keinen gemessenen Verbrauch, der die bestehende OMW-Planungsbasis ersetzen koennte.

Damit bleiben fuer OMW die bereits hoeherwertig dokumentierten Werte massgeblich:

```text
USAF baseline fuel capacity: 4,000 lb / 602 US gal
fully loaded endurance reference: up to 14 h
source-derived armed planning rate: 33.44 US gal/h
source-derived unarmed planning rate: 20.07 US gal/h
```

Die beiden Planungsraten sind weiterhin **nicht als gemessener Fuel Flow** zu bezeichnen. Die neuen drei Werke bestaetigen die hohe Ausdauer des Musters qualitativ, liefern aber **keine neue belastbare Verbrauchsmessung**.

## 6. Afghanistan - Basen, Einheiten und Einsatzorte

### 6.1 Kandahar Airfield

Yennes *Drone Strike!* enthaelt mehrere fotografische Afghanistan-Nachweise fuer MQ-9 am Kandahar Airfield. Dazu gehoeren:

- MQ-9-Reaper am Kandahar Airfield;
- Wartungs-/Ground-Crew-Arbeit an Reapern;
- Bildbelege der 451st Expeditionary Aircraft Maintenance Squadron im Kandahar-Kontext;
- spaetere RAF-Reaper am Kandahar Airfield.

Quelle: Yenne, *Drone Strike!*, S. 7, 26, 49-56 und 61-64.

Diese Fotografien sind wertvolle Standort- und Infrastrukturbelege, viele konkrete Bilddaten liegen jedoch **nach 2011**. Sie bestaetigen daher Kandahar als etablierten Predator/Reaper-Betriebsstandort und die Notwendigkeit lokaler Wartungs-, Start-/Lande- und Kommunikationsinfrastruktur, sind aber fuer die 2011er Staffelzuordnung nur `POST_PERIOD_CONFIRMATION`.

### 6.2 361st Expeditionary Reconnaissance Squadron - Kandahar, 2011

Der bereits vorhandene Juli-2011-ORBAT-Snapshot ist fuer die konkrete OMW-Zeitlage staerker als die drei neuen Sekundaerwerke und fuehrt:

```text
361st Expeditionary Reconnaissance Squadron
Kandahar Airfield
MC-12 + MQ-1 + MQ-9
```

Damit bleibt fuer OMW die **361st ERS** der direkt belegte 2011er Kandahar-Verband fuer MQ-1/MQ-9 im Rahmen der 451st AEW.

Die neuen Werke widersprechen dieser Zuordnung nicht; *Drone Strike!* bestaetigt vielmehr den langfristigen RPA-Betrieb und die entsprechende Wartungs-/Kommunikationsinfrastruktur in Kandahar.

### 6.3 62nd Expeditionary Reconnaissance Squadron

OMW verfuegt bereits ueber zwei wichtige direkte beziehungsweise zeitnahe Belege:

- AFCENT beschreibt die 62nd ERS im Kandahar-Kontext bereits bis Juni 2010 mit MQ-1/MQ-9 und sehr hohem kumulativem RPA-Flugbetrieb.
- Der Juli-2011-ORBAT-Snapshot fuehrt die 62nd ERS als MQ-1-/MQ-9-Drohnenstaffel.

Yennes spaetere Bildbelege zeigen 62nd-ERS-Reaper-Personal und Reaper in Afghanistan, liegen aber ueberwiegend nach dem OMW-Zeitraum. Quelle: Yenne, *Drone Strike!*, S. 44, 49-56.

OMW behandelt die neuen Bilder als `POST_PERIOD_CONFIRMATION`, nicht als Ersatz fuer die 2010/2011-AFCENT-/ORBAT-Evidenz.

### 6.4 Bagram und weitere afghanische Standorte

Yennes *Drone Strike!* dokumentiert RPA-Personal und Reaper-bezogene Aktivitaeten auch im Bagram-Kontext, darunter spaetere Reaper-Team-/Security-Force-Bildbelege. Quelle: Yenne, *Drone Strike!*, S. 53-54.

Die Quelle beweist jedoch **keine vollstaendige 2011er Airframe-zu-Basis-Verteilung**. OMW darf daraus daher weder eine zusaetzliche Staffel noch eine konkrete Zahl MQ-1/MQ-9 in Bagram ableiten.

Dougherty bestaetigt allgemein Predator- und Reaper-Einsatz in Afghanistan, liefert aber keine belastbare 2011er Basis-/Staffelmatrix. Quelle: Dougherty, S. 79-88.

## 7. Remote Operations und lokale Infrastruktur

Ein fuer OMW besonders wichtiger, von den neuen Quellen gut bestaetigter Punkt ist die Trennung zwischen **lokaler Flugzeugabfertigung** und **entfernter Missionsfuehrung**.

Dougherty beschreibt fuer Predator:

- Transport des zerlegbaren Systems per C-130 moeglich;
- lokale Ground Control Station beziehungsweise Launch-/Recovery-Komponente am Einsatzort;
- nach Einfuehrung verbesserter Satellitenkommunikation kann die Missionsfuehrung ueber grosse Distanz erfolgen;
- Start und Landung benoetigen weiterhin lokales Personal beziehungsweise lokale Kontrolle am Einsatzflugplatz.

Quelle: Dougherty, S. 80.

Yenne zeigt beziehungsweise beschreibt:

- MQ-1/MQ-9-Kommunikationsanlagen und Satellitenlinks;
- Remote-Pilot- und Sensor-Operator-Arbeitsplaetze in den USA;
- Flugzeuge und Wartungspersonal gleichzeitig auf vorgeschobenen Basen wie Kandahar;
- die operative Daten-/Kill-Chain zwischen Sensor, Operator, Kommando und Freigabe.

Quelle: Yenne, *Drone Strike!*, S. 33-50 und 52-56.

Fuer OMW folgt daraus eine klare Architektur-/Missionsdesigntrennung:

```text
physical RPA at Afghan operating base
        +
local launch/recovery + maintenance + fuel + weapons + datalink infrastructure
        !=
remote mission crew necessarily co-located at that base
```

Diese historische Betriebsweise ist fuer spaetere Mission-Editor- und CampaignState-Planung relevant, erzeugt aber **keine neue Lua-/MOOSE-Implementierung** in diesem Dokument.

## 8. Einsatzrhythmus und Flugzeit

Die neuen Werke bestaetigen vor allem die **qualitative** Eigenschaft sehr langer Missionen und persistenter Ueberwachung.

Dougherty beschreibt den Langzeitbetrieb des Predator und die Belastung durch lange Missionen; Yenne behandelt die wachsende Rolle persistenter ISR und den hohen RPA-Flugbetrieb. Die Werke liefern jedoch fuer Afghanistan 2011 keine ausreichend saubere Kombination aus:

```text
identified unit
+ identified airframe count
+ exact date window
+ total sorties
+ total flying hours
```

Daher wird aus diesen drei Quellen **keine neue OMW-Sortierate oder Flugstundenrate pro Airframe** berechnet.

Fuer quantitative Planung bleiben die bereits vorhandenen OMW-Evidenzsaetze massgeblich, insbesondere:

- 62nd-ERS/AFCENT-Kumulativwerte bis Juni 2010;
- vorhandene MQ-1-/MQ-9-Endurance-Referenzen;
- bereits dokumentierte RAF-MQ-9-Flugstundenreferenz fuer 2011, soweit sie im zustaendigen Air-Ops-Datensatz verwendet wird.

## 9. Bewaffnungszusammenfassung fuer OMW

Die neuen Sekundaerwerke bestaetigen folgende historische Waffenfamilien:

| Muster | Belegte Waffen in den neuen Quellen | OMW-Bewertung |
|---|---|---|
| MQ-1 Predator | AGM-114 Hellfire | **stark bestaetigte Typreferenz** |
| MQ-1 Predator | AIM-92 Stinger | Typ-/Integrationsreferenz; keine automatische OMW-Loadout-Entscheidung |
| MQ-9 Reaper | AGM-114 Hellfire | **stark bestaetigte Typreferenz** |
| MQ-9 Reaper | GBU-12 Paveway II | **stark bestaetigte Typreferenz**; Afghanistan-Bildbelege in Yenne sind teils post-period |
| MQ-9 Reaper | GBU-38 JDAM | **Typreferenz** aus Dougherty |

Nicht aus diesen drei Quellen abzuleiten sind konkrete OMW-Anfangsbestandszahlen fuer Hellfire/JDAM/Paveway oder ein verbindliches Standardloadout je Squadron.

## 10. Treibstoffzusammenfassung

Die neuen Werke liefern **keine neue belastbare Afghanistan-2011-Verbrauchsmessung** fuer MQ-1 oder MQ-9. Deshalb wird keine bestehende OMW-Fuel-Rate ersetzt.

Fuer die weitere Planung gilt weiterhin:

| Muster | OMW-Treibstoffbasis | Status |
|---|---:|---|
| MQ-1 | 100 US gal / 665 lb, AVGAS | direkte USAF-/ACC-Typreferenz |
| MQ-1 | >24 h Endurance | direkte USAF-Afghanistan-/Typreferenz |
| MQ-1 | 4.17 US gal/h | nur Capacity/24h-Proxy, **kein gemessener Burn** |
| MQ-9 | 602 US gal / 4,000 lb | direkte USAF-Baseline |
| MQ-9 | bis 14 h voll beladen | direkte USAF-Typreferenz |
| MQ-9 | 33.44 US gal/h bewaffnet | source-derived OMW planning rate, **kein gemessener Burn** |
| MQ-9 | 20.07 US gal/h unbewaffnet | source-derived OMW planning rate, **kein gemessener Burn** |

Die drei neuen Werke dienen hier nur als qualitative Bestaetigung der langen Endurance und des persistenten Einsatzprofils.

## 11. Direkt nutzbare OMW-Folgen

1. **MQ-1/MQ-9 in Kandahar 2011 bleibt historisch belastbar.** Die konkrete 361st-ERS-Zuordnung stammt weiterhin aus der staerkeren Juli-2011-ORBAT-Evidenz.
2. **Predator und Reaper sind primaer persistente ISR-/Overwatch-Plattformen mit Strike-Faehigkeit**, nicht reine Strike-Airframes.
3. **Lokale Flugzeugpraesenz bedeutet nicht lokale Mission-Crew-Praesenz.** Launch/Recovery, Wartung, Fuel, Weapons und Datalink sind lokal; Missionsfuehrung kann remote erfolgen.
4. **AGM-114 Hellfire** ist fuer beide Muster historisch gut bestaetigt.
5. **GBU-12 und GBU-38** sind fuer MQ-9 als Typbewaffnung bestaetigt; konkrete 2011er OMW-Loadouts bleiben gesondert zu belegen.
6. Die neuen Quellen rechtfertigen **keine Aenderung der vorhandenen Fuel-Planungsraten**, weil sie keinen gemessenen 2010-2011-Fuel-Flow liefern.
7. Die neuen Quellen liefern **keine belastbare Airframe-Anzahl fuer die 361st ERS oder 62nd ERS 2011**. Bestandszahlen duerfen daher nicht aus Fotos oder spaeteren Squadron-Nachweisen extrapoliert werden.
8. Die spaeteren Kandahar-Fotos in *Drone Strike!* sind fuer Infrastruktur, Ground Handling, Wartung und die anhaltende RPA-Nutzung wertvoll, aber als `POST_PERIOD_CONFIRMATION` zu kennzeichnen.

## 12. Nicht aus diesen Quellen abzuleiten

Nicht ausreichend belegt sind:

- exakte Zahl der MQ-1 oder MQ-9 je Afghanistan-Staffel 2011;
- exakte 2011er Airframe-zu-Basis-Matrix fuer alle RPA-Verbande;
- gemessener MQ-1- oder MQ-9-Treibstoffverbrauch pro Stunde in Afghanistan;
- verbindliche 2011er Standardloadouts oder Waffenbestandsmengen;
- DCS-spezifische Sensor-, Datalink-, Loiter- oder Waffenlogik;
- MOOSE-Methoden oder Runtime-Verhalten;
- Ableitung eines automatischen OMW-Missionsrhythmus aus den beschriebenen Langzeitmissionen.

## 13. Quellenverzeichnis und Seitenbezug

### Neue Quellen

- Bill Yenne, *Drone Strike! UCAVs and Unmanned Aerial Warfare in the 21st Century*, Specialty Press, 2017. Besonders relevant: S. 7, 17-25, 33-56, 61-64.
- Martin J. Dougherty, *Drones: An Illustrated Guide to the Unmanned Aircraft That Are Filling Our Skies*, Amber Books / Metro Books, 2015. Besonders relevant: S. 79-88.
- Bill Yenne, *Attack of the Drones: A History of Unmanned Aerial Combat*, Zenith Press, 2004. Besonders relevant: S. 59-67 fuer Predator-Entwicklung und fruehe Einsatzgeschichte.

### Bereits vorhandene, staerkere OMW-Evidenz

- `OMW-HIST-AFGHANISTAN-ORBAT-2011-07` - Juli-2011-ORBAT mit 361st ERS und 62nd ERS.
- USAF MQ-1 Fact Sheet - Fuel Capacity 665 lb / 100 US gal.
- USAF MQ-9 Fact Sheet - Baseline Fuel Capacity 4,000 lb / 602 US gal.
- USAF/AFCENT RPA-Beitraege zur 62nd ERS und Afghanistan-Endurance.
- OMW Air-Ops-Logistik-Evidenzregister fuer `USAF_MQ1_FACT`, `ACC_AVGAS`, `USAF_MQ9_FACT`, `KAF_RPA_250K_2010`, `MQ1_ENDURANCE_AFG_2010` und `MQ9_ENDURANCE_2006`.
- OMW MQ-9 Fuel-Rate-Source-Analysis vom 13.08.2026 fuer die getrennten bewaffneten/unbewaffneten Planungsraten.

## 14. Validierungsstatus

Diese Aenderung ist eine historische Quellen- und Dokumentationsreconciliation.

- Lua-/MOOSE-Aenderung: **nein**.
- Missionsdatei-Aenderung: **nein**.
- DCS-Test erforderlich: **nein** fuer diese Dokumentationsaufnahme.
- Neue MOOSE-Klasse oder -Methode: **nein**.
- Fuel-Rate-Aenderung: **nein**.
- Aktive ORBAT-Aenderung: **nein**.
- Neue belastbare Quelleninformation: **ja**, insbesondere zusaetzliche Sekundaerbestaetigung zu Predator/Reaper-Technik, Bewaffnung, ISR-/Strike-Rollen, Remote-Operations-Architektur und Kandahar-RPA-Infrastruktur.
