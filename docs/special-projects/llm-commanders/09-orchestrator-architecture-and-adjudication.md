---
document_id: OMW-SP-LLM-COMMANDERS-ORCHESTRATOR-ADJUDICATION
status: DRAFT_RUNTIME_DESIGN
document_class: ORCHESTRATOR_ARCHITECTURE_AND_ADJUDICATION
scenario_period: 2010-08-01/2011-12-31
source_branch: docs/optional-llm-commanders
validated_in_dcs: false
---

# Orchestrator Architecture and Adjudication

## 1. Zweck

Dieses Dokument definiert die technische und logische Vermittlung zwischen Commander-LLMs, CampaignState und DCS/MOOSE.

```text
CAMPAIGN_STATE
-> VIEW_BUILDER
-> COMMANDER_CONTEXT
-> COMMANDER_LLM
-> STRUCTURED_DECISION
-> VALIDATOR
-> ADJUDICATOR
-> OPERATION_PLAN
-> DCS_MOOSE_ADAPTER
-> EXECUTION_EVENTS
-> CAMPAIGN_STATE_UPDATE
-> COMMANDER_VISIBLE_RESULTS
```

Der Orchestrator ist die einzige Komponente, die LLM-Absichten in autoritative Kampagnenänderungen überführen darf.

## 2. Architekturprinzipien

```text
DETERMINISTIC_CORE
PROBABILISTIC_DECISION_SUPPORT
STRICT_SCHEMA_BOUNDARY
NO_DIRECT_LLM_WORLD_WRITE
NO_DIRECT_LLM_DCS_CONTROL
EVENT_SOURCED_AUDITABILITY
IDEMPOTENT_STATE_TRANSITIONS
```

## 3. Komponenten

```text
TURN_SCHEDULER
STATE_REPOSITORY
EVENT_STORE
VIEW_BUILDER
PROMPT_ASSEMBLER
LLM_GATEWAY
SCHEMA_VALIDATOR
KNOWLEDGE_VALIDATOR
AUTHORITY_VALIDATOR
RESOURCE_VALIDATOR
POLICY_VALIDATOR
RELATIONSHIP_VALIDATOR
ADJUDICATION_ENGINE
OPERATION_MANAGER
MATERIALIZATION_MANAGER
DCS_MOOSE_ADAPTER
RESULT_TRANSLATOR
MEMORY_MANAGER
AUDIT_LOGGER
RECOVERY_MANAGER
```

## 4. Turn Scheduler

Der Scheduler entscheidet, welcher Commander wann einen Turn erhält.

```yaml
turn_schedule:
  commander_id: string
  trigger_type: periodic|event|request|deadline
  earliest_time: datetime
  latest_time: datetime|null
  priority: 0..100
  reason: string
  blocking_dependencies: []
```

Mögliche Trigger:

```text
PERIODIC_REVIEW
MAJOR_BLUE_OPERATION
RESOURCE_LOSS
NODE_COMPROMISE
RELATIONSHIP_EVENT
NEGOTIATION_REQUEST
OPERATION_PHASE_CHANGE
LOCAL_COMMANDER_REPORT
INTELLIGENCE_THRESHOLD_REACHED
DEADLINE_EXPIRED
```

Commander laufen nicht zwingend gleichzeitig oder in fester Reihenfolge.

## 5. State Repository

Der autoritative State enthält mindestens:

```yaml
campaign_state:
  campaign_time:
  world_entities: {}
  locations: {}
  sectors: {}
  factions: {}
  commanders: {}
  resources: {}
  networks: {}
  routes: {}
  relationships: {}
  agreements: {}
  operations: {}
  information_items: {}
  memories: {}
  policy_constraints: {}
  execution_bindings: {}
```

Jede Änderung erzeugt ein versioniertes Ereignis.

## 6. View Builder

Der View Builder erzeugt aus dem autoritativen State ein fraktions- und commander-spezifisches Lagebild.

```text
OBJECTIVE_STATE
+ commander knowledge permissions
+ observations
+ reports
+ beliefs
+ memory
+ relationship channels
- hidden enemy information
- unobserved world state
= COMMANDER_VIEW
```

