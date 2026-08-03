---
document_id: OMW-SP-LLM-COMMANDERS-RESOURCE-INTEGRATION-AMENDMENTS
status: DRAFT_CROSS_DOCUMENT_DECISION
document_class: CROSS_DOCUMENT_INTEGRATION_AND_AMENDMENT
scenario_period: 2010-08-01/2011-12-31
source_branch: docs/optional-llm-commanders
validated_in_dcs: false
authoritative_for:
  - integration of Afghan State faction into the commander architecture
  - interpretation of resource fields in existing dossiers
  - transition from four to five campaign commanders
  - cross-document update requirements caused by document 17
---

# Integration des Afghan State Commanders und Amendments zum Ressourcenmodell

## 1. Zweck

Dieses Dokument integriert die neue afghanische Kampagnenfraktion und das gemeinsame Ressourcenmodell in den bisherigen Dokumentationsstand.

Es verhindert, dass ältere Dossiers weiterhin so gelesen werden, als besäße jede Fraktion einen unabhängigen, unbegrenzt regenerierenden Ressourcenpool.

Verbindliche Priorität:

```text
DOCUMENT_17
is authoritative for
resource definitions ownership flow and force generation
```

```text
DOCUMENT_16
is authoritative for
the Afghan State and ANSF commander baseline
```

Die bestehenden Dossiers bleiben für historische Identität, Zielhierarchie, Persönlichkeit, Führungsverhalten und fraktionsspezifische Präferenzen gültig. Ihre Ressourcenfelder sind jedoch durch Dokument 17 zu interpretieren.

## 2. Neue Commander-Gesamtarchitektur

Bisher:

```text
BLUE_COMMANDER
TALIBAN_COMMANDER
HAQQANI_COMMANDER
HIG_COMMANDER
```

Neu:

```text
BLUE_ISAF_COMMANDER
AFGHAN_STATE_COMMANDER
TALIBAN_COMMANDER
HAQQANI_COMMANDER
HIG_COMMANDER
```

Technische Koalitionszuordnung:

```text
BLUE_ISAF_COMMANDER.dcs_coalition = BLUE
AFGHAN_STATE_COMMANDER.dcs_coalition = BLUE
```

Kampagnenzuordnung:

```text
BLUE_ISAF_COMMANDER.faction_id = ISAF
AFGHAN_STATE_COMMANDER.faction_id = AFGHAN_STATE
```

Die beiden Fraktionen besitzen getrennte:

```text
force_package_ownership
resource_accounts
commander_views
mission_demands
operation_authority
reservations
loss_assessment
success_conditions
```

## 3. Gemeinsame Ressourcendefinition

Die folgenden drei Größen sind die einzigen gemeinsamen, umkämpften Grundressourcen der ersten Version:

```text
RECRUITABLE_MANPOWER
FINANCE
MATERIEL
```

Der physische Output ist:

```text
FORCE_PACKAGE
```

Die folgenden Größen sind keine Grundressourcen:

```text
LEGITIMACY
REPUTATION
VOLUNTARY_SUPPORT
COERCIVE_CONTROL
PRESTIGE
LOYALTY
COMMAND_COHESION
HUMINT_ACCESS
CAPABILITY
```

Sie beeinflussen Zugriff, Regeneration, Erhaltung, Risiko oder Gate-Prüfungen.

## 4. Amendment zu Dokument 02 – Common Commander Model

`02-common-commander-model.md` ist künftig mit fünf statt vier Kampagnen-Commandern zu lesen.

Neue gemeinsame Commander-Pflichtfelder:

```yaml
commander:
  commander_id:
  faction_id:
  dcs_coalition:
  strategic_objectives: []
  owned_force_packages: []
  resource_account_ids: []
  permitted_resource_sources: []
  commander_view_id:
  authority_scope:
  relationship_ids: []
```

Zusätzliche Trennung:

```text
SAME_DCS_COALITION != SAME_FACTION
ALLIED_RELATIONSHIP != SHARED_OWNERSHIP
SUPPORT_TRANSFER != COMMAND_TRANSFER
```

Der Afghan State Commander verwendet dieselben sechs Commander-Layer wie die übrigen Commander:

```text
IDENTITY
STRATEGIC_INTENT
ORGANIZATIONAL_AUTHORITY
CAPABILITIES_AND_RESOURCES
KNOWLEDGE_AND_BELIEFS
DECISION_AND_ACTION
```

## 5. Amendment zu Dokument 03 – Inter-Faction Relations

Die Beziehungsarchitektur wird um folgende gerichtete Beziehungen erweitert:

```text
ISAF -> AFGHAN_STATE
AFGHAN_STATE -> ISAF
AFGHAN_STATE -> TALIBAN
TALIBAN -> AFGHAN_STATE
AFGHAN_STATE -> HAQQANI
HAQQANI -> AFGHAN_STATE
AFGHAN_STATE -> HIG
HIG -> AFGHAN_STATE
```

### 5.1 ISAF und Afghan State

Erforderliche Dimensionen:

```yaml
partner_relationship:
  political_alignment: 0..100
  operational_trust: 0..100
  intelligence_sharing: 0..100
  training_support: 0..100
  finance_support: 0..100
  materiel_support: 0..100
  enabler_dependency: 0..100
  command_friction: 0..100
  transition_pressure: 0..100
  perceived_respect_for_sovereignty: 0..100
```

### 5.2 Afghan State und RED

Diese Beziehungen sind nicht nur militärische Feindschaft. Sie umfassen Konkurrenz um:

```text
population_access
recruitment
state_and_shadow_revenue
local_commanders
routes_and_checkpoints
materiel
political_legitimacy
information
```

## 6. Amendment zum Taliban-Dossier

Die strategische Zielhierarchie aus `04-taliban-commander-dossier.md` bleibt gültig.

Insbesondere gültig bleiben:

```text
preserve leadership
preserve network cohesion
maintain local intelligence access
maintain or expand political control
undermine government legitimacy
protect recruitment finance and logistics
retain reinfiltration access
```

### 6.1 Aktualisierte Ressourceninterpretation

Frühere Felder wie:

```text
manpower
weapons
finance_access
taxation_access
recruitment_access
cache_access
```

werden künftig aufgeteilt in:

```text
RESOURCE_ACCOUNT:
  RECRUITABLE_MANPOWER
  FINANCE
  MATERIEL

ACCESS_OR_STATE:
  recruitment_access
  taxation_access
  cache_access
  voluntary_support
  coercive_control
  shadow_governance
```

### 6.2 Keine automatische Einheitenerzeugung

```text
HIGH_TALIBAN_SUPPORT
!= NEW_UNIT
```

Neue Taliban-Force-Packages benötigen:

```text
finance
+ manpower
+ materiel
+ cadre capacity
+ time
```

### 6.3 Repression

Repression wird nicht mit freiwilliger Unterstützung zusammengeführt.

```text
VOLUNTARY_SUPPORT != COERCIVE_CONTROL
```

Sie kann kurzfristig Zugriff erhöhen und langfristig Unterstützung, Wirtschaftsleistung oder Stabilität beschädigen.

## 7. Amendment zum Haqqani-Dossier

Die strategische Identität aus `05-haqqani-commander-dossier.md` bleibt gültig:

```text
FAMILY_NETWORK_AND_OPERATIONAL_BROKER
RESOURCE_AGGREGATION_AND_HIGH_COMPLEXITY_OPERATIONS
```

### 7.1 Aktualisierte Ressourceninterpretation

Frühere Felder wie:

```text
finance_access
weapons_access
explosives_access
specialist_access
staging_capacity
attack_cell_capacity
```

werden getrennt in:

```text
RESOURCE_ACCOUNT:
  FINANCE
  RECRUITABLE_MANPOWER
  MATERIEL

ACCESS_OR_GATE:
  external_support_access
  specialist_access
  trusted_broker_capacity
  route_redundancy
  staging_access
  compartmentation
  target_intelligence
```

### 7.2 Fraktionsspezifische Force Generation

```text
finance
+ selected manpower
+ materiel
+ network access
+ cadre or specialist gate
+ time

-> HAQQANI_FORCE_PACKAGE
```

Haqqani benötigt nicht zwingend den größten regionalen Manpower-Anteil. Selektiver Kader-, Broker-, Spezialisten- und Routenzugang ist wichtiger als flächendeckende Rekrutierung.

### 7.3 Externe Unterstützung

Externe Unterstützung ist ein endlicher umkämpfter Zufluss. Ein höherer Haqqani-Anteil reduziert den gleichzeitig verfügbaren Anteil anderer RED-Fraktionen.

## 8. Amendment zum HIG-Dossier

Die strategische Identität aus `06-hig-commander-dossier.md` bleibt gültig:

```text
POLITICAL_MILITARY_FACTION_NETWORK
LOCAL_POWER_BROKERAGE_AND_OPPORTUNISTIC_COERCION
```

### 8.1 Aktualisierte Ressourceninterpretation

Frühere Felder wie:

```text
manpower
weapons
explosives
revenue_access
cache_capacity
political_capital
```

werden getrennt in:

```text
RESOURCE_ACCOUNT:
  FINANCE
  RECRUITABLE_MANPOWER
  MATERIEL

ACCESS_OR_STATE:
  patronage_strength
  regional_recruitment_access
  local_commander_loyalty
  political_capital
  negotiation_credibility
  representation_clarity
```

### 8.2 Fraktionsspezifische Force Generation

```text
finance
+ regional manpower
+ materiel
+ patronage access
+ local commander gate
+ time

-> HIG_FORCE_PACKAGE
```

### 8.3 Konkurrenz

HIG konkurriert besonders mit Taliban um:

```text
regional manpower
local commanders
local revenue shares
political representation
patronage networks
route and district access
```

## 9. Amendment zum BLUE-Dossier

Die strategische Zielhierarchie aus `10-blue-commander-dossier.md` bleibt grundsätzlich gültig.

Sie wird präzisiert:

```text
BLUE_PRIMARY_GOAL
!= DESTROY_EVERY_TALIBAN_UNIT
```

BLUE verfolgt im Szenariozeitraum:

```text
deny strategic terrorist safe haven
prevent insurgent overthrow of the Afghan state
reduce RED operational and political capability
protect priority populations and coalition forces
support Afghan security capability
preserve critical routes and bases
prepare sustainable transition
```

Nicht fest gebundene Kämpfer können historisch auch über Reintegration und Versöhnung aus dem Konflikt gelöst werden. Da DCS Gefangennahme und Entwaffnung nicht regulär abbildet, sind solche Ergebnisse nur als ausdrücklich adjudizierte Kampagnenereignisse zulässig.

### 9.1 ISAF-Eigenkräfte

ISAF rekrutiert nicht aus dem afghanischen Manpower-Pool.

```text
NATIONAL_FORCE_POOL
+ COALITION_COMMITMENT
+ REPLACEMENT_CAPACITY
+ TIME

-> ISAF_FORCE_PACKAGE
```

### 9.2 Lokales Ansehen

```text
ISAF_LOCAL_TRUST
!= ISAF_UNIT_GENERATION_RESOURCE
```

Lokales Vertrauen beeinflusst:

```text
HUMINT
population access
source protection
freedom of interaction
political cost
operation acceptance
```

### 9.3 Verhältnis zu ANSF

Afghanische Einheiten werden aus dem BLUE-Inventar entfernt und gehören `AFGHAN_STATE`.

BLUE kann übertragen oder bereitstellen:

```text
finance support
materiel support
training capacity
advisors
enablers
intelligence products
```

