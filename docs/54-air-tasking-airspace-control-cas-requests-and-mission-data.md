---
document_id: OMW-AIR-TASKING-AIRSPACE-CAS-REQUESTS
status: BINDING
document_class: AIR_C2_AND_MISSION_DATA_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - OMW internal data model for ATO-like tasking, ACO-like airspace control and SPINS-like instructions
  - OMW lifecycle for preplanned and immediate air-support requests
  - source qualification and implementation boundaries for the evaluated ATO, ACO, SPINS, JTAR, ASR, AAR and buddy-lasing sources
not_authoritative_for:
  - a real 2010-2011 ATO, ACO or SPINS product
  - active campaign ORBAT
  - real operational frequencies, IFF codes, laser codes or classified procedures
  - exact national doctrine or phraseology
  - DCS or MOOSE technical acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: docs/afghanistan-force-aviation-source-consolidation
source_commit: c3f61115480b4fd4c36fc7b0adcd76104c0b93ff
validated_in_dcs: false
---

# 54 – Air Tasking, Airspace Control, CAS Requests und Missionsdaten

## 1. Zweck

Dieses Dokument konsolidiert die noch nicht in der Projektdokumentation erfassten Quellen zu:

- Air Tasking Order (ATO);
- Airspace Control Order (ACO);
- Special Instructions (SPINS);
- Joint Tactical Air Strike Request (JTAR);
- NATO Air Support Request (ASR);
- Ground Alert und Airborne Alert;
- ATO-/USMTF-/ADatP-3-Datenfeldern;
- CAS-, AAR- und Supportmissionen;
- Tanker-Callsigns, AAR-Höhen und vermuteten ROZ-Lagen;
- Buddy Lasing und Laser-Handover;
- NATO CAS- und Air-Interdiction-Doktrin von 2019.

Ziel ist kein vollständiger militärischer ATO-Generator. Ziel ist ein belastbares internes OMW-Datenmodell, aus dem für Spieler und Missionslogik verständliche Produkte erzeugt werden können.

## 2. Autoritätsgrenze

Die ausgewerteten Quellen enthalten unterschiedliche Zeitstände und Qualitätsstufen:

- offizielle NATO-Doktrin von 2019;
- nichtamtliche Quick Guides von 2024;
- DCS-orientierte Sekundärartikel von 2024/2025;
- synthetische Ausbildungsbeispiele;
- aus Foren, Archiven und Karten abgeleitete Hypothesen;
- bereits bestehende OMW-Quellen zu ISAF-AAR-Räumen 2009–2013.

Daraus folgt:

1. Moderne Doktrin kann eine robuste OMW-Struktur begründen, beweist aber nicht die exakte Formulierung oder das Verfahren im Jahr 2010/2011.
2. Synthetische Beispiele erklären Felder, sind aber keine historischen Missionen.
3. Vermutete Tanker-Callsigns, Höhen und Tracks werden nicht zu historischen Tatsachen hochgestuft.
4. Reale Codes, Frequenzen, IFF-Werte oder Sicherheitsinformationen werden nicht aus Beispielen in die Kampagne kopiert.
5. Die aktive Luft-ORBAT bleibt ausschließlich Dokument 19 vorbehalten.

## 3. Quellenregister

### T01 – NATO ATP-3.3.2.1, Edition D Version 1, April 2019

Titel:

```text
Tactics, Techniques and Procedures for Close Air Support and Air Interdiction
```

Einstufung:

```text
source_type: OFFICIAL_NATO_DOCTRINE
classification_marking: NATO UNCLASSIFIED
period_relation: POST_PERIOD_DOCTRINAL_REFERENCE
```

Verwertbar für:

- CAS-Grundlagen;
- Command and Control;
- Planung und Anforderung;
- Air Support Requests;
- Type 1/2/3 Control;
- Fire Support Coordination Measures;
- Airspace Control Means;
- Terrain-, Wetter- und Zeitplanung;
- Laser-Operationen;
- Fixed-Wing-, Rotary-Wing-, UAS- und FAC(A)-Integration;
- 9-Line, Readbacks, Correlation, Attack, Abort und BDA;
- Emergency CAS;
- Air Interdiction und SCAR;
- NATO-ASR-Template in Appendix C.

Grenzen:

- veröffentlicht acht Jahre nach dem OMW-Zeitraum;
- nationale Vorbehalte zeigen abweichende Terminologie und Verfahren;
- darf nicht als Beweis verwendet werden, dass jede Nation 2010/2011 exakt diese Ausgabe anwandte;
- die Publikation ersetzt keine missionszeitbezogene ATO, SPINS oder nationale SOP.

### T02 – Combined Ops, *ATO, ACO and SPINS Quick Guide*, 8. März 2024

Einstufung:

```text
source_type: SECONDARY_TECHNICAL_GUIDE
period_relation: POST_PERIOD_REFERENCE
```

Verwertbar für:

- verständliche Einführung in ATO-, ACO- und SPINS-Struktur;
- beispielhafte USMTF-Sets und Felder;
- Header, Ausführungszeitraum, Task Unit und Mission Blocks;
- ACO-Airspace-Control-Means;
- typische SPINS-Themen und stehende/tägliche Anteile.

Grenzen:

- keine amtliche Publikation;
- Beispiele sind Ausbildungs- oder Demonstrationsdaten;
- Felddefinitionen müssen bei produktiver Parserentwicklung gegen die tatsächlich verwendete Formatversion geprüft werden;
- kein Nachweis einer Afghanistan-ATO aus 2010/2011.

### T03 – Graveyard of Empires, *Air Tasking Order – Introduction*, 10. November 2024

