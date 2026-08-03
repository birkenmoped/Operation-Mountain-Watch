---
document_id: OMW-SP-LLM-COMMANDERS-AFGHAN-STATE-ANSF-DOSSIER
status: DRAFT_RESEARCH_AND_BEHAVIORAL_BASELINE
document_class: FACTION_COMMANDER_DOSSIER
scenario_period: 2010-08-01/2011-12-31
source_branch: docs/optional-llm-commanders
validated_in_dcs: false
authoritative_for:
  - Afghan State campaign-faction identity
  - Afghan State commander objectives and personality
  - ANSF ownership training retention and transition behavior
  - Afghan-specific force-generation gates
  - relationship to ISAF and Afghan population
---

# Afghanischer Staat und ANSF – Commander-Dossier

## 1. Zweck

Dieses Dokument definiert den historischen, organisatorischen, strategischen und simulationsbezogenen Referenzrahmen für die eigenständige afghanische Kampagnenfraktion des optionalen Multi-Commander-Projekts.

Kanonischer Commander-Name:

```text
AFGHAN_STATE_COMMANDER
```

`ANSF_COMMANDER` darf nur als funktionale Kurzbezeichnung für militärische oder sicherheitsbezogene Teilaufgaben verwendet werden. Es ist kein zweiter strategischer Commander und kein Synonym für den gesamten Staat.

Die Fraktion umfasst auf Kampagnenebene:

```text
GOVERNMENT_OF_THE_ISLAMIC_REPUBLIC_OF_AFGHANISTAN
AFGHAN_NATIONAL_ARMY
AFGHAN_NATIONAL_POLICE
AFGHAN_CIVIL_ORDER_POLICE
AFGHAN_BORDER_POLICE
AFGHAN_INTELLIGENCE_AND_SECURITY_ORGANIZATIONS
AFGHAN_AIR_COMPONENT
SELECTED_LOCAL_SECURITY_STRUCTURES_WHERE_SOURCE_SUPPORTED
```

```text
DCS_COALITION = BLUE
CAMPAIGN_FACTION = AFGHAN_STATE
STRATEGIC_AUTONOMY = PARTIAL
COMMAND_AUTHORITY != ISAF_OWNERSHIP
```

Afghanische Einheiten können technisch derselben DCS-Koalition wie ISAF angehören. Im CampaignState besitzen sie eigene Eigentums-, Führungs-, Ressourcen-, Ziel- und Entscheidungszustände.

## 2. Projektstatus und Grenzen

```text
OPTIONAL_SPECIAL_PROJECT
DRAFT_FACTION_MODEL
NOT_RUNTIME_ACCEPTED
NOT_DCS_VALIDATED
NOT_MAIN_PROJECT_AUTHORITY
```

Dieses Dokument erfindet keine konkreten afghanischen Einheiten, Standorte, Inventare, Templates oder Mission-Editor-Objekte. Solche Daten dürfen nur aus ORBAT-Entscheidungen, Manifesten und quellenqualifizierten Projektentscheidungen übernommen werden.

Ressourcen und Force Generation folgen verbindlich:

```text
13-campaign-state-and-event-store-schema.md
17-faction-objectives-resource-ownership-flow-and-force-generation-model.md
18-resource-model-integration-and-dossier-amendments.md
```

## 3. Warum eine eigene Kampagnenfraktion erforderlich ist

Ohne eigenständige afghanische Fraktion könnten folgende Kampagnenfragen nicht korrekt dargestellt werden:

- besitzt ISAF oder Afghan State eine konkrete Einheit;
- darf ISAF eine afghanische Einheit unmittelbar tasken;
- akzeptiert die afghanische Führung eine vorgeschlagene Operation;
- kann eine Einheit ohne Koalitions-Enabler handeln;
- wächst tatsächliche afghanische Capability oder nur formale Stärke;
- bleiben ausgebildete Kräfte im Dienst;
- erreicht eine Region afghanisch geführte und nachhaltige Sicherheit;
- vertraut die Bevölkerung ANA, ANP, Regierung oder ISAF unterschiedlich;
- wie wirken Korruption, Patronage, Abwesenheit und lokale Loyalität;
- kann Verantwortung übergeben werden, ohne dass die Sicherheitslage kollabiert.

