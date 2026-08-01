---
document_id: OMW-SP-LLM-COMMANDERS-ORCHESTRATOR-TECH-SELECTION
status: DRAFT_ARCHITECTURE_DECISION
document_class: TECHNOLOGY_SELECTION_AND_DEPLOYMENT_MODEL
scenario_period: 2010-08-01/2011-12-31
source_branch: docs/optional-llm-commanders
validated_in_dcs: false
---

# Orchestrator-Technologieauswahl und Deploymentmodell

## 1. Zweck

Dieses Dokument definiert die Bewertungsmethode, Ausschlusskriterien, Zielarchitektur und Proof-of-Concept-Anforderungen für den externen Orchestrator des optionalen Multi-Commander-Projekts.

Die Technologieentscheidung betrifft ausschließlich die strategische und persistente Orchestrierung oberhalb der DCS-/MOOSE-Laufzeit.

```text
MOOSE remains the tactical runtime foundation.
The external orchestrator does not replace MOOSE.
```

Zu entscheiden ist daher nicht:

```text
Python or Elixir instead of MOOSE?
```

sondern:

```text
Which technology is best suited to operate a persistent,
validated and fault-tolerant campaign orchestrator above
a MOOSE-based DCS mission?
```

## 2. Verbindliche Architekturgrenze

```text
COMMANDER POLICY OR LLM
    proposes strategic intent

EXTERNAL ORCHESTRATOR
    owns campaign state, events, resources, beliefs,
    negotiations, validation and adjudication

DCS/MOOSE ADAPTER
    translates approved domain objects into fixed,
    reviewed MOOSE-compatible operations

MOOSE
    owns tactical mission generation, assignment,
    execution, detection, tasking and group management

DCS
    simulates the physical environment
```

Verbindlicher Datenfluss:

```text
COMMANDER_INTENT
-> VALIDATION
-> ADJUDICATION
-> OPERATION_PLAN
-> MOOSE_ADAPTER_COMMAND
-> MOOSE_EXECUTION
-> DCS_MOOSE_EVENT
-> RESULT_TRANSLATION
-> CAMPAIGN_STATE_EVENT
```

Nicht zulässig:

```text
LLM
-> generated Lua
-> direct DCS execution
```

Ebenfalls nicht zulässig:

```text
EXTERNAL_ORCHESTRATOR
-> reimplementation of MOOSE tactical functionality
```

## 3. MOOSE-First als Knock-out-Kriterium

MOOSE-Kompatibilität ist kein normal gewichteter Vorteil, sondern eine zwingende Zulassungsbedingung.

Ein Kandidat scheidet aus, wenn seine Architektur:

- MOOSE-Aufgaben, Missionen oder taktische C2-Funktionen außerhalb von MOOSE nachbildet;
- direkte DCS-Gruppenbefehle erzeugt, obwohl eine geeignete MOOSE-Klasse vorhanden ist;
- MOOSE-Zustände nicht eindeutig und idempotent zurückmelden kann;
- keine stabile Trennung zwischen strategischer Entität und physischer DCS-/MOOSE-Repräsentation ermöglicht;
- LLM-Ausgaben als Lua-, MOOSE- oder DCS-Code ausführt;
- die verbindliche MOOSE-First-Prüfung umgeht;
- keine MOOSE-Version und Adapterversion im Audit protokolliert.

Verbindliche Prüfreihenfolge für jede technische Funktion:

```text
1. Is the requirement already represented by a MOOSE class or function?
2. Can existing MOOSE functionality be configured to satisfy it?
3. Is only a thin domain-to-MOOSE adapter required?
4. Only when MOOSE is insufficient may a project-specific extension be proposed.
5. Every extension requires separate review and acceptance.
```

## 4. Nicht verhandelbare Projektanforderungen

### 4.1 Laufzeit

```yaml
runtime_requirements:
  dcs_server_os: WINDOWS
  mission_runtime_language: LUA
  tactical_framework: MOOSE
  external_orchestrator: SEPARATE_PROCESS
  direct_llm_access_to_dcs: PROHIBITED
  direct_llm_code_execution: PROHIBITED
  offline_testability: REQUIRED
  deterministic_replay: REQUIRED
  persistent_campaign_state: REQUIRED
  crash_recovery: REQUIRED
```

