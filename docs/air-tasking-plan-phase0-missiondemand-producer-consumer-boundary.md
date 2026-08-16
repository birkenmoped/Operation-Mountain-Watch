---
document_id: OMW-AIR-TASKING-PLAN-PHASE0-MISSIONDEMAND-BOUNDARY
status: DRAFT
document_class: ARCHITECTURE_RECONCILIATION
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Phase 0 MissionDemand producer and consumer boundary
  - reconciliation of MissionDemand origin with delegated command and support authority
not_authoritative_for:
  - repository-wide assignment of concrete OMW command nodes
  - exact historical OPCON, TACOM or TACON reconstruction
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

Dieses Dokument schließt die ursprüngliche zu enge Producer-Frage mit dem auf diesem Branch entwickelten Command-Authority-Modell zusammen.

Die frühere Auswahl zwischen

```text
A = one central producer
B = distributed domain producers
C = hybrid producer
```

wird **nicht** als OMW-Zielarchitektur übernommen.

Sie hat die reale und für OMW relevante Trennung zwischen:

```text
command authority
tasking authority
request authority
allocation
tactical control
```

nicht ausreichend abgebildet.

Maßgeblicher branch-lokaler Ergänzungsvertrag:

- `OMW-AIR-TASKING-PLAN-PHASE0-COMMAND-AUTHORITY`.

## 2. Bereits verbindlich festgelegt

Aus `OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION` gilt weiterhin:

```text
CampaignState
= strategische Wahrheit
= persistiert MissionDemand

MissionDemand
= einheitliche kampagnenweite Auftragsautorität

player tasks and AI AUFTRAG objects
= arbeiten auf demselben Bedarf
```

Damit bleibt zwingend:

```text
1 logical campaign need
= exactly 1 authoritative MissionDemand
```

Ein Player Task, MOOSE `AUFTRAG`, `AIR_SUPPORT_REQUEST` oder `AIR_TASKING_MISSION` darf keinen zweiten parallelen MissionDemand für denselben Bedarf erzeugen.

## 3. Korrektur der früheren Producer-Betrachtung

Die frühere Branch-Fassung führte beispielhaft auch `RedDirector` unter möglichen MissionDemand-Produzenten auf.

Das war für den hier untersuchten **BLUE Air-Tasking-/Support-Pfad fachlich falsch eingeordnet**.

Für die BLUE Command-/Support-Architektur gilt:

```text
RedDirector
= RED campaign behavior domain
!= BLUE MissionDemand authority
!= BLUE Air Support Request authority
!= BLUE Air Tasking authority
```

RED-Aktionen können die Kampagnenlage beeinflussen. Eine daraus entstehende BLUE-Bedarfsentscheidung gehört jedoch in die BLUE-/Campaign-Command-Domäne und nicht in den `RedDirector`.

## 4. MissionDemand-Origin statt globaler Producer

Die Foundation behandelt die Erzeugung eines MissionDemand nun als **autorisierten Origin innerhalb eines Command-/Responsibility-Scope**.

```text
Command / domain node
    ↓
detects or determines required effect
    ↓
authority / responsibility scope valid?
    ↓
duplicate / correlation check
    ↓
CampaignState registers canonical MissionDemand
```

Damit gilt:

```text
origin of demand
!= strategic ownership of assets
!= permission to task every capability required by the demand
```

Ein Command Node kann also einen gültigen MissionDemand erzeugen, obwohl er die für dessen Erfüllung benötigten Air Assets nicht selbst tasken darf.

## 5. Direkter Tasking-Pfad

Besitzt der originierende Command Node geeignete Kräfte unter eigener beziehungsweise ausdrücklich delegierter Tasking Authority:

```text
MissionDemand
    ↓
authority check
    ↓
asset available and taskable
    ↓
direct tasking path
```

Ein externer Air Support Request ist dafür nicht automatisch erforderlich.

Beispielhafte spätere Anwendungsfälle können lokale Bodenkräfte oder tatsächlich einem Command Node zugewiesene Capabilities sein. Die konkrete OMW-Zuordnung wird erst nach Festlegung der Command Nodes getroffen.

## 6. Support-Pfad über Authority-Grenze

Liegt die benötigte Capability außerhalb der Tasking Authority des Requesters:

```text
MissionDemand
    ↓
external capability required
    ↓
Support Request
    ↓
Supporting Authority
    ↓
allocation / tasking
```

Für Luftunterstützung:

```text
MissionDemand
    ↓
AIR_SUPPORT_REQUEST
    ↓
Air Support Authority
    ↓
AIR_TASKING_MISSION / AIR_TASKING_PLAN
    ↓
verified MOOSE execution
```

