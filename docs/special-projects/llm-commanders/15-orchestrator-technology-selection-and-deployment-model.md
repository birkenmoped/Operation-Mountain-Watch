---
document_id: OMW-SP-LLM-COMMANDERS-ORCHESTRATOR-TECH-SELECTION
status: DRAFT_ARCHITECTURE_DECISION
document_class: TECHNOLOGY_SELECTION_AND_DEPLOYMENT_MODEL
scenario_period: 2010-08-01/2011-12-31
source_branch: docs/optional-llm-commanders
validated_in_dcs: false
authoritative_for:
  - orchestrator technology evaluation method
  - MOOSE-first knockout criteria
  - deployment alternatives
  - five-faction reference proof of concept
  - technology decision acceptance criteria
---

# Orchestrator-Technologieauswahl und Deploymentmodell

## 1. Zweck

Dieses Dokument definiert Bewertungsmethode, Ausschlusskriterien, Zielarchitektur und Proof-of-Concept-Anforderungen für den externen Orchestrator des optionalen Multi-Commander-Projekts.

Die Technologieentscheidung betrifft ausschließlich die strategische und persistente Orchestrierung oberhalb der DCS-/MOOSE-Laufzeit.

```text
MOOSE remains the tactical runtime foundation.
The external orchestrator does not replace MOOSE.
```

Zu entscheiden ist nicht:

```text
Python or Elixir instead of MOOSE?
```

sondern:

```text
Which technology is best suited to operate a persistent,
validated and fault-tolerant campaign orchestrator above
a MOOSE-based DCS mission?
```

## 2. Verbindliche Facharchitektur

Kanonische Commander:

```text
BLUE_ISAF_COMMANDER
AFGHAN_STATE_COMMANDER
TALIBAN_COMMANDER
HAQQANI_COMMANDER
HIG_COMMANDER
```

Verbindliche Laufzeitgrenze:

```text
COMMANDER POLICY OR LLM
    proposes strategic intent

EXTERNAL ORCHESTRATOR
    owns CampaignState, Event Store, ResourceSources,
    ResourceAccounts, Force Generation, Beliefs,
    Agreements, Validation and Adjudication

DCS/MOOSE ADAPTER
    translates approved domain objects into fixed,
    reviewed MOOSE-compatible operations

MOOSE
    owns tactical mission generation, assignment,
    execution, detection, tasking and group management

DCS
    simulates the physical environment
```

Datenfluss:

```text
COMMANDER_INTENT
-> VALIDATION
-> RESOURCE_OR_FORCE_GENERATION_TRANSACTION
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
LLM -> generated Lua -> direct DCS execution
```

```text
EXTERNAL_ORCHESTRATOR
-> reimplementation of MOOSE tactical functionality
```

## 3. MOOSE-First als Knock-out-Kriterium

MOOSE-Kompatibilität ist keine gewichtete Zusatzqualität, sondern Zulassungsbedingung.

Ein Kandidat scheidet aus, wenn seine Architektur:

- MOOSE-Aufgaben, Missionen oder taktische C2-Funktionen außerhalb von MOOSE nachbildet;
- direkte DCS-Gruppenbefehle erzeugt, obwohl eine geeignete MOOSE-Klasse vorhanden ist;
- MOOSE-Zustände nicht eindeutig und idempotent zurückmelden kann;
- strategische Entitäten und physische DCS-/MOOSE-Repräsentationen nicht trennt;
- Commander-Ausgaben als Lua-, Python-, Elixir- oder anderen Code ausführt;
- die Prüfung der eingebundenen MOOSE-Version 2.9.18 umgeht;
- keine MOOSE- und Adapterversion im Audit protokolliert.

Verbindliche Prüfreihenfolge:

```text
1. Is the requirement represented by a MOOSE class or function?
2. Can existing MOOSE functionality be configured to satisfy it?
3. Is only a thin domain-to-MOOSE adapter required?
4. Only when MOOSE is insufficient may an extension be proposed.
5. Every extension requires separate review and acceptance.
```

## 4. Nicht verhandelbare Projektanforderungen

### 4.1 Laufzeit

```yaml
runtime_requirements:
  dcs_server_os: WINDOWS
  mission_runtime_language: LUA
  tactical_framework: MOOSE_2_9_18
  external_orchestrator: SEPARATE_PROCESS
  direct_commander_access_to_dcs: PROHIBITED
  direct_generated_code_execution: PROHIBITED
  offline_testability: REQUIRED
  deterministic_replay: REQUIRED
  persistent_campaign_state: REQUIRED
  crash_recovery: REQUIRED
  five_faction_concurrency: REQUIRED
```

