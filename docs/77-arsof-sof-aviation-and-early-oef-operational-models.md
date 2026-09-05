---
document_id: OMW-HIST-ARSOF-SOF-AVIATION-EARLY-OEF
status: BINDING
document_class: SOURCE_CRITICAL_OPERATIONAL_DESIGN_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-critical early-OEF ARSOF, SOF aviation, CSAR, PSYOP, civil-affairs and support patterns
  - historical base and communications models for K2, Bagram and Kandahar
  - mission-design lessons from October 2001 through May 2002
not_authoritative_for:
  - active 2010-2011 OMW SOF ORBAT
  - complete team roster or complete classified operation record
  - automatic use of early-OEF frequencies, callsigns or force levels
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: docs/afghanistan-aip-kaia-lop
source_commit: 60942323d6b4a58fd926999566a48df8da45fb99
supersedes: []
superseded_by: []
validated_in_dcs: false
---

# ARSOF, SOF Aviation and Early-OEF Operational Models

## 1. Quellenrahmen

Grundlage ist *Weapon of Choice: U.S. Army Special Operations Forces in Afghanistan*. Die Quelle behandelt den Zeitraum 11 September 2001 bis 15 Mai 2002 und ist eine offizielle, bewusst sanitizierte Operationsgeschichte.

```text
SANITIZED_PUBLIC_HISTORY != COMPLETE_OPERATIONAL_RECORD
PSEUDONYM_OR_GENERIC_ELEMENT != EXACT_UNIT_IDENTITY
VIGNETTE_SELECTION != COMPLETE_ORBAT
```

Ergaenzend wurde am 5. September 2026 ein vom Projektinhaber bereitgestellter DTIC-/RAND-/CRS-Quellenbatch gegen dieses Dokument geprueft. Die daraus belastbar nutzbaren Aussagen sind in Abschnitt 17 quellenkritisch aufgenommen. Diese Quellen behandeln ueberwiegend 2001-2002 und dienen daher ausschliesslich als historische Betriebs-, C2-, Targeting- und Logistikreferenz; sie ersetzen keine periodengerechte 2010-2011-ORBAT- oder Verfahrensquelle.

## 2. Führungsstruktur

Wesentliche Organisationen:

- USSOCOM;
- SOCCENT;
- JSOC;
- JSOTF-North / Task Force Dagger;
- spätere CJSOTF-Afghanistan;
- 5th Special Forces Group als Kern von CJSOTF-North;
- 7th und 3rd Special Forces Group in Vorbereitung und Folgeaufträgen;
- 160th Special Operations Aviation Regiment;
- Rangers;
- Civil Affairs;
- Psychological Operations;
- Signal- und Supportkräfte.

## 3. K2 / Karshi-Khanabad als austere SOF base

K2 wurde in kurzer Zeit zu Camp Freedom und JSOTF-North-Hub ausgebaut. Erforderlich waren:

- Host-Nation- und Site Coordination;
- Base Security;
- Runway und Air Movement Control;
- Fuel;
- Water;
- Power;
- billeting;
- food service;
- aviation maintenance;
- communications;
- JOC;
- medical support;
- logistics staging.

Reihenfolge:

```text
ACCESS_AGREEMENT
  -> ADVANCE_PARTY
  -> SECURITY_AND_AIRFIELD_CONTROL
  -> FUEL_AND_POWER
  -> COMMUNICATIONS
  -> AVIATION_MAINTENANCE
  -> JOC
  -> SUSTAINMENT_EXPANSION
```

```text
AIRFIELD_AVAILABLE != OPERATING_BASE_READY
AIRCRAFT_PRESENT != MAINTENANCE_SUPPORTED
SUPPLIES_DELIVERED != SUPPLIES_DISTRIBUTED
```

## 4. Aviation-System

Dokumentierte Plattformen und Rollen:

| Plattform | Rolle |
|---|---|
| MH-47E | Long-range infiltration, resupply, CSAR, high-altitude operations |
| MH-60L DAP | Armed escort and direct fire |
| AH-6 | Night attack and raid support |
| Mi-17 | austere utility movement with contract crews |
| MC-130P | infiltration support and aerial refueling |
| AC-130 | precision fires and overwatch |
| C-17/C-130 | strategic/theater airlift and humanitarian drops |
| P-3C | surveillance/support |
| A-10 | CAS |

Aerial refueling war für Reichweite und Loiter entscheidend. Maintenance war ein einsatzbestimmender Faktor.

```text
AIRFRAME_RANGE != MISSION_RADIUS_WITHOUT_TANKER
AIRCRAFT_TOTAL != AIRCRAFT_MISSION_READY
NIGHT_CAPABLE != WEATHER_INDEPENDENT
HIGH_ALTITUDE_CAPABLE != UNLIMITED_PAYLOAD
```

## 5. CSAR und Personnel Recovery

Northern Air Campaign und CSAR waren eng gekoppelt. MH-47E wurden für Personnel Recovery vorbereitet. Missionen mussten kombinieren:

- alert posture;
- survivor location;
- threat assessment;
- escort;
- tanker support;
- medical capability;
- recovery crew;
- alternate landing or hoist method.

```text
DOWNED_AIRCREW
  -> REPORT_AND_LOCATE
  -> ISOLATION_PLAN
  -> THREAT_SUPPRESSION
  -> RECOVERY_PACKAGE
  -> INFILTRATION
  -> AUTHENTICATION
  -> EXTRACTION
  -> MEDICAL_HANDOVER
```

## 6. Special Forces und indigene Partner

ODAs arbeiteten mit unterschiedlichen afghanischen Führern und Kräften. Wirkung entstand aus:

- rapport;
- communications;
- target designation;
- air-ground integration;
- small-unit advice;
- medical support;
- resupply;
- political mediation.

```text
PARTNER_FORCE_SIZE != PARTNER_FORCE_CONTROL
LOCAL_LEADER_ALLIED != LOCAL_FORCE_DISCIPLINED
TARGET_DESIGNATION != TARGET_AUTHORIZATION
RAPPORT != PERMANENT_LOYALTY
```

## 7. Airpower Integration

ODAs konnten mit Laser Designators und Funk die Wirkung großer Luftstreitkräfte auf taktische Ziele lenken. Erforderlich:

- eindeutige Friendly Location;
- Target Description;
- Attack Geometry;
- Airspace Deconfliction;
- Mark;
- Abort Criteria;
- BDA.

Friktionen:

- unterschiedliche Intelligence-Anforderungen von Air und Ground;
- Zeitverzug;
- Kommunikationsausfälle;
- unklare Friendly Positions;
- Wetter und Gelände;
- Munitions- und Plattformverfügbarkeit.

## 8. Communications

Die Quelle beschreibt Signalaufbau als kritische Grundlage. K2 und später Bagram benötigten:

- SATCOM;
- line-of-sight radio;
- data networks;
- redundant paths;
- power and cabling;
- battle-captain/JOC integration;
- cryptographic control.

```text
PRIMARY_NET_LOSS
  -> ALTERNATE_NET
  -> RELAY_OR_RETRANSMISSION
  -> SATCOM
  -> RUNNER_OR_PREPLANNED_ACTION
```

Ein Kryptografiekompromiss ist als eigener Incident mit Schlüsselwechsel und Netzrekonstitution zu behandeln.

## 9. PSYOP

Dokumentierte Mittel:

- leaflets;
- Commando Solo;
- lokale Radiofrequenzen;
- loudspeaker teams;
- transistor radios;
- tactical messages;
- surrender and reassurance themes.

```text
MESSAGE_BROADCAST != MESSAGE_RECEIVED
MESSAGE_RECEIVED != MESSAGE_BELIEVED
LEAFLET_DROP != BEHAVIOR_CHANGE
```