### 4.2 Daten und Persistenz

Der Kandidat muss folgende fachliche Objekte zuverlässig verwalten können:

```text
CAMPAIGN_STATE
EVENT_STORE
SNAPSHOTS
COMMANDER_VIEWS
BELIEFS
MEMORY
RESOURCE_POOLS
RESOURCE_RESERVATIONS
AGREEMENTS
MISSION_DEMANDS
TARGET_RECORDS
OPERATIONS
DCS_MOOSE_MAPPINGS
AUDIT_RECORDS
```

### 4.3 Testbarkeit

MUSS:

- vollständiger Betrieb ohne DCS;
- geskriptete Commander;
- reproduzierbare Seeds;
- Event-Replay;
- Golden-Master-Tests;
- Property-Based Tests;
- DCS-/MOOSE-Stub;
- Recovery-Tests;
- deterministische Hashes für State, View, Decision und Event Stream.

### 4.4 Betrieb

MUSS:

- Windows-kompatibel oder sauber getrennt auf Linux betreibbar sein;
- als Service gestartet und überwacht werden können;
- strukturierte Logs liefern;
- nach Prozessabsturz wieder anlaufen;
- Netzunterbrechungen tolerieren;
- doppelte und verspätete Nachrichten erkennen;
- Konfiguration und Secrets getrennt verwalten;
- Datenbankmigrationen reproduzierbar ausführen.

### 4.5 Sicherheit und Validierung

MUSS:

- JSON-Schema oder äquivalente strikte Schemas unterstützen;
- unbekannte Action Types ablehnen;
- fremde Ressourcen kontrollieren verhindern;
- State-Versionen prüfen;
- Authority-, Resource-, Knowledge- und Policy-Validatoren unterstützen;
- untrusted LLM text als Daten behandeln;
- keinerlei dynamische Codeausführung aus Commander-Ausgaben zulassen;
- jeden akzeptierten und abgelehnten Entscheid auditieren.

## 5. Bewertungsmethodik

### 5.1 Zweistufiges Verfahren

```text
STAGE 1: KNOCK_OUT_VALIDATION
STAGE 2: WEIGHTED_SCORING
```

Nur Kandidaten, die alle Knock-out-Kriterien erfüllen, werden bewertet.

### 5.2 Gewichtung

| Bewertungsbereich | Gewicht |
|---|---:|
| MOOSE-/DCS-Integration | 25 % |
| Zuverlässigkeit und Fehlertoleranz | 20 % |
| CampaignState und Event-Verarbeitung | 15 % |
| Testbarkeit und deterministischer Replay | 15 % |
| Entwicklungsaufwand und Wartbarkeit | 10 % |
| Deployment und Betrieb | 10 % |
| LLM-, Daten- und Analyseökosystem | 5 % |

Bewertungsskala:

```text
0 = unsuitable
1 = severe deficiencies
2 = significant limitations
3 = acceptable with manageable constraints
4 = strong fit
5 = excellent fit
```

Gewichtete Punktzahl:

```text
weighted_score = sum(score_0_to_5 * category_weight)
```

Maximalwert:

```text
5.00
```

## 6. MOOSE-/DCS-Integration

### 6.1 Fachliche Adaptergrenze

Der Orchestrator übermittelt keine frei formulierten MOOSE-Methodenaufrufe.

Er übermittelt versionierte Fachobjekte:

```yaml
adapter_command:
  command_id: CMD-000123
  schema_version: 1
  campaign_id: OMW-TEST-001
  operation_id: OPR-000042
  command_type: MATERIALIZE_OPERATION
  expected_state_version: 184
  issued_at: 2026-08-02T00:00:00Z
  payload:
    operation_type: ROUTE_SECURITY
    area_ref: SEC-KABUL-NORTH
    route_ref: RTE-MSR-EAST-E3
    assigned_force_refs:
      - UNT-BLUE-QRF-001
    desired_effects:
      - PROTECT
      - OBSERVE
    constraints:
      civilian_risk_limit: LOW
      recovery_required: true
    abort_conditions:
      - COMMUNICATION_LOSS
      - FRIENDLY_RISK_EXCEEDED
```