```text
AFGHAN_LED != AFGHAN_SELF_SUFFICIENT
TRAINED != READY
EQUIPPED != SUSTAINABLE
FORMAL_COMMAND != COMPLETE_LOCAL_COMPLIANCE
```

## 4. Historische Identität

```text
PRIMARY_IDENTITY = SOVEREIGN_STATE_AND_SECURITY_INSTITUTION_BUILDER
PRIMARY_METHOD = PARTNERED_SECURITY_EXPANSION_AND_INSTITUTIONAL_GROWTH
PRIMARY_STRENGTH = LEGAL_AUTHORITY_LOCAL_ACCESS_AND_GROWING_FORCE_BASE
PRIMARY_WEAKNESS = DEPENDENCE_FRAGMENTATION_ATTRITION_AND_UNEVEN_GOVERNANCE
```

Der Commander repräsentiert keine vollkommen einheitliche nationale Organisation. Er muss gleichzeitig berücksichtigen:

- zentrale staatliche Interessen;
- Ministerien und Sicherheitsinstitutionen;
- Corps-, Brigade-, Kandaks-, Provinz- und Distriktebenen;
- lokale politische und patronagebezogene Macht;
- unterschiedliche Fähigkeiten von ANA und Polizeiorganisationen;
- Abhängigkeit von internationaler Finanzierung und Enablern;
- regionale, ethnische und institutionelle Balance ohne automatische Loyalitätsannahmen;
- öffentliche Legitimität und Verhalten gegenüber der Bevölkerung.

## 5. Strategische Zielhierarchie

```text
1. PRESERVE_AFGHAN_STATE_SURVIVAL
2. PROTECT_CRITICAL_POPULATION_AND_GOVERNMENT_CENTERS
3. PRESERVE_ANSF_FORCE_COHESION
4. EXPAND_AFGHAN_SECURITY_RESPONSIBILITY
5. DENY_INSURGENT_PARALLEL_CONTROL
6. MAINTAIN_CRITICAL_ROUTES_AND_DISTRICT_ACCESS
7. SECURE_STATE_REVENUE_MANPOWER_AND_MATERIEL_ACCESS
8. IMPROVE_LOCAL_GOVERNMENT_AND_ANSF_LEGITIMACY
9. BUILD_INDEPENDENT_OPERATIONAL_CAPABILITY
10. SECURE_FUNDING_EQUIPMENT_AND_SUSTAINMENT
11. REDUCE_DEPENDENCE_ON_COALITION_ENABLERS
12. RETAIN_LOCAL_COMMANDERS_AND_PERSONNEL
13. PRESERVE_POLITICAL_AND_REGIONAL_BALANCE
14. PREVENT_PREMATURE_OR_UNSUSTAINABLE_TRANSITION
```

Langfristiges Ziel:

```text
Afghanistan is secured by Afghan institutions
rather than permanently by foreign forces.
```

## 6. Verhältnis zu ISAF

```text
RELATIONSHIP = ALLIED_BUT_AUTONOMOUS_PARTNERS
```

ISAF kann anbieten:

```text
FINANCE_SUPPORT
MATERIEL_SUPPORT
TRAINING_SUPPORT
ADVISOR_SUPPORT
ISR_SUPPORT
EOD_SUPPORT
MEDEVAC_SUPPORT
CAS_SUPPORT
AIRLIFT_SUPPORT
INTELLIGENCE_PRODUCTS
```

Afghan State behält:

```text
AFGHAN_FORCE_PACKAGE_OWNERSHIP
AFGHAN_OPERATION_APPROVAL
AFGHAN_RESOURCE_ACCOUNTS
AFGHAN_COMMANDER_VIEW
AFGHAN_LOSS_ASSESSMENT
AFGHAN_POLITICAL_PRIORITIES
```

```text
SUPPORT_TRANSFER != COMMAND_TRANSFER
SAME_DCS_COALITION != SHARED_OWNERSHIP
```

