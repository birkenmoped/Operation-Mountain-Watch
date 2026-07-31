---
document_id: OMW-SP-LLM-COMMANDERS-CAMPAIGN-STATE-EVENT-STORE
status: DRAFT_RUNTIME_DESIGN
document_class: CAMPAIGN_STATE_AND_EVENT_STORE_SCHEMA
scenario_period: 2010-08-01/2011-12-31
source_branch: docs/optional-llm-commanders
validated_in_dcs: false
---

# CampaignState und Event Store – persistentes Datenmodell

## 1. Zweck

Dieses Dokument definiert die autoritative persistente Datenbasis des optionalen Multi-Commander-Projekts.

Der CampaignState bildet die objektive strategische Simulationswahrheit ab. Der Event Store protokolliert jede relevante Zustandsänderung. Commander-LLMs greifen niemals direkt auf den vollständigen CampaignState zu, sondern ausschließlich auf durch den View Builder erzeugte, fraktionsspezifische Ausschnitte.

```text
EVENTS
-> STATE_REDUCER
-> CAMPAIGN_STATE
-> VIEW_BUILDER
-> COMMANDER_VIEW
-> COMMANDER_DECISION
-> VALIDATION_AND_ADJUDICATION
-> NEW_EVENTS
```

Verbindliche Trennung:

```text
CAMPAIGN_STATE != COMMANDER_BELIEF
EVENT_STORE != COMMANDER_MEMORY
DCS_OBJECT_STATE != COMPLETE_CAMPAIGN_STATE
LLM_OUTPUT != AUTHORITATIVE_STATE_CHANGE
```

## 2. Architekturgrundsätze

1. Der CampaignState ist die einzige autoritative strategische Wahrheit.
2. Jede fachlich relevante Änderung wird als Ereignis protokolliert.
3. Ereignisse sind nach dem Schreiben unveränderlich.
4. Korrekturen erfolgen durch neue kompensierende Ereignisse.
5. Persistente IDs dürfen niemals aus DCS-Gruppennamen allein abgeleitet werden.
6. Virtuelle und physische Repräsentation derselben Entität verwenden dieselbe strategische ID.
7. Fraktionswissen, Beliefs und Erinnerungen werden getrennt vom objektiven State gespeichert.
8. Ressourcen dürfen nur über validierte Reservierungs- und Verbrauchsereignisse gebunden werden.
9. Zeit, Version, Ursache und verantwortliche Komponente müssen für jede Änderung nachvollziehbar sein.
10. Der State muss ohne laufende DCS-Instanz rekonstruierbar und testbar sein.

## 3. Persistenzmodell

Empfohlene Trennung:

```text
EVENT_STORE
SNAPSHOT_STORE
READ_MODEL_STORE
AUDIT_STORE
DCS_MAPPING_STORE
```

### 3.1 Event Store

Enthält die unveränderliche Ereignisfolge.

### 3.2 Snapshot Store

Enthält periodisch erzeugte vollständige oder sektorweise Snapshots zur schnelleren Wiederherstellung.

### 3.3 Read Model Store

Enthält abgeleitete, nicht autoritative Sichten für:

- Commander Views;
- Operationsübersichten;
- Ressourcenverfügbarkeit;
- Kartenlayer;
- Spielerbriefings;
- Debugging und Telemetrie.

Read Models können jederzeit aus Event Store und Snapshots neu erzeugt werden.

### 3.4 Audit Store

Enthält LLM-, Prompt-, Validator- und Adjudikationsdaten, die nicht automatisch Teil der simulierten Welt sind.

### 3.5 DCS Mapping Store

Verknüpft strategische Entitäten mit aktuell materialisierten DCS-/MOOSE-Objekten.

## 4. Globale Campaign-Metadaten

```yaml
campaign:
  campaign_id: string
  schema_version: string
  scenario_id: string
  scenario_period_start: datetime
  scenario_period_end: datetime
  current_campaign_time: datetime
  time_scale: float
  campaign_seed: integer
  state_version: integer
  latest_event_sequence: integer
  latest_snapshot_sequence: integer
  runtime_mode: virtual|hybrid|physical
  status: initializing|active|paused|recovering|complete|failed
  dcs_session_id: string|null
  dcs_mission_build: string|null
  moose_version: string|null
  ruleset_version: string
  prompt_bundle_version: string
```

## 5. Identitäts- und Referenzsystem

Jede persistente Entität besitzt eine stabile ID.

Empfohlene Präfixe:

```text
CMP- campaign
FAC- faction
CMD- commander
SEC- sector
LOC- location
RTE- route
NOD- network or logistics node
ACT- actor
ORG- organization
UNT- force unit or cell
AST- asset
RES- resource pool
INF- information item
BLF- belief
MEM- memory item
AGR- agreement
MSG- inter-faction message
DEM- mission demand
TGT- target record
COL- collection requirement
OPR- operation
TSK- operation task
EVT- event
MAP- DCS materialization mapping
```

IDs sind unveränderlich. Namen, Callsigns, Zugehörigkeit, Status und DCS-Repräsentationen dürfen sich ändern.

## 6. Fraktionen und Commander

```yaml
faction:
  faction_id: string
  faction_type: blue|taliban|haqqani|hig|neutral|government|civilian
  display_name: string
  active: boolean
  strategic_alignment: string
  resource_ownership_policy: isolated|shared_by_agreement|hierarchical
  command_model: centralized|federated|networked|fragmented
  default_visibility_policy: string
```

```yaml
commander:
  commander_id: string
  faction_id: string
  profile_ref: string
  authority_scope:
    geographic_scope: []
    organization_refs: []
    resource_pool_refs: []
    permitted_action_types: []
  personality_ref: string
  active_goal_refs: []
  active_operation_refs: []
  relationship_refs: []
  belief_store_ref: string
  memory_store_ref: string
  status: active|isolated|degraded|replaced|captured|killed|inactive
  last_turn_at: datetime|null
  next_periodic_review_at: datetime|null
```

## 7. Geografisches Modell

### 7.1 Sector

```yaml
sector:
  sector_id: string
  name: string
  sector_type: province|district|valley|urban_area|operational_area|custom
  parent_sector_id: string|null
  geometry_ref: string
  terrain_class: urban|rural|mountain|desert|mixed
  population_estimate_band: string|null
  strategic_importance: 0..100
  current_accessibility: 0..100
  weather_region_ref: string|null
  adjacent_sector_refs: []
```

### 7.2 Location

```yaml
location:
  location_id: string
  sector_id: string
  location_type: airbase|fob|cop|village|city|checkpoint|bridge|pass|crossing|compound|facility|custom
  name: string
  coordinates:
    lat: float|null
    lon: float|null
    dcs_x: float|null
    dcs_y: float|null
  controlled_by_faction: string|null
  physical_status: intact|damaged|destroyed|abandoned|unknown
  access_status: open|restricted|contested|closed
  strategic_value: 0..100
  civilian_presence: 0..100
  no_strike_status: none|candidate|confirmed|restricted
  materialization_policy: virtual_only|event_only|hybrid|physical_required
```

### 7.3 Route

```yaml
route:
  route_id: string
  route_type: msr|asr|local_road|trail|air_corridor|facilitation_route|smuggling_route|custom
  origin_location_id: string
  destination_location_id: string
  waypoint_refs: []
  owner_or_primary_user: string|null
  capacity: 0..100
  concealment: 0..100
  travel_time_estimate: duration
  physical_condition: 0..100
  blue_control: 0..100
  red_access: 0..100
  civilian_usage: 0..100
  interdiction_risk: 0..100
  compromise_status: unknown|suspected|confirmed|clear
  current_status: open|degraded|interdicted|closed
```

## 8. Bevölkerung, Governance und lokale Macht

Zustände werden pro Sektor und nicht als einzelner pauschaler Score geführt.

```yaml
sector_governance_state:
  sector_id: string
  government_presence: 0..100
  government_service_delivery: 0..100
  government_legitimacy: 0..100
  local_representation: 0..100
  formal_justice_access: 0..100
  formal_justice_trust: 0..100
  informal_justice_access: 0..100
  informal_justice_trust: 0..100
  red_shadow_governance: 0..100
  red_shadow_justice: 0..100
  official_corruption: 0..100
  police_professionalism: 0..100
  police_abuse_risk: 0..100
  patronage_capture: 0..100
  local_powerbroker_influence: 0..100
  shura_representativeness: 0..100
  population_access_to_government: 0..100
  population_fear_of_government: 0..100
  population_fear_of_red: 0..100
```

```yaml
sector_population_state:
  sector_id: string
  perceived_security: 0..100
  freedom_of_movement: 0..100
  willingness_to_report: 0..100
  confidence_in_blue: 0..100
  confidence_in_government: 0..100
  confidence_in_taliban: 0..100
  confidence_in_haqqani: 0..100
  confidence_in_hig: 0..100
  coercive_compliance_taliban: 0..100
  coercive_compliance_haqqani: 0..100
  coercive_compliance_hig: 0..100
  grievance_against_blue: 0..100
  grievance_against_government: 0..100
  grievance_against_red: 0..100
  displacement_pressure: 0..100
```