Der Lua-/MOOSE-Adapter verwendet ausschließlich bekannte, versionierte Mappingregeln.

### 6.2 Adapterantwort

```yaml
adapter_result:
  command_id: CMD-000123
  adapter_version: 1
  dcs_session_id: DCS-SESSION-004
  moose_version: 2.9.18
  accepted: true
  status: MATERIALIZED
  strategic_entity_refs:
    - UNT-BLUE-QRF-001
  physical_refs:
    - group_name: OMW_BLUE_QRF_001
  emitted_event_refs:
    - EVT-009812
```

### 6.3 Idempotenz

```text
same command_id
-> no duplicate physical execution
```

Der Adapter muss bei Wiederholung eines bereits akzeptierten Befehls den vorhandenen Status zurückgeben.

### 6.4 Sequenz und Quittierung

Jede Richtung benötigt:

```text
message_id
sequence_number
correlation_id
causation_id
schema_version
sent_at
received_at
acknowledgement_status
```

Unterstützte Zustände:

```text
QUEUED
SENT
ACKNOWLEDGED
APPLIED
REJECTED
EXPIRED
RETRY_PENDING
DEAD_LETTER
```

### 6.5 Keine MOOSE-Duplizierung

Der Orchestrator darf nicht selbst implementieren:

- AIRWING-Squadron- und Missionsteuerung;
- AUFTRAG-Ausführung;
- PLAYERTASK-Lifecycle;
- taktische Detection;
- FAC-/AFAC-/JTAC-Abläufe;
- DCS-Gruppenrouting;
- CTLD-/OPSTRANSPORT-Ausführung;
- Spawn-/Despawn-Management;
- taktische Reaktion einzelner Gruppen.

Der Orchestrator darf hingegen bestimmen:

- welcher strategische Effekt benötigt wird;
- welche Ressourcen reserviert werden;
- welches MOOSE-kompatible Operationsprofil verwendet werden soll;
- wann ein Auftrag genehmigt, abgebrochen oder neu bewertet wird;
- wie das Ergebnis strategisch interpretiert wird.

## 7. Logistik- und Cargo-Anforderungen

Die aktuelle Projektlogistik verlangt stabile Cargo-IDs, einmalige Gutschrift und klare Eigentums- sowie Verlustsemantik.

Der Orchestrator muss deshalb unterstützen:

```text
CARGO_CREATED
CARGO_RESERVED
CARGO_LOADING_STARTED
CARGO_IN_TRANSIT
CARGO_TRANSFERRED
CARGO_DELIVERED
CARGO_PARTIALLY_DELIVERED
CARGO_LOST
CARGO_DESTROYED
```

Verbindliche Invarianten:

```text
ONE_CARGO_ID
-> AT_MOST_ONE_FINAL_CREDIT
```

```text
TRANSFER
!= NEW_RESOURCE
```

```text
DUPLICATE_DELIVERY_EVENT
-> NO_SECOND_CREDIT
```

MOOSE beziehungsweise DCS führt die physische Transportdarstellung aus. Der Orchestrator führt Eigentum, Menge, Reservierung und strategische Gutschrift.

## 8. Route-, PATHLINE- und Markeranforderungen

Die Technologie muss folgende Ebenen getrennt halten:

```text
STRATEGIC_ROUTE
ROUTE_SEGMENT
ROUTING_ANCHOR
MOOSE_PATHLINE
DCS_GROUP_ROUTE
INFRASTRUCTURE_MARKER
THREAT_INDICATOR
COMMANDER_BELIEF
PLAYER_VISIBLE_INFORMATION
```

Verbindlich:

```text
MOOSE_PATHLINE
!= guaranteed DCS route
```

```text
WORLD_THREAT_INDICATOR
!= commander knowledge
```

Sensitive Marker dürfen nur über autorisierte Commander Views oder Spielerprodukte sichtbar werden.