### 4.2 Fachliche Pflichtobjekte

Der Kandidat muss mindestens verwalten:

```text
CAMPAIGN_STATE
EVENT_STORE
SNAPSHOTS
COMMANDER_VIEWS
BELIEFS
MEMORY
RELATIONSHIPS
AGREEMENTS
RESOURCE_SOURCES
RESOURCE_ACCOUNTS
RESOURCE_RESERVATIONS
RESOURCE_TRANSFERS
RESOURCE_FLOWS
ACCESS_NODES
FACTION_SHARES
FORCE_GENERATION_ORDERS
FORCE_PACKAGES
CAPABILITY_ASSETS
MISSION_DEMANDS
TARGET_RECORDS
OPERATIONS
DCS_MOOSE_MAPPINGS
AUDIT_RECORDS
```

### 4.3 Fachliche Invarianten

```text
NO_RESOURCE_WITHOUT_SOURCE
NO_NEGATIVE_RESOURCE_ACCOUNT
NO_DOUBLE_RESOURCE_RESERVATION
NO_DUPLICATE_RESOURCE_CREDIT
NO_FORCE_PACKAGE_WITHOUT_RESOURCE_COMMITMENT
ONE_FORCE_GENERATION_ORDER_AT_MOST_ONE_FORCE_PACKAGE
NO_ISAF_RECRUITMENT_FROM_AFGHAN_MANPOWER
NO_AFGHAN_FORCE_OWNED_BY_ISAF
NO_REPUTATION_TO_DIRECT_UNIT_CONVERSION
NO_PHYSICAL_EXECUTION_BEFORE_APPROVAL
ONE_ADAPTER_COMMAND_AT_MOST_ONE_MATERIALIZATION
```

### 4.4 Testbarkeit

MUSS:

- vollständiger Kernbetrieb ohne DCS;
- fünf geskriptete Commander;
- reproduzierbare Seeds und Simulationsuhr;
- Event-Replay;
- Golden-Master-Tests;
- Property-Based Tests;
- ResourceSource- und Share-Tests;
- Force-Generation-Queue-Tests;
- DCS-/MOOSE-Stub;
- Recovery-Tests;
- deterministische Hashes für State, Resources, Force Generation, Views, Decisions und Events.

### 4.5 Betrieb

MUSS:

- auf Windows oder sauber getrennt auf Linux betreibbar sein;
- als Service gestartet und überwacht werden können;
- strukturierte Logs liefern;
- nach Prozessabsturz wieder anlaufen;
- Netzunterbrechungen tolerieren;
- doppelte, verspätete und ungeordnet eintreffende Nachrichten erkennen;
- Konfiguration und Secrets getrennt verwalten;
- Datenbankmigrationen reproduzierbar ausführen;
- Backups und Restore unterstützen.

### 4.6 Sicherheit

MUSS:

- strikte sprachneutrale Schemas unterstützen;
- unbekannte Action Types ablehnen;
- fremde Ressourcen- und Force-Package-Kontrolle verhindern;
- Afghan-State-Partnerautonomie prüfen;
- State-Versionen und Aggregate Locks verwenden;
- Authority-, Resource-, Force-Generation-, Knowledge- und Policy-Validatoren unterstützen;
- Commander-Text als nicht vertrauenswürdige Daten behandeln;
- keinerlei dynamische Codeausführung aus Commander-Ausgaben zulassen;
- akzeptierte und abgelehnte Entscheidungen auditieren.

## 5. Bewertungsmethodik

```text
STAGE 1: KNOCK_OUT_VALIDATION
STAGE 2: WEIGHTED_SCORING
STAGE 3: IDENTICAL_REFERENCE_POC
STAGE 4: MEASURED_DECISION
```

Nur Kandidaten, die alle Knock-out-Kriterien erfüllen, werden bewertet.

| Bewertungsbereich | Gewicht |
|---|---:|
| MOOSE-/DCS-Integration | 25 % |
| Zuverlässigkeit und Fehlertoleranz | 20 % |
| CampaignState, Resource Economy und Event-Verarbeitung | 18 % |
| Testbarkeit und deterministischer Replay | 15 % |
| Entwicklungsaufwand und Wartbarkeit | 9 % |
| Deployment und Betrieb | 8 % |
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

## 6. Adaptergrenze

Der Orchestrator übermittelt keine frei formulierten MOOSE-Methodenaufrufe.

