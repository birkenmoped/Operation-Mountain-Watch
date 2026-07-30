---
document_id: OMW-SP-LLM-COMMANDERS-BLUE-MISSION-DEMAND
status: DRAFT_RUNTIME_DESIGN
document_class: BLUE_MISSION_DEMAND_FORCE_ALLOCATION_TARGETING_SCHEMA
scenario_period: 2010-08-01/2011-12-31
source_branch: docs/optional-llm-commanders
validated_in_dcs: false
---

# BLUE MissionDemand, Force Allocation und Targeting Schema

## 1. Zweck

Dieses Dokument definiert die maschinenlesbaren BLUE-Objekte zwischen strategischer Commander-Entscheidung, operativer Bedarfsformulierung, Ressourcenpriorisierung, Target Development, Air Support, Partnerkräften und DCS/MOOSE-Ausführung.

```text
BLUE_COMMANDER_DECISION
-> MISSION_DEMAND
-> VALIDATION_AND_PRIORITY
-> FORCE_AND_ENABLER_ALLOCATION
-> OPERATION_PLAN
-> SUBORDINATE_REQUESTS_AND_TASKING
-> DCS_MOOSE_EXECUTION
-> MISREP_BDA_CAMPAIGN_ASSESSMENT
```

Der BLUE Commander fordert Wirkungen und priorisiert Bedarfe. Er erzeugt weder direkt einen ATO-Eintrag noch eine Waffenfreigabe.

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
```

## 3. Gemeinsames MissionDemand-Objekt

```yaml
mission_demand:
  schema_version: "1.0"
  demand_id: string
  originating_turn_id: string
  owning_commander_id: BLUE_COMMANDER
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
    supported_force_refs: []
    supported_partner_refs: []
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
ISR_COLLECTION
TARGET_DEVELOPMENT
NETWORK_DISRUPTION
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
CAPTURE
RESCUE
EVACUATE
DESTROY
ENABLE_PARTNER
RESTORE_ROUTE
HOLD_AREA
SUPPORT_GOVERNANCE
REDUCE_CIVILIAN_RISK
```

`DESTROY` ist nur eine Wirkung unter mehreren und darf nicht als Standard eingesetzt werden.

## 6. MissionDemand Lifecycle

```text
DRAFT
SUBMITTED
VALIDATING
NEEDS_INFORMATION
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
RESOURCING -> DEFERRED
TASKED -> SUSPENDED
EXECUTING -> ABORTED
ASSESSING -> NEEDS_INFORMATION
```

## 7. Priorisierung

Der Priority Score wird nicht allein aus Dringlichkeit berechnet.

```yaml
priority_factors:
  catastrophic_loss_prevention: 0..100
  population_protection_value: 0..100
  friendly_force_protection_value: 0..100
  strategic_effect: 0..100
  time_sensitivity: 0..100
  intelligence_confidence: 0..100
  target_or_problem_persistence: 0..100
  partner_enablement_value: 0..100
  route_or_logistics_value: 0..100
  political_risk: 0..100
  civilian_harm_risk: 0..100
  resource_cost: 0..100
  opportunity_cost: 0..100
  sustainability: 0..100
```

Beispielhafte Ausgangsformel:

```text
PRIORITY =
  0.20 catastrophic_loss_prevention
+ 0.14 population_protection_value
+ 0.12 friendly_force_protection_value
+ 0.13 strategic_effect
+ 0.10 time_sensitivity
+ 0.08 partner_enablement_value
+ 0.07 route_or_logistics_value
+ 0.08 sustainability
+ 0.05 intelligence_confidence
+ 0.03 target_or_problem_persistence
- 0.08 political_risk
- 0.10 civilian_harm_risk
- 0.06 resource_cost
- 0.06 opportunity_cost
```

Die konkrete Formel ist versioniert und testbar. Notfallregeln dürfen gewichtete Scores übersteuern.

## 8. Capability Request

```yaml
capability_request:
  capability_type: enum
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

Zulässige Capability Types:

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
```

## 9. BLUE Asset State

```yaml
blue_asset:
  asset_id: string
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

## 10. Force Allocation

```yaml
force_allocation:
  allocation_id: string
  demand_id: string
  asset_id: string
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

## 11. Reserve Policy

Nicht der gesamte Bestand darf verplant werden.

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
```

Der Orchestrator blockiert Zuteilungen, die kritische Mindestreserven ohne ausdrückliche Notfallfreigabe unterschreiten.

## 12. ISR Collection Requirement

```yaml
collection_requirement:
  collection_id: string
  linked_demand_ids: []
  priority_intelligence_requirement_ref: string|null
  essential_element_of_information: string
  subject_ref: string|null
  geographic_scope: []
  collection_window: {}
  required_confidence: 0..100
  required_update_rate: string|null
  acceptable_sensor_types: []
  source_protection_required: boolean
  dissemination_scope: []
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

## 13. Target Development Object

```yaml
target_development:
  target_id: string
  target_category: PERSON|GROUP|VEHICLE|BUILDING|ROUTE|NODE|AREA|CAPABILITY
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

## 14. Targeting Decision

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
  abort_conditions: []
  expiry: datetime
```

Decision Enum:

```text
CONTINUE_COLLECTION
MONITOR
NON_KINETIC_ONLY
CAPTURE_IF_FEASIBLE
INTERDICT
KINETIC_AUTHORIZED_WITH_CONDITIONS
DENIED
REMOVE_FROM_TARGET_SET
```

## 15. Air Support Request

```yaml
air_support_request:
  request_id: string
  linked_demand_id: string
  request_type: PREPLANNED|IMMEDIATE|EMERGENCY
  supported_unit: string
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

