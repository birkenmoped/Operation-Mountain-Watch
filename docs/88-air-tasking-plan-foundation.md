---
document_id: OMW-AIR-TASKING-PLAN-FOUNDATION
status: BINDING_PROJECT_DECISION
document_class: ARCHITECTURE
owning_policy: OMW-GOV-001
authoritative_for:
  - OMW Air Tasking Plan architecture boundary
  - relationship between CampaignState, MissionDemand, Air Support Requests and MOOSE mission execution
  - separation of planning data from MOOSE AUFTRAG runtime execution
  - implementation sequencing for the Air Tasking Plan foundation
not_authoritative_for:
  - historical 2010-2011 ATO message syntax or doctrine
  - operational AAR geometry, callsigns or tanker acceptance
  - DCS or MOOSE runtime acceptance
  - automatic mission-generation behavior not yet implemented and tested
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: main
source_commit: 79f29e153661e8c782c639d8ebd1b744744ea443
validated_in_dcs: false
---

# 88 – Air Tasking Plan Foundation

## 1. Entscheidung und Zweck

Operation Mountain Watch führt eine eigene **Air-Tasking-Planungsebene** als operative Arbeitsschicht zwischen Kampagnenbedarf und MOOSE-Ausführung ein.

Ziel ist **nicht**, einen vollständigen realen USMTF-/ADatP-3-ATO-Generator nachzubauen. Ziel ist ein OMW-internes, strukturiertes Missionsplanungsmodell, das:

- Kampagnenereignisse und Air-Support-Bedarfe nachvollziehbar mit konkreten Luftmissionen verknüpft;
- strategische Verfügbarkeit und physische DCS-Ausführung sauber trennt;
- MOOSE `COMMANDER`, `AIRWING`, `SQUADRON`, `AUFTRAG` und `FLIGHTGROUP` als primäre Ausführungsmechanismen nutzt;
- aus denselben Missionsdaten später Player Mission Cards, Kneeboard-Inhalte, F10-Informationen und ATO-artige Übersichten erzeugen kann;
- Missionen, Support-Beziehungen und Ergebnisse über stabile IDs nachvollziehbar macht.

Die fachliche Quellen- und Datenmodellreferenz bleibt [`OMW-AIR-TASKING-AIRSPACE-CAS-REQUESTS`](54-air-tasking-airspace-control-cas-requests-and-mission-data.md).

## 2. MOOSE-First-Verträglichkeit

Die Air-Tasking-Planung ist **keine parallele Missionsausführungsengine**.

Verbindliche Schichtung:

```text
CampaignState
    ↓
MissionDemand / AIR_SUPPORT_REQUEST
    ↓
AIR_TASKING_PLAN
    ↓
OMW Tasking Adapter
    ↓
MOOSE COMMANDER / AIRWING / SQUADRON / AUFTRAG
    ↓
FLIGHTGROUP / DCS
```

Dabei gilt:

```text
CampaignState
= strategische Autorität: Bestand, Verfügbarkeit, Kampagnenzustand

AIR_SUPPORT_REQUEST
= dokumentierter Bedarf: wer benötigt welche Luftunterstützung und warum

AIR_TASKING_PLAN
= operative Zuordnung: welche konkrete Mission erfüllt welchen Bedarf

MOOSE AUFTRAG
= technische Missionsausführung innerhalb des MOOSE-Lifecycles
```

Ein Air-Tasking-Missionsdatensatz ist **nicht identisch** mit einem MOOSE-`AUFTRAG`. Der OMW-Tasking-Adapter übersetzt die für die Ausführung erforderlichen Teile eines geplanten Missionsdatensatzes in die passende MOOSE-Mission. Projektspezifische Planung, IDs, Historie, Briefingdaten und Request-Beziehungen bleiben außerhalb der MOOSE-Ausführungsobjekte.

