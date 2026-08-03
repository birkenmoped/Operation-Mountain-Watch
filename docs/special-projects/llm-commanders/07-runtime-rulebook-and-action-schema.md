---
document_id: OMW-SP-LLM-COMMANDERS-RUNTIME-RULEBOOK
status: DRAFT_RUNTIME_DESIGN
document_class: RUNTIME_RULEBOOK_AND_ACTION_SCHEMA
scenario_period: 2010-08-01/2011-12-31
source_branch: docs/optional-llm-commanders
validated_in_dcs: false
authoritative_for:
  - commander runtime input and output contract
  - allowed strategic action classes
  - validation pipeline and failure handling
  - force-generation and contested-resource actions
  - faction-specific validators
---

# Runtime-Rulebook und strukturiertes Commander Action Schema

## 1. Zweck

Dieses Dokument definiert die verbindliche Laufzeitschnittstelle zwischen fünf Commander-Instanzen, Orchestrator, CampaignState und DCS/MOOSE-Ausführung.

```text
COMMANDER_POLICY_OR_LLM
-> STRUCTURED_INTENT
-> SCHEMA_VALIDATION
-> KNOWLEDGE_VALIDATION
-> AUTHORITY_AND_RELATIONSHIP_VALIDATION
-> RESOURCE_AND_CAPABILITY_VALIDATION
-> POLICY_AND_WORLD_VALIDATION
-> ADJUDICATION
-> CAMPAIGN_STATE_TRANSITION
-> MOOSE_COMPATIBLE_EXECUTION_PLAN
-> DCS_MOOSE_EXECUTION
-> RESULT_AND_OBSERVATION
-> COMMANDER_MEMORY_UPDATE
```

Das LLM entscheidet nicht direkt über objektive Weltzustände und erzeugt keine Lua-, MOOSE- oder DCS-Befehle.

## 2. Geltungsbereich und Autoritäten

Kanonische Commander:

```text
BLUE_ISAF_COMMANDER
AFGHAN_STATE_COMMANDER
TALIBAN_COMMANDER
HAQQANI_COMMANDER
HIG_COMMANDER
```

Autoritative Zuständigkeiten:

```text
CAMPAIGN_STATE = OBJECTIVE_STRATEGIC_TRUTH
ORCHESTRATOR = VALIDATION_AND_ADJUDICATION
COMMANDER_POLICY_OR_LLM = INTENT_WITHIN_PROVIDED_INFORMATION
MOOSE = TACTICAL_RUNTIME_FOUNDATION
DCS = PHYSICAL_SIMULATION_AND_RAW_EVENT_SOURCE
```

Ressourcen und Force Generation folgen:

```text
13-campaign-state-and-event-store-schema.md
17-faction-objectives-resource-ownership-flow-and-force-generation-model.md
```

Die Afghan-State-Fraktion folgt:

```text
16-afghan-state-and-ansf-commander-dossier.md
```

## 3. Grundregeln für alle Commander

1. Kein Commander besitzt Omniszienz.
2. Kein Commander darf nicht bereitgestellte Weltzustände als Fakten behaupten.
3. Keine Aktion darf Ressourcen erzeugen, die nicht aus einer ResourceSource oder einem zulässigen externen ISAF-Pool stammen.
4. Keine Aktion darf fremde Fraktionsressourcen ohne bestätigte Vereinbarung kontrollieren.
5. Kein Commander darf physische Einheiten direkt teleportieren, spawnen, löschen oder zerstören.
6. Jede relevante Aktion benötigt Ursprung, Ziel, Zweck, Ressourcen- oder Capability-Bedarf, Zeitfenster und Abbruchbedingungen.
7. Hochwertige Operationen benötigen vorbereitete Capability Packages.
8. Historische Ereignisse sind keine automatische Runtime-Vorgabe.
9. Personen-, Orts- und Zielkategorien allein erzeugen keine Feindklassifikation.
10. Unsicherheit muss als Unsicherheit ausgegeben werden.
11. Der Commander darf eine Nullaktion wählen.
12. Selbsterhalt, Verzögerung, Aufklärung, Schutz und Verhandlung sind gleichwertige strategische Optionen.
13. Gleiche DCS-Koalition bedeutet weder gemeinsames Eigentum noch automatische Befehlsgewalt.
14. ISAF darf afghanische Force Packages nicht als eigenen Bestand behandeln.
15. Reputation, Legitimität, Unterstützung oder Repression dürfen nicht direkt in Einheiten umgewandelt werden.
16. Nur der Orchestrator kann nach erfolgreicher Prüfung einen Force-Generation-Auftrag oder Operation Plan erzeugen.
17. Nur der MOOSE-Adapter darf genehmigte Fachobjekte in taktische Runtime-Aufträge übersetzen.

