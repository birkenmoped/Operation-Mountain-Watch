---
document_id: OMW-HIST-AFGHANISTAN-CSAR-KANDAHAR-SOURCE-REVIEW
status: BINDING
document_class: HISTORICAL_SOURCE_REVIEW
owning_policy: OMW-GOV-001
authoritative_for:
  - source-qualified review of the supplied Afghanistan CSAR and Kandahar Airfield materials
  - 2010-2011 USAF rescue-unit, basing, alert, CASEVAC and aerial-refueling evidence
  - pre-period Kandahar Airfield visual and early-OEF operational continuity evidence
not_authoritative_for:
  - active OMW air ORBAT or player slots
  - exact 2011 aircraft inventory where the source does not state a quantity
  - DCS or MOOSE technical behavior
  - treating 2001-2009 imagery or force posture as a 2011 snapshot
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by:
source_branch: docs/afghanistan-csar-kandahar-source-review
source_commit: d2f31e485346d8015c9ed67f5788b74dfce49936
validated_in_dcs: false
---

# 87 - Afghanistan CSAR und Kandahar Airfield: Quellenreview

## 1. Zweck

Dieses Dokument bewertet vier neu bereitgestellte Quellen auf ihren Nutzen fuer Operation Mountain Watch. Schwerpunkt sind Einsatzorte, Einheiten und Einsatzmuster im verbindlichen OMW-Zeitraum 01.08.2010-31.12.2011, insbesondere USAF Combat Search and Rescue (CSAR), Personnel Recovery (PR), CASEVAC/MEDEVAC sowie Kandahar Airfield.

Die Quellen werden nicht automatisch zu einer aktiven OMW-ORBAT. Die aktive Missions-ORBAT bleibt ausschliesslich durch `OMW-GOV-001` und `OMW-AIR-ACTIVE-ORBAT` bestimmt.

## 2. Gepruefte neu bereitgestellte Quellen

| Quelle | Zeitbezug | OMW-Evidenzklasse | Bewertung |
|---|---|---|---|
| Lou Drendel, *Operation Enduring Freedom: US Military Operations in Afghanistan, 2001-2002*, Squadron/Signal 6123 | 2001-2002 | `BACKGROUND_ONLY` | wertvolle fruehe OEF-Luftoperations- und Basierungsreferenz, aber kein 2010/2011-ORBAT-Beleg |
| Breanne Wagner, "The Men Who Make the Saves", *Air Force Magazine*, January 2007, S. 60-64 | bis 2006 | `TYPE_TTP_BACKGROUND` | HH-60G/CSAR-Leistungs-, Hot-and-high- und Einsatzbelastungsreferenz; kein 2011-Unit-Snapshot |
| "CSAR in Afghanistan", *Air Force Magazine*, May 2014, S. 124-131 | Fotos 2010-2013, Rueckblick seit 2001 | `IN_PERIOD_PHOTO_EVIDENCE` fuer datierte 2010/2011-Bilder; sonst `POST_PERIOD_CONTEXT` | direkter visueller Beleg fuer Kandahar 2010 und Bagram/83rd ERQS 2011 |
| *Kandahar 2009.pdf* | ueberwiegend 2008/2009; interne Beschriftung | `PRE_PERIOD_VISUAL_REFERENCE` | wertvolle Ramp-/Shelter-/Nutzerzonen-Referenz; nicht als 2011-ORBAT oder exakter Einheitenbeleg verwenden |

Repository- und Quellenregistersuche ergab keinen bereits vorhandenen Eintrag dieser vier konkreten Titel als eigenstaendige OMW-Quellen. Inhaltlich ueberschneiden sie sich mit bereits vorhandenen OMW-Referenzen, insbesondere Dokument 50, 60, 64 sowie der bestehenden CSAR-/Air-Operations-Forschung.

## 3. 83rd Expeditionary Rescue Squadron - Bagram / Regional Command East

Die staerkste neue 2011-Evidenz betrifft die `83rd Expeditionary Rescue Squadron (83rd ERQS)` auf Bagram Airfield.