Einstufung:

```text
source_type: SECONDARY_DCS_INTERPRETATION
period_relation: POST_PERIOD_REFERENCE
```

Verwertbar für:

- Zusammenhang von Strategie, Targeting, JIPTL, MAOP/MAAP, ATO, ACO und SPINS;
- parallele 72–96-Stunden-Planung für normalerweise 24-stündige ATO-Ausführung;
- Dynamic Targeting und laufende Execution-Anpassung;
- Darstellung, dass die ATO nur ein Produkt innerhalb eines größeren Air-Operations-Zyklus ist.

Quellenkritische Hinweise:

- der Artikel verwendet teilweise vereinfachte oder nicht sauber bezeichnete Referenzen;
- TBMCS wird als primärer Verteilungsweg dargestellt, darf aber nicht ohne zeitgenössischen Nachweis als alleinige 2010/2011-Lösung angenommen werden;
- MAOP/MAAP-Terminologie variiert national und zeitlich.

### T04 – Graveyard of Empires, *Air Tasking Order – Message Format*, 11. November 2024

Einstufung:

```text
source_type: SECONDARY_DCS_INTERPRETATION
period_relation: POST_PERIOD_REFERENCE
```

Verwertbar für:

- Aufbau aus Heading, Address, Body, Ending;
- Sets, Felder, Deskriptoren und Trennzeichen;
- Beispiel-Set-Identifiers `AMSNDAT`, `MSNACFT`, `GTGTLOC`, `CONTROLA`, `AMPN`, `POC`;
- maschinen- und menschenlesbare strukturierte Missionsdaten.

Quellenkritische Hinweise:

- die Aussage, USMTF und ADatP-3 seien für ATO-Zwecke „exactly the same“, wird nicht als technische Wahrheit übernommen;
- beide Standards sind verwandt und interoperabel ausgerichtet, können aber Versionen, nationale Implementierungen und Feldregeln unterscheiden;
- kein vollständiger Parser wird aus den Blogbeispielen abgeleitet.

### T05 – Graveyard of Empires, *Air Tasking Order – How to Decipher it?*, 12. November 2024

Einstufung:

```text
source_type: SOURCE_POINTER
period_relation: POST_PERIOD_REFERENCE
```

Der Beitrag verweist im Wesentlichen auf T02. Er besitzt keinen eigenständigen fachlichen Vorrang.

### T06 – Graveyard of Empires, *Air Tasking Order – Example 1 – CAS Mission*, 13. November 2024

Einstufung:

```text
source_type: SYNTHETIC_EXAMPLE
historical_status: EXAMPLE_ONLY
```

Beispielinhalt:

- zwei A-10;
- CAS-Auftrag;
- Abflug/Rückkehr Kandahar;
- Arbeitsgebiet, Zeitfenster und Höhe;
- FAC, Callsign, Color-Net-Presets und Report-In Point;
- Direct Air Support Center als Control Task Unit.

Verwendung:

- Validierung des OMW-Datenmodells für on-station CAS;
- kein Beleg für Mission `AN0714`, Callsign `HOG07`, FAC `WIDOW`, Gebiet `84CJ` oder die beispielhaften Frequenzbezeichner als reale 2010/2011-Daten.

### T07 – Graveyard of Empires, *Air Tasking Order – Example 2 – Ground Alert CAS*, 14. November 2024

Einstufung:

```text
source_type: SYNTHETIC_EXAMPLE
historical_status: EXAMPLE_ONLY
```

Verwertbar für:

- Ground Alert als geplante, noch nicht gestartete Mission;
- Alert-Status als maximale Reaktionszeit;
- Verbindung zwischen Air Support Request Number und später zugewiesener Mission;
- `REQNO` als Track-and-Trace-Schlüssel;
- Unterscheidung Mission Window und Launch Alert.

Quellenkritische Grenze:

- Präfixkonventionen und Mission-Type-Codes müssen vor produktiver Nutzung gegen die maßgebliche Formatversion geprüft werden;
- die beispielhafte 15-Minuten-Reaktion ist kein genereller OMW-Standard.

### T08 – Graveyard of Empires, *Air Tasking Order – Example 3 – Air-to-Air Refueling*, 15. November 2024

Einstufung:

```text
source_type: SYNTHETIC_EXAMPLE
historical_status: EXAMPLE_ONLY
```

Verwertbar für:

- Tanker-Mission und Receiver-Verknüpfung;
- Tanker-Orbit, Zeitfenster und Höhe;
- Refueling System;
- geplante Offload-Menge;
- Receiver Mission Number, Callsign, Flugzeuganzahl und -typ;
- Air Refueling Control Time;
- Control Agency und Report-In Point.

Nicht historisch zu übernehmen:

- `TOTAL31`, `RAGE51`, `RUSH`, FL260, Missionsnummern, Offload-Mengen und Codes des Beispiels.

### T09 – Graveyard of Empires, *JTAR or ASR?*, 5. November 2024

Einstufung:

```text
source_type: SECONDARY_DCS_INTERPRETATION
period_relation: POST_PERIOD_REFERENCE
```

Verwertbar für:

- preplanned und immediate air-support requests;
- Einsteuerung vorgeplanter Bedarfe in den ATO-Zyklus;
- verkürzte Bearbeitung und Umleitung verfügbarer Assets bei Immediate Requests;
- Bedeutung vollständiger Target-, Timing-, Friendly- und Effektinformationen.

Quellenkritischer Vorbehalt:

Die Aussage, JTAR und ASR seien „basically the same“, ist für OMW zu grob. Beide erfüllen eine ähnliche Bedarfsmeldungsfunktion, sind aber in unterschiedliche nationale beziehungsweise NATO-Prozesse, Formulare und Terminologie eingebunden. OMW vereinheitlicht sie intern, ohne ihre reale Gleichheit zu behaupten.

### T10 – NATO ASR Template / Appendix C zu ATP-3.3.2.1

Einstufung:

```text
source_type: OFFICIAL_NATO_FORM_TEMPLATE
period_relation: POST_PERIOD_DOCTRINAL_REFERENCE
```

Verwendung:

- Datenfeldinventar für geplante und unmittelbare Air-Support-Bedarfe;
- keine ungeprüfte 1:1-Reproduktion als OMW-Benutzeroberfläche;
- keine Behauptung, dieses Formular sei im gesamten OMW-Zeitraum unverändert genutzt worden.

### T11 – Graveyard of Empires, *Tankers Callsigns List*, 16. November 2024

Einstufung:

```text
source_type: LEAD_COMPILATION
confidence: LOW_TO_MEDIUM_BY_ITEM
```

Der Beitrag kombiniert:

- historische Forendiskussionen;
- archivierte Callsign-Webseiten;
- peacetime callsign lists;
- einzelne Artikel und Erinnerungen;
- eigene Kreuzvergleiche.

Genannte mögliche ISAF-/OEF-Tanker-Callsign-Familien:

- Esso;
- Pitstop/Postman;
- Shell;
- Python;
- Texaco;
- Whistler;
- Total.

Verbindliche OMW-Regel:

- jeder Callsign-Eintrag bleibt `LEAD_ONLY`, bis er durch einen zeitgenössischen ATO-, Funk-, Bild-, Einheits- oder Missionsnachweis für den relevanten Zeitraum bestätigt ist;
- peacetime und operational callsigns werden nicht gleichgesetzt;
- OIF- und OEF-Daten werden nicht ohne Nachweis vermischt;
- frühe OEF-Daten von 2001–2003 werden nicht automatisch auf ISAF 2010/2011 übertragen.

### T12 – Graveyard of Empires, *Tankers Refueling Altitudes*, 17. November 2024

Einstufung:

```text
source_type: SOURCE_DERIVED_HYPOTHESIS
historical_confidence: LOW_TO_MEDIUM
```

Der Beitrag leitet mögliche AAR-Höhen ab aus:

- ziviler Airways-Struktur;
- Terrain und Maximum Elevation Figures;
- angenommener MANPADS-/AAA-Bedrohung;
- Arbeitsraum darunterliegender CAS-/ISR-Flüge;
- AAR-Rejoin- und Exit-Verfahren;
- aerodynamischer Leistungsfähigkeit schwer beladener Receiver.

Genannte Hypothese:

- häufige AAR-Nutzung zwischen ungefähr FL200 und FL290;
- im Süden eventuell niedrigere Bereiche oberhalb ungefähr FL160/170;
- vertikaler Schutz- und Verfahrensblock um die Tankerhöhe.

Verbindliche OMW-Regel:

- keine dieser Höhen wird als historisch bestätigt behandelt;
- exakte Mindestabstände werden gegen die einschlägige ATP-56-Ausgabe und die konkrete ACO/SPINS-Baseline geprüft;
- die pauschale Annahme, ältere MANPADS seien oberhalb 10.000 ft AGL praktisch ausgeschlossen, ist keine vollständige Threat-Assessment-Regel;
- Terrain, Receiver Performance, Wetter und zivile Luftstraßen müssen gemeinsam bewertet werden.

### T13 – Graveyard of Empires, *Tankers ROZ Locations*, 19. November 2024

Einstufung:

```text
source_type: SOURCE_DERIVED_HYPOTHESIS
reference_period: primarily 2001-2002
OMW_period_relation: BACKGROUND_ONLY
```

Der Beitrag leitet mögliche Tracks aus frühen OEF-Ausgangsbasen, Einsatzräumen, Terrain, Notlandeplätzen und CSAR-Reichweite ab.

Verwertbare Planungsprinzipien:

- AAR unterstützt Reichweite und Ausdauer;
- Tracks sollten Receiver-Wege, Arbeitsgebiete, zivile Luftstraßen, Terrain und Ausweichflugplätze berücksichtigen;
- CSAR-/Recovery-Abdeckung und Emergency Divert sind relevante Risikofaktoren;
- preplanned dormant ROZs können bei Bedarf aktiviert werden.

Nicht zu übernehmen:

- vorgeschlagene frühe OEF-Tracklagen als 2010/2011-Tatsache;
- pauschale 15-Minuten-Distanz zum Arbeitsgebiet;
- Annahme, Zentral- und Nordostafghanistan seien generell ungeeignet;
- frühe Basis- und Gefahrenlage nach dem Regimewechsel als unveränderte OMW-Lage.

### T14 – Graveyard of Empires, *Paveway II Delivery Profiles – Buddy-Lasing Phraseology*, 29. Juli 2025

Einstufung:

```text
source_type: SECONDARY_DCS_INTERPRETATION
period_relation: POST_PERIOD_REFERENCE
```

Der Beitrag verwendet moderne US-/NATO-Referenzen und beschreibt unter anderem:

- `TEN SECONDS`;
- `CAPTURED`;
- `LASER ON`;
- `LASING`;
- `CEASE LASER`;
- `SHIFT`;
- `STARE`;
- `SPOT`;
- `NEGATIVE LASER`;
- `DEAD EYE`;
- `ABORT`;
- continuous und delayed lasing;
- Laser Handover und LOAL-Beispiele.

