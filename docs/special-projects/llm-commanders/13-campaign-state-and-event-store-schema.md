---
document_id: OMW-SP-LLM-COMMANDERS-CAMPAIGN-STATE-EVENT-STORE
status: DRAFT_RUNTIME_DESIGN
document_class: CAMPAIGN_STATE_AND_EVENT_STORE_SCHEMA
scenario_period: 2010-08-01/2011-12-31
source_branch: docs/optional-llm-commanders
validated_in_dcs: false
authoritative_for:
  - persistent campaign aggregates
  - event envelope and reducer invariants
  - five-faction campaign identity
  - contested resource sources, accounts and flows
  - force generation and force-package persistence
  - DCS/MOOSE materialization mappings
---

# CampaignState und Event Store – persistentes Datenmodell

## 1. Zweck

Dieses Dokument definiert die autoritative persistente Datenbasis des optionalen Multi-Commander-Projekts.

Der CampaignState bildet die objektive strategische Simulationswahrheit ab. Der Event Store protokolliert jede relevante Zustandsänderung. Commander erhalten niemals direkten Zugriff auf den vollständigen CampaignState, sondern ausschließlich auf durch den View Builder erzeugte, fraktions- und commander-spezifische Sichten.

Das Dokument integriert verbindlich:

- fünf getrennte Kampagnenfraktionen;
- die gemeinsame Ressourcenarchitektur aus Dokument 17;
- die Afghan-State-/ANSF-Fraktion aus Dokument 16;
- die Integrationsregeln aus Dokument 18;
- die Trennung zwischen strategischem `ForcePackage` und untergeordnetem `ForceUnit`;
- die MOOSE-First-Grenze zwischen strategischer Autorisierung und taktischer Ausführung.

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

Verbindliche Trennungen:

```text
CAMPAIGN_STATE != COMMANDER_BELIEF
EVENT_STORE != COMMANDER_MEMORY
DCS_OBJECT_STATE != COMPLETE_CAMPAIGN_STATE
LLM_OUTPUT != AUTHORITATIVE_STATE_CHANGE
DCS_COALITION != CAMPAIGN_FACTION
RESOURCE != CAPABILITY
RESOURCE != POLITICAL_STATE
FORCE_PACKAGE != DCS_GROUP
```

## 2. Autoritäts- und Querverweisregel

Für Ressourcenbegriffe, Eigentum, Zuflüsse und Kräftegenerierung gilt:

```text
17-faction-objectives-resource-ownership-flow-and-force-generation-model.md
```

Für die afghanische Fraktion gilt:

```text
16-afghan-state-and-ansf-commander-dossier.md
```

Für die Migration älterer Dokumente gilt:

```text
18-resource-model-integration-and-dossier-amendments.md
```

Dieses Dokument konkretisiert diese Entscheidungen als persistentes Datenmodell.

Hauptprojekt-Autoritäten bleiben insbesondere:

```text
docs/05-logistics.md
docs/15-template-library-and-spawning.md
docs/26-moose-first-development-policy.md
docs/37-campaign-architecture-and-dynamic-mission-design.md
```

```text
SPECIAL_PROJECT_CAMPAIGN_STATE
must not supersede
MAIN_PROJECT_MOOSE_OR_LOGISTICS_AUTHORITY
```

## 3. Architekturgrundsätze

1. Der CampaignState ist die einzige autoritative strategische Wahrheit.
2. Jede fachlich relevante Änderung wird als Ereignis protokolliert.
3. Ereignisse sind nach dem Schreiben unveränderlich.
4. Korrekturen erfolgen durch neue kompensierende Ereignisse.
5. Persistente IDs werden niemals allein aus DCS-Gruppennamen abgeleitet.
6. Virtuelle und physische Repräsentationen verwenden dieselbe strategische Referenz.
7. Fraktionswissen, Beliefs und Erinnerungen bleiben vom objektiven State getrennt.
8. Ressourcen werden ausschließlich über Quellen-, Konto-, Reservierungs-, Transfer- und Verbrauchsereignisse verändert.
9. Keine Ressource entsteht ohne eine definierte Quelle.
10. Kein `ForcePackage` entsteht ohne nachweisbare Ressourcenbindung und fraktionsspezifische Gates.
11. Zeit, Version, Ursache und verantwortliche Komponente sind für jede Änderung nachvollziehbar.
12. Der State muss ohne laufende DCS-Instanz rekonstruierbar und testbar sein.
13. DCS- oder MOOSE-Meldungen werden normalisiert und validiert, bevor sie den CampaignState ändern.
14. Gleichartige DCS-Ereignisse dürfen keine doppelte Ressourcengutschrift oder doppelte Verluste erzeugen.
15. MOOSE bleibt der taktische Runtime-Unterbau.

## 4. Persistenzmodell

Empfohlene Trennung:

```text
EVENT_STORE
SNAPSHOT_STORE
READ_MODEL_STORE
AUDIT_STORE
DCS_MAPPING_STORE
SCHEMA_REGISTRY
```