Der View Builder muss verhindern, dass interne IDs, versteckte Ressourcen oder gegnerische Absichten unbeabsichtigt in den Prompt gelangen.

## 7. Prompt Assembler

Das Eingabepaket besteht aus:

```text
SYSTEM_ROLE_AND_RULEBOOK
COMMANDER_DOSSIER
CURRENT_GOALS
CURRENT_PRIORITIES
AUTHORIZED_ACTIONS
COMMANDER_VIEW
ACTIVE_OPERATIONS
ACTIVE_AGREEMENTS
RECENT_RESULTS
RELEVANT_MEMORY
OUTPUT_SCHEMA
```

Prompt-Version, Modellkennung und Input-Snapshot werden protokolliert.

## 8. LLM Gateway

Aufgaben:

- Modellaufruf;
- Timeout und Retry;
- strukturierte Ausgabe erzwingen;
- Token- und Kostenkontrolle;
- Modellversion protokollieren;
- rohe Antwort unverändert archivieren;
- keine Interpretation außerhalb des Schemas.

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
```

## 9. Validation Stack

Validierung erfolgt in definierter Reihenfolge:

```text
1 SCHEMA
2 IDENTITY_AND_TURN
3 KNOWLEDGE
4 AUTHORITY
5 RELATIONSHIP_AND_AGREEMENT
6 RESOURCE
7 GEOGRAPHY_AND_TIME
8 POLICY_AND_TARGETING
9 TECHNICAL_MATERIALIZATION
10 CONFLICT_AND_CONCURRENCY
```

Ein später Validator darf keine frühere fehlende Voraussetzung stillschweigend ersetzen.

## 10. Adjudication

Adjudication beantwortet nicht nur `gültig/ungültig`, sondern bestimmt die plausible Kampagnenwirkung.

```yaml
adjudication_result:
  decision_id: string
  validation_status: enum
  accepted_action_type: string|null
  modifications: []
  operation_created: string|null
  resources_reserved: []
  immediate_state_changes: []
  delayed_effects: []
  uncertainty: 0..100
  execution_required: true|false
  commander_visible_response: {}
```

## 11. Adjudication Layers

### 11.1 Feasibility

Ist die Aktion grundsätzlich möglich?

### 11.2 Readiness

Sind Personal, Material, Intelligence, Zugang und Zeit vorhanden?

### 11.3 Friction

Welche Reibung entsteht durch Kommunikation, lokale Befolgung, Defektion, Rivalität oder technische Einschränkungen?

### 11.4 Opposition

Welche gegnerischen oder neutralen Akteure können die Aktion entdecken, stören oder vereiteln?

### 11.5 Outcome

Welche unmittelbaren, verzögerten und unbeabsichtigten Effekte entstehen?

## 12. Ergebnisprinzip

```text
INTENDED_EFFECT != GUARANTEED_EFFECT
SUCCESS != COMPLETE_INFORMATION
FAILURE != ZERO_EFFECT
TACTICAL_SUCCESS != STRATEGIC_SUCCESS
```

Eine Operation kann militärisch erfolgreich und politisch schädlich sein oder taktisch scheitern und dennoch Aufklärungsgewinn erzeugen.

## 13. Determinismus und Zufall

Zufall darf nur über versionierte, reproduzierbare Mechanismen eingebracht werden.

```yaml
random_context:
  campaign_seed: integer
  turn_seed: integer
  adjudication_seed: integer
  algorithm_version: string
```

Gleicher State, gleiche Entscheidung und gleicher Seed müssen zum gleichen Ergebnis führen.

## 14. Outcome Score

Vorläufiges abstraktes Modell:

```text
outcome_score =
  readiness
+ intelligence_quality
+ leadership_quality
+ terrain_advantage
+ surprise
+ local_support
+ counterpart_support
- blue_detection
- opposition_strength
- internal_friction
- route_compromise
- civilian_risk_constraints
- technical_failure
```

Das Ergebnis wird nicht allein aus einem Gesamtwert abgeleitet. Einzelne Teilergebnisse bleiben sichtbar.

## 15. Operation Plan

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
  participants: []
  resources_reserved: []
  route_plan: []
  preparation_tasks: []
  execution_tasks: []
  abort_conditions: []
  fallback_plan: {}
  observation_requirements: []
  materialization_policy: {}
```