Verwendung:

- optionales modernes DCS-Kommunikationsprofil;
- Zustands- und Fehlerlogik für Designator, Shooter, Code, Track und Abort;
- Multiplayer-Kneeboard und Training.

Quellenkritische Grenzen:

- Veröffentlichung 2025;
- nicht als exakte OEF-2010/2011-Phraseologie auszugeben;
- Behauptungen zu typischen OEF-LOAL-Verfahren, finalen Suchzeiten, Trefffehlern oder Counter-Laser-Szenarien benötigen Primärquellen;
- continuous lasing als „empfohlen“ ist eine Autoreneinschätzung für robuste DCS-Koordination, keine universelle historische Regel.

## 4. OMW-Produktmodell

OMW verwendet drei getrennte, aber verknüpfte Planungsprodukte:

```text
AIR_TASKING_PLAN
AIRSPACE_CONTROL_PLAN
SPECIAL_INSTRUCTIONS
```

Die Benennung vermeidet die Behauptung, ein echter klassifizierter beziehungsweise formatgetreuer ATO-/ACO-/SPINS-Datensatz werde reproduziert.

### 4.1 `AIR_TASKING_PLAN`

Enthält:

- Ausführungszeitraum;
- Version und Änderungsstand;
- geplante Missionspakete;
- Task Units und Start-/Recovery-Basen;
- Flugzeugtyp und -anzahl;
- Missionsrollen;
- Alert-Status;
- Mission Areas und Ziele;
- Zeitfenster, TOT, NET und NLT;
- Supportbeziehungen;
- Control Agencies;
- Tanker-, ISR-, Rescue- und Escort-Zuordnungen;
- Priorität und gewünschte Wirkung.

### 4.2 `AIRSPACE_CONTROL_PLAN`

Enthält:

- Airspace Control Means;
- zeitlich aktive und inaktive Zonen;
- vertikale Grenzen;
- Korridore, Tracks, Orbits und Holding Areas;
- Restricted, No-Fly, ROZ und Coordination Areas;
- Report-In Points und Airspace Control Points;
- zivile oder neutrale Konfliktbereiche;
- zuständige Control Agency;
- Geodetic Datum und Koordinatenquelle.

### 4.3 `SPECIAL_INSTRUCTIONS`

Enthält missionsweit oder tagesbezogen:

- allgemeine Kommunikationsregeln;
- Color-/TAD-Net-Zuordnung;
- Identification und Authentication;
- IFF-/Datalink-Regeln auf abstrakter Ebene;
- Tanker- und AAR-Verfahren;
- Divert-, Emergency- und Lost-Comms-Regeln;
- Personnel Recovery;
- Targeting-, ROE- und Civilian-Harm-Restriktionen;
- EMCON;
- Wetter- und Mindestbedingungen;
- besondere Weapons-Employment-Einschränkungen;
- BDA-/MISREP-Anforderungen.

Reale sensible Codes werden nicht in öffentlich dokumentierte Dauerwerte umgewandelt.

## 5. Interne Missionsdatenstruktur

## 5.1 Plan-Header

```yaml
airPlan:
  plan_id: string
  operation_id: string
  effective_from: datetime
  effective_to: datetime
  as_of: datetime
  version: integer
  change_serial: integer
  status: DRAFT | APPROVED | RELEASED | SUPERSEDED | CANCELLED
  source_ids: [string]
```

## 5.2 Task Unit

```yaml
taskUnit:
  task_unit_id: string
  display_name: string
  base_id: string
  command_relationship: string
  available_from: datetime
  available_to: datetime
  parent_airwing_id: string
  source_ids: [string]
```

## 5.3 Mission Record

```yaml
mission:
  mission_id: string
  request_id: string | null
  package_id: string | null
  task_unit_id: string
  mission_role_primary: string
  mission_role_secondary: string | null
  mission_commander: boolean
  alert_type: NONE | GROUND | AIRBORNE
  alert_minutes: integer | null
  departure_location_id: string
  recovery_location_id: string
  divert_location_ids: [string]
  planned_start: datetime
  planned_stop: datetime
  tot: datetime | null
  net: datetime | null
  nlt: datetime | null
  priority: string
  desired_effect: string
  status: PLANNED | ALERT | LAUNCHED | ON_STATION | EXECUTING | RTB | COMPLETE | ABORTED | LOST
```

## 5.4 Aircraft Element

```yaml
missionAircraft:
  aircraft_count: integer
  aircraft_type_id: string
  callsign: string
  configuration_id: string | null
  secondary_configuration_id: string | null
  datalink_profile_id: string | null
  iff_profile_id: string | null
  source_confidence: VERIFIED | PROJECT_ASSIGNED | LEAD_ONLY
```

`aircraft_count` ist eine Luftfahrzeugzahl. Bei der Übergabe an MOOSE muss sie gegen die Template-Gruppengröße und `SQUADRON:New(..., Ngroups, ...)` umgerechnet werden.

## 5.5 Mission Area

```yaml
missionArea:
  area_id: string
  geometry_type: POINT | CIRCLE | LINE | CORRIDOR | POLYGON | ORBIT | TRACK | GRID
  geometry_reference: string
  lower_altitude_ft: integer | null
  upper_altitude_ft: integer | null
  altitude_reference: MSL | AGL | FL
  active_from: datetime
  active_to: datetime
  control_agency_id: string | null
  priority: string | null
```

## 5.6 Target Record