Diese Unterstützung erzeugt nicht sofort eine einsatzbereite afghanische Einheit.

## 10. Amendment zum CampaignState-Schema

`13-campaign-state-and-event-store-schema.md` benötigt folgende zusätzliche Aggregate:

```text
ResourceSource
ResourceAccount
ResourceReservation
ResourceTransfer
AccessNode
FactionShare
PopulationState
ForceGenerationOrder
ForcePackage
```

### 10.1 ResourceSource

```yaml
resource_source:
  source_id:
  resource_type: MANPOWER | FINANCE | MATERIEL
  region_id:
  capacity:
  current_available:
  regeneration_per_turn:
  legal_owner:
  physical_controller:
  disruption_level:
  exhaustion_level:
  beneficiary_shares: {}
  version:
```

### 10.2 ResourceAccount

```yaml
resource_account:
  account_id:
  faction_id:
  resource_type:
  available:
  reserved:
  committed:
  in_transit:
  version:
```

### 10.3 ForceGenerationOrder

```yaml
force_generation_order:
  order_id:
  faction_id:
  template_id:
  source_region:
  resource_reservations: []
  organizational_gates: []
  generation_started_at:
  generation_complete_at:
  state:
```

### 10.4 Zusätzliche Invarianten

```text
NO_RESOURCE_GENERATION_WITHOUT_SOURCE
NO_FORCE_PACKAGE_WITHOUT_RESOURCE_COMMITMENT
NO_ISAF_RECRUITMENT_FROM_AFGHAN_MANPOWER
NO_POPULATION_OWNERSHIP
NO_REPUTATION_TO_DIRECT_UNIT_CONVERSION
NO_DUPLICATE_RESOURCE_CREDIT
```

## 11. Amendment zur Orchestrator-Architektur

`09-orchestrator-architecture-and-adjudication.md` wird um folgende Pipeline erweitert:

```text
RESOURCE_SOURCE_UPDATE
-> ACCESS_SHARE_CALCULATION
-> FACTION_RESOURCE_ACCOUNT_UPDATE
-> RESOURCE_RESERVATION
-> FORCE_GENERATION_VALIDATION
-> FORCE_PACKAGE_CREATION
-> OPERATION_ASSIGNMENT
-> MOOSE_MATERIALIZATION
-> RESULT_EVENT
-> RESOURCE_AND_CONTROL_UPDATE
```

Der Orchestrator muss zusätzlich:

- Quellkapazitäten aktualisieren;
- Beneficiary Shares verwalten;
- Ressourcenreservierungen transaktionssicher prüfen;
- Force-Generation-Zeiten verwalten;
- Materialisierung und Ressourcenverbrauch idempotent koppeln;
- doppelte DCS-Ergebnisse abfangen.

## 12. Amendment zum Test-Szenario-Dokument

`12-multi-commander-test-scenarios.md` wird von vier auf fünf Commander erweitert.

Neue Testgruppen:

```text
AFGHAN_STATE_AUTONOMY
ISAF_AFGHAN_PARTNER_FRICTION
RESOURCE_SOURCE_COMPETITION
RED_INTER_FACTION_RESOURCE_COMPETITION
FORCE_GENERATION
RESOURCE_DENIAL
RESOURCE_CAPTURE_AND_TRANSFER
POPULATION_ACCESS
```

Mindestfälle:

```text
AFG-001 Afghan commander declines operation without required enablers
AFG-002 BLUE cannot task Afghan unit as owned ISAF inventory
AFG-003 Afghan-led operation can reserve coalition enablers without transferring unit ownership
AFG-004 donor transfer does not create an immediate ready unit
AFG-005 premature transition is rejected

RES-001 one manpower share cannot generate two force packages
RES-002 Taliban recruitment gain reduces available regional manpower
RES-003 Haqqani external support gain reduces other RED shares
RES-004 HIG local commander loss reduces regional recruitment access
RES-005 route control changes finance and materiel flow
RES-006 captured materiel is removed from prior owner
RES-007 destroyed materiel cannot be credited
RES-008 ISAF local trust does not generate ISAF units
RES-009 repression and voluntary support remain separate
RES-010 force package cannot materialize before MOOSE adapter acceptance
```

