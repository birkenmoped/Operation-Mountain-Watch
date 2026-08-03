---
document_id: OMW-SP-LLM-COMMANDERS-BLUE-MISSION-DEMAND
status: DRAFT_RUNTIME_DESIGN
document_class: BLUE_MISSION_DEMAND_FORCE_ALLOCATION_TARGETING_SCHEMA
scenario_period: 2010-08-01/2011-12-31
source_branch: docs/optional-llm-commanders
validated_in_dcs: false
authoritative_for:
  - ISAF mission demand and force-allocation objects
  - Afghan partner approval and ownership boundaries
  - BLUE targeting and air-support gates
  - ISAF support for Afghan resource and force generation
---

# BLUE MissionDemand, Partner Coordination, Force Allocation und Targeting Schema

## 1. Zweck

Dieses Dokument definiert die maschinenlesbaren Objekte zwischen:

- strategischer Entscheidung des `BLUE_ISAF_COMMANDER`;
- operativer Bedarfsformulierung;
- ResourceSource-Schutz und Afghan-State-Unterstützung;
- ISAF-Force- und Enabler-Allokation;
- Partneranfrage und afghanischer Zustimmung;
- Target Development und Air Support;
- DCS-/MOOSE-Ausführung;
- MISREP, BDA und Campaign Assessment.

```text
BLUE_ISAF_COMMANDER_DECISION
-> MISSION_DEMAND
-> VALIDATION_AND_PRIORITY
-> OPTIONAL_AFGHAN_PARTNER_REVIEW
-> ISAF_FORCE_AND_ENABLER_ALLOCATION
-> AFGHAN_RESOURCE_OR_FORCE_RESERVATION
-> JOINT_OR_SINGLE_FACTION_OPERATION_PLAN
-> DCS_MOOSE_EXECUTION
-> MISREP_BDA_CAMPAIGN_ASSESSMENT
```

Der BLUE ISAF Commander fordert Wirkungen und priorisiert Bedarfe. Er erzeugt weder direkt einen ATO-Eintrag noch eine Waffenfreigabe oder afghanische Einheit.

## 2. Verbindliche Trennungen

```text
MISSION_DEMAND != EXECUTION_ORDER
TARGET_NOMINATION != TARGET_AUTHORIZATION
ATO_TASKING != WEAPONS_RELEASE
SENSOR_DETECTION != POSITIVE_IDENTIFICATION
POSITIVE_IDENTIFICATION != HOSTILE_INTENT
AFGHAN_LED != ENABLER_INDEPENDENT
AVAILABLE_ASSET != UNCOMMITTED_ASSET
TACTICAL_SUCCESS != CAMPAIGN_SUCCESS
SAME_DCS_COALITION != SAME_FORCE_OWNERSHIP
PARTNER_SUPPORT != COMMAND_TRANSFER
MATERIEL_TRANSFER != READY_AFGHAN_UNIT
CAPTURE_EFFECT != GUARANTEED_DCS_CAPTURE
```

## 3. MissionDemand