### 4.1 Event Store

Enthält die unveränderliche Ereignisfolge.

### 4.2 Snapshot Store

Enthält periodisch erzeugte vollständige oder sektorweise Snapshots zur schnelleren Wiederherstellung.

### 4.3 Read Model Store

Enthält abgeleitete, nicht autoritative Sichten für:

- Commander Views;
- Operationsübersichten;
- Ressourcenquellen und Fraktionskonten;
- Force-Generation-Warteschlangen;
- Kartenlayer;
- Spielerbriefings;
- Debugging und Telemetrie.

Read Models können jederzeit aus Event Store und Snapshots neu erzeugt werden.

### 4.4 Audit Store

Enthält LLM-, Prompt-, Validator-, Adjudikations- und Adapterdaten, die nicht automatisch Teil der simulierten Welt sind.

### 4.5 DCS Mapping Store

Verknüpft strategische Entitäten mit aktuell materialisierten DCS-/MOOSE-Objekten.

### 4.6 Schema Registry

Enthält Versionen und Kompatibilitätsregeln für:

```text
EVENT_ENVELOPE
CAMPAIGN_STATE
COMMANDER_VIEW
COMMANDER_DECISION
RESOURCE_SOURCE
RESOURCE_ACCOUNT
FORCE_GENERATION_ORDER
FORCE_PACKAGE
OPERATION
ADAPTER_COMMAND
ADAPTER_RESULT
```

## 5. Globale Campaign-Metadaten

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
  moose_adapter_version: string|null
  ruleset_version: string
  resource_model_version: string
  prompt_bundle_version: string
```

## 6. Identitäts- und Referenzsystem

Jede persistente Entität besitzt eine stabile ID.

Empfohlene Präfixe:

```text
CMP- campaign
FAC- faction
CMD- commander
SEC- sector
LOC- location
RTE- route
SEG- route segment
NOD- access, network or logistics node
ACT- actor
ORG- organization
FPG- force package
UNT- force unit or cell
AST- asset
RSC- resource source
RAC- resource account
RSV- resource reservation
RTX- resource transfer
FGN- force generation order
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

## 7. Fraktionen und DCS-Koalitionen

### 7.1 Kanonische Kampagnenfraktionen

```text
ISAF
AFGHAN_STATE
TALIBAN
HAQQANI
HIG
```

Nicht kommandierte Quellhalter und neutrale Akteure werden separat geführt.

```yaml
faction:
  faction_id: string
  faction_type: isaf|afghan_state|taliban|haqqani|hig|neutral|civilian|non_commanded
  dcs_coalition: blue|red|neutral|null
  display_name: string
  active: boolean
  strategic_alignment: string
  resource_ownership_policy: isolated|shared_by_agreement|hierarchical|source_holder
  command_model: centralized|federated|networked|fragmented|non_commanded
  default_visibility_policy: string
```

Verbindlich:

```text
ISAF.dcs_coalition = BLUE
AFGHAN_STATE.dcs_coalition = BLUE
ISAF.faction_id != AFGHAN_STATE.faction_id
```

```text
SAME_DCS_COALITION
!= SAME_OWNERSHIP
!= SAME_COMMAND_AUTHORITY
!= AUTOMATIC_INFORMATION_SHARING
```

### 7.2 Commander

```yaml
commander:
  commander_id: string
  faction_id: string
  dcs_coalition: blue|red|neutral|null
  profile_ref: string
  authority_scope:
    geographic_scope: []
    organization_refs: []
    force_package_refs: []
    resource_account_refs: []
    permitted_resource_source_refs: []
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

Kanonische Commander:

```text
BLUE_ISAF_COMMANDER
AFGHAN_STATE_COMMANDER
TALIBAN_COMMANDER
HAQQANI_COMMANDER
HIG_COMMANDER
```

## 8. Geografisches Modell

### 8.1 Sector

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

### 8.2 Location

```yaml
location:
  location_id: string
  sector_id: string
  location_type: airbase|fob|cop|village|city|checkpoint|bridge|pass|crossing|compound|facility|market|warehouse|custom
  name: string
  coordinates:
    lat: float|null
    lon: float|null
    dcs_x: float|null
    dcs_y: float|null
  legal_owner_faction_id: string|null
  physical_controller_faction_id: string|null
  beneficiary_shares: {}
  access_shares: {}
  physical_status: intact|damaged|destroyed|abandoned|unknown
  access_status: open|restricted|contested|closed
  strategic_value: 0..100
  civilian_presence: 0..100
  no_strike_status: none|candidate|confirmed|restricted
  materialization_policy: virtual_only|event_only|hybrid|physical_required
