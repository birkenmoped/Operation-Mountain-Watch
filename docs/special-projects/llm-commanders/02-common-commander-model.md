---
document_id: OMW-SP-LLM-COMMANDERS-COMMON-MODEL
status: DRAFT_DESIGN_BASELINE
document_class: COMMANDER_DOMAIN_AND_DECISION_MODEL
scenario_period: 2010-08-01/2011-12-31
source_branch: docs/optional-llm-commanders
validated_in_dcs: false
authoritative_for:
  - common commander layers and fields
  - commander authority and view boundaries
  - common distinction between resources capabilities access and political state
  - common decision formation model
---

# Gemeinsames Commander-Daten- und Entscheidungsmodell

## 1. Zweck

Dieses Dokument definiert das gemeinsame, fraktionsneutrale Commander-Modell für fünf getrennte Kampagnenfraktionen:

```text
BLUE_ISAF_COMMANDER
AFGHAN_STATE_COMMANDER
TALIBAN_COMMANDER
HAQQANI_COMMANDER
HIG_COMMANDER
```

Es beschreibt nicht die historische Persönlichkeit einer bestimmten Fraktion. Es legt fest:

- welche Zustände jeder Commander besitzt;
- welche Autorität er tatsächlich ausüben darf;
- welche Informationen er erhalten darf;
- wie Ziele, Ressourcen, Fähigkeiten und politische Zustände getrennt werden;
- wie Entscheidungen entstehen;
- welche strukturierte Ausgabe die technische Orchestrierung akzeptiert.

Fraktionsspezifische Dossiers bleiben autoritativ für Identität, Ziele, Führungsverhalten und Persönlichkeit:

```text
04-taliban-commander-dossier.md
05-haqqani-commander-dossier.md
06-hig-commander-dossier.md
10-blue-commander-dossier.md
16-afghan-state-and-ansf-commander-dossier.md
```

Ressourcen und Kräftegenerierung folgen verbindlich Dokument 17; das persistente Schema folgt Dokument 13.

## 2. Grundprinzipien

```text
COMMANDER_OR_LLM_PROPOSES_INTENT
ORCHESTRATOR_VALIDATES
CAMPAIGN_STATE_DECIDES_TRUTH
MOOSE_EXECUTES_TACTICAL_RUNTIME
DCS_SIMULATES_PHYSICAL_RESULT
```

Der Commander ist weder Datenbank noch Simulationskern. Er darf:

- Lageinformationen interpretieren;
- Absichten priorisieren;
- Handlungsoptionen bewerten;
- Aufträge an autorisierte unterstellte Rollen formulieren;
- Unterstützung anfordern oder anbieten;
- mit anderen Commandern über definierte Kanäle kommunizieren;
- begründete Annahmen und Unsicherheiten ausgeben;
- die Erzeugung oder Rekonstitution eines Force Packages beantragen.

Er darf nicht:

- unbekannte Weltzustände erfinden;
- Ressourcen ohne CampaignState-Nachweis erzeugen;
- Einheiten unmittelbar spawnen, löschen oder teleportieren;
- Lua-, MOOSE- oder DCS-Befehle direkt ausführen;
- fremde Fraktionsressourcen ohne Vereinbarung kontrollieren;
- Afghan-State-Einheiten als ISAF-Eigentum behandeln;
- politische Zustände direkt in Einheiten umwandeln;
- harte Regeln, Geographie oder historische Rahmenbedingungen überschreiben;
- eine Aktion allein durch erzählerische Plausibilität autorisieren.

## 3. Technische Koalition und Kampagnenfraktion

```text
DCS_COALITION
!= CAMPAIGN_FACTION
```

Verbindlich:

```text
BLUE_ISAF_COMMANDER.dcs_coalition = BLUE
AFGHAN_STATE_COMMANDER.dcs_coalition = BLUE

BLUE_ISAF_COMMANDER.faction_id = ISAF
AFGHAN_STATE_COMMANDER.faction_id = AFGHAN_STATE
```

Gleiche DCS-Koalition bedeutet nicht:

```text
SAME_OWNERSHIP
SAME_COMMAND_AUTHORITY
SAME_RESOURCE_ACCOUNT
SAME_COMMANDER_VIEW
AUTOMATIC_INFORMATION_SHARING
```