```yaml
mission_demand:
  schema_version: "2.0"
  demand_id: string
  originating_turn_id: string
  owning_commander_id: BLUE_ISAF_COMMANDER
  owning_faction_id: ISAF
  requesting_element: string
  campaign_time_created: datetime
  demand_type: enum
  urgency: ROUTINE|PRIORITY|IMMEDIATE|EMERGENCY
  decision_horizon: tactical|operational|strategic

  strategic_context:
    supported_goal_ids: []
    campaign_problem: string
    desired_campaign_effects: []
    unacceptable_outcomes: []
    priority_area_refs: []

  operational_need:
    desired_effect: enum
    target_or_problem_refs: []
    resource_source_refs: []
    access_node_refs: []
    supported_isaf_force_refs: []
    requested_afghan_force_refs: []
    geographic_scope: []
    earliest_start: datetime|null
    latest_completion: datetime|null
    required_duration: string|null
    persistence_required: 0..100

  intelligence_basis:
    information_item_refs: []
    confidence: 0..100
    intelligence_gaps: []
    deception_risk: 0..100
    last_verified: datetime|null

  partner_requirements:
    afghan_partner_required: boolean
    requested_lead_faction: ISAF|AFGHAN_STATE|null
    partner_approval_required: boolean
    requested_afghan_force_package_refs: []
    requested_afghan_resource_support: []
    requested_coalition_enablers: []

  constraints:
    roe_profile_ref: string
    no_strike_list_version: string
    airspace_control_ref: string|null
    civilian_harm_limit: 0..100
    political_risk_limit: 0..100
    force_risk_limit: 0..100
    national_caveats: []
    geographic_limits: []
    timing_limits: []

  requested_capabilities: []
  preferred_execution_modes: []
  acceptable_alternatives: []
  assessment_requirements: []

  lifecycle_state: enum
  priority_score: 0..100
  priority_rationale: []
```

## 4. Demand Types

```text
POPULATION_PROTECTION
BASE_DEFENSE
ROUTE_SECURITY
CONVOY_SUPPORT
FORCE_PROTECTION
PARTNER_FORCE_SUPPORT
PARTNER_OPERATION_REQUEST
ISR_COLLECTION
TARGET_DEVELOPMENT
NETWORK_DISRUPTION
RESOURCE_SOURCE_PROTECTION
RESOURCE_FLOW_INTERDICTION
REVENUE_NODE_SECURITY
RECRUITMENT_SITE_PROTECTION
MATERIEL_TRANSFER_PROTECTION
ANSF_FORCE_GENERATION_SUPPORT
TRAINING_SUPPORT
ADVISOR_SUPPORT
MATERIEL_TRANSFER
FINANCE_SUPPORT
DIRECT_ACTION
AIR_ASSAULT
CAS_SUPPORT
AIR_INTERDICTION
MEDEVAC_SUPPORT
CSAR_SUPPORT
LOGISTICS_SUPPORT
EOD_ROUTE_CLEARANCE
SHOW_OF_FORCE
INFORMATION_EFFECT
GOVERNANCE_SUPPORT
STABILITY_PRESENCE
DECEPTION_OPERATION
RECOVERY_AND_RECONSTITUTION
```

`MATERIEL_TRANSFER` und `FINANCE_SUPPORT` erzeugen keine automatische afghanische Einheit.

## 5. Desired Effects

```text
OBSERVE
DETECT
IDENTIFY
CORRELATE
MONITOR
PROTECT
ESCORT
REASSURE
DETER
SUPPRESS
FIX
DELAY
DISRUPT
ISOLATE
INTERDICT
DENY_ACCESS
PROTECT_RESOURCE_SOURCE
RESTORE_RESOURCE_FLOW
REDUCE_RED_ACCESS_SHARE
INCREASE_AFGHAN_ACCESS_SHARE
CAPTURE_IF_FEASIBLE_AS_CAMPAIGN_EFFECT
RESCUE
EVACUATE
DESTROY
ENABLE_PARTNER
RESTORE_ROUTE
HOLD_AREA
SUPPORT_GOVERNANCE
REDUCE_CIVILIAN_RISK
```

`DESTROY` ist nur eine Wirkung unter mehreren. Änderungen von Fraktionsanteilen sind gewünschte Kampagneneffekte und werden nicht direkt vom Commander gesetzt.

## 6. MissionDemand Lifecycle

```text
DRAFT
SUBMITTED
VALIDATING
NEEDS_INFORMATION
PARTNER_REVIEW_REQUIRED
PARTNER_ACCEPTED
PARTNER_DECLINED
PARTNER_CONDITIONAL
PRIORITIZED
APPROVED
DEFERRED
DENIED
RESOURCING
PARTIALLY_RESOURCED
FULLY_RESOURCED
TASKED
EXECUTING
SUSPENDED
COMPLETE
PARTIALLY_COMPLETE
ABORTED
CANCELLED
ASSESSING
CLOSED
```