```

```text
LEGAL_OWNER
!= PHYSICAL_CONTROLLER
!= CURRENT_BENEFICIARIES
```

### 8.3 Route

```yaml
route:
  route_id: string
  route_type: msr|asr|local_road|trail|air_corridor|facilitation_route|smuggling_route|custom
  origin_location_id: string
  destination_location_id: string
  segment_refs: []
  routing_anchor_refs: []
  primary_user_refs: []
  legal_owner_faction_id: string|null
  physical_controller_faction_id: string|null
  access_shares: {}
  capacity: 0..100
  concealment: 0..100
  travel_time_estimate: duration
  physical_condition: 0..100
  civilian_usage: 0..100
  interdiction_risk: 0..100
  compromise_status: unknown|suspected|confirmed|clear
  current_status: open|degraded|interdicted|closed
```

```yaml
route_segment:
  route_segment_id: string
  route_id: string
  geometry_ref: string
  routing_anchor_refs: []
  infrastructure_node_refs: []
  physical_controller_faction_id: string|null
  access_shares: {}
  capacity: 0..100
  physical_condition: 0..100
  threat_indicator_refs: []
  materialization_mapping_refs: []
```

```text
STRATEGIC_ROUTE
!= MOOSE_PATHLINE
!= GUARANTEED_DCS_GROUP_ROUTE
```

## 9. Bevölkerung, Governance und lokale Macht

Zustände werden pro Sektor und nicht als einzelner Loyalitätswert geführt.

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
  taliban_shadow_governance: 0..100
  taliban_shadow_justice: 0..100
  official_corruption: 0..100
  police_professionalism: 0..100
  police_abuse_risk: 0..100
  patronage_capture: 0..100
  local_powerbroker_influence: 0..100
  shura_representativeness: 0..100
  population_access_to_government: 0..100
```

```yaml
sector_population_state:
  sector_id: string
  perceived_security: 0..100
  freedom_of_movement: 0..100

  trust_in_isaf: 0..100
  trust_in_afghan_government: 0..100
  trust_in_ana: 0..100
  trust_in_anp: 0..100

  voluntary_support:
    TALIBAN: 0..100
    HAQQANI: 0..100
    HIG: 0..100

  coercive_compliance:
    TALIBAN: 0..100
    HAQQANI: 0..100
    HIG: 0..100

  fear:
    ISAF: 0..100
    AFGHAN_STATE: 0..100
    TALIBAN: 0..100
    HAQQANI: 0..100
    HIG: 0..100

  grievance:
    ISAF: 0..100
    AFGHAN_STATE: 0..100
    TALIBAN: 0..100
    HAQQANI: 0..100
    HIG: 0..100

  information_willingness:
    ISAF: 0..100
    AFGHAN_STATE: 0..100
    TALIBAN: 0..100
    HAQQANI: 0..100
    HIG: 0..100

  political_alienation: 0..100
  dual_alignment: 0..100
  displacement_pressure: 0..100
```

Verbindlich:

```text
COMPLIANCE != SUPPORT
PRESENCE != LEGITIMACY
PROJECT_OUTPUT != POSITIVE_POLITICAL_EFFECT
SECURITY_FORCE_PRESENT != POPULATION_PROTECTED
POPULATION != OWNED_RESOURCE
```

## 10. Lokale Akteure und Organisationen

```yaml
actor:
  actor_id: string
  actor_type: commander|official|elder|broker|facilitator|source|specialist|civilian_leader|local_commander|other
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
  organization_type: military|police|intelligence|political|government|tribal|commercial|criminal|civilian|network
  parent_organization_id: string|null
  member_actor_refs: []
  controlled_force_package_refs: []
  controlled_force_unit_refs: []
  controlled_resource_account_refs: []
  geographic_scope: []
  cohesion: 0..100
  command_reliability: 0..100
  political_influence: 0..100
  status: active|fragmented|merged|dissolved|inactive
```

## 11. ForcePackage und ForceUnit

### 11.1 Begriffstrennung

```text
ForcePackage
= strategisches, ressourcengedecktes Kräftepaket,
  das verfügbar, reserviert und materialisiert werden kann

ForceUnit
= persistente Teilstruktur oder konkrete Einheit innerhalb
  eines ForcePackage
```

Ein ForcePackage kann genau eine DCS-Gruppe, mehrere DCS-Gruppen oder ein zeitlich begrenztes Missionspaket repräsentieren. Die konkrete Zuordnung wird über MOOSE- und DCS-Mappings geführt.

### 11.2 ForcePackage

```yaml
force_package:
  force_package_id: string
  owner_faction_id: string
  owner_organization_id: string|null
  package_type: ground_unit|insurgent_cell|support_cell|qrf|convoy|air_mission_capacity|isr_package|logistics_package|other
  template_ref: string
  source_force_generation_order_id: string|null
  component_unit_refs: []
  home_location_id: string|null
  current_location_id: string|null
  readiness_state: planned|forming|available|reserved|assigned|deployed|recovering|maintenance|degraded|lost|disbanded
  readiness: 0..100
  cohesion: 0..100
  leadership_quality: 0..100
  command_reliability: 0..100
  current_strength_band: string
  assigned_operation_id: string|null
  resource_provenance_refs: []
  materialization_status: virtual|reserved|materializing|physical|dematerializing|lost
  materialization_policy: virtual_only|event_only|hybrid|physical_required
```

