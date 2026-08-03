---
document_id: OMW-SP-LLM-COMMANDERS-SOURCE-INVENTORY
status: DRAFT_RESEARCH_BASELINE
document_class: SOURCE_INVENTORY_AND_ANALYTICAL_BASELINE
scenario_period: 2010-08-01/2011-12-31
source_branch: docs/optional-llm-commanders
validated_in_dcs: false
authoritative_for:
  - source inventory and source-readiness assessment
  - evidence gaps for five faction dossiers
  - evidence basis for resource sources and force generation
---

# Quelleninventar und Fraktionsbaseline

## 1. Zweck

Dieses Dokument erfasst die vorhandene Quellenbasis für fünf getrennte Kampagnen-Commander und das gemeinsame Ressourcenmodell:

```text
BLUE_ISAF_COMMANDER
AFGHAN_STATE_COMMANDER
TALIBAN_COMMANDER
HAQQANI_COMMANDER
HIG_COMMANDER
```

Es bewertet:

- historische und organisatorische Eignung;
- strategische Ziele;
- Befehls- und Eigentumsbeziehungen;
- ResourceSources und Ressourcenzugänge;
- Force Generation und Erhaltung;
- Bevölkerungszugang und Informationsgewinn;
- Beziehungen, Konkurrenz und Verhandlungen;
- noch offene Quellenlücken.

Dieses Inventar erzeugt keine Runtime-Bestände, DCS-Gruppen, Templates oder endgültigen numerischen Parameter.

## 2. Aussageklassen

```text
SOURCE_DOCUMENTED
SOURCE_REPORTED_UNCORROBORATED
ANALYTICAL_INFERENCE
SIMULATION_ABSTRACTION
DESIGN_DECISION
UNKNOWN
```

Verbindliche Trennungen:

```text
historical_relationship != permanent_runtime_alliance
formal_subordination != complete_operational_control
shared_enemy != shared_resources
reported_strength != DCS_spawn_count
reported_finance != exact runtime account
population presence != voluntary support
```

## 3. Aktuelle Modellierungsautoritäten

```text
02-common-commander-model.md
03-inter-faction-relations-and-negotiation.md
04-taliban-commander-dossier.md
05-haqqani-commander-dossier.md
06-hig-commander-dossier.md
10-blue-commander-dossier.md
13-campaign-state-and-event-store-schema.md
16-afghan-state-and-ansf-commander-dossier.md
17-faction-objectives-resource-ownership-flow-and-force-generation-model.md
18-resource-model-integration-and-dossier-amendments.md
```

Dieses Dokument ist Quelleninventar, nicht die primäre Runtime-Autorität.

## 4. Hauptprojektquellen und technische Autoritäten

| Dokument oder Dokumentgruppe | Hauptnutzen |
|---|---|
| `docs/00-project-governance.md` | Projektgovernance und Entscheidungsautorität |
| `docs/05-logistics.md` | Eigentum, Cargo, Transfers, Verluste und strategisch-operative Logistikgrenze |
| `docs/15-template-library-and-spawning.md` | zulässige Templates und Materialisierungsgrundsätze |
| `docs/22-test-mission-build-transfer-and-validation-workflow.md` | Build-, Einbindungs- und Testworkflow |
| `docs/26-moose-first-development-policy.md` | verbindliche MOOSE-First-Regel |
| `docs/37-campaign-architecture-and-dynamic-mission-design.md` | CampaignState, Virtualisierung und Materialisierung |
| `docs/49-msr-routendesign-und-infrastrukturmarker.md` | Route, Segment, PATHLINE, Marker und Intelligence-Sichtbarkeit |
| `docs/56-insurgent-factions-shadow-governance-and-red-commander-behavior.md` | insurgente Fraktionen, Kontrolle, Rekrutierung und Shadow Governance |
| `docs/57...`, `docs/58...`, `docs/62...`, `docs/66...`, `docs/70...` | Taliban-, Haqqani-, HIG-, COIN- und Netzwerkgrundlagen gemäß Dokumentregister |
| `docs/67-afghanistan-route-clearance-counter-ied-and-convoy-design.md` | Routensicherung, Konvoi- und Clearance-Anforderungen |
| `docs/19-active-air-orbat-decisions.md` und Airfield-Manifeste | belegte ISAF-/Afghan-Air-Assets und Basierung |
| `docs/airfield-airwing-squadron-commander-implementation-workflow.md` | aktuelle MOOSE-AIRWING-/SQUADRON-/COMMANDER-Implementierung |

