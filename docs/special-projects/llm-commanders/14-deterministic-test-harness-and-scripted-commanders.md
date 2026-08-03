---
document_id: OMW-SP-LLM-COMMANDERS-DETERMINISTIC-HARNESS
status: DRAFT_RUNTIME_DESIGN
document_class: TEST_HARNESS_AND_SCRIPTED_COMMANDER_SPECIFICATION
scenario_period: 2010-08-01/2011-12-31
source_branch: docs/optional-llm-commanders
validated_in_dcs: false
authoritative_for:
  - deterministic non-LLM reference runtime
  - five scripted commander baselines
  - resource-source force-generation and adapter test fixtures
  - replay golden-master and differential testing
---

# Deterministischer Test Harness und geskriptete Commander

## 1. Zweck

Dieses Dokument definiert den ersten ausführbaren Testbetrieb des optionalen Multi-Commander-Projekts.

Der Test Harness muss ohne LLM und ohne laufende DCS-Instanz prüfen können:

- CampaignState und Event Store;
- ResourceSources, ResourceAccounts und Access Shares;
- Force Generation und Force Packages;
- fünf Commander Views;
- Validierung und Adjudication;
- Partnerautonomie ISAF/Afghan State;
- Operation Lifecycle;
- DCS-/MOOSE-Adaptervertrag;
- Recovery und Replay.

```text
NO_LLM_REQUIRED
NO_DCS_REQUIRED_FOR_CORE_TESTS
DETERMINISTIC_INPUT
DETERMINISTIC_DECISION
DETERMINISTIC_ADJUDICATION
REPRODUCIBLE_EVENTS
ASSERTABLE_STATE
```

Der Harness verwendet dieselben Schnittstellen, Schemas und Zustandsübergänge wie die spätere Runtime.

```text
SCRIPTED_COMMANDER
and
LLM_COMMANDER
must produce
THE_SAME_COMMANDER_DECISION_SCHEMA
```

## 2. Ziele

Der Harness muss mindestens beantworten:

1. Ist CampaignState aus Events reproduzierbar?
2. Erhält jeder Commander ausschließlich seine zulässige Sicht?
3. Werden unzulässige Entscheidungen zuverlässig blockiert?
4. Werden ResourceSources deterministisch erzeugt und verteilt?
5. Werden Ressourcen korrekt reserviert, verbraucht, transferiert und freigegeben?
6. Erzeugt ein Force-Generation-Auftrag höchstens ein Force Package?
7. Bleiben ISAF- und Afghan-State-Eigentum getrennt?
8. Funktionieren parallele Commander-Turns ohne Doppelbelegung?
9. Sind Adjudication-Ergebnisse mit gleichem Seed reproduzierbar?
10. Bleiben virtuelle und physische Repräsentationen konsistent?
11. Erzeugen fünf Scripted Commander unterscheidbare Entscheidungen?
12. Funktioniert Recovery nach Prozess- oder DCS-Ausfall?
13. Sind alle State-Änderungen über Events und Audit-Daten erklärbar?

## 3. Nichtziele der ersten Stufe

Die erste Stufe benötigt nicht:

- freie natürliche Sprache;
- echte LLM-Aufrufe;
- vollständige DCS-Missionen;
- dynamische Lua-Code-Erzeugung;
- vollständige taktische KI;
- vollständige Volkswirtschaft;
- grafische Benutzeroberfläche;
- Multiplayer-Synchronisation.

Sie benötigt dieselben IDs, Events, Validatoren, Resource- und Operation-Lifecycle-Regeln wie die spätere Laufzeit.

## 4. Referenzarchitektur

```text
TEST_SCENARIO
-> FIXTURE_LOADER
-> EVENT_STORE
-> STATE_REDUCER
-> CAMPAIGN_STATE
-> RESOURCE_SOURCE_TICK
-> ACCESS_SHARE_CALCULATOR
-> RESOURCE_ACCOUNT_SERVICE
-> FORCE_GENERATION_MANAGER
-> TURN_SCHEDULER
-> VIEW_BUILDER
-> SCRIPTED_COMMANDER
-> COMMANDER_DECISION
-> VALIDATION_STACK
-> ADJUDICATION_ENGINE
-> OPERATION_MANAGER
-> OPTIONAL_DCS_STUB
-> RESULT_TRANSLATOR
-> MEMORY_AND_BELIEF_UPDATE
-> ASSERTION_ENGINE
-> TEST_REPORT
```