### 11.3 ForceUnit

```yaml
force_unit:
  unit_id: string
  parent_force_package_id: string
  faction_id: string
  organization_id: string|null
  unit_type: conventional|special_operations|partner_force|militia|insurgent_cell|support_cell|technical_team
  echelon_or_size_band: string
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
  casualty_state: 0..100
  exposure_status: hidden|suspected|detected|identified|engaged
  status: ready|tasked|moving|staging|engaged|recovering|degraded|destroyed|disbanded
```

### 11.4 ISAF Assets und Capabilities

ISAF-Luft-, ISR-, MEDEVAC-, EOD- und weitere Enabler sind keine gemeinsamen Grundressourcen aus Dokument 17.

```yaml
capability_asset:
  asset_id: string
  owner_faction_id: ISAF|AFGHAN_STATE
  owner_organization_id: string
  asset_type: aircraft|helicopter|uav|ground_vehicle|artillery|sensor|medical|eod|logistics|advisor|other
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
  reserve_category: uncommitted|local_reserve|regional_reserve|theater_reserve|emergency_only|recovery_protected
  assigned_operation_id: string|null
```

## 12. Gemeinsame Ressourcenarchitektur

Version 1 verwendet genau drei gemeinsame umkämpfte Grundressourcen:

```text
RECRUITABLE_MANPOWER
FINANCE
MATERIEL
```

Nicht als gemeinsame Grundressourcen geführt werden:

```text
LEGITIMACY
REPUTATION
VOLUNTARY_SUPPORT
COERCIVE_CONTROL
PRESTIGE
LOYALTY
COMMAND_COHESION
HUMINT_ACCESS
SPECIALIST_ACCESS
AIRLIFT
ISR
MEDEVAC
```

Diese Größen sind politische Zustände, Zugänge, organisatorische Gates oder Capability Assets.

### 12.1 ResourceSource

```yaml
resource_source:
  resource_source_id: string
  resource_type: RECRUITABLE_MANPOWER|FINANCE|MATERIEL
  source_type: population|legal_economy|state_revenue|donor_support|external_insurgent_support|illicit_economy|warehouse|cache|convoy|other
  region_id: string|null
  location_id: string|null
  legal_owner_faction_id: string|null
  physical_controller_faction_id: string|null
  capacity: number
  current_available: number
  regeneration_per_turn: number|null
  regeneration_interval: duration|null
  disruption_level: 0..100
  exhaustion_level: 0..100
  concealment: 0..100
  compromise_risk: 0..100
  beneficiary_shares: {}
  access_shares: {}
  status: active|degraded|isolated|exhausted|destroyed
  state_version: integer
```

### 12.2 ResourceAccount

```yaml
resource_account:
  resource_account_id: string
  faction_id: string
  resource_type: RECRUITABLE_MANPOWER|FINANCE|MATERIEL
  available: number
  reserved: number
  committed: number
  in_transit: number
  degraded_or_unusable: number
  state_version: integer
```

Verbindliche Invariante:

```text
available
+ reserved
+ committed
+ in_transit
+ degraded_or_unusable
<= total_credited_from_sources_and_transfers
```

### 12.3 ResourceReservation

```yaml
resource_reservation:
  reservation_id: string
  resource_account_id: string
  resource_type: RECRUITABLE_MANPOWER|FINANCE|MATERIEL
  requesting_commander_id: string
  force_generation_order_id: string|null
  operation_id: string|null
  quantity: number
  reserved_at: datetime
  expires_at: datetime|null
  status: requested|approved|active|consumed|released|expired|cancelled
  state_version_created: integer
```

### 12.4 ResourceTransfer

```yaml
resource_transfer:
  transfer_id: string
  resource_type: FINANCE|MATERIEL|RECRUITABLE_MANPOWER
  source_account_id: string
  destination_account_id: string
  quantity: number
  agreement_ref: string|null
  transport_operation_ref: string|null
  ownership_transfer: boolean
  state: proposed|approved|reserved|in_transit|partially_delivered|delivered|lost|destroyed|cancelled
  idempotency_key: string
```

Ein Transfer erzeugt keine neue Ressource.

```text
TRANSFER != GENERATION
DUPLICATE_DELIVERY_EVENT != SECOND_CREDIT
```

### 12.5 AccessNode und FactionShare

```yaml
access_node:
  access_node_id: string
  node_type: district|route|checkpoint|market|crossing|warehouse|cache|revenue_node|recruitment_network|support_channel|other
  region_id: string|null
  location_id: string|null
  legal_owner_faction_id: string|null
  physical_controller_faction_id: string|null
  connected_resource_source_refs: []
  beneficiary_shares: {}
  access_shares: {}
  disruption_level: 0..100
  materialization_policy: virtual_only|event_only|hybrid|physical_required
```