PSYOP-Wirkung hängt ab von:

- credibility;
- language;
- timing;
- local messenger;
- consistency with observed coalition behavior;
- enemy counter-narrative.

## 10. Civil Affairs und Humanitarian Assistance

CA-Teams arbeiteten an:

- wells;
- schools;
- hospitals;
- humanitarian delivery;
- local negotiations;
- liaison;
- needs assessment.

Inventur, Accountability und Distribution waren ebenso wichtig wie Lieferung.

```text
AID_ARRIVES_AT_BASE != AID_REACHES_POPULATION
AID_DISTRIBUTED != GOVERNMENT_CREDIT
LOCAL_REQUEST != VERIFIED_PRIORITY
```

## 11. Aerial Resupply

Einsatzmuster:

- receiver-marked drop zones;
- bundles from altitude;
- emergency resupply;
- date drops;
- vehicle and equipment insertion;
- recovery of misdropped supplies.

Risiken:

- navigation error;
- wind drift;
- enemy observation;
- bundle damage;
- inability to recover heavy loads;
- compromise of team location.

## 12. Tarin Kowt, Kandahar and southern campaign

Die Quelle dokumentiert die Kombination aus:

- ODA support to Afghan forces;
- close air support;
- rapid political-military alignment;
- ground maneuver toward Kandahar;
- tactical engagements at bridges and approaches;
- Civil Affairs after combat.

Für OMW gilt:

```text
CITY_CAPTURED != REGION_STABILIZED
LOCAL_LEADER_EMPOWERED != GOVERNANCE_INSTITUTIONALIZED
TACTICAL_AIRPOWER_SUCCESS != POST_CONFLICT_CONTROL
```

## 13. Tora Bora und Anaconda

Die Fälle zeigen:

- Grenzen kleiner Ground Footprints;
- Bedeutung von Blocking Positions;
- komplexe SOF-/Conventional-/Air-Integration;
- Hochgebirgs- und LZ-Probleme;
- Rescue under Fire;
- Friktionen durch unvollständige gemeinsame Planung.

Takur Ghar und andere Rescue-Fälle bestätigen:

```text
ISR_CONTACT != COMPLETE_SITUATIONAL_AWARENESS
EXTRACTION_HELICOPTER != SECURED_LZ
CAS_AVAILABLE != IMMEDIATE_FIRE
```

## 14. Base- und JOC-Modell

```yaml
sof_base:
  runway_status:
  fuel_state:
  water_state:
  power_state:
  billeting_capacity:
  maintenance_capacity:
  communications_primary:
  communications_alternate:
  medical_capacity:
  security_state:
  air_movement_capacity:
  jstaff_capacity:
```

## 15. OMW-Nutzungsgrenzen

Die Quelle darf verwendet werden für:

- frühe SOF- und Aviation-Prinzipien;
- austere basing;
- CSAR;
- Air-Ground Integration;
- PSYOP/CA;
- Kommunikationsfriktion.

Sie darf nicht unverändert die 2010/2011-ORBAT bestimmen.

## 16. Querverweise

- `docs/45-air-c2-cas-afghanistan.md`
- `docs/50-afghanistan-force-basing-aviation-2010-2011.md`
- `docs/52-army-aviation-vignettes-and-coin-intelligence-metrics.md`
- `docs/54-air-tasking-airspace-control-cas-requests-and-mission-data.md`
- `docs/60-afghan-air-wars-2009-2011-airpower-operations-reference.md`
- `docs/63-ntma-sfa-attack-the-network-stratcom-and-local-influence.md`

## 17. Ergaenzender DTIC-/RAND-/CRS-Quellenbatch vom 5. September 2026

### 17.1 Quellenbewertung

