---
document_id: OMW-SP-LLM-COMMANDERS-AFGHAN-STATE-ANSF-DOSSIER
status: DRAFT_RESEARCH_AND_BEHAVIORAL_BASELINE
document_class: FACTION_COMMANDER_DOSSIER
scenario_period: 2010-08-01/2011-12-31
source_branch: docs/optional-llm-commanders
validated_in_dcs: false
---

# Afghanischer Staat und ANSF – Commander-Dossier

## 1. Zweck

Dieses Dokument definiert den historischen, organisatorischen, strategischen und simulationsbezogenen Referenzrahmen für eine eigenständige afghanische Kampagnenfraktion innerhalb des optionalen Multi-Commander-Projekts.

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

Der zugehörige Commander wird zunächst als `AFGHAN_STATE_COMMANDER` beziehungsweise `ANSF_COMMANDER` bezeichnet.

Er ist keine bloße Unterkomponente des BLUE Commanders.

```text
DCS_COALITION = BLUE
CAMPAIGN_FACTION = AFGHAN_STATE
STRATEGIC_AUTONOMY = PARTIAL
COMMAND_AUTHORITY != ISAF_OWNERSHIP
```

Afghanische Einheiten können technisch derselben DCS-Koalition wie ISAF angehören. Im CampaignState besitzen sie dennoch eigene Eigentums-, Führungs-, Ressourcen-, Ziel- und Entscheidungszustände.

## 2. Projektstatus

```text
OPTIONAL_SPECIAL_PROJECT
DRAFT_FACTION_MODEL
NOT_RUNTIME_ACCEPTED
NOT_DCS_VALIDATED
NOT_MAIN_PROJECT_AUTHORITY
```

Dieses Dokument trifft keine Aussage darüber, welche konkreten afghanischen Einheiten bereits im Missionseditor angelegt sind. Namen, Standorte, Inventare und Templates dürfen nur aus vorhandenen Manifesten und quellenqualifizierten Projektentscheidungen übernommen werden.

## 3. Warum eine eigenständige afghanische Fraktion erforderlich ist

Der Aufbau und die schrittweise Übernahme der Sicherheitsverantwortung durch afghanische Institutionen waren für den Szenariozeitraum zentrale strategische Ziele.

Der NATO-Gipfel von Lissabon legte im November 2010 fest, dass der Übergang zu afghanischer Sicherheitsführung Anfang 2011 beginnen und bis Ende 2014 zur vollständigen afghanischen Sicherheitsverantwortung führen sollte. Die erste Transition-Tranche begann 2011.

Die afghanischen Kräfte waren zugleich noch deutlich von Koalitionsunterstützung abhängig. Eine GAO-Bewertung stellte für September 2010 fest, dass keine bewertete ANA-Einheit das volle Missionsspektrum unabhängig von Koalitionshilfe durchführen konnte. Wachstum, Ausbildung, Führung, Ausrüstung, Attrition und langfristige Finanzierung blieben wesentliche Probleme.

Daraus folgt für die Simulation:

```text
AFGHAN_LED != AFGHAN_INDEPENDENT
PARTNERED != SUBORDINATE_PROPERTY
TRAINED_AND_EQUIPPED != SUSTAINABLY_CAPABLE
FORMAL_UNIT_STRENGTH != MISSION_READY_STRENGTH
```

Ohne eigene afghanische Fraktion wären folgende Kampagnenfragen nicht abbildbar:

- ob afghanische Einheiten tatsächlich selbständiger werden;
- ob sie Operationen planen, führen und erhalten können;
- ob Bevölkerung und lokale Autoritäten ihnen vertrauen;
- ob ausgebildetes Personal in der Organisation verbleibt;
- ob Material einsatzbereit bleibt oder verloren beziehungsweise umgeleitet wird;
- ob die afghanische Führung eine BLUE-Priorisierung akzeptiert;
- ob ein Gebiet nach Reduzierung der ISAF-Präsenz gehalten werden kann;
- ob Transition nur formal erklärt oder praktisch tragfähig ist.

## 4. Quellen- und Modellierungsgrenzen