## 4. Ebenen des Commander-Modells

Jeder Commander wird in sechs getrennte Ebenen zerlegt:

```text
IDENTITY
STRATEGIC_INTENT
ORGANIZATIONAL_AUTHORITY
CAPABILITIES_AND_RESOURCES
KNOWLEDGE_AND_BELIEFS
DECISION_AND_ACTION
```

Diese Trennung verhindert, dass Persönlichkeit, materielle Fähigkeit, politische Stellung und tatsächliches Wissen vermischt werden.

## 5. CommanderIdentity

```yaml
commander_identity:
  commander_id: string
  faction_id: ISAF|AFGHAN_STATE|TALIBAN|HAQQANI|HIG
  dcs_coalition: BLUE|RED|NEUTRAL
  display_name: string
  historical_archetype: string
  role_scope: strategic|operational|regional
  geographic_mandate: []
  political_mandate: []
  military_mandate: []
  organization_refs: []
  dossier_ref: string
  source_classification: SOURCE_DOCUMENTED|SOURCE_REPORTED_UNCORROBORATED|ANALYTICAL_INFERENCE|SIMULATION_ABSTRACTION|DESIGN_DECISION|UNKNOWN
```

Der `display_name` muss keine reale historische Person sein.

```text
HISTORICAL_ARCHETYPE != BIOGRAPHICAL_REENACTMENT
```

Kanonische IDs und Namen werden nicht vom LLM erfunden.

## 6. Persönlichkeits- und Führungsprofil

Persönlichkeitswerte liegen auf einer Skala von `0..100`. Sie verändern Bewertungsgewichte, erzeugen aber keine automatischen Aktionen.

```yaml
personality:
  aggression: 0..100
  patience: 0..100
  risk_tolerance: 0..100
  loss_tolerance: 0..100
  prestige_sensitivity: 0..100
  ideological_rigidity: 0..100
  pragmatism: 0..100
  political_sensitivity: 0..100
  population_sensitivity: 0..100
  operational_security_bias: 0..100
  deception_preference: 0..100
  retaliation_bias: 0..100
  negotiation_preference: 0..100
  delegation_preference: 0..100
  distrust_of_subordinates: 0..100
  adaptability: 0..100
```

Verwendungsregeln:

- `aggression` erhöht die Bereitschaft, günstige Gelegenheiten kurzfristig zu nutzen.
- `patience` erhöht die Bereitschaft zu Aufklärung, Vorbereitung und langfristiger Wirkung.
- `risk_tolerance` betrifft Gefährdung von Kräften, Netzwerken und politischem Kapital.
- `loss_tolerance` betrifft akzeptierte materielle und personelle Verluste.
- `prestige_sensitivity` erhöht die Bedeutung öffentlich wahrnehmbarer Erfolge und Kränkungen.
- `political_sensitivity` bewertet Legitimitäts-, Bündnis- und Übergabewirkungen.
- `population_sensitivity` bewertet Unterstützung, Duldung, Angst und Rückschlagsrisiken.
- `operational_security_bias` bevorzugt Abbruch, Verzögerung, Compartmentation und Routenwechsel.
- `negotiation_preference` erhöht die Nutzung von Absprachen und Vermittlern.
- `adaptability` bestimmt, wie schnell der Commander Verfahren und Annahmen ändert.

Ein Wert ist kein moralisches Urteil und keine klinische Diagnose.

## 7. Strategische Zielhierarchie

Jeder Commander besitzt dauerhaft gültige Ziele sowie zeitabhängige Kampagnenziele.

```yaml
strategic_goal:
  goal_id: string
  category: survival|state_survival|population_protection|political_control|territorial_access|military_pressure|resource_denial|resource_access|legitimacy|prestige|transition|negotiation|rival_containment
  base_priority: 0..100
  current_priority: 0..100
  desired_end_state: string
  geographic_scope: []
  time_horizon: immediate|short|medium|long
  success_metrics: []
  failure_thresholds: []
  source_classification: string
```

```text
CURRENT_PRIORITY =
  BASE_PRIORITY
  + THREAT_MODIFIER
  + OPPORTUNITY_MODIFIER
  + PERSONALITY_MODIFIER
  + POLITICAL_MODIFIER
  + RELATIONSHIP_MODIFIER
  + RESOURCE_ACCESS_MODIFIER
  - RESOURCE_CONSTRAINT
  - AUTHORITY_CONSTRAINT
```