Zulässige Rücksprünge:

```text
VALIDATING -> NEEDS_INFORMATION
PARTNER_REVIEW_REQUIRED -> PARTNER_CONDITIONAL
RESOURCING -> DEFERRED
TASKED -> SUSPENDED
EXECUTING -> ABORTED
ASSESSING -> NEEDS_INFORMATION
```

## 7. Priorisierung

```yaml
priority_factors:
  catastrophic_loss_prevention: 0..100
  population_protection_value: 0..100
  friendly_force_protection_value: 0..100
  strategic_effect: 0..100
  terrorist_safe_haven_denial_value: 0..100
  time_sensitivity: 0..100
  intelligence_confidence: 0..100
  target_or_problem_persistence: 0..100
  partner_enablement_value: 0..100
  resource_source_value: 0..100
  resource_denial_value: 0..100
  route_or_logistics_value: 0..100
  transition_value: 0..100
  political_risk: 0..100
  civilian_harm_risk: 0..100
  resource_cost: 0..100
  opportunity_cost: 0..100
  sustainability: 0..100
```

Die konkrete Formel ist versioniert und testbar. Notfallregeln dürfen Scores nur mit protokollierter Begründung übersteuern.

## 8. Capability Request

```yaml
capability_request:
  capability_type: enum
  owner_faction_requirement: ISAF|AFGHAN_STATE|EITHER
  minimum_quantity: number
  preferred_quantity: number
  minimum_quality: 0..100
  start_window: {}
  duration: string|null
  location_or_orbit_ref: string|null
  persistence: 0..100
  response_time_required: string|null
  compatibility_requirements: []
  national_restrictions: []
  fallback_capabilities: []
```

Capability Types:

```text
GROUND_MANEUVER
QRF
ROUTE_CLEARANCE
EOD
FIXED_WING_CAS
ROTARY_WING_ATTACK
AIR_ASSAULT
TACTICAL_AIRLIFT
STRATEGIC_AIRLIFT
ISR_FMV
ISR_SIGINT
ISR_WIDE_AREA
UAS
AFAC
JTAC
ARTILLERY
MORTAR
MEDEVAC
CSAR
LOGISTICS
ENGINEER
CIVIL_AFFAIRS
INFORMATION_OPERATIONS
PARTNER_ADVISORY
INTELLIGENCE_FUSION
TRAINING_CAPACITY
```

## 9. ISAF Asset State

```yaml
isaf_asset:
  asset_id: string
  owner_faction_id: ISAF
  asset_type: string
  owning_organization: string
  command_relationship: OPCON|TACON|SUPPORT|COORDINATION_ONLY
  home_location_ref: string
  current_location_ref: string
  readiness_state: enum
  available_from: datetime|null
  endurance_remaining: number|null
  fuel_state: 0..100|null
  ammunition_state: 0..100|null
  crew_state: 0..100|null
  maintenance_state: 0..100|null
  recovery_required: boolean
  national_caveats: []
  weather_limits: []
  mission_qualifications: []
  current_commitment_refs: []
  reserve_category: enum
```

Readiness States:

```text
READY
ALERT
TASKED
ENROUTE
ON_STATION
ENGAGED
RETURNING
RECOVERING
MAINTENANCE
CREW_REST
WEATHER_HOLD
DAMAGED
UNAVAILABLE
DESTROYED
```

Reserve Categories:

```text
UNCOMMITTED
LOCAL_RESERVE
REGIONAL_RESERVE
THEATER_RESERVE
EMERGENCY_ONLY
RECOVERY_PROTECTED
```

## 10. ISAF Force Allocation

