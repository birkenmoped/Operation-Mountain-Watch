---
document_id: OMW-SP-LLM-COMMANDERS-ORCHESTRATOR-ADJUDICATION
status: DRAFT_RUNTIME_DESIGN
document_class: ORCHESTRATOR_ARCHITECTURE_AND_ADJUDICATION
scenario_period: 2010-08-01/2011-12-31
source_branch: docs/optional-llm-commanders
validated_in_dcs: false
authoritative_for:
  - orchestrator component boundaries
  - validation and adjudication pipeline
  - resource-source and force-generation runtime services
  - transaction and recovery model
  - DCS/MOOSE adapter boundary
---

# Orchestrator Architecture and Adjudication

## 1. Zweck

Dieses Dokument definiert die technische und logische Vermittlung zwischen fünf Commander-Instanzen, CampaignState, Resource Engine, Force Generation und DCS/MOOSE.

```text
CAMPAIGN_STATE
-> RESOURCE_SOURCE_AND_ACCOUNT_SERVICES
-> VIEW_BUILDER
-> COMMANDER_CONTEXT
-> SCRIPTED_COMMANDER_OR_LLM
-> STRUCTURED_DECISION
-> VALIDATION_STACK
-> ADJUDICATION_ENGINE
-> RESOURCE_OR_FORCE_GENERATION_TRANSACTION
-> OPERATION_PLAN
-> DCS_MOOSE_ADAPTER
-> EXECUTION_EVENTS
-> CAMPAIGN_STATE_UPDATE
-> COMMANDER_VISIBLE_RESULTS
```

Der Orchestrator ist die einzige Komponente, die Commander-Absichten in autoritative Kampagnenänderungen überführen darf.

## 2. Geltungsbereich

Kanonische Commander:

```text
BLUE_ISAF_COMMANDER
AFGHAN_STATE_COMMANDER
TALIBAN_COMMANDER
HAQQANI_COMMANDER
HIG_COMMANDER
```

Verbindliche Autoritäten:

```text
13-campaign-state-and-event-store-schema.md
16-afghan-state-and-ansf-commander-dossier.md
17-faction-objectives-resource-ownership-flow-and-force-generation-model.md
18-resource-model-integration-and-dossier-amendments.md
```

MOOSE bleibt der taktische Unterbau. Der Orchestrator implementiert keine parallele taktische Missionssteuerung.

## 3. Architekturprinzipien

```text
DETERMINISTIC_CORE
PROBABILISTIC_DECISION_SUPPORT
STRICT_SCHEMA_BOUNDARY
NO_DIRECT_LLM_WORLD_WRITE
NO_DIRECT_LLM_DCS_CONTROL
NO_DIRECT_COMMANDER_RESOURCE_WRITE
EVENT_SOURCED_AUDITABILITY
IDEMPOTENT_STATE_TRANSITIONS
RESOURCE_CONSERVATION
FIVE_FACTION_OWNERSHIP_ISOLATION
MOOSE_FIRST_TACTICAL_EXECUTION
```

Zusätzliche Trennungen:

```text
DCS_COALITION != CAMPAIGN_FACTION
RESOURCE_SOURCE != RESOURCE_ACCOUNT
RESOURCE_ACCOUNT != CAPABILITY_ASSET
FORCE_GENERATION_ORDER != FORCE_PACKAGE
FORCE_PACKAGE != DCS_GROUP
COMMANDER_VIEW != WORLD_TRUTH
```

## 4. Komponenten

```text
TURN_SCHEDULER
STATE_REPOSITORY
EVENT_STORE
SNAPSHOT_STORE
SCHEMA_REGISTRY
RESOURCE_SOURCE_MANAGER
ACCESS_SHARE_CALCULATOR
RESOURCE_ACCOUNT_SERVICE
RESOURCE_TRANSFER_SERVICE
FORCE_GENERATION_MANAGER
FORCE_PACKAGE_REGISTRY
VIEW_BUILDER
PROMPT_ASSEMBLER
COMMANDER_GATEWAY
SCHEMA_VALIDATOR
KNOWLEDGE_VALIDATOR
AUTHORITY_VALIDATOR
RELATIONSHIP_VALIDATOR
RESOURCE_VALIDATOR
FORCE_GENERATION_VALIDATOR
CAPABILITY_VALIDATOR
POLICY_VALIDATOR
ADJUDICATION_ENGINE
OPERATION_MANAGER
MATERIALIZATION_MANAGER
DCS_MOOSE_ADAPTER
RESULT_TRANSLATOR
MEMORY_MANAGER
AUDIT_LOGGER
RECOVERY_MANAGER
```