## 16. Operation Manager

Aufgaben:

- Lebenszyklus verwalten;
- Ressourcen reservieren und freigeben;
- Abhängigkeiten prüfen;
- Teilaufgaben terminieren;
- Abbruchbedingungen überwachen;
- Unterbrechung und Wiederaufnahme unterstützen;
- Resultate an State und Commander verteilen.

## 17. Materialization Manager

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
BUILD_POLITICAL_INFLUENCE = EVENT_ONLY or HYBRID
MOVE_RESOURCES = HYBRID
CONDUCT_AMBUSH = PHYSICAL_REQUIRED
```

Materialisierung erfolgt so spät wie möglich und nur mit ausreichender Spielrelevanz.

## 18. DCS/MOOSE Adapter

Der Adapter erhält keine freien LLM-Texte, sondern ausschließlich validierte Operation Plans.

```yaml
dcs_execution_request:
  operation_id: string
  execution_type: enum
  template_refs: []
  spawn_or_activate_refs: []
  route_refs: []
  task_refs: []
  zone_refs: []
  timing: {}
  event_callbacks: []
  cleanup_policy: {}
```

Vor eigener Lua-Implementierung ist im technischen Spezialprojekt ebenfalls zu prüfen, ob MOOSE vorhandene Klassen und Funktionen bereitstellt.

## 19. MOOSE-First-Prüffelder

Mindestens zu prüfen:

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
```

Die konkrete Auswahl hängt von der eingebundenen MOOSE-Version ab.

## 20. Execution Events

DCS/MOOSE meldet normalisierte Ereignisse:

```text
GROUP_ACTIVATED
GROUP_DESTROYED
GROUP_DAMAGED
GROUP_WITHDREW
ROUTE_REACHED
TARGET_ENGAGED
TARGET_EFFECT_OBSERVED
CACHE_DISCOVERED
CACHE_DESTROYED
UNIT_CAPTURED
CIVILIAN_HARM_REPORTED
MISSION_ABORTED
MISSION_COMPLETED
CONTACT_LOST
```

Rohe DCS-Events werden durch den Adapter in Kampagnenereignisse übersetzt.

## 21. Result Translator

Nicht jeder Commander erfährt das objektive Ergebnis vollständig.

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
WORLD_TRUTH: attack cell destroyed
TALIBAN_VIEW: contact lost, fate unknown
HAQQANI_VIEW: route compromised, cell status uncertain
BLUE_VIEW: probable destruction, identity unconfirmed
```

## 22. Concurrency Control

Mehrere Commander können widersprüchliche Aktionen gegen dieselben Ressourcen oder Räume planen.

Erforderlich:

```text
STATE_VERSION_CHECK
RESOURCE_LOCK
OPERATION_RESERVATION
AGREEMENT_LOCK
LOCATION_CONFLICT_CHECK
OPTIMISTIC_CONCURRENCY_RETRY
```

Eine Entscheidung gegen einen veralteten Snapshot kann zurückgewiesen oder neu bewertet werden.

## 23. Inter-Commander Messages

Commander kommunizieren nicht direkt per freiem Chat.

```yaml
commander_message:
  message_id: string
  sender: string
  recipient: string
  channel_ref: string
  message_type: enum
  subject: string
  structured_terms: {}
  free_text_summary: string|null
  sent_at: datetime
  delivery_status: enum
  authenticity_confidence: 0..100
