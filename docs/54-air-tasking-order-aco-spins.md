---
document_id: OMW-C2-ATO-ACO-SPINS
status: BINDING
document_class: SOURCE_DERIVED_DESIGN_REFERENCE
source_status: SOURCE_CAPTURE_COMPLETE
owning_policy: OMW-GOV-001
authoritative_for:
  - OMW representation of Air Tasking Order, Airspace Control Order and Special Instructions
  - minimum mission-data fields for air-tasking, briefing and campaign records
  - relationship between tasking, airspace and standing procedures
not_authoritative_for:
  - authentic operational ATO reproduction
  - classified or theatre-specific message procedures
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/document-ato-asr-aar-buddy-lasing
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# 54 - Air Tasking Order, Airspace Control Order und Special Instructions

## 1. Zweck und Quellenabgrenzung

Dieses Dokument überführt die bereitgestellten ATO-, ACO- und SPINS-Unterlagen in eine missionsdesignorientierte Referenz für **Operation Mountain Watch**. Es beschreibt, welche Informationen für Planung, Briefing, dynamische Neuvergabe und technische Datenhaltung benötigt werden. Es ist keine Vorlage zur Rekonstruktion eines echten, vollständigen Einsatz-ATO.

Ausgewertete Quellen:

| Quelle | Relevanter Inhalt |
|---|---|
| Graveyard of Empires, `Air Tasking Order - Introduction` | Planungszyklus, CAOC, MAOP, ATO/ACO-Beziehung, Dynamic Targeting |
| Graveyard of Empires, `Air Tasking Order - Message Format` | USMTF/ADatP-3, Sets, Felder und Trennzeichen |
| Graveyard of Empires, `Air Tasking Order - How to Decipher it?` | Verweis auf den Combined-Ops-Quick-Guide |
| `Combined Ops - ATO ACO SPINS Quick Guide`, 08.03.2024 | ATO-, ACO- und SPINS-Datensätze, Missions- und Loadoutfelder |
| Graveyard of Empires, ATO-Beispiele 1-3 | CAS, Ground Alert CAS und Air-to-Air Refuelling |
| NATO ATP-3.3.2.1, Edition D Version 1, April 2019 | Einordnung von ATO, ACO und SPINS in CAS und Air Interdiction |

**Credits für Recherche und Quellenzusammenstellung: Graveyard of Empires - <https://www.patreon.com/cw/graveyard4DCS>**

## 2. Operative Produktkette

### 2.1 Planungsrhythmus

Die ATO-Erstellung ist Teil eines mehrstufigen Air-Planning- und Targeting-Zyklus. Die Quellen beschreiben typischerweise:

```text
strategische und operative Weisung
-> Zielentwicklung und Priorisierung
-> Joint Integrated Prioritized Target List
-> Master Air Operations Plan
-> Air Tasking Order
-> Ausführung, Überwachung und Dynamic Targeting
```

Die Planungsarbeit kann 72 bis 96 Stunden vor der Ausführung beginnen. Die veröffentlichte ATO gilt normalerweise für ein 24-Stunden-Ausführungsfenster. Parallel befinden sich mehrere ATO-Tage in unterschiedlichen Bearbeitungsständen. Deshalb muss jeder Datensatz eindeutig einem Gültigkeitszeitraum und einer Version zugeordnet sein.

### 2.2 ATO

Die Air Tasking Order weist Kräfte, Fähigkeiten und Sorties konkreten Missionen zu. Für eine einzelne Mission enthält sie mindestens:

- eindeutige Missionsnummer;
- Tasking Unit und Basis;
- Flugzeugzahl und -typ;
- taktisches Callsign;
- Primär- und gegebenenfalls Sekundärmission;
- Start-, Recovery- und Einsatzzeitraum;
- Ziel, Arbeitsgebiet oder Orbit;
- Konfiguration beziehungsweise Standard Conventional Load;
- C2-Stelle, Kontrollpunkt und Kommunikationsdaten;
- Verknüpfungen zu Support-, Package-, Tanker- oder Request-Daten.

Die ATO ist kein unveränderliches Flugprogramm. Während der Ausführung können Assets aufgrund neuer Lageinformationen umgeleitet, neu gerollt oder einem höher priorisierten Bedarf zugewiesen werden. Jede solche Änderung benötigt eine nachvollziehbare Autorität und einen Audit-Trail.

### 2.3 ACO

