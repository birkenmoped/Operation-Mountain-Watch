---
document_id: OMW-C2-JTAR-ASR
status: BINDING
document_class: SOURCE_DERIVED_DESIGN_REFERENCE
source_status: SOURCE_CAPTURE_COMPLETE
owning_policy: OMW-GOV-001
authoritative_for:
  - OMW preplanned and immediate air-support request workflow
  - minimum ASR/JTAR request data and lifecycle
  - request-to-ATO traceability for CAS missions
not_authoritative_for:
  - certification of JTAC or FAC personnel
  - authentic national JTAR form reproduction
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/document-ato-asr-aar-buddy-lasing
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# 55 - JTAR/ASR: Anforderung von Close Air Support

## 1. Einordnung

`JTAR` steht in US-Unterlagen für **Joint Tactical Air Strike Request**, `ASR` in NATO-Unterlagen für **Air Support Request**. Die bereitgestellten Quellen behandeln beide Begriffe funktional als dasselbe Grundinstrument: Eine Bodeneinheit beschreibt ihren Unterstützungsbedarf in standardisierter Form, damit CAS geplant, priorisiert, zugewiesen, koordiniert und später ausgewertet werden kann.

Dieses Dokument verwendet im OMW-Datenmodell den neutralen Begriff `AirSupportRequest`. Die Anzeige darf abhängig vom dargestellten Verband `JTAR` oder `ASR` verwenden.

Ausgewertete Quellen:

- Graveyard of Empires, `JTAR or ASR?`, 05.11.2024;
- Graveyard of Empires, `ASR Template`, 07.11.2024;
- NATO ATP-3.3.2.1, Edition D Version 1, April 2019, besonders Abschnitt 3.15 und Annex C;
- Graveyard of Empires, `Air Tasking Order - Example 2 - Ground Alert CAS`.

**Credits für Recherche und Quellenzusammenstellung: Graveyard of Empires - <https://www.patreon.com/cw/graveyard4DCS>**

## 2. Zweck eines Air Support Request

Ein ASR/JTAR übermittelt nicht lediglich eine Zielkoordinate. Er verbindet:

- den Bedarf des unterstützten Ground Commanders;
- Zielart, Zielort und gewünschte Wirkung;
- gewünschte Zeit beziehungsweise Verfügbarkeitsfenster;
- Friendly Positions, Feuerunterstützung und Luftraumbeschränkungen;
- vorgesehene Kontrollstelle;
- Priorität beziehungsweise Precedence;
- spätere Missionszuweisung und Battle Damage Assessment.

Die Qualität der Anfrage beeinflusst direkt, ob geeignete Plattformen, Sensoren und Waffen bereitgestellt werden können.

## 3. Preplanned und Immediate

### 3.1 Preplanned Request

Ein Preplanned Request wird rechtzeitig vor Beginn des ATO-Produktionszyklus eingereicht. Er durchläuft die Führungskette, wird konsolidiert, priorisiert, genehmigt oder abgelehnt und kann anschließend in eine ATO-Missionszeile umgesetzt werden.

Wichtige Merkmale:

- Precedence wird durch den Requestor vergeben und auf höheren Ebenen neu priorisiert;
- möglichst genaue Angaben zu Ziel, Ort, TOT, gewünschtem Effekt und FSCMs erhöhen die Qualität der Zuweisung;
- fehlende Detaildaten verhindern die Anfrage nicht, sofern Zeitraum, wahrscheinlicher Zieltyp und erwarteter Einsatzraum angegeben werden;
- spätere Updates referenzieren weiterhin die ursprüngliche Request Number;
- digitale Übermittlung ist laut ATP-3.3.2.1 das bevorzugte Verfahren.

### 3.2 Immediate Request vor ATO-Ausführung

Eine Anfrage, die nach Beginn der ATO-Produktion, aber vor der Ausführung entsteht, folgt weiterhin weitgehend der normalen Genehmigungskette. Abhängig vom Veröffentlichungsstand wird sie über die zuständigen Liaison- und Air-C2-Elemente in die Planung oder Ausführung eingebracht.

### 3.3 Immediate Request während ATO-Ausführung

Diese Anfrage entsteht aus einer ungeplanten, häufig dringenden Gefechtssituation. Sie kann über Sprach- oder digitale Netze unmittelbar an die zuständigen Fire-Support- und Air-C2-Stellen geleitet werden.

Die ATP beschreibt dafür unter anderem:

- JARN als Verbindung zwischen AOCC und untergeordneten TACPs;
- AOCC als Net Control Station;
- Überwachung durch Zwischenebenen;
- stillschweigende Zustimmung der Zwischenebene, sofern sie nicht widerspricht;
- Genehmigung oder Ablehnung nach Commander Intent, Priorität und Verfügbarkeit organischer Mittel;
- aktuelle Situation Update zusammen mit der Anfrage;
- mögliche Nutzung von On-Alert-CAS oder Umleitung anderer Missionen.