```text
SPECIAL_PROJECT_RESOURCE_MODEL
must not supersede
MAIN_PROJECT_LOGISTICS_TEMPLATE_OR_MOOSE_AUTHORITY
```

## 5. Gemeinsame Quellenmatrix

| Bereich | ISAF | Afghan State | Taliban | Haqqani | HIG |
|---|---|---|---|---|---|
| strategische Ziele | hoch | hoch | hoch | hoch | mittel bis hoch |
| Organisationsstruktur | hoch | mittel bis hoch | hoch | hoch | mittel |
| lokale Befehlsfriktion | mittel | hoch | hoch | hoch | hoch |
| Force Generation | mittel | hoch | mittel | mittel | niedrig bis mittel |
| Finance-Quellen | mittel | mittel bis hoch | mittel | mittel bis hoch | niedrig bis mittel |
| Materiel-Zugänge | hoch für belegte Assets | mittel | mittel | mittel | niedrig bis mittel |
| Manpower-Zugang | nicht afghanisch | hoch relevant | hoch relevant | selektiv relevant | regional relevant |
| Bevölkerungsverhältnis | hoch | hoch | hoch | mittel | mittel |
| Verhandlungen | mittel | hoch | mittel | mittel | hoch |
| regionale Abdeckung | hoch | mittel | mittel bis hoch | hoch im Kernraum | mittel |

Die Matrix bewertet Quellenreife, nicht militärische Stärke.

## 6. BLUE ISAF

### 6.1 Quellenbasis

Relevante Themen:

- US-/ISAF-Strategie;
- Verhinderung eines terroristischen Rückzugsraums;
- Population Protection;
- Unterstützung des Afghan State;
- Transition;
- nationale Kontingente, Caveats und Verluste;
- Air C2, ISR, CAS, MEDEVAC, CSAR und Logistik;
- Governance, Entwicklung und politische Legitimität.

### 6.2 Quellengetragene Commander-These

```text
PRIMARY_IDENTITY = COALITION_CAMPAIGN_AND_FORCE_EMPLOYMENT_COMMANDER
PRIMARY_GOAL != DESTROY_EVERY_TALIBAN_UNIT
```

Das Ziel umfasst sichere Bevölkerung und Kräfte, Störung strategisch relevanter Netzwerke, Erhalt der afghanischen Regierung und Übergabe nachhaltiger Sicherheitsverantwortung.

### 6.3 Ressourcen- und Kräftebasis

ISAF-Eigenkräfte stammen nicht aus afghanischem Manpower.

```text
NATIONAL_FORCE_POOL
+ COALITION_COMMITMENT
+ REPLACEMENT_CAPACITY
+ TIME
-> ISAF_FORCE_PACKAGE
```

Quellenbedarf:

- Kontingent- und Rotationslogik;
- nationale Verlust- und Mandatswirkungen;
- Ersatz- und Verstärkungszeiten;
- belegte Basierung, Inventare und Readiness;
- Umfang und Grenzen der Unterstützungsleistungen an Afghan State.

## 7. Afghan State und ANSF

### 7.1 Quellenbasis

Relevante Themen:

- Government of the Islamic Republic of Afghanistan;
- ANA, ANP, ANCOP, ABP und afghanische Intelligence-Strukturen;
- Wachstum, Ausbildung und Ausrüstung;
- internationale Finanzierung;
- Attrition, Abwesenheit, Führung, Korruption und Infiltration;
- Afghan-led Transition;
- Koalitionsabhängigkeit bei ISR, EOD, MEDEVAC, Luftunterstützung und Logistik;
- lokale Legitimität und unterschiedliche Wahrnehmung von ANA und ANP.

### 7.2 Commander-These