## 9. Kandidat A – Python

### 9.1 Erwartete Stärken

- sehr schnelle Entwicklung des ersten Harness;
- starkes JSON-Schema- und Datenmodellökosystem;
- Pydantic oder vergleichbare strikte Modellierung;
- pytest und Hypothesis;
- sehr gute LLM-SDK-Verfügbarkeit;
- gute Datenanalyse und Simulation;
- einfache Implementierung von CLI-, HTTP- und Worker-Diensten;
- große Verfügbarkeit von Datenbank-, Message-Queue- und Observability-Bibliotheken;
- gute Windows-Unterstützung.

### 9.2 Erwartete Risiken

- Fehlertoleranz ist nicht automatisch Teil des Runtime-Modells;
- Prozessaufsicht muss bewusst implementiert oder über Service Manager beziehungsweise Container-Orchestrierung bereitgestellt werden;
- undisziplinierte Nutzung globaler Zustände kann Determinismus beschädigen;
- unkontrolliertes asyncio kann schwer diagnostizierbare Nebenläufigkeitsprobleme erzeugen;
- lange laufende Prozesse benötigen klare Worker-, Timeout- und Cancellation-Regeln;
- dynamische Typisierung erfordert strikte Runtime-Schemas und Type Checking.

### 9.3 Geeignetes Python-Zielbild

```text
PYTHON ORCHESTRATOR SERVICE
- FastAPI or minimal HTTP service
- Pydantic domain schemas
- explicit command handlers
- deterministic reducers
- PostgreSQL
- background worker queue only if justified
- pytest + Hypothesis
- structured logging
```

Zwingend:

```text
NO UNCONTROLLED PLUGIN EXECUTION
NO DYNAMIC IMPORT FROM LLM OUTPUT
NO GENERATED PYTHON EXECUTION
```

### 9.4 Vorläufige technische Kandidaten

Die konkrete Bibliotheksauswahl bleibt PoC-abhängig. Zu prüfen sind mindestens:

```text
Python 3.13 or supported project baseline
Pydantic
SQLAlchemy or explicit database layer
Alembic
PostgreSQL driver
pytest
Hypothesis
structlog or equivalent
FastAPI or minimal ASGI service
```

Keine Bibliothek wird allein aufgrund ihrer Popularität verbindlich.

## 10. Kandidat B – Elixir

### 10.1 Erwartete Stärken

- OTP Supervisor Trees;
- robuste langlaufende Prozesse;
- klare Isolation von Commander-, Operation- und Adapterprozessen;
- Message Passing;
- Restart-Strategien;
- hohe Eignung für nebenläufige, zustandsbehaftete Orchestrierung;
- gute Telemetrie;
- natürliche Modellierung von Timeouts und Prozessausfällen;
- gute Grundlage für verteilte Systeme.

### 10.2 Erwartete Risiken

- kleineres LLM- und Datenanalyseökosystem;
- höhere Einarbeitungskosten;
- zusätzliche Release- und Betriebsfragen unter Windows;
- weniger projektinterne Erfahrung wahrscheinlich;
- zwei Laufzeitwelten bleiben trotzdem bestehen: Elixir und Lua;
- historische Simulation, Datenanalyse und experimentelle Tests können mehr Zusatzarbeit erfordern;
- weniger Standardbeispiele für DCS-nahe Integrationen.

### 10.3 Geeignetes Elixir-Zielbild

```text
ELIXIR OTP APPLICATION
- supervision tree
- commander processes
- operation processes
- adapter connection process
- event store process boundary
- Ecto + PostgreSQL
- ExUnit + StreamData
- telemetry
```

### 10.4 Windows-Frage

Elixir darf nicht allein deshalb ausgeschlossen werden, weil DCS auf Windows läuft.

Zulässige Varianten:

```text
DCS + MOOSE + local adapter on Windows
Elixir orchestrator on Linux
```

oder:

```text
DCS + MOOSE + Elixir release on Windows
```

Die zweite Variante muss im PoC ausdrücklich auf Installation, Servicebetrieb, Update und Recovery geprüft werden.