## 5. Komponenten

```text
TEST_RUNNER
TEST_SCENARIO_LOADER
FIXTURE_REGISTRY
DETERMINISTIC_CLOCK
SEED_MANAGER
IN_MEMORY_EVENT_STORE
STATE_REDUCER
RESOURCE_SOURCE_SIMULATOR
ACCESS_SHARE_CALCULATOR
RESOURCE_ACCOUNT_SERVICE
RESOURCE_TRANSFER_STUB
FORCE_GENERATION_MANAGER
FORCE_PACKAGE_REGISTRY
SCRIPTED_COMMANDER_ADAPTER
DECISION_POLICY_ENGINE
FAULT_INJECTION_LAYER
TURN_RUNNER
DCS_MOOSE_ADAPTER_STUB
EVENT_COLLECTOR
ASSERTION_ENGINE
GOLDEN_REPLAY_MANAGER
DIFFERENTIAL_RUNNER
COVERAGE_REPORTER
```

### 5.1 Test Runner

Verantwortlich für:

- Auswahl des Szenarios;
- Laden der Fixtures;
- Festlegung der Seeds;
- Ausführung von Turns und Resource Ticks;
- Vergleich von Soll- und Ist-Zuständen;
- Erzeugung maschinenlesbarer Reports.

### 5.2 Fixture Loader

Lädt einen Ausgangszustand als:

```text
INITIAL_EVENTS
or
TRUSTED_SNAPSHOT + FOLLOW_UP_EVENTS
```

Ein Fixture darf CampaignState nicht direkt mutieren.

### 5.3 Deterministic Clock

```text
WALL_CLOCK_TIME != CAMPAIGN_TIME
```

Zeitfortschritt erfolgt ausschließlich durch Events.

### 5.4 Scripted Commander Registry

```yaml
scripted_commander_registry:
  CMD-ISAF-001: blue_isaf_baseline_v2
  CMD-AFGHAN-STATE-001: afghan_state_baseline_v1
  CMD-TALIBAN-001: taliban_baseline_v2
  CMD-HAQQANI-001: haqqani_baseline_v2
  CMD-HIG-001: hig_baseline_v2
```

### 5.5 Assertion Engine

Prüft:

- Events und State-Versionen;
- ResourceSources und Shares;
- ResourceAccounts und Transfers;
- Force-Generation-Orders;
- Force Packages;
- Operation Lifecycle;
- Commander Views;
- Beliefs und Memory;
- DCS-Mappings;
- Audit Records;
- Invarianten.

### 5.6 DCS/MOOSE Adapter Stub

Der Stub simuliert ausschließlich Rückmeldungen, die auch ein realer Adapter erzeugen könnte.

```text
ENTITY_MATERIALIZED
ENTITY_MOVED
ENTITY_DAMAGED
ENTITY_DESTROYED
PHYSICAL_ENTITY_REMOVED
TASK_STARTED
TASK_PHASE_CHANGED
TASK_COMPLETED
TASK_ABORTED
CARGO_OR_TRANSFER_DELIVERED
CARGO_OR_TRANSFER_LOST
CONTACT_REPORTED
COMMUNICATION_LOST
```

Der Stub setzt keine CampaignState-Werte direkt.

## 6. Testmodi

```text
SCHEMA_ONLY
PURE_STATE
RESOURCE_ECONOMY
SINGLE_TURN
MULTI_TURN
VIRTUAL_CAMPAIGN
EVENT_REPLAY
SNAPSHOT_RECOVERY
DIFFERENTIAL_COMMANDER
DCS_STUB
DCS_LIVE
LONG_RUNNING_CAMPAIGN
```

`DCS_LIVE` ist nachgelagert. Resource Economy und Force Generation müssen vorher vollständig außerhalb DCS funktionieren.