Historische und fachliche Grundlagen sind insbesondere:

- NATO, `Lisbon Summit Declaration`, 20.11.2010;
- NATO, `Inteqal: Transition to Afghan lead (2011-2014)`;
- U.S. GAO, `Afghanistan Security: Afghan Army Growing, but Additional Trainers Needed; Long-term Costs Not Determined`, GAO-11-66;
- U.S. GAO, `Afghanistan's Donor Dependence`, GAO-11-948R;
- SIGAR- und CSTC-A/NTM-A-Unterlagen zur Finanzierung, Ausbildung, Ausrüstung und Erhaltung der ANSF;
- bestehende OMW-Dokumentation zu ORBAT, Basierung, Transition, COIN, Governance, Logistik, Partnering und Air C2.

Offizielle Referenzen:

- https://www.nato.int/en/about-us/official-texts-and-resources/official-texts/2010/11/20/lisbon-summit-declaration
- https://www.nato.int/en/what-we-do/operations-and-missions/inteqal-transition-to-afghan-lead-2011-2014
- https://www.gao.gov/products/gao-11-66
- https://www.gao.gov/products/gao-11-948r

Jede Aussage ist einer der folgenden Klassen zuzuordnen:

```text
SOURCE_DOCUMENTED
SOURCE_REPORTED_UNCORROBORATED
ANALYTICAL_INFERENCE
SIMULATION_ABSTRACTION
DESIGN_DECISION
UNKNOWN
```

Verbindliche Grenzen:

```text
AFGHAN_STATE != UNIFIED_PERFECTLY_COMPLIANT_ACTOR
ANSF != SINGLE_HOMOGENEOUS_FORCE
ANA_CAPABILITY != ANP_CAPABILITY
FORMAL_COMMAND != COMPLETE_LOCAL_COMPLIANCE
DONOR_FINANCING != AFGHAN_SELF_SUSTAINMENT
UNIT_PRESENT != UNIT_EFFECTIVE
EQUIPMENT_DELIVERED != EQUIPMENT_OPERATIONAL
POPULATION_SUPPORT_FOR_ANSF != SUPPORT_FOR_EVERY_GOVERNMENT_ACTOR
```

## 5. Strategische Identität

```text
PRIMARY_IDENTITY = SOVEREIGN_STATE_AND_SECURITY_PARTNER
PRIMARY_METHOD = EXPANDING_AFGHAN_SECURITY_CONTROL_WITH_COALITION_SUPPORT
PRIMARY_STRENGTH = LEGAL_AUTHORITY_LOCAL_PRESENCE_AND_GROWING_FORCE_STRUCTURE
PRIMARY_WEAKNESS = CAPABILITY_GAPS_DEPENDENCY_AND_INTERNAL_FRICTION
```

Der Afghan State Commander repräsentiert keine einzelne reale Person. Er ist eine Simulationsabstraktion für die kampagnenrelevante afghanische staatliche und sicherheitspolitische Entscheidungsseite.

Er verfolgt gleichzeitig:

- Erhalt des Staates und seiner Institutionen;
- Schutz wichtiger Bevölkerungs- und Regierungszentren;
- Ausbau eigener Sicherheitsverantwortung;
- Erhalt und Entwicklung der ANSF;
- Begrenzung insurgenter Parallelherrschaft;
- Sicherung staatlicher Einnahmen, Ausrüstung und Zugänge;
- politische und regionale Ausbalancierung;
- Nutzung von Koalitionsunterstützung ohne dauerhafte vollständige Abhängigkeit.

## 6. Strategische Zielhierarchie

Vorläufige Ausgangsreihenfolge:

```text
1. PRESERVE_AFGHAN_STATE_SURVIVAL
2. PRESERVE_ANSF_FORCE_COHESION
3. PROTECT_CRITICAL_POPULATION_AND_GOVERNMENT_CENTERS
4. PRESERVE_COMMAND_C2_AND_KEY_SECURITY_INSTALLATIONS
5. EXPAND_AFGHAN_SECURITY_RESPONSIBILITY
6. DENY_INSURGENT_PARALLEL_CONTROL
7. MAINTAIN_CRITICAL_ROUTES_AND_DISTRICT_ACCESS
8. IMPROVE_LOCAL_GOVERNMENT_AND_ANSF_LEGITIMACY
9. BUILD_INDEPENDENT_OPERATIONAL_CAPABILITY
10. SECURE_FINANCE_EQUIPMENT_AND_SUSTAINMENT
11. RETAIN_PERSONNEL_AND_LOCAL_COMMANDERS
12. REDUCE_DEPENDENCE_ON_COALITION_ENABLERS
13. PRESERVE_POLITICAL_AND_REGIONAL_BALANCE
14. SUPPORT_SUSTAINABLE_TRANSITION
```

Diese Ziele sind nicht immer deckungsgleich mit den kurzfristigen Prioritäten des BLUE Commanders.

## 7. Verhältnis zu ISAF und BLUE

### 7.1 Grundbeziehung

```text
RELATIONSHIP = ALLIED_PARTNER
RESOURCE_OWNERSHIP = SEPARATE
COMMAND_AUTHORITY = CONTEXT_DEPENDENT
INTELLIGENCE_SHARING = PARTIAL
OPERATIONAL_DEPENDENCY = VARIABLE
```

ISAF kann:

- ausbilden;
- beraten;
- Ausrüstung und Finanzierung bereitstellen;
- Enabler reservieren;
- gemeinsame Operationen vorschlagen;
- kritische Unterstützung leisten;
- Kapazitätsentwicklung priorisieren.

ISAF besitzt afghanische Einheiten jedoch nicht automatisch und darf sie im CampaignState nicht wie eigenes Inventar behandeln.

### 7.2 Befehls- und Operationsbeziehungen

Jede gemeinsame Operation erhält genau eine Führungsform:

```text
COALITION_LED
PARTNERED
AFGHAN_LED_WITH_COALITION_ENABLERS
AFGHAN_LED_ADVISED
AFGHAN_INDEPENDENT
```

Beispiel:

```yaml
operation_relationship:
  lead_faction: AFGHAN_STATE
  command_relationship: AFGHAN_LED_WITH_COALITION_ENABLERS
  afghan_force_packages:
    - ANA_INFANTRY_PACKAGE_01
    - ANP_DISTRICT_PACKAGE_03
  coalition_enablers:
    - ISR
    - MEDEVAC
    - EOD_ADVISORY
    - CAS_ON_VALID_REQUEST
```

Der BLUE Commander darf Enabler anbieten, priorisieren oder verweigern. Der Afghan State Commander entscheidet im Rahmen seiner Autorität, ob und wie eigene Kräfte eingesetzt werden.

### 7.3 Typische Interessendifferenzen

| Lage | BLUE-Priorität | Mögliche afghanische Priorität |
|---|---|---|
| gefährlicher Distrikt | Druck auf RED erhöhen | eigene Kräfte erhalten |
| kurzfristige Operation | messbare Wirkung | lokale Beziehungen berücksichtigen |
| Stationierung | Kampagnenschwerpunkt | politische und regionale Balance |
| Material | missionsbezogen reservieren | Einheit dauerhaft ausrüsten |
| lokaler Machthaber | Korruption begrenzen | politische Kooperation erhalten |
| Transition | Verantwortung erhöhen | weitere Enabler sichern |
| Festnahme oder Razzia | Netzwerk stören | lokale Spannungen vermeiden |
| Checkpoint | Route sichern | Präsenz, Einnahmen und Patronage erhalten |

Diese Friktionen sind keine automatische Illoyalität, sondern Teil einer eigenständigen staatlichen und organisatorischen Interessenlage.

## 8. Organisationsmodell

Die Fraktion wird nicht als einheitliche Organisation modelliert.

### 8.1 Afghan National Army

Schwerpunkte:

```text
territorial_and_mobile_security_operations
partnered_ground_operations
holding_key_terrain
route_and_district_security
force_generation_and_training
```

Typische Schwachstellen:

```text
coalition_enabler_dependency
leadership_shortfalls
attrition
absenteeism
logistics_and_maintenance_gaps
specialist_shortages
```