## 11. Kandidat C – Hybrid Elixir plus Python

### 11.1 Zielbild

```text
ELIXIR
- runtime supervision
- event processing
- operation lifecycle
- adapter connectivity
- scheduling

PYTHON
- LLM gateway
- offline analysis
- evaluation
- embedding or retrieval services if later required
```

### 11.2 Vorteile

- OTP für Runtime und Fehlertoleranz;
- Python für LLM- und Datenökosystem;
- klare Trennung zwischen Campaign Runtime und AI Service möglich.

### 11.3 Nachteile

- zwei Deploymentketten;
- zusätzliche API-Grenze;
- verteiltes Debugging;
- doppelte Schemaimplementierung oder Codegenerierung erforderlich;
- zusätzliche Versionsmatrix;
- mehr Ausfallmodi;
- höherer Betriebsaufwand.

### 11.4 Zulassungsregel

Das Hybridmodell wird nur gewählt, wenn der PoC einen klaren, messbaren Vorteil gegenüber einem einzelnen Runtime-Stack zeigt.

```text
HYBRID_COMPLEXITY
must be justified by
MEASURABLE_OPERATIONAL_BENEFIT
```

## 12. Persistenzoptionen

### 12.1 SQLite

Geeignet für:

- ersten lokalen Harness;
- Einprozessbetrieb;
- schnelle Fixtures;
- reproduzierbare Tests;
- kleine Demonstratoren.

Nicht automatisch geeignet für:

- mehrere parallele Dienste;
- verteilte Runtime;
- hohe Schreibkonkurrenz;
- endgültige Multi-Server-Produktion.

### 12.2 PostgreSQL

Vorläufig bevorzugter Produktionskandidat für:

- Transaktionen;
- optimistic concurrency;
- Resource Locks;
- Event Store;
- Snapshots;
- JSON-Daten;
- Migrationswerkzeuge;
- robuste Backups;
- Remote-Betrieb.

### 12.3 Dateibasierter Event Store

Nur für:

- Fixtures;
- Export;
- Debug-Replay;
- Testartefakte.

Nicht als vorläufige Produktionsentscheidung.

## 13. Kommunikationsoptionen zum DCS-/MOOSE-Adapter

Zu vergleichen:

```text
LOCAL FILE QUEUE
TCP SOCKET
HTTP
WEBSOCKET
MESSAGE BROKER
```

### 13.1 Local File Queue

Vorteile:

- einfach;
- gut sichtbar;
- offline debugbar.

Nachteile:

- Locking und atomare Übergabe erforderlich;
- höhere Latenz;
- Fehler- und Retry-Logik schnell unübersichtlich;
- Netzwerkbetrieb unpraktisch.

### 13.2 TCP Socket

Vorteile:

- geringe Latenz;
- einfache bidirektionale Verbindung.

Nachteile:

- eigenes Protokoll und Framing;
- Reconnect, Sequencing und Authentication müssen implementiert werden.

### 13.3 HTTP

Vorteile:

- gut debuggbar;
- standardisierte Werkzeuge;
- klare Request-/Response-Semantik;
- einfache lokale und entfernte Nutzung.

Nachteile:

- Event Push benötigt Polling, Callback oder zusätzliche Verbindung;
- DCS-/Lua-Umgebung kann Einschränkungen besitzen.

### 13.4 WebSocket

Vorteile:

- bidirektional;
- geeignet für laufende Eventverbindung.

Nachteile:

- komplexere Reconnect- und Sequenzlogik;
- Lua-Unterstützung muss konkret geprüft werden.

### 13.5 Message Broker

Vorteile:

- Queues, Acknowledgements und Retry;
- gute Entkopplung.

Nachteile:

- zusätzlicher Dienst;
- höherer Betriebsaufwand;
- direkter Lua-Client möglicherweise ungeeignet.

### 13.6 Vorläufige PoC-Auswahl

Für den ersten PoC sollen zwei Adaptermodi geprüft werden:

```text
MODE A: local append-only file queue
MODE B: local HTTP bridge
```