Immediate bedeutet nicht unkontrolliert. Request, Autorität, Zielidentifikation, Deconfliction und Weapons Release bleiben getrennte Schritte.

## 4. Request-to-Mission-Verknüpfung

Die Request Number ist der persistente Schlüssel der Anfrage. Das ATO-Beispiel mit Ground Alert CAS verwendet:

```text
REQNO/8V031
```

und weist diesem Bedarf die Mission `AN1041` zu. Für OMW gilt:

```text
AirSupportRequest.requestId
-> AirTaskingMission.requestId
-> Spielerauftrag oder KI-AUFTRAG
-> Ergebnis und BDA
```

Eine Mission kann geändert oder ersetzt werden, ohne die ursprüngliche Request-ID zu verlieren.

## 5. NATO-ASR-Formular

Annex C der ATP-3.3.2.1 enthält ein dreiteiliges Formular. Die Originalvorlage ist bildbasiert und nicht als leicht bearbeitbares Projektdokument verfügbar. OMW erstellt deshalb eine eigene digitale Eingabemaske mit denselben funktionalen Informationsgruppen.

### 5.1 Section I - Mission Request

#### Administrative Daten

- Unit Called;
- eigene Einheit beziehungsweise `THIS IS`;
- Request Number;
- Datum;
- Sendezeit und Sender;
- Empfangszeit und Empfänger.

#### Request-Kategorie

- `PREPLANNED` mit Precedence und Priority;
- `IMMEDIATE` mit Priority.

#### Zielart und Zielanzahl

Das NATO-Formular bietet unter anderem Kategorien für:

- Personal im offenen Gelände;
- eingegrabene Kräfte;
- Waffen-/MG-/RR-/AT-Stellungen;
- Mörser und Artillerie;
- AAA;
- Flugabwehrsysteme beziehungsweise Raketen;
- Panzerung und Fahrzeuge;
- Gebäude, Brücken, Bunker und Pillboxes;
- Command Post beziehungsweise Communications Center;
- Flächenziele, Route, Nachschub und bewegte Ziele;
- freie Bemerkungen.

Die Kategorien sind eine Planungshilfe. Das OMW-Zielobjekt muss zusätzlich eine präzise Beschreibung und positive Identifikation besitzen.

#### Zielort

- Koordinaten;
- Target Elevation;
- Sheet Number, Series und Chart Number;
- Bestätigung beziehungsweise Prüfung durch eine zweite Stelle.

OMW speichert das verwendete Koordinatenformat und Datum explizit. Eine bloße Zahlenfolge ohne Formatkennung ist unzulässig.

#### Gewünschte Zeit

- `ASAP`;
- `NLT`;
- `AT`;
- `TO` beziehungsweise Endzeit.

#### Gewünschte Wirkung und Ordnance

- gewünschte Wirkung beziehungsweise Resultat;
- gewünschte Ordnance, soweit der Ground Commander sie vorgibt oder einschränkt;
- `DESTROY`;
- `NEUTRALIZE`;
- `HARASS/INTERDICT`.

Die Aircrew bleibt für Weaponeering-Empfehlungen und Plattformtaktik zuständig. Der Request beschreibt primär den benötigten Effekt und die Einschränkungen.

#### Final Control

- FAC/RABFAC beziehungsweise zuständige Kontrollart;
- Controller-Callsign;
- Frequenz;
- Control Point.

#### Remarks

Die Formularstruktur sieht unter anderem vor:

- IP;
- Heading und Offset;
- Distanz;
- Target Elevation;
- Target Description;
- Target Location;
- Mark Type und Laser Code;
- Friendly Positions;
- Egress;
- gegebenenfalls Beacon-Ziel, Beacon-Heading, Distanz, Grid und Elevation.

### 5.2 Section II - Coordination

Die Koordinationssektion umfasst:

- Naval Surface Fire Support;
- Artillery;
- ALO/G-2/G-3 beziehungsweise zuständige Stabskoordination;
- Approved oder Disapproved;
- Genehmigende Stelle;
- Reason for Disapproval;
- Restrictive Fire/Air Plan;
- Nummer und Aktivierungszeit;
- From-/To-Koordinaten;
- Breite;
- Maximum/Vertex und Minimum Altitude.

OMW darf eine Ablehnung nicht als technischen Fehler behandeln. Sie ist ein regulärer Request-Status mit dokumentiertem Grund.

### 5.3 Section III - Mission Data

Nach der Zuweisung werden ergänzt:

- Mission Number;
- Callsign;
- Anzahl und Typ der Luftfahrzeuge;
- Ordnance;
- Estimated/Actual Takeoff;
- Estimated TOT;
- Contact Point;
- Initial Contact;
- FAC/FAC(A)/TACA-Callsign und Frequenz;
- Airspace Coordination Area;
- Target Description;
- Target Coordinates und Elevation;
- BDA Report.

Der BDA-Block enthält eine kompakte Rückmeldung mit Callsign, Mission Number, Request Number, Ort, TOT, Resultat und Remarks.

## 6. Verbindlicher OMW-Request-Lifecycle

