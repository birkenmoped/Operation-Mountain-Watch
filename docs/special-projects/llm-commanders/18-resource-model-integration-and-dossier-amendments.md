---
document_id: OMW-SP-LLM-COMMANDERS-RESOURCE-INTEGRATION-AMENDMENTS
status: MIGRATION_RECORD_COMPLETE
document_class: CROSS_DOCUMENT_MIGRATION_AND_CONSOLIDATION_RECORD
scenario_period: 2010-08-01/2011-12-31
source_branch: docs/optional-llm-commanders
validated_in_dcs: false
authoritative_for:
  - record of transition from four to five campaign commanders
  - record of migration to contested resource model
  - document-authority and compatibility history
  - remaining implementation gaps after documentation consolidation
---

# Integration des Afghan State Commanders und Migration des Ressourcenmodells

## 1. Zweck

Dieses Dokument ist die abgeschlossene Migrations- und Konsolidierungsakte für:

- Einführung des `AFGHAN_STATE_COMMANDER`;
- Übergang von vier auf fünf Kampagnen-Commander;
- Einführung der gemeinsamen Ressourcen `RECRUITABLE_MANPOWER`, `FINANCE` und `MATERIEL`;
- Trennung von Ressourcen, Capabilities, Zugängen und politischen Zuständen;
- direkte Aktualisierung der bereits vorhandenen Dokumente 01 bis 17.

Es ist nicht mehr erforderlich, Dokument 18 als dauerhafte Interpretationsschicht zwischen widersprüchlichen Ursprungsdokumenten zu verwenden. Die Ursprungsdokumente wurden direkt migriert.

```text
DIRECT_DOCUMENT_MIGRATION = COMPLETE
RUNTIME_IMPLEMENTATION = NOT_STARTED
DCS_VALIDATION = NOT_COMPLETED
```

## 2. Autoritätsreihenfolge nach Migration

```text
DOCUMENT_13
= persistent CampaignState and Event Store schema
```

```text
DOCUMENT_16
= Afghan State and ANSF commander authority
```

```text
DOCUMENT_17
= contested resource ownership flow and force-generation authority
```

```text
DOCUMENT_02
= common commander domain model
```

```text
DOCUMENT_07
= runtime action and validation contract
```

```text
DOCUMENT_09
= orchestrator service and transaction architecture
```

Dokument 18 dokumentiert, wie diese Autoritäten entstanden und in ältere Dokumente integriert wurden.

## 3. Verbindlicher konsolidierter Stand

```text
CAMPAIGN_COMMANDER_COUNT = 5
```

```text
COMMANDERS =
  BLUE_ISAF_COMMANDER
  AFGHAN_STATE_COMMANDER
  TALIBAN_COMMANDER
  HAQQANI_COMMANDER
  HIG_COMMANDER
```

```text
COMMON_CONTESTED_RESOURCES =
  RECRUITABLE_MANPOWER
  FINANCE
  MATERIEL
```

```text
PHYSICAL_STRATEGIC_OUTPUT = FORCE_PACKAGE
TACTICAL_RUNTIME_FOUNDATION = MOOSE_2_9_18
```

```text
DCS_COALITION != CAMPAIGN_FACTION
RESOURCE != CAPABILITY
RESOURCE != POLITICAL_STATE
FORCE_PACKAGE != DCS_GROUP
```

## 4. Phase 1 – zentrale Verträge

### 4.1 Dokument 13 – CampaignState

Direkt migriert:

- fünf kanonische Fraktionen;
- DCS-Koalition getrennt von Kampagnenfraktion;
- `ResourceSource`;
- `ResourceAccount`;
- `ResourceReservation`;
- `ResourceTransfer`;
- `ResourceFlow`;
- `AccessNode`;
- `FactionShare`;
- `ForceGenerationOrder`;
- `ForcePackage` und `ForceUnit`;
- Resource- und Force-Generation-Events;
- Ownership-, Idempotenz- und Recovery-Invarianten;
- DCS-Löschung getrennt von Detention, Disarmament und Demobilization.

### 4.2 Dokument 02 – Common Commander Model

Direkt migriert:

- fünf Commander;
- gemeinsame Commander-Felder;
- Trennung `ResourceAccount / Capability / Access / PoliticalState`;
- Force-Generation-Anträge;
- ISAF-/Afghan-State-Partnerautonomie;
- resource-bezogene Beliefs und Decisions.

### 4.3 Dokument 07 – Runtime Rulebook

Direkt migriert:

- Frontmatter korrigiert;
- fünf fraktionsspezifische Validatoren;
- ResourceSource-, Transfer- und Force-Generation-Actions;
- abstrakte militärische Wirkungsaktionen statt prozeduraler Taktikanweisungen;
- Afghan-State-Partnerfreigabe;
- MOOSE-First- und No-Generated-Code-Grenze.