## 5. Turn Scheduler

```yaml
turn_schedule:
  commander_id: string
  faction_id: string
  trigger_type: periodic|event|request|deadline
  earliest_time: datetime
  latest_time: datetime|null
  priority: 0..100
  reason: string
  blocking_dependencies: []
  expected_state_version: integer
```

Mögliche Trigger:

```text
PERIODIC_REVIEW
MAJOR_OPERATION
RESOURCE_SOURCE_CHANGE
RESOURCE_ACCOUNT_THRESHOLD
FORCE_GENERATION_PHASE_CHANGE
FORCE_PACKAGE_LOSS
NODE_COMPROMISE
RELATIONSHIP_EVENT
NEGOTIATION_REQUEST
PARTNER_SUPPORT_REQUEST
OPERATION_PHASE_CHANGE
LOCAL_COMMANDER_REPORT
INTELLIGENCE_THRESHOLD_REACHED
DEADLINE_EXPIRED
```

Commander laufen nicht zwingend gleichzeitig oder in fester Reihenfolge. Parallelität wird über State-Versionen und Aggregate Locks kontrolliert.

## 6. State Repository

Der autoritative State enthält mindestens:

```yaml
campaign_state:
  campaign_time:
  world_entities: {}
  locations: {}
  sectors: {}
  routes: {}
  factions: {}
  commanders: {}
  organizations: {}
  actors: {}
  population_states: {}
  governance_states: {}
  resource_sources: {}
  resource_accounts: {}
  resource_reservations: {}
  resource_transfers: {}
  access_nodes: {}
  faction_shares: {}
  force_generation_orders: {}
  force_packages: {}
  force_units: {}
  capability_assets: {}
  networks: {}
  relationships: {}
  agreements: {}
  operations: {}
  information_items: {}
  beliefs: {}
  memories: {}
  policy_constraints: {}
  execution_bindings: {}
```

Jede Änderung erzeugt ein versioniertes Ereignis.

## 7. Resource Source Manager

Aufgaben:

- ResourceSources anlegen, ändern und deaktivieren;
- Turn-basierte Regeneration ausführen;
- Kapazität, Erschöpfung, Störung und Zerstörung verwalten;
- physische Kontrolle und rechtliches Eigentum getrennt halten;
- Quellenprovenienz erhalten;
- illegale, staatliche, lokale und externe Zuflüsse getrennt ausweisen.

```text
RESOURCE_SOURCE_TICK
-> GROSS_GENERATION
-> DISRUPTION_AND_EXHAUSTION
-> AVAILABLE_FLOW
```

Der Manager darf keine Fraktionsanteile frei erfinden. Er verwendet versionierte Regeln und den aktuellen CampaignState.

## 8. Access Share Calculator

Der Calculator bestimmt nachvollziehbar, welcher Anteil einer Quelle einer Fraktion zugänglich wird.

Eingaben können umfassen:

```text
PHYSICAL_CONTROL
ACCESS_NODE_CONTROL
ROUTE_STATUS
LEGAL_OWNERSHIP
AGREEMENTS
VOLUNTARY_SUPPORT
COERCIVE_CONTROL
LEGITIMACY
CORRUPTION_LEAKAGE
NETWORK_ACCESS
DISRUPTION
```

Ausgabe:

```yaml
share_calculation:
  source_id: string
  calculation_version: string
  input_state_version: integer
  gross_quantity: number
  faction_allocations: {}
  leakage: number
  unallocated: number
  rationale_codes: []
```

```text
SAME_STATE + SAME_RULE_VERSION
-> SAME_SHARE_RESULT
```

## 9. Resource Account Service

Aufgaben:

- Zuflüsse gutschreiben;
- Reservierungen erstellen und freigeben;
- Verpflichtungen und Verbrauch buchen;
- Transfers transaktionssicher verwalten;
- negative Bestände verhindern;
- doppelte Gutschriften blockieren;
- Ressourcenprovenienz verknüpfen.

Verbindliche Ressourcen:

```text
RECRUITABLE_MANPOWER
FINANCE
MATERIEL
```