Die technische Schicht berechnet oder begrenzt diese Werte. Das LLM darf Prioritätsänderungen begründen, aber nicht beliebig außerhalb definierter Grenzen setzen.

## 8. Autorität, Organisation und Befehlsreichweite

Ein Commander kontrolliert nicht automatisch jede zugehörige Einheit, Zelle oder Partnerorganisation.

```yaml
organizational_authority:
  strategic_cohesion: 0..100
  command_reach: 0..100
  communication_reliability: 0..100
  regional_control: 0..100
  district_control: 0..100
  subordinate_compliance: 0..100
  discipline_capacity: 0..100
  appointment_power: 0..100
  removal_power: 0..100
  sanction_capacity: 0..100
  internal_rivalry: 0..100
  corruption_or_criminality_pressure: 0..100
  defection_risk: 0..100
  representation_clarity: 0..100
```

### 8.1 Autoritätsscope

```yaml
authority_scope:
  geographic_scope: []
  organization_refs: []
  owned_force_package_refs: []
  controlled_force_package_refs: []
  resource_account_refs: []
  permitted_resource_source_refs: []
  permitted_action_types: []
  support_agreement_refs: []
```

```text
OWNED_FORCE_PACKAGE
!= SUPPORTED_FORCE_PACKAGE
!= ALLIED_FORCE_PACKAGE
```

### 8.2 Auftrag statt Fernsteuerung

Der strategische Commander erteilt bevorzugt:

```text
PURPOSE
PRIORITY
GEOGRAPHIC_SCOPE
RESOURCE_LIMIT
RISK_LIMIT
TIME_WINDOW
ABORT_CONDITIONS
REPORTING_REQUIREMENT
```

Lokale Kommandeure entscheiden innerhalb ihrer Autonomie über konkrete Ausführung. Die Ausführung kann:

```text
COMPLY
PARTIALLY_COMPLY
DELAY
MODIFY
REFUSE
MISREPORT
EXPLOIT_FOR_PRIVATE_GAIN
DEFECT
```

Die Wahrscheinlichkeit hängt von Disziplin, Loyalität, Kommunikation, lokaler Lage, persönlichem Interesse und Ressourcenlage ab.

## 9. Gemeinsame Taxonomie: Ressourcen, Fähigkeiten, Zugänge und Zustände

### 9.1 Grundressourcen

Die einzigen gemeinsamen umkämpften Grundressourcen der ersten Version sind:

```text
RECRUITABLE_MANPOWER
FINANCE
MATERIEL
```

```yaml
resource_account_summary:
  account_refs: []
  known_available: {}
  known_reserved: {}
  known_committed: {}
  known_in_transit: {}
  knowledge_confidence: 0..100
```

Der Commander erhält keine objektiven gegnerischen Kontostände.

### 9.2 Capability Assets und organisatorische Fähigkeiten

Keine Grundressourcen sind:

```text
ISR
AIRLIFT
MEDEVAC
EOD
ADVISORS
SPECIALISTS
TRAINING_CAPACITY
COMMAND_AND_CONTROL
LOGISTICS_CAPABILITY
OPERATIONAL_SECURITY
```

Sie werden als konkrete Assets, Kapazitäten oder organisatorische Gates geführt.

```yaml
capability_state:
  capability_id: string
  capability_type: string
  owner_faction_id: string
  available_capacity: number
  reserved_capacity: number
  readiness: 0..100
  geographic_scope: []
  restrictions: []
  supporting_asset_refs: []
```

### 9.3 Access and Control

```yaml
access_state:
  local_access: 0..100
  recruitment_access: 0..100
  revenue_access: 0..100
  route_access: 0..100
  warehouse_access: 0..100
  cache_access: 0..100
  external_support_access: 0..100
  specialist_access: 0..100
  political_access: 0..100
  information_access: 0..100
```

Zugang ist keine verbrauchbare Ressource. Er bestimmt, welcher Anteil einer endlichen Quelle erreichbar ist.

### 9.4 Political and Social State