Die Air-Force-Magazine-Bildstrecke von 2014 enthaelt ein auf den **12. Juni 2011** datiertes Foto eines 83rd-ERQS-HH-60-Piloten, der auf Bagram zum Start laeuft. Die Bildunterschrift nennt fuer die Alert-Reaktion im Mittel **weniger als zehn Minuten**, bis ein HH-60-Flug nach Alarmierung airborne und auf dem Weg zur Verwundetenaufnahme ist. Quelle: *Air Force Magazine*, May 2014, S. 131.

Zeitgenoessische offizielle USAF/AFCENT-Berichte bestaetigen fuer 2011:

- Februar 2011: 83rd ERQS auf Bagram Airfield mit Doppelrolle `personnel recovery + casualty evacuation` fuer **Regional Command East**; zeitweilige Vorwaertsverlegung auf FOBs zur Unterstuetzung geplanter Bodenoperationen.
- 23. April 2011: Nach einem Army-Hubschrauberabsturz in Kapisa starteten **zwei HH-60G Pave Hawks** innerhalb von etwa zehn Minuten. `Pedro 83` und `Pedro 84` arbeiteten mit F-15E, AH-64 und OH-58D zusammen und operierten unter Feindfeuer.
- 11. Juni 2011: Zwei 83rd-ERQS-Pave-Hawks starteten von Bagram fuer eine Rettungsmission; die offizielle USAF-Fotodokumentation bestaetigt Datum, Einheit und Bagram.
- 11. September 2011: 83rd-ERQS-Kraefte waren auf **FOB Ghazni** fuer CASEVAC vorpositioniert. Fuer eine Rettung im Gebiet der Kuh-e-Nilu-Berge mussten zwei HH-60G ueber mehr als **12,000 ft** hohes Gelaende fliegen und eine **Luftbetankung mit einem HC-130P/N aus Kandahar Airfield** koordinieren.

Primaerquellen:

- U.S. Air Forces Central / 455th AEW, "Pedros provide confidence, combat power for ground forces", 18 Feb 2011.
- U.S. Air Force / 455th AEW, "Rescue Airmen engage hostile forces to retrieve 'Fallen Angels'", May 2011, Einsatz vom 23 Apr 2011.
- U.S. Air Force, "Photo essay: Airmen at Bagram conduct pararescue mission", 13 Jun 2011.
- U.S. Air Forces Central / 455th AEW, "CSAR executes high risk, dynamic ANA rescue", 28 Sep 2011, Einsatz vom 11 Sep 2011.

Damit ist fuer 2011 direkt belegt:

```text
Bagram Airfield
-> 83rd ERQS
-> HH-60G Pave Hawk
-> PR + CASEVAC for RC-East
-> alert launch around <=10 min in documented examples
-> forward positioning to FOBs such as Ghazni
-> high-altitude mountain rescue
-> cooperation with F-15E / AH-64 / OH-58D
-> HC-130P/N aerial refueling when range/terrain required
```

Diese Evidenz ist fuer historische Missionsplanung hochrelevant. Sie aendert **nicht automatisch** die derzeitige aktive Bagram-ORBAT in Dokument 19; eine Aufnahme der 83rd ERQS als produktiver OMW-Bestand waere eine gesonderte Eigentumerentscheidung.

## 4. Suedafghanistan: 26th ERQS, Camp Bastion und Kandahar

### 4.1 26th ERQS - Kandahar 2010

AFCENT dokumentiert am 1. Oktober 2010 die `26th Expeditionary Rescue Squadron` mit HH-60G Pave Hawk auf **Kandahar Airfield**. Auftrag: Tag-/Nacht-Personnel-Recovery und MEDEVAC/CASEVAC in feindlicher Umgebung gemeinsam mit Pararescuemen.

Das liegt innerhalb des OMW-Zeitraums und stutzt die bestehende Kandahar-Governance, in der die 26th ERQS unter der 451st AEW gefuehrt wird.

Quelle: U.S. Air Forces Central / 451st AEW, "Rescue helicopter crews answer the call in Afghanistan", 1 Oct 2010.

### 4.2 26th ERQS - Camp Bastion 2011

Eine belastbare 2011-Evidenz stammt aus 451st AEW/Air Force Reserve:

- ungefaehr **60 Mitglieder des 920th Rescue Wing** waren von Anfang Juni bis Anfang Oktober 2011 dem **26th ERQS Detachment at Camp Bastion** zugeordnet;
- der 120-Tage-Einsatz flog **nahezu 500 Missionen** und rettete **mehr als 350 Menschen**;
- eingesetzt wurden HH-60G Pave Hawks mit PJs;
- die Einheit operierte in **Regional Command Southwest**;
- siebenkoepfige Teams arbeiteten taeglich in **12-Stunden-Schichten**;
- der Einsatzrhythmus wurde als einer der hoechsten Auslastungsgrade innerhalb der Air Force beschrieben.

Quelle: 920th Rescue Wing / 451st AEW, "Rescue Reserve Airmen return home from 120-day deployment", 16 Oct 2011; parallel AFCENT "Bastion ERQS members redeploy", 7 Oct 2011.

Kandahar und Camp Bastion duerfen fuer Rescue daher nicht als zwei voellig isolierte historische Systeme betrachtet werden. Die 451st-AEW-Rescue-Struktur nutzte im Zeitraum Kandahar sowie Camp Bastion und verlegte/teilte Funktionen und Detachments nach Missionsbedarf.

```text
unit documented at KAF != every aircraft always physically at KAF
unit documented at Bastion != separate strategic aircraft pool without further evidence
```

Die OMW-Governance bleibt fuer die aktive Ressourcenabbildung massgeblich.

## 5. Fixed-wing Rescue 2011: HC-130P Combat King

### 5.1 76th Expeditionary Rescue Squadron - Camp Bastion

AFCENT dokumentiert fuer **7. Juni 2011** die `76th Expeditionary Rescue Squadron` auf **Camp Bastion**, Helmand Province. Der Verband bediente mit HC-130P Hercules/Combat King eine theaterweite Fixed-wing-Rescue-/CASEVAC-Funktion.

Der Bericht nennt:

- Reaktion auf Notfaelle in allen Regional Commands Afghanistans;
- duale Rolle `casualty evacuation + personnel recovery / combat search and rescue`;
- drei Rescue Crews;
- zwei HC-130P;
- Zusammenarbeit mit Maintenance und `46th ERQS/Fixed Wing` im beschriebenen Fever-Operations-Verbund.

Quelle: U.S. Air Forces Central, "Fixed wing rescue fills essential lifesaving role", 7 Jun 2011.

### 5.2 Einsatzleistung bis Dezember 2011

AFCENT dokumentiert am **21. Dezember 2011**, dass die 76th ERQS seit Juni 2011 mehr als **475 Missionen** geflogen und nahezu **600 Patienten** transportiert hatte. Ziele waren abgelegene Combat Outposts, FOBs und Camps; Patienten wurden unter anderem zu hoeherwertigen Einrichtungen auf **Bagram oder Kandahar Airfield** gebracht.

Quelle: U.S. Air Forces Central / 451st AEW, "76th ERQS transports injured to more capable medical facilities", 21 Dec 2011.

### 5.3 Direkter HH-60G/HC-130P-Verbund

Der 83rd-ERQS-Einsatz vom 11. September 2011 liefert den systemischen Nachweis: HH-60G aus Bagram koordinierten eine Luftbetankung durch einen **HC-130P/N aus Kandahar Airfield**, um einen hochgelegenen Rettungseinsatz durchzufuehren.

Damit ist fuer OMW historisch belegt:

```text
HH-60G rescue package
+ forward positioning
+ HC-130P/N aerial refueling
+ high-altitude transit
+ cross-regional rescue support
```

Es ist **nicht** belegt, dass jede 2011er HC-130P/N-Mission von Kandahar derselben ERQS zugeordnet war. Fuer konkrete Tail-/Squadron-Zuordnung muss die jeweilige zeitgenoessische Quelle herangezogen werden.

## 6. 46th ERQS - Guardian-Angel-/Rescue-Triad-Kontext

Eine AFCENT-Quelle von 2010 dokumentiert die `46th Expeditionary Rescue Squadron` auf Camp Bastion als Guardian-Angel-Komponente des Rescue Triad. Der beschriebene Verbund bestand aus:

- HH-60G Pave Hawk aircrews;
- HC-130P/N King crews;
- Guardian Angels: Combat Rescue Officers, Pararescuemen und SERE-Personal.

Quelle: U.S. Air Forces Central, "Commander takes on new Guardian Angel unit, completes 'Rescue Triad'", 2010.

Dies stutzt die aktuelle OMW-Governance, die die 46th ERQS als Guardian-Angel-Personal fuehrt und **keinen eigenen Aircraft-Pool** daraus ableitet.