Nicht als gemeinsame ResourceAccounts geführt werden:

```text
ISR
AIRLIFT
MEDEVAC
EOD
SPECIALIST_ACCESS
LEGITIMACY
PRESTIGE
VOLUNTARY_SUPPORT
COERCIVE_CONTROL
```

## 10. Resource Transfer Service

Ein Transfer umfasst:

```text
PROPOSAL
AUTHORITY_AND_AGREEMENT_CHECK
SOURCE_RESERVATION
OPTIONAL_PHYSICAL_TRANSPORT
PARTIAL_OR_FINAL_DELIVERY
DESTINATION_CREDIT
LOSS_OR_CANCELLATION
```

Verbindlich:

```text
TRANSFER != GENERATION
ONE_TRANSFER_ID -> AT_MOST_ONE_FINAL_CREDIT
DUPLICATE_DELIVERY_EVENT -> NO_SECOND_CREDIT
```

Foreign-faction transfers benötigen ein aktives Agreement oder eine ausdrücklich zulässige hierarchische Autorität. ISAF-zu-Afghan-State-Unterstützung überträgt Finance oder Materiel, nicht automatisch Kommando über afghanische Einheiten.

## 11. Force Generation Manager

Aufgaben:

- Force-Generation-Anträge entgegennehmen;
- Template- und Fraktionszulässigkeit prüfen;
- Ressourcenreservierungen koordinieren;
- fraktionsspezifische organisatorische Gates prüfen;
- Ausbildungs-, Formierungs- und Vorbereitungszeit verwalten;
- genau ein Force Package je erfolgreichem Auftrag erzeugen;
- Abbruch, Fehler und Rückerstattung kontrollieren;
- Recovery aus Event Store unterstützen.

Pipeline:

```text
FORCE_GENERATION_REQUEST
-> VALIDATION
-> RESOURCE_RESERVATION
-> ORGANIZATIONAL_GATE_CHECK
-> TIME_BASED_PHASES
-> FORCE_PACKAGE_CREATION
-> FORCE_PACKAGE_AVAILABLE
-> OPTIONAL_MOOSE_MATERIALIZATION
```

Fraktionsspezifische Gates:

```text
ISAF:
  NATIONAL_FORCE_POOL
  COALITION_COMMITMENT
  REPLACEMENT_CAPACITY

AFGHAN_STATE:
  TRAINING_CAPACITY
  RETENTION
  LEADERSHIP
  SUSTAINMENT

TALIBAN:
  CADRE_CAPACITY
  LOCAL_RECRUITMENT_ACCESS
  COMMAND_LINK

HAQQANI:
  NETWORK_ACCESS
  TRUSTED_CADRE_OR_SPECIALIST_GATE
  ROUTE_AND_STAGING_ACCESS

HIG:
  PATRONAGE_ACCESS
  LOCAL_COMMANDER_GATE
  REPRESENTATION_AND_COHESION
```

## 12. Force Package Registry

Die Registry verwaltet:

- Eigentümerfraktion;
- Organisation;
- Template-Referenz;
- Ressourcenprovenienz;
- Readiness;
- Reservierung und Zuweisung;
- virtuelle und physische Repräsentation;
- Verlust, Rekonstitution und Demobilisierung.

```text
AFGHAN_FORCE_PACKAGE.owner_faction = AFGHAN_STATE
```

ISAF darf ein afghanisches Force Package unterstützen, aber nicht als eigenen Bestand übernehmen.

## 13. View Builder

```text
OBJECTIVE_STATE
+ commander knowledge permissions
+ observations
+ reports
+ beliefs
+ memory
+ relationship channels
- hidden enemy information
- objective resource account values not observed
- unobserved source ownership and shares
- other commander internal state
= COMMANDER_VIEW
```

Der View Builder muss insbesondere verhindern:

- Leck objektiver ResourceSource-Bestände;
- Leck gegnerischer ResourceAccounts;
- Leck exakter Beneficiary Shares;
- automatische Vollteilung zwischen ISAF und Afghan State;
- Weitergabe versteckter Route-, Node- und Markerzustände;
- Leck anderer Beliefs und Memories.

Resource-bezogene Views enthalten nur:

```text
KNOWN
ESTIMATED
REPORTED
BELIEVED
UNKNOWN
```

mit Provenienz und Confidence.

## 14. Prompt Assembler