```yaml
political_and_social_state:
  legitimacy: 0..100
  reputation: 0..100
  voluntary_support: 0..100
  coercive_control: 0..100
  prestige: 0..100
  population_grievance: 0..100
  coalition_commitment: 0..100|null
  transition_readiness: 0..100|null
```

```text
LEGITIMACY != FINANCE
REPRESSION != SUPPORT
PRESTIGE != MATERIEL
TRUST != FORCE_PACKAGE
```

### 9.5 ForcePackage

Der physische militärische Output ist ein ressourcengedecktes `ForcePackage`.

```text
RECRUITABLE_MANPOWER
+ FINANCE
+ MATERIEL
+ TIME
+ FACTION_SPECIFIC_ORGANIZATIONAL_GATE
-> FORCE_PACKAGE
```

ISAF nutzt statt afghanischem Manpower einen externen nationalen Force Pool.

## 10. Force-Generation-Anträge

Der Commander darf die Erzeugung oder Rekonstitution beantragen:

```yaml
force_generation_request:
  requested_template_ref: string
  requested_package_type: string
  intended_role: string
  source_region_ref: string|null
  known_resource_account_refs: []
  requested_resource_quantities: {}
  required_organizational_gates: []
  requested_completion_window: {}
  strategic_rationale: string
  alternatives: []
```

Er darf weder Kosten noch Erzeugungszeit frei erfinden. Der Orchestrator validiert gegen Dokument 17, Dokument 13 und die Template-Bibliothek.

## 11. Gebiets- und Einflussmodell

Kontrolle wird nicht auf einen einzigen Wert reduziert.

```yaml
area_influence:
  armed_presence: 0..100
  freedom_of_movement: 0..100
  local_access: 0..100
  population_support: 0..100
  population_compliance: 0..100
  population_fear: 0..100
  intelligence_penetration: 0..100
  recruitment_access: 0..100
  revenue_access: 0..100
  cache_network: 0..100
  shadow_governance: 0..100
  shadow_justice: 0..100
  route_influence: 0..100
  rival_influence: 0..100
  opposing_pressure: 0..100
  government_legitimacy: 0..100
  persistence_potential: 0..100
```

```text
SUPPORT != COMPLIANCE
COMPLIANCE != FEAR
ARMED_PRESENCE != GOVERNANCE
ROUTE_INFLUENCE != TERRITORIAL_CONTROL
PHYSICAL_CONTROL != SOLE_RESOURCE_BENEFIT
```

## 12. Wissen, Wahrnehmung und Überzeugungen

### 12.1 Drei Wahrheitsstufen

```text
WORLD_TRUTH
OBSERVED_INFORMATION
COMMANDER_BELIEF
```

`WORLD_TRUTH` ist ausschließlich dem CampaignState bekannt.

### 12.2 KnowledgeItem

```yaml
knowledge_item:
  knowledge_id: string
  subject_type: unit|force_package|route|base|person|network|pattern|event|resource_source|resource_account|relationship
  subject_id: string
  claim: string
  source_type: string
  source_owner: string
  reliability: 0..100
  confidence: 0..100
  first_observed: timestamp
  last_verified: timestamp
  geographic_scope: []
  freshness: 0..100
  decay_rate: 0..100
  deception_risk: 0..100
  compromise_risk: 0..100
  sharing_restrictions: []
  status: rumor|unconfirmed|probable|confirmed|contested|stale|disproven|compromised
```

Resource-bezogene Wissensobjekte unterscheiden mindestens:

```text
KNOWN_RESOURCE_STOCK
ESTIMATED_RESOURCE_STOCK
BELIEVED_SOURCE_LOCATION
BELIEVED_PHYSICAL_CONTROLLER
BELIEVED_BENEFICIARY_SHARE
BELIEVED_ACCESS_SHARE
```

## 13. Gedächtnismodell

```yaml
commander_memory:
  doctrine_memory: []
  strategic_memory: []
  relationship_memory: []
  recent_event_memory: []
  lessons_learned: []
  unresolved_assumptions: []
  grievances: []
  commitments: []
```

Erinnerungsklassen:

```text
DOCTRINE
STRATEGIC
RELATIONSHIP
OPERATIONAL
TACTICAL
RUMOR
LESSON_LEARNED
```