### 8.2 Afghan National Police

Schwerpunkte:

```text
local_presence
checkpoint_and_route_control
law_enforcement
population_contact
local_intelligence_access
```

Typische Schwachstellen:

```text
local_political_pressure
corruption_leakage
uneven_training
infiltration_risk
high_exposure
community_trust_variation
```

### 8.3 ANCOP und spezialisierte Polizeikräfte

Schwerpunkte:

```text
higher_readiness_police_operations
public_order
selected_route_and_area_security
reinforcement_of_local_police
```

### 8.4 Afghan Border Police

Schwerpunkte:

```text
border_and_crossing_control
customs_and_route_access
interdiction
remote_post_security
```

### 8.5 Afghan Intelligence and Security Organizations

Schwerpunkte:

```text
human_intelligence
counter_network_information
source_management
investigative_support
threat_warning
```

### 8.6 Afghan Air Component

Schwerpunkte:

```text
airlift
limited_medical_and_logistics_support
selected_mobility_and_reconnaissance_functions
```

Keine Fähigkeit darf ohne ORBAT-, Zeit-, Basierungs- und Readiness-Nachweis angenommen werden.

## 9. Eigene Ressourcen und gemeinsamer Ressourcenraum

Für das gemeinsame Ressourcenmodell gelten als umkämpfte Grundressourcen:

```text
RECRUITABLE_MANPOWER
FINANCE
MATERIEL
```

Der Afghan State Commander benötigt daraus:

```text
FINANCE
+ RECRUITABLE_MANPOWER
+ MATERIEL
+ TRAINING_CAPACITY
+ TIME
+ RETENTION

-> AFGHAN_FORCE_PACKAGE
```

Die verbindliche Gesamtlogik wird in `17-faction-objectives-resource-ownership-flow-and-force-generation-model.md` definiert.

### 9.1 Finance

Afghanische Finanzmittel können stammen aus:

```text
AFGHAN_STATE_REVENUE
FORMAL_TAX_AND_CUSTOMS
INTERNATIONAL_DONOR_SUPPORT
SECURITY_ASSISTANCE_FUNDING
```

Sie können beeinträchtigt werden durch:

```text
RED_CONTROL_OF_REVENUE_NODES
CORRUPTION_LEAKAGE
DIVERSION
ROUTE_DISRUPTION
LOSS_OF_GOVERNMENT_CONTROL
DONOR_COMMITMENT_REDUCTION
```

### 9.2 Recruitable Manpower

Der afghanische Staat konkurriert regional mit Taliban, Haqqani und HIG um Zugang zu einem begrenzten Rekrutierungspool.

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
ASSASSINATION_OR_INTIMIDATION_OF_RECRUITERS
ATTRITION
ABSENTEEISM
PAY_FAILURE
POOR_LEADERSHIP
LOCAL_GRIEVANCE
```

### 9.3 Materiel

Materiel umfasst abstrakt:

```text
weapons
ammunition
vehicles
communications_equipment
protective_equipment
fuel
maintenance_parts
template_specific_equipment
```

Materiel ist an Warehouses, Basen, Convoys, Cargo oder virtuelle Zuführungsknoten gebunden.

Es kann:

```text
delivered
reserved
consumed
lost
destroyed
diverted
captured
transferred
```

werden.

## 10. Virtuelle Fähigkeiten und Zustände

Nicht alle wichtigen Größen sind Ressourcen.

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

Diese Werte dürfen nicht wie Geld ausgegeben werden.

```text
RESOURCE != CAPABILITY
CAPABILITY != LEGITIMACY
LEGITIMACY != FORCE_PACKAGE
```

## 11. Kräftegenerierung

### 11.1 Grundformel

```text
AFGHAN_FORCE_GENERATION
=
MIN(
  AVAILABLE_FINANCE,
  AVAILABLE_MANPOWER,
  AVAILABLE_MATERIEL,
  TRAINING_CAPACITY
)
× RETENTION_FACTOR
× READINESS_FACTOR
× TIME
```

Die Formel ist eine Modellierungsregel, keine konkrete numerische Festlegung.

### 11.2 Force-Package-Lebenszyklus

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

### 11.3 Keine Sofortwirkung durch BLUE-Unterstützung

```text
BLUE_FINANCE_OR_MATERIEL_TRANSFER
!= IMMEDIATE_READY_UNIT
```

Eine neue afghanische Einheit benötigt:

- verfügbares Personal;
- Finanzierung;
- Ausrüstung;
- Ausbildungszeit;
- Führung;
- ausreichende Personalbindung;
- Logistik und Erhaltung;
- gegebenenfalls fortlaufende Beratung.

### 11.4 Verluste

DCS/MOOSE meldet physische Verluste. Der CampaignState entscheidet über:

```text
force_package_loss
replacement_requirement
surviving_personnel_fraction
materiel_loss
recovery_time
readiness_reduction
political_and_recruitment_effects
```

Gefangennahme, Entwaffnung oder Demobilisierung sind in Version 1 keine regulär aus DCS abgeleiteten Mechaniken. Sie dürfen nur als ausdrücklich adjudizierte Kampagnenereignisse entstehen.

## 12. Population und Legitimität

Die Bevölkerung wird nicht binär zwischen NATO und Taliban aufgeteilt.

Mindestens getrennt:

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

Ein Gebiet kann gleichzeitig:

```text
oppose_taliban
 distrust_isaf
 distrust_local_government
 support_ana
 distrust_anp
