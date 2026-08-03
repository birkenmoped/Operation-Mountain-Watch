---
document_id: OMW-SP-LLM-COMMANDERS-LANGUAGE-NEUTRAL-CONTRACTS
status: DRAFT_RUNTIME_CONTRACT
document_class: LANGUAGE_NEUTRAL_CONTRACT_AND_JSON_SCHEMA_BASELINE
scenario_period: 2010-08-01/2011-12-31
source_branch: docs/optional-llm-commanders
validated_in_dcs: false
authoritative_for:
  - language-neutral runtime message contracts
  - JSON Schema baseline and schema-registry policy
  - contract versioning compatibility and canonical hashing
  - commander orchestrator and DCS/MOOSE adapter boundaries
  - EventEnvelope CommanderView CommanderDecision and OperationPlan contracts
  - resource force-generation cargo adapter and audit contracts
---

# Sprachneutrale Runtime-Verträge und JSON-Schema-Baseline

## 1. Zweck

Dieses Dokument definiert die sprachneutralen Verträge zwischen:

```text
SCRIPTED_COMMANDER_OR_LLM
EXTERNAL_ORCHESTRATOR
CAMPAIGN_STATE_AND_EVENT_STORE
RESOURCE_AND_FORCE_GENERATION_SERVICES
DCS_MOOSE_ADAPTER
MOOSE_RUNTIME
AUDIT_AND_TEST_HARNESS
```

Die Verträge müssen unabhängig davon identisch interpretierbar sein, ob der Orchestrator später in Python, Elixir oder einer anderen geeigneten Laufzeit implementiert wird.

Verbindliche Grundregel:

```text
SAME_CONTRACT
-> SAME_SEMANTICS
-> SAME_VALIDATION_RESULT
-> SAME_CANONICAL_HASH
```

Dieses Dokument konkretisiert insbesondere:

- `02-common-commander-model.md`;
- `07-runtime-rulebook-and-action-schema.md`;
- `09-orchestrator-architecture-and-adjudication.md`;
- `11-blue-mission-demand-force-allocation-and-targeting-schema.md`;
- `13-campaign-state-and-event-store-schema.md`;
- `14-deterministic-test-harness-and-scripted-commanders.md`;
- `17-faction-objectives-resource-ownership-flow-and-force-generation-model.md`;
- die verbindliche Hauptprojektlogistik aus `docs/05-logistics.md`.

Es erzeugt noch keine Produktionsruntime und keine akzeptierte MOOSE- oder DCS-Implementierung.

## 2. Nicht verhandelbare Grenzen

```text
LLM_OUTPUT = UNTRUSTED_DATA
LLM_OUTPUT != LUA
LLM_OUTPUT != MOOSE_METHOD_CALL
LLM_OUTPUT != DCS_COMMAND
```

```text
ORCHESTRATOR
-> validates and adjudicates domain intent

DCS_MOOSE_ADAPTER
-> translates approved domain objects through fixed reviewed mappings

MOOSE
-> owns tactical mission and group execution
```

Nicht zulässig sind Vertragsfelder für:

```text
arbitrary_lua
script_body
method_name_from_llm
shell_command
code_to_execute
free_form_dcs_command
```

Freitextfelder dienen ausschließlich Erklärung, Audit oder Commander-Einschätzung. Sie besitzen niemals ausführbare Semantik.

## 3. Normative Begriffe

In diesem Dokument gelten:

```text
MUST      = verbindlich erforderlich
MUST NOT  = verbindlich verboten
SHOULD    = Regelfall; Abweichung benötigt dokumentierte Begründung
MAY       = optional zulässig
```

Kanonische Vertragsnamen und Enum-Werte werden in `UPPER_SNAKE_CASE` geschrieben. JSON-Eigenschaftsnamen verwenden grundsätzlich `lower_snake_case`.

Ausnahme:

```text
CargoManifest
```

behält die in `docs/05-logistics.md` verbindlich festgelegten Feldnamen in `camelCase`.

## 4. Vertragssuite

Version 1 umfasst mindestens:

```text
SCHEMA_REGISTRY_ENTRY
EVENT_ENVELOPE
COMMANDER_VIEW
COMMANDER_DECISION
OPERATION_PLAN
RESOURCE_RESERVATION
RESOURCE_TRANSFER
FORCE_GENERATION_ORDER
FORCE_PACKAGE
ADAPTER_COMMAND
ADAPTER_RESULT
CARGO_MANIFEST
AUDIT_RECORD
CONTRACT_ERROR
```

Die vollständigen internen CampaignState-Aggregate bleiben in Dokument 13 definiert. Dieses Dokument legt ihre sprachneutralen Transport-, Persistenz- und Integrationsgrenzen fest.

## 5. JSON-Schema-Baseline

Projektbaseline:

```text
JSON Schema Draft 2020-12
```

Jedes maschinenlesbare Schema MUSS enthalten:

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "urn:omw:schema:<contract-name>:<semantic-version>",
  "title": "...",
  "type": "object"
}
```

Diese Festlegung ist eine Projektentscheidung. Sie behauptet nicht, dass Draft 2020-12 zu jedem späteren Zeitpunkt der jeweils neueste veröffentlichte Standard ist.

Verbindlich:

```text
NO_IMPLICIT_SCHEMA
NO_SCHEMA_BY_FILENAME_ONLY
NO_ACCEPT_LATEST
EXACT_SCHEMA_RESOLUTION_REQUIRED
```

Jede Nachricht oder jeder persistierte Vertrag verweist auf eine genaue Schema-ID und Version.

## 6. Schema Registry

### 6.1 Registry-Eintrag

```yaml
schema_registry_entry:
  contract_name: string
  schema_version: semver
  schema_ref: urn
  schema_sha256: string
  validation_fingerprint: string
  status: draft|active|deprecated|retired
  effective_from: datetime
  deprecated_from: datetime|null
  predecessor_refs: []
  compatible_with: []
  upcaster_refs: []
  owner_document_id: string