## 7. Verbindliches Test-Szenarioformat

```yaml
test_scenario:
  scenario_id: string
  title: string
  description: string
  schema_version: "2.0"
  mode: enum

  seeds:
    campaign_seed: integer
    scheduler_seed: integer
    share_calculation_seed: integer
    adjudication_seed: integer
    dcs_stub_seed: integer

  versions:
    resource_model_version: string
    share_calculation_version: string
    reducer_version: string
    scripted_policy_versions: {}
    adapter_stub_version: string

  initial_state:
    snapshot_ref: string|null
    event_fixture_refs: []

  commanders:
    - commander_id: string
      policy_ref: string
      enabled: boolean
      profile_overrides: {}

  execution:
    start_time: datetime
    end_time: datetime|null
    max_turns: integer
    max_events: integer
    resource_tick_interval: duration|null
    stop_conditions: []

  injected_events: []
  expected_decisions: []
  expected_events: []
  expected_state: {}
  forbidden_events: []
  invariant_sets: []
```

## 8. Determinismus

### 8.1 Seed-Regel

```text
NO_IMPLICIT_RANDOM
NO_SYSTEM_TIME_RANDOM
NO_PROCESS_ID_RANDOM
NO_UNLOGGED_RANDOM_DRAW
```

Jede Zufallsziehung wird protokolliert.

### 8.2 Stabile Sortierung

```text
priority DESC
created_at ASC
stable_id ASC
```

### 8.3 Hashes

Nach jedem Turn oder Resource Tick:

```text
EVENT_STREAM_HASH
CAMPAIGN_STATE_HASH
RESOURCE_SOURCE_HASH
RESOURCE_ACCOUNT_HASH
FORCE_GENERATION_QUEUE_HASH
COMMANDER_VIEW_HASH
DECISION_HASH
AUDIT_RECORD_HASH
```

Gleicher Ausgangszustand, gleiche Policy, gleiche Versionen und gleiche Seeds müssen dieselben Hashes erzeugen.

## 9. Gemeinsame Fixtures

Die erste Fixture-Bibliothek enthält mindestens:

```text
FIVE_FACTIONS
FIVE_COMMANDERS
REGIONAL_MANPOWER_SOURCE
LOCAL_LEGAL_FINANCE_SOURCE
AFGHAN_STATE_REVENUE_SOURCE
INTERNATIONAL_DONOR_SOURCE
EXTERNAL_RED_SUPPORT_SOURCE
ILLICIT_FINANCE_SOURCE
AFGHAN_MATERIEL_WAREHOUSE
RED_MATERIEL_CACHE
ROUTE_REVENUE_NODE
STRATEGIC_ROUTE_WITH_SEGMENTS
FIVE_FACTION_RESOURCE_ACCOUNTS
FORCE_GENERATION_QUEUE
ISAF_CAPABILITY_ASSETS
AFGHAN_FORCE_PACKAGE
RED_FORCE_PACKAGES
RELATIONSHIP_STATES
AGREEMENTS
BELIEF_STORES
```

Keine Fixture darf unbelegte konkrete DCS-Templates oder Mission-Editor-Objekte erfinden.

## 10. Scripted Commander Interface

Ein geskripteter Commander erhält exakt dasselbe Eingabeobjekt wie später ein LLM und liefert exakt dasselbe Decision-Schema.

Er erhält keinen direkten Zugriff auf:

- vollständigen CampaignState;
- fremde Commander Views;
- objektive gegnerische ResourceAccounts;
- versteckte Shares und Knoten;
- zukünftige Ereignisse;
- Adjudication-Zufallswerte.

## 11. Policy Engine

```yaml
scripted_policy:
  policy_id: string
  policy_version: string
  faction_id: string
  applicable_profile_refs: []
  rule_sets: []
  scoring_weights: {}
  tie_breakers: []
  fallback_rules: []
```

Gemeinsame Entscheidungsschritte:

```text
1 VALIDATE_INPUT
2 SUMMARIZE_BELIEFS
3 IDENTIFY_URGENT_THREATS
4 IDENTIFY_RESOURCE_AND_ACCESS_RISKS
5 IDENTIFY_AVAILABLE_OPPORTUNITIES
6 UPDATE_GOAL_PRIORITIES
7 GENERATE_ALLOWED_CANDIDATES
8 FILTER_BY_KNOWLEDGE
9 FILTER_BY_AUTHORITY
10 FILTER_BY_RESOURCE_AWARENESS
11 FILTER_BY_PARTNER_AND_AGREEMENT_STATE
12 SCORE_REMAINING_CANDIDATES
13 APPLY_PROFILE_BIAS
14 SELECT_ACTION
15 DEFINE_ABORT_AND_FALLBACK
16 FORMAT_DECISION
```

## 12. Kandidatenbewertung

```text
candidate_score =
  strategic_value
+ urgency
+ profile_preference
+ expected_information_gain
+ resource_access_gain
+ resource_denial_gain
+ relationship_value
+ sustainability
- military_risk
- political_risk
- network_risk
- civilian_harm_risk
- resource_cost
- capability_opportunity_cost
- uncertainty_penalty
```

## 13. BLUE ISAF Scripted Commander

```text
BLUE_ISAF_BASELINE_V2
```

Prioritätslogik:

1. katastrophale Verluste verhindern;
2. kritische C2-, Base- und Recovery-Kapazität erhalten;
3. Bevölkerung und Routen schützen;
4. unklare Ziele weiter aufklären;
5. Afghan-State-Unterstützung anbieten, ohne Eigentum zu übernehmen;
6. RED-ResourceSources und Netzwerke mit vertretbarem Risiko stören;
7. nachhaltige Transition fördern;
8. Coalition Commitment erhalten.

Regelbeispiele:

```text
IF Afghan force requested
AND partner approval absent
THEN REQUEST_PARTNER_OPERATION
```

```text
IF local trust high
THEN improve information and access scoring
BUT do not generate ISAF force package
```

```text
IF last MEDEVAC reserve would be consumed
AND emergency = false
THEN reject candidate
```

## 14. Afghan State Scripted Commander

```text
AFGHAN_STATE_BASELINE_V1
```

Prioritätslogik:

1. Staat, Führung und Force Cohesion erhalten;
2. kritische Bevölkerungs-, Regierungs- und Sicherheitszentren schützen;
3. staatliche Revenue-, Manpower- und Materielzugänge sichern;
4. nur capability-gerechte Operationen akzeptieren;
5. fehlende Koalitions-Enabler anfordern;
6. Afghan-led-Verantwortung erhöhen, wenn nachhaltig;
7. verfrühte Transition ablehnen;
8. Force Generation mit Training, Retention und Sustainment verbinden.

Regelbeispiele:

```text
IF operation requires unavailable enablers
THEN PARTNER_CONDITIONAL or DECLINE
```

```text
IF finance manpower and materiel available
AND training and retention gates met
THEN REQUEST_FORCE_GENERATION
```

```text
IF ISAF attempts direct tasking of Afghan package
THEN reject authority violation
```

## 15. Taliban Scripted Commander

```text
TALIBAN_BASELINE_V2
```

Prioritätslogik:

1. Führung und Netzwerk erhalten;
2. kritische ResourceSources und AccessNodes erhalten;
3. lokalen Informationszugang schützen;
4. unter hohem Druck Signatur reduzieren;
5. politische und soziale Kontrolle ausbauen;
6. gegnerische Ressourcenflüsse kosteneffizient stören;
7. nur ressourcengedeckte Force Packages erzeugen;
8. reinfiltrieren.

## 16. Haqqani Scripted Commander

```text
HAQQANI_BASELINE_V2
```

Prioritätslogik:

1. Führung und Kernbeziehungen erhalten;
2. Broker, Routen und externe ResourceSources schützen;
3. kompromittierte Knoten isolieren;
4. Redundanz aktivieren;
5. Finance, Materiel und ausgewählten Manpower sichern;
6. Force Packages mit Trusted-Cadre-Gate erzeugen;
7. Capability Packages vollständig vorbereiten;
8. hochwertige Operationen nur bei Readiness ausführen.

## 17. HIG Scripted Commander

