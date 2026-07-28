---
document_id: OMW-C2-AIR-C2-CAS-AFGHANISTAN
status: BINDING
document_class: SOURCE_DERIVED_DESIGN_REFERENCE
source_status: SOURCE_CAPTURE_COMPLETE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-derived Air C2 and CAS mission-design requirements
  - separation of ASOC, TACP, FAC, AFAC, JTAC, JFO, ground commander and aircrew roles
  - OMW CAS planning and execution data flow
not_authoritative_for:
  - DCS runtime acceptance
  - mission-specific frequencies or current ORBAT
  - real-world JTAC or aircrew qualification
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - SOURCE_CAPTURE_COMPLETE used as document status
superseded_by:
source_branch: agent/document-ato-asr-aar-buddy-lasing
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# 45 - Air C2 und Close Air Support in Afghanistan

## 1. Einordnung

Dieses Dokument ist die verbindliche quellenbasierte Designreferenz für Air C2 und CAS in **Operation Mountain Watch**. Es trennt Quellenbefund, Projektableitung und spätere technische Umsetzung.

Der vollständige dreiteilige Quellen- und Auswertungstext der Serie `Who's in Charge?` bleibt unverändert erhalten:

- [`Legacy-Quellenfassung mit vollständiger Serie`](evidence/source-records/legacy-45-air-c2-cas-afghanistan-source-capture.md)

Die ergänzend bereitgestellte NATO-Publikation ATP-3.3.2.1, Edition D Version 1, April 2019, wird für CAS-/AI-Verfahren, Air Support Requests, Terminal Attack Control, UAS-Integration und Laseroperationen ausgewertet.

**Credits für Recherche und Quellenzusammenstellung: Graveyard of Empires - <https://www.patreon.com/cw/graveyard4DCS>**

## 2. Quellenstatus

```yaml
source_series: Who's in Charge? Air C2 and Close Air Support in Afghanistan
source_author: Graveyard of Empires
parts_available: 3/3
nato_source: ATP-3.3.2.1 Edition D Version 1 April 2019
nato_source_status: EVALUATED_FOR_MISSION_DESIGN
source_status: SOURCE_CAPTURE_COMPLETE
primary_source_verification: PARTIAL
```

Die Projektnutzung folgt [`OMW-GOV-SOURCE-USE`](sources/graveyard-of-empires.md). Patreon-Darstellung, identifizierte Originalquelle, unabhängige Recherche und OMW-Projektentscheidung bleiben getrennt.

## 3. CAS-Grundverständnis

CAS ist Luftwirkung gegen feindliche Ziele in enger Nähe zu eigenen Kräften, die eine detaillierte Integration jeder Luftmission mit Feuer und Bewegung dieser Kräfte erfordert. `Close` bezeichnet dabei keine feste Entfernung. Entscheidend ist der Integrationsbedarf aufgrund von Nähe, Feuer, Bewegung, Luftraum und möglicher Wirkung auf Friendlies oder Zivilpersonen.

CAS ist ein Bestandteil von Joint Fire Support. Es ist deshalb kein isolierter Luftauftrag und keine reine Waffenfunktion. Die Ground Force Commander bestimmen Zielpriorität, gewünschten Effekt und Timing innerhalb ihres Verantwortungsbereichs. Die Air Component bleibt für Planung und Einsatz der bereitgestellten Luftkräfte verantwortlich.

### 3.1 Bedingungen für wirksames CAS

Die NATO-Quelle nennt als wesentliche Bedingungen:

- ausgebildetes und geübtes Personal;
- detaillierte Planung und Integration;
- wirksames, flexibles Command and Control;
- ausreichende Luftüberlegenheit und erforderlichenfalls SEAD;
- eindeutige Zielkorrelation, Markierung und Zielaufnahme;
- schnelle und anpassbare Verfahren;
- zum Ziel und Effekt passende Bewaffnung;
- berücksichtigte Wetter-, Sicht- und Terrainbedingungen.

Diese Bedingungen werden in OMW als Planungs- und Freigabekriterien behandelt, nicht nur als Briefingtext.

## 4. Rollen und Autorität

| Rolle/Element | Kernaufgabe im OMW-Modell |
|---|---|
| Ground Force Commander | Zielpriorität, gewünschter Effekt, Timing und Annahme taktischer Risiken |
| JFAC/CAOC | Air Planning, Allocation, ATO/ACO/SPINS und operative Steuerung |
| AOCC/ASOC | landnahe Air-C2-Koordination, Immediate Requests, Alert Launch, Retasking und Weiterleitung |
| TACP/ALO | Beratung des Ground Commanders, Air-Land-Integration und CAS-Planung |
| JFSE | Integration aller Joint Fires und Fire Support Coordination Measures |
| JTAC | Terminal Attack Control, CAS-Brief, Deconfliction, Clearance und initiale BDA |
| FAC(A)/AFAC | airborne Terminal Attack Control beziehungsweise CAS-Koordination im zugewiesenen Rahmen |
| JFO/Observer | Zielbeobachtung, Daten und Terminal Guidance innerhalb der eigenen Qualifikation; keine automatische Release Authority |
| Aircrew | Plattform-, Sensor-, Waffen- und Taktikempfehlung; sichere Waffenanwendung |
| ISR/UAS-Crew | Sensor-, Daten-, Markierungs-, Relay- und gegebenenfalls Waffenbeitrag unter denselben CAS-Verfahrensanforderungen |