## 7. HH-60G Pave Hawk - Typ-/TTP-Hintergrunddaten

`The Men Who Make the Saves` (*Air Force Magazine*, Jan 2007) liegt ausserhalb des Szenariozeitraums, liefert aber wichtige Type-/Environment-Evidence.

### 7.1 Hot-and-high und Gewicht

Ein Afghanistan-Einsatz im Sommer 2005 erreichte **15,000 ft**. Aufgrund des Gewichts musste die Crew zwischen Nutzlast, Schutz und Reichweite abwaegen; Treibstoffablassen haette die Rueckkehr in freundliches Gebiet gefaehrden koennen. Die Crew entfernte schliesslich schwere Kevlar-Bodenpanzerung, um die Rettung durchfuehren zu koennen.

Quelle: Wagner, *Air Force Magazine*, Jan 2007, S. 64.

### 7.2 Konfigurations- und Reichweitengrenzen

Die Quelle nennt fuer den damaligen HH-60G:

- regulaeren Betrieb bei **22,000+ lb** gross weight;
- Zusatzgewicht durch FLIR, Gun Package und Air-refueling equipment;
- internen Zusatztank zur Reichweitenerhoehung, der bis zu etwa **ein Drittel der Kabine** beanspruchen kann;
- ungefaehr **180 miles combat radius** als damalige Groessenordnung;
- eingeschraenkte Leistung durch hohe Temperaturen, Staub und Hoehe.

Diese Angaben sind `TYPE_TTP_BACKGROUND`, keine DCS-Leistungswerte und keine Garantie fuer eine konkrete 2011er Missionskonfiguration.

Historisch plausibles Rescue-Design muss deshalb mindestens unterscheiden:

```text
terrain altitude
ambient temperature
payload / armor / medical load
internal fuel / auxiliary fuel
need for aerial refueling
patient count
forward staging option
```

Keiner dieser Punkte darf ohne DCS-Test direkt in ein DCS-HH-60-Leistungsmodell uebersetzt werden.

## 8. Kandahar 2009 - visuelle Airfield-Referenz

Die Datei `Kandahar 2009.pdf` ist eine Bild-/Satellitenzusammenstellung. Sie besitzt keinen ausreichend dokumentierten Herausgeber-/Erhebungsapparat fuer eine gleichwertige ORBAT-Autoritaet. Sie wird deshalb nur als `PRE_PERIOD_VISUAL_REFERENCE` verwendet.

### 8.1 Beschriftete Nutzer-/Funktionsbereiche

Die Legende auf Seite 1 markiert folgende Bereiche am Kandahar Airfield:

```text
CIA + SOF: UH-1, CH-47, Mi-8, light ISR
HLO
Military passengers apron
Civilian passengers apron
UAV: MQ-9
UAV: RQ-170
UK: Harrier GR-9 / Tornado GR-4
Belgium: F-16
France: Mirage 2000D / Mirage F1CR / Rafale B / Super Etendard
Transport aircraft / temporary transit
USMC: Transport / HLO / F-18 / Harrier
```

Diese Beschriftungen sind als Autoreninterpretation der Bildsammlung zu behandeln, nicht als administrative Einheitenliste.

### 8.2 Visuell erkennbare Infrastruktur und Typfamilien

Die Seiten 2-45 zeigen unter anderem:

- grosse Transport-/Transit-Abstellflaechen mit C-130-artigen und weiteren Transportflugzeugen;
- getrennte Fighter-/Fast-Jet-Rampen und Revetments;
- UAV-Shelter-/Apron-Bereiche;
- CH-47-Chinook- und weitere Hubschrauberabstellbereiche;
- Harrier-, F-16-, F/A-18-artige und weitere Coalition-Fast-Jet-Praesenz;
- zahlreiche Expeditionary Shelters, HESCO-/Blastwall-Strukturen, Hangars und modulare Supportbereiche;
- eine als `2008` gekennzeichnete Satellitenaufnahme auf Seite 45, sodass die Sammlung nicht als einheitlicher 2009-Stichtag interpretiert werden darf.

Fuer OMW ist dies primar ein **Layout-/Atmosphaere-/Zonenbeleg** fuer den Ausbau Kandahars vor dem Szenariozeitraum. Exakte 2011-Parking-IDs, gleichzeitig vorhandene Flugzeugzahlen oder Einheitsidentitaeten werden daraus nicht abgeleitet.