```text
HIG_BASELINE_V2
```

Prioritätslogik:

1. eigenständige politische Relevanz erhalten;
2. gefährdete lokale Commander binden;
3. Verhandlungs- und Patronagekanäle schützen;
4. Defektionsrisiko reduzieren;
5. regionale Finance-, Manpower- und Materielzugänge sichern;
6. Force Packages nur bei gültigem Local-Commander-Gate erzeugen;
7. militärische Aktionen nur bei politischem Nutzen durchführen;
8. irreversible Unterordnung vermeiden.

## 18. Fault Injection

```text
INVALID_SCHEMA_COMMANDER
HALLUCINATING_COMMANDER
FOREIGN_RESOURCE_COMMANDER
OVERCONFIDENT_COMMANDER
ATTACK_ONLY_COMMANDER
NO_ABORT_CONDITION_COMMANDER
STALE_TURN_COMMANDER
DUPLICATE_ACTION_ID_COMMANDER
AFGHAN_OWNERSHIP_VIOLATION_COMMANDER
RESOURCE_WITHOUT_SOURCE_COMMANDER
DUPLICATE_FORCE_GENERATION_COMMANDER
DIRECT_MOOSE_COMMANDER
```

Zusätzliche technische Fehler:

```text
RESOURCE_SOURCE_TICK_DUPLICATE
RESOURCE_ACCOUNT_WRITE_CONFLICT
TRANSFER_DELIVERY_DUPLICATE
FORCE_GENERATION_RESTART
DCS_EVENT_DUPLICATE
DCS_ENTITY_MISSING
MATERIALIZATION_TIMEOUT
SNAPSHOT_CORRUPTION
```

## 19. Assertions

### 19.1 State und Event

```text
EVENT_SEQUENCE_CONTIGUOUS
STATE_VERSION_MONOTONIC
REPLAY_HASH_MATCH
SNAPSHOT_PLUS_TAIL_EQUIVALENT
```

### 19.2 Ressourcen

```text
NO_NEGATIVE_RESOURCE_ACCOUNT
NO_RESOURCE_WITHOUT_SOURCE
NO_DOUBLE_RESERVATION
NO_DUPLICATE_CREDIT
TRANSFER_CONSERVES_RESOURCE
SHARE_ALLOCATION_CONSERVES_GROSS_FLOW
ONE_MANPOWER_SHARE_NOT_DOUBLE_USED
```

### 19.3 Force Generation

```text
RESOURCE_PROVENANCE_COMPLETE
FACTION_GATES_MET
ONE_ORDER_ONE_FORCE_PACKAGE
NO_ISAF_USE_OF_AFGHAN_MANPOWER
NO_REPUTATION_TO_UNIT_CONVERSION
```

### 19.4 Eigentum und Partner

```text
AFGHAN_FORCE_OWNER_REMAINS_AFGHAN_STATE
ISAF_SUPPORT_DOES_NOT_TRANSFER_COMMAND
PARTNER_APPROVAL_REQUIRED
SAME_DCS_COALITION_NOT_SHARED_AUTHORITY
```

### 19.5 DCS/MOOSE

```text
NO_PHYSICAL_EXECUTION_BEFORE_APPROVAL
ONE_COMMAND_ID_ONE_MATERIALIZATION
MISSING_ENTITY_NOT_AUTOMATICALLY_DESTROYED
NO_DIRECT_LLM_OR_SCRIPTED_MOOSE_CALL
MOOSE_VERSION_PRESENT_IN_AUDIT
```

## 20. Golden Master Tests

Golden Results sind geprüfte Artefakte und werden nicht automatisch überschrieben.

Ein Golden Master enthält:

```yaml
golden_run:
  scenario_id: string
  schema_version: string
  policy_versions: {}
  resource_model_version: string
  expected_event_stream_hash: string
  expected_state_hash: string
  expected_resource_hash: string
  expected_force_generation_hash: string
  expected_decision_hashes: {}
```

Änderungen an Schema, Regeln, Policy oder Share Calculation können Golden Results ungültig machen. Aktualisierung benötigt Review und Begründung.

## 21. Differential Testing