```

### 6.2 Registry-Regeln

1. Ein Schema wird über `schema_ref` exakt aufgelöst.
2. Ein unbekanntes Major-Schema wird abgelehnt.
3. Ein unbekanntes Minor-Schema wird standardmäßig abgelehnt, bis die Registry ausdrückliche Kompatibilität bestätigt.
4. Ein Patch-Update darf nur Annotationen, Beispiele oder nicht semantische Metadaten ändern.
5. Der Schema-Hash wird vor Aktivierung geprüft.
6. Persistierte Events werden niemals rückwirkend überschrieben.
7. Alte Event-Payloads dürfen durch versionierte Upcaster lesbar gemacht werden.
8. Upcaster erzeugen eine Lesedarstellung; sie verändern nicht den originalen Event Store.

## 7. Versions- und Kompatibilitätspolitik

Schema-Versionen verwenden:

```text
MAJOR.MINOR.PATCH
```

### 7.1 Patch

Zulässig:

- Beschreibung verbessern;
- Beispiele ergänzen;
- Kommentare korrigieren;
- keine Änderung der zulässigen Instanzmenge.

### 7.2 Minor

Zulässig:

- neue optionale Felder;
- neue optionale Vertragsvarianten;
- neue nicht verpflichtende Metadaten.

Wegen der strikten Schemas muss ein Consumer die neue Minor-Version ausdrücklich aus der Registry kennen. Unbekannte Felder werden nicht stillschweigend ignoriert.

### 7.3 Major

Erforderlich bei:

- neuem Pflichtfeld;
- Entfernen oder Umbenennen eines Feldes;
- Typänderung;
- Änderung einer Feldsemantik;
- Änderung einer Statusmaschine;
- geschlossenem Enum mit neuen Werten, wenn alte Consumer keine Unknown-Strategie besitzen;
- Änderung von ID-, Zeit-, Mengen- oder Hashregeln.

Verbindlich:

```text
FIELD_RENAME = MAJOR_CHANGE
SEMANTIC_REINTERPRETATION = MAJOR_CHANGE
SILENT_DEFAULT_CHANGE = PROHIBITED
```

## 8. Gemeinsame Datentypen

### 8.1 Stabile IDs

IDs sind ASCII-Zeichenketten mit Typpräfix.

Beispiele:

```text
CMP-...
CMD-...
FAC-...
EVT-...
OPR-...
RSC-...
RAC-...
RSV-...
RTX-...
FGN-...
FPG-...
MAP-...
AUD-...
```

Neue Laufzeitobjekte SHOULD einen zeitlich sortierbaren, kollisionsresistenten Suffix verwenden. Menschlich lesbare Fixture-IDs bleiben für Tests zulässig.

Basismuster:

```regex
^[A-Z][A-Z0-9_]{1,31}-[A-Z0-9][A-Z0-9._-]{0,95}$
```

IDs sind opak. Consumer dürfen aus ihnen keine fachliche Wahrheit ableiten.

```text
ID_PREFIX = TYPE_HINT_ONLY
ID_CONTENT != AUTHORITY
ID_CONTENT != OWNERSHIP
```

### 8.2 Zeit

Alle absoluten Zeitwerte verwenden UTC und enden mit `Z`.

Projektprofil:

```text
YYYY-MM-DDTHH:MM:SS.sssZ
```

Beispiel:

```text
2026-08-03T14:20:00.000Z
```

Campaign-Zeit und Wall-Clock-Zeit bleiben getrennt.

```text
CAMPAIGN_TIME != WALL_CLOCK_TIME
```

Dauern werden als nichtnegative ganzzahlige Sekunden geführt:

```yaml
duration_seconds: integer >= 0
```

### 8.3 Mengen

Version 1 verwendet für autoritative Ressourcenmengen ausschließlich nichtnegative ganze Kampagneneinheiten.

```text
NO_FLOATING_RESOURCE_QUANTITY
NO_NAN
NO_INFINITY
```

Die tatsächliche Bedeutung einer Einheit wird durch `resource_type`, `resource_catalog_ref` und die jeweilige Szenariokonfiguration definiert.

```yaml
quantity_units: integer >= 0
```

Prozentuale Anteile in Transportverträgen werden als Basis Points geführt:

```text
0..10000
```

```text
10000 = 100 percent
```

Die konzeptionellen Werte `0..100` aus den Fachtexten werden beim Transport exakt in Basis Points konvertiert.

### 8.4 Confidence, Risiko und Zustandswerte

```yaml
score_0_100: integer minimum 0 maximum 100
```

Ein Score ist keine Wahrscheinlichkeit, sofern das jeweilige Feld dies nicht ausdrücklich festlegt.

### 8.5 Null und fehlende Werte

Verbindlich:

```text
ABSENT = field not applicable or not supplied
NULL = explicitly no value where schema permits
UNKNOWN = explicit domain state
EMPTY_ARRAY = known to contain no entries
```

`null` darf nicht als allgemeiner Ersatz für `UNKNOWN` verwendet werden.

Arrays werden nie als `null` übertragen. Unbekannte Lageinformationen werden als strukturierte Beliefs oder Knowledge States ausgedrückt.

### 8.6 Strikte Objekte

Wire- und Persistenzverträge verwenden grundsätzlich:

```json
"additionalProperties": false
```

Erweiterungen erfolgen ausschließlich über:

```yaml
extensions:
  urn:omw:extension:<owner>:<name>: {}
```

Ein Extension-Key MUSS namensraumqualifiziert sein. Extensions dürfen keine Pflichtlogik umgehen und keine ausführbaren Inhalte enthalten.

## 9. Gemeinsamer Nachrichtenkopf

Alle interprozessual übertragenen Verträge enthalten mindestens:

```yaml
contract_name: string
schema_version: semver
schema_ref: urn
message_id: string
campaign_id: string
correlation_id: string
causation_id: string|null
idempotency_key: string
created_at: datetime
producer:
  component: string
  version: string
  instance_id: string
payload_hash: sha256
extensions: {}
```

### 9.1 Semantik

- `message_id` identifiziert eine konkrete Nachricht.
- `idempotency_key` identifiziert den fachlichen Effekt, der höchstens einmal angewandt werden darf.
- `correlation_id` verbindet einen vollständigen Workflow.
- `causation_id` verweist auf die unmittelbar auslösende Nachricht oder das auslösende Event.
- `payload_hash` schützt die kanonische Payload.
- `producer` wird vom technischen Absender gesetzt, nicht vom Commander-LLM.

## 10. EventEnvelope

### 10.1 Zweck

`EVENT_ENVELOPE` ist der unveränderliche persistente Vertrag für fachliche Zustandsänderungen.

### 10.2 Pflichtfelder

```yaml
event_envelope:
  contract_name: EVENT_ENVELOPE
  schema_version: string
  schema_ref: string
  message_id: string
  event_id: string
  idempotency_key: string
  campaign_id: string
  event_sequence: integer
  event_type: string
  aggregate_type: string
  aggregate_id: string
  aggregate_version: integer
  expected_state_version: integer|null
  resulting_state_version: integer
  occurred_at: datetime
  effective_at: datetime
  recorded_at: datetime
  actor:
    actor_type: commander|orchestrator|validator|adjudicator|adapter|dcs|moose|operator|system
    actor_ref: string|null
  correlation_id: string
  causation_id: string|null
  payload_schema_ref: string
  payload: object
  payload_hash: string
  producer: object
  metadata: object
  extensions: object