```yaml
adapter_command:
  command_id: CMD-000123
  schema_version: "2.0"
  campaign_id: OMW-TEST-001
  operation_id: OPR-000042
  command_type: MATERIALIZE_OPERATION
  expected_state_version: 184
  issued_at: 2026-08-03T00:00:00Z
  payload:
    operation_type: ROUTE_SECURITY
    area_ref: SEC-KABUL-NORTH
    route_ref: RTE-MSR-EAST-E3
    force_package_refs:
      - FPG-ISAF-QRF-001
    desired_effects:
      - PROTECT
      - OBSERVE
    constraints:
      civilian_risk_limit: LOW
      recovery_required: true
```

Adapterantwort:

```yaml
adapter_result:
  command_id: CMD-000123
  adapter_version: "2.0"
  dcs_session_id: DCS-SESSION-004
  moose_version: 2.9.18
  accepted: true
  status: MATERIALIZED
  strategic_entity_refs:
    - FPG-ISAF-QRF-001
  physical_refs:
    - object_type: group
      object_name: OMW_BLUE_QRF_001
  emitted_event_refs:
    - EVT-009812
```

```text
same command_id
-> no duplicate physical execution
```

## 7. Resource-Economy-Anforderungen

Die Technologie muss transaktionssicher verwalten:

```text
RESOURCE_SOURCE_TICK
ACCESS_SHARE_CALCULATION
BENEFICIARY_ALLOCATION
RESOURCE_ACCOUNT_CREDIT
RESOURCE_RESERVATION
RESOURCE_TRANSFER
RESOURCE_CONSUMPTION
FORCE_GENERATION
```

Zwingend:

```text
same source state + same rule version
-> same share allocation
```

```text
TRANSFER != GENERATION
```

```text
duplicate delivery event
-> no second credit
```

```text
one manpower allocation
-> no double force generation
```

## 8. Force-Generation-Anforderungen

Der Kandidat muss einen langlebigen, recoverbaren Lifecycle verwalten:

```text
PROPOSED
VALIDATING
REJECTED
RESOURCES_RESERVED
RECRUITING
TRAINING
EQUIPPING
FORMING
AVAILABLE
CANCELLED
FAILED
```

Nach Neustart müssen rekonstruierbar sein:

- reservierte Ressourcen;
- aktueller Phase;
- verbleibende Zeit;
- organisatorische Gates;
- erzeugtes Force Package oder fehlender Abschluss;
- idempotente Materialisierungsanforderung.

## 9. Route-, PATHLINE- und Markeranforderungen

Die Technologie muss trennen:

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

```text
MOOSE_PATHLINE != guaranteed DCS route
WORLD_THREAT_INDICATOR != commander knowledge
```

## 10. Kandidat A – Python

### 10.1 Erwartete Stärken

- schnelle Entwicklung des Harness;
- starkes Schema- und Datenmodellökosystem;
- Pydantic oder vergleichbare Runtime-Validierung;
- pytest und Hypothesis;
- sehr gute LLM-SDK-Verfügbarkeit;
- gute Analyse- und Simulationstools;
- gute Windows-Unterstützung;
- breite PostgreSQL-, Queue- und Observability-Unterstützung.

### 10.2 Erwartete Risiken

- Fehlertoleranz ist nicht automatisch Teil des Runtime-Modells;
- Prozessaufsicht muss bewusst umgesetzt werden;
- globale Zustände können Determinismus beschädigen;
- undisziplinierte Nebenläufigkeit kann schwer diagnostizierbar werden;
- dynamische Typisierung erfordert strikte Runtime-Schemas und Type Checking.

### 10.3 Zielbild

```text
PYTHON ORCHESTRATOR SERVICE
- explicit domain services
- Pydantic schemas
- deterministic reducers
- PostgreSQL
- migration tooling
- pytest + Hypothesis
- structured logging
- minimal HTTP or message interface
- supervised service process
```

Zwingend:

```text
NO DYNAMIC IMPORT FROM COMMANDER OUTPUT
NO GENERATED PYTHON EXECUTION
NO UNVERSIONED GLOBAL RANDOM
```

## 11. Kandidat B – Elixir

### 11.1 Erwartete Stärken

- OTP Supervisor Trees;
- robuste langlaufende Prozesse;
- Isolation von Commander-, Operation-, Resource- und Adapterprozessen;
- Message Passing;
- Restart-Strategien;
- hohe Eignung für nebenläufige zustandsbehaftete Orchestrierung;
- gute Telemetrie;
- natürliche Modellierung von Timeouts und Prozessausfällen.