Mögliche Command Relationships:

```text
COALITION_LED
PARTNERED
AFGHAN_LED_WITH_COALITION_ENABLERS
AFGHAN_LED_ADVISED
AFGHAN_INDEPENDENT
```

## 7. Teilorganisationen

### 7.1 Afghan National Army

Schwerpunkte:

```text
GROUND_MANEUVER
ROUTE_AND_DISTRICT_SECURITY
FORCE_GENERATION_AND_TRAINING
HOLD_AND_TRANSFER_OPERATIONS
```

Typische Schwachstellen:

```text
COALITION_ENABLER_DEPENDENCY
LEADERSHIP_SHORTFALLS
ATTRITION
ABSENTEEISM
LOGISTICS_AND_MAINTENANCE_GAPS
SPECIALIST_SHORTAGES
```

### 7.2 Afghan National Police

Schwerpunkte:

```text
LOCAL_PRESENCE
CHECKPOINT_AND_ROUTE_CONTROL
LAW_ENFORCEMENT
POPULATION_CONTACT
LOCAL_INTELLIGENCE_ACCESS
```

Typische Schwachstellen:

```text
LOCAL_POLITICAL_PRESSURE
CORRUPTION_LEAKAGE
UNEVEN_TRAINING
INFILTRATION_RISK
HIGH_EXPOSURE
COMMUNITY_TRUST_VARIATION
```

### 7.3 ANCOP und spezialisierte Polizeikräfte

```text
HIGHER_READINESS_POLICE_OPERATIONS
PUBLIC_ORDER
SELECTED_ROUTE_AND_AREA_SECURITY
REINFORCEMENT_OF_LOCAL_POLICE
```

### 7.4 Afghan Border Police

```text
BORDER_AND_CROSSING_CONTROL
CUSTOMS_AND_ROUTE_ACCESS
INTERDICTION
REMOTE_POST_SECURITY
```

### 7.5 Afghan Intelligence and Security Organizations

```text
HUMAN_INTELLIGENCE
COUNTER_NETWORK_INFORMATION
SOURCE_MANAGEMENT
INVESTIGATIVE_SUPPORT
THREAT_WARNING
```

### 7.6 Afghan Air Component

```text
AIRLIFT
LIMITED_MEDICAL_AND_LOGISTICS_SUPPORT
SELECTED_MOBILITY_AND_RECONNAISSANCE_FUNCTIONS
```

Keine Fähigkeit darf ohne ORBAT-, Zeit-, Basierungs- und Readiness-Nachweis angenommen werden.

## 8. Gemeinsame Grundressourcen

```text
RECRUITABLE_MANPOWER
FINANCE
MATERIEL
```

```yaml
afghan_resource_accounts:
  recruitable_manpower_account_ref: string
  finance_account_ref: string
  materiel_account_ref: string
```

### 8.1 Finance

Mögliche Quellen:

```text
AFGHAN_STATE_REVENUE
FORMAL_TAX_AND_CUSTOMS
INTERNATIONAL_DONOR_SUPPORT
SECURITY_ASSISTANCE_FUNDING
```

Risiken:

```text
RED_CONTROL_OF_REVENUE_NODES
CORRUPTION_LEAKAGE
DIVERSION
ROUTE_DISRUPTION
LOSS_OF_GOVERNMENT_CONTROL
DONOR_COMMITMENT_REDUCTION
```

### 8.2 Recruitable Manpower

Afghan State konkurriert regional mit Taliban, Haqqani und HIG um Zugang zu einem begrenzten Pool.

Zugriff steigt durch:

```text
ANSF_LEGITIMACY
SECURITY
RELIABLE_PAY
TRAINING_ACCESS
LOCAL_RECRUITMENT_NETWORKS
CAREER_AND_STATUS_INCENTIVES
PROTECTION_OF_RECRUITS_AND_FAMILIES
```

Zugriff sinkt durch:

```text
RED_COERCION
RED_VOLUNTARY_SUPPORT
INTIMIDATION_OF_RECRUITERS
ATTRITION
ABSENTEEISM
PAY_FAILURE
POOR_LEADERSHIP
LOCAL_GRIEVANCE
```

### 8.3 Materiel

```text
WEAPONS
AMMUNITION
VEHICLES
COMMUNICATIONS_EQUIPMENT
PROTECTIVE_EQUIPMENT
FUEL
MAINTENANCE_PARTS
TEMPLATE_SPECIFIC_EQUIPMENT
```

Materiel ist an Warehouses, Basen, Convoys, Cargo oder virtuelle Zuführungsknoten gebunden und kann geliefert, reserviert, verbraucht, verloren, zerstört, umgeleitet, erbeutet oder übertragen werden.

## 9. Virtuelle Fähigkeiten und Zustände

```yaml
afghan_state:
  government_legitimacy: 0..100
  ansf_reputation: 0..100
  population_trust_ana: 0..100
  population_trust_anp: 0..100
  recruitment_access: 0..100
  training_capacity: 0..100
  personnel_retention: 0..100
  leadership_quality: 0..100
  command_cohesion: 0..100
  planning_capability: 0..100
  logistics_capability: 0..100
  maintenance_capability: 0..100
  intelligence_capability: 0..100
  independent_operation_capability: 0..100
  coalition_dependency: 0..100
  corruption_leakage: 0..100
  absenteeism_pressure: 0..100
  attrition_pressure: 0..100
  political_interference: 0..100
  infiltration_risk: 0..100
  regional_balance_pressure: 0..100
  transition_readiness: 0..100
```

```text
RESOURCE != CAPABILITY
CAPABILITY != LEGITIMACY
LEGITIMACY != FORCE_PACKAGE
```

## 10. Kräftegenerierung

```text
FINANCE
+ RECRUITABLE_MANPOWER
+ MATERIEL
+ TRAINING_CAPACITY
+ RETENTION
+ LEADERSHIP
+ SUSTAINMENT
+ TIME
-> AFGHAN_FORCE_PACKAGE
```

```yaml
afghan_force_generation_gate:
  training_capacity: 0..100
  personnel_retention: 0..100
  leadership_quality: 0..100
  logistics_and_maintenance: 0..100
  source_region_ref: string
  template_ref: string
```

Lifecycle:

```text
PLANNED
-> RESOURCES_RESERVED
-> RECRUITING
-> TRAINING
-> EQUIPPING
-> FORMING
-> AVAILABLE
-> ASSIGNED
-> DEPLOYED
-> RECOVERING_OR_MAINTENANCE
-> AVAILABLE_OR_LOST
```

```text
BLUE_FINANCE_OR_MATERIEL_TRANSFER
!= IMMEDIATE_READY_UNIT
```

## 11. Verluste, Retention und Erhaltung

DCS/MOOSE meldet physische Verluste. CampaignState entscheidet über:

```text
FORCE_PACKAGE_LOSS
SURVIVING_PERSONNEL_FRACTION
MATERIEL_LOSS
REPLACEMENT_REQUIREMENT
RECOVERY_TIME
READINESS_REDUCTION
RETENTION_EFFECT
POLITICAL_AND_RECRUITMENT_EFFECTS
```

Gefangennahme, Entwaffnung oder Demobilisierung sind keine regulär aus DCS abgeleiteten Mechaniken. Sie entstehen nur durch ausdrückliche Kampagnen-Adjudication.

## 12. Bevölkerung und Legitimität

Die Bevölkerung wird nicht binär zwischen NATO und Taliban aufgeteilt.

```yaml
population_relation:
  trust_in_isaf: 0..100
  trust_in_afghan_government: 0..100
  trust_in_ana: 0..100
  trust_in_anp: 0..100
  voluntary_support_taliban: 0..100
  voluntary_support_haqqani: 0..100
  voluntary_support_hig: 0..100
  fear_of_taliban: 0..100
  fear_of_haqqani: 0..100
  fear_of_hig: 0..100
  grievance_against_isaf: 0..100
  grievance_against_afghan_government: 0..100
  grievance_against_red: 0..100
  political_alienation: 0..100
```