```text
SYSTEM_ROLE_AND_RULEBOOK
COMMANDER_DOSSIER
CURRENT_GOALS
CURRENT_PRIORITIES
AUTHORIZED_ACTIONS
COMMANDER_VIEW
KNOWN_FORCE_PACKAGES
KNOWN_RESOURCE_ACCOUNTS
KNOWN_RESOURCE_SOURCES
KNOWN_CAPABILITIES
ACTIVE_FORCE_GENERATION_ORDERS
ACTIVE_OPERATIONS
ACTIVE_AGREEMENTS
RECENT_RESULTS
RELEVANT_MEMORY
OUTPUT_SCHEMA
```

Prompt-Version, Modellkennung und Input-Snapshot werden protokolliert.

## 15. Commander Gateway

Das Gateway unterstützt geskriptete Commander und LLM-Commander über denselben Vertrag.

Aufgaben:

- Aufruf der Commander Policy;
- Timeout und Retry;
- strukturierte Ausgabe erzwingen;
- Modell- oder Policy-Version protokollieren;
- rohe Antwort unverändert archivieren;
- keinerlei Interpretation außerhalb des Schemas;
- deterministischen Fallback auslösen.

Mögliche Zustände:

```text
REQUEST_CREATED
REQUEST_SENT
RESPONSE_RECEIVED
TIMEOUT
TRANSPORT_ERROR
MODEL_ERROR
INVALID_OUTPUT
RETRYING
COMPLETED
FAILED
FALLBACK_USED
```

## 16. Validation Stack

```text
1 SCHEMA
2 IDENTITY_AND_TURN
3 KNOWLEDGE
4 AUTHORITY
5 RELATIONSHIP_AND_AGREEMENT
6 RESOURCE_SOURCE_AND_ACCOUNT
7 FORCE_GENERATION
8 FORCE_PACKAGE_AND_CAPABILITY
9 GEOGRAPHY_AND_TIME
10 POLICY_AND_TARGETING
11 TECHNICAL_MATERIALIZATION
12 CONFLICT_AND_CONCURRENCY
```

Ein später Validator darf keine frühere fehlende Voraussetzung stillschweigend ersetzen.

### 16.1 Resource Validator

Prüft:

```text
SOURCE_EXISTS
ACCOUNT_EXISTS
PROVENANCE_VALID
AVAILABLE_QUANTITY
RESERVATION_CONFLICT
TRANSFER_AUTHORITY
NO_DUPLICATE_CREDIT
```

### 16.2 Force Generation Validator

Prüft:

```text
TEMPLATE_AUTHORIZED
RESOURCE_RESERVATIONS_COMPLETE
FACTION_GATES_MET
GENERATION_TIME_VALID
QUEUE_STATE_VALID
NO_DUPLICATE_ORDER
```

### 16.3 Partner Authority Validator

Prüft:

```text
AFGHAN_FORCE_OWNER = AFGHAN_STATE
PARTNER_APPROVAL_EXISTS
COMMAND_RELATIONSHIP_VALID
COALITION_SUPPORT_AGREEMENT_EXISTS
ENABLER_RESERVATION_VALID
```

## 17. Adjudication Engine

Adjudication beantwortet nicht nur `gültig/ungültig`, sondern bestimmt plausible Kampagnenwirkung.

```yaml
adjudication_result:
  decision_id: string
  validation_status: enum
  accepted_action_type: string|null
  modifications: []
  resource_source_effects: []
  resource_account_effects: []
  force_generation_order_created: string|null
  operation_created: string|null
  resources_reserved: []
  force_packages_reserved: []
  immediate_state_changes: []
  delayed_effects: []
  uncertainty: 0..100
  execution_required: true|false
  commander_visible_response: {}
```

## 18. Adjudication Layers

### 18.1 Feasibility

Ist die Aktion grundsätzlich möglich?

### 18.2 Resource and Access Feasibility

Sind Quelle, Zugriff, Bestand und Übertragungsweg vorhanden?

### 18.3 Readiness

Sind Force Packages, Capabilities, Intelligence, Führung und Zeit vorhanden?

### 18.4 Friction

Welche Reibung entsteht durch Kommunikation, lokale Befolgung, Defektion, Korruption, Rivalität oder technische Einschränkungen?

### 18.5 Opposition

Welche gegnerischen oder neutralen Akteure können die Aktion entdecken, stören, blockieren oder umleiten?