### 11.2 Erwartete Risiken

- kleineres LLM- und Datenanalyseökosystem;
- höhere Einarbeitungskosten;
- zusätzliche Release- und Betriebsfragen unter Windows;
- weniger Standardbeispiele für DCS-nahe Integrationen;
- mögliche Zusatzarbeit für historische Simulation und Offline-Analyse.

### 11.3 Zielbild

```text
ELIXIR OTP APPLICATION
- supervision tree
- commander processes
- resource services
- force generation processes
- operation processes
- adapter connection process
- Ecto + PostgreSQL
- ExUnit + StreamData
- telemetry
```

## 12. Kandidat C – Hybrid Elixir plus Python

```text
ELIXIR
- runtime supervision
- event processing
- resource transactions
- force-generation lifecycle
- operation lifecycle
- adapter connectivity
- scheduling

PYTHON
- LLM gateway
- offline analysis
- evaluation
- test-data generation
```

Das Hybridmodell wird nur zugelassen, wenn messbarer Nutzen die zusätzlichen Kosten rechtfertigt:

- zwei Laufzeitumgebungen;
- zusätzliche API-Grenze;
- zwei Deployment- und Migrationsebenen;
- verteiltes Debugging;
- mehr Fehler- und Versionsmöglichkeiten.

## 13. Persistenz

Produktionsnahe Referenz:

```text
PostgreSQL
```

Benötigte Eigenschaften:

- Transaktionen;
- optimistic concurrency;
- eindeutige Idempotency Keys;
- Event Store und Snapshots;
- referenzielle Integrität;
- Schema-Migration;
- Recovery und Backup;
- parallele Commander- und Resource-Transaktionen.

SQLite kann für frühe lokale Tests dienen, ist aber keine automatisch gesetzte Produktionsentscheidung.

## 14. Deploymentmodelle

### Modell A – Alles auf Windows

```text
DCS
MOOSE
local adapter
orchestrator
PostgreSQL
optional LLM gateway
```

Vorteile:

- geringe Netzkomplexität;
- einfacher früher PoC.

Risiken:

- Ressourcen- und Fehlerkopplung zum DCS-Server;
- aufwendigere Wartung;
- LLM- und Datenbanklast auf demselben Host.

### Modell B – DCS/MOOSE auf Windows, Orchestrator extern

```text
WINDOWS DCS HOST:
  DCS
  MOOSE
  adapter

LINUX OR OTHER SERVICE HOST:
  orchestrator
  PostgreSQL
  LLM gateway
```

Vorteile:

- klare Trennung;
- bessere Service- und Datenbankumgebung;
- weniger Belastung des DCS-Hosts.

Risiken:

- Netzwerkunterbrechungen;
- zusätzliche Absicherung und Monitoring.

### Modell C – Kleiner lokaler Bridge-Service

```text
WINDOWS DCS HOST:
  DCS
  MOOSE
  minimal local bridge

EXTERNAL HOST:
  campaign orchestrator
  event store
  database
  commander services
  LLM gateway
```

Dieses Modell ist langfristig bevorzugter Prüfkandidat. Der lokale Bridge-Service bleibt klein und enthält keine Campaign Logic.

## 15. Verbindlicher Referenz-PoC

Alle Kandidaten implementieren dasselbe Szenario.

```text
1 CampaignState
1 Event Store
5 Commander
1 regional manpower source
1 Afghan state revenue source
1 external RED support source
1 materiel warehouse
1 route with 2 segments
1 hidden threat indicator
5 faction resource accounts
2 competing resource reservations
1 ISAF/Afghan partner request
1 RED negotiation
1 force-generation queue
1 resource transfer
1 DCS/MOOSE adapter stub
1 orchestrator restart and recovery
```

## 16. PoC-Ablauf

1. ResourceSources erzeugen einen begrenzten Turn-Zufluss.
2. Access Shares werden deterministisch auf Afghan State, Taliban, Haqqani und HIG verteilt.
3. ISAF erhält kein afghanisches Manpower.
4. ISAF fordert eine Afghan-led Route-Security-Operation an.
5. Afghan State akzeptiert nur unter Bedingung bestimmter Enabler.
6. Taliban und HIG konkurrieren um denselben regionalen Manpower-Anteil.
7. Haqqani erhält einen größeren Anteil eines begrenzten externen RED-Zuflusses.
8. Zwei Force-Generation-Anträge konkurrieren um Materiel.
9. Ein Materieltransfer wird physisch über den Adapter-Stub abgebildet.
10. Ein doppeltes Delivery Event wird gesendet.
11. Eine Operation wird genehmigt und materialisiert.
12. Der Orchestrator wird während laufender Force Generation beendet.
13. State, Locks und Queue werden aus Snapshot plus Events wiederhergestellt.
14. Derselbe Adapterbefehl wird erneut übermittelt.
15. Replay und Live-Fortsetzung müssen denselben Endzustand ergeben.

