---
document_id: OMW-SP-LLM-COMMANDERS-INDEX
status: DRAFT_OPTIONAL_PROJECT
document_class: SPECIAL_PROJECT_CHARTER_AND_INDEX
scenario_period: 2010-08-01/2011-12-31
source_branch: docs/optional-llm-commanders
validated_in_dcs: false
---

# Optionales Spezialprojekt: Multi-Commander Campaign

## 1. Zweck

Dieses Spezialprojekt untersucht eine eigenständige DCS-Kampagnenform mit fünf getrennten strategischen Commander- und Fraktionsmodellen:

```text
BLUE_ISAF_COMMANDER
AFGHAN_STATE_COMMANDER
TALIBAN_COMMANDER
HAQQANI_COMMANDER
HIG_COMMANDER
```

Technische DCS-Koalitionen und strategische Kampagnenfraktionen sind nicht identisch.

```text
BLUE_ISAF_COMMANDER.dcs_coalition = BLUE
AFGHAN_STATE_COMMANDER.dcs_coalition = BLUE

BLUE_ISAF_COMMANDER.faction_id = ISAF
AFGHAN_STATE_COMMANDER.faction_id = AFGHAN_STATE
```

ISAF und Afghan State sind verbündete, aber getrennte Kampagnenfraktionen mit eigenem Eigentum, eigenen Ressourcen, eigenen Views und teilweise unterschiedlichen Zielen.

Die vorhandene Dokumentation von Operation Mountain Watch dient als historische, geografische, operative und technische Quellenbasis. Entscheidungen des optionalen Spezialprojekts ändern nicht automatisch die Hauptprojektarchitektur.

## 2. Projektstatus

```text
OPTIONAL_SPECIAL_PROJECT
DIRECT_DOCUMENT_MIGRATION_COMPLETE
LANGUAGE_NEUTRAL_CONTRACT_BASELINE_DEFINED
NOT_MAIN_PROJECT_AUTHORITY
NOT_RUNTIME_ACCEPTED
NOT_DCS_VALIDATED
NOT_MERGE_READY
```

Es wurde noch keine Produktionsruntime, keine akzeptierte DCS-Testmission und keine LLM-Anbindung freigegeben. Die tatsächlichen `.schema.json`-Dateien, Fixtures und Contract Tests sind noch nicht implementiert.

## 3. MOOSE-First

```text
MOOSE = TACTICAL_RUNTIME_FOUNDATION
ORCHESTRATOR = STRATEGIC_STATE_VALIDATION_AND_ADJUDICATION
COMMANDER_POLICY_OR_LLM = STRUCTURED_INTENT_ONLY
DCS = PHYSICAL_SIMULATION
```

Vor eigenem Lua-Code ist die eingebundene MOOSE-Version 2.9.18 einschließlich Quellen und Dokumentation zu prüfen.

Nicht zulässig:

```text
LLM -> generated Lua -> direct DCS execution
ORCHESTRATOR -> reimplementation of MOOSE tactical functionality
```

## 4. Gemeinsames Ressourcenmodell

Version 1 verwendet genau drei gemeinsame umkämpfte Grundressourcen:

```text
RECRUITABLE_MANPOWER
FINANCE
MATERIEL
```

Physischer strategischer Output:

```text
FORCE_PACKAGE
```

```text
RECRUITABLE_MANPOWER
+ FINANCE
+ MATERIEL
+ TIME
+ FACTION_SPECIFIC_ORGANIZATIONAL_GATE
-> FORCE_PACKAGE
```

Wichtige Trennungen:

```text
RESOURCE != CAPABILITY
RESOURCE != POLITICAL_STATE
ACCESS != RESOURCE_STOCK
DCS_COALITION != CAMPAIGN_FACTION
FORCE_PACKAGE != DCS_GROUP
```

## 5. Dokumentautoritäten

```text
13 = CampaignState Event Store and persistent aggregates
16 = Afghan State and ANSF commander dossier
17 = contested resource ownership flow and force generation
02 = common commander domain model
07 = runtime action and validation contract
09 = orchestrator architecture
19 = language-neutral contracts JSON Schema versioning and hashing baseline
18 = completed migration and consolidation record
```