### 18.6 Outcome

Welche unmittelbaren, verzögerten und unbeabsichtigten Effekte entstehen?

## 19. Ergebnisprinzipien

```text
INTENDED_EFFECT != GUARANTEED_EFFECT
SUCCESS != COMPLETE_INFORMATION
FAILURE != ZERO_EFFECT
TACTICAL_SUCCESS != STRATEGIC_SUCCESS
PHYSICAL_CONTROL != TOTAL_RESOURCE_CAPTURE
DCS_ENTITY_REMOVAL != AUTOMATIC_DEATH_OR_DETENTION
```

Eine Operation kann militärisch erfolgreich und politisch schädlich sein. Ein ResourceSource-Knoten kann physisch kontrolliert werden, ohne dass alle Zuflüsse sofort vollständig an die kontrollierende Fraktion gehen.

## 20. Determinismus und Zufall

```yaml
random_context:
  campaign_seed: integer
  turn_seed: integer
  share_calculation_seed: integer|null
  adjudication_seed: integer
  algorithm_version: string
```

Gleicher State, gleiche Entscheidung, gleiche Regelversion und gleicher Seed müssen zum gleichen Ergebnis führen.

Anteile und Ressourcenbuchungen sollen nach Möglichkeit ohne Zufall bestimmt werden. Zufall ist nur für ausdrücklich probabilistische Friktion zulässig.

## 21. Operation Plan

```yaml
operation_plan:
  operation_id: string
  originating_decision_id: string
  owner_faction: string
  owner_commander: string
  action_type: string
  lifecycle_state: enum
  strategic_effect: string
  origin_refs: []
  target_refs: []
  participant_force_package_refs: []
  supporting_capability_asset_refs: []
  resource_reservation_refs: []
  agreement_refs: []
  route_plan: []
  preparation_tasks: []
  execution_tasks: []
  abort_conditions: []
  fallback_plan: {}
  observation_requirements: []
  materialization_policy: {}
```

## 22. Operation Manager

Aufgaben:

- Lebenszyklus verwalten;
- Ressourcen und Force Packages reservieren und freigeben;
- Abhängigkeiten prüfen;
- Teilaufgaben terminieren;
- Abbruchbedingungen überwachen;
- Unterbrechung und Wiederaufnahme unterstützen;
- Resultate an State und Commander verteilen;
- ResourceSource- und AccessNode-Effekte an die Resource Engine zurückgeben.

## 23. Materialization Manager

Nicht jede strategische Aktion benötigt sofort DCS-Objekte.

```text
VIRTUAL_ONLY
EVENT_ONLY
HYBRID
PHYSICAL_REQUIRED
```

Beispiele:

```text
NEGOTIATE = VIRTUAL_ONLY
CHANGE_BENEFICIARY_SHARE = EVENT_ONLY after adjudication
PROTECT_RESOURCE_SOURCE = HYBRID or PHYSICAL_REQUIRED
RESOURCE_TRANSFER = VIRTUAL_ONLY or HYBRID
FORCE_PACKAGE_DEPLOYMENT = PHYSICAL_REQUIRED when player relevant
```

Materialisierung erfolgt so spät wie möglich und nur bei ausreichender Spielrelevanz.

## 24. DCS/MOOSE Adapter

Der Adapter erhält ausschließlich validierte Fachobjekte.

```yaml
dcs_execution_request:
  command_id: string
  schema_version: string
  operation_id: string
  expected_state_version: integer
  execution_type: enum
  force_package_refs: []
  template_refs: []
  route_refs: []
  task_profile_refs: []
  zone_refs: []
  timing: {}
  event_callbacks: []
  cleanup_policy: {}
```

Der Adapter übermittelt keine freien Commander-Texte an Lua oder MOOSE.

### 24.1 MOOSE-First

Vor eigener Lua-Implementierung sind in der tatsächlich eingebundenen MOOSE-Version 2.9.18 mindestens relevante Klassen und Funktionen zu prüfen, darunter soweit anwendbar:

```text
FSM
EVENTS
SCHEDULER
SET_*
ZONE
PATHLINE
COORDINATE
INTEL
DETECTION
SPAWN
SPAWNSTATIC
OPSGROUP
ARMYGROUP
AUFTRAG
WAREHOUSE
COMMANDER
CHIEF
AIRWING
SQUADRON
OPSTRANSPORT
CTLD
```