## 13. Amendment zum deterministischen Test Harness

`14-deterministic-test-harness-and-scripted-commanders.md` benötigt einen fünften Baseline-Commander:

```text
AFGHAN_STATE_BASELINE_V1
```

Baseline-Entscheidungen:

```text
preserve state and force cohesion
protect critical centers
request missing coalition enablers
secure revenue manpower and materiel access
accept only capability-matched operations
increase Afghan lead when sustainable
delay premature transition
```

Zusätzliche Fixtures:

```text
regional manpower source
state and donor finance source
external RED support source
materiel warehouse
route revenue node
five faction resource accounts
force generation queue
```

## 14. Amendment zur Technologieauswahl

Der PoC aus `15-orchestrator-technology-selection-and-deployment-model.md` wird von vier auf fünf Commander erweitert.

```text
POC_COMMANDERS = 5
```

Der Technologievergleich muss zusätzlich messen:

```text
resource transaction safety
share allocation determinism
force generation queue recovery
five commander concurrency
resource source replay
idempotent resource and DCS coupling
```

## 15. README- und Dokumentreihenfolge

Die weitere Dokumentreihenfolge lautet:

```text
16-afghan-state-and-ansf-commander-dossier.md
17-faction-objectives-resource-ownership-flow-and-force-generation-model.md
18-resource-model-integration-and-dossier-amendments.md
19-language-neutral-contracts-and-json-schemas.md
```

Die zuvor als Dokument 16 geplanten sprachneutralen Verträge werden aufgrund der fachlich notwendigen Ressourcen- und Fraktionsentscheidung auf Dokument 19 verschoben.

## 16. DCS- und MOOSE-Grenze

```text
DCS_MOOSE
= physical force package and mission runtime
```

```text
CAMPAIGN_STATE_ORCHESTRATOR
= virtual resource source account reservation and authorization
```

Verbindlich:

```text
LLM_CANNOT_SPAWN
LLM_CANNOT_TRANSFER_RESOURCE_DIRECTLY
ORCHESTRATOR_CANNOT_BYPASS_MOOSE
AFGHAN_AND_ISAF_UNITS_REMAIN_SEPARATE_CAMPAIGN_OWNERSHIP
```

Vor eigenem Lua-Code ist die tatsächlich eingebundene MOOSE-Version 2.9.18 zu prüfen.

## 17. Verbindlicher Konsolidierungsstand

```text
CAMPAIGN_COMMANDER_COUNT = 5

COMMANDERS =
  BLUE_ISAF
  AFGHAN_STATE
  TALIBAN
  HAQQANI
  HIG

COMMON_CONTESTED_RESOURCES =
  RECRUITABLE_MANPOWER
  FINANCE
  MATERIEL

PHYSICAL_OUTPUT =
  FORCE_PACKAGE

RESOURCE_AUTHORITY =
  DOCUMENT_17

AFGHAN_FACTION_AUTHORITY =
  DOCUMENT_16
```

## 18. Noch offene Aktualisierungen

Vor Runtime-Implementierung sind die betroffenen Ursprungsdokumente redaktionell direkt zu aktualisieren. Bis dahin besitzt dieses Amendment Vorrang bei Widersprüchen.

Noch offen:

- direkte Einfügung der Dokument-17-Referenz in 04, 05, 06 und 10;
- Erweiterung der Commander-Anzahl in 02, 09, 12, 13, 14 und 15;
- Erstellung der sprachneutralen Schemas in Dokument 19;
- konkrete ResourceSource-Ausgangsdaten;
- Force-Package-Kosten und Aufbauzeiten;
- MOOSE-2.9.18-Prüfung für Materialisierung, Warehouses und Logistik.