Terminal Guidance Operations liefern Zielinformationen oder Guidance, sind aber nicht mit Terminal Attack Control gleichzusetzen. Personal ohne JTAC-/FAC(A)-Befugnis erhält durch Laser, Video, Koordinaten oder Funkkontakt keine automatische Waffenfreigabebefugnis.

## 5. Verbindliche Missionsdesign-Grundsätze

- CAS ist ein Führungs-, Koordinations- und Identifikationsprozess, nicht nur Waffenwirkung.
- ASOC/AOCC, TACP, JFSE, FAC, FAC(A), JTAC, JFO, Aircrew und Ground Commander besitzen getrennte Rollen.
- Zielinformationen, Friendly Positions, ziviles Umfeld, ROE, NSL, verfügbare Waffen und gewünschter Effekt müssen nachvollziehbar übergeben werden.
- Unklare Autorität oder widersprüchliche Zielinformationen blockieren die Angriffserzeugung.
- Spieler- und KI-Aufträge müssen auf demselben `MissionDemand` beziehungsweise Zielobjekt arbeiten.
- Die No-Strike-List und positive Zielbestätigung sind vor jeder Zielnominierung und vor Weapons Release zu prüfen.
- Request, ATO-Mission, CAS Brief, Attack Clearance und BDA sind getrennte, verknüpfte Datensätze beziehungsweise Zustände.
- Jeder Angriff benötigt Zielkorrelation; ein früherer erfolgreicher Angriff ersetzt die Korrelation für einen Folgeangriff nicht.
- Restriktionen werden auf das für Sicherheit, ROE, Deconfliction und gewünschten Effekt notwendige Minimum begrenzt.

## 6. Request-to-Tasking-Kette

```text
Ground Commander / Requestor
-> ASR/JTAR mit stabiler Request-ID
-> Prüfung, Priorisierung und Approval in der Ground-/Fire-Support-Kette
-> Air-C2-Zuweisung
-> ATO-Mission oder Immediate Retasking
-> Aircraft Check-in und Situation Update
-> Game Plan und CAS Brief
-> Readback und Correlation
-> Attack Clearance
-> Wirkung und BDA
-> Reattack, Folgeauftrag oder Abschluss
```

Die Einzelheiten stehen in:

- [`OMW-C2-JTAR-ASR`](55-jtar-asr-air-support-request.md);
- [`OMW-C2-ATO-ACO-SPINS`](54-air-tasking-order-aco-spins.md).

Die Request-ID bleibt bei Ground Alert, Aircraft Swap, Retasking und Reattack nachvollziehbar. Ein genehmigter Request ist noch keine Waffenfreigabe.

## 7. Method of Attack: BOT und BOC

Method of Attack und Type of Control sind voneinander unabhängig. Beide werden im Game Plan angegeben.

### 7.1 Bomb on Coordinates - BOC

BOC wird verwendet, wenn der gewünschte Effekt durch Einsatz auf einen ausreichend genauen Koordinatensatz erzeugt werden kann und die Aircrew das Ziel oder den Mark nicht zwingend `TALLY`, `CONTACT` oder `CAPTURED` haben muss.

OMW-Anforderungen:

- Koordinatengenauigkeit muss zur Waffe, Zielart, Friendly-Nähe und gewünschten Wirkung passen;
- Datum und Koordinatenformat werden mitgeführt;
- Line 4, Line 6, Line 8 und relevante Restriktionen werden aus dem System beziehungsweise Waffenprofil zurückgelesen;
- nach bestätigtem Readback werden Koordinaten nicht stillschweigend verändert;
- Off-board-Lasing kann Bestandteil eines BOC-Angriffs sein.

### 7.2 Bomb on Target - BOT

BOT erfordert, dass die Aircrew das beabsichtigte Ziel oder den Mark `TALLY`, `CONTACT` oder `CAPTURED` hat. Es ist besonders geeignet für mobile beziehungsweise sich verändernde Zielbilder, visuell eindeutige Ziele und Situationen, in denen schnelle Zielaufnahme zweckmäßiger ist als aufwendige Koordinatenmensuration.

OMW-Anforderungen:

- Zielbeschreibung muss das eigentliche Ziel und nicht nur dessen Umgebung beschreiben;
- Koordinaten dienen mindestens zur Cueing- und Fires-Approval-Plausibilisierung;
- Target Talk-on, Mark oder Sensor Correlation werden protokolliert;
- bei Zielverlust erfolgt keine Fortsetzung allein auf Basis einer früheren Sichtbestätigung.

## 8. Types of Terminal Attack Control

Der Type of Control wird aus taktischer Risikobewertung, Beobachtungsmöglichkeit, Zielkorrelation, Geschwindigkeit und Risikominderung abgeleitet. Er ist nicht an eine bestimmte Waffenart und nicht fest an BOT oder BOC gebunden.

### 8.1 Type 1

Type 1 kontrolliert jeden einzelnen Angriff. Der JTAC/FAC(A) benötigt visuelle Aufnahme von Ziel und angreifendem Luftfahrzeug und bewertet die Attack Geometry. Clearance erfolgt erst nach Abschluss des Anflugmanövers entsprechend der Verfahrenslage.

### 8.2 Type 2

Type 2 kontrolliert ebenfalls jeden einzelnen Angriff, wird aber eingesetzt, wenn der JTAC/FAC(A) das angreifende Luftfahrzeug bei Release und/oder das Ziel nicht visuell erfassen kann. Echtzeitdaten anderer Sensoren, UAS-Video, Markierung und vollständige Korrelation werden entsprechend wichtiger. Jeder Angriff erhält weiterhin `CLEARED HOT`, `CONTINUE DRY` oder `ABORT`.

### 8.3 Type 3

Type 3 erlaubt mehrere Angriffe innerhalb eines Engagements unter klaren Grenzen für Zielset, Raum, Zeit, Waffen und Attack Geometry. Nach Readback kann `CLEARED TO ENGAGE` erteilt werden. Die Aircrew meldet `COMMENCING ENGAGEMENT` und abschließend `ENGAGEMENT COMPLETE`; der JTAC/FAC(A) überwacht die Lage und behält Abort Authority.

### 8.4 OMW-Regel

Der Type of Control wird nicht automatisch anhand von Flugzeugtyp, KI/Spieler oder Waffenklasse gewählt. Er wird pro Engagement begründet und in Game Plan, CAS Brief und Zustandsautomat geführt. Wechsel des Control Type benötigen erneute Koordination vor dem relevanten terminalen Call.

## 9. CAS-Ausführungsfolge

Die OMW-CAS-Ausführung bildet mindestens folgende Phasen ab:

1. Battle-Staff- und Airspace-Koordination;
2. Routing/Safety of Flight;
3. Aircraft Check-in mit Plattform-, Waffen-, Sensor-, Spielzeit- und Abortdaten;
4. Situation Update zu Friendlies, Enemy, Target Area, Threats, Weather und Einschränkungen;
5. Game Plan mit Control Type, BOT/BOC, gewünschtem Effekt und Ordnance;
6. CAS Brief beziehungsweise 9-Line;
7. Remarks und Restrictions, einschließlich Attack Heading, Danger Close, ACA, TOT/TTT und Post-Launch-Abort;
8. Readbacks;
9. Correlation und Marking;
10. `CLEARED HOT`, `CLEARED TO ENGAGE`, `CONTINUE DRY` oder `ABORT`;
11. Weapon Release, Guidance und Impact;
12. Wirkungseinschätzung und BDA;
13. Reattack-Entscheidung, Check-out und Übergabe.

Die CAS-Brief-Entwicklung beginnt mit Ziel und gewünschtem Effekt und arbeitet rückwärts zu Plattform, Waffe, Methode, Control Type, Marking, Attack Geometry, Deconfliction und Timing.

## 10. Targeting, Friendlies und Wirkung

Für die erste Planung benötigt der Controller mindestens:

- Target Description;
- Target Location und Elevation;
- Friendly Location;
- gewünschte Wirkung des Ground Commanders.

Die erforderliche Koordinatengenauigkeit hängt ab von:

- Plattform- und Waffensystem;
- Friendly-Nähe;
- Zielart und Beweglichkeit;
- Collateral-Damage-Lage;
- BOT/BOC;
- Marking-/Laserplan;
- Wetter und Sensorleistung.

Friendly Locations dürfen nicht als generische Zielkoordinaten in einem Request verwendet werden. Moving Targets benötigen Bewegungsrichtung, Geschwindigkeit, aktualisierte Position sowie erneute Prüfung von Friendlies, FSCM und Airspace.

## 11. UAS-Integration

Bewaffnete oder unbewaffnete UAS nutzen dieselben CAS-Grundverfahren wie bemannte Luftfahrzeuge. Missionsplanung berücksichtigt zusätzlich:

- tatsächliche Sensoren: EO, Thermal, Near-IR, SAR, MTI und Video;
- Laser Designator, Laser Spot Tracking und veränderbare Codes;
- Sensor Masking und Abbruch der Designation durch Flugprofil oder Airframe;
- Lost Communications und Lost Link;
- Contingency Routes;
- niedrige Transitgeschwindigkeit und begrenzte kurzfristige Verlegefähigkeit;
- Operating Area, Orbit und Höhen-Deconfliction;
- Launch-/Recovery-Wetter;
- Radio Relay und Datenlink;
- bei Bewaffnung denselben Attack-, Clearance- und Airspace-Prozess wie bei anderen Weapon-Delivery-Plattformen.

Die historische und technische MQ-1-/MQ-9-Einordnung wird in dem dafür vorgesehenen UAS-Dokument geführt. UAS-Video oder Laser ersetzt keine geklärte Autorität.

## 12. Laser- und Buddy-Lasing-Verfahren

Buddy Lasing und Laser Handover ergänzen die normale CAS-Kette. Sie ersetzen weder Game Plan, CAS Brief, Readback, Correlation noch Attack Clearance.

Verbindlich zu führen sind:

- Shooter, Designator und Controller;
- Ziel-ID und Zielpunkt;
- Laser-Code;
- Continuous oder Delayed Lasing;
- Laser-On- und Impactfenster;
- `CAPTURED`, `LASING`, `SPOT` beziehungsweise Negativstatus;
- `SHIFT`, `DEAD EYE`, `CEASE LASER` und `ABORT`.

Die vollständige Arbeitsreferenz steht in [`OMW-CAS-BUDDY-LASING`](56-buddy-lasing-phraseology.md).

## 13. Afghanistan-spezifische Planungsfolgen

Terrain, Wetter, Staub, Sicht und hohe Density Altitude beeinflussen Plattform, Sensoren, Waffe und Attack Geometry. In bergigem Gelände sind insbesondere zu prüfen:

- maskierte Funk- und Sichtverbindungen;
- eingeschränkte Talk-on-Referenzen;
- Geländeüberhöhung und sichere Egress-Routen;
- UAS-/Helikopter-Orbits und Höhenstaffelung;
- Laser-Maskierung;
- Wolkenbasis und Sicht zwischen Shooter, Designator und Ziel;
- indirektes Feuer aus FOBs und dessen ACA-/ROZ-Bedarf;
- zivile Siedlungen, NSL-Objekte und Verkehrswege;
- Auswirkung von Wind und Temperatur auf Rotary-Wing- und Weapons Employment.

Favorable Weather ist keine Voraussetzung für CAS, aber die eingesetzte Plattform, Methode, Control Type und Waffe müssen zu den tatsächlichen Bedingungen passen.

## 14. Technische Zielarchitektur

Vorrangig zu prüfen und einzusetzen:

- `COMMANDER` und `AIRWING` für Zuweisung und Ausführung;
- `AUFTRAG` für KI-Missionen;
- `PLAYERTASK` für Spieleraufträge;
- `INTEL`, `DETECTION`, `TARGET`, `PLAYERRECCE` und `DESIGNATE` für Aufklärung und Zielentwicklung;
- MOOSE-Events/FSM für Request-, Assignment-, Control-, Attack-, Abort- und BDA-Zustände;
- projektbezogene Adapter nur nach Dokument 26.

Die vollständige technische MOOSE-Einordnung steht in:

- [`ISR-, FAC-, AFAC-, JTAC-, CAS- und AAR-Architektur`](moose/ISR-FAC-CAS-AAR.md)

## 15. Verbindliche Datenverknüpfung

```yaml
CasEngagement:
  engagementId:
  requestId:
  atoMissionId:
  targetId:
  targetVersion:
  groundCommanderId:
  controllerId:
  flightId:
  controlType:
  attackMethod: BOT | BOC
  desiredEffect:
  selectedOrdnance:
  friendlyLocations:
  targetLocation:
  markPlan:
  laserPlanId:
  airspaceMeasures:
  restrictions:
  clearanceState:
  weaponEvents:
  bda:
  status:
```

## 16. Noch erforderliche Acceptance

- missionsspezifische C2-Kette und Menüs;
- Spieler-/KI-Übergabe desselben Requests und Zielobjekts;
- vollständiger Aircraft Check-in, Situation Update, Game Plan und CAS Brief;
- Type-1-/Type-2-/Type-3-Zustandsautomaten;
- BOT-/BOC-Readbacks und Correlation;
- Zielaktualisierung, Moving Targets und Abbruch;
- Funk- und Frequenzmodell;
- Multiplayer-Synchronisation;
- NSL-, ROE- und ACO-Blockierung;
- UAS-, FAC(A)-, JFO- und Buddy-Lase-Integration;
- reproduzierbare DCS-Tests für Clearance, Weapon Release, BDA und Reattack.