Die Airspace Control Order setzt den Airspace Control Plan für einen bestimmten Zeitraum um. Sie definiert, wo, wann und in welchem Höhenband Luftraummaßnahmen gelten. Die ACO schafft die geometrische und zeitliche Grundlage, innerhalb derer die ATO-Missionen sicher ausgeführt werden.

### 2.4 SPINS

Special Instructions enthalten theatreweite oder tagesbezogene Verfahren, die nicht sinnvoll in jeder einzelnen Missionszeile wiederholt werden. Typische Inhalte sind:

- Luftraumnutzungs- und Deconfliction-Verfahren;
- Kommunikationsverfahren;
- Tankerverfahren;
- Rules of Engagement und Identifikationskriterien;
- Acceptable Level of Risk;
- EMCON-Regeln;
- Waffen- und Plattformhinweise;
- Base Defense Zone-Verfahren;
- Personnel-Recovery-Verfahren.

Der Quick Guide unterscheidet:

| Abschnitt | Funktion |
|---|---|
| Daily SPINS I | nur für den aktuellen ATO-/ACO-Zeitraum benötigte Informationen |
| Daily SPINS II | Änderungen, Ergänzungen oder Streichungen der Standing SPINS |
| Standing SPINS III | dauerhaft geltende Theaterverfahren |

## 3. USMTF-/ADatP-3-Grundstruktur

ATO und ACO können als strukturierte USMTF- beziehungsweise ADatP-3-Nachrichten dargestellt werden. Für OMW ist nicht die vollständige Nachrichtenkonformität entscheidend, sondern die eindeutige Datenstruktur.

### 3.1 Syntax

```text
SETIDENTIFIER/FELD1/FELD2/DESCRIPTOR:WERT/-//
```

| Zeichen | Bedeutung |
|---|---|
| `/` | trennt Felder |
| `:` | trennt Descriptor und Wert innerhalb eines Feldes |
| `-` | kein Wert beziehungsweise nicht anwendbar |
| `//` | Ende eines Sets |

Die Nachricht besteht aus Header, Adressierung, Body und Abschluss. Der Body enthält die einsatzrelevanten Sets.

### 3.2 Wichtige Header-Sets

| Set | Zweck |
|---|---|
| `OPER` / `EXER` | Operations- beziehungsweise Übungsname |
| `MSGID` | Nachrichtentyp, Herausgeber, Seriennummer, Monat und Änderungsstand |
| `AKNLDG` | Bestätigung erforderlich oder nicht |
| `TIMEFRAM` | Beginn, Ende und `ASOF`-Zeit der ATO |
| `ACOID` | ACO-Gebiet und Seriennummer |
| `GEODATUM` | verbindliches geodätisches Datum |
| `PERIOD` | ACO-Gültigkeitszeitraum |

## 4. Missionsbezogene ATO-Sets

### 4.1 Kerndaten

| Set | OMW-relevante Bedeutung |
|---|---|
| `TASKUNIT` | verantwortlicher Verband und Stationierungsort |
| `AMSNDAT` | Missionsnummer, Package, Mission Commander, Missionsart, Alertstatus, Abflug und Recovery |
| `MSNACFT` | Anzahl, Typ, Callsign, Konfiguration, Datalink und IFF/SIF |
| `AMSNLOC` | Start/Ende, Arbeitsgebiet, Höhe und Priorität bei Missionen ohne Einzelziel |
| `GTGTLOC` | Ziel, TOT/NET/NLT, Ziel-ID, DMPI, Koordinaten, Höhe, Effekt und Priorität |
| `CONTROLA` | kontrollierende Stelle, Callsign, Primär-/Sekundärfrequenz und Report-in Point |
| `FACINFOR` | FAC- oder FAC(A)-Callsign, Frequenzen und Kontaktpunkt |
| `PKGCMD` | Package Commander, Mission und Callsign |
| `ASUPTBY` / `ASUPTFOR` | unterstützende beziehungsweise unterstützte Mission |
| `REQNO` | Verknüpfung mit dem ursprünglichen Air Support Request |
| `AMPN` / `GENTEXT` | zusätzliche, nicht ausreichend codierbare Hinweise |

Jede OMW-Air-Mission benötigt mindestens das funktionale Äquivalent zu `AMSNDAT`, `MSNACFT` und genau einem Ziel- oder Einsatzraumdatensatz.

### 4.2 Standard Conventional Load

Der ATO-Loadoutcode beschreibt die empfohlene Konfiguration für den gewünschten Effekt. Der Combined-Ops-Guide zeigt fünfstellige SCL-Codes für Air-to-Air-, Air-to-Ground- und Bomberloads. Für OMW gilt:

- der historische Code darf als Referenz gespeichert werden;
- die tatsächliche DCS-Konfiguration wird zusätzlich als explizite Waffenliste geführt;
- ein Code ersetzt niemals die DCS-Prüfung von Pylon-, Tank-, Sensor- und Modultauglichkeit;
- gemischte Loads benötigen eine lesbare Erläuterung;
- `BEST` oder `BEST AVAILABLE` ist nur zulässig, wenn die konkrete Auswahl durch die Squadron-/Warehouse-Logik nachvollziehbar bleibt.

## 5. ATO-Beispiele und OMW-Lesart

### 5.1 Geplante CAS-Mission

Die Quelle beschreibt `AN0714` als zwei A-10 mit Callsign `HOG07`, die von Kandahar aus zwischen 1300Z und 1600Z im Gebiet `84CJ` auf FL150 CAS bereitstellen. Kontrollstelle ist `WIDOW` über `AMBER 10` beziehungsweise `RED 3`; der Control Task Unit ist das `232 DASC`.

OMW muss daraus getrennt speichern:

```yaml
mission_id: AN0714
mission_type: CAS
aircraft_count: 2
aircraft_type: A-10
callsign: HOG07
station_window: 1300Z/1600Z
working_area: 84CJ
planned_altitude: FL150
controller_callsign: WIDOW
controller_primary: AMBER10
controller_secondary: RED3
control_unit: 232_DASC
```

### 5.2 Ground Alert CAS

`AN1041` ist in der Quelle eine geplante, noch nicht gestartete `GCAS`-Mission mit zwei A-10 in Kandahar und 15 Minuten Alertstatus. Das Alertfenster reicht von 1400Z bis 1700Z. `REQNO/8V031` verbindet die Mission mit dem ursprünglichen Unterstützungsantrag.

Für OMW ist diese Trennung verbindlich:

```text
Mission ist geplant und bemannt
!=
Mission ist gestartet
!=
Mission ist einem konkreten CAS-Bedarf zugewiesen
```

Der Alertstatus ist eine Reaktionszeitvorgabe. Ein 15-Minuten-Alert bedeutet, dass das Asset nach Alarmierung innerhalb dieses Zeitfensters airborne sein soll. Ein `G`-Präfix bezeichnet in den Quellen Ground Alert; ein `X`-Präfix Airborne Alert.

### 5.3 Air-to-Air Refuelling

`1AT101` beschreibt einen französischen C-135FR `TOTAL31` von Manas im Orbit `RUSH`, 1330Z bis 1900Z auf FL260. `REFTSK` nennt BDA, 5.000 lb geplanten Offload; `5REFUEL` weist zwei Mirage 2000D `RAGE51` mit 4.800 lb und ARCT 1415Z zu. Die Kontrollstelle wird über `CONTROLA` angegeben.

Die vollständige AAR-Planungsreferenz steht in [`OMW-AAR-ISAF-ACO`](29-isaf-2009-2013-air-to-air-refueling.md).

## 6. AAR-spezifische ATO-Sets

| Set | Inhalt |
|---|---|
| `ARINFO` | Tanker, Mission, IFF, ARCP/Track, Höhe, ARCT, Ende, Offload, Frequenzen, Typ, Refuelling-System, TACAN |
| `REFTSK` | Tankersystem, Gesamt- und Contingency-Offload, Frequenzen und TACAN |
| `5REFUEL` | Receiver-Missionen mit Callsign, Anzahl, Typ, Offload, ARCT, Fuel Type und System |

Die Codes für Boom- und Drogue-Konfigurationen sowie die OMW-Anwendung sind in Dokument 29 definiert.

## 7. ACO-Datenmodell

### 7.1 Identität und Gültigkeit

Jede Airspace Control Measure benötigt:

- eindeutigen Namen oder Designator;
- Typ und Nutzungszweck;
- Geometrie;
- Höhenunter- und -obergrenze;
- Aktivierungszeitraum;
- controlling authority;
- Primär- und Sekundärfrequenz, soweit relevant;
- Quelle und Validierungsstatus.

### 7.2 Unterstützte Grundformen

Der Quick Guide nennt unter anderem:

- `POLYGON`;
- `CIRCLE`;
- `CORRIDOR`;
- `TRACK`;
- `ORBIT`;
- `POINT`;
- `LINE`;
- `POLYARC`;
- `RADARC`.