Ein Commander darf Ereignisse falsch gewichten, Quellen überschätzen und aus veralteten Mustern falsche Schlüsse ziehen. Er darf aber keine nie beobachteten harten Fakten ergänzen.

## 14. Beziehungen zwischen Commandern

Beziehungen sind bilateral, asymmetrisch und regional.

```yaml
relationship_state:
  actor: string
  counterpart: string
  formal_alignment: 0..100
  political_alignment: 0..100
  ideological_alignment: 0..100
  personal_trust: 0..100
  operational_trust: 0..100
  intelligence_sharing: 0..100
  logistics_cooperation: 0..100
  finance_support: 0..100
  materiel_support: 0..100
  training_support: 0..100
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
  conflict_risk: 0..100
  negotiation_channel_quality: 0..100
  outstanding_commitments: []
  disputed_claims: []
```

Zulässige Interaktionen:

```text
REQUEST_INFORMATION
SHARE_INFORMATION
REQUEST_TRANSIT
GRANT_TRANSIT
REQUEST_SUPPORT
OFFER_SUPPORT
REQUEST_FINANCE_TRANSFER
REQUEST_MATERIEL_TRANSFER
PROPOSE_RESOURCE_SOURCE_SHARE
PROPOSE_JOINT_OPERATION
PROPOSE_DECONFLICTION
PROPOSE_TEMPORARY_TRUCE
REQUEST_PARTNER_OPERATION
ACCEPT_PARTNER_OPERATION
REJECT_PARTNER_OPERATION
WARN_COUNTERPART
ACCUSE_COUNTERPART
WITHHOLD_SUPPORT
BREAK_COMMITMENT
```

## 15. Bedrohungs- und Chancenbewertung

```yaml
assessment:
  subject_id: string
  military_value: 0..100
  political_value: 0..100
  intelligence_value: 0..100
  resource_source_value: 0..100
  resource_denial_value: 0..100
  force_generation_value: 0..100
  prestige_value: 0..100
  urgency: 0..100
  opportunity_window: 0..100
  expected_cost: 0..100
  expected_network_risk: 0..100
  expected_population_backlash: 0..100
  expected_rival_benefit: 0..100
  confidence: 0..100
```

```text
ACTION_UTILITY =
  strategic_gain
  + political_gain
  + resource_access_gain
  + resource_denial_gain
  + information_gain
  + relationship_gain
  + prestige_gain
  - personnel_cost
  - finance_cost
  - materiel_cost
  - capability_opportunity_cost
  - compromise_risk
  - civilian_and_population_cost
  - rival_benefit
  - uncertainty_penalty
```

## 16. Entscheidungsprozess

```text
1. INPUT_AND_VIEW_VALIDATION
2. BELIEF_SUMMARY
3. GOAL_PRIORITY_UPDATE
4. THREAT_IDENTIFICATION
5. OPPORTUNITY_IDENTIFICATION
6. RESOURCE_AND_CAPABILITY_AWARENESS
7. AUTHORITY_CHECK
8. CANDIDATE_ACTION_GENERATION
9. KNOWLEDGE_FILTER
10. RESOURCE_SOURCE_AND_ACCOUNT_FILTER
11. RELATIONSHIP_AND_AGREEMENT_FILTER
12. RISK_AND_SUSTAINABILITY_ASSESSMENT
13. ACTION_SELECTION
14. ABORT_AND_FALLBACK_DEFINITION
15. STRUCTURED_OUTPUT
```

Der Commander führt nur eine vorläufige Prüfung gegen seine Sicht aus. Die autoritative Prüfung bleibt beim Orchestrator.

## 17. Gemeinsames Decision-Objekt

```yaml
commander_decision:
  schema_version: string
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
    action_type: string
    target_refs: []
    origin_refs: []
    geographic_scope: []
    desired_effects: []
    assigned_force_package_refs: []
    required_resource_account_refs: []
    requested_resource_quantities: {}
    requested_capability_refs: []
    requested_partner_support: []
    required_agreement_refs: []
    start_window: {}

  risk:
    military_risk: 0..100
    political_risk: 0..100
    network_risk: 0..100
    civilian_harm_risk: 0..100
    resource_loss_risk: 0..100
    escalation_risk: 0..100

  constraints:
    political_limits: []
    geographic_limits: []
    resource_limits: []
    timing_limits: []
    prohibited_outcomes: []

  abort_conditions: []
  fallback_action: {}
  alternatives_considered: []
  relationship_effects_expected: []
  memory_items_to_record: []
```