```

### 10.3 Invarianten

```text
EVENT_ID_IMMUTABLE
EVENT_SEQUENCE_MONOTONIC_PER_CAMPAIGN
AGGREGATE_VERSION_MONOTONIC_PER_AGGREGATE
PAYLOAD_VALIDATES_AGAINST_PAYLOAD_SCHEMA_REF
PAYLOAD_HASH_MATCHES_CANONICAL_PAYLOAD
RESULTING_STATE_VERSION > EXPECTED_STATE_VERSION when expected exists
```

Eine erneute Übertragung desselben Events darf eine neue `message_id` besitzen, behält aber dieselbe `event_id` und denselben fachlichen Inhalt.

### 10.4 JSON-Schema-Kern

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "urn:omw:schema:event-envelope:1.0.0",
  "title": "OMW EventEnvelope",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "contract_name",
    "schema_version",
    "schema_ref",
    "message_id",
    "event_id",
    "idempotency_key",
    "campaign_id",
    "event_sequence",
    "event_type",
    "aggregate_type",
    "aggregate_id",
    "aggregate_version",
    "resulting_state_version",
    "occurred_at",
    "effective_at",
    "recorded_at",
    "actor",
    "correlation_id",
    "payload_schema_ref",
    "payload",
    "payload_hash",
    "producer",
    "metadata",
    "extensions"
  ],
  "properties": {
    "contract_name": { "const": "EVENT_ENVELOPE" },
    "schema_version": { "type": "string", "pattern": "^[0-9]+\\.[0-9]+\\.[0-9]+$" },
    "schema_ref": { "const": "urn:omw:schema:event-envelope:1.0.0" },
    "message_id": { "$ref": "urn:omw:schema:common-defs:1.0.0#/$defs/stable_id" },
    "event_id": { "$ref": "urn:omw:schema:common-defs:1.0.0#/$defs/stable_id" },
    "idempotency_key": { "$ref": "urn:omw:schema:common-defs:1.0.0#/$defs/idempotency_key" },
    "campaign_id": { "$ref": "urn:omw:schema:common-defs:1.0.0#/$defs/stable_id" },
    "event_sequence": { "type": "integer", "minimum": 1 },
    "event_type": { "type": "string", "pattern": "^[A-Z][A-Z0-9_]{2,95}$" },
    "aggregate_type": { "type": "string", "pattern": "^[A-Z][A-Z0-9_]{2,63}$" },
    "aggregate_id": { "$ref": "urn:omw:schema:common-defs:1.0.0#/$defs/stable_id" },
    "aggregate_version": { "type": "integer", "minimum": 1 },
    "expected_state_version": { "type": ["integer", "null"], "minimum": 0 },
    "resulting_state_version": { "type": "integer", "minimum": 1 },
    "occurred_at": { "$ref": "urn:omw:schema:common-defs:1.0.0#/$defs/utc_timestamp" },
    "effective_at": { "$ref": "urn:omw:schema:common-defs:1.0.0#/$defs/utc_timestamp" },
    "recorded_at": { "$ref": "urn:omw:schema:common-defs:1.0.0#/$defs/utc_timestamp" },
    "actor": { "$ref": "urn:omw:schema:common-defs:1.0.0#/$defs/actor_ref" },
    "correlation_id": { "$ref": "urn:omw:schema:common-defs:1.0.0#/$defs/stable_id" },
    "causation_id": { "anyOf": [{ "$ref": "urn:omw:schema:common-defs:1.0.0#/$defs/stable_id" }, { "type": "null" }] },
    "payload_schema_ref": { "type": "string", "format": "uri" },
    "payload": { "type": "object" },
    "payload_hash": { "$ref": "urn:omw:schema:common-defs:1.0.0#/$defs/sha256" },
    "producer": { "$ref": "urn:omw:schema:common-defs:1.0.0#/$defs/producer" },
    "metadata": { "type": "object" },
    "extensions": { "$ref": "urn:omw:schema:common-defs:1.0.0#/$defs/extensions" }
  }
}
```

Die offene `payload`-Struktur wird in einem zweiten Validierungsschritt exakt gegen `payload_schema_ref` geprüft.

## 11. CommanderView

### 11.1 Zweck

`COMMANDER_VIEW` ist die einzige zulässige Laufzeitsicht eines Commanders auf den Kampagnenzustand.

Verbindlich:

```text
COMMANDER_VIEW != CAMPAIGN_STATE
COMMANDER_VIEW != WORLD_TRUTH_DUMP
```

### 11.2 Pflichtstruktur

```yaml
commander_view:
  contract_name: COMMANDER_VIEW
  schema_version: string
  schema_ref: string
  message_id: string
  view_id: string
  idempotency_key: string
  campaign_id: string
  turn_id: string
  commander_id: string
  faction_id: ISAF|AFGHAN_STATE|TALIBAN|HAQQANI|HIG
  dcs_coalition: BLUE|RED|NEUTRAL
  generated_at: datetime
  campaign_time: datetime
  based_on_state_version: integer
  decision_horizon: TACTICAL|OPERATIONAL|STRATEGIC
  allowed_action_types: []
  strategic_goals: []
  current_priorities: []
  known_facts: []
  observations: []
  beliefs: []
  memories: []
  relationships: []
  known_force_packages: []
  known_resource_accounts: []
  known_resource_sources: []
  known_access_nodes: []
  known_capability_assets: []
  active_force_generation_orders: []
  active_operations: []
  active_agreements: []
  information_gaps: []
  policy_constraints: []
  correlation_id: string
  causation_id: string|null
  producer: object
  payload_hash: string
  extensions: object
```

### 11.3 TypedViewItem

Komplexe Sichtelemente verwenden einen strikten Wrapper:

```yaml
typed_view_item:
  item_id: string
  subject_ref: string
  entity_type: string
  schema_ref: string
  knowledge_state: KNOWN|OBSERVED|REPORTED|ESTIMATED|BELIEVED|CONTESTED|STALE|UNKNOWN
  confidence: 0..100
  observed_at: datetime|null
  valid_at: datetime
  expires_at: datetime|null
  source_refs: []
  data: object
```

`data` wird separat gegen das angegebene `schema_ref` geprüft.

### 11.4 Verbotene Inhalte