```yaml
force_allocation:
  allocation_id: string
  demand_id: string
  owner_faction_id: ISAF
  asset_or_force_package_id: string
  allocated_capability: string
  allocation_state: PROPOSED|RESERVED|CONFIRMED|TASKED|RELEASED|CANCELLED
  start_window: {}
  release_condition: string|null
  supported_element: string|null
  command_relationship_for_mission: string
  expected_consumption: {}
  recovery_requirement: {}
  conflicts_detected: []
  opportunity_cost: []
```

Eine Zuteilung benötigt:

```text
ASSET_READY
COMMAND_RELATIONSHIP_VALID
CAVEATS_COMPATIBLE
TIME_WINDOW_COMPATIBLE
LOCATION_AND_RANGE_VALID
RECOVERY_CAPACITY_AVAILABLE
NO_HIGHER_PRIORITY_LOCK
```

## 11. Afghan Partner Review

```yaml
afghan_partner_review:
  review_id: string
  demand_id: string
  requested_by_commander_id: BLUE_ISAF_COMMANDER
  reviewing_commander_id: AFGHAN_STATE_COMMANDER
  requested_lead_role: LEAD|SUPPORTED|SUPPORTING|HOLD_FORCE
  requested_force_package_refs: []
  requested_resource_account_refs: []
  offered_isaf_enabler_refs: []
  offered_finance_transfer_ref: string|null
  offered_materiel_transfer_ref: string|null
  proposed_command_relationship: string
  proposed_start_window: {}
  decision: PENDING|ACCEPTED|DECLINED|CONDITIONAL
  conditions: []
  decision_rationale: []
  expires_at: datetime|null
```

ISAF darf den Partner Review nicht überspringen, wenn afghanische Force Packages oder ResourceAccounts betroffen sind.

## 12. Afghan Partner Force Package

```yaml
partner_force_package:
  force_package_ref: string
  owner_faction_id: AFGHAN_STATE
  owner_commander_id: AFGHAN_STATE_COMMANDER
  owner_organization_ref: string
  mission_role: LEAD|SUPPORTED|SUPPORTING|SECURITY|HOLD_FORCE

  readiness_snapshot:
    personnel_present: 0..100
    leadership_quality: 0..100
    tactical_skill: 0..100
    staff_planning: 0..100
    discipline: 0..100
    logistics: 0..100
    intelligence: 0..100
    communications: 0..100
    eod_access: 0..100
    air_support_access: 0..100
    medevac_access: 0..100
    corruption_risk: 0..100
    abuse_risk: 0..100
    infiltration_risk: 0..100
    local_legitimacy: 0..100

  partner_approval_state: PENDING|ACCEPTED|DECLINED|CONDITIONAL
  afghan_resource_reservation_refs: []
  coalition_support_agreement_ref: string|null
  coalition_enablers_required: []
  mentor_or_liaison_required: boolean
  command_relationship: string
  mission_limitations: []
  fallback_if_partner_fails: string
```

```text
owner_faction_id remains AFGHAN_STATE
throughout the operation
```

## 13. Afghan Resource and Force-Generation Support

### 13.1 Support Request

```yaml
afghan_support_package:
  support_package_id: string
  requested_by: AFGHAN_STATE_COMMANDER
  offered_or_prioritized_by: BLUE_ISAF_COMMANDER
  support_type: FINANCE|MATERIEL|TRAINING|ADVISOR|ENABLER|INTELLIGENCE
  quantity_or_capacity: number|null
  source_ref: string
  destination_ref: string|null
  ownership_transfer: boolean
  agreement_ref: string
  delivery_or_availability_window: {}
  lifecycle_state: PROPOSED|APPROVED|RESERVED|IN_TRANSIT|AVAILABLE|PARTIALLY_DELIVERED|DELIVERED|LOST|CANCELLED
```

### 13.2 Keine Soforteinheit

```text
FINANCE_SUPPORT
+ MATERIEL_SUPPORT
!= READY_AFGHAN_FORCE_PACKAGE
```

Afghan Force Generation benötigt weiterhin:

```text
RECRUITABLE_MANPOWER
FINANCE
MATERIEL
TRAINING
RETENTION
LEADERSHIP
SUSTAINMENT
TIME
```