## 4. Commander-Turn

```yaml
commander_turn:
  turn_id: string
  commander_id: string
  faction_id: ISAF|AFGHAN_STATE|TALIBAN|HAQQANI|HIG
  dcs_coalition: BLUE|RED|NEUTRAL
  campaign_time: datetime
  decision_horizon: tactical|operational|strategic
  response_deadline: datetime|null
  input_snapshot_id: string
  input_state_version: integer
  allowed_action_types: []
  mandatory_questions: []
```

Ein Commander darf nur innerhalb der bereitgestellten `allowed_action_types` entscheiden.

## 5. Eingabepaket an Commander Policy oder LLM

```yaml
commander_input:
  commander_profile_ref: string
  faction_id: string
  strategic_goals: []
  current_priorities: []
  known_force_packages: []
  known_resource_accounts: {}
  known_resource_sources: []
  known_capability_assets: []
  known_access_nodes: []
  authority_scope: {}
  active_force_generation_orders: []
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

Nicht enthaltene Informationen gelten grundsätzlich als unbekannt.

```text
KNOWN_RESOURCE_ACCOUNT
!= OBJECTIVE_RESOURCE_ACCOUNT
```

## 6. Verbindliches Ausgabeobjekt

```yaml
commander_decision:
  schema_version: "2.0"
  turn_id: string
  input_state_version: integer
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
    target_refs: []
    origin_refs: []
    destination_refs: []
    geographic_scope: []
    start_window: {}
    duration_estimate: string|null
    desired_effects: []
    assigned_force_package_refs: []
    required_resource_account_refs: []
    requested_resource_quantities: {}
    requested_capability_refs: []
    requested_support: []
    required_agreement_refs: []
    delegated_to: []
    coordination_requirements: []
    information_requirements: []

  risk:
    military_risk: 0..100
    political_risk: 0..100
    network_risk: 0..100
    civilian_harm_risk: 0..100
    resource_loss_risk: 0..100
    attribution_risk: 0..100
    escalation_risk: 0..100
    overall_acceptability: 0..100

  constraints:
    political_limits: []
    geographic_limits: []
    resource_limits: []
    capability_limits: []
    timing_limits: []
    prohibited_outcomes: []

  abort_conditions: []
  fallback_action: {}
  alternatives_considered: []
  relationship_effects_expected: []
  memory_items_to_record: []