Der MOOSE-Adapter darf dabei nicht direkt von einer schweren externen Bibliothek abhängig werden.

## 14. Deploymentvarianten

### 14.1 Variante A – Alles auf dem Windows-DCS-Server

```text
WINDOWS SERVER
- DCS dedicated server
- MOOSE mission
- local adapter
- orchestrator
- database
```

Vorteile:

- geringe Netzkomplexität;
- einfache lokale Verbindung.

Nachteile:

- konkurrierende CPU-, RAM- und I/O-Last;
- Orchestrator- oder Datenbankfehler auf demselben Host;
- Updates und Neustarts beeinflussen DCS;
- geringere Isolation.

### 14.2 Variante B – DCS auf Windows, Orchestrator auf Linux

```text
WINDOWS DCS HOST
- DCS
- MOOSE
- thin local adapter

LINUX ORCHESTRATOR HOST
- campaign runtime
- event store
- database
- commander policies
- optional LLM gateway
```

Vorteile:

- saubere Isolation;
- bessere Service- und Datenbankumgebung;
- weniger Last auf DCS;
- einfachere Containerisierung möglich.

Nachteile:

- Netzwerkabhängigkeit;
- Authentifizierung und Verschlüsselung erforderlich;
- Offline- und Reconnect-Verhalten muss sauber definiert sein.

### 14.3 Variante C – Lokaler Bridge-Service plus externer Orchestrator

```text
WINDOWS DCS HOST
- DCS
- MOOSE
- Lua adapter
- local bridge service

EXTERNAL HOST
- orchestrator
- database
- LLM gateway
```

Der lokale Bridge-Service kann:

- Dateisystemzugriff kapseln;
- lokale HTTP-/TCP-Verbindungen bereitstellen;
- Nachrichten puffern;
- Sequenzen und Acknowledgements führen;
- DCS-Neustarts erkennen.

Diese Variante ist langfristig besonders relevant, weil der Lua-Adapter klein bleiben kann.

## 15. Failure Isolation

### 15.1 Orchestrator-Ausfall

Bei Ausfall des Orchestrators:

```text
MOOSE continues already accepted tactical operations
NO new strategic operations are accepted
adapter buffers bounded result events
unsafe or expired requests are rejected
```

### 15.2 DCS-Ausfall

Bei DCS-Neustart:

```text
DCS mappings become UNCONFIRMED
CampaignState remains authoritative
confirmed losses remain losses
unconfirmed physical entities are reconciled
no resource is recreated automatically
```

### 15.3 Datenbankausfall

```text
NO state-changing command without durable event write
```

Read-only Diagnose darf möglich bleiben. Neue strategische Entscheidungen werden nicht autoritativ angewendet.

### 15.4 LLM-Ausfall

```text
LLM failure
-> scripted fallback or NO_ACTION
-> no CampaignState corruption
```

## 16. Observability

Mindestmetriken:

```text
commander_turn_duration
validation_failure_count
adjudication_duration
event_write_latency
snapshot_duration
adapter_round_trip_latency
adapter_retry_count
dead_letter_count
state_version_conflict_count
resource_lock_conflict_count
llm_timeout_count
fallback_decision_count
dcs_reconnect_count
```

Jeder Logeintrag benötigt mindestens:

```text
campaign_id
turn_id
commander_id
operation_id
command_id
correlation_id
state_version
component
severity
```

## 17. Proof of Concept

### 17.1 Ziel

Python und Elixir müssen denselben fachlichen Referenztest implementieren.

Der PoC darf nicht auf unterschiedlich vereinfachten Anforderungen beruhen.

### 17.2 Gemeinsames Szenario

```text
1 CampaignState
1 Event Store
4 Commander
1 strategic route
2 route segments
1 hidden threat indicator
2 competing resource requests
1 shared specialist resource
1 negotiation
1 resource lock conflict
1 operation lifecycle
1 cargo manifest
1 DCS/MOOSE adapter stub
1 process failure and recovery
```

### 17.3 Testablauf