## 14. Reserve Policy

```yaml
reserve_policy:
  qrf_minimum_ready: number
  medevac_minimum_ready: number
  csar_minimum_ready: number
  base_defense_minimum: number
  fixed_wing_divert_reserve: number
  rotary_wing_recovery_reserve: number
  isr_retask_reserve: number
  logistics_contingency_reserve: number
  partner_support_contingency: number
```

Der Orchestrator blockiert Zuteilungen, die kritische Mindestreserven ohne Emergency Override unterschreiten.

## 15. ISR Collection Requirement

```yaml
collection_requirement:
  collection_id: string
  linked_demand_ids: []
  requesting_faction_id: ISAF|AFGHAN_STATE
  dissemination_scope: []
  priority_intelligence_requirement_ref: string|null
  essential_element_of_information: string
  subject_ref: string|null
  geographic_scope: []
  collection_window: {}
  required_confidence: 0..100
  required_update_rate: string|null
  acceptable_sensor_types: []
  source_protection_required: boolean
  collection_state: enum
```

Collection States:

```text
DRAFT
VALIDATED
QUEUED
ALLOCATED
COLLECTING
PARTIAL_RESULT
RESULT_AVAILABLE
NO_RESULT
COMPROMISED
CANCELLED
CLOSED
```

Eine ISAF-Collection wird nicht automatisch vollständig an Afghan State verteilt.

## 16. Target Development Object

```yaml
target_development:
  target_id: string
  target_category: PERSON|GROUP|FORCE_PACKAGE|VEHICLE|BUILDING|ROUTE|ACCESS_NODE|RESOURCE_SOURCE|AREA|CAPABILITY
  nomination_source: string
  linked_information_items: []

  identity_assessment:
    assessed_identity: string|null
    confidence: 0..100
    alternatives: []

  activity_assessment:
    observed_activity: []
    hostile_status_basis: []
    confidence: 0..100

  location_assessment:
    location_ref: string|null
    confidence: 0..100
    last_verified: datetime|null
    mobility: STATIC|SEMI_MOBILE|MOBILE|UNKNOWN

  context:
    civilian_presence: 0..100
    friendly_proximity: 0..100
    afghan_partner_proximity: 0..100
    protected_site_proximity: 0..100
    expected_pattern_of_life: []

  policy_checks:
    no_strike_list_result: CLEAR|POTENTIAL_MATCH|MATCH|NOT_CHECKED
    restricted_target_result: CLEAR|REVIEW_REQUIRED|BLOCKED
    roe_result: AUTHORIZED|REVIEW_REQUIRED|NOT_AUTHORIZED
    legal_review_ref: string|null

  effect_options: []
  collection_gaps: []
  lifecycle_state: enum
```

Target Lifecycle:

```text
DISCOVERED
CORRELATED
UNDER_DEVELOPMENT
NEEDS_COLLECTION
CANDIDATE
NOMINATED
REVIEWING
AUTHORIZED_FOR_SPECIFIC_EFFECT
DENIED
MONITOR_ONLY
EXPIRED
DISPROVEN
REMOVED
```

## 17. Targeting Decision

```yaml
targeting_decision:
  decision_id: string
  target_id: string
  requested_effect: string
  authority_level: string
  decision: enum
  authorized_window: {}
  authorized_methods: []
  prohibited_methods: []
  positive_identification_requirement: string
  collateral_constraints: []
  civilian_presence_limit: number|null
  friendly_proximity_limit: number|null
  terminal_control_requirement: string|null
  partner_coordination_requirement: string|null
  abort_conditions: []
  expiry: datetime
```

Decision Enum:

```text
CONTINUE_COLLECTION
MONITOR
NON_KINETIC_ONLY
CAPTURE_IF_FEASIBLE_AS_CAMPAIGN_EFFECT
INTERDICT
KINETIC_AUTHORIZED_WITH_CONDITIONS
DENIED
REMOVE_FROM_TARGET_SET
```