Dokument 18 ist nach der direkten Migration nicht mehr zur grundlegenden Interpretation älterer Widersprüche erforderlich.

```text
BASIC_INTERPRETATION_REQUIRES_DOCUMENT_18 = NO
```

## 6. Dokumentationsbestand

1. [Quelleninventar und Fraktionsbaseline](01-source-inventory-and-faction-baseline.md)
2. [Gemeinsames Commander-Modell](02-common-commander-model.md)
3. [Fraktionsbeziehungen, Partnerschaft und Verhandlungen](03-inter-faction-relations-and-negotiation.md)
4. [Taliban Commander Dossier](04-taliban-commander-dossier.md)
5. [Haqqani Commander Dossier](05-haqqani-commander-dossier.md)
6. [HIG Commander Dossier](06-hig-commander-dossier.md)
7. [Runtime-Rulebook und Action Schema](07-runtime-rulebook-and-action-schema.md)
8. [Memory-, Belief- und Informationsmodell](08-commander-memory-belief-and-information-model.md)
9. [Orchestrator Architecture and Adjudication](09-orchestrator-architecture-and-adjudication.md)
10. [BLUE ISAF Commander Dossier](10-blue-commander-dossier.md)
11. [BLUE MissionDemand, Partner Coordination und Targeting](11-blue-mission-demand-force-allocation-and-targeting-schema.md)
12. [Reproduzierbare Multi-Commander-Tests](12-multi-commander-test-scenarios.md)
13. [CampaignState und Event Store](13-campaign-state-and-event-store-schema.md)
14. [Deterministischer Test Harness und Scripted Commander](14-deterministic-test-harness-and-scripted-commanders.md)
15. [Orchestrator-Technologieauswahl und Deployment](15-orchestrator-technology-selection-and-deployment-model.md)
16. [Afghan State und ANSF Commander Dossier](16-afghan-state-and-ansf-commander-dossier.md)
17. [Ressourceneigentum, Ressourcenfluss und Kräftegenerierung](17-faction-objectives-resource-ownership-flow-and-force-generation-model.md)
18. [Migrations- und Konsolidierungsakte](18-resource-model-integration-and-dossier-amendments.md)
19. [Sprachneutrale Runtime-Verträge und JSON-Schema-Baseline](19-language-neutral-contracts-and-json-schemas.md)

Nächster Implementierungsblock:

```text
docs/special-projects/llm-commanders/schemas/
```

Dort folgen die tatsächlichen `.schema.json`-Dateien, Registry, positive und negative Fixtures sowie sprachübergreifende Golden Tests.

## 7. Commander-Kurzprofile

### 7.1 BLUE ISAF

Schwerpunkte:

- terroristischen Rückzugsraum verhindern;
- Bevölkerung und Kräfte schützen;
- RED-Netzwerke und Ressourcenflüsse stören;
- Afghan State unterstützen;
- Coalition Commitment erhalten;
- nachhaltige Transition vorbereiten.

```text
BLUE_PRIMARY_GOAL != DESTROY_EVERY_TALIBAN_UNIT
```

### 7.2 Afghan State

Schwerpunkte:

- Staat und Sicherheitskräfte erhalten;
- Bevölkerung, Regierungsknoten und Routen schützen;
- Finance-, Manpower- und Materielzugang sichern;
- Force Generation und Retention;
- afghanische Sicherheitsverantwortung erweitern;
- Abhängigkeit nachhaltig reduzieren.

### 7.3 Taliban

Schwerpunkte:

- Bewegung und Führung erhalten;
- politische und gesellschaftliche Kontrolle;
- Recruitment-, Finance- und Materielzugang;
- Regierung delegitimieren;
- ISAF-Kosten erhöhen und Abzug beschleunigen;
- Reinfiltration und langfristige Herrschaftsfähigkeit.

### 7.4 Haqqani

Schwerpunkte:

- Familien- und Broker-Netzwerk erhalten;
- externe Support-, Route-, Staging- und Spezialistenzugänge;
- Compartmentation;
- ausgewählte hochwertige Capability Packages;
- Prestige und Einfluss.

### 7.5 HIG

Schwerpunkte:

- eigenständige politische und organisatorische Relevanz;
- lokale Commander und Patronage;
- regionale Finance-, Manpower- und Materielzugänge;
- Verhandlungen und politische Hebelwirkung;
- Fragmentierung und Unterordnung vermeiden.

## 8. Ressourcen- und Eigentumsgrundsätze

```text
LEGAL_OWNER != PHYSICAL_CONTROLLER != BENEFICIARY
POPULATION != OWNED_RESOURCE
TRANSFER != GENERATION
SUPPORT_TRANSFER != COMMAND_TRANSFER
SAME_DCS_COALITION != SAME_OWNERSHIP
```

ISAF-Mittel werden erst durch autorisierten Transfer Teil eines Afghan-State-ResourceAccounts. Afghanische Force Packages bleiben Eigentum von `AFGHAN_STATE`.

## 9. Informationsgrundsätze

```text
WORLD_TRUTH
-> OBSERVATION
-> INFORMATION_ITEM
-> COMMANDER_BELIEF
-> DECISION
```

Kein Commander erhält Omniszienz. ISAF und Afghan State teilen Informationen nicht automatisch vollständig. ResourceSources, Account-Stände und Shares bleiben subjektiv, solange sie nicht beobachtet oder berichtet wurden.

## 10. Vertragsgrundsätze

```text
JSON_SCHEMA_BASELINE = DRAFT_2020_12
SCHEMA_RESOLUTION = EXACT
UNKNOWN_FIELDS = REJECT
RESOURCE_QUANTITY = NONNEGATIVE_INTEGER_CAMPAIGN_UNITS
TIMESTAMPS = UTC_MILLISECONDS_Z
ADAPTER_INPUT = VALIDATED_DOMAIN_OBJECTS_ONLY
```

Alle interprozessualen Verträge benötigen stabile IDs, Schema-Referenz, Idempotency Key, Correlation ID, Causation ID, Producer-Metadaten und kanonischen Payload-Hash.

## 11. Test- und Implementierungsreihenfolge

```text
1 actual JSON schemas registry and fixtures
2 cross-language canonical-hash and validation tests
3 in-memory Event Store and reducers
4 ResourceSource and Share Calculation
5 ResourceAccount and Transfer Service
6 ForceGenerationManager and ForcePackageRegistry
7 five Scripted Commander policies
8 deterministic virtual campaign
9 DCS/MOOSE adapter stub
10 MOOSE 2.9.18 source and API verification
11 isolated DCS/MOOSE test mission
12 LLM shadow mode
13 controlled multi-LLM experiments
```

## 12. Noch offene Daten

Nicht festgelegt und nicht zu erfinden:

- konkrete ResourceSource-Kapazitäten;
- regionale Startanteile und Regenerationsraten;
- Force-Package-Kosten und Aufbauzeiten;
- konkrete Template-Zuordnungen;
- konkrete DCS-/Mission-Editor-Objekte;
- quantifizierter ISAF National Force Pool;
- quantitative Afghan-State-Training-, Attrition- und Retention-Werte;
- konkrete MOOSE-Capability-Mappings;
- endgültige maximale Vertragsgrößen;
- endgültige Python-/Elixir-/Hybridentscheidung.

## 13. Hauptprojektgrenze

Hauptprojekt-Autoritäten bleiben insbesondere:

```text
docs/00-project-governance.md
docs/05-logistics.md
docs/15-template-library-and-spawning.md
docs/22-test-mission-build-transfer-and-validation-workflow.md
docs/26-moose-first-development-policy.md
docs/37-campaign-architecture-and-dynamic-mission-design.md
```

Das Spezialprojekt darf diese Dokumente nicht stillschweigend überschreiben.

## 14. Konsolidierungsstatus

```text
DOCUMENTS_01_TO_17_DIRECTLY_UPDATED = YES
DOCUMENT_18_CONVERTED_TO_MIGRATION_RECORD = YES
DOCUMENT_19_CONTRACT_BASELINE_DEFINED = YES
README_INDEX_CURRENT = YES
ACTUAL_JSON_SCHEMA_ARTIFACTS_CREATED = NO
RUNTIME_IMPLEMENTED = NO
MOOSE_ADAPTER_VALIDATED = NO
DCS_TEST_ACCEPTED = NO
PR_CREATED = NO
MERGED_TO_MAIN = NO
```