Vor produktivem Adaptercode gelten vollständig [`OMW-GOV-MOOSE-FIRST`](26-moose-first-development-policy.md) sowie die Prüfung der tatsächlich gepinnten `Moose.lua` und der relevanten offiziellen MOOSE-Beispiele.

## 3. Warum OMW diese Ebene benötigt

Ohne eine Air-Tasking-Planung kann ein Runtime-System lediglich wissen:

```text
A-10 flight exists and is flying CAS
```

Mit Air-Tasking-Planung bleibt die Ursache und Zuordnung erhalten:

```text
Campaign event
    ↓
Air Support Request ASR-0042
    ↓
Mission CAS-017
    ↓
2 aircraft allocated from an eligible squadron
    ↓
Callsign / area / time window / controller / support assigned
    ↓
MOOSE AUFTRAG
    ↓
execution result
    ↓
request and campaign outcome
```

Damit beantwortet das System dauerhaft:

- Warum wurde diese Mission erzeugt?
- Welcher Bedarf wird erfüllt?
- Welche Luftfahrzeuge und Ressourcen wurden gebunden?
- Welche Support-Assets sind zugeordnet?
- Wer fliegt die Mission: Spieler oder KI?
- Welcher Status und welches Ergebnis gehören zu diesem Auftrag?

## 4. Kernobjekte

### 4.1 Air Support Request

Ein `AIR_SUPPORT_REQUEST` beschreibt einen Bedarf, nicht bereits die Ausführung.

Mindestens relevant:

```text
request_id
request_type
requesting_entity_id
priority
created_at
required_effect_or_task
area_or_target_reference
time_constraints
status
assigned_mission_ids
```

Die in den ausgewerteten ATO-Beispielen gezeigte `REQNO`-Beziehung dient ausschließlich als semantische Vorlage für die stabile Request-to-Mission-Verknüpfung. Beispielwerte werden nicht historisch übernommen.

### 4.2 Air Tasking Mission

Ein Missionsdatensatz beschreibt eine konkrete operative Zuordnung.

Kernfelder:

```text
mission_id
mission_type
request_ids
status
planned_start
planned_stop
alert_window
readiness_time
departure_node_id
recovery_node_id
assigned_squadron_id
aircraft_type
aircraft_count
callsign
mission_area_id
altitude_or_block
control_agency_id
report_in_point_id
support_mission_ids
player_or_ai_assignment
moose_mission_binding
result
```

Nicht jede Mission benötigt jedes Feld. Missionsspezifische Erweiterungen bleiben typisiert und dürfen den generischen Kern nicht mit unkontrollierten Freitextwerten ersetzen.

### 4.3 Air Tasking Plan

Der `AIR_TASKING_PLAN` ist eine Sammlung geplanter und laufender Air-Tasking-Missionen für einen definierten Planungszeitraum beziehungsweise Kampagnenkontext.

Er ist **keine Ressourcenautorität** und besitzt keine eigene Flugzeugmenge. Er referenziert ausschließlich die durch CampaignState autorisierten beziehungsweise reservierten Ressourcen.

## 5. Status- und Lifecycle-Grundsatz

Der konkrete produktive Statuskatalog wird im Foundation-Branch festgelegt. Die Architektur muss mindestens die Trennung folgender Zustände ermöglichen:

```text
REQUESTED
PLANNED
ALLOCATED
TASKED
EXECUTING
COMPLETED
CANCELLED
FAILED
```

Für Alert-Missionen müssen getrennt modelliert werden:

```text
alert window
!=
readiness / launch-response time
!=
taxi / takeoff time
!=
transit time
!=
on-station time
```

Eine beispielhafte `15M`-Ground-Alert-Angabe aus einer Sekundärquelle wird nicht als OMW-Standard übernommen.

## 6. Spielerperspektive

Der Spieler soll normalerweise **keinen Roh-ATO-Text** wie `AMSNDAT/...` lesen müssen.