```yaml
faction_share:
  share_id: string
  faction_id: string
  source_or_node_ref: string
  share_type: access|beneficiary|control_claim|recruitment|revenue
  percentage: 0..100
  effective_from: datetime
  effective_until: datetime|null
  basis_event_refs: []
```

## 13. Resource Flow und Kampagnenturn

```text
RESOURCE_SOURCE_TICK
-> SOURCE_GENERATION
-> ACCESS_SHARE_CALCULATION
-> BENEFICIARY_ALLOCATION
-> RESOURCE_ACCOUNT_CREDIT
-> RESERVATION_OR_TRANSFER
-> FORCE_GENERATION_OR_OPERATION
-> PHYSICAL_RESULT
-> CONTROL_AND_SHARE_UPDATE
```

```yaml
resource_flow:
  resource_flow_id: string
  resource_source_id: string
  resource_type: RECRUITABLE_MANPOWER|FINANCE|MATERIEL
  gross_quantity: number
  disruption_loss: number
  leakage_loss: number
  allocations:
    - faction_id: string
      quantity: number
      destination_account_id: string
  generated_at: datetime
  event_ref: string
```

Bestandsformel:

```text
STOCK_NEXT
=
MIN(
  CAPACITY,
  STOCK_CURRENT
  + GENERATED
  + TRANSFERRED_IN
  - RESERVED_OR_COMMITTED
  - CONSUMED
  - DESTROYED
  - TRANSFERRED_OUT
  - DIVERTED
)
```

## 14. Force Generation

### 14.1 ForceGenerationOrder

```yaml
force_generation_order:
  force_generation_order_id: string
  faction_id: string
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
  lifecycle_state: proposed|validating|rejected|resources_reserved|recruiting|training|equipping|forming|available|cancelled|failed
  generated_force_package_id: string|null
```

### 14.2 Gemeinsame Validierungsformel

```text
RECRUITABLE_MANPOWER
+ FINANCE
+ MATERIEL
+ TIME
+ FACTION_SPECIFIC_ORGANIZATIONAL_GATE
-> FORCE_PACKAGE
```

### 14.3 Fraktionsspezifische Gates

```text
ISAF:
  NATIONAL_FORCE_POOL
  COALITION_COMMITMENT
  REPLACEMENT_CAPACITY
  TIME

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

ISAF rekrutiert nicht aus afghanischen Manpower-Quellen.

```text
NO_ISAF_RECRUITMENT_FROM_AFGHAN_MANPOWER
```

## 15. RED-Netzwerkknoten und Capability Packages

```yaml
network_node:
  node_id: string
  owner_faction_id: string
  node_type: sanctuary|border_entry|transit|facilitation|safehouse|cache|training|finance|specialist|staging|surveillance|media|other
  location_id: string|null
  connected_route_refs: []
  connected_resource_source_refs: []
  capacity: 0..100
  concealment: 0..100
  redundancy: 0..100
  replacement_difficulty: 0..100
  compromise_risk: 0..100
  opposing_pressure: 0..100
  visibility_by_faction: {}
  status: active|degraded|quarantined|compromised|abandoned|destroyed
```

```yaml
capability_package:
  capability_package_id: string
  owner_faction_id: string
  sponsor_actor_id: string|null
  strategic_effect: string
  target_ref: string|null
  target_intelligence_level: 0..100
  assigned_force_package_refs: []
  materiel_reservation_refs: []
  finance_reservation_refs: []
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

Ein `CapabilityPackage` ist keine Ressource. Es ist ein readiness- und gate-geprüftes Bündel aus Kräften, Ressourcenreservierungen, Zugängen und Fähigkeiten.

## 16. Beziehungen, Vereinbarungen und Nachrichten

```yaml
relationship_state:
  relationship_id: string
  subject_faction_id: string
  object_faction_id: string
  geographic_scope: []
  formal_alignment: 0..100
  political_alignment: 0..100
  ideological_alignment: 0..100
  political_trust: 0..100
  operational_trust: 0..100
  intelligence_sharing_willingness: 0..100
  logistics_cooperation_willingness: 0..100
  finance_support_willingness: 0..100
  materiel_support_willingness: 0..100
  training_support_willingness: 0..100
  enabler_dependency: 0..100
  command_friction: 0..100
  transition_pressure: 0..100
  sovereignty_respect: 0..100
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
  agreement_type: information_exchange|transit_access|finance_transfer|materiel_transfer|resource_source_share|specialist_support|enabler_support|training_support|joint_operation|revenue_sharing|local_non_aggression|temporary_truce|withdrawal|other
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

## 17. Information, Beliefs und Memory

### 17.1 Objective Information Item

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

### 17.2 Commander Belief

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

Resource-bezogene Beliefs müssen unterscheiden:

```text
KNOWN_RESOURCE_STOCK
ESTIMATED_RESOURCE_STOCK
BELIEVED_SOURCE_LOCATION
BELIEVED_PHYSICAL_CONTROLLER
BELIEVED_BENEFICIARY_SHARE
BELIEVED_ACCESS_SHARE
```

### 17.3 Commander Memory

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

## 18. MissionDemand, Collection und Targeting

```yaml
mission_demand:
  demand_id: string
  requesting_commander_id: string
  owning_faction_id: string
  demand_type: string
  desired_effect: string
  strategic_context: string
  geographic_scope: []
  urgency: routine|priority|immediate|emergency
  required_by: datetime|null
  intelligence_basis_refs: []
  required_capabilities: []
  required_partner_approval_refs: []
  required_resource_source_refs: []
  acceptable_alternatives: []
  political_constraints: []
  civilian_constraints: []
  assessment_requirements: []
  priority_score: number|null
  lifecycle_state: draft|submitted|validated|partner_review|prioritized|approved|allocated|tasked|executing|complete|denied|cancelled|aborted
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
  dissemination_scope: []
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

