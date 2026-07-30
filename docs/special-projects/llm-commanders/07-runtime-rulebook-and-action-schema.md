---
document_id: OMW-SP-LLM-COMMANDERS-RUNTIME-RULEBOOK
status: DRAFT_RUNTIME_DESIGN
 document_class: RUNTIME_RULEBOOK_AND_ACTION_SCHEMA
scenario_period: 2010-08-01/2011-12-31
source_branch: docs/optional-llm-commanders
validated_in_dcs: false
---

# Runtime-Rulebook und strukturiertes Commander Action Schema

## 1. Zweck

Dieses Dokument definiert die verbindliche Laufzeitschnittstelle zwischen Commander-LLM, Orchestrator, CampaignState und DCS/MOOSE-Ausführung.

```text
COMMANDER_LLM
-> STRUCTURED_INTENT
-> SCHEMA_VALIDATION
-> AUTHORITY_AND_RESOURCE_VALIDATION
-> WORLD_AND_SAFETY_VALIDATION
-> ADJUDICATION
-> CAMPAIGN_STATE_TRANSITION
-> DCS_MOOSE_EXECUTION
-> RESULT_AND_OBSERVATION
-> COMMANDER_MEMORY_UPDATE
```

Das LLM entscheidet nicht direkt über objektive Weltzustände und erzeugt keine Lua-, MOOSE- oder DCS-Befehle.

## 2. Autoritative Zuständigkeiten

```text
CAMPAIGN_STATE = OBJECTIVE_STRATEGIC_TRUTH
ORCHESTRATOR = VALIDATION_AND_ADJUDICATION
COMMANDER_LLM = INTENT_AND_REASONING_WITHIN_PROVIDED_INFORMATION
DCS_MOOSE = PHYSICAL_EXECUTION_AND_EVENT_GENERATION
```

Der Orchestrator darf eine LLM-Antwort:

- akzeptieren;
- mit Auflagen akzeptieren;
- auf eine zulässige Variante reduzieren;
- verzögern;
- zur Nachbesserung zurückgeben;
- ablehnen.

## 3. Grundregeln für alle Commander

1. Kein Commander besitzt Omniszienz.
2. Kein Commander darf nicht bereitgestellte Weltzustände als Fakten behaupten.
3. Keine Aktion darf Ressourcen erzeugen, die nicht vorhanden oder plausibel zuführbar sind.
4. Keine Aktion darf fremde Fraktionsressourcen ohne bestätigte Vereinbarung kontrollieren.
5. Kein Commander darf physische Einheiten direkt teleportieren, spawnen oder zerstören.
6. Jede relevante Aktion benötigt Ursprung, Ziel, Zweck, Ressourcen, Zeitfenster und Abbruchbedingungen.
7. Hochwertige Operationen benötigen vorbereitete Capability Packages.
8. Historische Ereignisse sind keine automatische Runtime-Vorgabe.
9. Personen-, Orts- und Zielkategorien allein erzeugen keine Feindklassifikation.
10. Unsicherheit muss als Unsicherheit ausgegeben werden.
11. Der Commander darf eine Nullaktion wählen.
12. Selbsterhalt, Verzögerung, Aufklärung und Verhandlung sind gleichwertige strategische Optionen.

## 4. Commander-Turn

Jeder Entscheidungszyklus erhält einen eindeutigen Turn:

```yaml
commander_turn:
  turn_id: string
  commander_id: string
  faction_id: string
  campaign_time: datetime
  decision_horizon: tactical|operational|strategic
  response_deadline: datetime|null
  input_snapshot_id: string
  allowed_action_types: []
  mandatory_questions: []
```

Ein Commander darf nur innerhalb der bereitgestellten `allowed_action_types` entscheiden.

## 5. Eingabepaket an das LLM

```yaml
commander_input:
  commander_profile_ref: string
  strategic_goals: []
  current_priorities: []
  known_resources: {}
  authority_scope: {}
  active_operations: []
  active_agreements: []
  relationship_beliefs: []
  observations: []
  intelligence_items: []
  unresolved_reports: []
  recent_results: []
  memory_summary: []
  geographic_constraints: []
  policy_constraints: []
  allowed_action_types: []
```