1. CampaignState wird aus Fixture-Events aufgebaut.
2. BLUE fordert ISR für eine Route an.
3. Haqqani plant eine Ressourcenverlagerung über dieselbe Route.
4. Taliban besitzt ein anderes Lagebild zur Route.
5. HIG fordert lokale Transitfreiheit.
6. Zwei Operationen konkurrieren um dieselbe Ressource.
7. Eine Verhandlung erzeugt eine zeitlich begrenzte Vereinbarung.
8. Eine Operation wird genehmigt und reserviert Ressourcen.
9. Der Adapter materialisiert die Operation im Stub.
10. Ein Cargo-Objekt wird umgeschlagen, ohne dupliziert zu werden.
11. Der Adapter meldet einen Teilerfolg.
12. Der Orchestrator wird während einer aktiven Operation beendet.
13. State und Operation werden aus Event Store und Snapshot wiederhergestellt.
14. Eine doppelte Adaptermeldung wird idempotent verworfen.
15. Gleicher Seed erzeugt denselben finalen State.
16. Unterschiedlicher Seed darf nur ausdrücklich zufallsabhängige Felder ändern.

### 17.4 Verbindliche PoC-Tests

```text
POC-001 MOOSE boundary remains intact
POC-002 event replay reproduces state
POC-003 hidden route indicator is absent from unauthorized views
POC-004 resource double reservation is rejected
POC-005 foreign resource control is rejected
POC-006 duplicate adapter command does not duplicate execution
POC-007 duplicate cargo delivery does not duplicate credit
POC-008 stale state version is rejected
POC-009 orchestrator restart restores operation state
POC-010 DCS restart does not recreate confirmed losses
POC-011 same seed reproduces hashes
POC-012 invalid commander output produces safe fallback
POC-013 adapter disconnect applies bounded buffering
POC-014 MOOSE version is present in audit output
POC-015 no generated code is executed
```

## 18. Messwerte

Für beide PoCs werden dieselben Messwerte erfasst:

```text
implementation_hours
lines_of_domain_code
lines_of_infrastructure_code
number_of_external_dependencies
unit_test_count
property_test_count
integration_test_count
cold_start_time
idle_memory
peak_memory
single_turn_latency
1000_event_replay_time
snapshot_restore_time
recovery_time
adapter_reconnect_time
failed_message_recovery_rate
schema_validation_failure_quality
debugging_effort
deployment_steps
windows_service_complexity
linux_service_complexity
```

Zusätzlich qualitative Bewertung:

```text
code_readability
failure_diagnosability
schema_clarity
operational_simplicity
team_maintainability
```

## 19. Acceptance-Kriterien für den PoC

Ein Kandidat besteht nur, wenn:

```text
ALL KNOCK_OUT CRITERIA PASS
ALL POC-001 TO POC-015 PASS
NO RESOURCE DUPLICATION
NO TRUTH LEAKAGE
NO UNLOGGED STATE CHANGE
NO DIRECT LLM TO DCS PATH
NO MOOSE FUNCTIONALITY REIMPLEMENTATION
RECOVERY PRODUCES IDENTICAL AUTHORITATIVE STATE
```

Zusätzliche Mindestwerte werden nach dem ersten Referenzlauf festgelegt, damit keine willkürlichen Performancegrenzen ohne Messbasis entstehen.

## 20. Vorläufige Bewertungsmatrix

Diese Tabelle ist eine Hypothese vor dem PoC und keine endgültige Entscheidung.

| Bereich | Gewicht | Python | Elixir | Hybrid |
|---|---:|---:|---:|---:|
| MOOSE-/DCS-Integration | 25 % | 4 | 4 | 3 |
| Zuverlässigkeit/Fehlertoleranz | 20 % | 3 | 5 | 5 |
| CampaignState/Event-Verarbeitung | 15 % | 4 | 5 | 5 |
| Testbarkeit/Replay | 15 % | 5 | 5 | 4 |
| Entwicklungsaufwand/Wartbarkeit | 10 % | 5 | 3 | 2 |
| Deployment/Betrieb | 10 % | 4 | 3 | 2 |
| LLM-/Datenökosystem | 5 % | 5 | 3 | 5 |