## 18. Air Support Request

```yaml
air_support_request:
  request_id: string
  linked_demand_id: string
  request_type: PREPLANNED|IMMEDIATE|EMERGENCY
  supported_force_package_ref: string
  supported_force_owner_faction: ISAF|AFGHAN_STATE
  requesting_controller: string|null
  desired_effect: string
  target_ref: string|null
  target_description: string|null
  target_location: {}
  friendly_positions: []
  civilian_context: []
  threat_context: []
  requested_time_window: {}
  requested_platform_or_capability: []
  weapons_constraints: []
  laser_requirements: {}
  communications_plan_ref: string|null
  airspace_control_ref: string|null
  partner_approval_ref: string|null
  lifecycle_state: enum
```

Lifecycle:

```text
DRAFT
SUBMITTED
VALIDATED
PRIORITIZED
APPROVED
TASKED
ON_CALL
DIVERTED
EXECUTING
COMPLETE
DENIED
CANCELLED
ABORTED
```

## 19. CAS Execution Gate

Vor einer physischen CAS-Wirkung müssen mindestens geprüft sein:

```text
SUPPORTED_FORCE_CONFIRMED
SUPPORTED_FORCE_OWNER_CONFIRMED
PARTNER_COORDINATION_VALID_IF_REQUIRED
TARGET_CORRELATED
FRIENDLY_POSITIONS_CURRENT
CIVILIAN_CONTEXT_ASSESSED
ROE_VALID
NSL_CLEAR
AIRSPACE_CONFLICT_CLEAR
COMMUNICATIONS_SUFFICIENT
CONTROLLER_AUTHORITY_VALID
WEAPON_SENSOR_COMPATIBLE
ABORT_PATH_AVAILABLE
```

Die Execution-Phasen bleiben:

```text
CHECK_IN
SITUATION_UPDATE
GAME_PLAN
CAS_BRIEF
READBACK
CORRELATION
ATTACK_CLEARANCE
ATTACK
ASSESSMENT
CHECK_OUT
```

## 20. Mission Package

```yaml
mission_package:
  package_id: string
  linked_demand_ids: []
  supported_goal_ids: []
  lead_faction_id: ISAF|AFGHAN_STATE
  supporting_faction_ids: []
  command_element: string
  isaf_ground_elements: []
  afghan_ground_elements: []
  air_elements: []
  isr_elements: []
  support_elements: []
  reserve_elements: []
  partner_approval_refs: []
  ownership_boundaries: {}
  command_relationships: {}
  communications_plan_ref: string
  airspace_plan_ref: string|null
  medical_plan_ref: string
  recovery_plan_ref: string
  roe_profile_ref: string
  target_authorization_refs: []
  resource_reservation_refs: []
  phases: []
  decision_points: []
  abort_conditions: []
  branch_plans: []
  sequel_plans: []
```

## 21. Mission Phases

```text
SHAPE
COLLECT
PREPARE
MOVE
ISOLATE
EXECUTE
EXPLOIT
HOLD
TRANSFER
RECOVER
ASSESS
```

`TRANSFER` bezeichnet Übergabe von Verantwortung oder Raum, nicht automatisch Eigentumsübertragung aller Kräfte und Ressourcen.

## 22. Recovery und Reconstitution

Jede größere Mission muss vor Freigabe definieren:

```text
FORCE_RECOVERY
MEDICAL_RECOVERY
AIRCRAFT_RECOVERY
RESERVE_RESTORE
AFGHAN_PARTNER_RECOVERY
MATERIEL_ACCOUNTING
RESOURCE_RESERVATION_RELEASE
```

Verluste wirken auf:

- ISAF Coalition Commitment;
- Force-Package-Readiness;
- Afghan-State-Rekrutierung und Retention;
- Materiel-Konten;
- politische und lokale Wahrnehmung.

## 23. ResourceSource- und AccessNode-Missionen