Verbindlich:

```text
COMPLIANCE != SUPPORT
PRESENCE != LEGITIMACY
PROJECT_OUTPUT != POSITIVE_POLITICAL_EFFECT
SECURITY_FORCE_PRESENT != POPULATION_PROTECTED
```

## 9. Lokale Akteure und Organisationen

```yaml
actor:
  actor_id: string
  actor_type: commander|official|elder|broker|facilitator|source|specialist|civilian_leader|other
  display_name: string
  primary_faction_id: string|null
  secondary_affiliations: []
  home_sector_id: string|null
  current_location_id: string|null
  formal_authority: 0..100
  informal_influence: 0..100
  local_legitimacy: 0..100
  armed_backing: 0..100
  patronage_strength: 0..100
  reliability: 0..100
  loyalty: 0..100
  personal_ambition: 0..100
  corruption_pressure: 0..100
  defection_risk: 0..100
  compromise_risk: 0..100
  status: active|missing|detained|defected|captured|killed|inactive
```

```yaml
organization:
  organization_id: string
  faction_id: string|null
  organization_type: military|political|government|tribal|commercial|criminal|civilian|network
  parent_organization_id: string|null
  member_actor_refs: []
  controlled_unit_refs: []
  controlled_resource_pool_refs: []
  geographic_scope: []
  cohesion: 0..100
  command_reliability: 0..100
  political_influence: 0..100
  status: active|fragmented|merged|dissolved|inactive
```

## 10. Kräfte, Zellen und Assets

### 10.1 Gemeinsames Force-Objekt

```yaml
force_unit:
  unit_id: string
  faction_id: string
  organization_id: string|null
  unit_type: conventional|special_operations|partner_force|militia|insurgent_cell|support_cell|technical_team
  echelon_or_size_band: string
  home_location_id: string|null
  current_location_id: string|null
  assigned_operation_id: string|null
  readiness: 0..100
  cohesion: 0..100
  leadership_quality: 0..100
  discipline: 0..100
  tactical_skill: 0..100
  concealment: 0..100
  mobility: 0..100
  logistics_state: 0..100
  communications_state: 0..100
  intelligence_state: 0..100
  current_strength_band: string
  casualty_state: 0..100
  exposure_status: hidden|suspected|detected|identified|engaged
  materialization_status: virtual|reserved|materializing|physical|dematerializing|lost
  status: ready|tasked|moving|staging|engaged|recovering|degraded|destroyed|disbanded
```

### 10.2 BLUE Asset

```yaml
blue_asset:
  asset_id: string
  asset_type: aircraft|helicopter|uav|ground_vehicle|artillery|sensor|medical|eod|logistics|other
  owner_organization_id: string
  home_base_id: string
  current_location_id: string
  readiness_state: ready|alert|tasked|enroute|on_station|engaged|returning|recovering|maintenance|crew_rest|weather_hold|damaged|unavailable|destroyed
  mission_qualifications: []
  available_payloads: []
  endurance_remaining: duration|null
  fuel_state: 0..100|null
  ammunition_state: 0..100|null
  crew_state: 0..100|null
  maintenance_state: 0..100
  national_caveats: []
  weather_limits: []
  reserve_category: uncommitted|local_reserve|regional_reserve|theater_reserve|emergency_only|recovery_protected
  assigned_operation_id: string|null
```

## 11. Ressourcenpools und Reservierungen

```yaml
resource_pool:
  resource_pool_id: string
  owner_faction_id: string
  owner_organization_id: string|null
  resource_type: manpower|finance|weapons|explosives|fuel|vehicles|airlift|isr|medevac|specialist|political_capital|local_access|other
  location_id: string|null
  total_capacity: number
  available_capacity: number
  reserved_capacity: number
  degraded_capacity: number
  replenishment_rate: number|null
  replenishment_interval: duration|null
  concealment: 0..100
  compromise_risk: 0..100
  sharing_policy: private|request_only|agreement_only|shared
  status: active|degraded|isolated|exhausted|destroyed
```

```yaml
resource_reservation:
  reservation_id: string
  resource_pool_id: string
  operation_id: string
  requester_commander_id: string
  quantity_or_capacity: number
  reserved_at: datetime
  expires_at: datetime|null
  status: requested|approved|active|consumed|released|expired|cancelled
  state_version_created: integer
```

Verbindliche Invariante:

```text
available_capacity + reserved_capacity + degraded_capacity <= total_capacity
```

## 12. RED-Netzwerkknoten und Capability Packages

```yaml
network_node:
  node_id: string
  owner_faction_id: string
  node_type: sanctuary|border_entry|transit|facilitation|safehouse|cache|training|finance|specialist|staging|surveillance|media|other
  location_id: string|null
  connected_route_refs: []
  capacity: 0..100
  concealment: 0..100
  redundancy: 0..100
  replacement_difficulty: 0..100
  compromise_risk: 0..100
  blue_pressure: 0..100
  known_by_blue_level: unknown|suspected|correlated|confirmed
  status: active|degraded|quarantined|compromised|abandoned|destroyed
```

```yaml
capability_package:
  package_id: string
  owner_faction_id: string
  sponsor_actor_id: string|null
  strategic_effect: string
  target_ref: string|null
  target_intelligence_level: 0..100
  manpower_refs: []
  weapon_resource_refs: []
  explosive_resource_refs: []
  specialist_actor_refs: []
  communication_node_refs: []
  route_refs: []
  safehouse_refs: []
  staging_node_refs: []
  media_node_refs: []
  operational_security: 0..100
  lifecycle_state: concept|intelligence_gathering|assembling|preparing|moving|staging|ready|executing|disrupted|delayed|aborted|complete
  associated_operation_id: string|null
```

## 13. Beziehungen, Vereinbarungen und Nachrichten

```yaml
relationship_state:
  relationship_id: string
  subject_faction_id: string
  object_faction_id: string
  geographic_scope: []
  formal_alignment: 0..100
  ideological_alignment: 0..100
  political_trust: 0..100
  operational_trust: 0..100
  intelligence_sharing_willingness: 0..100
  logistics_cooperation_willingness: 0..100
  territorial_competition: 0..100
  recruitment_competition: 0..100
  revenue_competition: 0..100
  prestige_competition: 0..100
  grievance_level: 0..100
  dependency: 0..100
  fear_of_betrayal: 0..100
  conflict_risk: 0..100
  last_material_change_at: datetime
```

Beziehungen sind gerichtet. `A -> B` kann andere Werte besitzen als `B -> A`.

```yaml
agreement:
  agreement_id: string
  participant_faction_refs: []
  agreement_type: information_exchange|transit_access|resource_transfer|specialist_support|joint_operation|revenue_sharing|local_non_aggression|temporary_truce|withdrawal|other
  geographic_scope: []
  valid_from: datetime
  valid_until: datetime|null
  obligations: []
  verification_methods: []
  breach_conditions: []
  termination_conditions: []
  status: proposed|negotiating|accepted|active|partially_fulfilled|fulfilled|breached|expired|terminated
```

```yaml
faction_message:
  message_id: string
  sender_faction_id: string
  sender_commander_id: string
  recipient_faction_refs: []
  message_type: request|offer|acceptance|rejection|counteroffer|warning|protest|status_report|information_share|termination_notice
  channel_ref: string
  payload_ref: string
  sent_at: datetime
  received_at: datetime|null
  authenticity: confirmed|probable|uncertain|false
  transmission_status: queued|sent|delivered|delayed|intercepted|lost|compromised
```

## 14. Objective Intelligence, Beliefs und Memory

### 14.1 Objective Information Item

```yaml
information_item:
  information_id: string
  subject_ref: string
  objective_content: object
  source_type: sensor|human|report|document|intercept|operation_result|liaison|other
  source_owner: string|null
  source_chain: []
  reliability: 0..100
  credibility: 0..100
  first_observed_at: datetime
  last_verified_at: datetime|null
  geographic_scope: []
  decay_rate: float
  deception_risk: 0..100
  compromise_risk: 0..100
  sharing_restrictions: []
  objective_status: valid|contested|false|expired
```

### 14.2 Commander Belief

```yaml
commander_belief:
  belief_id: string
  commander_id: string
  subject_ref: string
  believed_content: object
  supporting_information_refs: []
  contradicting_information_refs: []
  confidence: 0..100
  belief_state: unknown|rumor|reported|observed_once|partially_correlated|pattern_suspected|pattern_confirmed|recently_verified|contested|stale|compromised|disproven
  first_formed_at: datetime
  last_updated_at: datetime
  next_decay_at: datetime|null
```

### 14.3 Commander Memory

```yaml
commander_memory:
  memory_id: string
  commander_id: string
  memory_type: episodic|semantic|relationship|operational|organizational|shock
  subject_refs: []
  summary: string
  salience: 0..100
  emotional_or_political_weight: 0..100
  created_at: datetime
  last_recalled_at: datetime|null
  decay_rate: float
  archive_status: active|compressed|archived
```