Ein CommanderView-Schema darf keine Felder enthalten wie:

```text
world_truth
objective_enemy_resources
hidden_enemy_operations
other_commander_private_memory
adjudication_random_seed
future_events
unfiltered_nsl_data
```

ISAF- und Afghan-State-Views werden getrennt erzeugt. Gleiche DCS-Koalition erzeugt keine automatische Vollteilung.

## 12. CommanderDecision

### 12.1 Zweck

`COMMANDER_DECISION` enthält genau eine strukturierte strategische oder operative Absicht für einen Commander-Turn.

### 12.2 Pflichtstruktur

```yaml
commander_decision:
  contract_name: COMMANDER_DECISION
  schema_version: "2.0.0"
  schema_ref: urn:omw:schema:commander-decision:2.0.0
  message_id: string
  decision_id: string
  idempotency_key: string
  campaign_id: string
  turn_id: string
  view_id: string
  based_on_state_version: integer
  commander_id: string
  faction_id: ISAF|AFGHAN_STATE|TALIBAN|HAQQANI|HIG
  generated_at: datetime
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
    time_horizon: IMMEDIATE|SHORT|MEDIUM|LONG
  proposed_action:
    action_id: string
    action_type: string
    action_variant: string|null
    target_refs: []
    origin_refs: []
    destination_refs: []
    geographic_scope: []
    start_window: object
    duration_seconds: integer|null
    desired_effects: []
    assigned_force_package_refs: []
    required_resource_account_refs: []
    requested_resource_quantities: []
    requested_capability_refs: []
    requested_support: []
    required_agreement_refs: []
    delegated_to: []
    coordination_requirements: []
    information_requirements: []
  risk: object
  constraints: object
  abort_conditions: []
  fallback_action: object
  alternatives_considered: []
  relationship_effects_expected: []
  memory_items_to_record: []
  correlation_id: string
  causation_id: string|null
  producer: object
  payload_hash: string
  extensions: object
```

### 12.3 Ressourcenanforderung

Dynamische Maps werden auf der Wire-Ebene vermieden. Ressourcenanforderungen sind geordnete Einträge:

```yaml
requested_resource_quantity:
  resource_type: RECRUITABLE_MANPOWER|FINANCE|MATERIEL
  resource_account_ref: string
  quantity_units: integer
  purpose: FORCE_GENERATION|OPERATION|TRANSFER|RECOVERY
```

### 12.4 Ausführungsgrenze

Zulässig:

```yaml
proposed_action:
  action_type: PROTECT_RESOURCE_SOURCE
  target_refs:
    - RSC-EXAMPLE
  desired_effects:
    - PRESERVE_ACCESS
```

Nicht zulässig:

```yaml
proposed_action:
  method: "SomeMooseClass:SomeMethod()"
  lua: "..."
```

Die `assessment.summary` darf Freitext enthalten. Dieser Text darf weder Action Type noch IDs, Ressourcenbuchungen oder technische Adapterbefehle überschreiben.

## 13. OperationPlan

`OPERATION_PLAN` ist das erste autoritative, vom Orchestrator erzeugte Objekt für eine genehmigte Operation.

```yaml
operation_plan:
  contract_name: OPERATION_PLAN
  schema_version: string
  schema_ref: string
  message_id: string
  operation_id: string
  idempotency_key: string
  campaign_id: string
  originating_decision_id: string
  originating_action_id: string
  based_on_state_version: integer
  owner_faction_id: string
  owner_commander_id: string
  lead_faction_id: string
  supporting_faction_refs: []
  action_type: string
  lifecycle_state: PROPOSED|VALIDATING|APPROVED|RESOURCES_RESERVED|PREPARING|READY|EXECUTING|DELAYED|DISRUPTED|PARTIAL|COMPLETE|ABORTED|FAILED|CANCELLED|RECOVERING
  strategic_effect: string
  origin_refs: []
  target_refs: []
  participant_force_package_refs: []
  supporting_capability_asset_refs: []
  resource_reservation_refs: []
  agreement_refs: []
  route_refs: []
  tasks: []
  abort_conditions: []
  fallback_plan: object|null
  observation_requirements: []
  materialization_policy: VIRTUAL_ONLY|EVENT_ONLY|HYBRID|PHYSICAL_REQUIRED
  planned_start_at: datetime|null
  deadline_at: datetime|null
  correlation_id: string
  causation_id: string|null
  producer: object
  payload_hash: string
  extensions: object
```

### 13.1 OperationTask

```yaml
operation_task:
  task_id: string
  task_type: PREPARE|COLLECT|MOVE|STAGE|COORDINATE|EXECUTE|ASSESS|RECOVER
  domain_profile_ref: string
  assigned_entity_refs: []
  dependency_task_refs: []
  required_resource_reservation_refs: []
  required_capability_refs: []
  start_condition_refs: []
  completion_condition_refs: []
  failure_condition_refs: []
```

`domain_profile_ref` verweist auf einen geprüften Fachkatalog. Es ist kein MOOSE-Klassen- oder Methodenname.

## 14. ResourceReservation

```yaml
resource_reservation:
  contract_name: RESOURCE_RESERVATION
  schema_version: string
  schema_ref: string
  message_id: string
  reservation_id: string
  idempotency_key: string
  campaign_id: string
  resource_account_id: string
  resource_type: RECRUITABLE_MANPOWER|FINANCE|MATERIEL
  quantity_units: integer
  requesting_commander_id: string
  requesting_faction_id: string
  purpose_type: FORCE_GENERATION_ORDER|OPERATION|RESOURCE_TRANSFER|RECOVERY
  purpose_ref: string
  created_at: datetime
  activated_at: datetime|null
  expires_at: datetime|null
  status: REQUESTED|APPROVED|ACTIVE|CONSUMED|RELEASED|EXPIRED|CANCELLED
  state_version_created: integer
  correlation_id: string
  causation_id: string|null
  producer: object
  payload_hash: string
  extensions: object
```

Invarianten:

```text
QUANTITY_UNITS > 0
ACCOUNT_RESOURCE_TYPE = RESERVATION_RESOURCE_TYPE
CONSUMED_RESERVATION_CANNOT_BE_REACTIVATED
ONE_RESERVATION_ID -> ONE_PURPOSE_REF
```

## 15. ResourceTransfer