Eine Operation gegen oder zum Schutz einer ResourceSource benötigt:

```yaml
resource_source_operation:
  resource_source_ref: string
  access_node_refs: []
  known_legal_owner: string|null
  believed_physical_controller: string|null
  desired_effect: PROTECT|RESTORE|DISRUPT|INTERDICT|MONITOR
  assigned_force_package_refs: []
  required_capabilities: []
  civilian_and_economic_constraints: []
  assessment_requirements: []
```

Der Missionserfolg setzt keinen exakten neuen Share-Wert. Der Orchestrator adjudiziert die Veränderung anhand der objektiven Lage.

## 24. Assessment

```yaml
mission_assessment:
  demand_id: string
  operation_id: string|null
  tactical_effects: []
  force_package_effects: []
  resource_source_effects: []
  resource_transfer_effects: []
  population_effects: []
  governance_effects: []
  partner_capability_effects: []
  coalition_commitment_effects: []
  intelligence_gained: []
  uncertainties: []
  follow_up_demands: []
```

```text
TACTICAL_SUCCESS
!= RESOURCE_SOURCE_SECURED
!= POPULATION_PROTECTED
!= AFGHAN_CAPABILITY_IMPROVED
```

## 25. Validierungsregeln

```text
NO_AFGHAN_FORCE_WITHOUT_PARTNER_APPROVAL
NO_AFGHAN_FORCE_OWNED_BY_ISAF
NO_ISAF_RESOURCE_RESERVATION_AGAINST_AFGHAN_ACCOUNT
NO_MATERIEL_TRANSFER_WITHOUT_SOURCE_AND_DESTINATION
NO_SUPPORT_PACKAGE_TO_INSTANT_READY_UNIT
NO_TARGETING_GATE_BYPASS
NO_CRITICAL_RESERVE_VIOLATION_WITHOUT_OVERRIDE
NO_RESOURCE_SHARE_DIRECT_WRITE_BY_COMMANDER
NO_DCS_CAPTURE_ASSUMPTION
```

## 26. Mindesttests

```text
BLUE-001 Afghan unit request enters partner review
BLUE-002 Afghan State declines operation without enablers
BLUE-003 accepted partner operation retains Afghan ownership
BLUE-004 materiel transfer does not create ready unit
BLUE-005 finance support requires source account
BLUE-006 ISR sharing respects dissemination scope
BLUE-007 resource source protection changes state only after adjudication
BLUE-008 last MEDEVAC reserve remains protected
BLUE-009 ATO tasking does not grant weapons release
BLUE-010 capture effect does not assume physical prisoner
BLUE-011 duplicate transfer delivery does not double credit
BLUE-012 premature transition is rejected
```

## 27. Acceptance-Kriterien

Das Schema ist akzeptiert, wenn:

- MissionDemand Wirkung statt direkte Ausführung beschreibt;
- Afghan-State-Eigentum, Zustimmung und ResourceAccounts erhalten bleiben;
- ISAF-Capability-Support von Finance-/Materiel-Transfers getrennt ist;
- Partneroperationen Command Relationships explizit führen;
- Targeting-, NSL-, ROE-, PID- und CAS-Gates erhalten bleiben;
- ResourceSource-Missionen keine direkten Share-Writes erlauben;
- MATERIEL- oder FINANCE-Support keine Soforteinheit erzeugt;
- Recovery und Campaign Assessment Ressourcen- und Partnerfolgen abbilden;
- DCS/MOOSE ausschließlich genehmigte Mission Packages materialisiert.

## 28. Querverweise

```text
03-inter-faction-relations-and-negotiation.md
07-runtime-rulebook-and-action-schema.md
09-orchestrator-architecture-and-adjudication.md
10-blue-commander-dossier.md
13-campaign-state-and-event-store-schema.md
16-afghan-state-and-ansf-commander-dossier.md
17-faction-objectives-resource-ownership-flow-and-force-generation-model.md
```
