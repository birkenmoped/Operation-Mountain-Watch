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

ISAF und Afghan State sind verbündete, aber getrennte Kampagnenfraktionen mit eigenem Eigentum, eigenen Ressourcen, eigenem Lagebild und teilweise unterschiedlichen Zielen.

Die vorhandene Dokumentation von Operation Mountain Watch dient als historische, geographische, taktische und technische Quellenbasis. Bestehende Hauptprojektentscheidungen zugunsten eines konsolidierten RED Commanders begrenzen dieses optionale Spezialprojekt ausdrücklich nicht.

## 2. Projektstatus und Abgrenzung

```text
OPTIONAL_SPECIAL_PROJECT
NOT_MAIN_PROJECT_AUTHORITY
NOT_RUNTIME_ACCEPTED
NOT_DCS_VALIDATED
NOT_MERGE_READY
```

Der Projektzweig darf eigene Entscheidungen treffen zu:

- getrennten Fraktionen und Commander-Instanzen;
- getrenntem Force-Package- und Ressourceneigentum;
- Fraktionsbeziehungen, Kooperation und Konkurrenz;
- unvollständigen und widersprüchlichen Lagebildern;
- Verhandlungen, Unterstützungsanfragen und Ressourcentransfers;
- eigenständigen strategischen Zielen und Erfolgskriterien;
- einem BLUE/ISAF-Commander;
- einem Afghan-State-/ANSF-Commander;
- drei getrennten RED-Commandern;
- einem externen persistenten Campaign-Orchestrator.

Er verändert ohne gesonderte Entscheidung weder die Hauptprojektarchitektur noch verbindliche Dokumente auf `main`.

## 3. Historische Modellierungsregel

Jede Aussage wird einer der folgenden Klassen zugeordnet:

```text
SOURCE_DOCUMENTED
SOURCE_REPORTED_UNCORROBORATED
ANALYTICAL_INFERENCE
SIMULATION_ABSTRACTION
DESIGN_DECISION
UNKNOWN
```

Insbesondere gilt:

```text
historical_relationship != permanent_runtime_alliance
formal_subordination != complete_operational_control
shared_enemy != shared_resources
local_cooperation != strategic_unity
reported_strength != DCS_spawn_count
same_dcs_coalition != same_campaign_faction
allied_relationship != shared_ownership
```

## 4. MOOSE-First-Grundsatz

MOOSE bleibt der taktische Runtime-Unterbau innerhalb von DCS.

```text
MOOSE remains the tactical runtime foundation.
The external orchestrator does not replace MOOSE.
```

Verantwortungstrennung:

```text
COMMANDER
-> proposes strategic intent

ORCHESTRATOR
-> validates authority resources beliefs and campaign effects

DCS_MOOSE_ADAPTER
-> translates approved domain objects

MOOSE
-> creates and manages tactical missions and force packages

DCS
-> simulates the physical world
```

Nicht zulässig:

```text
LLM_TO_LUA
LLM_TO_DCS_COMMAND
ORCHESTRATOR_BYPASS_OF_MOOSE
UNVALIDATED_FORCE_SPAWN
```

Vor eigenem Lua-Code ist für jede Funktion die tatsächlich eingebundene MOOSE-Version 2.9.18 zu prüfen.

## 5. Commander- und Fraktionsrollen

### 5.1 BLUE / ISAF Commander

Schwerpunkte:

- strategischen terroristischen Rückzugsraum verhindern;
- RED-Operationsfähigkeit reduzieren;
- priorisierte Bevölkerung und eigene Kräfte schützen;
- kritische Basen, Routen und Logistik sichern;
- afghanische Sicherheitsfähigkeit aufbauen;
- RED-Zugriff auf umkämpfte Ressourcen begrenzen;
- nachhaltige Transition ermöglichen;
- Koalitionszusammenhalt und politische Einsatzbereitschaft erhalten.

BLUE will nicht alle afghanischen Ressourcen selbst besitzen. Erfolg bedeutet, dem Afghan State nachhaltigen Zugriff zu ermöglichen und RED-Zugriff unter die für dessen strategische Ziele notwendige Schwelle zu drücken.

### 5.2 Afghan State / ANSF Commander

Schwerpunkte:

- Überleben und Handlungsfähigkeit des afghanischen Staates;
- Erhalt und Entwicklung der ANSF;
- Schutz wichtiger Bevölkerungs- und Regierungszentren;
- staatliche Kontrolle über Routen, Distrikte und Einrichtungen;
- Sicherung von Rekrutierung, Finanzierung und Materiel;
- Verringerung insurgenter Parallelkontrolle;
- Ausbau afghanisch geführter Operationsfähigkeit;
- nachhaltige Übernahme der Sicherheitsverantwortung.