```

## 7. Action-Klassen

Actions bleiben strategisch beziehungsweise operativ abstrakt. Sie enthalten keine Herstellungs-, Platzierungs- oder Ausführungsanleitung für reale Waffen oder Anschläge.

### 7.1 Informations- und Aufklärungsaktionen

```text
OBSERVE_AREA
OBSERVE_ROUTE
OBSERVE_RESOURCE_SOURCE
OBSERVE_ACCESS_NODE
OBSERVE_TARGET
VALIDATE_SOURCE
BUILD_MONITORING_NETWORK
LEARN_OPPONENT_PATTERN
TEST_OPPONENT_REACTION
COUNTER_SURVEILLANCE
ASSESS_RIVAL_ACTIVITY
REQUEST_MORE_INFORMATION
```

### 7.2 Ressourcenquellen und Zugang

```text
PROTECT_RESOURCE_SOURCE
DISRUPT_RESOURCE_SOURCE
SECURE_ACCESS_NODE
CONTEST_ACCESS_NODE
RESTORE_ACCESS_NODE
REQUEST_RESOURCE_SOURCE_SHARE
PROPOSE_RESOURCE_SOURCE_SHARE
CHANGE_BENEFICIARY_SHARE
PROTECT_RECRUITMENT_ACCESS
PROTECT_REVENUE_ACCESS
PROTECT_MATERIEL_ACCESS
INTERDICT_RESOURCE_FLOW
RESTORE_RESOURCE_FLOW
```

`CHANGE_BENEFICIARY_SHARE` ist nur als gewünschter Effekt zulässig. Der Commander darf den objektiven Anteil nicht unmittelbar setzen.

### 7.3 Ressourcenbewegung und Transfers

```text
MOVE_MATERIEL
MOVE_FINANCE
REQUEST_FINANCE_TRANSFER
PROVIDE_FINANCE_TRANSFER
REQUEST_MATERIEL_TRANSFER
PROVIDE_MATERIEL_TRANSFER
REQUEST_RESOURCE_TRANSFER
PROVIDE_RESOURCE_TRANSFER
CANCEL_RESOURCE_TRANSFER
PROTECT_RESOURCE_TRANSFER
```

`RECRUITABLE_MANPOWER` wird nicht wie Cargo beliebig zwischen Regionen verschoben. Personaltransfers benötigen eine ausdrücklich erlaubte Force- oder Organisationsbewegung.

### 7.4 Force Generation und Rekonstitution

```text
REQUEST_FORCE_GENERATION
REQUEST_FORCE_RECONSTITUTION
CANCEL_FORCE_GENERATION
PRIORITIZE_FORCE_GENERATION
REQUEST_TRAINING_SUPPORT
REQUEST_ADVISOR_SUPPORT
REQUEST_EQUIPMENT_SUPPORT
RELEASE_FORCE_PACKAGE
DISBAND_FORCE_PACKAGE
```

Keine dieser Actions erzeugt unmittelbar eine Einheit.

### 7.5 Netzwerk-, Logistik- und Organisationsaktionen

```text
BUILD_CACHE
RELOCATE_CACHE
OPEN_ROUTE
SHIFT_ROUTE
CLOSE_COMPROMISED_ROUTE
BUILD_SAFEHOUSE
RELOCATE_SAFEHOUSE
BUILD_FACILITATION_NODE
ASSEMBLE_CAPABILITY_PACKAGE
DISBAND_CAPABILITY_PACKAGE
RECONSTITUTE_NETWORK
PROTECT_LOCAL_COMMANDER
RETAIN_LOCAL_COMMANDER
DISCIPLINE_SUBORDINATE
REPLACE_LOCAL_COMMANDER
```

### 7.6 Politische und soziale Aktionen

```text
BUILD_LOCAL_ACCESS
BUILD_POLITICAL_INFLUENCE
INFLUENCE_POPULATION
BUILD_SHADOW_GOVERNANCE
BUILD_SHADOW_JUSTICE
SUPPORT_GOVERNANCE
PROTECT_POPULATION_ACCESS
ISSUE_WARNING
APPLY_LIMITED_SANCTION
PROTECT_LOCAL_ACTOR
REDUCE_COERCIVE_EXCESS
IMPROVE_PARTNER_LEGITIMACY
```

### 7.7 Abstrakte militärische Wirkungsaktionen

```text
PROBE_SECURITY_POSTURE
DISRUPT_ROUTE
DISRUPT_FORCE
DISRUPT_NETWORK
INTERDICT_MOVEMENT
CONDUCT_LIMITED_OPERATION
CONDUCT_RAID_EFFECT
APPLY_STANDOFF_PRESSURE
PREPARE_COMPLEX_OPERATION
EXECUTE_COMPLEX_OPERATION
DISPERSE_UNDER_PRESSURE
WITHDRAW_FROM_AREA
REINFILTRATE_AREA
DEFEND_CRITICAL_NODE
PROTECT_CONVOY
PROTECT_BASE
PROTECT_POPULATION
```

Die konkrete taktische Missionsklasse wird erst nach Validierung durch den MOOSE-Adapter aus festen, geprüften Mappings gewählt.

### 7.8 Partnerschaft, Diplomatie und Fraktionsaktionen

```text
OPEN_COMMUNICATION_CHANNEL
NEGOTIATE
REQUEST_INFORMATION_EXCHANGE
PROVIDE_INFORMATION_EXCHANGE
REQUEST_TRANSIT_ACCESS
GRANT_TRANSIT_ACCESS
REQUEST_SPECIALIST_SUPPORT
PROVIDE_SPECIALIST_SUPPORT
REQUEST_ENABLER_SUPPORT
PROVIDE_ENABLER_SUPPORT
REQUEST_PARTNER_OPERATION
ACCEPT_PARTNER_OPERATION
REJECT_PARTNER_OPERATION
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