Für OMW werden diese Formen in Mission-Editor-Zonen, Wegpunkten, Zeichnungsobjekten oder maschinenlesbaren Geometrien abgebildet. Ein visueller Kartenname allein reicht nicht aus.

### 7.3 Vertikale und zeitliche Dimension

`EFFLEVEL` definiert den wirksamen Höhenbereich, beispielsweise AGL-Bänder oder Flight Levels. `APERIOD` definiert Aktivierung und Wiederholungsmuster. Eine Zone ohne Höhen- und Zeitangabe darf nicht als vollständige ACO-Maßnahme gelten.

## 8. Verbindliche OMW-Datenstruktur

Für die erste produktive OMW-Ausbaustufe ist keine vollständige USMTF-Ausgabe erforderlich. Die internen Daten müssen jedoch mindestens folgende Felder abbilden:

```yaml
AirTaskingMission:
  missionId:
  requestId:
  atoPeriod:
  taskUnit:
  departureLocation:
  recoveryLocation:
  missionTypePrimary:
  missionTypeSecondary:
  alertStatus:
  aircraftType:
  aircraftCount:
  callsign:
  loadoutCode:
  explicitLoadout:
  startTime:
  endTime:
  targetOrAreaId:
  altitudeBlock:
  controllerId:
  controllerFrequencies:
  supportingMissions:
  supportedMission:
  status:
  source:

AirspaceControlMeasure:
  acmId:
  name:
  type:
  geometry:
  lowerLimit:
  upperLimit:
  activeFrom:
  activeUntil:
  controllingAuthority:
  frequencies:
  source:
```

## 9. Missionsdesign- und Implementierungsregeln

1. **ATO, ACO und SPINS bleiben getrennte Produkte.** Eine Mission darf nicht gleichzeitig als Airspace-Geometrie oder Standing Procedure missbraucht werden.
2. **Jede Mission erhält eine stabile ID.** Callsigns, Gruppennamen oder DCS-Unit-Namen ersetzen die Missions-ID nicht.
3. **Preplanned, Alert, Airborne und Assigned sind getrennte Zustände.** Ein Ground-Alert-Asset ist nicht automatisch einem Ziel zugewiesen.
4. **Request- und Mission-ID werden verknüpft.** Die Herkunft eines CAS-Auftrags muss bis zum ASR/JTAR zurückverfolgbar sein.
5. **Zeitfenster werden in Zulu gespeichert.** Lokale Anzeige ist zusätzlich möglich, aber nicht die Primärreferenz.
6. **Loadoutcodes werden nicht blind in DCS übersetzt.** DCS-Modul, Zeitraum, Warehouse-Bestand und gewünschter Effekt entscheiden über die konkrete Konfiguration.
7. **Dynamic Retasking verändert nicht rückwirkend die ursprüngliche Planung.** Ursprungsauftrag, Änderung, Autorität und Zeitpunkt werden protokolliert.
8. **ACO-Konflikte blockieren oder ändern die Mission.** Route, Orbit, Höhe und Zeit müssen vor Freigabe gegen aktive ACMs geprüft werden.
9. **SPINS sind versioniert.** Standing Rules und Tagesänderungen werden getrennt geführt.
10. **Spieler- und KI-Briefings verwenden dieselben Kerndaten.** Kneeboard, F10-Auftrag und KI-`AUFTRAG` dürfen keine widersprüchlichen Missionsparameter enthalten.

## 10. Technische Zielartefakte

- ATO-/Mission-Register für CampaignState;
- ACO-/ACM-Register mit Geometrien, Höhen und Aktivierungsfenstern;
- SPINS-Baseline plus Daily-Deltas;
- standardisierte Spielerbriefings und Kneeboards;
- maschinenlesbare Request-to-Mission-Verknüpfung;
- Mission-Editor-/MOOSE-Abbildung für Alert, On-Station, Retasking und Recovery;
- Validierungswerkzeug für Zeit-, Höhen-, Frequenz- und Luftraumkonflikte.

## 11. Offene Validierung

- endgültiges OMW-Datenformat und Persistenzschema;
- Mapping der Missionsarten auf MOOSE `AUFTRAG`, `AIRWING`, `SQUADRON`, `COMMANDER` und `PLAYERTASK`;
- DCS-seitiges Alert- und Retasking-Verhalten;
- ACO-Geometrieprüfung gegen die Afghanistan-Karte;
- Multiplayer-Synchronisation von Mission Changes;
- automatische Kneeboard-/Briefing-Erzeugung;
- Abgleich mit den tatsächlich verwendeten TAD-/Color-Net- und Callsign-Dokumenten.