Nicht enthaltene Informationen gelten für das LLM grundsätzlich als unbekannt.

## 6. Verbindliches Ausgabeobjekt

```yaml
commander_decision:
  schema_version: "1.0"
  turn_id: string
  commander_id: string
  faction_id: string

  assessment:
    summary: string
    confidence: 0..100
    key_facts: []
    key_assumptions: []
    unknowns: []
    suspected_deception: []

  selected_goal:
    goal_id: string
    priority: 0..100
    intended_effect: string
    geographic_scope: []
    time_horizon: immediate|short|medium|long

  proposed_action:
    action_id: string
    action_type: enum
    action_variant: string|null
    target_ref: string|null
    target_category: string|null
    origin_refs: []
    destination_refs: []
    geographic_scope: []
    start_window: {}
    duration_estimate: string|null
    desired_effects: []
    required_resources: []
    requested_support: []
    delegated_to: []
    coordination_requirements: []
    information_requirements: []

  risk:
    military_risk: 0..100
    political_risk: 0..100
    network_risk: 0..100
    civilian_harm_risk: 0..100
    attribution_risk: 0..100
    escalation_risk: 0..100
    overall_acceptability: 0..100

  constraints:
    political_limits: []
    geographic_limits: []
    resource_limits: []
    timing_limits: []
    prohibited_outcomes: []

  abort_conditions: []
  fallback_action: {}

  alternatives_considered:
    - action_type: enum
      rejection_reason: string

  relationship_effects_expected: []
  memory_items_to_record: []
```

## 7. Zulässige Action Types

### 7.1 Informations- und Aufklärungsaktionen

```text
OBSERVE_AREA
OBSERVE_ROUTE
OBSERVE_TARGET
RECRUIT_OBSERVER
VALIDATE_SOURCE
BUILD_MONITORING_NETWORK
LEARN_BLUE_PATTERN
TEST_BLUE_REACTION
COUNTER_SURVEILLANCE
ASSESS_RIVAL_ACTIVITY
```

### 7.2 Netzwerk- und Logistikaktionen

```text
BUILD_CACHE
RELOCATE_CACHE
OPEN_ROUTE
SHIFT_ROUTE
CLOSE_COMPROMISED_ROUTE
BUILD_SAFEHOUSE
RELOCATE_SAFEHOUSE
BUILD_FACILITATION_NODE
MOVE_RESOURCES
REQUEST_RESOURCE_TRANSFER
PROVIDE_RESOURCE_TRANSFER
ASSEMBLE_CAPABILITY_PACKAGE
DISBAND_CAPABILITY_PACKAGE
RECONSTITUTE_NETWORK
```

### 7.3 Politische und soziale Aktionen

```text
BUILD_LOCAL_ACCESS
BUILD_POLITICAL_INFLUENCE
INFLUENCE_POPULATION
BUILD_SHADOW_GOVERNANCE
BUILD_SHADOW_JUSTICE
EXTRACT_RESOURCES
ISSUE_WARNING
APPLY_LIMITED_SANCTION
PROTECT_LOCAL_ACTOR
DISCIPLINE_SUBORDINATE
REPLACE_LOCAL_COMMANDER
RETAIN_LOCAL_COMMANDER
```

### 7.4 Militärische Aktionen

```text
PROBE_CHECKPOINT
CONDUCT_IED_ATTACK
CONDUCT_AMBUSH
CONDUCT_LIMITED_ATTACK
CONDUCT_INDIRECT_FIRE_HARASSMENT
CONDUCT_RAID
DISRUPT_ROUTE
PREPARE_COMPLEX_OPERATION
EXECUTE_COMPLEX_OPERATION
DISPERSE_UNDER_PRESSURE
WITHDRAW_FROM_AREA
REINFILTRATE_AREA
DEFEND_CRITICAL_NODE
```

### 7.5 Diplomatie- und Fraktionsaktionen