```text
DRAFT
-> SUBMITTED
-> VALIDATING
-> APPROVED | DENIED
-> PRIORITIZED
-> PLANNED
-> ASSIGNED
-> CHECKED_IN
-> IN_CONTROL
-> EXECUTED | ABORTED | EXPIRED
-> ASSESSED
-> CLOSED
```

Immediate Requests dürfen Schritte zeitlich verkürzen, aber nicht die Sicherheits- und Autoritätsprüfungen entfernen.

### 6.1 Mindestdaten für `SUBMITTED`

- Request-ID;
- anfordernde Einheit und Commander Intent;
- Preplanned oder Immediate;
- Priority/Precedence;
- Zielbeschreibung und Zielort beziehungsweise erwarteter Einsatzraum;
- Friendly Positions;
- gewünschte Wirkung;
- gewünschtes Zeitfenster;
- bekannte Einschränkungen;
- erreichbare Kontrollstelle.

### 6.2 Mindestdaten für `APPROVED`

- genehmigende Stelle;
- bestätigte oder angepasste Priorität;
- Deconfliction-Status;
- NSL-/ROE-Prüfung;
- zulässiger Effekt;
- dokumentierte Einschränkungen.

### 6.3 Mindestdaten für `ASSIGNED`

- Mission-ID;
- Plattform, Anzahl und Callsign;
- Waffen-/Sensorstatus;
- Start- und On-Station-Zeiten;
- Kontaktpunkt und Frequenzen;
- relevante ACO-/ACA-Daten.

## 7. Missionsdesign-Regeln

1. **Request und Attack Clearance sind nicht dasselbe.** Ein genehmigter Request berechtigt nicht automatisch zur Waffenfreigabe.
2. **Request-ID bleibt stabil.** Retasking, Aircraft Swap oder Mission Abort erzeugen keine neue Ursprungsanfrage.
3. **Preplanned CAS wird vorgebrieft.** Spieler erhalten den Request-Inhalt vor Start; KI-Missionen werden aus denselben Daten erzeugt.
4. **Immediate CAS erhält eine verkürzte, aber vollständige Situation Update.** Ziel, Friendlies, gewünschter Effekt und Einschränkungen bleiben Pflicht.
5. **Ground Alert ist eine Ressource, keine fertige Zielzuweisung.** Das Alert-Asset wird erst nach Approval und Assignment mit dem Request verbunden.
6. **Denied Requests bleiben sichtbar.** Ablehnungsgrund, Zeitpunkt und Autorität werden protokolliert.
7. **NSL, ROE und ziviles Umfeld blockieren oder begrenzen die Zuweisung.** Sie werden nicht erst im Cockpit geprüft.
8. **BDA schließt die Anfrage nicht automatisch.** Der gewünschte Effekt kann nicht erreicht sein und einen Reattack- oder Folge-Request auslösen.
9. **Spieler und KI greifen auf dasselbe Request-Objekt zu.** Parallele, widersprüchliche Aufgabenbeschreibungen sind unzulässig.
10. **Koordinaten werden validiert.** Datum, Format, Höhe und Plausibilität müssen vor Assignment geprüft sein.

## 8. Technische Zielstruktur

```yaml
AirSupportRequest:
  requestId:
  terminology: ASR | JTAR
  requestType: PREPLANNED | IMMEDIATE
  precedence:
  priority:
  requestingUnitId:
  commanderIntent:
  targetId:
  targetDescription:
  targetCategory:
  targetLocation:
  targetElevation:
  coordinateFormat:
  datum:
  friendlyLocations:
  desiredEffect:
  requestedOrdnance:
  requestedFrom:
  requestedUntil:
  finalControllerId:
  controllerFrequencies:
  markType:
  laserCode:
  restrictions:
  coordinationStatus:
  approvalStatus:
  approvalAuthority:
  denialReason:
  assignedMissionId:
  status:
  bda:
```

## 9. Zu erstellende Projektartefakte

- bearbeitbare OMW-ASR/JTAR-Markdownvorlage;
- maschinenlesbares JSON-/Lua-Schema;
- F10-/UI-Eingabefluss für Immediate Requests;
- Kneeboard- und Briefingdarstellung für Preplanned Requests;
- Request-Queue mit Priorisierung und Ablehnungsgründen;
- automatische Verknüpfung mit ATO-/Mission-ID;
- BDA- und Reattack-Workflow;
- Testfälle für Request-Änderung, Denial, Ablauf, Retasking und Multiplayer-Konflikte.

## 10. Querverweise

- [`OMW-C2-AIR-C2-CAS-AFGHANISTAN`](45-air-c2-cas-afghanistan.md)
- [`OMW-C2-ATO-ACO-SPINS`](54-air-tasking-order-aco-spins.md)
- [`OMW-TARGETING-AFGHANISTAN-NSL`](48-afghanistan-no-strike-list.md)
- [`OMW-ROE-NON-LETHAL-USE-OF-FORCE`](46-non-lethal-use-of-force.md)