```yaml
target:
  target_id: string
  target_name: string
  target_type: string
  dmppi_description: string | null
  coordinates: object
  geodetic_datum: string
  elevation_ft: integer | null
  desired_effect: DESTROY | NEUTRALIZE | SUPPRESS | DISRUPT | FIX | DELAY | OBSERVE | SHOW_OF_FORCE | OTHER
  target_status: NOMINATED | VALIDATED | APPROVED | RESTRICTED | ENGAGED | ASSESSED | CANCELLED
  nsl_conflict: boolean
  civilian_risk_state: string
```

Die Schreibweise `DMPI` wird im eigentlichen Datenmodell verwendet. Eine doppelte oder abweichende Schreibweise aus Beispielen wird nicht übernommen.

## 5.7 Control Agency

```yaml
controlAgency:
  agency_id: string
  agency_type: FAC | JTAC | FAC_A | DASC | CRC | AWACS | OTHER
  callsign: string
  primary_net_id: string | null
  secondary_net_id: string | null
  report_point_id: string | null
  task_unit_id: string | null
```

Frequenzwerte werden über Net-IDs aus Dokument 28 referenziert, nicht an mehreren Stellen dupliziert.

## 6. Air Support Request

OMW verwendet ein neutrales internes Objekt:

```text
AIR_SUPPORT_REQUEST
```

Es kann aus einem US-geprägten JTAR-, NATO-ASR- oder missionsinternen Bedarf entstehen.

## 6.1 Request-Typen

```text
PREPLANNED
IMMEDIATE
EMERGENCY
```

### Preplanned

- vor dem Ausführungstag eingereicht;
- vollständige Prüfung, Priorisierung und Deconfliction möglich;
- kann als Mission im Air Tasking Plan erscheinen;
- gewünschter Effekt, Timing und Ground Scheme of Maneuver werden synchronisiert.

### Immediate

- entsteht im laufenden Execution Cycle;
- kann vorhandene On-Call-/Alert-Missionen nutzen;
- kann Umleitung oder Re-Tasking erfordern;
- besitzt verkürzte Planungszeit, aber keine automatische Aufhebung von ROE, Target Validation oder Civilian-Harm-Prüfung.

### Emergency

- akute Gefahr für eigene Kräfte oder zeitkritische Rettungslage;
- höchste Bearbeitungspriorität;
- dokumentierte Abweichungen und Restrisiken;
- keine automatische Waffenfreigabe allein durch das Label `EMERGENCY`.

## 6.2 Request-Lifecycle

```text
DRAFT
SUBMITTED
VALIDATED
PRIORITIZED
APPROVED
TASKED
ON_CALL
DIVERTED
EXECUTING
COMPLETE
DENIED
CANCELLED
ABORTED
```

Übergänge:

```text
DRAFT -> SUBMITTED -> VALIDATED -> PRIORITIZED -> APPROVED -> TASKED
TASKED -> ON_CALL -> EXECUTING -> COMPLETE
ON_CALL -> DIVERTED -> EXECUTING
any active state -> CANCELLED | ABORTED
SUBMITTED | VALIDATED | PRIORITIZED -> DENIED
```

## 6.3 Pflichtdaten

```yaml
airSupportRequest:
  request_id: string
  request_type: PREPLANNED | IMMEDIATE | EMERGENCY
  requesting_unit_id: string
  supported_commander_id: string
  requested_effect: string
  target_or_area_id: string
  friendly_location_reference: string
  contact_point_id: string
  requested_from: datetime
  requested_to: datetime
  priority: string
  threat_summary: string
  target_description: string
  marking_method: string | null
  laser_code_profile_id: string | null
  restrictions: [string]
  civilian_considerations: [string]
  preferred_asset_type: string | null
  preferred_weapon_effect: string | null
  request_status: string
  assigned_mission_ids: [string]
  source_ids: [string]
```

Eine Anfrage benennt den Bedarf. Sie garantiert weder Asset, Waffentyp noch Freigabe.

## 7. Ground Alert und On-Call

## 7.1 Alert-Daten

```yaml
alertMission:
  alert_type: GROUND | AIRBORNE
  ready_time_minutes: integer
  alert_window_start: datetime
  alert_window_end: datetime
  current_readiness: READY | DEGRADED | NOT_READY | LAUNCHED
  supported_request_ids: [string]
```

## 7.2 Verbindliche Regeln

- Alert-Zeit beginnt erst mit bestätigter Tasking Notification.
- `15M` bedeutet im OMW-Modell eine projektseitig gewählte maximale Startbereitschaft, nicht automatisch einen historischen Standard.
- Start, Taxi, Takeoff und Transit sind getrennte Zeiten.
- Wetter, Parking, Crew, Fuel, Munition und Wartungszustand können die Bereitschaft herabsetzen.
- eine Mission kann mehrere Requests unterstützen, aber jeder Request bleibt separat nachvollziehbar.
- Ground Alert ist kein unsichtbarer unbegrenzter Reservebestand.

## 8. ATO-/USMTF-nahe Darstellung

## 8.1 Unterstützte Set-Familien

Für lesbare Exporte kann OMW folgende Set-Familien abbilden:

```text
OPER
MSGID
AKNLDG
TIMEFRAM
TASKUNIT
AMSNDAT
MSNACFT
AMSNLOC
GTGTLOC
CONTROLA
AMPN
POC
REQNO
REFTSK
```

Weitere Sets werden nur bei echtem Projektbedarf ergänzt.

## 8.2 Parser-Grenze

Es wird zunächst **kein vollständiger generischer USMTF-/ADatP-3-Parser** entwickelt.

Begründung:

- hohe Format- und Versionskomplexität;
- nationale Unterschiede;
- die Mission benötigt nur eine begrenzte Teilmenge;
- Fehler in Feldpositionen können sicherheits- und missionskritische Bedeutungen verändern;
- OMW besitzt keine Anforderung, reale operative Dateien einzulesen.

Vorrangig ist:

```text
internal structured data -> validated briefing/export
```

Nicht:

```text
arbitrary external military message -> automatic mission execution
```

## 8.3 Beispielschutz

Alle aus T06–T08 übernommenen Datensätze erhalten:

```yaml
example_only: true
historical_claim: false
```

Dadurch können automatisierte Tests mit realistisch wirkenden Daten durchgeführt werden, ohne sie als Geschichte auszugeben.

## 9. Airspace Control

## 9.1 Geometrien

Unterstützte Geometrietypen:

- Point;
- Circle;
- Line;
- Corridor;
- Polygon;
- Orbit;
- Track;
- Grid;
- Keyhole/Battle Position als missionsspezifische zusammengesetzte Geometrie.

## 9.2 Pflichtmerkmale

Jedes Airspace Control Measure besitzt:

```yaml
airspaceControlMeasure:
  acm_id: string
  name: string
  type: string
  geometry: object
  lower_limit: number
  upper_limit: number
  altitude_reference: MSL | AGL | FL
  active_from: datetime
  active_to: datetime
  controlling_authority_id: string
  activation_state: PLANNED | ACTIVE | SUSPENDED | EXPIRED
  usage: [string]
  conflict_ids: [string]
  source_ids: [string]
```

## 9.3 Deconfliction

Vor Aktivierung werden mindestens geprüft:

- vertikale Überlappung;
- horizontale Überlappung;
- zeitliche Überlappung;
- Konflikt mit ziviler Route;
- Konflikt mit Artillerie- oder Fires-Maßnahme;
- Konflikt mit NSL-/ROE-/Targeting-Beschränkung;
- Konflikt mit Tanker-, AWACS-, ISR-, Rescue- oder Transitbereich;
- DCS-Kartengrenzen und tatsächliche Terrainhöhe.

## 10. SPINS-Modell

## 10.1 Standing und Daily Instructions

OMW trennt:

```text
STANDING_SPINS
DAILY_SPINS
MISSION_CHANGE
```

### Standing

- allgemeine Net- und Kommunikationsstruktur;
- Standard-Lost-Comms;
- allgemeine Emergency-/Divert-Regeln;
- Grundprinzipien für Identification, ROE und Personnel Recovery;
- unveränderliche Theater-Konventionen.

### Daily

- Wetter und Mindestbedingungen;
- aktive Airspace Measures;
- Tages-Callsigns und Net-Presets;
- Tanker-, AWACS- und Rescue-Plan;
- besondere Threats;
- zeitlich begrenzte ROE-/Targeting-Hinweise;
- aktuelle Diverts und geschlossene Flugplätze.

### Mission Change

- dringende Änderung nach Veröffentlichung;
- eindeutige Versions- und Änderungsnummer;
- Bestätigung durch betroffene Einheiten;
- keine stille Überschreibung bereits gebriefter Daten.

## 10.2 Sicherheitsgrenze

OMW speichert keine realen oder als real dargestellten:

- Authentication Tables;
- Kryptoschlüssel;
- klassifizierten Mode-/Code-Tabellen;
- geheimen Frequenzen;
- echten Personal-Recovery-Daten aus laufenden Operationen.

Alle Werte sind fiktiv, historisch veröffentlicht oder projektintern generiert und entsprechend gekennzeichnet.

## 11. CAS-Execution-Modell

Aus T01 wird ein generischer Ablauf abgeleitet:

```text
REQUEST
TASKING
CHECK_IN
SITUATION_UPDATE
GAME_PLAN
CAS_BRIEF
READBACK
CORRELATION
ATTACK_CLEARANCE
ATTACK
ASSESSMENT
CHECK_OUT
```

Mögliche Abbruchzustände:

```text
ABORT_TARGET_ID
ABORT_FRIENDLY_RISK
ABORT_CIVILIAN_RISK
ABORT_LOST_COMMS
ABORT_WEATHER
ABORT_WEAPON_OR_SENSOR
ABORT_AIRSPACE_CONFLICT
ABORT_CONTROLLER
```

## 11.1 Type of Control

Type 1, Type 2 und Type 3 werden als Doktrinbegriffe dokumentiert, aber nicht automatisch aus Entfernung oder Sichtbedingungen allein gewählt. Auswahl und Simulation hängen ab von:

- Controller-Qualifikation;
- Sicht auf Ziel und angreifendes Luftfahrzeug;
- Zahl gleichzeitiger Angriffe;
- Zielidentifikation;
- Friendly- und Civilian-Risk;
- Kommunikations- und Sensorlage;
- missionsspezifischem Trainingsziel.

## 11.2 Desired Effect

CAS ist nicht gleichbedeutend mit `DESTROY`.

Zulässige Wirkungen:

- destroy;
- neutralize;
- suppress;
- disrupt;
- fix;
- delay;
- show of force;
- warning shot, falls die Missions- und ROE-Baseline dies ausdrücklich zulässt;
- observe/track.

## 12. Laser- und Buddy-Lasing-Modell

## 12.1 Zustände

```text
DESIGNATOR_SEARCHING
TARGET_CAPTURED
CODE_CONFIRMED
LASER_STANDBY
LASER_ON
LASING_STABLE
SPOT_ACQUIRED
NEGATIVE_LASER
TARGET_MASKED
DEAD_EYE
CEASE_LASER
SHIFT_TARGET
ABORT
IMPACT
```

## 12.2 Daten