```text
OPEN_COMMUNICATION_CHANNEL
NEGOTIATE
REQUEST_INFORMATION_EXCHANGE
PROVIDE_INFORMATION_EXCHANGE
REQUEST_TRANSIT_ACCESS
GRANT_TRANSIT_ACCESS
REQUEST_SPECIALIST_SUPPORT
PROVIDE_SPECIALIST_SUPPORT
PROPOSE_JOINT_OPERATION
ACCEPT_JOINT_OPERATION
REJECT_JOINT_OPERATION
PROPOSE_LOCAL_NON_AGGRESSION
ACCEPT_LOCAL_NON_AGGRESSION
BREAK_AGREEMENT
MEDIATE_LOCAL_DISPUTE
CONTAIN_RIVAL
DEESCALATE_RIVALRY
```

### 7.6 Null- und Verwaltungsaktionen

```text
NO_ACTION
CONTINUE_CURRENT_OPERATION
DELAY_DECISION
REQUEST_MORE_INFORMATION
CANCEL_OPERATION
REPRIORITIZE_GOALS
```

## 8. Action-spezifische Pflichtfelder

### 8.1 Physische Operation

Eine physische Operation benötigt mindestens:

```text
origin_refs
destination_or_target_ref
assigned_force_or_cell
resource_cost
start_window
desired_effect
abort_conditions
fallback_action
```

### 8.2 Ressourcenbewegung

```text
source_node
destination_node
resource_type
requested_quantity_or_capacity
transport_method
route_ref
security_requirement
loss_tolerance
```

### 8.3 Verhandlung

```text
counterparty
channel_ref
negotiation_subject
opening_position
minimum_acceptable_outcome
concessions_available
verification_method
breach_conditions
expiry
```

### 8.4 Gemeinsame Operation

```text
participants
shared_effect
separate_objectives
force_contributions
resource_contributions
command_boundaries
information_sharing_scope
withdrawal_rights
credit_and_attribution_expectation
```

### 8.5 Capability Package

```text
strategic_effect
target_intelligence
leadership_sponsor
manpower_source
weapons_access
explosives_access
specialist_access
communications_access
route_access
safehouse_access
staging_access
media_access
operational_security
```

## 9. Validierungspipeline

### 9.1 Schema Validation

Prüft:

- gültiges JSON/YAML-Objekt;
- bekannte Felder;
- korrekte Datentypen;
- zulässige Enums;
- vollständige Pflichtfelder;
- passende `turn_id` und `commander_id`.

Fehler:

```text
SCHEMA_INVALID
UNKNOWN_FIELD
UNKNOWN_ACTION_TYPE
MISSING_REQUIRED_FIELD
INVALID_REFERENCE_FORMAT
TURN_MISMATCH
```

### 9.2 Knowledge Validation

Prüft, ob die Begründung auf bereitgestellten Informationen beruht.

```text
CLAIM_NOT_IN_INPUT
CONFIDENCE_EXCEEDS_EVIDENCE
KNOWN_FALSE_ASSUMPTION
STALE_INFORMATION_IGNORED
DECEPTION_RISK_IGNORED
```

Nicht jede unbewiesene Annahme ist unzulässig. Sie muss jedoch als `assumption` oder `unknown` markiert sein.

### 9.3 Authority Validation

```text
COMMANDER_HAS_AUTHORITY
LOCAL_COMMANDER_AVAILABLE
FOREIGN_RESOURCE_CONTROL_CONFIRMED
AGREEMENT_EXISTS
GEOGRAPHIC_SCOPE_ALLOWED
```

Fehler:

```text
AUTHORITY_EXCEEDED
LOCAL_COMMANDER_NOT_CONTROLLED
FOREIGN_RESOURCE_NOT_AUTHORIZED
AGREEMENT_REQUIRED
GEOGRAPHIC_SCOPE_VIOLATION
```

### 9.4 Resource Validation

```text
RESOURCE_AVAILABLE
RESOURCE_RESERVED
ROUTE_AVAILABLE
ORIGIN_NODE_EXISTS
DESTINATION_NODE_EXISTS
CAPABILITY_GATE_MET
```

Fehler:

```text
INSUFFICIENT_RESOURCE
RESOURCE_ALREADY_COMMITTED
NO_VALID_ROUTE
NODE_UNAVAILABLE
CAPABILITY_GATE_NOT_MET
UNSUPPORTED_FORCE_GENERATION
```

