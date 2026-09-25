---
document_id: OMW-ADR-0008-FIRE-SUPPORT-STRATEGIC-RESUPPLY-RESOURCE-AUTHORITY
status: BINDING_PROJECT_DECISION
document_class: ARCHITECTURE_DECISION_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - operational asset selection authority for Fire Support and Strategic Resupply
  - CampaignState, MOOSE and DCS resource-authority boundary for this scope
  - interpretation of the conflicting preselection language identified by Gate 0
not_authoritative_for:
  - DCS runtime acceptance of the future generic base module
  - approval of non-MOOSE or Native-DCS fallback implementations
  - replacement of resource-specific MOOSE-first gap analysis
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - CampaignState preselection of a concrete operational asset for Fire Support and Strategic Resupply
  - C2/OMW candidate selection of a concrete CAS asset before MOOSE recruitment in the generic production scope
superseded_by: []
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# ADR 0008 – Ressourcenautorität für Fire Support und Strategic Resupply

## Entscheidung

Für Fire Support und Strategic Resupply gilt die folgende MOOSE-first-Autoritätsgrenze:

```text
fachlicher Bedarf / MissionDemand / Incident
-> MOOSE-Organisation und öffentlicher MOOSE-Auftrag bzw. Transport
-> MOOSE selektiert und rekrutiert operative Assets
-> MOOSE/DCS führt den physischen Lifecycle aus
-> bestätigtes physisches Lifecycle-Ereignis
-> idempotente strategische Buchung in CampaignState
```

MOOSE besitzt innerhalb der konfigurierten Organisationen und Warehouses die operative Auswahl, Rekrutierung, Verfügbarkeitswarteschlange, Materialisierung, Auftrags-/Transportausführung und den beobachtbaren physischen Lifecycle. OMW und CampaignState bauen davor keine zweite Kandidatenwahl, keine Verfügbarkeitsqueue und keinen parallelen Dispatcher.

CampaignState selektiert für diesen Scope daher weder ein konkretes Luft- oder Bodenasset noch eine konkrete SQUADRON-, COHORT-, Carrier- oder Batterieinstanz, wenn MOOSE diese operative Auswahl innerhalb der konfigurierten Organisation bereits leisten kann.

## Rolle von CampaignState

CampaignState bleibt die strategische Persistenz- und Rechtsautorität. Dazu gehören insbesondere:

- dauerhafte strategische Identität und Zugehörigkeit, soweit sie für Kampagnenpersistenz benötigt werden;
- Eigentums-, Verlegungs-, Freigabe-, Verlust-, Wartungs- und sonstige Kampagnenzustände;
- idempotente Übernahme bestätigter Delivery-, Return-, Loss- und vergleichbarer Lifecycle-Ereignisse;
- Ressourcen, die weder MOOSE noch DCS autoritativ als operativen Bestand führen, insbesondere geeignete META-Ressourcen wie Personal- oder Versorgungskategorien.

CampaignState darf einen durch MOOSE oder DCS autoritativ geführten operativen Bestand nicht als unabhängigen zweiten Bestand duplizieren. Ein strategischer Ledger-Eintrag ist nur die persistente Abbildung derselben Ressource beziehungsweise ihres bestätigten Lifecycle-Ereignisses und keine zweite operative Verfügbarkeitsentscheidung.

## Rolle von MOOSE und DCS

MOOSE ist für den operativen Ressourcenpfad maßgeblich, soweit der eingesetzte und geprüfte MOOSE-Stand die jeweilige Funktion bereitstellt. Dazu gehören insbesondere `COMMANDER`, `CHIEF`, `LEGION`, `AIRWING`, `BRIGADE`, `COHORT`, `SQUADRON`, `WAREHOUSE`, `AUFTRAG`, `OPSTRANSPORT` und `ARTY` in ihrem jeweils bestätigten Funktionsumfang.

DCS bleibt die Laufzeitquelle für physische Simulationsobjekte und für native Stores-/Warehouse-Zustände, soweit ein solcher DCS-Bestand in OMW ausdrücklich als autoritative Quelle verwendet wird. Auch dann darf CampaignState denselben Bestand nicht unabhängig ein zweites Mal führen.

## Auswirkung auf ältere Regeln

Für den hier definierten Scope wird die ältere Aussage aus `OMW-GOV-001`, CampaignState müsse vor jeder Disposition den konkreten Herkunftspool und die konkrete strategische Ressource auswählen und MOOSE anschließend daran binden, präzisiert und insoweit ersetzt.

Ebenso sind die generischen Candidate-Evaluation-Aussagen in `OMW-MOOSE-STAGE3-CAS-LIFECYCLE-RECOVERY-LAW`, nach denen C2/OMW vor MOOSE eine konkrete CAS-Ressource auswählen soll, nur noch als historischer Stage-3-Testvertrag für die dort exakt dokumentierte Jalalabad-AH-64-Testbindung zu lesen. Sie sind keine Produktionsregel für die standortunabhängige Base.

Die Stage-3-Testprovenienz wird dadurch nicht rückwirkend verändert. Der Honaker/Jalalabad-Test bleibt Nachweis genau seines gebundenen Testfixtures.

## Grenzen

Diese Entscheidung behauptet nicht, dass MOOSE jede benötigte Fähigkeit bereits vollständig bereitstellt. Insbesondere bleibt die dokumentierte öffentliche API-Grenze für die individuelle Expiry beziehungsweise das Canceln roher `WAREHOUSE:AddRequest(...)`-Anforderungen bei dauerhaft fehlendem passenden Bestand offen.

Vor jedem projektspezifischen Fallback gilt weiterhin `OMW-GOV-MOOSE-FIRST`: Dokumentation, gepinnte `Moose.lua`, offizielle Demos/Tests, dokumentierte technische Lücke, kleinstmögliche Ergänzung und ausdrückliche Projektinhaberfreigabe.

## Gate-0-Folge

Der in `OMW-HANDOFF-FIRE-SUPPORT-STRATEGIC-RESUPPLY-BASE-20260911` Abschnitt 9 dokumentierte Authority-Konflikt ist mit dieser Entscheidung fachlich aufgelöst. Gate 1 darf daraus keine OMW-Vorselektion von Assets ableiten.
