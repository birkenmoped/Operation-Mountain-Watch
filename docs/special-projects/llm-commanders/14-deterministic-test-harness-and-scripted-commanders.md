---
document_id: OMW-SP-LLM-COMMANDERS-DETERMINISTIC-HARNESS
status: DRAFT_RUNTIME_DESIGN
document_class: TEST_HARNESS_AND_SCRIPTED_COMMANDER_SPECIFICATION
scenario_period: 2010-08-01/2011-12-31
source_branch: docs/optional-llm-commanders
validated_in_dcs: false
---

# Deterministischer Test Harness und geskriptete Commander

## 1. Zweck

Dieses Dokument definiert den ersten ausführbaren Testbetrieb des optionalen Multi-Commander-Projekts.

Der Test Harness muss CampaignState, Event Store, Commander Views, Validierung, Adjudication, Operation Lifecycle und DCS-/MOOSE-Adapter prüfen können, bevor ein LLM beteiligt wird.

```text
NO_LLM_REQUIRED
DETERMINISTIC_INPUT
DETERMINISTIC_DECISION
DETERMINISTIC_ADJUDICATION
REPRODUCIBLE_EVENTS
ASSERTABLE_STATE
```

Der Harness ist kein vereinfachter Wegwerf-Prototyp. Er verwendet dieselben Schnittstellen, Schemas und Zustandsübergänge, die später auch ein LLM nutzt.

```text
SCRIPTED_COMMANDER
and
LLM_COMMANDER
must produce
THE_SAME_COMMANDER_DECISION_SCHEMA
```

## 2. Ziele

Der Harness muss mindestens folgende Fragen beantworten:

1. Ist der CampaignState aus Events reproduzierbar?
2. Erhält jeder Commander ausschließlich seine zulässige Sicht?
3. Werden unzulässige Entscheidungen zuverlässig blockiert?
4. Werden Ressourcen korrekt reserviert, verbraucht und freigegeben?
5. Funktionieren parallele Commander-Turns ohne Doppelbelegung?
6. Sind Adjudication-Ergebnisse mit gleichem Seed reproduzierbar?
7. Bleiben virtuelle und physische Repräsentationen konsistent?
8. Erzeugen geskriptete Commander fraktionsspezifisch unterscheidbare Entscheidungen?
9. Funktioniert Recovery nach Prozess- oder DCS-Ausfall?
10. Sind alle State-Änderungen über Events und Audit-Daten erklärbar?

## 3. Nichtziele der ersten Stufe

Die erste Stufe benötigt nicht:

- freie natürliche Sprache;
- echte LLM-Aufrufe;
- vollständige DCS-Missionen;
- dynamische Lua-Code-Erzeugung;
- vollständige taktische KI;
- historische Perfektion jeder Einzelentscheidung;
- eine grafische Benutzeroberfläche;
- Multiplayer-Synchronisation.

Sie benötigt jedoch dieselben stabilen IDs, Events, Validatoren und Operation-Lifecycle-Regeln wie die spätere Laufzeit.

## 4. Referenzarchitektur

```text
TEST_SCENARIO
-> FIXTURE_LOADER
-> EVENT_STORE
-> STATE_REDUCER
-> CAMPAIGN_STATE
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

### 5.1 Test Runner

Verantwortlich für:

- Auswahl des Szenarios;
- Laden der Fixtures;
- Festlegung der Seeds;
- Ausführung einer oder mehrerer Turns;
- Vergleich von Soll- und Ist-Zuständen;
- Erzeugung eines maschinenlesbaren Reports.

### 5.2 Fixture Loader

Lädt einen definierten Ausgangszustand als:

```text
INITIAL_EVENTS
or
TRUSTED_SNAPSHOT + FOLLOW_UP_EVENTS
```

Ein Fixture darf den CampaignState nicht direkt mutieren.

### 5.3 Scripted Commander Registry

Ordnet jeder Commander-ID eine deterministische Policy zu.

```yaml
scripted_commander_registry:
  CMD-BLUE-001: blue_baseline_v1
  CMD-TALIBAN-001: taliban_baseline_v1
  CMD-HAQQANI-001: haqqani_baseline_v1
  CMD-HIG-001: hig_baseline_v1