### 4.4 Dokument 09 – Orchestrator

Direkt migriert:

- `ResourceSourceManager`;
- `AccessShareCalculator`;
- `ResourceAccountService`;
- `ResourceTransferService`;
- `ForceGenerationManager`;
- `ForcePackageRegistry`;
- neue Transaktions- und Recovery-Pipelines;
- idempotente DCS-/MOOSE-Kopplung.

## 5. Phase 2 – Fraktionen und Partnerschaft

### 5.1 Dokument 03 – Relationships

Direkt migriert:

- ISAF ↔ Afghan State;
- Afghan State ↔ Taliban;
- Afghan State ↔ Haqqani;
- Afghan State ↔ HIG;
- Finance-/Materiel-Transfer getrennt von Capability Support;
- Partneroperationen und Souveränitätsfriktion;
- RED-Konkurrenz um ResourceSources und Shares.

### 5.2 Dokument 10 – BLUE ISAF Dossier

Direkt migriert:

- Zielkorrektur: nicht Vernichtung aller Taliban;
- strategischer Safe-Haven-, Schutz-, Partner- und Transition-Auftrag;
- ISAF-eigener Force Pool und `COALITION_COMMITMENT`;
- lokale ISAF-Reputation als HUMINT-/Zugangsmodifikator, nicht als Unit Currency;
- Afghan-State-Eigentum und Zustimmung.

### 5.3 Dokument 11 – MissionDemand

Direkt migriert:

- Afghan Partner Review;
- separate Eigentums- und Ressourcenreservierungen;
- ResourceSource-, Revenue-, Recruitment- und Force-Generation-Support-Demands;
- Targeting-, NSL-, ROE-, PID- und CAS-Gates;
- Capture nur als möglicher Kampagneneffekt.

### 5.4 Dokumente 04, 05 und 06 – RED-Dossiers

Direkt migriert:

```text
RESOURCE_ACCOUNTS:
  RECRUITABLE_MANPOWER
  FINANCE
  MATERIEL
```

Getrennt davon:

```text
ACCESS
CAPABILITY
ORGANIZATIONAL_GATES
POLITICAL_AND_SOCIAL_STATE
```

Taliban:

- freiwillige Unterstützung und Repression getrennt;
- Cadre- und Command-Link-Gates;
- politische Kontrolle, Ressourcenzugang und Reinfiltration.

Haqqani:

- externe Unterstützung endlich und umkämpft;
- Broker-, Spezialisten-, Route-, Staging- und Compartmentation-Gates;
- Capability Package getrennt vom ResourceAccount.

HIG:

- Patronage, politisches Kapital und Vertretungsbefugnis getrennt von Finance;
- Local-Commander-Gate;
- regionale ResourceSource- und Repräsentationskonkurrenz.

### 5.5 Dokument 08 – Information

Direkt migriert:

- fünftes Afghan-State-Informationsprofil;
- ISAF-/Afghan-State-Informationsteilung nicht automatisch vollständig;
- resource-bezogene Beliefs;
- Resource Memory;
- Share-, Source- und Account-Provenienz.

## 6. Phase 3 – Tests und Technologie

### 6.1 Dokument 12 – Testszenarien

Direkt migriert:

- fünf Commander auf allen Levels;
- ResourceSource-, Share-, Transfer- und Force-Generation-Tests;
- Afghan-State-Eigentum und Partnerautonomie;
- DCS-Missing-Entity- und MOOSE-Idempotenztests;
- 30-Tage-Resource-Economy-Langzeittest.

### 6.2 Dokument 14 – Deterministic Harness

Direkt migriert:

```text
BLUE_ISAF_BASELINE_V2
AFGHAN_STATE_BASELINE_V1
TALIBAN_BASELINE_V2
HAQQANI_BASELINE_V2
HIG_BASELINE_V2
```

Zusätzlich:

- ResourceSource Tick;
- Share Calculation;
- ResourceAccount Service;
- Force-Generation-Queue;
- Transfer- und Recovery-Fixtures;
- Golden Master, Differential und Shadow Mode.

### 6.3 Dokument 15 – Technology Selection

Direkt migriert:

- PoC mit fünf Commandern;
- Resource-Economy-Pflichtobjekte;
- Partnerautonomie;
- Resource Conservation;
- Force-Generation-Recovery;
- Share Determinism;
- MOOSE-Adapter-Idempotenz;
- Python-/Elixir-/Hybridvergleich bleibt offen.

## 7. Phase 4 – Quellen und Autoritäten

### 7.1 Dokument 01 – Source Inventory

Direkt migriert:

- Quellenbasis für alle fünf Fraktionen;
- ISAF-/Transition-/Coalition-Commitment-Quellen;
- Afghan-State-/ANSF-/Force-Generation-Quellen;
- ResourceSource- und Quellenreife-Matrix;
- offene quantitative Ausgangsdaten.

### 7.2 Dokument 16 – Afghan State

Direkt konsolidiert:

```text
CANONICAL_COMMANDER_NAME = AFGHAN_STATE_COMMANDER
```

`ANSF_COMMANDER` ist nur funktionale Kurzbezeichnung, kein zweiter strategischer Commander.

### 7.3 Dokument 17 – Resource Model

Direkt konsolidiert:

- `MATERIEL` als strategisches Aggregat;
- `docs/05-logistics.md` bleibt operative Logistikautorität;
- `ForcePackage` und `ForceUnit` getrennt;
- ISAF-Mittel werden erst durch autorisierten Transfer Teil des Afghan-State-Flusses;
- schriftlicher Ressourcenzyklus und Mermaid-Kreislauf aktualisiert;
- direkte MOOSE-First- und Template-Autoritätsverweise.

## 8. Nicht mehr gültige Lesarten

Folgende ältere Interpretationen sind verworfen:

```text
FOUR_COMMANDERS_ONLY
BLUE_OWNS_ALL_BLUE_COALITION_UNITS
ANSF_IS_A_BLUE_RESOURCE
ALL_IMPORTANT_VALUES_ARE_RESOURCES
SUPPORT_OR_REPRESSION_DIRECTLY_GENERATES_UNITS
EXTERNAL_SUPPORT_IS_UNLIMITED
DCS_GROUP_DELETED_MEANS_CAPTURED_OR_DISARMED
RESOURCE_TRANSFER_CREATES_NEW_STOCK
```

## 9. Weiterhin offene fachliche Daten

Die Dokumentationsmigration ersetzt keine noch fehlenden Ausgangsdaten.

Offen bleiben:

- konkrete ResourceSource-Kapazitäten je Region;
- Startanteile und Regenerationsraten;
- Force-Package-Kosten;
- Aufbau-, Trainings- und Rekonstitutionszeiten;
- Template-Zuordnungen;
- konkreter nationaler ISAF Force Pool und Ersatzlogik;
- fraktions- und regionsspezifische Finance-Mixe;
- quantitative Afghan-State-Training-, Attrition- und Retention-Werte;
- MOOSE-2.9.18-Materialisierungs- und Warehouse-Prüfung.

Diese Werte dürfen nicht erfunden werden.

## 10. Weiterhin offene technische Arbeit

```text
19-language-neutral-contracts-and-json-schemas.md
```

Danach:

- konkrete JSON Schemas;
- Event Upcaster und Migrationen;
- deterministischer Reference Harness;
- ResourceSource- und Force-Generation-Fixtures;
- MOOSE-2.9.18-Adapterprüfung;
- isolierte DCS-Testmission;
- erst anschließend LLM Shadow Mode.

## 11. MOOSE-First-Grenze

```text
ORCHESTRATOR
= strategic state resource validation and authorization
```

```text
MOOSE
= tactical mission task group and materialization runtime
```

```text
LLM_OR_SCRIPTED_COMMANDER
= structured intent only
```

Vor eigenem Lua-Code ist die eingebundene MOOSE-Version 2.9.18 einschließlich Quellen und Dokumentation zu prüfen.

## 12. Konsolidierungsstatus

```text
DIRECT_UPDATE_01_TO_17 = COMPLETE
DOCUMENT_18_ROLE = MIGRATION_AND_HISTORY_RECORD
BASIC_INTERPRETATION_REQUIRES_DOCUMENT_18 = NO
RUNTIME_ACCEPTED = NO
DCS_VALIDATED = NO
MERGE_READY = NO
```

## 13. Querverweise

```text
README.md
01-source-inventory-and-faction-baseline.md
02-common-commander-model.md
03-inter-faction-relations-and-negotiation.md
04-taliban-commander-dossier.md
05-haqqani-commander-dossier.md
06-hig-commander-dossier.md
07-runtime-rulebook-and-action-schema.md
08-commander-memory-belief-and-information-model.md
09-orchestrator-architecture-and-adjudication.md
10-blue-commander-dossier.md
11-blue-mission-demand-force-allocation-and-targeting-schema.md
12-multi-commander-test-scenarios.md
13-campaign-state-and-event-store-schema.md
14-deterministic-test-harness-and-scripted-commanders.md
15-orchestrator-technology-selection-and-deployment-model.md
16-afghan-state-and-ansf-commander-dossier.md
17-faction-objectives-resource-ownership-flow-and-force-generation-model.md
```