Der konkrete Adapter darf nur dokumentierte, geprüfte MOOSE-Funktionalität verwenden oder eine ausdrücklich freigegebene Ergänzung aufrufen.

### 24.2 Idempotenz

```text
same command_id
-> no duplicate physical execution
```

Der Adapter muss bei Wiederholung eines bereits akzeptierten Befehls den vorhandenen Status zurückgeben.

## 25. Execution Events

DCS/MOOSE meldet normalisierte Ereignisse:

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
ROUTE_REACHED
CONTACT_REPORTED
CACHE_DISCOVERED
CACHE_DESTROYED
CARGO_OR_TRANSFER_DELIVERED
CARGO_OR_TRANSFER_LOST
COMMUNICATION_LOST
```

Nicht direkt aus einer DCS-Gruppenlöschung abgeleitet werden dürfen:

```text
FORCE_PACKAGE_DETAINED
FORCE_PACKAGE_DISARMED
FORCE_PACKAGE_DEMOBILIZED
```

Diese Ergebnisse benötigen eine ausdrückliche Kampagnen-Adjudication.

## 26. Result Translator

```text
OBJECTIVE_RESULT
-> observable signatures
-> available reporting channels
-> report delay
-> source reliability
-> commander visible result
```

Beispiel:

```text
WORLD_TRUTH:
  materiel transfer partly lost

ISAF_VIEW:
  convoy failed to deliver full load

AFGHAN_STATE_VIEW:
  partial delivery confirmed, exact loss disputed

TALIBAN_VIEW:
  operation probably disrupted transfer