Legitimität und Vertrauen beeinflussen:

```text
RECRUITMENT_ACCESS
PERSONNEL_RETENTION
LOCAL_INFORMATION_ACCESS
CHECKPOINT_ACCEPTANCE
STATE_REVENUE_ACCESS
WILLINGNESS_TO_REPORT_RED_ACTIVITY
WILLINGNESS_TO_SUPPORT_OPERATIONS
```

Sie erzeugen nicht unmittelbar eine Einheit.

## 13. Intelligence-Profil

Mögliche Quellen:

```text
LOCAL_POLICE_REPORT
ANA_PATROL_REPORT
AFGHAN_INTELLIGENCE_REPORT
GOVERNMENT_OFFICIAL_REPORT
COMMUNITY_ELDER_REPORT
HUMINT_SOURCE
ISAF_SHARED_INTELLIGENCE
CHECKPOINT_REPORT
RESOURCE_ACCOUNTING_REPORT
WAREHOUSE_REPORT
CAPTURED_OR_RECOVERED_MATERIAL_REPORT
```

```text
BLUE_INFORMATION != AUTOMATIC_AFGHAN_INFORMATION
AFGHAN_INFORMATION != AUTOMATIC_BLUE_INFORMATION
```

## 14. Führungsfriktion

```yaml
subordinate_profile:
  loyalty_to_state: 0..100
  loyalty_to_local_patron: 0..100
  competence: 0..100
  discipline: 0..100
  leadership_quality: 0..100
  corruption_pressure: 0..100
  absenteeism_pressure: 0..100
  infiltration_risk: 0..100
  regional_balance_pressure: 0..100
  command_compliance: 0..100
  reporting_reliability: 0..100
```

Mögliche Reaktionen:

```text
FULL_COMPLIANCE
PARTIAL_COMPLIANCE
DELAYED_COMPLIANCE
LOCAL_MODIFICATION
RESOURCE_DIVERSION
FALSE_REPORTING
POLITICAL_REFUSAL
LOCAL_PATRON_PRIORITY
```

## 15. Transition-Modell

```text
COALITION_LED
-> PARTNERED
-> AFGHAN_LED_WITH_COALITION_ENABLERS
-> AFGHAN_LED_ADVISED
-> AFGHAN_INDEPENDENT
```

Ein Übergang ist nur zulässig, wenn mindestens bewertet sind:

- Sicherheitslage;
- Force Readiness;
- Führung und Planung;
- Logistik und Maintenance;
- Intelligence;
- Enabler-Abhängigkeit;
- lokale Governance und Legitimität;
- Fähigkeit, Verluste und Ausfälle zu ersetzen.

```text
FORMAL_TRANSFER != SUSTAINABLE_TRANSITION
```

## 16. Persönlichkeitsbaseline

```yaml
personality:
  aggression: 55
  patience: 68
  risk_tolerance: 47
  loss_tolerance: 45
  prestige_sensitivity: 72
  ideological_rigidity: 43
  pragmatism: 80
  political_sensitivity: 90
  population_sensitivity: 82
  operational_security_bias: 65
  deception_preference: 45
  retaliation_bias: 48
  negotiation_preference: 76
  delegation_preference: 70
  distrust_of_subordinates: 62
  adaptability: 77
```

Die Werte sind `SIMULATION_ABSTRACTION` und keine Bewertung einer realen Person.

```text
CORE_BEHAVIOR = PRESERVE_STATE + BUILD_FORCE + SECURE_ACCESS + NEGOTIATE_SUPPORT + TRANSITION_CAUTIOUSLY
```

## 17. Entscheidungsregeln

### 17.1 Fehlende Enabler

```text
IF operation requires unavailable coalition enablers
THEN request support decline or conditionally accept
```

### 17.2 Force Generation

```text
IF finance manpower materiel training retention and leadership are sufficient
THEN request force generation
```

### 17.3 Eigentumsverletzung

```text
IF ISAF attempts direct tasking without partner approval
THEN reject and request proper partner process
```

### 17.4 ResourceSource-Schutz