## 17. Verbindliche PoC-Tests

```text
POC-001 MOOSE boundary remains intact
POC-002 five commander views contain no unauthorized world truth
POC-003 hidden route indicator absent from unauthorized views
POC-004 resource-source shares are deterministic
POC-005 resource double reservation is rejected
POC-006 ISAF cannot use Afghan manpower
POC-007 ISAF cannot own Afghan force package
POC-008 partner operation requires Afghan approval
POC-009 donor or materiel transfer does not create ready unit
POC-010 duplicate adapter command does not duplicate execution
POC-011 duplicate transfer delivery does not duplicate credit
POC-012 one force-generation order creates one package
POC-013 force-generation queue survives restart
POC-014 event replay reproduces resource accounts and state
POC-015 snapshot plus tail equals full replay
POC-016 resource conservation holds after loss and transfer
POC-017 invalid Commander output triggers safe fallback
POC-018 MOOSE version present in audit output
POC-019 no generated code is executed
POC-020 same fixture seed and versions yield same hashes
```

## 18. Messwerte

```text
implementation_effort
code_size
schema_coverage
test_coverage
startup_time
memory_usage
recovery_time
event_throughput
resource_transaction_latency
resource_transaction_failure_rate
share_allocation_determinism
resource_conservation_failure_rate
force_generation_queue_recovery_time
force_generation_duplicate_rate
five_commander_concurrency_conflicts
partner_ownership_violation_rate
adapter_idempotency_rate
Windows deployment effort
Linux service deployment effort
debugging effort
operational complexity
```

Performance ist nur nach Korrektheit, Determinismus und Recovery relevant.

## 19. Acceptance-Kriterien des PoC

Ein Kandidat besteht nur, wenn:

- alle Knock-out-Kriterien erfüllt sind;
- alle 20 PoC-Tests bestehen;
- gleicher State und gleiche Versionen gleiche Resource- und Event-Hashes erzeugen;
- Recovery keine Ressource, Einheit oder Materialisierung dupliziert;
- fünf Commander ohne Ownership-Verletzung parallel arbeiten;
- ISAF/Afghan-State-Partnerautonomie erhalten bleibt;
- ResourceSource-, Transfer- und Force-Generation-Transaktionen nachvollziehbar sind;
- der MOOSE-Adapter klein und taktisch autoritativ bleibt;
- Deployment und Servicebetrieb reproduzierbar dokumentiert sind.

## 20. Vorläufige Richtung

```text
PYTHON_REFERENCE_POC = RECOMMENDED
ELIXIR_COMPARISON_POC = REQUIRED_BEFORE_FINAL_DECISION
HYBRID_MODEL = CONDITIONAL
PRODUCTION_TECHNOLOGY_DECISION = NOT_YET_MADE
```

Python ist für den ersten deterministischen Referenz-Harness wahrscheinlich effizienter. Dies ist keine endgültige Produktionsfestlegung.

Elixir muss denselben fachlichen PoC, dieselben Schemas und dieselben Tests erfüllen.

## 21. Entscheidungsvorlage

Nach Abschluss beider PoCs wird dokumentiert:

```yaml
technology_decision:
  candidates: []
  knockout_results: {}
  weighted_scores: {}
  poc_test_results: {}
  measured_metrics: {}
  deployment_results: {}
  operational_risks: {}
  selected_option: string|null
  rejected_options: []
  rationale: []
  review_date: date
  decision_status: PROPOSED|ACCEPTED|REJECTED|DEFERRED
```

Keine Technologie wird allein wegen LLM-Bibliotheken, persönlicher Präferenz oder theoretischer Concurrency-Vorteile ausgewählt.

## 22. Querverweise

```text
07-runtime-rulebook-and-action-schema.md
09-orchestrator-architecture-and-adjudication.md
12-multi-commander-test-scenarios.md
13-campaign-state-and-event-store-schema.md
14-deterministic-test-harness-and-scripted-commanders.md
16-afghan-state-and-ansf-commander-dossier.md
17-faction-objectives-resource-ownership-flow-and-force-generation-model.md
19-language-neutral-contracts-and-json-schemas.md
```