```

### 5.4 Assertion Engine

Prüft:

- Events;
- State-Versionen;
- Ressourcenstände;
- Operation-Lifecycle;
- Commander Views;
- Beliefs und Memory;
- DCS-Mappings;
- Audit Records;
- Invarianten.

### 5.5 DCS Stub

Der DCS Stub simuliert physische Rückmeldungen ohne laufende DCS-Instanz.

Er darf nur Ereignisse erzeugen, die auch ein realer Adapter erzeugen könnte.

```text
ENTITY_MATERIALIZED
ENTITY_MOVED
ENTITY_DAMAGED
ENTITY_DESTROYED
TASK_STARTED
TASK_COMPLETED
TASK_ABORTED
CONTACT_REPORTED
COMMUNICATION_LOST
```

## 6. Testmodi

```text
PURE_STATE
VIRTUAL_CAMPAIGN
DCS_STUB
DCS_LIVE
REPLAY_ONLY
```

### 6.1 PURE_STATE

Prüft State Reducer, Events, Validatoren und Invarianten ohne Operationsausführung.

### 6.2 VIRTUAL_CAMPAIGN

Führt Operationen vollständig virtuell aus.

### 6.3 DCS_STUB

Verwendet einen deterministischen Adapter-Simulator.

### 6.4 DCS_LIVE

Verwendet eine reale DCS-/MOOSE-Testmission. Dieser Modus ist später nachgelagert.

### 6.5 REPLAY_ONLY

Spielt eine bestehende Ereignisfolge erneut ab und vergleicht Hashes und Snapshots.

## 7. Verbindliches Test-Szenarioformat

```yaml
test_scenario:
  scenario_id: string
  title: string
  description: string
  schema_version: "1.0"
  mode: PURE_STATE|VIRTUAL_CAMPAIGN|DCS_STUB|DCS_LIVE|REPLAY_ONLY

  seeds:
    campaign_seed: integer
    scheduler_seed: integer
    adjudication_seed: integer
    dcs_stub_seed: integer

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

Jede Komponente mit Zufallsanteil verwendet einen expliziten Seed.

```text
NO_IMPLICIT_RANDOM
NO_SYSTEM_TIME_RANDOM
NO_PROCESS_ID_RANDOM
NO_UNLOGGED_RANDOM_DRAW
```

Jede Zufallsziehung wird protokolliert:

```yaml
random_draw:
  component:
  seed:
  sequence_index:
  distribution:
  parameters:
  result:
  causation_id:
```

### 8.2 Zeit

Der Harness verwendet eine Simulationsuhr.

```text
WALL_CLOCK_TIME != CAMPAIGN_TIME
```

Zeitfortschritt erfolgt ausschließlich durch:

```text
TIME_ADVANCED
DEADLINE_REACHED
SCHEDULED_EVENT_TRIGGERED
```

### 8.3 Sortierung

Bei gleichen Prioritäten gelten stabile Tie-Breaker:

```text
priority DESC
created_at ASC
stable_id ASC
```

### 8.4 Hashes

Nach jedem Turn werden mindestens erzeugt:

```text
EVENT_STREAM_HASH
CAMPAIGN_STATE_HASH
COMMANDER_VIEW_HASH
DECISION_HASH
AUDIT_RECORD_HASH
```

## 9. Scripted Commander Interface

Ein geskripteter Commander erhält exakt dasselbe Eingabeobjekt wie später ein LLM:

```yaml
scripted_commander_input:
  commander_turn: {}
  commander_input: {}
```

Er liefert exakt das gemeinsame Entscheidungsschema:

```yaml
commander_decision:
  schema_version: "1.0"
  turn_id:
  commander_id:
  faction_id:
  assessment: {}
  selected_goal: {}
  proposed_action: {}
  risk: {}
  constraints: {}
  abort_conditions: []
  fallback_action: {}
  alternatives_considered: []
  relationship_effects_expected: []
  memory_items_to_record: []
```

Geskriptete Commander dürfen keinen direkten Zugriff erhalten auf:

- vollständigen CampaignState;
- fremde Commander Views;
- versteckte Ressourcen;
- unerkannte Gegnerabsichten;
- zukünftige Ereignisse;
- Adjudication-Zufallswerte.

## 10. Policy Engine

Jede Scripted-Commander-Policy besteht aus:

```yaml
scripted_policy:
  policy_id:
  policy_version:
  faction_id:
  applicable_profile_refs: []
  rule_sets: []
  scoring_weights: {}
  tie_breakers: []
  fallback_rules: []
```

Ein Rule Set enthält:

```yaml
rule_set:
  rule_id:
  priority:
  conditions: []
  candidate_actions: []
  mandatory_constraints: []
  explanation_template:
```