```text
DCS_COALITION = BLUE
CAMPAIGN_FACTION = AFGHAN_STATE
STRATEGIC_AUTONOMY = PARTIAL
COMMAND_AUTHORITY != ISAF_OWNERSHIP
```

### 7.3 Force Generation

```text
FINANCE
+ RECRUITABLE_MANPOWER
+ MATERIEL
+ TRAINING
+ RETENTION
+ LEADERSHIP
+ SUSTAINMENT
+ TIME
-> AFGHAN_FORCE_PACKAGE
```

### 7.4 Offene Quellenpunkte

- regionale Rekrutierungs- und Attritionsunterschiede;
- organisationsspezifische Readiness;
- belastbare Ausgangsbestände für Finance und Materiel;
- konkrete Ausbildungskapazitäten;
- lokale Vertrauensunterschiede ANA/ANP;
- belegte afghanische Luft- und Spezialfähigkeiten im Szenariozeitraum.

## 8. Taliban

### 8.1 Quellenstärke

```text
HISTORICAL_DEPTH: HIGH
ORGANIZATIONAL_DEPTH: HIGH
POLITICAL_GOVERNANCE_DEPTH: HIGH
TACTICAL_BEHAVIOR_DEPTH: HIGH
REGIONAL_COVERAGE: MEDIUM_TO_HIGH
RESOURCE_FLOW_DEPTH: MEDIUM
```

### 8.2 Direkt nutzbare Felder

- alternative Herrschaftsbewegung;
- Provinz-, Distrikt- und lokale Strukturen;
- Shadow Governance und Shadow Justice;
- lokale Autonomie bei strategischem Kohäsionsanspruch;
- Unterstützung, Duldung und erzwungene Compliance;
- Informanten, Beobachter und Pattern Learning;
- Rekrutierung, Besteuerung und Reinfiltration;
- Konkurrenz um Routen, Finance, Materiel und lokale Macht.

### 8.3 Commander-These

```text
PRIMARY_IDENTITY = ALTERNATIVE_GOVERNING_MOVEMENT
PRIMARY_METHOD = POLITICAL_CONTROL_SUPPORTED_BY_INSURGENT_FORCE
PRIMARY_STRENGTH = TERRITORIAL_AND_SOCIAL_PERSISTENCE
PRIMARY_WEAKNESS = LOCAL_NONCOMPLIANCE_AND_INTERNAL_FRICTION
```

### 8.4 Offene Quellenpunkte

- regionale Finance-Mixe;
- Anteil legaler, illegaler und externer Zuflüsse;
- regionale Manpower-Zugänge;
- konkrete Materiel- und Cache-Ausgangsdaten;
- Unterschiede zwischen strategischer Vorgabe und lokaler Ressourcenumleitung.

## 9. Haqqani

### 9.1 Quellenstärke

```text
HISTORICAL_DEPTH: HIGH
NETWORK_STRUCTURE_DEPTH: HIGH
EXTERNAL_SUPPORT_DEPTH: HIGH
COMPLEX_OPERATION_DEPTH: HIGH
POLITICAL_GOVERNANCE_DEPTH: MEDIUM
RESOURCE_FLOW_DEPTH: MEDIUM_TO_HIGH
```

### 9.2 Direkt nutzbare Felder

- familien- und beziehungsgebundene Führung;
- eigenständige C2- und Operationslinien;
- Sanctuary-, Facilitation-, Transit- und Staging-Kette;
- Finance-, Materiel-, Broker- und Spezialistenzugänge;
- Compartmentation und Redundanz;
- ausgewählte hochwertige Capability Packages;
- Konkurrenz um externe Unterstützung, Prestige und lokale Zugänge.

### 9.3 Commander-These

```text
PRIMARY_IDENTITY = FAMILY_NETWORK_AND_OPERATIONAL_BROKER
PRIMARY_METHOD = RESOURCE_AGGREGATION_AND_HIGH_COMPLEXITY_OPERATIONS
PRIMARY_STRENGTH = RESILIENCE_REACH_AND_COMPARTMENTATION
PRIMARY_WEAKNESS = DEPENDENCE_ON_KEY_RELATIONSHIPS_AND_FACILITATION_NODES
```