```

sein.

### 12.1 Einfluss auf den afghanischen Staat

Legitimität und Vertrauen beeinflussen:

```text
recruitment_access
personnel_retention
local_information_access
checkpoint_acceptance
state_revenue_access
willingness_to_report_red_activity
willingness_to_support_operations
```

Sie erzeugen nicht unmittelbar eine Einheit.

## 13. Intelligence-Profil

Mögliche Informationsquellen:

```text
LOCAL_POLICE_REPORT
ANA_PATROL_REPORT
NDS_OR_OTHER_SECURITY_REPORT
GOVERNMENT_OFFICIAL_REPORT
COMMUNITY_ELDER_REPORT
HUMINT_SOURCE
ISAF_SHARED_INTELLIGENCE
CHECKPOINT_REPORT
CAPTURED_OR_RECOVERED_MATERIAL_REPORT
```

Der Afghan State Commander erhält kein vollständiges BLUE-Lagebild.

```text
BLUE_INFORMATION != AUTOMATIC_AFGHAN_INFORMATION
AFGHAN_INFORMATION != AUTOMATIC_BLUE_INFORMATION
```

Informationsaustausch hängt von:

```text
trust
classification
source_protection
liaison_capacity
political_sensitivity
operational_security
technical_interoperability
```

ab.

## 14. Führungsfriktion

Unterstellte Akteure besitzen mindestens:

```yaml
subordinate_profile:
  loyalty_to_state: 0..100
  loyalty_to_local_patron: 0..100
  competence: 0..100
  discipline: 0..100
  leadership_quality: 0..100
  corruption_pressure: 0..100
  absenteeism_pressure: 0..100
  defection_risk: 0..100
  infiltration_risk: 0..100
  coalition_dependency: 0..100
  local_legitimacy: 0..100
```

Mögliche Reaktionen auf einen Auftrag:

```text
COMPLY
PARTIALLY_COMPLY
REQUEST_MORE_SUPPORT
DELAY
MODIFY_FOR_LOCAL_CONDITIONS
REFUSE_FOR_CAPABILITY_REASON
REFUSE_FOR_POLITICAL_REASON
MISREPORT_READINESS
ABORT_AFTER_START
```

## 15. Commander-Persönlichkeitsbaseline

Die Werte sind Simulationsparameter und keine Bewertung einer realen Person.

```yaml
personality:
  aggression: 55
  patience: 69
  risk_tolerance: 46
  loss_tolerance: 43
  prestige_sensitivity: 76
  ideological_rigidity: 48
  pragmatism: 81
  political_sensitivity: 93
  population_sensitivity: 78
  operational_security_bias: 64
  deception_preference: 49
  retaliation_bias: 47
  negotiation_preference: 72
  delegation_preference: 71
  distrust_of_subordinates: 63
  adaptability: 76