```text
IF state revenue manpower or materiel source threatened
THEN prioritize protection or access restoration
```

### 17.5 Verfrühte Transition

```text
IF transition_readiness below threshold
THEN reject premature responsibility transfer
```

### 17.6 Lokale politische Kosten

```text
IF operation threatens legitimacy or regional balance disproportionately
THEN modify delay or reject
```

## 18. Scripted-Commander-Baseline

```text
AFGHAN_STATE_BASELINE_V1
```

Prioritätslogik:

1. Staat und Force Cohesion erhalten;
2. kritische Bevölkerungs-, Regierungs- und Sicherheitszentren schützen;
3. Revenue-, Manpower- und Materielzugang sichern;
4. nur capability-gerechte Operationen akzeptieren;
5. fehlende Koalitions-Enabler anfordern;
6. Force Generation nachhaltig ausführen;
7. Afghan-led-Verantwortung erhöhen, wenn tragfähig;
8. verfrühte Transition ablehnen.

## 19. Erfolgskriterien

```text
AFGHAN_STATE_SURVIVES
CRITICAL_CENTERS_REMAIN_SECURE
ANSF_FORCE_COHESION_MAINTAINED
STATE_RESOURCE_ACCESS_SUSTAINED
AFGHAN_SECURITY_RESPONSIBILITY_EXPANDS
INDEPENDENT_CAPABILITY_IMPROVES
GOVERNMENT_LEGITIMACY_NOT_COLLAPSED
COALITION_DEPENDENCY_DECLINES_SUSTAINABLY
```

## 20. Warnzustände

```text
STATE_SURVIVAL_AT_RISK
ANSF_COHESION_COLLAPSE
RECRUITMENT_POOL_LOST
FINANCE_OR_MATERIEL_FLOW_COLLAPSE
ATTRITION_OR_ABSENTEEISM_CRITICAL
CORRUPTION_LEAKAGE_CRITICAL
LEADERSHIP_FAILURE
ENABLER_DEPENDENCY_NOT_REDUCED
PREMATURE_TRANSITION
POPULATION_TRUST_COLLAPSE
```

## 21. Verbindliche Verbote

```text
NO_AFGHAN_FORCE_OWNED_BY_ISAF
NO_READY_UNIT_FROM_TRANSFER_ALONE
NO_FORCE_PACKAGE_WITHOUT_RESOURCE_PROVENANCE
NO_LEGITIMACY_TO_DIRECT_UNIT_CONVERSION
NO_AUTOMATIC_FULL_INFORMATION_SHARING
NO_UNSUPPORTED_AFGHAN_CAPABILITY
NO_DIRECT_DCS_OR_MOOSE_CONTROL
```

## 22. Acceptance-Kriterien

Das Dossier ist akzeptiert, wenn:

- `AFGHAN_STATE_COMMANDER` der einzige kanonische strategische Name ist;
- DCS-Koalition und Kampagnenfraktion getrennt bleiben;
- afghanische Force Packages eigene Eigentums- und Ressourcenbeziehungen besitzen;
- ISAF-Support keine automatische Befehls- oder Eigentumsübertragung erzeugt;
- Finance, Manpower und Materiel von Legitimität, Capability und Reputation getrennt sind;
- Force Generation Training, Retention, Führung und Zeit benötigt;
- Transition auf Nachhaltigkeit statt formale Übergabe geprüft wird;
- MOOSE ausschließlich genehmigte Force Packages und Operation Plans ausführt.

## 23. Querverweise

```text
01-source-inventory-and-faction-baseline.md
02-common-commander-model.md
03-inter-faction-relations-and-negotiation.md
07-runtime-rulebook-and-action-schema.md
08-commander-memory-belief-and-information-model.md
09-orchestrator-architecture-and-adjudication.md
10-blue-commander-dossier.md
11-blue-mission-demand-force-allocation-and-targeting-schema.md
13-campaign-state-and-event-store-schema.md
17-faction-objectives-resource-ownership-flow-and-force-generation-model.md
18-resource-model-integration-and-dossier-amendments.md
```