Die strukturierten Missionsdaten bilden stattdessen eine gemeinsame Quelle für mehrere Spielerprodukte.

Beispiel eines späteren Player Mission Card Outputs:

```text
MISSION
HAWG 2 / CAS-017

TASK
Close Air Support – Paktika West

REQUEST
ASR-0042

DEPARTURE
Kandahar

ON STATION
1420Z–1545Z

CONTROL
AXEMAN

AAR SUPPORT
KRUSTY
```

Mögliche Ausgabekanäle:

- Missionsbriefing;
- Kneeboard;
- F10-Menü beziehungsweise F10-Tasking-Information;
- ATO-artige Tagesübersicht;
- Debrief-/Mission-History-Ausgabe.

Diese Ausgaben sind **Views auf denselben Missionsdatensatz** und dürfen keine eigene zweite Missionswahrheit erzeugen.

## 7. Ground Alert als späterer Anwendungsfall

Ground Alert ist ein besonders geeigneter Anwendungsfall, weil ein Spieler oder KI-Flight zunächst bereitsteht, bevor ein konkreter Auftrag zugewiesen wird.

Zielbild:

```text
Ground Alert mission
    ↓
real campaign demand occurs
    ↓
AIR_SUPPORT_REQUEST created
    ↓
request assigned to eligible alert mission
    ↓
launch authorized
    ↓
MOOSE mission execution
```

Die Umsetzung darf keine unbegrenzten Spawn-Ressourcen erzeugen. Alert-Missionen binden reale strategische Verfügbarkeit gemäß CampaignState und den jeweils geltenden Air-Ops-/Warehouse-Verträgen.

## 8. AAR als erster vorgesehener Integrationsnachweis

Die bestehende AAR-Architektur wird **nicht während ihrer laufenden Finalisierung umgebaut**.

Nach Abschluss und Integration der aktuellen AAR-Baseline soll AAR der erste bevorzugte vertikale Integrationsnachweis für den Air-Tasking-Plan werden, weil bereits vorhanden sind:

- MissionDemand-basierter Bedarf;
- CampaignState-Verfügbarkeitsregeln;
- strategischer AAR-Adapter;
- MOOSE-basierter physischer Lifecycle;
- definierte AAR-Areas, Profile und Support-Rollen.

Zielbild nach AAR-Abschluss:

```text
MissionDemand
    ↓
AIR_SUPPORT_REQUEST: AAR
    ↓
AIR_TASKING_PLAN mission
    ↓
receiver/support relationship
    ↓
existing OMW AAR adapter
    ↓
MOOSE execution
```

Die operative AAR-Geometrie, Callsigns, Gate-/Track-Logik und Acceptance bleiben weiterhin ausschließlich in der zuständigen AAR-Baseline autoritativ.

## 9. AAR Receiver Allocation

Das ATO-AAR-Beispiel zeigt eine strukturell nützliche Receiver-Zuordnung. Für OMW kann später eine AAR-Mission optionale Receiver-Beziehungen führen:

```text
receiver_mission_id
receiver_callsign
receiver_aircraft_count
receiver_aircraft_type
planned_offload
planned_arct
sequence
```

Diese Daten dienen zunächst Planung, Briefing, Telemetrie und Mission-to-Support-Verknüpfung. Sie erzwingen **nicht automatisch** starre ARCT-Runtime-Steuerung auf bereits kontinuierlich betriebenen STANDARD-Tracks.

MissionDemand-gesteuerte Reserve-/FLEX-AAR-Missionen sind ein geeigneter Kandidat, Receiver-Bedarf später als einen Auslöser für Materialisierung und Planung zu verwenden.

## 10. Persistenz und Speicherung

OMW soll Air-Tasking-Daten strukturiert speichern beziehungsweise im CampaignState-/Persistenzkontext referenzierbar halten, nicht ausschließlich als formatierten ATO-Text.

Grundsatz:

```text
structured mission data
    ├── runtime tasking
    ├── player briefing
    ├── kneeboard
    ├── F10 view
    ├── ATO-like view
    └── debrief/history
```

Welche Teile persistent und welche ausschließlich laufzeitbezogen sind, wird vor Runtime-Implementierung ausdrücklich festgelegt. CampaignState bleibt die strategische Autorität; der Air Tasking Plan darf keine zweite Ressourcenhoheit bilden.

## 11. Entwicklungszeitpunkt

Die Air-Tasking-Architektur wird **jetzt in der COMPLETE_FOUNDATION_BUILD_PHASE festgelegt**, die große Runtime jedoch erst nach ausreichender Air-Ops-Foundation implementiert.

Begründung:

- zu Projektbeginn fehlten noch stabile Air-Ops-, Ressourcen-, AIRWING-/SQUADRON- und CampaignState-Verträge;
- ein vollständiger ATO-Generator zu diesem Zeitpunkt wäre vorzeitig gewesen;
- eine Einführung erst am Projektende würde dagegen direkte `MissionDemand -> AUFTRAG`- oder `Trigger -> Spawn`-Abhängigkeiten nachträglich aufbrechen und unnötiges Refactoring erzeugen.

Daher gilt:

```text
architecture contract now
    ↓
foundation completion
    ↓
first vertical integration
    ↓
progressive runtime capabilities
```

## 12. Entwicklungsbranch

Für die Foundation wird der eigenständige Branch verwendet:

```text
agent/air-tasking-plan-foundation
```

Der Branch wird vom aktuellen `main` abgeleitet und bleibt von der laufenden AAR-Finalisierung getrennt. Die AAR-Integration erfolgt erst, wenn die maßgebliche AAR-Baseline auf `main` verfügbar und gegen den Foundation-Branch reconciled ist.

## 13. Explizit nicht Teil der ersten Foundation

Die erste Foundation implementiert noch nicht automatisch:

- vollständige dynamische ATO-Erzeugung;
- automatische CAS-Priorisierung;
- Ground-Alert-Runtime;
- automatische Player-Retasking-Logik;
- vollständige AAR-Receiver-Scheduling-Engine;
- echte USMTF-/ADatP-3-Nachrichtenerzeugung;
- Player-Kneeboard-Generator;
- F10-Tasking-UI;
- persistente Mission-History.

Diese Funktionen werden in aufeinanderfolgenden Phasen eingeführt und jeweils separat MOOSE-first geprüft und getestet.

## 14. Quellen- und Evidenzgrenze

Die Graveyard-of-Empires-Beispiele 1–3 aus Dokument 54 werden als `SYNTHETIC_EXAMPLE / EXAMPLE_ONLY` verwendet.

Sie können Struktur und Semantik illustrieren, insbesondere:

- CAS Mission + Control Agency;
- Ground Alert + Request Number;
- AAR Tanker + Receiver Allocation.

Nicht übernommen werden konkrete Beispielwerte wie Callsigns, Mission IDs, Frequenzbezeichner, IFF-Codes, Areas, Alert-Zeiten, Höhen, Offload-Mengen oder Präfixkonventionen als historische 2010/2011-Tatsachen.

## 15. Acceptance-Grenze

Dieses Dokument ist eine Architekturentscheidung, kein Runtime-Nachweis.

```text
validated_in_dcs: false
```

Jede spätere produktive MOOSE-Integration benötigt:

1. Prüfung der passenden MOOSE-Dokumentation;
2. Prüfung der tatsächlich verwendeten `Moose.lua`;
3. Prüfung relevanter offizieller MOOSE-Demos/Tests;
4. dokumentierte Signaturen, Events/FSMs und Voraussetzungen;
5. Syntax-/Testprüfung;
6. vollständigen Diff-Review;
7. reproduzierbaren DCS-Test für Runtime-Verhalten;
8. Acceptance-Provenienz entsprechend der Governance.