```

## 27. Concurrency Control

Erforderlich:

```text
STATE_VERSION_CHECK
RESOURCE_SOURCE_LOCK
RESOURCE_ACCOUNT_LOCK
RESOURCE_RESERVATION_LOCK
FORCE_GENERATION_LOCK
FORCE_PACKAGE_LOCK
OPERATION_LOCK
AGREEMENT_LOCK
LOCATION_CONFLICT_CHECK
OPTIMISTIC_CONCURRENCY_RETRY
```

Eine Entscheidung gegen einen veralteten Snapshot kann zurückgewiesen oder neu bewertet werden.

## 28. Transaction Model

### 28.1 ResourceSource Tick

```text
BEGIN_TRANSACTION
-> read source and access state
-> calculate shares
-> append generation and allocation events
-> credit accounts
-> commit state version
```

### 28.2 Force Generation

```text
BEGIN_TRANSACTION
-> validate request
-> reserve FINANCE MANPOWER MATERIEL
-> create force generation order
-> commit state version
-> process timed phases through events
-> create exactly one force package
```

### 28.3 Physical Operation

```text
BEGIN_TRANSACTION
-> reserve force packages and resources
-> create operation
-> append events
-> commit state version
-> dispatch adapter command
```

Bei physischer Ausführung wird zwischen strategischer Commit-Phase und technischer Bestätigung unterschieden.

## 29. Failure Recovery

```text
COMMANDER_FAILURE -> deterministic fallback
VALIDATION_FAILURE -> repair request or fallback
RESOURCE_TRANSACTION_FAILURE -> rollback or compensating events
FORCE_GENERATION_FAILURE -> release or explicitly consume reservations
DCS_FAILURE -> preserve state consistency and reconcile
STATE_WRITE_FAILURE -> no partial commit
ADAPTER_TIMEOUT -> reconcile against adapter and DCS events
```

Operationen, Transfers und Force-Generation-Aufträge dürfen nach einem Fehler nicht in unbestimmten Doppelzuständen verbleiben.

## 30. Recovery Sequence

```text
1 load last valid snapshot
2 replay remaining events
3 validate resource conservation
4 reconcile resource and operation locks
5 reconstruct force generation queues
6 mark DCS mappings unconfirmed
7 reconnect or start DCS session
8 reconcile materialized entities
9 reissue only idempotent commands where required
10 append recovery events
```

## 31. Security Boundaries

1. Commander- und LLM-Ausgaben werden als nicht vertrauenswürdig behandelt.
2. Keine Tool-, Shell-, Lua- oder Dateianweisung aus Commander-Text wird ausgeführt.
3. Nur bekannte IDs und Enums sind zulässig.
4. Freitext wird niemals als Code interpretiert.
5. CampaignState-Zugriffe erfolgen nur über definierte Services.
6. Audit- und Promptdaten dürfen keine Zugangsdaten enthalten.
7. Modellfehler dürfen keine Ressourcen duplizieren oder löschen.
8. ISAF- und Afghan-State-Eigentum bleibt getrennt.
9. Objektive ResourceSource- und Accountdaten werden nicht ungefiltert in Prompts übertragen.

## 32. Logging und Observability

Zu protokollieren:

```text
TURN_LATENCY
MODEL_OR_POLICY_LATENCY
VALIDATION_FAILURES
REPAIR_ATTEMPTS
FALLBACK_RATE
RESOURCE_SOURCE_TICK_DURATION
SHARE_CALCULATION_DURATION
RESOURCE_CONSERVATION_FAILURES
RESOURCE_LOCK_DURATION
FORCE_GENERATION_QUEUE_DEPTH
FORCE_GENERATION_FAILURES
OPERATION_SUCCESS_RATE
STATE_CONFLICTS
DCS_ADAPTER_ERRORS
MEMORY_UPDATE_COUNT
TOKEN_USAGE
```

## 33. Testarchitektur

### Unit Tests

- Schema und Validatoren;
- Share Calculation;
- Ressourcenreservierung und Transfer;
- Force Generation;
- Knowledge Filtering;
- Belief Update;
- Outcome-Berechnung.

### Integration Tests

- Commander Decision zu Resource Transaction;
- Commander Decision zu Force Generation;
- Operation Plan zu DCS Adapter;
- DCS Event zu CampaignState;
- ISAF/Afghan-State-Partneroperation;
- RED-Ressourcenkonkurrenz;
- konkurrierende ResourceSource-Anforderungen.

### Replay Tests

Gespeicherte Turns müssen mit gleichem State, Regelversionen und Seeds reproduzierbar sein.

## 34. Referenzszenarien

```text
TEST-ORCH-01 five commander turn scheduling
TEST-ORCH-02 regional manpower allocation among Afghan State and RED
TEST-ORCH-03 external RED support share competition
TEST-ORCH-04 ISAF support request accepted by Afghan State
TEST-ORCH-05 Afghan State rejects unsupported operation
TEST-ORCH-06 resource source disrupted and shares recalculated
TEST-ORCH-07 force generation creates exactly one package
TEST-ORCH-08 duplicate transfer delivery does not double credit
TEST-ORCH-09 MOOSE command replay does not duplicate materialization
TEST-ORCH-10 DCS execution failure and state reconciliation
TEST-ORCH-11 invalid Commander output and deterministic fallback
TEST-ORCH-12 campaign replay with identical state hash
```

## 35. Technische Abnahmekriterien

Die Architektur ist erst akzeptiert, wenn:

- Commander keinen direkten Schreibzugriff auf CampaignState besitzen;
- jeder Commander nur seine eigene View erhält;
- alle Aktionen schema-, autoritäts-, ressourcen- und capability-validiert werden;
- ResourceSources und Accounts konservativ und nachvollziehbar gebucht werden;
- ein Force-Generation-Auftrag höchstens ein Force Package erzeugt;
- ISAF keine afghanischen Force Packages besitzt oder direkt generiert;
- Operationen persistente Lebenszyklen besitzen;
- DCS-/MOOSE-Events normalisiert zurückgeführt werden;
- Ressourcen atomar reserviert und freigegeben werden;
- konkurrierende Turns keine Doppelverwendung erzeugen;
- Fehler deterministisch behandelt werden;
- vollständige Replay- und Auditdaten vorhanden sind;
- MOOSE-First vor eigener Lua-Funktionalität dokumentiert geprüft wurde.

## 36. Empfohlene Implementierungsreihenfolge

```text
PHASE 1: Event Store, CampaignState and schema registry
PHASE 2: ResourceSource, AccessShare and ResourceAccount services
PHASE 3: ForceGenerationManager and ForcePackageRegistry
PHASE 4: commander-specific View Builder
PHASE 5: schema validation and five scripted commanders
PHASE 6: operation lifecycle and adjudication
PHASE 7: DCS/MOOSE adapter with one limited effect profile
PHASE 8: memory, beliefs and information sharing
PHASE 9: negotiations, partner operations and resource competition
PHASE 10: LLM gateway behind the same contracts
```

Das LLM wird bewusst erst nach einer funktionierenden deterministischen Basis angeschlossen.