```

Der Commander:

- will staatliche Handlungsfähigkeit sichtbar erhalten;
- vermeidet nach Möglichkeit Verluste, die Kohäsion oder Legitimität gefährden;
- fordert häufig Koalitions-Enabler an;
- kann politische und regionale Erwägungen höher gewichten als BLUE;
- priorisiert häufig den Erhalt eigener Kräfte vor maximalem kurzfristigem Druck;
- reagiert empfindlich auf öffentliche Demütigung oder Behandlung als bloßer Untergebener;
- kann lokales Wissen besser als BLUE besitzen, zugleich aber unvollständig oder politisch verzerrt informiert sein.

## 16. Zulässige strategische Aktionen

Abstrakte Aktionsklassen:

```text
REQUEST_COALITION_SUPPORT
ACCEPT_PARTNERED_OPERATION
PROPOSE_AFGHAN_LED_OPERATION
DECLINE_OPERATION
REASSIGN_FORCE_PACKAGE
REINFORCE_DISTRICT
SECURE_REVENUE_NODE
SECURE_ROUTE_OR_CHECKPOINT
PROTECT_RECRUITMENT_ACCESS
ALLOCATE_TRAINING_CAPACITY
ALLOCATE_MATERIEL
PRIORITIZE_FORCE_RECOVERY
REQUEST_ISR
REQUEST_MEDEVAC_OR_LOGISTICS_SUPPORT
INVESTIGATE_CORRUPTION_OR_DIVERSION
REPLACE_LOCAL_COMMANDER
NEGOTIATE_LOCAL_SECURITY_ARRANGEMENT
TRANSFER_SECURITY_RESPONSIBILITY
DELAY_TRANSITION
DECLARE_TRANSITION_READY
```

Diese Aktionen sind keine direkten MOOSE-Methodenaufrufe.

## 17. Transition-Modell

Ein Raum durchläuft nicht automatisch nur aufgrund eines Datums die Transition.

```text
COALITION_LED
-> PARTNERED
-> AFGHAN_LED_WITH_COALITION_ENABLERS
-> AFGHAN_LED_ADVISED
-> AFGHAN_INDEPENDENT
```

Voraussetzungen können umfassen:

```yaml
transition_assessment:
  local_security: 0..100
  afghan_force_readiness: 0..100
  afghan_command_capability: 0..100
  logistics_sustainability: 0..100
  local_government_capacity: 0..100
  population_confidence: 0..100
  red_freedom_of_action: 0..100
  coalition_enabler_dependency: 0..100
  reversibility_risk: 0..100