```yaml
resource_transfer:
  contract_name: RESOURCE_TRANSFER
  schema_version: string
  schema_ref: string
  message_id: string
  transfer_id: string
  idempotency_key: string
  campaign_id: string
  resource_type: FINANCE|MATERIEL|RECRUITABLE_MANPOWER
  source_account_id: string
  destination_account_id: string
  quantity_units: integer
  agreement_ref: string|null
  transport_operation_ref: string|null
  ownership_transfer: boolean
  status: PROPOSED|APPROVED|RESERVED|IN_TRANSIT|PARTIALLY_DELIVERED|DELIVERED|LOST|DESTROYED|CANCELLED
  credited_quantity_units: integer
  lost_quantity_units: integer
  created_at: datetime
  completed_at: datetime|null
  based_on_state_version: integer
  correlation_id: string
  causation_id: string|null
  producer: object
  payload_hash: string
  extensions: object
```

Verbindlich:

```text
TRANSFER != GENERATION
CREDITED + LOST <= REQUESTED
ONE_TRANSFER_ID -> AT_MOST_ONE_FINAL_CREDIT
```

`RECRUITABLE_MANPOWER` darf nur in ausdrücklich genehmigten Organisations- oder Force-Bewegungen übertragen werden. Es ist kein frei bewegliches Cargo.

## 16. ForceGenerationOrder

```yaml
force_generation_order:
  contract_name: FORCE_GENERATION_ORDER
  schema_version: string
  schema_ref: string
  message_id: string
  force_generation_order_id: string
  idempotency_key: string
  campaign_id: string
  faction_id: ISAF|AFGHAN_STATE|TALIBAN|HAQQANI|HIG
  requesting_commander_id: string
  requested_template_ref: string
  requested_package_type: string
  source_region_id: string|null
  resource_reservation_refs: []
  organizational_gate_requirements: []
  training_or_preparation_requirements: []
  requested_at: datetime
  generation_started_at: datetime|null
  generation_complete_at: datetime|null
  lifecycle_state: PROPOSED|VALIDATING|REJECTED|RESOURCES_RESERVED|RECRUITING|TRAINING|EQUIPPING|FORMING|AVAILABLE|CANCELLED|FAILED
  generated_force_package_id: string|null
  based_on_state_version: integer
  correlation_id: string
  causation_id: string|null
  producer: object
  payload_hash: string
  extensions: object
```

ISAF-Force-Generation-Orders dürfen keine afghanische Manpower-Quelle referenzieren.

## 17. ForcePackage

```yaml
force_package:
  contract_name: FORCE_PACKAGE
  schema_version: string
  schema_ref: string
  message_id: string
  force_package_id: string
  idempotency_key: string
  campaign_id: string
  owner_faction_id: ISAF|AFGHAN_STATE|TALIBAN|HAQQANI|HIG
  owner_organization_id: string|null
  package_type: string
  template_ref: string
  source_force_generation_order_id: string|null
  component_unit_refs: []
  home_location_id: string|null
  current_location_id: string|null
  readiness_state: PLANNED|FORMING|AVAILABLE|RESERVED|ASSIGNED|DEPLOYED|RECOVERING|MAINTENANCE|DEGRADED|LOST|DISBANDED
  readiness: 0..100
  current_strength_band: string
  assigned_operation_id: string|null
  resource_provenance_refs: []
  materialization_status: VIRTUAL|RESERVED|MATERIALIZING|PHYSICAL|DEMATERIALIZING|LOST
  materialization_policy: VIRTUAL_ONLY|EVENT_ONLY|HYBRID|PHYSICAL_REQUIRED
  state_version: integer
  correlation_id: string
  causation_id: string|null
  producer: object
  payload_hash: string
  extensions: object
```

```text
FORCE_PACKAGE != DCS_GROUP
```

Ein Force Package kann eine oder mehrere physische Mappings besitzen. Das Eigentum ändert sich nicht durch DCS-Koalitionszuordnung oder Unterstützung einer Partnerfraktion.

## 18. AdapterCommand

### 18.1 Zweck

`ADAPTER_COMMAND` ist der einzige zulässige Befehl vom Orchestrator an den DCS-/MOOSE-Adapter.

### 18.2 Struktur

```yaml
adapter_command:
  contract_name: ADAPTER_COMMAND
  schema_version: string
  schema_ref: string
  message_id: string
  command_id: string
  idempotency_key: string
  campaign_id: string
  dcs_session_id: string|null
  operation_id: string|null
  command_type: MATERIALIZE_OPERATION|UPDATE_OPERATION|ABORT_OPERATION|DEMATERIALIZE_ENTITY|MATERIALIZE_TRANSFER|QUERY_STATE|RECONCILE_STATE
  capability_profile_ref: string
  expected_state_version: integer
  expected_mapping_version: integer|null
  issued_at: datetime
  expires_at: datetime|null
  domain_payload_schema_ref: string
  domain_payload: object
  callback_event_types: []
  retry_policy:
    policy_ref: string
    max_attempts: integer
    retry_delay_seconds: integer
    owner: ORCHESTRATOR
  correlation_id: string
  causation_id: string|null
  producer: object
  payload_hash: string
  extensions: object
```

### 18.3 Adaptergrenze

`capability_profile_ref` verweist auf einen geprüften Katalogeintrag, beispielsweise eine abstrakte Operationsfähigkeit. Er darf nicht aus einem freien LLM-Text erzeugt werden.

`domain_payload` wird separat gegen `domain_payload_schema_ref` validiert.

Verboten:

```text
lua
script
method
function
arbitrary_command
raw_moose_call
raw_dcs_task
```

Retry-Parameter werden ausschließlich durch Orchestrator-Policy gesetzt. Ein Commander darf sie nicht beeinflussen.

### 18.4 Beispiel

```json
{
  "contract_name": "ADAPTER_COMMAND",
  "schema_version": "1.0.0",
  "schema_ref": "urn:omw:schema:adapter-command:1.0.0",
  "message_id": "MSG-EXAMPLE-001",
  "command_id": "CMD-EXAMPLE-001",
  "idempotency_key": "ADAPTER-COMMAND-EXAMPLE-001",
  "campaign_id": "CMP-EXAMPLE-001",
  "dcs_session_id": "DCS-SESSION-001",
  "operation_id": "OPR-EXAMPLE-001",
  "command_type": "MATERIALIZE_OPERATION",
  "capability_profile_ref": "CAP-PROTECT-RESOURCE-SOURCE-V1",
  "expected_state_version": 184,
  "expected_mapping_version": null,
  "issued_at": "2026-08-03T14:20:00.000Z",
  "expires_at": "2026-08-03T14:25:00.000Z",
  "domain_payload_schema_ref": "urn:omw:schema:materialize-operation-payload:1.0.0",
  "domain_payload": {
    "force_package_refs": ["FPG-EXAMPLE-001"],
    "target_refs": ["RSC-EXAMPLE-001"],
    "desired_effects": ["PROTECT"],
    "abort_condition_refs": ["COND-EXAMPLE-001"]
  },
  "callback_event_types": ["ENTITY_MATERIALIZED", "TASK_COMPLETED", "TASK_ABORTED"],
  "retry_policy": {
    "policy_ref": "RETRY-IDEMPOTENT-ADAPTER-V1",
    "max_attempts": 3,
    "retry_delay_seconds": 10,
    "owner": "ORCHESTRATOR"
  },
  "correlation_id": "COR-EXAMPLE-001",
  "causation_id": "EVT-EXAMPLE-001",
  "producer": {
    "component": "ORCHESTRATOR",
    "version": "0.1.0",
    "instance_id": "ORCH-INSTANCE-001"
  },
  "payload_hash": "sha256:0000000000000000000000000000000000000000000000000000000000000000",
  "extensions": {}
}
```