Die folgenden vom Projektinhaber bereitgestellten Dokumente enthalten fuer OMW belastbare Zusatzinformationen. Wegen ihres Zeitstands sind sie als **Early-OEF-Hintergrund** und nicht als direkte 2010-2011-Baseline zu verwenden.

| DTIC/Report-ID | Quelle | OMW-Wert | Evidenzgrenze |
|---|---|---|---|
| `ADA449279` | Benjamin S. Lambeth, *Air Power Against Terror: America's Conduct of Operation Enduring Freedom*, RAND MG-166-CENTAF, 2005 | **hoch** fuer Air-Ground-Integration, ISR-Fusion, Targeting- und Logistikfriktion | untersucht im Kern 7.10.2001 bis Maerz 2002; keine 2010/2011-ORBAT- oder ROE-Baseline |
| `ADA434031` | Daniel L. Haulman, *Intertheater Airlift Challenges of Operation Enduring Freedom*, Air Force Historical Research Agency, 14.11.2002 | **hoch** fuer strategischen Airlift, austere basing, Ramp-/Staging- und Cargo-Flow-Friktion | Early OEF; keine automatische Uebertragung konkreter Kapazitaeten auf 2010/2011 |
| `ADA429053` | Richard G. Rhyne, *Special Forces Command and Control in Afghanistan*, U.S. Army Command and General Staff College, 2004 | **hoch** fuer SOF-/Conventional-C2, OPCON/TACON und gemeinsame Planung | Fallstudie vor allem 2001-2002; keine direkte 2010/2011-C2-ORBAT |
| `ADA422702` | David D. Kindley, *"Why Won't You Drop, Damn You!?" - An Examination of the Targeting Process in Operation Enduring Freedom and its Implications*, Naval War College | **hoch** fuer ROE-Verstaendnis, CAS/TST-Targeting und Freigabefriktion | bibliographischer Datumswiderspruch: Titelblatt 2.2.2003, Report Documentation Page 2.2.2004; Early-OEF-Fallstudie |
| `ADA540984` | RAND, *Operation Enduring Freedom: An Assessment*, RB-9148-CENTAF, 2005 | **mittel**, kompakte Zusammenfassung von Lambeth | Sekundaerzusammenfassung des umfangreicheren `ADA449279`; keine unabhaengige Baseline |
| `RL31152` / `ADA477221` | CRS, *Operation Enduring Freedom: Foreign Pledges of Military & Intelligence Support*, Update 17.10.2001 | **niedrig bis mittel** fuer Coalition Access/Basing als Startbedingung | Momentaufnahme unmittelbar nach Operationsbeginn; Zusagen teilweise ausdruecklich als unklar/vage bezeichnet |

### 17.2 Air-Ground-Integration und ISR

Lambeth dokumentiert fuer Early OEF eine fuer das Missionsdesign relevante Kombination aus technischen Sensoren und menschlichen Sensoren:

- Global Hawk und bewaffnete Predator wurden operativ eingesetzt;
- eine dauerhaft gespeiste ISR-Lage kombinierte mehrere luft- und weltraumgestuetzte Sensoren;
- SOF-Teams dienten zugleich als lokale, bewegliche `human ISR sensors`, identifizierten Ziele und verbanden diese mit Praezisionsluftmacht;
- der operative Effekt entstand nicht aus einem einzelnen Sensor, sondern aus **Fusion, Kommunikation, Zielidentifikation und anschliessender Waffenwirkung**.

Quelle: Lambeth, `ADA449279`, Summary xxii-xxiv, PDF-Seiten 26-28. Der RAND Research Brief `ADA540984` fasst dieselben Befunde zusaetzlich zusammen.

OMW-Ableitung:

```text
SENSOR_CONTACT != TARGET_AUTHORIZATION
ISR_FEED != COMMON_OPERATING_PICTURE_WITHOUT_FUSION
UAV_ON_STATION != TARGET_POSITIVELY_IDENTIFIED
SOF_EYES_ON_TARGET != AUTOMATIC_WEAPON_RELEASE
```