## 18. Fraktionsspezifische gemeinsame Besonderheiten

### 18.1 BLUE ISAF

```text
ISAF_LOCAL_TRUST != ISAF_FORCE_GENERATION
```

ISAF-Eigenkräfte stammen aus einem externen nationalen Force Pool. Afghanische Kräfte bleiben Partnerkräfte mit eigenem Eigentum und eigener Zustimmung.

### 18.2 Afghan State

```text
AFGHAN_STATE_FORCE_GENERATION
requires
FINANCE + RECRUITABLE_MANPOWER + MATERIEL
+ TRAINING + RETENTION + TIME
```

Der Commander kann Koalitionsunterstützung anfordern, aber nicht automatisch voraussetzen.

### 18.3 Taliban

Freiwillige Unterstützung und Repression bleiben getrennt. Beide beeinflussen Zugang, erzeugen aber keine unmittelbare Einheit.

### 18.4 Haqqani

Selektiver Kader-, Broker-, Spezialisten-, Routen- und Staging-Zugang ist wichtiger als der größte allgemeine Manpower-Anteil.

### 18.5 HIG

Patronage, lokale Commander, politische Relevanz und Vertretungsfähigkeit sind Gates beziehungsweise Zustände, keine frei verbrauchbaren Ressourcen.

## 19. Harte Validatorregeln

```text
NO_RESOURCE_WITHOUT_SOURCE
NO_FORCE_PACKAGE_WITHOUT_RESOURCE_COMMITMENT
NO_POPULATION_OWNERSHIP
NO_REPUTATION_TO_DIRECT_UNIT_CONVERSION
NO_ISAF_RECRUITMENT_FROM_AFGHAN_MANPOWER
NO_AFGHAN_UNIT_OWNED_BY_ISAF
NO_FOREIGN_RESOURCE_CONTROL_WITHOUT_AGREEMENT
NO_DIRECT_LLM_DCS_OR_MOOSE_CONTROL
NO_COMMANDER_VIEW_WITH_HIDDEN_WORLD_TRUTH
NO_ACTION_OUTSIDE_AUTHORITY_SCOPE
```

## 20. Fallback-Verhalten

Ein Commander darf ausdrücklich:

```text
NO_ACTION
DELAY_DECISION
REQUEST_MORE_INFORMATION
REQUEST_SUPPORT
PROTECT_EXISTING_FORCE
PRESERVE_NETWORK
RELEASE_RESERVATION
CANCEL_FORCE_GENERATION
```

wählen.

Ungültige oder unvollständige LLM-Ausgaben führen zu Reparatur oder fraktionsspezifischem deterministischem Fallback.

## 21. Acceptance-Kriterien

Das gemeinsame Modell ist akzeptiert, wenn:

1. alle fünf Commander dasselbe formale Eingabe- und Ausgabeformat verwenden;
2. DCS-Koalition und Kampagnenfraktion getrennt sind;
3. ISAF und Afghan State getrennte Eigentums- und Autoritätsbereiche besitzen;
4. Ressourcen, Fähigkeiten, Zugänge und politische Zustände technisch getrennt sind;
5. kein Commander objektive gegnerische Ressourcenbestände erhält;
6. ein Commander keine fremden Force Packages ohne Vereinbarung steuern kann;
7. Force-Generation-Anträge dieselbe Validierung wie spätere LLM-Ausgaben verwenden;
8. Nullaktion, Verzögerung, Schutz und Verhandlung zulässige Entscheidungen sind;
9. lokale Befehlsfriktion und Partnerautonomie erhalten bleiben;
10. alle Entscheidungen auf Dokument 13, 16, 17 und 18 referenzierbar sind.

## 22. Folgedokumente

Dieses Modell wird konkretisiert durch:

```text
03-inter-faction-relations-and-negotiation.md
07-runtime-rulebook-and-action-schema.md
08-commander-memory-belief-and-information-model.md
09-orchestrator-architecture-and-adjudication.md
12-multi-commander-test-scenarios.md
13-campaign-state-and-event-store-schema.md
19-language-neutral-contracts-and-json-schemas.md
```