`CAPTURE`, `DETENTION`, `DISARMAMENT` und `DEMOBILIZATION` sind mögliche Kampagneneffekte, aber keine garantiert technisch verfügbare DCS-Wirkung.

## 19. Operation und Task Lifecycle

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
  participant_force_package_refs: []
  supporting_capability_asset_refs: []
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

## 20. DCS-/MOOSE-Materialisierung

```yaml
materialization_mapping:
  mapping_id: string
  strategic_entity_ref: string
  dcs_session_id: string
  dcs_object_type: group|unit|static|zone|warehouse|airbase|task|cargo|other
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
SAME_ADAPTER_COMMAND_ID != DUPLICATE_MATERIALIZATION
```

Der Adapter erhält ausschließlich validierte Fachobjekte. Er entscheidet anhand geprüfter, versionierter Mappings, welche MOOSE-Klasse oder vorhandene MOOSE-Funktion verwendet wird.

## 21. Event Envelope

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
  idempotency_key: string|null
  aggregate_type: string
  aggregate_id: string
  expected_state_version: integer|null
  resulting_state_version: integer
  payload: object
  metadata:
    dcs_session_id: string|null
    turn_id: string|null
    operation_id: string|null
    force_generation_order_id: string|null
    model_identifier: string|null
    prompt_version: string|null
    adjudication_seed: integer|null
```

## 22. Ereigniskategorien

### 22.1 Campaign und Zeit

```text
CAMPAIGN_INITIALIZED
CAMPAIGN_STARTED
CAMPAIGN_PAUSED
CAMPAIGN_RESUMED
CAMPAIGN_TIME_ADVANCED
CAMPAIGN_COMPLETED
SNAPSHOT_CREATED
```

### 22.2 Commander und Organisation

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

### 22.3 Information, Belief und Memory

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

### 22.4 Ressourcenquellen, Konten und Transfers

```text
RESOURCE_SOURCE_CREATED
RESOURCE_SOURCE_GENERATED
RESOURCE_SOURCE_DISRUPTED
RESOURCE_SOURCE_EXHAUSTED
RESOURCE_SOURCE_DESTROYED
ACCESS_SHARE_CHANGED
BENEFICIARY_SHARE_CHANGED
RESOURCE_ACCOUNT_CREDITED
RESOURCE_ACCOUNT_DEBITED
RESOURCE_RESERVED
RESOURCE_RESERVATION_RELEASED
RESOURCE_COMMITTED
RESOURCE_CONSUMED
RESOURCE_TRANSFER_REQUESTED
RESOURCE_TRANSFER_APPROVED
RESOURCE_TRANSFER_STARTED
RESOURCE_TRANSFER_PARTIALLY_DELIVERED
RESOURCE_TRANSFER_COMPLETED
RESOURCE_TRANSFER_DISRUPTED
RESOURCE_TRANSFER_LOST
RESOURCE_TRANSFER_DESTROYED
```

### 22.5 Force Generation und Kräfte

```text
FORCE_GENERATION_REQUESTED
FORCE_GENERATION_VALIDATED
FORCE_GENERATION_REJECTED
FORCE_GENERATION_RESOURCES_RESERVED
FORCE_GENERATION_STARTED
FORCE_GENERATION_PHASE_CHANGED
FORCE_GENERATION_COMPLETED
FORCE_GENERATION_CANCELLED
FORCE_PACKAGE_CREATED
FORCE_PACKAGE_AVAILABLE
FORCE_PACKAGE_RESERVED
FORCE_PACKAGE_ASSIGNED
FORCE_PACKAGE_DEGRADED
FORCE_PACKAGE_LOST
FORCE_PACKAGE_DISBANDED
FORCE_UNIT_STATUS_CHANGED
ASSET_READINESS_CHANGED
```

### 22.6 Beziehungen und Vereinbarungen

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

### 22.7 MissionDemand, Targeting und Operations

```text
MISSION_DEMAND_CREATED
MISSION_DEMAND_PARTNER_REVIEW_REQUESTED
MISSION_DEMAND_PARTNER_ACCEPTED
MISSION_DEMAND_PARTNER_DECLINED
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