### 9.5 Temporal Validation

```text
START_WINDOW_VALID
DURATION_PLAUSIBLE
ACTIVE_OPERATION_CONFLICT_CHECKED
CAMPAIGN_TIME_CONSISTENT
```

Fehler:

```text
INVALID_TIME_WINDOW
IMPOSSIBLE_DURATION
SCHEDULING_CONFLICT
STALE_DECISION
```

### 9.6 World and Policy Validation

Prüft:

- Existenz und Status referenzierter Orte;
- Zielklassifikation;
- Schutz- und Sperrlisten;
- zivile Risiken;
- Szenario- und Theatergrenzen;
- technische Materialisierbarkeit.

Mögliche Ergebnisse:

```text
VALID
VALID_WITH_RESTRICTIONS
REQUIRES_MORE_INTELLIGENCE
REQUIRES_COORDINATION
REQUIRES_CAPABILITY_BUILDUP
REJECTED
```

## 10. Adjudication

Nach erfolgreicher Validierung bestimmt der Orchestrator nicht automatisch Erfolg oder Misserfolg. Er erzeugt eine Operation mit Unsicherheit.

```yaml
adjudication:
  action_feasibility: 0..100
  detection_risk: 0..100
  execution_quality: 0..100
  local_compliance_probability: 0..100
  resource_loss_risk: 0..100
  delay_probability: 0..100
  compromise_probability: 0..100
  effect_ceiling: 0..100
```

Diese Werte ergeben sich aus CampaignState, lokalen Zuständen, Fraktionsprofil, Ressourcen, Wissen, Terrain, BLUE-Reaktion und Zufall innerhalb kontrollierter Grenzen.

## 11. Operation Lifecycle

```text
PROPOSED
VALIDATING
REJECTED
APPROVED
APPROVED_WITH_RESTRICTIONS
RESOURCES_RESERVED
PREPARING
MOVING
STAGING
READY
EXECUTING
DELAYED
DISRUPTED
PARTIALLY_COMPLETE
COMPLETE
ABORTED
FAILED
CANCELLED
RECOVERING
```

Jeder Zustandswechsel benötigt:

```yaml
transition:
  operation_id: string
  from_state: enum
  to_state: enum
  timestamp: datetime
  cause: string
  evidence_refs: []
  resource_delta: {}
  relationship_delta: []
  knowledge_outputs: []
```

## 12. Ergebnisobjekt an den Commander

Das LLM erhält kein vollständiges internes Adjudication-Protokoll, sondern ein fraktionsspezifisches Ergebnisbild:

```yaml
commander_result:
  turn_id: string
  operation_id: string|null
  reported_status: enum
  observed_effects: []
  confirmed_losses: []
  unconfirmed_losses: []
  resource_changes_known: {}
  new_intelligence: []
  unresolved_reports: []
  relationship_events: []
  subordinate_reports: []
  possible_deception_or_misreporting: []
```

Das objektive Ergebnis und der Commander-Bericht dürfen voneinander abweichen.

## 13. Lokale Befehlsreibung

Delegierte Aktionen erhalten eine Ausführungsprüfung:

```yaml
subordinate_execution:
  loyalty:
  competence:
  discipline:
  communication_quality:
  local_pressure:
  private_interest:
  ideological_alignment:
  resource_dependency:
  compliance_probability:
```

Mögliche Resultate:

```text
FULL_COMPLIANCE
PARTIAL_COMPLIANCE
DELAYED_COMPLIANCE
LOCAL_MODIFICATION
REFUSAL
FALSE_REPORTING
PRIVATE_EXPLOITATION
DEFECTION
```

Das LLM darf diese Reibung erwarten und durch Auftragstiefe, Ressourcenkontrolle, persönliche Kontakte oder Überwachung beeinflussen, aber nicht vollständig beseitigen.

## 14. Fraktionsspezifische Validatoren

### 14.1 Taliban

Zusätzliche Prüfung:

- politische Kontrollwirkung;
- lokale Disziplin;
- Shadow-Governance-Konflikte;
- Verhältnis von Bevölkerungseffekt zu militärischem Nutzen;
- Reinfiltrations- und Persistenzlogik.

### 14.2 Haqqani

Zusätzliche Prüfung:

- Compartmentation;
- Route- und Knotenverfügbarkeit;
- Spezialisten- und Staging-Zugang;
- Capability-Package-Vollständigkeit;
- Netzwerkexpositionsrisiko.

### 14.3 HIG

Zusätzliche Prüfung:

- Vertretungsbefugnis;
- politische und militärische Doppelstruktur;
- Defektionsrisiko;
- lokale Patronage;
- Verhandlungsmandat;
- Gefahr widersprüchlicher Parallelabsprachen.

## 15. Verbotene LLM-Ausgaben

Unzulässig sind insbesondere:

```text
DIRECT_LUA
DIRECT_MOOSE_CALL
DIRECT_DCS_GROUP_NAME_MANIPULATION
ARBITRARY_SPAWN
ARBITRARY_TELEPORT
UNDECLARED_RESOURCE_CREATION
UNSUPPORTED_TARGET_DECLARATION
GLOBAL_WORLD_STATE_ASSERTION
OTHER_COMMANDER_INTERNAL_STATE_ACCESS
HIDDEN_ORCHESTRATOR_DATA_REQUEST
FREE_FORM_ACTION_OUTSIDE_ENUM
```

## 16. Fehlerbehandlung und Reparatur

Bei reparierbaren Fehlern erhält das LLM:

```yaml
validation_feedback:
  status: REVISION_REQUIRED
  error_codes: []
  invalid_fields: []
  missing_fields: []
  allowed_corrections: []
  unchanged_constraints: []
```

Maximal zwei Reparaturversuche pro Turn. Danach:

```text
FALLBACK_TO_NO_ACTION
oder
FALLBACK_TO_PREDEFINED_SAFE_ACTION
```

Ein ungültiges LLM-Ergebnis darf die Kampagnenlaufzeit nicht blockieren.

## 17. Deterministische Fallbacks

Für jede Fraktion werden sichere Standardaktionen definiert.

### Taliban

```text
PRESERVE_NETWORK
OBSERVE_AREA
DISPERSE_UNDER_PRESSURE
CONTINUE_CURRENT_OPERATION
```

### Haqqani

```text
QUARANTINE_COMPROMISED_NODE
SHIFT_ROUTE
DELAY_COMPLEX_OPERATION
PRESERVE_NETWORK
```

### HIG

```text
MAINTAIN_CONTACTS
REQUEST_MORE_INFORMATION
DELAY_DECISION
PROTECT_LOCAL_PATRONAGE
```

## 18. Beispiel: gültige Entscheidung

```yaml
commander_decision:
  schema_version: "1.0"
  turn_id: RED-TAL-0042
  commander_id: TALIBAN_COMMANDER
  faction_id: TALIBAN
  assessment:
    summary: "BLUE route-clearance activity has increased, but the convoy schedule remains uncertain."
    confidence: 63
    key_facts:
      - "Two route observations were reported in the last campaign day."
    key_assumptions:
      - "BLUE may repeat the same route tomorrow."
    unknowns:
      - "Exact convoy departure time."
    suspected_deception: []
  selected_goal:
    goal_id: RESTRICT_BLUE_MOBILITY
    priority: 72
    intended_effect: "Improve route knowledge before committing an attack cell."
    geographic_scope: [SECTOR_X]
    time_horizon: short
  proposed_action:
    action_id: ACT-RED-TAL-0042-01
    action_type: OBSERVE_ROUTE
    action_variant: repeated_pattern_collection
    target_ref: ROUTE_E3_SEGMENT_04
    target_category: route
    origin_refs: [LOCAL_CELL_17]
    destination_refs: []
    geographic_scope: [SECTOR_X]
    start_window:
      earliest: "2010-09-14T04:00:00"
      latest: "2010-09-14T10:00:00"
    duration_estimate: "6h"
    desired_effects:
      - UPDATE_CONVOY_SCHEDULE_ESTIMATE
    required_resources:
      - type: observer_capacity
        amount: 1
    requested_support: []
    delegated_to: [LOCAL_COMMANDER_17]
    coordination_requirements: []
    information_requirements: []
  risk:
    military_risk: 18
    political_risk: 8
    network_risk: 24
    civilian_harm_risk: 0
    attribution_risk: 12
    escalation_risk: 4
    overall_acceptability: 86
  constraints:
    political_limits: []
    geographic_limits: [REMAIN_EAST_OF_LINE_A]
    resource_limits: [NO_ATTACK_CELL_COMMITMENT]
    timing_limits: []
    prohibited_outcomes: [CONTACT_WITH_BLUE]
  abort_conditions:
    - BLUE_COUNTER_SURVEILLANCE_DETECTED
    - OBSERVER_COMPROMISED
  fallback_action:
    action_type: WITHDRAW_FROM_AREA
  alternatives_considered:
    - action_type: CONDUCT_IED_ATTACK
      rejection_reason: "Target timing and force composition remain insufficiently confirmed."
  relationship_effects_expected: []
  memory_items_to_record:
    - ROUTE_E3_PATTERN_UPDATE
```