Afghanische Kräfte gehören im CampaignState nicht dem BLUE Commander.

### 5.3 Taliban Commander

Schwerpunkte:

- alternative politische und gesellschaftliche Herrschaft;
- Shadow Governance und Shadow Justice;
- Bevölkerungskontrolle, freiwillige Unterstützung und erzwungene Befolgung;
- Rekrutierung, Finanzierung, Materiel und Reinfiltrationszugang;
- Schwächung staatlicher Legitimität;
- Einschränkung von BLUE- und ANSF-Handlungsfreiheit;
- langfristige Verdrängung ausländischer und staatlicher Kontrolle.

### 5.4 Haqqani Commander

Schwerpunkte:

- familien- und beziehungsgebundenes Netzwerk;
- externe Sanctuary-, Finance-, Facilitation- und Spezialistenkanäle;
- hohe Operationssicherheit und Compartmentation;
- regionale Verankerung in Loya Paktia bei überregionaler Reichweite;
- ausgewählte geeignete Kader und Broker;
- Zusammenstellung hochwertiger Capability Packages;
- Prestige und Einfluss innerhalb des insurgenten Lagers.

### 5.5 HIG Commander

Schwerpunkte:

- eigenständige politische und militärische Organisation;
- regionale Kommandeurs- und Patronagenetzwerke;
- Verhandlungs- und Deal-Fähigkeit;
- opportunistische lokale Kooperation;
- Konkurrenz um Rekruten, lokale Commander, Einnahmen und politische Repräsentation;
- Erhalt als eigenständiger Akteur trotz schwächerer militärischer Kohäsion.

## 6. Gemeinsames Ressourcenmodell

Version 1 modelliert nur Ressourcen, um die mindestens zwei Fraktionen konkurrieren oder deren Zugriff eine andere Fraktion beeinflussen kann.

```text
COMMON_CONTESTED_RESOURCES =
  RECRUITABLE_MANPOWER
  FINANCE
  MATERIEL
```

Der physische militärische Output ist:

```text
FORCE_PACKAGE
```

Grundformel:

```text
MANPOWER
+ FINANCE
+ MATERIEL
+ TIME
+ FACTION_SPECIFIC_ORGANIZATIONAL_GATE

-> FORCE_PACKAGE
```

Nicht als Grundressourcen geführt werden:

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

Diese Größen beeinflussen Zugang, Regeneration, Erhaltung, Risiko und Gate-Prüfungen.

## 7. Ressourcenherkunft und Eigentum

Ressourcen können zu Beginn stammen aus:

```text
AFGHAN_POPULATION_AND_LOCAL_COMMUNITIES
LOCAL_LEGAL_ECONOMY
AFGHAN_STATE_REVENUE_SYSTEM
ILLICIT_AND_CRIMINAL_ECONOMY
INTERNATIONAL_DONOR_AND_SECURITY_ASSISTANCE
ISAF_CONTRIBUTING_NATIONS
EXTERNAL_INSURGENT_SUPPORT_NETWORKS
```

Die Bevölkerung ist kein Besitzobjekt.

```text
POPULATION != OWNED_RESOURCE
```

Jeder relevante Knoten trennt:

```text
LEGAL_OWNER
PHYSICAL_CONTROLLER
CURRENT_BENEFICIARIES
ACCESS_SHARES
```

## 8. Informations- und Wahrheitsmodell

```text
WORLD_TRUTH
!= OBSERVED_INFORMATION
!= COMMANDER_BELIEF
!= COMMANDER_MEMORY
```

Jeder Commander erhält nur eine zulässige Sicht. Gemeinsame DCS-Koalition bedeutet keine automatische gemeinsame Omniszienz.

## 9. Deterministische Runtime-Regel

```text
LLM_PROPOSES_INTENT
ORCHESTRATOR_VALIDATES
CAMPAIGN_STATE_DECIDES_TRUTH
DCS_AND_MOOSE_EXECUTE
```

Geskriptete und spätere LLM-Commander verwenden dieselben Eingabe-, Ausgabe-, Validierungs- und Event-Verträge.

## 10. Dokumentautorität

Bei Widersprüchen innerhalb dieses Spezialprojekts gilt für den jeweiligen Fachbereich:

```text
Commander identities and behavior
-> faction dossier

Afghan State and ANSF faction
-> document 16

Contested resources ownership flow and force generation
-> document 17

Cross-document interpretation and amendments
-> document 18

Campaign persistence and events
-> document 13

Deterministic testing
-> document 14

Technology selection and deployment
-> document 15
```

Dokument 18 besitzt für die Interpretation älterer Ressourcenfelder Vorrang, bis die Ursprungsdokumente redaktionell direkt aktualisiert wurden.