## 16. CAS Execution Gate

Vor einer physischen CAS-Wirkung müssen mindestens geprüft sein:

```text
SUPPORTED_FORCE_CONFIRMED
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

## 17. Partner Force Package

```yaml
partner_force_package:
  partner_unit_ref: string
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
  coalition_enablers_required: []
  mentor_or_liaison_required: boolean
  mission_limitations: []
  fallback_if_partner_fails: string
```

## 18. Mission Package

```yaml
mission_package:
  package_id: string
  linked_demand_ids: []
  supported_goal_ids: []
  command_element: string
  ground_elements: []
  air_elements: []
  isr_elements: []
  partner_elements: []
  support_elements: []
  reserve_elements: []
  communications_plan_ref: string
  airspace_plan_ref: string|null
  medical_plan_ref: string
  recovery_plan_ref: string
  roe_profile_ref: string
  target_authorization_refs: []
  phases: []
  decision_points: []
  abort_conditions: []
  branch_plans: []
  sequel_plans: []
```

## 19. Mission Phases

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

Nicht jede Mission verwendet alle Phasen.

## 20. Recovery und Reconstitution

Jede größere Mission muss vor Freigabe prüfen:

```text
FUEL_RECOVERY
AMMUNITION_RECOVERY
MAINTENANCE_RECOVERY
CREW_REST
MEDICAL_RECOVERY
REPLACEMENT_CAPACITY
BASE_PARKING_AND_FLOW
FOLLOW_ON_RESERVE
```

Eine Mission, die den Bestand physisch ausführen kann, aber keine Rückkehr, Wartung oder Folgefähigkeit erlaubt, gilt als nicht vollständig ressourciert.

## 21. Assessment

```yaml
mission_assessment:
  mission_id: string
  tactical_results: []
  desired_effect_achieved: 0..100
  unintended_effects: []
  friendly_losses: []
  partner_losses: []
  civilian_harm: []
  target_status: []
  network_effect: 0..100
  population_security_effect: -100..100
  government_legitimacy_effect: -100..100
  partner_capability_effect: -100..100
  route_reliability_effect: -100..100
  intelligence_gain: 0..100
  political_cost: 0..100
  resource_cost: 0..100
  sustainability: 0..100
  confidence: 0..100
  follow_up_demands: []
```

## 22. BLUE-spezifische Validierungsfehler

```text
DEMAND_NOT_LINKED_TO_STRATEGIC_GOAL
DESIRED_EFFECT_UNCLEAR
PRIORITY_NOT_JUSTIFIED
INSUFFICIENT_INTELLIGENCE
TARGET_IDENTITY_UNCONFIRMED
HOSTILE_STATUS_UNCONFIRMED
NSL_CHECK_REQUIRED
ROE_REVIEW_REQUIRED
CIVILIAN_RISK_EXCEEDS_LIMIT
FRIENDLY_PROXIMITY_EXCEEDS_LIMIT
AIRSPACE_CONFLICT
CONTROLLER_AUTHORITY_MISSING
ASSET_NOT_READY
ASSET_CAVEAT_CONFLICT
CRITICAL_RESERVE_VIOLATION
RECOVERY_CAPACITY_INSUFFICIENT
PARTNER_READINESS_INSUFFICIENT
FOLLOW_ON_FORCE_MISSING
HOLD_OR_TRANSFER_PLAN_MISSING
```

## 23. Deterministische Fallbacks

Bei ungültiger BLUE-LLM-Ausgabe:

```text
1. REQUEST_MORE_INFORMATION
2. CONTINUE_COLLECTION
3. PROTECT_CRITICAL_FORCE_OR_POPULATION
4. PRESERVE_EMERGENCY_RESERVES
5. DEFER_KINETIC_EFFECT
```

Ein Schema- oder LLM-Fehler darf keine unautorisierte Waffenwirkung erzeugen.

## 24. MOOSE-/DCS-Projektion

```text
MissionDemand
-> OperationPlan
-> AirSupportRequest / CollectionRequirement / GroundTask
-> MOOSE COMMANDER / AIRWING / AUFTRAG / PLAYERTASK
-> INTEL / DETECTION / TARGET / PLAYERRECCE / DESIGNATE
-> DCS groups, routes, zones, tasking and events
-> MISREP / BDA / CampaignState update
```

Vor eigener Lua-Funktionalität ist zu prüfen, welche MOOSE-Klassen die jeweilige Zuweisung, Aufklärung, Missionserzeugung und Ausführung bereits abbilden.

## 25. Acceptance-Kriterien

```text
- Ein Demand kann ohne physische Mission bestehen.
- Ein Demand kann wegen fehlender Intelligence zurückgestellt werden.
- Zwei Demands konkurrieren reproduzierbar um dieselbe Ressource.
- Kritische Reserven werden nicht unbemerkt unterschritten.
- NSL-, ROE- und PID-Prüfungen blockieren unzulässige Targeting-Schritte.
- Afghan-led Missionen können Koalitions-Enabler erhalten, ohne die Führungsrolle zu verlieren.
- CAS Request, Mission Tasking und Weapons Release bleiben getrennt.
- Recovery und Folgefähigkeit beeinflussen die Allokation.
- Tactical Result und Campaign Effect werden getrennt bewertet.
- Spieler und KI können auf demselben MissionDemand arbeiten.
```