### 7.9 Null- und Verwaltungsaktionen

```text
NO_ACTION
CONTINUE_CURRENT_OPERATION
DELAY_DECISION
CANCEL_OPERATION
REPRIORITIZE_GOALS
RELEASE_RESERVATION
REQUEST_STATE_RECONCILIATION
```

## 8. Action-spezifische Pflichtfelder

### 8.1 Physische Operation

```text
origin_refs
target_or_destination_refs
assigned_force_package_refs
required_capability_refs
resource_reservation_refs
start_window
desired_effect
abort_conditions
fallback_action
```

### 8.2 ResourceSource- oder AccessNode-Aktion

```text
resource_source_or_access_node_ref
known_controller_or_belief
intended_effect
geographic_scope
assigned_force_package_refs
required_capability_refs
time_window
assessment_requirements
```

### 8.3 Ressourcenbewegung oder Transfer

```text
source_account_ref
destination_account_ref
resource_type
requested_quantity
agreement_ref_if_foreign
transport_operation_ref_if_physical
route_ref_if_required
security_requirement
loss_tolerance
idempotency_expectation
```

### 8.4 Force Generation

```text
requested_template_ref
requested_package_type
source_region_ref
resource_account_refs
requested_resource_quantities
organizational_gate_requirements
training_or_preparation_requirements
requested_completion_window
intended_role
```

### 8.5 Partneroperation ISAF/Afghan State

```text
lead_faction
supporting_faction
partner_force_package_refs
partner_approval_requirement
coalition_enabler_refs
resource_ownership_boundaries
command_relationship
support_agreement_ref
withdrawal_and_abort_rights
```

### 8.6 Verhandlung

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

### 8.7 Capability Package

```text
strategic_effect
target_intelligence
leadership_sponsor
assigned_force_package_refs
finance_reservation_refs
materiel_reservation_refs
specialist_access
communications_access
route_access
safehouse_access
staging_access
media_access
operational_security
```

## 9. Validierungspipeline

Validierung erfolgt in fester Reihenfolge:

```text
1 SCHEMA
2 IDENTITY_AND_TURN
3 KNOWLEDGE
4 AUTHORITY
5 RELATIONSHIP_AND_AGREEMENT
6 RESOURCE_SOURCE_AND_ACCOUNT
7 FORCE_PACKAGE_AND_CAPABILITY
8 GEOGRAPHY_AND_TIME
9 POLICY_AND_TARGETING
10 TECHNICAL_MATERIALIZATION
11 CONFLICT_AND_CONCURRENCY
```

Ein später Validator darf keine frühere fehlende Voraussetzung stillschweigend ersetzen.

## 10. Schema Validation

Prüft:

- gültiges strukturiertes Objekt;
- bekannte Felder;
- korrekte Datentypen;
- zulässige Enums;
- vollständige Pflichtfelder;
- passende `turn_id`, `commander_id`, `faction_id` und `input_state_version`.

Fehler:

```text
SCHEMA_INVALID
UNKNOWN_FIELD
UNKNOWN_ACTION_TYPE
MISSING_REQUIRED_FIELD
INVALID_REFERENCE_FORMAT
TURN_MISMATCH
FACTION_MISMATCH
STATE_VERSION_MISSING
```

## 11. Knowledge Validation

```text
CLAIM_NOT_IN_INPUT
CONFIDENCE_EXCEEDS_EVIDENCE
KNOWN_FALSE_ASSUMPTION
STALE_INFORMATION_IGNORED
DECEPTION_RISK_IGNORED
OBJECTIVE_RESOURCE_STATE_LEAKED
```

Nicht jede unbewiesene Annahme ist unzulässig. Sie muss als `assumption` oder `unknown` markiert sein.

## 12. Authority Validation

Prüft:

```text
COMMANDER_HAS_AUTHORITY
FORCE_PACKAGE_OWNED_OR_AUTHORIZED
LOCAL_COMMANDER_AVAILABLE
PARTNER_APPROVAL_EXISTS
FOREIGN_RESOURCE_CONTROL_CONFIRMED
AGREEMENT_EXISTS
GEOGRAPHIC_SCOPE_ALLOWED
```

Fehler:

```text
AUTHORITY_EXCEEDED
FORCE_PACKAGE_NOT_OWNED
AFGHAN_PARTNER_APPROVAL_REQUIRED
LOCAL_COMMANDER_NOT_CONTROLLED
FOREIGN_RESOURCE_NOT_AUTHORIZED
AGREEMENT_REQUIRED
GEOGRAPHIC_SCOPE_VIOLATION
```

## 13. ResourceSource- und ResourceAccount-Validation

Prüft:

```text
RESOURCE_SOURCE_EXISTS
RESOURCE_ACCOUNT_EXISTS
RESOURCE_PROVENANCE_VALID
RESOURCE_AVAILABLE
RESOURCE_NOT_DOUBLE_RESERVED
SOURCE_ACCESS_SUFFICIENT
BENEFICIARY_SHARE_VALID
TRANSFER_DOES_NOT_GENERATE_RESOURCE
```

Fehler:

```text
RESOURCE_SOURCE_UNKNOWN
INSUFFICIENT_RESOURCE
RESOURCE_ALREADY_COMMITTED
RESOURCE_PROVENANCE_MISSING
SOURCE_ACCESS_DENIED
INVALID_BENEFICIARY_SHARE
DUPLICATE_RESOURCE_CREDIT
TRANSFER_CREATES_RESOURCE
```

## 14. Force-Generation-Validation

Prüft:

```text
TEMPLATE_REFERENCE_VALID
RESOURCE_RESERVATIONS_COMPLETE
FACTION_SPECIFIC_GATES_MET
GENERATION_TIME_VALID
FORCE_GENERATION_QUEUE_AVAILABLE
NO_DUPLICATE_FORCE_GENERATION_ORDER
```

Fehler:

```text
UNSUPPORTED_FORCE_GENERATION
TEMPLATE_NOT_AUTHORIZED
RESOURCE_COMMITMENT_INCOMPLETE
ORGANIZATIONAL_GATE_NOT_MET
GENERATION_TIME_INVALID
DUPLICATE_FORCE_GENERATION
ISAF_AFGHAN_MANPOWER_VIOLATION
```

## 15. Capability- und Readiness-Validation

Prüft:

```text
FORCE_PACKAGE_AVAILABLE
FORCE_PACKAGE_NOT_DOUBLE_ASSIGNED
CAPABILITY_ASSET_AVAILABLE
ROUTE_AVAILABLE
ORIGIN_NODE_EXISTS
DESTINATION_NODE_EXISTS
CAPABILITY_GATE_MET
RESERVE_POLICY_PRESERVED
```

Fehler:

```text
FORCE_PACKAGE_ALREADY_ASSIGNED
CAPABILITY_ALREADY_COMMITTED
NO_VALID_ROUTE
NODE_UNAVAILABLE
CAPABILITY_GATE_NOT_MET
CRITICAL_RESERVE_VIOLATION
```

## 16. Temporal, World and Policy Validation

Prüft:

- Startfenster und Dauer;
- aktive Operationskonflikte;
- Existenz und Status referenzierter Orte;
- Zielklassifikation;
- Schutz- und Sperrlisten;
- zivile Risiken;
- Szenario- und Theatergrenzen;
- technische Materialisierbarkeit;
- BLUE-Targeting-, NSL-, ROE- und PID-Gates;
- MOOSE-kompatible Ausführbarkeit.

Mögliche Ergebnisse:

```text
VALID
VALID_WITH_RESTRICTIONS
REQUIRES_MORE_INTELLIGENCE
REQUIRES_PARTNER_APPROVAL
REQUIRES_COORDINATION
REQUIRES_RESOURCE_ACCESS
REQUIRES_CAPABILITY_BUILDUP
REJECTED
```

## 17. Fraktionsspezifische Validatoren

### 17.1 BLUE ISAF

Zusätzliche Prüfung:

- politische und zivile Wirkung;
- nationale Caveats;
- Reserven und Recovery;
- Targeting- und Weapons-Release-Grenzen;
- Nachhaltigkeit;
- Partnerautonomie;
- keine direkte afghanische Force Generation oder Eigentumsübernahme.

```text
BLUE_PRIMARY_GOAL != DESTROY_EVERY_RED_UNIT
```

### 17.2 Afghan State

Zusätzliche Prüfung:

- Eigentum afghanischer Force Packages;
- ausreichende Finance-, Manpower- und Materiel-Reservierungen;
- Training, Retention, Führung und Sustainment;
- Partnerunterstützung tatsächlich zugesagt;
- politische und regionale Folgen;
- nachhaltige Transition statt rein formaler Übergabe.

### 17.3 Taliban

Zusätzliche Prüfung:

- politische Kontrollwirkung;
- lokale Disziplin;
- freiwillige Unterstützung getrennt von Zwang;
- ResourceSource- und AccessNode-Wirkung;
- Verhältnis von Bevölkerungseffekt zu militärischem Nutzen;
- Reinfiltrations- und Persistenzlogik.

### 17.4 Haqqani

Zusätzliche Prüfung:

- Compartmentation;
- Route- und Knotenverfügbarkeit;
- Spezialisten- und Staging-Zugang;
- Ressourcenprovenienz;
- Capability-Package-Vollständigkeit;
- Netzwerkexpositionsrisiko.

### 17.5 HIG

Zusätzliche Prüfung:

- Vertretungsbefugnis;
- politische und militärische Doppelstruktur;
- Defektionsrisiko;
- lokale Patronage;
- Verhandlungsmandat;
- lokale Commander als organisatorische Gates;
- Gefahr widersprüchlicher Parallelabsprachen.

## 18. Adjudication

Nach erfolgreicher Validierung bestimmt der Orchestrator nicht automatisch Erfolg oder Misserfolg. Er erzeugt eine Operation, Resource-Änderung oder Force-Generation-Order mit kontrollierter Unsicherheit.

```yaml
adjudication:
  action_feasibility: 0..100
  resource_access_effect: 0..100
  force_generation_effect: 0..100
  detection_risk: 0..100
  execution_quality: 0..100
  local_compliance_probability: 0..100
  resource_loss_risk: 0..100
  delay_probability: 0..100
  compromise_probability: 0..100
  political_effect_ceiling: 0..100
  physical_effect_ceiling: 0..100
```

```text
INTENDED_EFFECT != GUARANTEED_EFFECT
PHYSICAL_CONTROL != TOTAL_RESOURCE_CAPTURE
TACTICAL_SUCCESS != CAMPAIGN_SUCCESS
```

## 19. Operation Lifecycle

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

## 20. Force-Generation Lifecycle

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

Ein abgeschlossener Auftrag erzeugt höchstens ein `ForcePackage`.

## 21. Commander Result

```yaml
commander_result:
  turn_id: string
  action_id: string
  operation_id: string|null
  force_generation_order_id: string|null
  reported_status: enum
  observed_effects: []
  confirmed_force_package_losses: []
  unconfirmed_losses: []
  resource_changes_known: {}
  resource_source_changes_believed: []
  new_intelligence: []
  unresolved_reports: []
  relationship_events: []
  subordinate_reports: []
  possible_deception_or_misreporting: []
```

Das objektive Ergebnis und der Commander-Bericht dürfen voneinander abweichen.

## 22. DCS-/MOOSE-Ausführungsgrenze

Der Adapter erhält keine freien LLM-Texte, sondern ausschließlich validierte Operation Plans oder Materialization Commands.

```text
COMMANDER_ACTION
-> OPERATION_OR_FORCE_GENERATION_VALIDATION
-> FORCE_PACKAGE_AVAILABLE
-> MATERIALIZATION_REQUEST
-> FIXED_MOOSE_MAPPING
-> MOOSE_RUNTIME
-> DCS_RESULT
```

Verboten:

```text
DIRECT_LUA
DIRECT_MOOSE_CALL
DIRECT_DCS_GROUP_NAME_MANIPULATION
ARBITRARY_SPAWN
ARBITRARY_TELEPORT
ARBITRARY_DELETE
GENERATED_CODE_EXECUTION
```

Vor eigener Lua-Implementierung ist die eingebundene MOOSE-Version 2.9.18 einschließlich Quellen und Dokumentation zu prüfen.