```yaml
laserCoordination:
  designator_entity_id: string
  shooter_entity_id: string
  target_id: string
  laser_code_profile_id: string
  method: CONTINUOUS | DELAYED | HANDOVER
  requested_lase_time: datetime | null
  expected_time_of_flight_seconds: integer | null
  state: string
  abort_reason: string | null
```

## 12.3 Verbindliche Regeln

- Code und Ziel müssen vor Waffenfreigabe korreliert sein.
- `CAPTURED` ist kein Ersatz für die CAS-Clearance.
- `LASER ON` und `LASING` werden getrennt protokolliert.
- `NEGATIVE LASER`, `DEAD EYE` oder Verlust des Tracks sperren eine darauf angewiesene Waffenfreigabe.
- `ABORT` beendet die Angriffssequenz unabhängig vom bisherigen Fortschritt.
- Continuous Lasing kann als einfacheres Multiplayer-Standardprofil verwendet werden.
- Delayed Lasing wird nur mit geeigneter Waffe, Training und Timinglogik freigegeben.
- historische Phraseologie bleibt konfigurierbar und wird nicht aus dem 2025er Beitrag rückprojiziert.

## 13. Air-to-Air Refueling

## 13.1 Datenmodell

```yaml
airRefuelingTask:
  tanker_mission_id: string
  orbit_or_track_id: string
  tanker_altitude_ft_or_fl: string
  refueling_system: BOOM | DROGUE | BDA | OTHER
  fuel_type: string
  planned_total_offload_lb: number | null
  receiver_allocations:
    - receiver_mission_id: string
      receiver_callsign: string
      aircraft_count: integer
      aircraft_type_id: string
      planned_offload_lb: number | null
      arct: datetime | null
      sequence: integer | null
  control_agency_id: string | null
```

## 13.2 Historische Evidenzstufen

```text
VERIFIED_HISTORICAL
CORROBORATED
SOURCE_DERIVED
PROJECT_ASSIGNED
EXAMPLE_ONLY
```

Callsign, Track, Höhe und ARCT werden jeweils separat bewertet. Ein bestätigter Callsign beweist nicht automatisch einen bestimmten Track oder eine Höhe.

## 13.3 Track- und Höhenwahl

OMW verwendet folgende Prüfmatrix:

1. georeferenzierter historischer ACO-/Kartenbeleg;
2. zivile Airways und kontrollierter Luftraum;
3. Terrain und MFE;
4. Threat Envelope;
5. Receiver-Performance und Tanker-Performance;
6. Arbeitsräume von CAS/ISR/AWACS;
7. Rejoin-, Contact- und Exit-Verfahren;
8. Divert-Airfields;
9. CSAR-/Personnel-Recovery-Abdeckung;
10. DCS-KI- und Multiplayer-Funktionstest.

Abgeleitete Webhypothesen dürfen nur als Kandidaten in diese Matrix eingehen.

## 13.4 Verhältnis zu Dokumenten 29 und 30

Dokumente 29 und 30 bleiben autoritativ für die bereits erfassten ISAF-AAR-/ACO-Daten und Abbildungen. Dokument 54 ergänzt:

- Datenmodell;
- Evidenzstufen;
- Request-/Tasking-Verknüpfung;
- Quellenkritik der nichtamtlichen Tankerartikel.

Es überschreibt keine geographische AAR-Entscheidung aus einer höherwertigen Quelle.

## 14. DCS-/MOOSE-Umsetzung

## 14.1 MOOSE-First

Vor eigenem Lua-Code sind mindestens zu prüfen:

- `AIRWING`;
- `SQUADRON`;
- `AUFTRAG`;
- `COMMANDER`;
- `CHIEF`, soweit eine Rolle tatsächlich passt;
- `OPSZONE` und Airbase-/Zone-Funktionen;
- `WAREHOUSE`;
- Event- und FSM-Klassen;
- vorhandene AAR-, FAC(A)-, CAS-, ISR- und Auftragstypen.

Eigenentwicklung ist nur zulässig, wenn MOOSE die benötigte Request-, Daten-, Export- oder Synchronisationsfunktion nicht ausreichend bereitstellt.

## 14.2 Architektur

```text
CampaignState / MissionDemand
        |
        v
AirSupportRequest + AirPlan
        |
        v
Tasking Adapter
        |
        +--> MOOSE AUFTRAG / AIRWING / COMMANDER
        +--> Player Briefing / Kneeboard
        +--> F10 / Radio Menu
        +--> Optional ATO-like text export
        +--> Debrief / MISREP / BDA
```

## 14.3 Keine automatische Waffenfreigabe

Ein Tasking- oder ATO-Eintrag erzeugt:

- Missionsauftrag;
- verfügbare Ziel- und Koordinationsdaten;
- geplante Supportbeziehungen.

Er erzeugt nicht automatisch:

- positive Identifikation;
- gültige aktuelle Zielkoordinaten;
- ROE-Erfüllung;
- Kollateralschadensfreigabe;
- Terminal Attack Control;
- Waffenfreigabe.

## 15. Spielerprodukte

Aus dem internen Modell werden getrennte, lesbare Produkte erzeugt:

### Mission Card

- Mission ID;
- Callsign;
- Flugzeug und Anzahl;
- Start-/Recovery-Basis;
- Zeitfenster;
- Rolle;
- Arbeitsgebiet oder Ziel;
- Control Agency;
- primäres/sekundäres Net;
- Support Assets;
- Diverts;
- Restrictions.

### Kneeboard

- kompakte Check-in-/CAS-/AAR-Daten;
- Kartenreferenzen;
- Net-Presets;
- Laser-/Marking-Daten;
- Abort- und Emergency-Hinweise.

