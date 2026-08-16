---
document_id: OMW-AIR-TASKING-PLAN-PHASE0-MISSIONDEMAND-BOUNDARY
status: DRAFT
document_class: ARCHITECTURE_RECONCILIATION
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Phase 0 analysis of MissionDemand producer and consumer boundaries
  - identification of the owner decision still required before assigning producer authority
not_authoritative_for:
  - repository-wide assignment of new MissionDemand producer authority
  - MOOSE method signatures or runtime behavior
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Air Tasking Plan – Phase 0 MissionDemand Producer / Consumer Boundary

## 1. Zweck

Dieses Dokument untersucht den offenen Phase-0-Punkt:

```text
festlegen, welche vorhandenen Module MissionDemand erzeugen beziehungsweise konsumieren dürfen
```

Dabei wird ausdrücklich zwischen bereits verbindlich dokumentierten Rollen und einer noch nicht getroffenen Projektentscheidung über die tatsächliche Erzeugerautorität unterschieden.

Geprüfte Baselines:

- `OMW-GOV-001`;
- `OMW-GOV-MOOSE-FIRST`;
- `OMW-ARCH-SYSTEM`;
- `OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`;
- `OMW-AIR-TASKING-PLAN-FOUNDATION`;
- Phase-0-Reconciliation, CampaignState-Contract, Persistence-Boundary und Stable-ID-Convention auf diesem Branch.

## 2. Bereits verbindlich festgelegt

Dokument 37 legt fest:

```text
CampaignState
= strategische Wahrheit
= enthält MissionDemand-Objekte

MissionDemand
= einheitliche kampagnenweite Auftragsautorität

player tasks and AI AUFTRAG objects
= arbeiten auf demselben Bedarf
```

Dokument 03 ordnet außerdem folgende Komponenten ein:

```text
CampaignState
EntityManager
VirtualizationManager
LogisticsManager
RedDirector
CSARCampaignManager
MissionGenerator
PersistenceManager
```

Dabei ist ausdrücklich dokumentiert:

```text
MissionGenerator
= erzeugt spielbare Aufträge aus dem aktuellen Kampagnenzustand

PersistenceManager
= speichert ausschließlich strategischen Zustand
```

Diese Aussagen beantworten jedoch noch nicht vollständig, **welches Modul neue MissionDemand-Objekte anlegen darf**.

## 3. Sicher ableitbare Consumer-Grenze

Aus der bestehenden Architektur lässt sich ohne neue Projektentscheidung ableiten:

### 3.1 CampaignState

`CampaignState` speichert und autorisiert MissionDemand-Zustand, ist damit aber nicht automatisch fachlicher Erzeuger jedes neuen Bedarfs.

```text
CampaignState
= store / authority
!= automatically producer of every demand
```

### 3.2 MissionGenerator

Der dokumentierte `MissionGenerator` erzeugt spielbare Aufträge **aus** dem Kampagnenzustand. Damit ist er mindestens als Consumer von Kampagnenbedarf beziehungsweise MissionDemand einzuordnen.

Er darf aus dieser Beschreibung nicht stillschweigend zum alleinigen MissionDemand-Erzeuger erklärt werden.

### 3.3 Player-Tasking und KI-Ausführung

Dokument 37 legt fest, dass Spieleraufträge und KI-`AUFTRAG`-Objekte auf demselben MissionDemand arbeiten.

Damit sind spätere:

```text
player task adapters
MOOSE tasking adapters
AIR_TASKING_PLAN / AIR_TASKING_MISSION planning
```

Consumer beziehungsweise Planner auf Basis eines bestehenden Bedarfs. Sie dürfen nicht allein durch ihre Ausführungslogik einen zweiten parallelen Bedarf erzeugen.

### 3.4 PersistenceManager

Der `PersistenceManager` ist ausschließlich Transport-/Speichermechanismus für strategischen Zustand und besitzt keine fachliche Producer-Autorität.

## 4. Nicht aus der Baseline ableitbar

Die vorhandenen BINDING-Dokumente definieren **nicht eindeutig**, ob neue MissionDemand-Objekte zentral durch genau ein Modul oder dezentral durch mehrere fachliche Domänenmodule erzeugt werden sollen.

Insbesondere ist nicht verbindlich entschieden, ob folgende Komponenten selbst MissionDemand erzeugen dürfen:

```text
MissionGenerator
RedDirector
LogisticsManager
CSARCampaignManager
future BLUE operational director / Air Tasking planner
other future campaign-domain managers
```

Eine solche Producer-Zuweisung würde bestimmen:

- wo fachliche Duplikatvermeidung erfolgt;
- wer Priorität und Ablaufdatum eines Bedarfs setzt;
- wer Erfolgskriterien und Failure Consequences definiert;
- wie mehrere Domänen denselben Kampagnenbedarf korrelieren;
- ob Air Tasking Requests aus einem zentral erzeugten MissionDemand entstehen oder selbst neue MissionDemand anlegen dürfen.

Das ist eine echte Architekturentscheidung und wird in diesem Branch nicht stillschweigend getroffen.

## 5. Technisch notwendige Mindestregel unabhängig von der Entscheidung

Unabhängig vom später gewählten Producer-Modell gilt:

```text
1 logical campaign need
= exactly 1 authoritative MissionDemand
```

Nicht zulässig:

```text
MissionGenerator creates MD-000041
AirTaskingPlanner creates MD-000042
for the same underlying campaign need
```

Ebenfalls nicht zulässig:

```text
AIR_SUPPORT_REQUEST
= second MissionDemand authority
```

Der Air-Tasking-Pfad bleibt:

```text
MissionDemand
    ↓
AIR_SUPPORT_REQUEST
    ↓
AIR_TASKING_MISSION / AIR_TASKING_PLAN
```

Ein `AIR_SUPPORT_REQUEST` darf einen bestehenden MissionDemand normalisieren oder spezifizieren, aber nicht ohne ausdrücklich genehmigten Producer-Vertrag eine zweite Kampagnenbedarfswahrheit schaffen.

## 6. Entscheidungspunkt für den Projektinhaber

Für den Abschluss dieses Phase-0-Punkts ist eine Projektentscheidung erforderlich.

### Variante A – zentraler MissionDemand Producer

```text
Campaign event / domain signal
    ↓
central MissionDemand service / generator
    ↓
MissionDemand
    ↓
domain consumers / Air Tasking / player / AI
```

Eigenschaften:

- eine zentrale Duplikat- und ID-Grenze;
- Priorisierung und Lifecycle an einer Stelle;
- Fachmodule melden Bedarf, erzeugen ihn aber nicht selbst;
- stärkere zentrale Kopplung.

### Variante B – autorisierte Domain Producer

```text
RedDirector / Logistics / CSAR / other approved domain modules
    ↓
create canonical MissionDemand through one shared CampaignState contract
    ↓
MissionDemand
    ↓
consumers
```

Eigenschaften:

- Fachmodul besitzt die semantische Erzeugung seines Bedarfs;
- CampaignState bleibt gemeinsame Autorität und ID-/Duplicate-Grenze;
- Producer müssen explizit registriert beziehungsweise freigegeben sein;
- höhere Anforderungen an Duplicate-/Correlation-Regeln zwischen Domänen.

### Variante C – Hybrid

```text
domain modules propose demand
    ↓
central MissionDemand authority validates / deduplicates / creates
    ↓
MissionDemand
```

Eigenschaften:

- fachliche Erkennung bleibt in den Domänen;
- tatsächliche Erzeugung und Lifecycle-Autorität bleiben zentral;
- etwas mehr Koordinationslogik, aber klare Single-Writer-Grenze.

## 7. Empfehlung aus technischer Sicht

Keine der drei Varianten wird hier verbindlich ausgewählt.

Für OMW ist aus Sicht der bereits festgelegten Architektur **Variante C** besonders konsistent mit:

```text
CampaignState as strategic authority
+ domain-specific campaign logic
+ one canonical MissionDemand per need
+ no duplicate player/AI execution
```

Das ist jedoch lediglich eine technische Empfehlung. Die Auswahl ist eine Architekturentscheidung des Projektinhabers.

## 8. Phase-0-Status

```text
DONE:
- existing producer/consumer evidence reviewed
- safe consumer roles classified
- duplicate-authority prohibition documented
- owner decision isolated

BLOCKED ON OWNER DECISION:
- canonical MissionDemand producer model: A, B or C
```

Der Manifest-Punkt bleibt bis zu dieser Entscheidung offen.

Kein Runtime-Code wurde geändert. Kein DCS-Test ist für diese Architektur-Reconciliation erforderlich. `validated_in_dcs` bleibt `false`.