Diese Aussagen stuetzen das bestehende OMW-Prinzip, ISR, Request/Tasking, Zielkorrelation und Waffenfreigabe getrennt zu modellieren. Sie rechtfertigen **keine** automatische bewaffnete UAV-Freigabe und keine 2010/2011-spezifische Sensorreichweite ohne periodengerechte Quelle.

### 17.3 Airlift, austere basing und logistische Engpaesse

Haulman identifiziert in Early OEF mehrere wiederkehrende Mobility-Probleme:

- fehlende beziehungsweise begrenzte Theaterinfrastruktur;
- zu wenige geeignete Offload-Basen;
- ueberlastete Intermediate Staging Bases;
- unzureichende In-Transit Visibility und inkompatible Daten-/Trackingprozesse;
- Abhaengigkeit von C-17 fuer kleinere beziehungsweise weniger entwickelte Flugplaetze;
- Wartungs- und Verfuegbarkeitsprobleme aelterer Transportmuster;
- Cargo- und Ramp-Backlogs, wenn Zufluss groesser als die lokale Entlade-/Weiterleitungsleistung war.

Haulman nennt Kandahar und Bagram als zentrale Early-OEF-Theaterbasen und beschreibt, dass auch nach ihrer Oeffnung die begrenzte Abfertigungsleistung den Zufluss begrenzte. Quelle: Haulman, `ADA434031`, S. 1, 6-8.

Lambeth ergaenzt, dass bis zur Oeffnung einer Landverbindung aus Usbekistan Ende November praktisch alles, einschliesslich Treibstoff, eingeflogen werden musste. Quelle: Lambeth, `ADA449279`, Summary xxiv, PDF-Seite 28.

OMW-Ableitung fuer Logistik und Base Capacity:

```text
RUNWAY_AVAILABLE != UNLIMITED_THROUGHPUT
CARGO_ARRIVED != CARGO_AVAILABLE_AT_DESTINATION
AIRLIFT_CAPACITY != OFFLOAD_CAPACITY
AIRCRAFT_IN_INVENTORY != MISSION_CAPABLE_AIRCRAFT
STAGING_BASE != INFINITE_RAMP_OR_BILLETING_CAPACITY
```

Diese Early-OEF-Belege sind fuer OMW als **Systemdesign-Prinzipien** relevant. Konkrete 2010/2011-Kapazitaeten, Flugbewegungen oder Bestandszahlen muessen weiterhin aus periodengerechten Quellen stammen.

### 17.4 SOF-/Conventional-C2 und zeitkritische Planung

Rhyne zeigt anhand der C2-Umstellungen 2002, dass die Integration von Special Forces und konventionellen Verbaenden nicht allein durch organisatorische Zugehoerigkeit geloest wurde. Dokumentiert sind insbesondere:

- wechselnde `OPCON`-/`TACON`-Beziehungen zwischen CJSOTF-A und konventionellen Joint-Task-Force-Strukturen;
- der Einsatz von SOCCE-Elementen in konventionellen Tactical Operations Centers;
- gemeinsame Planungsprozesse und direkte Liaison als Beschleuniger;
- erhebliche Verzoegerungen fuer actionable intelligence bei langen Freigabekanaelen;
- deutlich kuerzere Reaktionszeiten nach engerer organisatorischer und raeumlicher Integration.

Quelle: Rhyne, `ADA429053`, S. 41-47, insbesondere die C2-Diagramme auf S. 41 und 44 sowie die Ausfuehrungen zu den Freigabezeiten auf S. 45-46.

OMW-Ableitung:

```text
INTELLIGENCE_AVAILABLE != FORCE_TASKED
SUPPORTING_RELATIONSHIP != UNDEFINED_AUTHORITY
DIRECT_LIAISON != RESOURCE_OWNERSHIP
JOINT_PLANNING != AUTOMATIC_EXECUTION_CLEARANCE
```