## 11. Aktueller Dokumentbestand

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
18-resource-model-integration-and-dossier-amendments.md
```

## 12. Dokumentübersicht

### 01 – Quelleninventar

Historische Quellenbasis, Fraktionsabgrenzung und Readiness der Dossiers.

### 02 – Common Commander Model

Gemeinsame Commander-Struktur, Persönlichkeit, Autorität, begrenztes Lagebild und Entscheidungsschema.

### 03 – Inter-Faction Relations

Asymmetrische, regionale und ereignisabhängige Beziehungen, Verhandlungen, Ressourcentransfers und Konflikteskalation.

### 04 – Taliban Dossier

Historische Identität, Zielhierarchie, politische Kontrolle, Führungsverhalten und Persönlichkeit.

### 05 – Haqqani Dossier

Netzwerkidentität, Broker-, Facilitation-, Compartmentation- und Capability-Logik.

### 06 – HIG Dossier

Politisch-militärische Fraktion, regionale Patronage, Verhandlungsmacht, Fragmentierung und Eigenständigkeit.

### 07 – Runtime Rulebook

Strukturierte Aktionen, Validierung, Autorität und Runtime-Regeln.

### 08 – Memory, Belief and Information

Wahrheit, Beobachtung, Information, Belief, Memory, Täuschung und Wissenstransfer.

### 09 – Orchestrator Architecture

Scheduler, View Builder, LLM Gateway, Validator, Adjudicator, Operation Manager, Adapter und Recovery.

### 10 – BLUE Commander Dossier

ISAF-Kampagnenführung, Population Protection, Force Protection, Afghan Partnering und politische Einschränkungen.

### 11 – BLUE Mission Demand

MissionDemand, Force Allocation, Targeting, ISR, CAS, Partnering und Recovery auf Kommandoebene.

### 12 – Multi-Commander Tests

Teststufen, Invarianten, Szenarien und Qualitätsmetriken.

### 13 – CampaignState and Event Store

Persistente Aggregate, Events, Replay, Snapshots, IDs, Locks und DCS-Mappings.

### 14 – Deterministic Test Harness

Reproduzierbarer Testbetrieb mit geskripteten Commandern, Fault Injection und Golden Replay.

### 15 – Technology Selection

MOOSE-First-Anforderungen, Python-/Elixir-/Hybridvergleich, Deploymentmodelle und PoC.

### 16 – Afghan State and ANSF Dossier

Eigenständige afghanische Fraktion, Ziele, Organisation, Transition, Ressourcen, Force Generation und Beziehung zu ISAF.

### 17 – Resource Ownership and Force Generation

Verbindliches gemeinsames Ressourcenmodell mit Manpower, Finance, Materiel, Zugriff, Eigentum, Fluss, Konkurrenz und Force Packages.

### 18 – Integration and Amendments

Querschnittliche Aktualisierung der bestehenden Dossiers, Runtime-, State- und Testdokumente auf fünf Commander und das gemeinsame Ressourcenmodell.

## 13. Weitere Arbeitsreihenfolge

```text
19-language-neutral-contracts-and-json-schemas.md
20-resource-source-baseline-and-initial-allocation.md
21-force-package-catalog-and-generation-cost-model.md
22-population-access-legitimacy-and-coercion-transition-rules.md
23-moose-2-9-18-adapter-capability-audit.md
```

Die nächste fachliche Voraussetzung vor Implementierung ist Dokument 19. Es definiert sprachneutrale Schemas für Events, Commander Views, Decisions, Resources, Force Packages und Adapterkommunikation.

Konkrete Ausgangsmengen, Kosten und regionale Ressourcenquellen werden erst nach quellenbasierter Baseline und ausdrücklicher Datenentscheidung festgelegt.

## 14. Sicherheits- und Abstraktionsgrenze

Das Projekt modelliert militärische und politische Entscheidungslogik für eine Simulation. Es dokumentiert keine technischen Herstellungsanleitungen für Waffen, Sprengmittel oder reale Anschläge. Fähigkeiten werden als abstrakte Ressourcen, Missionsklassen und Capability Gates geführt.

## 15. Verbindlicher aktueller Konsolidierungsstand

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

PHYSICAL_MILITARY_OUTPUT =
  FORCE_PACKAGE

AFGHAN_STATE_SEPARATE_CAMPAIGN_FACTION = YES
AFGHAN_STATE_SEPARATE_DCS_COALITION = NO
BLUE_DIRECT_OWNERSHIP_OF_ANSF = NO
MOOSE_TACTICAL_FOUNDATION = REQUIRED
DIRECT_LLM_DCS_CONTROL = PROHIBITED
```