### 22.8 DCS und MOOSE

```text
DCS_SESSION_STARTED
DCS_SESSION_ENDED
ENTITY_MATERIALIZATION_REQUESTED
ENTITY_MATERIALIZED
ENTITY_SYNCHRONIZED
ENTITY_MISSING_IN_DCS
ENTITY_DEMATERIALIZED
PHYSICAL_ENTITY_REMOVED
DCS_DAMAGE_REPORTED
DCS_DESTRUCTION_REPORTED
DCS_POSITION_REPORTED
DCS_TASK_RESULT_REPORTED
MOOSE_TASK_STATE_CHANGED
```

### 22.9 Nur adjudizierte Kampagnenergebnisse

```text
FORCE_PACKAGE_DETAINED
FORCE_PACKAGE_DISARMED
FORCE_PACKAGE_DEMOBILIZED
FORCE_PACKAGE_DEFECTED
```

Diese Ereignisse dürfen niemals allein aus dem Verschwinden oder Löschen einer DCS-Gruppe abgeleitet werden.

## 23. State Reducer

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
- DCS-Meldungen ungeprüft als endgültiges Ergebnis übernehmen;
- Zugang, Unterstützung oder Prestige direkt in Einheiten umwandeln.

## 24. Optimistic Concurrency und Locks

Jeder schreibende Vorgang enthält die erwartete State-Version.

```text
IF expected_state_version != current_state_version
THEN reject with STATE_VERSION_CONFLICT
```

Zusätzliche Sperren:

```text
RESOURCE_SOURCE_LOCK
RESOURCE_ACCOUNT_LOCK
RESOURCE_RESERVATION_LOCK
FORCE_GENERATION_LOCK
FORCE_PACKAGE_LOCK
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

## 25. Snapshots

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

## 26. Schema-Versionierung und Migration

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
6. Die Migration von `ResourcePool` zu `ResourceSource`, `ResourceAccount` und `CapabilityAsset` muss ausdrücklich versioniert werden.

## 27. Recovery nach Abbruch oder DCS-Ausfall

```text
1. letzten gültigen Snapshot laden
2. Events bis zum letzten bestätigten Sequence-Wert wiedergeben
3. offene Locks prüfen und bereinigen
4. Force-Generation-Aufträge rekonstruieren
5. laufende Operationen auf Recovery-Regeln prüfen
6. DCS-Mappings als nicht bestätigt markieren
7. neue DCS-Session starten
8. erforderliche Entitäten über MOOSE neu materialisieren
9. Synchronisationsereignisse schreiben
```

Ein DCS-Ausfall darf:

- keine Ressourcen duplizieren;
- keine bestätigten Verluste rückgängig machen;
- keine abgeschlossene Force Generation erneut gutschreiben;
- keinen identischen Adapterbefehl doppelt materialisieren.

## 28. Idempotenz

Externe Meldungen benötigen einen stabilen Idempotency Key.

```yaml
external_event_identity:
  source_system: string
  source_session_id: string
  source_event_id: string