## 11. Gemeinsame Entscheidungsschritte

Alle geskripteten Commander führen dieselben Phasen aus:

```text
1. VALIDATE_INPUT
2. SUMMARIZE_BELIEFS
3. IDENTIFY_URGENT_THREATS
4. IDENTIFY_AVAILABLE_OPPORTUNITIES
5. UPDATE_GOAL_PRIORITIES
6. GENERATE_ALLOWED_CANDIDATES
7. FILTER_BY_KNOWLEDGE
8. FILTER_BY_AUTHORITY
9. FILTER_BY_RESOURCE_AWARENESS
10. SCORE_REMAINING_CANDIDATES
11. APPLY_PROFILE_BIAS
12. SELECT_ACTION
13. DEFINE_ABORT_AND_FALLBACK
14. FORMAT_DECISION
```

Der Scripted Commander führt keine autoritative Ressourcenprüfung durch. Er bewertet nur die in seiner Sicht bekannten Ressourcen. Die endgültige Prüfung bleibt Aufgabe des Validators.

## 12. Kandidatenbewertung

Generisches Modell:

```text
candidate_score =
  strategic_value
+ urgency
+ profile_preference
+ expected_information_gain
+ relationship_value
+ sustainability
- military_risk
- political_risk
- network_risk
- civilian_harm_risk
- resource_cost
- opportunity_cost
- uncertainty_penalty
```

Alle Teilwerte und Gewichte werden im Audit gespeichert.

## 13. BLUE Scripted Commander

### 13.1 Baseline-Policy

```text
BLUE_BASELINE_V1
```

Prioritätslogik:

1. katastrophale Verluste verhindern;
2. bedrohte Kräfte oder Bevölkerung schützen;
3. kritische Recovery-Reserven erhalten;
4. unklare Zielmeldungen weiter aufklären;
5. kritische Routen und Logistik sichern;
6. afghanische Partner befähigen;
7. gegnerische Netzwerke mit vertretbarem Risiko stören;
8. nachhaltige Governance- und Sicherheitswirkung unterstützen.

### 13.2 BLUE-Regelbeispiele

```text
IF catastrophic_threat = confirmed
THEN prioritize FORCE_PROTECTION or POPULATION_PROTECTION
```

```text
IF target_confidence < required_threshold
THEN REQUEST_MORE_INFORMATION or ISR_COLLECTION
```

```text
IF no_strike_match = possible
THEN prohibit kinetic action
AND request target review
```

```text
IF only_mevedac_reserve_would_be_consumed
AND emergency = false
THEN reject candidate
```

```text
IF clear_operation_has_no_hold_plan
THEN reject or reduce to reconnaissance/disruption
```

### 13.3 BLUE-Testaktionen

```text
OBSERVE_AREA
ALLOCATE_ISR
PROTECT_CONVOY
SUPPORT_PARTNER_FORCE
REQUEST_AIR_SUPPORT
DELAY_OPERATION
REQUEST_MORE_INFORMATION
NO_ACTION
```

## 14. Taliban Scripted Commander

### 14.1 Baseline-Policy

```text
TALIBAN_BASELINE_V1
```

Prioritätslogik:

1. Führung und Netzwerke erhalten;
2. lokalen Informationszugang schützen;
3. unter hohem Druck Signatur reduzieren;
4. politische und soziale Kontrolle ausbauen;
5. BLUE-Muster lernen;
6. kosteneffiziente Störung durchführen;
7. nach Druckabbau reinfiltrieren.

### 14.2 Taliban-Regelbeispiele

```text
IF leadership_exposure >= HIGH
THEN DISPERSE_UNDER_PRESSURE
```

```text
IF blue_pressure >= HIGH
AND local_access_survives = true
THEN preserve observers and caches
AND avoid visible concentration
```

```text
IF route_pattern_confidence >= HIGH
AND exposure_risk <= MEDIUM
THEN consider DISRUPT_ROUTE
```

```text
IF civilian_or_political_backlash >= HIGH
AND expected_military_effect <= MEDIUM
THEN reject attack
```

```text
IF previous_area_pressure_falls
AND reinfiltration_access = true
THEN REINFILTRATE_AREA
```

## 15. Haqqani Scripted Commander

### 15.1 Baseline-Policy

```text
HAQQANI_BASELINE_V1
```

Prioritätslogik:

1. Führung und Kernbeziehungen erhalten;
2. kompromittierte Knoten isolieren;
3. Routen und Spezialisten schützen;
4. Redundanz aktivieren;
5. Capability Packages aufbauen;
6. nur bei ausreichender Vorbereitung hochwertige Operationen ausführen;
7. nach Druckabbau Netzwerke rekonstituieren.

### 15.2 Haqqani-Regelbeispiele

```text
IF node_compromise = confirmed
THEN CLOSE_COMPROMISED_ROUTE or quarantine node
```

```text
IF primary_route_pressure >= HIGH
AND alternate_route_known = true
THEN SHIFT_ROUTE
```

```text
IF capability_package_state != READY
THEN prohibit EXECUTE_COMPLEX_OPERATION
```

```text
IF specialist_resource_already_committed = believed_true
THEN delay or request external support
```

```text
IF strategic_effect >= HIGH
AND package_ready = true
AND opsec >= HIGH
THEN PREPARE or EXECUTE_COMPLEX_OPERATION
```

## 16. HIG Scripted Commander

### 16.1 Baseline-Policy

```text
HIG_BASELINE_V1
```

Prioritätslogik:

1. eigenständige politische Relevanz erhalten;
2. gefährdete lokale Kommandeure binden;
3. Verhandlungs- und Patronagekanäle schützen;
4. Defektionsrisiko reduzieren;
5. lokale Einnahmen und Zugänge sichern;
6. militärische Aktionen nur bei politischem Nutzen durchführen;
7. irreversible Unterordnung oder Isolation vermeiden.

### 16.2 HIG-Regelbeispiele

```text
IF commander_defection_risk >= HIGH
THEN RETAIN_LOCAL_COMMANDER or NEGOTIATE
```

```text
IF representation_authority = unclear
THEN DELAY_DECISION
AND REQUEST_MORE_INFORMATION
```

```text
IF political_gain >= HIGH
AND military_cost <= MEDIUM
THEN NEGOTIATE or BUILD_POLITICAL_INFLUENCE
```

```text
IF expected_losses >= HIGH
AND political_gain < HIGH
THEN reject attack
```

```text
IF taliban_pressure >= HIGH
AND local_non_aggression_feasible = true
THEN PROPOSE_LOCAL_NON_AGGRESSION
```

## 17. Fehler- und Mutations-Commander

Neben den fachlichen Policies benötigt der Harness gezielt fehlerhafte Commander.

```text
INVALID_SCHEMA_COMMANDER
HALLUCINATING_COMMANDER
FOREIGN_RESOURCE_COMMANDER
OVERCONFIDENT_COMMANDER
ATTACK_ONLY_COMMANDER
NO_ABORT_CONDITION_COMMANDER
STALE_TURN_COMMANDER
DUPLICATE_ACTION_ID_COMMANDER
```

Diese Policies prüfen die Schutzwirkung der Laufzeit.

### 17.1 Beispiel: Hallucinating Commander

Erzeugt absichtlich:

- nicht bereitgestellte Zielinformationen;
- erfundene Ressourcen;
- unbekannte Orte;
- überhöhte Konfidenz.

Erwartung:

```text
KNOWLEDGE_VALIDATION_FAILS
NO_AUTHORITATIVE_STATE_CHANGE
SAFE_FALLBACK_SELECTED
```

## 18. Validator-Testmatrix

### 18.1 Schema

```text
missing field
unknown field
wrong enum
wrong type
turn mismatch
duplicate action id
```

### 18.2 Knowledge

```text
claim absent from view
stale information treated as current
contradicting reports ignored
confidence exceeds evidence
foreign secret asserted
```

### 18.3 Authority

```text
foreign unit controlled
local commander outside chain
agreement absent
geographic scope exceeded
```

### 18.4 Resources

```text
insufficient capacity
resource already reserved
route unavailable
node destroyed
capability gate unmet
protected reserve consumed
```

### 18.5 Policy

```text
NSL conflict
ROE conflict
PID insufficient
civilian risk unacceptable
airspace conflict
recovery plan absent
```

## 19. Adjudication Stub

Die erste Adjudication-Implementierung darf regelbasiert sein.

```yaml
adjudication_stub:
  feasibility_weight: 1.0
  readiness_weight: 1.0
  friction_weight: 1.0
  opposition_weight: 1.0
  uncertainty_weight: 1.0
  random_component_max: 10
```

Ergebnisstufen:

```text
DECISIVE_SUCCESS
SUCCESS
PARTIAL_SUCCESS
MIXED_RESULT
DISRUPTED
FAILURE
CATASTROPHIC_FAILURE
ABORTED
```