```

Transition ist erfolgreich, wenn die afghanische Seite Verantwortung nachhaltig und nicht nur nominell übernehmen kann.

## 18. Erfolgskriterien

```text
AFGHAN_STATE_SURVIVES
ANSF_COHESION_MAINTAINED
STATE_ACCESS_TO_MANPOWER_FINANCE_AND_MATERIEL_SUSTAINED
RED_PARALLEL_CONTROL_REDUCED
AFGHAN_LED_OPERATIONS_INCREASE
COALITION_DEPENDENCY_DECREASES
CRITICAL_ROUTES_AND_CENTERS_HELD
POPULATION_TRUST_DOES_NOT_COLLAPSE
TRANSITION_BECOMES_SUSTAINABLE
```

Der Afghan State Commander muss nicht jede RED-Einheit zerstören. Strategischer Erfolg entsteht durch ausreichende eigene Handlungsfähigkeit und die Verringerung gegnerischer Fähigkeit, den Staat zu verdrängen.

## 19. Scheiternsbedingungen

```text
STATE_REVENUE_AND_DONOR_FLOW_COLLAPSE
RECRUITMENT_AND_RETENTION_COLLAPSE
MATERIEL_LOSS_EXCEEDS_REPLACEMENT
ANSF_FORCE_COHESION_COLLAPSES
LOCAL_COMMANDERS_DEFECT_OR_FRAGMENT
CRITICAL_DISTRICTS_AND_ROUTES_LOST
POPULATION_TRUST_COLLAPSES
COALITION_SUPPORT_WITHDRAWS_BEFORE_SUSTAINABILITY
TRANSITION_REVERSES
```

## 20. Scripted-Commander-Baseline

Für den ersten deterministischen PoC ist kein fünftes LLM erforderlich. Der afghanische Commander muss jedoch als eigenständiger geskripteter Commander vorhanden sein.

```text
AFGHAN_SCRIPTED_COMMANDER_REQUIRED = YES
AFGHAN_LLM_REQUIRED_FOR_FIRST_POC = NO
```

Baseline-Prioritäten:

```text
1. prevent state or force collapse
2. protect critical population and government centers
3. preserve force cohesion and replacement ability
4. request missing coalition enablers
5. secure revenue, recruitment and materiel access
6. accept operations that match readiness
7. decline or modify operations that exceed capability
8. increase Afghan lead when sustainability permits
9. avoid premature transition
10. reduce long-term dependency
```

## 21. Testvarianten

### 21.1 Transition-Oriented Commander

```text
high_partner_cooperation
high_training_priority
high_willingness_to_take_lead
moderate_risk_tolerance
```

### 21.2 Force-Preservation Commander

```text
high_loss_aversion
high_support_demand
slow_transition
strong_focus_on_key_centers
```

### 21.3 Politically Constrained Commander

```text
high_political_sensitivity
high_regional_balance_pressure
high_local_patron_influence
uneven_command_compliance
```

## 22. MOOSE-First-Grenze

```text
AFGHAN_STATE_COMMANDER
-> proposes intent and resource use

ORCHESTRATOR
-> validates ownership, authority, resources and capability

DCS_MOOSE_ADAPTER
-> maps approved operation to existing MOOSE functionality

MOOSE
-> creates and manages tactical missions and force packages

DCS
-> simulates physical execution
```

Vor eigenem Lua-Code ist für jede Funktion die tatsächlich eingebundene MOOSE-Version 2.9.18 zu prüfen.

Insbesondere zu prüfen:

- getrennte Eigentümerschaft und Tasking verbündeter Gruppen;
- COMMANDER-, AUFTRAG-, AIRWING- und OPSTRANSPORT-Nutzung;
- Missions- und Resultatmeldungen;
- Warehouse-, Cargo- und Logistikabbildung;
- Übergabe und Wiederverwendung bestehender Gruppen;
- sichere Trennung zwischen CampaignState-IDs und DCS-Gruppen-IDs.

## 23. Verbindliche Entscheidungen

```text
AFGHAN_STATE_FACTION_REQUIRED = YES
SEPARATE_DCS_COALITION_REQUIRED = NO
SEPARATE_CAMPAIGN_OWNERSHIP_REQUIRED = YES
SEPARATE_COMMANDER_VIEW_REQUIRED = YES
SEPARATE_RESOURCE_ACCOUNT_REQUIRED = YES
BLUE_DIRECT_OWNERSHIP_OF_ANSF = NO
SCRIPTED_AFGHAN_COMMANDER_REQUIRED_FOR_FIRST_POC = YES
FULL_AFGHAN_LLM_REQUIRED_FOR_FIRST_POC = NO
COMMON_RESOURCE_MODEL_REFERENCE = DOCUMENT_17
```

## 24. Offene Entscheidungen

Noch festzulegen:

- endgültiger Commander-Identifier;
- genaue Organisationsabgrenzung zwischen ANA, ANP, ANCOP, ABP und Nachrichtendiensten;
- regionaler Ausgangsbestand afghanischer Force Packages;
- Ausgangswerte für Legitimität, Rekrutierung, Retention und Readiness;
- Übergabekriterien pro Region;
- konkrete Kosten und Zeiten der Force-Package-Generierung;
- zulässige afghanische Luft- und Spezialfähigkeiten;
- MOOSE-2.9.18-Abbildung der Partnering- und Führungsbeziehungen;
- spätere Entscheidung über einen eigenständigen Afghan-State-LLM-Commander.