```

Bereits verarbeitete Schlüssel werden nicht erneut als State-Änderung angewandt.

Verbindlich:

```text
ONE_CARGO_OR_TRANSFER_ID
-> AT_MOST_ONE_FINAL_CREDIT
```

```text
ONE_FORCE_GENERATION_ORDER
-> AT_MOST_ONE_FORCE_PACKAGE
```

```text
ONE_ADAPTER_COMMAND_ID
-> AT_MOST_ONE_PHYSICAL_EXECUTION
```

## 29. Audit- und Reproduzierbarkeitsanforderungen

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

Für jede Force Generation müssen verknüpfbar sein:

```text
SOURCE_REQUEST
RESOURCE_SOURCE_PROVENANCE
RESOURCE_RESERVATIONS
ORGANIZATIONAL_GATES
GENERATION_PHASES
GENERATED_FORCE_PACKAGE
MATERIALIZATION_RESULTS
```

Für jede Operation müssen verknüpfbar sein:

```text
SOURCE_DECISION
RESOURCE_RESERVATIONS
FORCE_PACKAGE_ASSIGNMENTS
OPERATION_TASKS
DCS_MAPPINGS
EXECUTION_EVENTS
ASSESSMENT
MEMORY_AND_RELATIONSHIP_EFFECTS
```

## 30. Sichtbarkeit und Datenschutz innerhalb der Simulation

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

- gegnerische Ressourcenquellen und Kontostände;
- exakte Beneficiary- und Access-Shares;
- versteckte Knoten;
- nicht erkannte Fraktionsbeziehungen;
- genaue gegnerische Operationspläne;
- objektive Quellenzuverlässigkeit;
- andere Commander-Beliefs und Memories;
- interne BLUE-Targeting- und NSL-Daten;
- Afghan-State- und ISAF-Informationen, sofern nicht geteilt.

## 31. Mindestinvarianten

```text
NO_NEGATIVE_RESOURCE_CAPACITY
NO_RESOURCE_GENERATION_WITHOUT_SOURCE
NO_DOUBLE_RESOURCE_RESERVATION
NO_DUPLICATE_RESOURCE_CREDIT
NO_FORCE_PACKAGE_WITHOUT_RESOURCE_COMMITMENT
NO_FORCE_PACKAGE_WITHOUT_TEMPLATE_REFERENCE
NO_ISAF_RECRUITMENT_FROM_AFGHAN_MANPOWER
NO_POPULATION_OWNERSHIP
NO_REPUTATION_TO_DIRECT_UNIT_CONVERSION
NO_FOREIGN_RESOURCE_CONTROL_WITHOUT_AGREEMENT
NO_AFGHAN_UNIT_OWNED_BY_ISAF
NO_PHYSICAL_EXECUTION_BEFORE_APPROVAL
NO_EXECUTE_COMPLEX_OPERATION_WITHOUT_READY_PACKAGE
NO_KINETIC_BLUE_EFFECT_WITHOUT_REQUIRED_TARGETING_STATUS
NO_DUPLICATE_ACTIVE_DCS_MAPPING
NO_STATE_UPDATE_WITH_STALE_VERSION
NO_COMMANDER_VIEW_WITH_UNAUTHORIZED_WORLD_TRUTH
NO_EVENT_SEQUENCE_GAP
NO_SNAPSHOT_WITH_INVALID_HASH
NO_MISSING_DCS_OBJECT_AUTOMATICALLY_CLASSIFIED_AS_DESTROYED
```

## 32. Minimaler Implementierungsumfang

Für den ersten deterministischen Test Harness sind erforderlich:

```text
Campaign
Faction
Commander
Sector
Location
Route
RouteSegment
PopulationState
Actor
Organization
ResourceSource
ResourceAccount
ResourceReservation
ResourceTransfer
AccessNode
FactionShare
ForceGenerationOrder
ForcePackage
ForceUnit
CapabilityAsset
InformationItem
CommanderBelief
RelationshipState
Agreement
MissionDemand
Operation
OperationTask
MaterializationMapping
EventEnvelope
Snapshot
```

Noch nicht erforderlich:

- vollständige DCS-Materialisierung;
- komplette ATO-Projektion;
- vollständige Targeting-Automation;
- semantische Vektorsuche für Memory;
- Echtzeit-Multi-LLM-Kommunikation;
- vollständige volkswirtschaftliche Modellierung.

## 33. Empfohlene technische Ablagestruktur

```text
campaign/
  schemas/
    campaign-state.schema.json
    event-envelope.schema.json
    resource-source.schema.json
    resource-account.schema.json
    resource-transfer.schema.json
    force-generation-order.schema.json
    force-package.schema.json
    operation.schema.json
  reducers/
    campaign_reducer
    resource_source_reducer
    resource_account_reducer
    force_generation_reducer
    force_package_reducer
    operation_reducer
    relationship_reducer
  projections/
    commander_view
    operation_board
    resource_flow_board
    force_generation_board
    map_layers
  migrations/
  snapshots/
  tests/
```

Die Programmiersprache ist nicht festgelegt. Schnittstellen und Invarianten gelten für Python, Elixir oder eine andere geeignete Laufzeit.

## 34. Acceptance-Kriterien

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
12. Recovery nach simuliertem Prozess- oder DCS-Abbruch;
13. gleiche Quelle erzeugt bei gleichem State dieselben Fraktionsanteile;
14. ein Manpower-Anteil kann nicht zwei Force Packages finanzieren;
15. ein zerstörter Materielbestand kann nicht erneut gutgeschrieben werden;
16. ISAF kann keine afghanische Einheit als eigenes Force Package übernehmen;
17. ein Force-Generation-Auftrag erzeugt höchstens ein Force Package;
18. ein identischer Adapterbefehl erzeugt höchstens eine physische Repräsentation;
19. DCS-Löschung erzeugt ohne Adjudication weder Gefangennahme noch Entwaffnung;
20. fünf Commander können parallel auf konsistenten State-Versionen arbeiten.

## 35. Folgedokumente

Dieses Schema ist verbindliche Grundlage für:

```text
02-common-commander-model.md
07-runtime-rulebook-and-action-schema.md
09-orchestrator-architecture-and-adjudication.md
12-multi-commander-test-scenarios.md
14-deterministic-test-harness-and-scripted-commanders.md
15-orchestrator-technology-selection-and-deployment-model.md
19-language-neutral-contracts-and-json-schemas.md
```

Vor Runtime-Implementierung müssen die sprachneutralen Verträge in Dokument 19 aus diesem Modell abgeleitet und maschinenlesbar versioniert werden.