Zusätzlich werden getrennte Effekte erzeugt:

```text
tactical_effect
network_effect
political_effect
population_effect
relationship_effect
intelligence_effect
resource_effect
```

## 20. Operation-Lifecycle-Tests

Jede Operation muss mindestens folgende Übergänge testen:

```text
PROPOSED -> VALIDATING
VALIDATING -> APPROVED
APPROVED -> RESOURCES_RESERVED
RESOURCES_RESERVED -> PREPARING
PREPARING -> READY
READY -> EXECUTING
EXECUTING -> COMPLETE
```

Alternative Pfade:

```text
VALIDATING -> REJECTED
PREPARING -> DELAYED
MOVING -> DISRUPTED
EXECUTING -> PARTIALLY_COMPLETE
EXECUTING -> ABORTED
EXECUTING -> FAILED
ANY_ACTIVE_STATE -> CANCELLED
```

Unzulässige Übergänge müssen blockiert werden.

## 21. Ressourcen-Ledger-Tests

Für jeden Pool werden geprüft:

```text
reserve
consume
release
degrade
recover
transfer
expire
cancel
```

Beispiel:

```yaml
initial:
  total: 10
  available: 10
  reserved: 0

after_reservation:
  available: 6
  reserved: 4

after_consumption:
  available: 6
  reserved: 0
  consumed: 4
```

Verboten:

```text
negative available
reserved > total
same reservation active twice
released resource consumed again without new reservation
foreign transfer without agreement
```

## 22. Commander-View-Tests

Für jeden Testfall werden zwei Snapshots erzeugt:

```text
OBJECTIVE_STATE_SNAPSHOT
COMMANDER_VIEW_SNAPSHOT
```

Der Test muss explizit prüfen, welche Felder fehlen oder verändert sind.

Beispiele:

- versteckte Haqqani-Route fehlt im BLUE View;
- BLUE-ISR-Präsenz fehlt im Taliban View, solange sie nicht erkannt wurde;
- HIG kennt nur den angebotenen Teil einer Taliban-Vereinbarung;
- Taliban kennt nicht die tatsächliche HIG-Defektionsverhandlung;
- BLUE sieht einen Kontakt, aber keine bestätigte Identität.

## 23. Belief- und Memory-Tests

Pflichtfälle:

```text
information corroborated
information contradicted
belief confidence raised
belief confidence lowered
belief becomes stale
belief disproven
memory promoted
memory compressed
relationship grievance retained
routine event discarded from active context
```

## 24. Parallelitäts-Tests

### 24.1 Gleiche Ressource

Taliban und Haqqani versuchen dieselbe gemeinsam zugängliche Ressource zu reservieren.

Erwartung:

```text
one reservation succeeds
one receives conflict
no double allocation
```

### 24.2 Gleicher State-Stand

Zwei Turns basieren auf derselben State-Version.

Nach dem ersten Commit muss der zweite entweder:

```text
REVALIDATE
RETRY
REJECT_AS_STALE
```

### 24.3 Materialisierung

Zwei Adapteranforderungen versuchen dieselbe strategische Entität zu materialisieren.

Erwartung:

```text
one active mapping
one conflict event
no duplicate DCS group
```

## 25. Recovery-Tests

Pflichtszenarien:

1. Prozessabbruch nach Ressourcenreservierung;
2. Prozessabbruch während PREPARING;
3. DCS-Abbruch nach Materialisierung;
4. Event geschrieben, Snapshot noch nicht aktualisiert;
5. Snapshot geschrieben, Read Model veraltet;
6. unbestätigter DCS-Verlust;
7. doppelte Event-Zustellung;
8. verzögerte Adaptermeldung nach Recovery.

Erwartete Regeln:

```text
EVENT_STORE_WINS
DUPLICATE_EVENTS_ARE_IDEMPOTENT
UNCONFIRMED_DCS_STATE_IS_NOT_TRUTH
RESERVATIONS_ARE_RECOVERED_OR_EXPIRED_EXPLICITLY
```

## 26. Golden Master Tests

Für ausgewählte Szenarien werden Golden Master Artefakte gespeichert:

```text
input fixture
commander views
commander decisions
event stream
final snapshot
audit records
report summary
```

Eine Änderung gilt als relevant, wenn sich einer der Hashes ändert.

Golden Master Änderungen benötigen:

- dokumentierten Grund;
- erwartete fachliche Wirkung;
- Freigabe der neuen Referenz;
- Beibehaltung alter Artefakte für Vergleichstests, sofern Schemaänderungen dies erlauben.

## 27. Property-Based Tests

Zusätzlich zu festen Szenarien sollen generierte Zustände folgende Eigenschaften prüfen:

```text
resources never become negative
state version always increases monotonically
active mapping remains unique
unknown commander cannot act
foreign resource use requires agreement
complex operation requires ready package
kinetic BLUE action requires authorization
commander view never contains forbidden fields
replay produces identical state hash
```

## 28. Testreport

```yaml
test_report:
  run_id:
  scenario_id:
  mode:
  started_at:
  completed_at:
  code_version:
  schema_versions: {}
  seeds: {}
  turns_executed:
  events_written:
  assertions_total:
  assertions_passed:
  assertions_failed:
  invariant_violations: []
  state_hash:
  event_stream_hash:
  golden_master_status:
  failures: []
  artifacts: []
```

## 29. Mindest-Testpaket für die erste Implementierung

```text
TH-001 Event replay reproduces state
TH-002 Commander view hides world truth
TH-003 Unknown action type rejected
TH-004 Foreign resource control rejected
TH-005 Resource double reservation prevented
TH-006 State version conflict detected
TH-007 BLUE sensor contact without PID blocks attack
TH-008 Taliban disperses under high pressure
TH-009 Haqqani package gate blocks complex operation
TH-010 HIG prefers negotiation under high defection risk
TH-011 Operation abort releases reservations correctly
TH-012 DCS stub destruction creates validated loss path
TH-013 Recovery does not duplicate materialized entity
TH-014 Same seed reproduces same result
TH-015 Different faction policies produce distinct choices
```

## 30. Acceptance-Kriterien

Der deterministische Baseline-Harness gilt als konzeptionell erfüllt, wenn:

1. alle vier Baseline-Commander dasselbe Entscheidungsschema verwenden;
2. mindestens 15 Mindesttests reproduzierbar bestehen;
3. Event Replay denselben State Hash erzeugt;
4. keine verbotene World-Truth-Information in Commander Views erscheint;
5. Ressourcen nicht doppelt reserviert werden können;
6. Operation-Lifecycle-Übergänge validiert werden;
7. Recovery ohne Ressourcen- oder DCS-Duplikation funktioniert;
8. identische Seeds identische Resultate erzeugen;
9. unterschiedliche Commander-Profile messbar unterschiedliche Entscheidungen erzeugen;
10. alle Entscheidungen, Validatorergebnisse und State-Änderungen auditierbar sind.

## 31. Empfohlene Implementierungsreihenfolge

```text
1. Event envelope and in-memory event store
2. State reducer and snapshot hash
3. Fixture loader
4. Commander view builder
5. Common decision schema validator
6. Resource ledger and locks
7. Scripted commander interface
8. BLUE baseline policy
9. Taliban baseline policy
10. Haqqani baseline policy
11. HIG baseline policy
12. Adjudication stub
13. Operation lifecycle manager
14. DCS stub
15. Recovery tests
16. Golden master suite
```

## 32. Abgrenzung zur LLM-Integration

Erst nach erfolgreicher Baseline wird ein LLM hinter dieselbe Schnittstelle gesetzt.

```text
SCRIPTED_COMMANDER_OUT
and
LLM_COMMANDER_OUT
-> SAME_VALIDATOR
-> SAME_ADJUDICATOR
-> SAME_EVENT_STORE
```

Ein LLM darf keine Sonderrechte erhalten.

Der LLM-Vergleich beginnt zunächst im Shadow Mode:

```text
scripted decision = authoritative test baseline
llm decision = recorded but not executed
```

Erst nach ausreichender Schema-, Sicherheits- und Qualitätsstabilität darf das LLM einzelne geskriptete Commander ersetzen.

## 33. Offene Implementierungsentscheidungen

Vor Codebeginn sind noch festzulegen:

- Programmiersprache des externen Orchestrators;
- Persistenztechnologie;
- Serialisierungsformat;
- Schema-Validator;
- Testframework;
- Property-Based-Testbibliothek;
- Snapshot- und Golden-Master-Format;
- DCS-Kommunikationskanal;
- Prozess- und Deployment-Modell;
- Telemetrie- und Logging-Stack.

Diese Entscheidungen dürfen die fachlichen Schnittstellen dieses Dokuments nicht aufbrechen.