`AIR_SUPPORT_REQUEST` ist damit keine zweite MissionDemand-Autorität und kein obligatorischer Zwischenschritt jedes MissionDemand. Es repräsentiert den Luftunterstützungsbedarf **über eine Authority-Grenze hinweg**.

## 7. Consumer-Grenze

### 7.1 CampaignState

```text
CampaignState
= canonical store / authority for MissionDemand identity and state
```

CampaignState muss nicht selbst die fachliche Ursache jedes Bedarfs erkennen.

### 7.2 MissionGenerator

Der dokumentierte `MissionGenerator` erzeugt spielbare Aufträge aus Kampagnenzustand.

Damit bleibt er mindestens Consumer/Planner von MissionDemand beziehungsweise Kampagnenbedarf. Seine genaue Rolle bei der späteren technischen Registrierung eines autorisierten MissionDemand wird erst im Domain Model festgelegt und darf nicht aus dem alten Namen `MissionGenerator` abgeleitet werden.

### 7.3 Air Tasking

```text
AIR_SUPPORT_REQUEST
AIR_TASKING_PLAN
AIR_TASKING_MISSION
```

sind Planungs-/Supportobjekte auf Basis eines autorisierten Bedarfs und besitzen keine parallele strategische Ressourcen- oder MissionDemand-Hoheit.

### 7.4 Player- und AI-Ausführung

```text
player task adapter
MOOSE COMMANDER / AIRWING / BRIGADE / AUFTRAG
FLIGHTGROUP / ARMYGROUP / DCS
```

sind Consumer beziehungsweise Execution-Repräsentationen.

### 7.5 PersistenceManager

`PersistenceManager` bleibt Speicher-/Transportmechanismus und besitzt keine fachliche Origin- oder Tasking Authority.

## 8. Request Path ist nicht Command Path

Ein Command Node kann innerhalb eines später festgelegten Request Scope Unterstützung direkt bei der zuständigen Supporting Authority anfordern, ohne dass dadurch jede Zwischenstufe der organisatorischen Führungskette zu einem technischen Freigabeschritt werden muss.

```text
requesting node
    ↓
authorized support channel
    ↓
supporting authority
```

Die eigene Führungskette kann trotzdem Prioritäten, Constraints, Reservations oder Override-Regeln vorgeben.

Die genauen Eskalations- und Override-Regeln bleiben offen.

## 9. Höheres Tasking bindet lokale Disposition

Ein Asset, das durch höher priorisiertes Tasking oder eine CampaignState-Reservation bereits gebunden ist, darf nicht durch einen lokalen MissionDemand stillschweigend erneut disponiert werden.

```text
higher-priority tasking / reservation
    ↓
asset committed
    ↓
local direct-tasking unavailable
```

Eine spätere Retasking-Entscheidung benötigt eine eigene Authority-Regel.

## 10. Was Phase 0 damit festlegen kann

Ohne die vollständige OMW-Kommandotopologie vorwegzunehmen gilt branch-lokal:

```text
1. MissionDemand has one canonical CampaignState identity.
2. Demand may originate at different authorized BLUE command/domain nodes.
3. Origin authority is limited by responsibility scope.
4. Direct tasking requires actual tasking authority over a suitable asset.
5. External air capability requires an Air Support Request to the supporting authority.
6. Request authority does not imply command or ownership of the requested asset.
7. Air Tasking and MOOSE remain consumers/execution layers, not MissionDemand authorities.
```

## 11. Noch offene Projektentscheidungen

Nicht festgelegt sind:

- vollständige OMW-Liste von Command Nodes;
- welche Basis-/FOB-/COP-/taktischen Ebenen eigene MissionDemand-Origin-Authority erhalten;
- welche Capabilities welcher Ebene direkt unterstehen;
- welche Capabilities regional beziehungsweise zeitlich alloziert werden können;
- welche Capabilities ausschließlich über höhere Supporting Authorities angefordert werden;
- Override-, Escalation- und Retasking-Regeln;
- konkrete MOOSE-`CHIEF`-/`COMMANDER`-/`AIRWING`-/`BRIGADE`-Topologie.

Diese Punkte werden nicht stillschweigend entschieden.

## 12. Phase-0-Status

Der alte A/B/C-Entscheidungspunkt ist damit verworfen.

Der Producer-/Consumer-Punkt ist fachlich auf die Command-Authority-Frage zurückgeführt und besitzt jetzt einen belastbaren Branch-Vertrag. Die konkrete Command-Node-Ausprägung bleibt Aufgabe des folgenden Domain Models und der MOOSE-First-Prüfung.

Kein Runtime-Code wurde geändert. Kein DCS-Test ist für diese Reconciliation erforderlich. `validated_in_dcs` bleibt `false`.