Die Beispielwerte sind nicht als reale Mission-Editor-Namen, Templates oder akzeptierte Runtime-IDs zu verwenden.

## 19. AdapterResult

```yaml
adapter_result:
  contract_name: ADAPTER_RESULT
  schema_version: string
  schema_ref: string
  message_id: string
  result_id: string
  command_id: string
  idempotency_key: string
  campaign_id: string
  dcs_session_id: string|null
  operation_id: string|null
  status: ACCEPTED|REJECTED|STARTED|PARTIAL|COMPLETED|FAILED|CANCELLED|DUPLICATE_NOOP
  accepted: boolean
  duplicate_of_result_id: string|null
  adapter_version: string
  moose_version: string|null
  dcs_build: string|null
  mapping_version: integer|null
  mapping_updates: []
  observations: []
  emitted_event_ids: []
  error: object|null
  occurred_at: datetime
  received_at: datetime
  correlation_id: string
  causation_id: string|null
  producer: object
  payload_hash: string
  extensions: object
```

### 19.1 MappingUpdate

```yaml
mapping_update:
  mapping_id: string
  strategic_entity_ref: string
  physical_ref_type: GROUP|UNIT|STATIC|ZONE|WAREHOUSE|AIRBASE|TASK|OTHER
  physical_ref: string
  moose_object_type: string|null
  mapping_state: CREATED|UPDATED|LOST|DEMATERIALIZED|ORPHANED
  mapping_version: integer
```

### 19.2 Fehlersemantik

Ein abgelehnter Command erzeugt keine physische Wirkung.

```text
REJECTED -> NO_MAPPING_UPDATE
DUPLICATE_NOOP -> NO_SECOND_PHYSICAL_EFFECT
FAILED != AUTOMATIC_RESOURCE_ROLLBACK
```

Ressourcenfolgen werden ausschließlich über validierte CampaignState-Events und gegebenenfalls kompensierende Events gebucht.

## 20. CargoManifest

### 20.1 Autorität

Die Mindestfelder stammen verbindlich aus `docs/05-logistics.md` und behalten ihre dort festgelegten Namen:

```text
cargoId
resourceType
quantity
weight
volume
origin
destination
transportMode
carrierEntityId
status
reservationId
historicalSourceIds
missionDemandId
```

### 20.2 Vertrag

```yaml
cargo_manifest:
  cargoId: string
  resourceType: string
  quantity: integer
  weight: string
  volume: string
  origin: string
  destination: string
  transportMode: ROAD_CONVOY|HELICOPTER_INTERNAL|HELICOPTER_SLING|FIXED_WING_LANDED|FIXED_WING_AIRDROP|AI_EMERGENCY_RESUPPLY
  carrierEntityId: string|null
  status: AVAILABLE|RESERVED|LOADING|INTERNAL|SLING|IN_TRANSIT|TRANSFERRED|DELIVERED|LOST|DESTROYED
  reservationId: string|null
  historicalSourceIds: []
  missionDemandId: string|null
  units:
    quantityUnit: string
    weightUnit: string
    volumeUnit: string
  manifestVersion: string
  stateVersion: integer
```

`weight` und `volume` werden als kanonische Dezimalzeichenketten übertragen, damit Python, Elixir und Lua keine unterschiedlichen binären Rundungen erzeugen. Die Einheiten stehen ausdrücklich in `units`.

### 20.3 Invarianten

```text
ONE_CARGO_ID -> AT_MOST_ONE_FINAL_CREDIT
TRANSFERRED != NEW_RESOURCE
DELIVERED + DUPLICATE_EVENT -> NO_SECOND_CREDIT
LOST_OR_DESTROYED -> NO_DESTINATION_CREDIT
CARRIER_CHANGE -> SAME_CARGO_ID
```

Ein CargoManifest ist kein Ersatz für `ResourceTransfer`. Es kann dessen physische Transportdarstellung referenzieren.

## 21. AuditRecord

```yaml
audit_record:
  contract_name: AUDIT_RECORD
  schema_version: string
  schema_ref: string
  audit_id: string
  campaign_id: string
  audit_type: COMMANDER_TURN|VALIDATION|ADJUDICATION|RESOURCE_TRANSACTION|FORCE_GENERATION|ADAPTER_COMMAND|ADAPTER_RESULT|RECOVERY|SCHEMA_MIGRATION
  correlation_id: string
  causation_id: string|null
  recorded_at: datetime
  component:
    name: string
    version: string
    instance_id: string
  input_refs: []
  output_refs: []
  input_hashes: []
  output_hashes: []
  schema_refs: []
  state_version_before: integer|null
  state_version_after: integer|null
  commander_id: string|null
  model_or_policy:
    type: SCRIPTED|LLM|NONE
    identifier: string|null
    version: string|null
    configuration_hash: string|null
  prompt_or_context_hash: string|null
  raw_response_hash: string|null
  parsed_decision_hash: string|null
  validation_results: []
  adjudication_result_ref: string|null
  random_draw_refs: []
  adapter_metadata: object|null
  redaction_applied: boolean
  error_refs: []
  extensions: object
```

AuditRecords dürfen enthalten:

- Hashes;
- sichere interne Referenzen;
- Modell- und Policy-Versionen;
- Validatorergebnisse;
- Zufallsziehungen;
- Adapter- und MOOSE-Versionen.

Sie dürfen nicht enthalten:

```text
API_KEYS
PASSWORDS
TOKENS
UNREDACTED_SECRETS
EXECUTABLE_LLM_OUTPUT
```

## 22. ContractError