## 9. CSAR in Afghanistan - Air Force Magazine 2014

Die 2014er Bildstrecke mischt datierte Fotos aus 2010-2013. Nur die datierten Bilder innerhalb des OMW-Zeitraums werden als direkte Periodenevidenz verwendet.

### 9.1 Innerhalb des OMW-Zeitraums

- **24 Dec 2010, Kandahar:** 46th ERQS bei Mass-casualty-/Qualification-Szenario; HH-60/Pave-Hawk- und PJ-Betrieb in Brownout-Bedingungen.
- **12 Jun 2011, Bagram:** 83rd ERQS HH-60/PJ-Alertstart; Bildunterschrift nennt im Mittel weniger als zehn Minuten vom Alert bis zum airborne flight.

Quelle: *Air Force Magazine*, May 2014, S. 129-131.

### 9.2 Ausserhalb des OMW-Zeitraums

- **8 Jan 2010, Kandahar:** Pave Hawks auf dem Vorfeld; `PRE_PERIOD_CONTINUITY`.
- 2012/2013-Fotos belegen spaetere Fortsetzung des Grundsystems - 83rd ERQS, Bagram, HH-60G, PJs, hoist operations und defensive Bewaffnung - sind aber kein direkter 2011-Nachweis fuer Staerke oder Konfiguration.

## 10. Operation Enduring Freedom 2001-2002 - Hintergrundgrenze

Lou Drendels Squadron/Signal-Band ist vollstaendig fruehe-OEF-bezogen und liegt ausserhalb des OMW-Zeitraums. Er ist nuetzlich fuer historische Kontinuitaet, aber nicht fuer 2011er Force Posture.

Die Bildquelle dokumentiert unter anderem:

- B-1B/B-52/F-15E/F-16/JSTARS/Predator und Tankerunterstuetzung;
- C-17/C-130/AC-130 und Special-Operations-Aircraft;
- AH-64, MH-47, MH-53, USMC- und Navy-Aviation;
- Kandahar als fruehen Transport-/Operationsknoten;
- Bagram als Operationsbasis;
- starke Abhaengigkeit langer Afghanistan-Sorties von AAR;
- fruehe OEF-Verwendung von SOF, Rangers und Airborne/air-assault elements.

Quelle: Lou Drendel, *Operation Enduring Freedom: US Military Operations in Afghanistan, 2001-2002*, Squadron/Signal 6123, 2002.

OMW-Regel:

```text
2001-2002 platform presence != 2011 platform presence
2001-2002 unit identity != 2011 unit identity
2001-2002 basing != 2011 basing
```

## 11. Zusammengefuehrtes 2011-Lagebild fuer Rescue Operations

| Standort / Bereich | 2011-Beleg | Rolle |
|---|---|---|
| Bagram Airfield | 83rd ERQS, HH-60G | PR, CSAR, CASEVAC fuer RC-East |
| FOB Ghazni | 83rd ERQS forward-positioned | temporaere Vorwaertsverlegung fuer CASEVAC |
| Kapisa / Kunar / Wardak / Kuh-e-Nilu | 83rd ERQS missions | mountain rescue, hostile extraction, CASEVAC |
| Kandahar Airfield | HC-130P/N in Sep-2011 rescue support; 26th ERQS continuity from 2010 | rescue hub / aerial-refueling support / southern rescue architecture |
| Camp Bastion | 26th ERQS detachment, HH-60G | RC-Southwest PR/CASEVAC; ~500 missions Jun-Oct 2011 in cited rotation |
| Camp Bastion | 76th ERQS, HC-130P | theater-wide fixed-wing rescue/CASEVAC; 2 aircraft in Jun-2011 source |
| Bagram/Kandahar medical chain | receiving higher-level care facilities | fixed-wing casualty movement destination |

## 12. Projektfolgen und Grenzen

### 12.1 Historisch belastbar fuer Missionsdesign