### 9.4 Offene Quellenpunkte

- quantitative Ausgangsanteile externer Zuflüsse;
- regionale Manpower-Nutzung;
- Abgrenzung lokaler Taliban- und Haqqani-ResourceSources;
- belastbare Startwerte für Broker-, Routen- und Spezialistenzugang.

## 10. HIG

### 10.1 Quellenstärke

```text
HISTORICAL_DEPTH: MEDIUM
ORGANIZATIONAL_DEPTH: MEDIUM
POLITICAL_NETWORK_DEPTH: HIGH
TACTICAL_BEHAVIOR_DEPTH: LOW_TO_MEDIUM
REGIONAL_COVERAGE: MEDIUM
RESOURCE_FLOW_DEPTH: LOW_TO_MEDIUM
```

### 10.2 Direkt nutzbare Felder

- politisch-militärische Doppelstruktur;
- regionale Kommandeure und kleine Gefolgschaften;
- Patronage und politische Kontakte;
- hohe Verhandlungs- und Deal-Fähigkeit;
- Defektionen und unklare Vertretungsbefugnis;
- Konkurrenz mit Taliban um Routen, Finance, Manpower und politische Repräsentation.

### 10.3 Commander-These

```text
PRIMARY_IDENTITY = POLITICAL_MILITARY_FACTION_NETWORK
PRIMARY_METHOD = LOCAL_POWER_BROKERAGE_AND_OPPORTUNISTIC_COERCION
PRIMARY_STRENGTH = POLITICAL_ACCESS_DEALMAKING_AND_LOCAL_NETWORKS
PRIMARY_WEAKNESS = FRAGMENTED_COMMAND_AND_UNCERTAIN_REPRESENTATION
```

### 10.4 Offene Quellenpunkte

- regionale Finance- und Materielquellen;
- belastbare lokale Commander- und Patronagekarten;
- Trennung von legal-politischem und bewaffnetem Zugang;
- Stärke, Bindung und Regenerationsfähigkeit lokaler Force Packages.

## 11. Quellenbasis des Ressourcenmodells

Version 1 modelliert ausschließlich:

```text
RECRUITABLE_MANPOWER
FINANCE
MATERIEL
```

Eine Quelle wird nur aktiviert, wenn sie:

- historisch oder analytisch begründbar;
- geografisch zuordenbar;
- von mindestens zwei Fraktionen beeinflussbar;
- endlich oder zuflussbegrenzt;
- für Force Generation oder Erhaltung relevant ist.

### 11.1 Recruitable Manpower

Quellhalter:

```text
AFGHAN_POPULATION_AND_LOCAL_COMMUNITIES
```

Zu prüfen:

- regionale Bevölkerung und Altersstruktur nur in geeigneten Bändern;
- freiwillige staatliche und insurgente Rekrutierung;
- Geld-, Patronage-, Ideologie- und Zwangseinflüsse;
- Abwanderung, Verluste und Erschöpfung;
- keine ethnische oder regionale automatische Loyalitätsannahme.

### 11.2 Finance

Mögliche Quellenklassen:

```text
AFGHAN_STATE_REVENUE
FORMAL_TAX_AND_CUSTOMS
INTERNATIONAL_DONOR_AND_SECURITY_ASSISTANCE
LOCAL_LEGAL_ECONOMY
SHADOW_TAXATION
ILLICIT_ECONOMY
EXTERNAL_INSURGENT_SUPPORT
PATRONAGE_CHANNELS
```

```text
ALL_RED_FINANCE != DRUG_MONEY
```

Drogen- oder Schmuggelzugänge werden nur regional und quellenbegründet aktiviert.

### 11.3 Materiel

Mögliche Quellen:

```text
ISAF_AND_AFGHAN_STATE_WAREHOUSES
SECURITY_ASSISTANCE_DELIVERIES
RED_CACHES
EXTERNAL_SUPPORT_CHANNELS
CAPTURED_OR_DIVERTED_STOCKS
CONVOYS_AND_CARGO
```

`MATERIEL` ist im Spezialprojekt ein strategisches Aggregat. Die operative und detaillierte Logistik bleibt unter `docs/05-logistics.md` und MOOSE/DCS-Autorität.