```yaml
contract_error:
  contract_name: CONTRACT_ERROR
  schema_version: string
  schema_ref: string
  message_id: string
  error_id: string
  campaign_id: string|null
  correlation_id: string
  causation_id: string|null
  category: TRANSPORT|SCHEMA|REFERENCE|AUTHORITY|STATE_VERSION|BUSINESS_RULE|MOOSE_CAPABILITY|ADAPTER|INTERNAL
  error_code: string
  message: string
  retryable: boolean
  rejected_field_paths: []
  detail_codes: []
  expected_schema_ref: string|null
  received_schema_ref: string|null
  current_state_version: integer|null
  occurred_at: datetime
  producer: object
  extensions: object
```

Commander erhalten nur sichere, fachliche Fehlerantworten. Interne Stack Traces und Geheimnisse werden nicht zurückgegeben.

## 23. Validierungsstufen

Jeder eingehende Vertrag durchläuft in dieser Reihenfolge:

```text
1 TRANSPORT_PARSE
2 ENVELOPE_VALIDATE
3 SCHEMA_RESOLVE
4 PAYLOAD_VALIDATE
5 REFERENCE_VALIDATE
6 IDENTITY_AND_AUTHORITY_VALIDATE
7 STATE_VERSION_VALIDATE
8 IDEMPOTENCY_VALIDATE
9 BUSINESS_RULE_VALIDATE
10 POLICY_VALIDATE
11 MOOSE_CAPABILITY_VALIDATE
```

### 23.1 TRANSPORT_PARSE

Prüft:

- gültiges UTF-8;
- genau ein JSON-Dokument;
- keine doppelten Objekt-Keys;
- Größenlimit;
- keine ungültigen Zahlenwerte.

### 23.2 ENVELOPE_VALIDATE

Prüft gemeinsame Metadaten, IDs, Zeitformat, Hashfelder und Producer.

### 23.3 SCHEMA_RESOLVE

Löst die exakte Schema-ID in der Registry auf. Kein Fallback auf eine neuere Version.

### 23.4 PAYLOAD_VALIDATE

Validiert das Objekt vollständig, einschließlich `additionalProperties: false`.

### 23.5 REFERENCE_VALIDATE

Prüft, ob referenzierte IDs existieren und der erwarteten Entitätsart entsprechen.

### 23.6 IDENTITY_AND_AUTHORITY_VALIDATE

Prüft Commander, Fraktion, Eigentum, Vereinbarungen und Befehlsbefugnis.

### 23.7 STATE_VERSION_VALIDATE

Prüft Optimistic Concurrency und verhindert Entscheidungen gegen einen unzulässig veralteten State.

### 23.8 IDEMPOTENCY_VALIDATE

Prüft bereits verarbeitete fachliche Effekte und verhindert Doppelbuchungen oder Doppelmaterialisierung.

### 23.9 BUSINESS_RULE_VALIDATE

Prüft Ressourcen, Force Generation, Operation Lifecycle, Partnerautonomie und weitere fachliche Invarianten.

### 23.10 POLICY_VALIDATE

Prüft ROE-, NSL-, Schutz-, Fraktions- und Projektregeln.

### 23.11 MOOSE_CAPABILITY_VALIDATE

Prüft, ob eine genehmigte Fachaktion durch einen geprüften Adapter-/MOOSE-Capability-Katalog abgebildet werden kann.

```text
NO_CAPABILITY_MAPPING
-> NO_PHYSICAL_EXECUTION
```

## 24. Canonical Serialization und Hashing

### 24.1 Projektprofil

Kanonische JSON-Serialisierung verwendet das Projektprofil:

```text
OMW-JCS-1
```

`OMW-JCS-1` basiert auf deterministischer JSON-Kanonisierung und verlangt:

1. UTF-8 ohne BOM;
2. keine doppelten Objekt-Keys;
3. deterministische Objekt-Key-Reihenfolge;
4. keine unzulässigen Zahlenwerte;
5. keine irrelevanten Whitespaces;
6. Strings unverändert in ihrer Unicode-Zeichenfolge;
7. für Ressourcen ausschließlich Integer;
8. für Dezimalwerte kanonische Dezimalzeichenketten;
9. definierte Array-Semantik.

### 24.2 Arrays

Arrays mit Ablaufsemantik behalten ihre Reihenfolge:

```text
EVENTS
TASKS
ALTERNATIVES_IN_PRIORITY_ORDER
```

Arrays mit Set-Semantik werden vor dem Hashen nach stabiler ID lexikografisch sortiert:

```text
REFERENCE_SETS
SOURCE_REFS
AGREEMENT_REFS
CAPABILITY_REFS
```

Jedes Schema MUSS seine Array-Semantik dokumentieren.

### 24.3 Hashes

```text
payload_hash = SHA256(OMW-JCS-1(payload))
```

```text
contract_hash = SHA256(OMW-JCS-1(contract_without_contract_hash))
```

Hashformat:

```text
sha256:<64 lowercase hexadecimal characters>
```

Ein Objekt mit abweichendem Hash wird abgelehnt und nicht teilweise angewandt.

## 25. Idempotenz, Korrelation und Kausalität

### 25.1 Idempotenz

```text
SAME_IDEMPOTENCY_KEY
+ SAME_PAYLOAD_HASH
-> RETURN_PREVIOUS_RESULT
```

```text
SAME_IDEMPOTENCY_KEY
+ DIFFERENT_PAYLOAD_HASH
-> IDEMPOTENCY_CONFLICT
```

Idempotency Keys gelten innerhalb eines klar definierten Scopes, mindestens Campaign und Contract Type.

### 25.2 Korrelation

Eine vollständige Kette verwendet dieselbe `correlation_id`:

```text
COMMANDER_VIEW
-> COMMANDER_DECISION
-> VALIDATION
-> OPERATION_PLAN
-> ADAPTER_COMMAND
-> ADAPTER_RESULT
-> EVENTS
-> AUDIT_RECORDS
```

### 25.3 Kausalität

`causation_id` verweist nur auf die unmittelbar auslösende Nachricht oder das auslösende Event. Vollständige Ursachenketten werden durch wiederholte Auflösung aufgebaut.

## 26. Security und Größenlimits

Jedes Schema definiert:

- maximale Stringlänge;
- maximale Arraygröße;
- maximale Verschachtelung;
- zulässige Enum- oder Catalog-Werte;
- maximale Gesamtgröße der Nachricht.

Startwerte für den PoC dürfen konfigurierbar sein, müssen aber deterministisch und auditierbar gelten.

Freitext MUSS als nicht vertrauenswürdige Zeichenkette behandelt werden. Markdown, URLs oder Codeblöcke besitzen keine Sonderrechte.