## 15. BLUE MissionDemand, Collection und Targeting

```yaml
mission_demand:
  demand_id: string
  requesting_commander_id: string
  demand_type: string
  desired_effect: string
  strategic_context: string
  geographic_scope: []
  urgency: routine|priority|immediate|emergency
  required_by: datetime|null
  intelligence_basis_refs: []
  required_capabilities: []
  acceptable_alternatives: []
  political_constraints: []
  civilian_constraints: []
  assessment_requirements: []
  priority_score: number|null
  lifecycle_state: draft|submitted|validated|prioritized|approved|allocated|tasked|executing|complete|denied|cancelled|aborted
```

```yaml
collection_requirement:
  collection_id: string
  requesting_commander_id: string
  intelligence_question: string
  subject_refs: []
  geographic_scope: []
  required_confidence: 0..100
  available_collection_methods: []
  collection_risk: 0..100
  deadline: datetime|null
  assigned_asset_refs: []
  lifecycle_state: draft|validated|queued|allocated|collecting|partial_result|result_available|no_result|compromised|cancelled|closed
```

```yaml
target_record:
  target_id: string
  subject_ref: string
  identity_assessment: object
  activity_assessment: object
  hostile_status_basis: []
  location_confidence: 0..100
  civilian_context: object
  friendly_context: object
  no_strike_status: clear|potential_match|confirmed_match|restricted|unknown
  roe_status: valid|invalid|requires_review|unknown
  desired_effects: []
  non_kinetic_options: []
  source_refs: []
  lifecycle_state: discovered|correlated|under_development|needs_collection|candidate|nominated|reviewing|authorized_for_specific_effect|denied|monitor_only|expired|disproven|removed
```

## 16. Operation und Task Lifecycle

```yaml
operation:
  operation_id: string
  owner_faction_id: string
  owner_commander_id: string
  source_decision_id: string
  action_type: string
  action_variant: string|null
  strategic_goal_ref: string
  desired_effects: []
  geographic_scope: []
  origin_refs: []
  target_refs: []
  participant_refs: []
  resource_reservation_refs: []
  agreement_refs: []
  route_plan_refs: []
  abort_conditions: []
  fallback_plan: object|null
  materialization_policy: virtual_only|event_only|hybrid|physical_required
  lifecycle_state: proposed|validating|approved|resources_reserved|preparing|moving|staging|ready|executing|delayed|disrupted|partially_complete|complete|aborted|failed|cancelled|recovering
  state_version_created: integer
  state_version_last_modified: integer
  created_at: datetime
  planned_start_at: datetime|null
  actual_start_at: datetime|null
  completed_at: datetime|null
```

```yaml
operation_task:
  task_id: string
  operation_id: string
  task_type: prepare|collect|move|stage|coordinate|execute|assess|recover
  assigned_entity_refs: []
  dependency_task_refs: []
  required_resource_refs: []
  start_condition: object
  completion_condition: object
  failure_condition: object
  lifecycle_state: pending|ready|active|blocked|complete|failed|cancelled
```

## 17. DCS-/MOOSE-Materialisierung

```yaml
materialization_mapping:
  mapping_id: string
  strategic_entity_ref: string
  dcs_session_id: string
  dcs_object_type: group|unit|static|zone|warehouse|airbase|task|other
  dcs_object_name: string
  moose_object_type: string|null
  moose_object_name: string|null
  materialized_at: datetime
  last_seen_at: datetime
  synchronization_state: synchronized|state_ahead|dcs_ahead|missing|conflicted
  dematerialization_policy: retain_state|derive_losses|discard_transient
  status: planned|active|lost|dematerialized|orphaned
```

Verbindliche Invarianten:

```text
ONE_STRATEGIC_ENTITY may have multiple historical mappings
ONE_ACTIVE_DCS_OBJECT maps to only one strategic entity
DEMATERIALIZATION does not recreate consumed resources
DCS_DESTRUCTION requires validated state transition
MISSING_DCS_OBJECT != AUTOMATICALLY_DESTROYED
```

## 18. Event Envelope

Jedes Ereignis verwendet denselben Umschlag:

```yaml
event:
  event_id: string
  sequence: integer
  campaign_id: string
  event_type: string
  schema_version: string
  occurred_at: datetime
  recorded_at: datetime
  effective_at: datetime
  actor_type: commander|orchestrator|validator|adjudicator|dcs|moose|system|operator
  actor_ref: string|null
  causation_id: string|null
  correlation_id: string|null
  aggregate_type: string
  aggregate_id: string
  expected_state_version: integer|null
  resulting_state_version: integer
  payload: object
  metadata:
    dcs_session_id: string|null
    turn_id: string|null
    operation_id: string|null
    model_identifier: string|null
    prompt_version: string|null
    adjudication_seed: integer|null
```

## 19. Ereigniskategorien

### 19.1 Campaign und Zeit

```text
CAMPAIGN_INITIALIZED
CAMPAIGN_STARTED
CAMPAIGN_PAUSED
CAMPAIGN_RESUMED
CAMPAIGN_TIME_ADVANCED
CAMPAIGN_COMPLETED
SNAPSHOT_CREATED
```

### 19.2 Commander und Organisation

```text
COMMANDER_ACTIVATED
COMMANDER_REPLACED
COMMANDER_DEGRADED
COMMANDER_REMOVED
AUTHORITY_SCOPE_CHANGED
ORGANIZATION_FRAGMENTED
ORGANIZATION_MERGED
ACTOR_STATUS_CHANGED
ACTOR_DEFECTED
```

### 19.3 Information, Belief und Memory

```text
INFORMATION_REPORTED
INFORMATION_CORROBORATED
INFORMATION_CONTRADICTED
INFORMATION_DISPROVEN
INFORMATION_SHARED
INFORMATION_INTERCEPTED
BELIEF_CREATED
BELIEF_UPDATED
BELIEF_DECAYED
BELIEF_DISPROVEN
MEMORY_RECORDED
MEMORY_COMPRESSED
MEMORY_ARCHIVED
```

### 19.4 Ressourcen und Kräfte

```text
RESOURCE_ADDED
RESOURCE_DEGRADED
RESOURCE_RESERVED
RESOURCE_RESERVATION_RELEASED
RESOURCE_CONSUMED
RESOURCE_TRANSFER_REQUESTED
RESOURCE_TRANSFER_STARTED
RESOURCE_TRANSFER_COMPLETED
RESOURCE_TRANSFER_DISRUPTED
UNIT_TASKED
UNIT_MOVED
UNIT_DEGRADED
UNIT_DESTROYED
ASSET_READINESS_CHANGED
```

### 19.5 Beziehungen und Vereinbarungen

```text
MESSAGE_SENT
MESSAGE_DELIVERED
MESSAGE_INTERCEPTED
NEGOTIATION_OPENED
AGREEMENT_PROPOSED
AGREEMENT_ACCEPTED
AGREEMENT_ACTIVATED
AGREEMENT_PARTIALLY_FULFILLED
AGREEMENT_FULFILLED
AGREEMENT_BREACHED
AGREEMENT_TERMINATED
RELATIONSHIP_CHANGED
LOCAL_CLASH_OCCURRED
```

### 19.6 MissionDemand, Targeting und Operations

```text
MISSION_DEMAND_CREATED
MISSION_DEMAND_PRIORITIZED
MISSION_DEMAND_APPROVED
MISSION_DEMAND_DENIED
COLLECTION_REQUIREMENT_CREATED
COLLECTION_ASSET_ALLOCATED
COLLECTION_RESULT_RECORDED
TARGET_RECORD_CREATED
TARGET_STATUS_CHANGED
OPERATION_PROPOSED
OPERATION_VALIDATED
OPERATION_RESTRICTED
OPERATION_APPROVED
OPERATION_REJECTED
OPERATION_RESOURCES_RESERVED
OPERATION_PHASE_CHANGED
OPERATION_DELAYED
OPERATION_DISRUPTED
OPERATION_ABORTED
OPERATION_COMPLETED
OPERATION_FAILED
```

### 19.7 DCS und MOOSE

```text
DCS_SESSION_STARTED
DCS_SESSION_ENDED
ENTITY_MATERIALIZATION_REQUESTED
ENTITY_MATERIALIZED
ENTITY_SYNCHRONIZED
ENTITY_MISSING_IN_DCS
ENTITY_DEMATERIALIZED
DCS_DAMAGE_REPORTED
DCS_DESTRUCTION_REPORTED
DCS_POSITION_REPORTED
DCS_TASK_RESULT_REPORTED
MOOSE_TASK_STATE_CHANGED
```

## 20. State Reducer

Der State Reducer ist deterministisch.

```text
CURRENT_STATE
+ NEXT_EVENT
+ REDUCER_VERSION
=
NEXT_STATE
```

Er darf:

- Ereignisse gegen das aktuelle Schema prüfen;
- Aggregate aktualisieren;
- Invarianten prüfen;
- abgeleitete interne Indizes aktualisieren;
- bei Versionskonflikten ablehnen.

Er darf nicht:

- eigenständig strategische Entscheidungen treffen;
- fehlende Ereignisse erfinden;
- LLM-Begründungen als Weltwahrheit übernehmen;
- DCS-Meldungen ungeprüft als endgültiges Ergebnis übernehmen.

## 21. Optimistic Concurrency und Locks

Jeder schreibende Vorgang enthält die erwartete State-Version.

```text
IF expected_state_version != current_state_version
THEN reject with STATE_VERSION_CONFLICT
```

Zusätzliche Sperren:

```text
RESOURCE_LOCK
OPERATION_LOCK
AGREEMENT_LOCK
ENTITY_MATERIALIZATION_LOCK
LOCATION_CONFLICT_LOCK
```

Sperren besitzen:

- Besitzer;
- Erstellzeit;
- Ablaufzeit;
- Correlation-ID;
- automatisches Recovery-Verfahren.

## 22. Snapshots

Snapshots werden empfohlen:

- nach einer festen Ereignisanzahl;
- vor und nach einer DCS-Session;
- vor Schema-Migrationen;
- vor langen Testläufen;
- nach großen Kampagnenphasen.

```yaml
snapshot:
  snapshot_id: string
  campaign_id: string
  event_sequence: integer
  state_version: integer
  schema_version: string
  reducer_version: string
  created_at: datetime
  state_hash: string
  payload_ref: string
```

Ein Snapshot ist nur gültig, wenn seine Prüfsumme und die anschließende Event-Replay-Kette verifiziert werden können.

## 23. Schema-Versionierung und Migration

```text
SCHEMA_CHANGE
-> MIGRATION_PLAN
-> BACKUP_AND_SNAPSHOT
-> EVENT_COMPATIBILITY_CHECK
-> STATE_MIGRATION
-> REPLAY_TEST
-> ACCEPTANCE
```

Regeln:

1. Alte Ereignisse werden nicht rückwirkend überschrieben.
2. Event Upcaster dürfen alte Payloads in eine aktuelle Lesedarstellung transformieren.
3. Jede Migration besitzt eine eigene Versionsnummer.
4. Replay vor und nach Migration muss fachlich äquivalente Ergebnisse liefern oder dokumentierte Abweichungen erzeugen.
5. Inkompatible Änderungen benötigen einen neuen Campaign-Zweig oder eine explizite Konvertierung.

## 24. Recovery nach Abbruch oder DCS-Ausfall

```text
1. letzten gültigen Snapshot laden
2. Events bis zum letzten bestätigten Sequence-Wert wiedergeben
3. offene Locks prüfen und bereinigen
4. laufende Operationen auf Recovery-Regeln prüfen
5. DCS-Mappings als nicht bestätigt markieren
6. neue DCS-Session starten
7. erforderliche Entitäten neu materialisieren
8. Synchronisationsereignisse schreiben
```

Ein DCS-Ausfall darf keine Ressourcen duplizieren und keine bereits bestätigten Verluste rückgängig machen.

## 25. Idempotenz

DCS- und externe Adapter können dasselbe Ereignis mehrfach melden. Deshalb benötigt jede externe Meldung einen stabilen Idempotency Key.

```yaml
external_event_identity:
  source_system: string
  source_session_id: string
  source_event_id: string
```

Bereits verarbeitete Schlüssel werden nicht erneut als State-Änderung angewandt.

## 26. Audit- und Reproduzierbarkeitsanforderungen

Für jede Commander-Entscheidung müssen verknüpfbar sein:

```text
COMMANDER_INPUT_SNAPSHOT
RAW_LLM_RESPONSE_HASH
PARSED_DECISION
VALIDATION_RESULT
ADJUDICATION_RESULT
GENERATED_EVENTS
RESULTING_STATE_VERSION
COMMANDER_VISIBLE_RESULT
```

Für jede Operation müssen verknüpfbar sein:

```text
SOURCE_DECISION
RESOURCE_RESERVATIONS
OPERATION_TASKS
DCS_MAPPINGS
EXECUTION_EVENTS
ASSESSMENT
MEMORY_AND_RELATIONSHIP_EFFECTS
```

## 27. Datenschutz innerhalb der Simulation

Der View Builder arbeitet mit expliziten Sichtbarkeitsregeln:

```text
OBJECTIVE_STATE_FIELD
-> VISIBILITY_POLICY
-> FACTION_ACCESS
-> COMMANDER_AUTHORITY
-> INFORMATION_SHARING_RESTRICTIONS
-> COMMANDER_VIEW_FIELD
```

Es ist verboten, vollständige Aggregate ungefiltert in LLM-Prompts zu serialisieren.

Besonders geschützt:

- gegnerische Ressourcenbestände;
- versteckte Knoten;
- nicht erkannte Fraktionsbeziehungen;
- genaue gegnerische Operationspläne;
- objektive Quellenzuverlässigkeit;
- andere Commander-Beliefs und Memories;
- interne BLUE-Targeting- und NSL-Daten, soweit nicht freigegeben.

## 28. Mindestinvarianten

Der Runtime-Kern muss mindestens folgende Invarianten durchsetzen:

```text
NO_NEGATIVE_RESOURCE_CAPACITY
NO_DOUBLE_RESOURCE_RESERVATION
NO_ACTIVE_OPERATION_WITH_DESTROYED_OWNER_UNIT
NO_FOREIGN_RESOURCE_CONTROL_WITHOUT_AGREEMENT
NO_PHYSICAL_EXECUTION_BEFORE_APPROVAL
NO_EXECUTE_COMPLEX_OPERATION_WITHOUT_READY_PACKAGE
NO_KINETIC_BLUE_EFFECT_WITHOUT_REQUIRED_TARGETING_STATUS
NO_DUPLICATE_ACTIVE_DCS_MAPPING
NO_STATE_UPDATE_WITH_STALE_VERSION
NO_COMMANDER_VIEW_WITH_UNAUTHORIZED_WORLD_TRUTH
NO_EVENT_SEQUENCE_GAP
NO_SNAPSHOT_WITH_INVALID_HASH
```

## 29. Minimaler Implementierungsumfang

Für den ersten deterministischen Test Harness genügt:

```text
Campaign
Faction
Commander
Sector
Location
Route
ForceUnit
ResourcePool
ResourceReservation
InformationItem
CommanderBelief
RelationshipState
Agreement
MissionDemand
Operation
OperationTask
EventEnvelope
Snapshot
```

Noch nicht erforderlich für Phase 1:

- vollständige DCS-Materialisierung;
- komplette BLUE-ATO-Projektion;
- vollständige Targeting-Automation;
- komplexe geografische Datenbank;
- semantische Vektorsuche für Memory;
- Echtzeit-Multi-LLM-Kommunikation.

## 30. Empfohlene technische Ablagestruktur

```text
campaign/
  schemas/
    campaign-state.schema.json
    event-envelope.schema.json
    operation.schema.json
    resource.schema.json
  reducers/
    campaign_reducer
    operation_reducer
    resource_reducer
    relationship_reducer
  projections/
    commander_view
    operation_board
    resource_board
    map_layers
  migrations/
  snapshots/
  tests/
```

Die konkrete Programmiersprache ist in diesem Dokument nicht festgelegt. Die Schnittstellen und Invarianten gelten unabhängig davon, ob der Orchestrator später in Python, Elixir oder einer anderen geeigneten Laufzeit umgesetzt wird.

## 31. Acceptance-Kriterien

Das Datenmodell ist erst als Runtime-Basis akzeptiert, wenn folgende Tests bestehen:

1. vollständiger State-Aufbau aus leerem Store;
2. deterministischer Replay mit identischem State-Hash;
3. Recovery aus Snapshot plus Rest-Events;
4. Ablehnung eines State-Version-Konflikts;
5. Ablehnung einer doppelten Ressourcenreservierung;
6. idempotente Verarbeitung doppelter DCS-Meldungen;
7. keine Duplikation nach Materialisierung und Dematerialisierung;
8. korrekte Trennung von World Truth und Commander View;
9. unterschiedliche Beliefs bei identischem objektivem State;
10. reproduzierbares Operationsergebnis bei gleichem Seed;
11. Schema-Migration mit Replay-Test;
12. Recovery nach simuliertem Prozess- oder DCS-Abbruch.

## 32. Nächster Implementierungsblock

Auf Basis dieses Schemas folgt:

```text
14-deterministic-test-harness-and-scripted-commanders.md
```

Dieses Dokument muss festlegen:

- minimale ausführbare Komponenten;
- geskriptete Commander als Referenzverhalten;
- Fixture- und Seed-Verwaltung;
- Event-Replay-Tests;
- Property- und Invariant-Tests;
- LLM-freie Baseline;
- spätere Austauschbarkeit der geskripteten Commander durch LLM-Adapter.