Vorläufig gewichtete Erwartung:

```text
Python: strong initial fit
Elixir: strong runtime fit, higher entry cost
Hybrid: technically powerful, highest complexity
```

Die Zahlen dürfen nach dem PoC geändert werden. Jede Änderung benötigt eine dokumentierte Begründung.

## 21. Vorläufige Empfehlung

### 21.1 Phase 1

Für den ersten deterministischen Harness wird Python als Referenzkandidat priorisiert, weil:

- Dokument 14 bereits einen schnellen, vollständig testbaren Harness verlangt;
- Python eine geringe Einstiegshürde für Schemas, Tests und Datenanalyse besitzt;
- der erste Schritt keine verteilte Hochlast-Runtime benötigt;
- die fachlichen Verträge sprachneutral bleiben können.

Diese Priorisierung ist keine endgültige Produktionsentscheidung.

### 21.2 Phase 2

Ein Elixir-PoC wird mit denselben Schemas und Tests erstellt, sobald der Python-Referenzfall stabil ist.

Nicht zulässig wäre, den Elixir-PoC funktional zu reduzieren oder ihm andere Acceptance-Kriterien zu geben.

### 21.3 Entscheidungsregel

```text
Choose Python if:
- it passes all reliability and recovery tests,
- deployment remains simple,
- concurrency remains manageable,
- no material OTP advantage appears in the PoC.
```

```text
Choose Elixir if:
- supervisor and process isolation produce a measurable reliability advantage,
- Windows/Linux deployment is operationally acceptable,
- development and maintenance cost remain justified.
```

```text
Choose Hybrid only if:
- a single-stack candidate cannot meet both runtime and AI requirements,
- the benefit exceeds the added operational complexity.
```

## 22. Sprachneutrale Verträge

Unabhängig von der späteren Sprache müssen folgende Verträge separat versioniert werden:

```text
Event Envelope Schema
Commander View Schema
Commander Decision Schema
Operation Plan Schema
Resource Reservation Schema
Agreement Schema
Adapter Command Schema
Adapter Result Schema
Cargo Manifest Schema
DCS Mapping Schema
Audit Record Schema
```

Bevorzugtes Austauschformat für den PoC:

```text
JSON
+ JSON Schema
+ explicit schema_version
```

Eine spätere Umstellung auf MessagePack, Protobuf oder ein anderes Binärformat darf die fachlichen Verträge nicht verändern.

## 23. Offene Entscheidungen

Vor endgültiger Produktionsfreigabe sind noch zu entscheiden:

```text
ORCHESTRATOR_HOSTING_MODEL
DATABASE_HOSTING_MODEL
ADAPTER_PROTOCOL
WINDOWS_LOCAL_BRIDGE_REQUIRED
OFFLINE_OPERATION_DURATION
MAX_BUFFERED_ADAPTER_EVENTS
MAX_COMMANDER_TURN_FREQUENCY
MULTI_DCS_SERVER_SUPPORT
BACKUP_AND_RESTORE_POLICY
SECRET_MANAGEMENT
TLS_AND_AUTHENTICATION_MODEL
OBSERVABILITY_STACK
```

## 24. Verbindliche nächste Schritte

```text
1. Define language-neutral JSON schemas.
2. Implement the Python deterministic reference harness.
3. Implement the DCS/MOOSE adapter stub.
4. Execute POC-001 to POC-015.
5. Record measurements.
6. Implement the equivalent Elixir PoC.
7. Repeat the identical test set.
8. Complete weighted scoring.
9. Produce an Architecture Decision Record.
10. Only then select the production orchestrator stack.
```

## 25. Status

```text
MOOSE_FIRST_BOUNDARY = MANDATORY
PYTHON_REFERENCE_POC = RECOMMENDED
ELIXIR_COMPARISON_POC = REQUIRED_BEFORE_FINAL_DECISION
HYBRID_MODEL = CONDITIONAL
PRODUCTION_TECHNOLOGY_DECISION = NOT_YET_MADE
DCS_RUNTIME_ACCEPTANCE = NOT_YET_PERFORMED
```