## 12. Beziehungs- und Konkurrenzquellen

Mindestens zu erfassen:

```text
ISAF <-> AFGHAN_STATE partnership and friction
AFGHAN_STATE <-> TALIBAN governance and resource competition
AFGHAN_STATE <-> HAQQANI network and route competition
AFGHAN_STATE <-> HIG political and local-commander competition
TALIBAN <-> HAQQANI alignment and autonomy
TALIBAN <-> HIG rivalry and local cooperation
HAQQANI <-> HIG pragmatic uncertainty
```

Ein Ereignis in einer Region wird nicht automatisch als landesweite Beziehung interpretiert.

## 13. Readiness nach Dokumentbereich

```text
TALIBAN_DOSSIER_READINESS = HIGH
HAQQANI_DOSSIER_READINESS = HIGH
HIG_DOSSIER_READINESS = MEDIUM
BLUE_ISAF_DOSSIER_READINESS = HIGH
AFGHAN_STATE_DOSSIER_READINESS = MEDIUM_TO_HIGH
INTER_FACTION_MODEL_READINESS = MEDIUM
RESOURCE_MODEL_STRUCTURE_READINESS = HIGH
RESOURCE_START_VALUE_READINESS = LOW
RUNTIME_RULEBOOK_READINESS = MEDIUM
DCS_MOOSE_INTEGRATION_READINESS = LOW
```

## 14. Verbotene Ableitungen

```text
SOURCE_MENTIONS_UNIT != RUNTIME_TEMPLATE_EXISTS
SOURCE_MENTIONS_REVENUE != EXACT_FINANCE_VALUE
SOURCE_MENTIONS_SUPPORT != VOLUNTARY_POPULATION_SUPPORT
SOURCE_MENTIONS_CONTROL != COMPLETE_RESOURCE_CAPTURE
SOURCE_MENTIONS_FORCE_SIZE != DCS_GROUP_COUNT
NEW_DOCUMENT != RUNTIME_ACCEPTANCE
```

## 15. Nächste Quellenarbeit

Priorität 1:

- konkrete ResourceSource-Ausgangsdaten nach Region;
- belastbare Startanteile und Kapazitätsbänder;
- ANSF-Force-Generation-, Attritions- und Trainingsevidenz;
- ISAF Coalition-Commitment- und Ersatzmodell;
- HIG-ResourceSources und regionale Commander;
- Taliban-/Haqqani-Abgrenzung bei externen und lokalen Zuflüssen.

Priorität 2:

- Template-Kosten und Aufbauzeiten erst nach Template-Autorität;
- regionale Bevölkerungs- und Wirtschaftsbandbreiten;
- Transfer- und Verlustwahrscheinlichkeiten;
- MOOSE-2.9.18-Prüfung für Warehouses, Cargo, Spawn, AIRWING, COMMANDER, CHIEF und Operationsprofile.

## 16. Acceptance-Kriterien

Das Inventar ist ausreichend, wenn:

- alle fünf Fraktionen eine nachvollziehbare Quellenbasis besitzen;
- Quellen und Simulationsentscheidungen getrennt markiert sind;
- ResourceSources geografisch und fraktionsbezogen begründbar sind;
- fehlende quantitative Ausgangsdaten offen als `UNKNOWN` bleiben;
- keine DCS-Objekte, Templates oder Inventare erfunden werden;
- Hauptprojekt-Autoritäten verlinkt und nicht überschrieben werden;
- neue Quellen systematisch in Dossiers, Dokument 17 und Testfixtures zurückgeführt werden.

## 17. Querverweise

```text
02-common-commander-model.md
03-inter-faction-relations-and-negotiation.md
04-taliban-commander-dossier.md
05-haqqani-commander-dossier.md
06-hig-commander-dossier.md
10-blue-commander-dossier.md
13-campaign-state-and-event-store-schema.md
16-afghan-state-and-ansf-commander-dossier.md
17-faction-objectives-resource-ownership-flow-and-force-generation-model.md
18-resource-model-integration-and-dossier-amendments.md
```