```

Zulässige Typen:

```text
REQUEST
OFFER
ACCEPTANCE
REJECTION
COUNTEROFFER
WARNING
PROTEST
STATUS_REPORT
INFORMATION_SHARE
TERMINATION_NOTICE
```

## 24. Failure Recovery

Bei Fehlern gilt:

```text
LLM_FAILURE -> deterministic fallback
VALIDATION_FAILURE -> repair request or fallback
DCS_FAILURE -> preserve state consistency, mark execution failure
STATE_WRITE_FAILURE -> no partial commit
ADAPTER_TIMEOUT -> reconcile against DCS events
```

Operationen und Ressourcen dürfen nach einem Fehler nicht in unbestimmten Doppelzuständen verbleiben.

## 25. Transaction Model

```text
BEGIN_STATE_TRANSACTION
-> reserve resources
-> create operation
-> append events
-> commit state version
-> dispatch execution request
```

Bei physischer Ausführung wird zwischen strategischer Commit-Phase und technischer Bestätigung unterschieden.

## 26. Security Boundaries

1. LLM-Ausgaben werden als nicht vertrauenswürdig behandelt.
2. Keine Tool-, Shell-, Lua- oder Dateianweisung aus LLM-Text wird ausgeführt.
3. Nur bekannte IDs und Enums sind zulässig.
4. Freitext wird niemals als Code interpretiert.
5. CampaignState-Zugriffe erfolgen nur über definierte Services.
6. Audit- und Promptdaten dürfen keine geheimen Zugangsdaten enthalten.
7. Modellfehler dürfen keine Ressourcen duplizieren oder löschen.

## 27. Logging und Observability

Zu protokollieren:

```text
TURN_LATENCY
MODEL_LATENCY
VALIDATION_FAILURES
REPAIR_ATTEMPTS
FALLBACK_RATE
OPERATION_SUCCESS_RATE
STATE_CONFLICTS
RESOURCE_LOCK_DURATION
DCS_ADAPTER_ERRORS
MEMORY_UPDATE_COUNT
TOKEN_USAGE
```

## 28. Testarchitektur

### Unit Tests

- Schema und Validatoren;
- Ressourcenreservierung;
- Knowledge Filtering;
- Belief Update;
- Outcome-Berechnung.

### Integration Tests

- LLM zu Operation Plan;
- Operation Plan zu DCS Adapter;
- DCS Event zu CampaignState;
- Inter-Commander-Verhandlung;
- konkurrierende Ressourcenanforderung.

### Replay Tests

Gespeicherte Turns müssen mit gleichem Seed reproduzierbar sein.

## 29. Referenzszenarien

```text
TEST-ORCH-01 Taliban route observation and ambush preparation
TEST-ORCH-02 Haqqani complex-operation capability buildup
TEST-ORCH-03 HIG parallel negotiation and local defection risk
TEST-ORCH-04 Taliban-Haqqani joint operation with separate objectives
TEST-ORCH-05 Taliban-HIG local rivalry escalation
TEST-ORCH-06 BLUE deception modifies RED beliefs
TEST-ORCH-07 simultaneous claims on same route and resource
TEST-ORCH-08 DCS execution failure and state reconciliation
TEST-ORCH-09 invalid LLM output and deterministic fallback
TEST-ORCH-10 campaign replay with identical seed
```

## 30. Technische Abnahmekriterien

Die Architektur ist erst akzeptiert, wenn:

- LLMs keinen direkten Schreibzugriff auf CampaignState besitzen;
- jeder Commander nur seine eigene View erhält;
- alle Aktionen schema- und ressourcenvalidiert werden;
- Operationen persistente Lebenszyklen besitzen;
- DCS-Events normalisiert zurückgeführt werden;
- Ressourcen atomar reserviert und freigegeben werden;
- konkurrierende Turns keine Doppelverwendung erzeugen;
- Fehler deterministisch behandelt werden;
- vollständige Replay- und Auditdaten vorhanden sind;
- MOOSE-First vor eigener Lua-Funktionalität dokumentiert geprüft wurde.

## 31. Empfohlene Implementierungsreihenfolge

```text
PHASE 1: deterministic CampaignState and event store
PHASE 2: commander-specific view builder
PHASE 3: schema validation and scripted commander decisions
PHASE 4: operation lifecycle and adjudication
PHASE 5: DCS/MOOSE adapter with one limited action type
PHASE 6: LLM gateway behind same schema
PHASE 7: memory, beliefs and information sharing
PHASE 8: multi-commander negotiations and conflicts
PHASE 9: BLUE Commander and full campaign experiments
```

Das LLM wird bewusst erst nach einer funktionierenden deterministischen Basis angeschlossen.