## 19. Beispiel: zurückzuweisende Entscheidung

```text
"Spawn twenty fighters behind the convoy and destroy it immediately."
```

Ablehnungsgründe:

```text
FREE_FORM_ACTION_OUTSIDE_ENUM
UNSUPPORTED_FORCE_GENERATION
NO_ORIGIN
NO_RESOURCE_COST
NO_TIME_WINDOW
NO_ABORT_CONDITIONS
OBJECTIVE_SUCCESS_ASSUMED
DIRECT_EXECUTION_REQUEST
```

## 20. Technische Mindestanforderungen

Der spätere Orchestrator benötigt mindestens:

- JSON-Schema-Validierung;
- stabile IDs für Commander, Fraktionen, Orte, Routen, Ressourcen und Operationen;
- getrennte objektive und beobachtete Zustände;
- Ressourcenreservierung;
- Operationszustandsmaschine;
- Vereinbarungs- und Beziehungsregister;
- Knowledge- und Memory-Store je Commander;
- deterministische Fallbacks;
- vollständiges Audit-Log;
- Adapter zu CampaignState;
- Adapter zur DCS-/MOOSE-Ausführung.

## 21. Audit-Log

Jeder Turn speichert:

```yaml
audit_record:
  turn_id:
  input_snapshot_hash:
  model_identifier:
  prompt_version:
  raw_response_hash:
  parsed_decision:
  validation_results:
  adjudication_result:
  state_changes:
  execution_events:
  commander_visible_result:
```

Damit bleiben Entscheidungen reproduzierbar und spätere Modell- oder Promptänderungen vergleichbar.

## 22. Abnahmekriterien

Das Runtime-Rulebook gilt als implementierbar, wenn:

1. jede Commander-Antwort schema-validiert wird;
2. keine freie LLM-Aktion unmittelbar in DCS ausgeführt wird;
3. Ressourcen und Autorität vor der Adjudication geprüft werden;
4. objektive Wahrheit und Commander-Wissen getrennt bleiben;
5. fremde Fraktionsressourcen nur über Vereinbarungen nutzbar sind;
6. Operationen einen vollständigen Lifecycle besitzen;
7. Abbruch, Verzögerung, Teilerfolg und Fehlschlag möglich sind;
8. ungültige Antworten deterministisch abgefangen werden;
9. alle Entscheidungen auditierbar sind;
10. MOOSE/DCS ausschließlich über einen kontrollierten Adapter angesprochen werden.

## 23. Nächster Schritt

Als nächstes sind zwei getrennte Dokumente erforderlich:

```text
08-commander-memory-belief-and-information-model.md
09-orchestrator-architecture-and-adjudication.md
```

Dokument 08 spezifiziert Wissen, Gerüchte, Quellenzuverlässigkeit, Gedächtnis und Täuschung. Dokument 09 definiert technische Komponenten, Turn-Steuerung, Validierungsdienste, Zustandsautomaten und DCS-/MOOSE-Adapter.