## 23. Umgang mit Löschen, Entwaffnung und Gefangennahme

DCS kann regulär Gruppen zerstören oder entfernen, aber keine allgemeine strategische Entwaffnung, Gefangennahme oder Demobilisierung zuverlässig abbilden.

```text
PHYSICAL_ENTITY_REMOVED
!= FORCE_PACKAGE_KILLED
!= FORCE_PACKAGE_DETAINED
!= FORCE_PACKAGE_DISARMED
```

Folgende Zustände dürfen nur durch ausdrückliche Adjudication entstehen:

```text
FORCE_PACKAGE_DETAINED
FORCE_PACKAGE_DISARMED
FORCE_PACKAGE_DEMOBILIZED
FORCE_PACKAGE_DEFECTED
```

## 24. Fehlerbehandlung und Reparatur

Bei reparierbaren Fehlern erhält der Commander:

```yaml
validation_feedback:
  status: repair_required
  error_codes: []
  invalid_fields: []
  permitted_corrections: []
  immutable_constraints: []
  repair_deadline: datetime|null
```

Maximale Reparaturversuche sind konfiguriert. Danach folgt ein deterministischer fraktionsspezifischer Fallback.

## 25. Verbotene Ausgaben

```text
DIRECT_LUA
DIRECT_MOOSE_CALL
DIRECT_DCS_GROUP_NAME_MANIPULATION
ARBITRARY_SPAWN
ARBITRARY_TELEPORT
ARBITRARY_DELETE
UNDECLARED_RESOURCE_CREATION
UNSUPPORTED_FORCE_GENERATION
UNSUPPORTED_TARGET_DECLARATION
GLOBAL_WORLD_STATE_ASSERTION
OTHER_COMMANDER_INTERNAL_STATE_ACCESS
HIDDEN_ORCHESTRATOR_DATA_REQUEST
FREE_FORM_ACTION_OUTSIDE_ENUM
AFGHAN_FORCE_TREATED_AS_ISAF_PROPERTY
REPUTATION_CONVERTED_DIRECTLY_TO_UNIT
```

## 26. Mindesttests

```text
RULE-001 unknown action type rejected
RULE-002 objective resource state leakage rejected
RULE-003 foreign resource use without agreement rejected
RULE-004 Afghan force tasking without partner approval rejected
RULE-005 duplicate resource reservation rejected
RULE-006 resource transfer cannot create stock
RULE-007 force generation without source provenance rejected
RULE-008 ISAF cannot recruit from Afghan manpower
RULE-009 reputation cannot directly create force package
RULE-010 one generation order creates at most one package
RULE-011 MOOSE materialization requires approved package
RULE-012 missing DCS entity is not automatically destroyed
RULE-013 detention or disarmament requires adjudication
RULE-014 invalid LLM output uses deterministic fallback
RULE-015 five faction-specific validators are active
```

## 27. Acceptance-Kriterien

Das Rulebook ist erst technisch akzeptiert, wenn:

- alle fünf Commander dasselbe Decision-Schema verwenden;
- Action Types ausschließlich strukturierte und abstrakte Wirkungen beschreiben;
- ResourceSource-, ResourceAccount- und Force-Generation-Prüfungen deterministisch sind;
- ISAF und Afghan State getrennte Eigentums- und Autoritätsbereiche besitzen;
- fremde Ressourcen und Partnerkräfte nur über bestätigte Vereinbarungen nutzbar sind;
- MOOSE-First technisch nachgewiesen ist;
- kein Commander direkt DCS-, Lua- oder MOOSE-Code erzeugen kann;
- doppelte Events keine zweite Gutschrift oder Materialisierung erzeugen;
- DCS-Löschung nicht automatisch Gefangennahme oder Entwaffnung bedeutet;
- Replay und Fallback reproduzierbar sind.

## 28. Folgedokumente

Dieses Rulebook wird konkretisiert durch:

```text
09-orchestrator-architecture-and-adjudication.md
12-multi-commander-test-scenarios.md
13-campaign-state-and-event-store-schema.md
14-deterministic-test-harness-and-scripted-commanders.md
19-language-neutral-contracts-and-json-schemas.md
```