1. Rescue war 2011 kein rein lokales Base-Asset, sondern ein theaterweites, vorwaerts verlegbares Netzwerk.
2. Bagram/83rd ERQS ist fuer RC-East 2011 direkt belegt.
3. Camp Bastion war ein zentraler southern-rescue node mit HH-60G und HC-130P.
4. Kandahar blieb Teil der Rescue-/Medical-/Aerial-refueling-Kette.
5. HH-60G-Air-to-air-refueling durch HC-130P/N ist fuer einen konkreten Afghanistan-Einsatz am 11.09.2011 direkt belegt.
6. Hot-and-high, Gewicht, Reichweite, Patientenzahl und Forward Staging waren operative Planungsfaktoren.
7. Alarmreaktionen im Bereich von etwa zehn Minuten sind fuer konkrete 83rd-ERQS-Einsaetze 2011 dokumentiert; daraus wird kein universeller fixer Schedulerwert abgeleitet.

### 12.2 Nicht automatisch abzuleiten

Nicht aus diesen Quellen ableiten:

- neue aktive OMW-SQUADRONs oder Aircraft-Pools;
- exakte 2011-Gesamtstaerke der 83rd/26th/46th/76th ERQS ohne weitere Unit-Strength-Quelle;
- universelle zehnminuetige Startzeit;
- DCS-HH-60G-Leistungsdaten aus realen 15,000-ft-/180-mile-Angaben;
- 2011-Parking-Layout direkt aus `Kandahar 2009.pdf`;
- 2011-RQ-170/MQ-9-Einheiten allein aus der 2009er Bildlegende;
- Gleichsetzung von 46th ERQS mit einem eigenen Aircraft-Pool entgegen der aktuellen Governance.

## 13. Quellenverzeichnis

### Neu bereitgestellte Quellen

1. Lou Drendel, *Operation Enduring Freedom: US Military Operations in Afghanistan, 2001-2002*, Squadron/Signal Publications No. 6123, 2002.
2. Breanne Wagner, "The Men Who Make the Saves", *Air Force Magazine*, January 2007, pp. 60-64.
3. "CSAR in Afghanistan", *Air Force Magazine*, May 2014, pp. 124-131; DoD/USAF photographs with individual date captions.
4. *Kandahar 2009.pdf*, user-provided visual compilation; provenance not sufficiently established for primary-source ORBAT status.

### Offizielle Gegenpruefung

5. U.S. Air Forces Central, 455th AEW, "Pedros provide confidence, combat power for ground forces", 18 Feb 2011.
6. U.S. Air Force / Air Combat Command / 455th AEW, "Rescue Airmen engage hostile forces to retrieve 'Fallen Angels'", May 2011.
7. U.S. Air Force, "Photo essay: Airmen at Bagram conduct pararescue mission", 13 Jun 2011.
8. U.S. Air Forces Central, 455th AEW, "CSAR executes high risk, dynamic ANA rescue", 28 Sep 2011.
9. U.S. Air Forces Central, 451st AEW, "Rescue helicopter crews answer the call in Afghanistan", 1 Oct 2010.
10. U.S. Air Forces Central / 451st AEW, "Bastion ERQS members redeploy", 7 Oct 2011; 920th Rescue Wing, "Rescue Reserve Airmen return home from 120-day deployment", 16 Oct 2011.
11. U.S. Air Forces Central, "Fixed wing rescue fills essential lifesaving role", 7 Jun 2011.
12. U.S. Air Forces Central / 451st AEW, "76th ERQS transports injured to more capable medical facilities", 21 Dec 2011.
13. U.S. Air Forces Central, "Commander takes on new Guardian Angel unit, completes 'Rescue Triad'", 2010.

## 14. Querverweise

- `OMW-GOV-001` - `docs/00-project-governance.md`
- `OMW-AIR-ACTIVE-ORBAT` - `docs/19-active-air-orbat-decisions.md`
- `OMW-HIST-AFGHANISTAN-FORCE-BASING-AVIATION` - `docs/50-afghanistan-force-basing-aviation-2010-2011.md`
- `OMW-HIST-AFGHAN-AIR-WARS-2009-2011` - `docs/60-afghan-air-wars-2009-2011-airpower-operations-reference.md`
- `OMW-HIST-AFGHANISTAN-ORBAT-2011-07` - `docs/64-afghanistan-order-of-battle-july-2011.md`

## 15. Validierungsstatus

```text
Documentation/source integration only.
No Lua changed.
No MOOSE API changed.
No mission file changed.
No DCS runtime validation claimed or required for this source-review change.
```