### ATO-like Export

- optionaler strukturierter Text;
- ausdrücklich als `OMW TRAINING / SIMULATION PRODUCT` gekennzeichnet;
- keine Behauptung eines originalen historischen Dokuments.

## 16. Acceptance-Anforderungen

## 16.1 Datenvalidierung

- eindeutige Mission IDs;
- eindeutige Request IDs;
- gültige Zeitfenster;
- bekannte Basen- und Orts-IDs;
- gültige Koordinaten und Datum;
- keine widersprüchlichen Altitude References;
- Request-zu-Mission-Nachverfolgbarkeit;
- keine doppelte Asset-Reservierung;
- Parent-/Detachment-Bestand korrekt;
- NSL-/Targeting-Prüfung durchgeführt.

## 16.2 Runtime

- Alertmission startet innerhalb definierter Simulationsgrenze;
- Abbruch lässt keine Folgewaffe automatisch auslösen;
- Dynamic Retask verändert Mission und Briefing nachvollziehbar;
- verlorene Assets werden im CampaignState gebucht;
- Spieler- und KI-Tasking konkurrieren korrekt um Bestand;
- Tanker-Receiver-Verknüpfung funktioniert;
- Frequenz-/Net-Referenzen stimmen mit Dokument 28 überein;
- Airspace-Zonen sind in DCS korrekt positioniert und vertikal abbildbar;
- Multiplayer-Synchronisation geprüft;
- verwendete DCS-, MOOSE-, Mission- und Bundle-Version dokumentiert.

## 16.3 Quellenvalidierung

Für jede historisch behauptete Mission:

- Quelle identifizieren;
- Datum und Zeitraum prüfen;
- historische oder synthetische Daten kennzeichnen;
- Callsign, Aircraft Type, Base, Track und Höhe separat bewerten;
- Widersprüche sichtbar halten;
- keine Bloghypothese als Primärquelle ausgeben.

## 17. Bekannte Quellenanomalien und offene Punkte

1. moderne NATO-Doktrin von 2019 ist nicht automatisch OEF-2010/2011-Doktrin;
2. nationale Reservations in ATP-3.3.2.1 verhindern eine pauschale Einheitsphraseologie;
3. USMTF und ADatP-3 sind nicht ungeprüft identisch;
4. ATO-Beispiele 1–3 sind synthetisch;
5. in Beispiel 1 tritt eine uneinheitliche ICAO-Schreibweise `AOKN/OAKN` auf; OMW verwendet den validierten DCS-/ICAO-Ortsdatensatz;
6. Tanker-Callsign-Liste basiert teilweise auf Foren, Archiven und Cross-Theater-Ableitungen;
7. Tanker-Höhen sind hergeleitet, nicht dokumentiert;
8. Tanker-ROZ-Lagen betreffen überwiegend frühe OEF-Phasen 2001–2002;
9. 2025er Buddy-Lasing-Artikel darf nicht als historische Phraseologie ausgegeben werden;
10. exakte ATP-56-Ausgabe und Verfahren für den OMW-Zeitraum sind noch zu prüfen;
11. ein vollständiger realer Afghanistan-ATO-/ACO-/SPINS-Satz 2010/2011 liegt weiterhin nicht vor;
12. das ASR-Template ist modern und muss gegen historische nationale Verfahren abgegrenzt werden.

## 18. Forschungsbedarf

1. zeitgenössische OEF-/ISAF-ATO-, ACO- oder SPINS-Auszüge für 2010/2011 finden;
2. tatsächliche ATO-/USMTF-/ADatP-3-Version im Theater bestimmen;
3. nationale JTAR-/ASR-Formulare und Request Chains der eingesetzten Verbände prüfen;
4. historische Ground-Alert- und On-Call-Bereitschaften pro Basis und Einheit belegen;
5. Tanker-Callsigns je Datum, Nation, Typ und Mission bestätigen;
6. AAR-Tracks und Höhen mit Dokumenten 29/30 sowie historischen ACO-Karten abgleichen;
7. ATP-56-Ausgabe und vertikale AAR-Verfahrensräume für 2010/2011 prüfen;
8. periodengerechte Laser-/CAS-Phraseologie gegen zeitgenössische JP-/ATP-/SPINS-Ausgaben prüfen;
9. MOOSE-Klassen und Methoden für Request, Alert, Retask, AAR und Mission Lifecycle vollständig prüfen;
10. erst danach einen produktiven OMW-Tasking-Adapter spezifizieren.

## 19. Verbindliche Projektentscheidung

OMW übernimmt aus den ausgewerteten Quellen:

- die Trennung von Air Tasking, Airspace Control und Special Instructions;
- einen versionierten täglichen Air-Plan;
- einen nachverfolgbaren Air-Support-Request-Lifecycle;
- Request-zu-Mission-Verknüpfung;
- Ground-/Airborne-Alert als endliche Ressource;
- strukturierte Mission-, Aircraft-, Area-, Target-, Control- und AAR-Daten;
- moderne CAS- und Laserabläufe als konfigurierbares Trainingsprofil;
- strikte Quellenkennzeichnung für historische, abgeleitete und synthetische Daten.

OMW übernimmt ausdrücklich nicht:

- Blogbeispiele als historische Wahrheit;
- unbestätigte Callsigns oder ROZs;
- moderne Doktrin als unveränderte 2010/2011-Praxis;
- reale sensible Codes;
- automatisierte Waffenfreigabe;
- einen unnötig vollständigen militärischen Nachrichtenparser.