Verglichen werden:

```text
SCRIPTED_BASELINE
vs
LLM_NORMALIZED_DECISION
```

Nicht verglichen wird exakte Wortwahl. Verglichen werden:

- Legalität;
- Authority Awareness;
- Resource Awareness;
- Partnerautonomie;
- strategische Konsistenz;
- Risiko- und Unsicherheitsbehandlung;
- Attack Bias;
- Fallback-Qualität.

## 22. LLM Shadow Mode

Im Shadow Mode:

- Scripted Decision wird autoritativ angewandt;
- LLM Decision wird validiert und protokolliert;
- LLM Decision verändert CampaignState nicht;
- Abweichungen werden klassifiziert;
- gefährliche oder ungültige Muster werden gemessen.

## 23. Beispieltests

```text
TH-001 event replay reproduces state
TH-002 commander view hides world truth
TH-003 five commanders receive distinct views
TH-004 unknown action type rejected
TH-005 foreign resource control rejected
TH-006 Afghan force ownership violation rejected
TH-007 resource double reservation prevented
TH-008 resource transfer duplicate credit prevented
TH-009 resource source shares deterministic
TH-010 one force-generation order creates one package
TH-011 ISAF cannot recruit from Afghan manpower
TH-012 reputation cannot generate force package
TH-013 Afghan State requests missing enablers
TH-014 Taliban protects threatened resource source
TH-015 Haqqani package gate blocks operation
TH-016 HIG local commander gate blocks generation
TH-017 DCS stub destruction creates validated loss path
TH-018 missing DCS entity does not imply destruction
TH-019 recovery does not duplicate materialized entity
TH-020 same seed reproduces same result
TH-021 different faction policies produce distinct choices
TH-022 thirty-day resource economy conserves stocks
```

## 24. Run Report

```yaml
test_report:
  run_id: string
  scenario_id: string
  started_at: datetime
  completed_at: datetime
  mode: string
  versions: {}
  seeds: {}
  commander_turns: integer
  event_count: integer
  final_state_hash: string
  resource_hash: string
  force_generation_hash: string
  assertion_results: []
  invariant_failures: []
  validation_failures: []
  fallback_events: []
  differential_results: []
  adapter_events: []
  status: PASSED|FAILED|INCONCLUSIVE
```

## 25. Acceptance-Kriterien

Der Harness ist akzeptiert, wenn:

- gleiche Fixture, Versionen und Seeds denselben Event Stream erzeugen;
- Replay denselben State erzeugt;
- ResourceSource- und Share-Logik konservativ und deterministisch ist;
- alle fünf Scripted Commander eine 30-Tage-Kampagne ausführen können;
- ungültige Entscheidungen sichere Fallbacks auslösen;
- Afghan-State-Eigentum und Partnerautonomie erhalten bleiben;
- Force Generation keine Einheiten oder Ressourcen dupliziert;
- kein Testkern von einem Live-LLM oder DCS abhängt;
- DCS Stub und späterer Adapter denselben Eventvertrag verwenden;
- MOOSE-First in Audit und Testreport sichtbar ist.

## 26. Implementierungsreihenfolge

```text
1 Event Envelope and in-memory Event Store
2 State Reducer and snapshot hash
3 ResourceSource and Share Calculation
4 ResourceAccount and Transfer Service
5 ForceGenerationManager and ForcePackageRegistry
6 Fixture Loader
7 Commander View Builder
8 Common Decision Schema Validator
9 Five Scripted Commander Policies
10 Adjudication Engine
11 Operation Lifecycle Manager
12 DCS/MOOSE Adapter Stub
13 Recovery Tests
14 Golden Master Suite
15 Differential and Shadow Mode
```

## 27. Querverweise

```text
07-runtime-rulebook-and-action-schema.md
09-orchestrator-architecture-and-adjudication.md
12-multi-commander-test-scenarios.md
13-campaign-state-and-event-store-schema.md
15-orchestrator-technology-selection-and-deployment-model.md
16-afghan-state-and-ansf-commander-dossier.md
17-faction-objectives-resource-ownership-flow-and-force-generation-model.md
```