Fuer OMW bestaetigt dies die bereits vorgesehene Trennung von strategischer Autoritaet, Request/Tasking, physischer Ausfuehrung und klaren Zustandsuebergaengen.

### 17.5 ROE-, Targeting- und Freigabefriktion

Kindley beschreibt einen Early-OEF-Fall, in dem das formell veroeffentlichte ROE-Verstaendnis und das tatsaechliche Verstaendnis bei Piloten, AWACS und Air-Operations-Personal auseinanderliefen. Seine zentrale Beobachtung ist fuer OMW nicht die konkrete 2001er ROE-Regel, sondern die **Prozessgefahr einer uneindeutigen oder falsch verstandenen Freigabekette**. Er trennt ausserdem vorgeplante ATO-Ziele, FAC-gefuhrte CAS-Situationen und Time-Sensitive Targeting.

Quelle: Kindley, `ADA422702`, gedruckte S. 4-7.

OMW-Ableitung:

```text
ATO_ENTRY != WEAPON_RELEASE_AUTHORITY
TARGET_COORDINATE != POSITIVE_IDENTIFICATION
FAC_REQUEST != UNCONDITIONAL_CLEARANCE
ROE_PUBLISHED != ROE_UNDERSTOOD
```

Damit wird die bestehende OMW-Regel gestuetzt, dass Targeting, Friendly-Risk, ziviles Umfeld, ROE und ausdrueckliche Angriffserlaubnis getrennt nachvollziehbar bleiben muessen.

### 17.6 Nur begrenzt oder nicht in Fachbaselines uebernommene Dokumente

Vier weitere Dateien wurden geprueft, erzeugen aber **keine neue OMW-Fachbaseline**:

- `ADA415851`, John G. Clement, *Operation Enduring Freedom as an Enabling Campaign in the War on Terrorism* (SAMS, 2003): interessante Kampagnentheorie zu `enabling` versus `terminal campaign`, aber fuer den aktuellen OMW-Grundbau zu abstrakt und nicht periodenspezifisch genug fuer eine neue Designregel.
- `ADA519692`, *Mental Health Advisory Team (MHAT) V ... Operation Enduring Freedom 8: Afghanistan* (2008): relevante Human-Factors-/Belastungsdaten, aber derzeit kein ausreichend direkter Bezug zu einer OMW-System- oder Missionseditorentscheidung.
- `ADA495793`, GAO-09-302, *DOD Needs to More Accurately Capture and Report the Costs of Operation Iraqi Freedom and Operation Enduring Freedom* (2009): Haushalts-/Kostenreporting, fuer OMW-Missionsdesign ohne belastbaren Mehrwert.
- `ADA498363`, CRS RS22452, *United States Military Casualty Statistics: Operation Iraqi Freedom and Operation Enduring Freedom* (25.3.2009): historische Casualty-/MEDEVAC-Statistik, aber vor dem Kampagnenzeitraum und teilweise theateruebergreifend aggregiert; deshalb keine direkte OMW-Verlust-, IED- oder MEDEVAC-Rate daraus ableiten.

### 17.7 Verbindliche Nutzungsgrenze fuer den Quellenbatch

Der Batch erhoeht die Quellenbasis fuer **Prinzipien** von C2, ISR, Air-Ground-Integration, Targeting und Logistics Friction. Er aendert keine aktive OMW-ORBAT und setzt keine konkrete 2010/2011-Frequenz, Callsign-, ROE-, Flugplan-, Bestands-, Endurance-, Fuel- oder Base-Capacity-Zahl.

```text
EARLY_OEF_OPERATIONAL_LESSON != 2010_2011_PERIOD_FACT
CORROBORATING_SOURCE != ACTIVE_ORBAT_DECISION
HISTORICAL_PROCESS_FRICTION != DCS_RUNTIME_VALIDATION
```