Verbindlich:

```text
NO_DYNAMIC_EVAL
NO_DYNAMIC_IMPORT
NO_SCHEMA_FROM_LLM
NO_EXTENSION_EXECUTION
NO_SECRET_IN_COMMANDER_VIEW
```

## 27. Vorgesehene Schema-Ablage

```text
docs/special-projects/llm-commanders/schemas/
  registry.json
  common/
    common-defs.schema.json
    contract-error.schema.json
  events/
    event-envelope.schema.json
  commander/
    commander-view.schema.json
    commander-decision.schema.json
  operations/
    operation-plan.schema.json
  resources/
    resource-reservation.schema.json
    resource-transfer.schema.json
    force-generation-order.schema.json
    force-package.schema.json
  adapter/
    adapter-command.schema.json
    adapter-result.schema.json
  logistics/
    cargo-manifest.schema.json
  audit/
    audit-record.schema.json
  examples/
  compatibility/
  migrations/
```

Die Datei `registry.json` ist selbst gegen ein Registry-Schema zu validieren.

## 28. Contract Tests

Jeder Vertrag benötigt mindestens:

```text
VALID_MINIMAL_INSTANCE
VALID_COMPLETE_INSTANCE
UNKNOWN_FIELD_REJECTED
MISSING_REQUIRED_FIELD_REJECTED
WRONG_TYPE_REJECTED
INVALID_ENUM_REJECTED
INVALID_ID_REJECTED
NON_UTC_TIMESTAMP_REJECTED
NEGATIVE_QUANTITY_REJECTED
DUPLICATE_OBJECT_KEY_REJECTED
HASH_MISMATCH_REJECTED
UNKNOWN_SCHEMA_REJECTED
```

Zusätzliche fachliche Tests:

```text
COMMANDER_VIEW_CONTAINS_NO_WORLD_TRUTH_FIELD
COMMANDER_DECISION_CONTAINS_NO_EXECUTABLE_FIELD
ISAF_CANNOT_REFERENCE_AFGHAN_MANPOWER_FOR_OWN_FORCE_GENERATION
AFGHAN_FORCE_PACKAGE_OWNER_REMAINS_AFGHAN_STATE
TRANSFER_CANNOT_CREATE_RESOURCE
DUPLICATE_CARGO_DELIVERY_CANNOT_CREDIT_TWICE
DUPLICATE_ADAPTER_COMMAND_CANNOT_MATERIALIZE_TWICE
ADAPTER_RESULT_CANNOT_DIRECTLY_MUTATE_RESOURCE_ACCOUNT
UNKNOWN_MOOSE_CAPABILITY_BLOCKS_EXECUTION
```

### 28.1 Cross-Language Golden Tests

Python, Elixir und der spätere Lua-Adapter müssen für dieselben Fixtures erzeugen:

```text
SAME_VALIDATION_RESULT
SAME_CANONICAL_PAYLOAD_HASH
SAME_IDEMPOTENCY_DECISION
SAME_ENUM_INTERPRETATION
```

Lua muss nicht alle CampaignState-Schemas implementieren. Es validiert ausschließlich die für den Adapter relevanten Verträge und Felder.

## 29. Fehler- und Recovery-Verhalten

Ein Vertragsfehler darf keine teilweise fachliche Änderung erzeugen.

```text
VALIDATION_FAILURE
-> NO_STATE_CHANGE
-> CONTRACT_ERROR
-> AUDIT_RECORD
```

Ein Fehler nach einem bereits bestätigten State Commit wird durch ein neues Event oder kompensierendes Event behandelt. Alte Events werden nicht gelöscht.

Adapter-Timeout:

```text
TIMEOUT
-> QUERY_OR_RECONCILE
-> DO_NOT_BLINDLY_REPEAT_NON_IDEMPOTENT_EFFECT
```

## 30. Implementierungsreihenfolge

```text
1 create common-defs and registry schemas
2 create EventEnvelope and ContractError schemas
3 create CommanderView and CommanderDecision schemas
4 create ResourceReservation Transfer ForceGenerationOrder and ForcePackage schemas
5 create OperationPlan schema
6 create AdapterCommand and AdapterResult schemas
7 create CargoManifest schema aligned with docs/05-logistics.md
8 create AuditRecord schema
9 create positive and negative fixtures
10 implement schema validation in the deterministic harness
11 implement cross-language canonical-hash tests
12 only then implement one limited MOOSE adapter capability profile
```

## 31. Noch offene Entscheidungen

Nicht festgelegt und nicht zu erfinden:

- konkrete ResourceSource-Kapazitäten;
- konkrete Force-Package-Kosten;
- reale Template-IDs;
- reale Mission-Editor-Gruppennamen;
- konkrete MOOSE-Capability-Mappings;
- endgültige maximale Nachrichtengrößen;
- endgültige Retention-Zeiten für Audit- und Promptdaten;
- endgültige Python-/Elixir-/Hybridentscheidung.

Diese offenen Werte verhindern nicht die Erstellung und Prüfung der sprachneutralen Verträge.

## 32. Verbindlicher Konsolidierungsstand

```text
JSON_SCHEMA_BASELINE = DRAFT_2020_12
WIRE_NAMING = LOWER_SNAKE_CASE
CARGO_MANIFEST_NAMING = MAIN_PROJECT_CAMEL_CASE
RESOURCE_QUANTITY = NONNEGATIVE_INTEGER_CAMPAIGN_UNITS
SHARES_ON_WIRE = BASIS_POINTS
TIMESTAMP_PROFILE = UTC_MILLISECONDS_Z
SCHEMA_RESOLUTION = EXACT
UNKNOWN_FIELDS = REJECT
UNKNOWN_MAJOR_SCHEMA = REJECT
DIRECT_LLM_CODE_EXECUTION = PROHIBITED
DIRECT_LLM_DCS_CONTROL = PROHIBITED
ADAPTER_INPUT = VALIDATED_DOMAIN_OBJECTS_ONLY
MOOSE_FIRST = REQUIRED
```

## 33. Nächster Implementierungsblock

Nach Annahme dieses Vertragsdokuments folgt kein weiterer rein konzeptioneller Schemaentwurf, sondern die Erstellung der tatsächlichen `.schema.json`-Dateien, Registry, Fixtures und Contract Tests unter dem in Abschnitt 27 festgelegten Pfad.

Erst nach bestandenen sprachübergreifenden Golden Tests darf ein begrenztes Adapterprotokoll gegen MOOSE 2.9.18 implementiert oder in DCS getestet werden.
