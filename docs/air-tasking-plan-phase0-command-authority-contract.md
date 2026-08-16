---
document_id: OMW-AIR-TASKING-PLAN-PHASE0-COMMAND-AUTHORITY
status: DRAFT
document_class: ARCHITECTURE_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Phase 0 command-authority model for MissionDemand and air-support tasking
  - separation of command, tasking, request, allocation and tactical-control relationships
  - branch-local rule for when Air Support Requests cross an authority boundary
not_authoritative_for:
  - repository-wide ISAF command reconstruction
  - final OMW command-node inventory or exact authority assignments
  - exact OPCON, TACOM or TACON reproduction
  - MOOSE API signatures or runtime behavior
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Air Tasking Plan – Phase 0 Command Authority Contract

## 1. Zweck

Dieses Dokument ersetzt die zu enge Fragestellung

```text
Welches einzelne Modul darf MissionDemand erzeugen?
```

für den Foundation-Branch durch die fachlich passendere Frage:

```text
Welche Stelle erkennt einen Bedarf,
welche Stelle besitzt dafür Tasking Authority,
und wann muss eine externe Supporting Authority angefragt werden?
```

OMW bildet die reale ISAF-/NATO-Kommandostruktur nicht 1:1 nach. Die historische Struktur dient als fachliche Vorlage für eine vereinfachte, spielbare und MOOSE-first-fähige Autoritätslogik.

Geprüfte Projektbaselines:

- `OMW-GOV-001`;
- `OMW-GOV-MOOSE-FIRST`;
- `OMW-ARCH-SYSTEM`;
- `OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`;
- `OMW-AIR-TASKING-AIRSPACE-CAS-REQUESTS`;
- `OMW-AIR-TASKING-PLAN-FOUNDATION`;
- Phase-0-CampaignState-, Persistence- und Stable-ID-Verträge.

## 2. Grundentscheidung der Branch-Architektur

MissionDemand, Support Request und physische Missionsausführung sind getrennte Verantwortungsbereiche.

```text
CampaignState
= strategische Wahrheit und persistente Autorität

Command Domain
= wer innerhalb welchen Scopes Bedarf, Tasking und Support-Anforderungen autorisieren darf

MissionDemand
= welcher Effekt beziehungsweise Auftrag erreicht werden muss

Support Request
= Anforderung an eine andere Authority, wenn der Requester die benötigte Capability nicht selbst tasken darf

Air Tasking
= luftseitige Planung und Zuordnung einer konkreten Luftmission

MOOSE
= primärer Mechanismus für Asset-Auswahl und physische Ausführung innerhalb der geprüften Framework-Grenzen
```

Damit gilt ausdrücklich:

```text
REQUEST AUTHORITY != TASKING AUTHORITY
TASKING AUTHORITY != STRATEGIC RESOURCE OWNERSHIP
TACTICAL CONTROL != ASSET OWNERSHIP
MOOSE RUNTIME OBJECT != CAMPAIGN AUTHORITY
```

## 3. Fünf getrennte Beziehungen

### 3.1 Strategic Availability Authority

`CampaignState` bleibt alleinige strategische Autorität für Bestand, Verfügbarkeit, Verlust, Reparatur, Reservierung und Ressourcenwirkung.

Ein Command Node darf ein Asset nicht dadurch strategisch besitzen, dass es ihm operativ zugeordnet oder für einen Zeitraum zur Unterstützung bereitgestellt wurde.

### 3.2 Command Authority

Beschreibt die organisatorische beziehungsweise operative Unterstellung, die OMW für einen Command Node modelliert.

Sie beantwortet:

```text
Welche Kräfte gehören innerhalb des aktuellen OMW-Scope grundsätzlich zu diesem Command Node?
```

Die genaue historische NATO-Rechtsform `OPCOM`/`OPCON` wird in Phase 0 nicht 1:1 implementiert.

### 3.3 Tasking Authority

Beschreibt, welche unterstellten oder ausdrücklich zugewiesenen Assets ein Command Node innerhalb eines definierten Scopes direkt für einen Auftrag einsetzen darf.

Tasking Authority ist immer begrenzt durch mindestens:

```text
higher-priority existing tasking
CampaignState availability
existing reservations
mission rules / ROE / campaign constraints
asset capability
readiness / technical availability
assigned geographic / temporal / mission scope
```

### 3.4 Request Authority

Beschreibt, welche Unterstützung ein Command Node bei einer anderen Authority anfordern darf.

Ein Request erzeugt keine Befehlsgewalt über das angeforderte Asset.

```text
requester
    ↓
Support Request
    ↓
supporting authority
    ↓
allocate / delay / deny / retask within its authority
```

### 3.5 Tactical Control

Beschreibt begrenzte Kontrolle während eines Abschnitts der Ausführung.

Für CAS ist das wichtigste spätere Beispiel die terminale Kontrolle durch einen JTAC. Daraus folgt keine organisatorische oder strategische Besitzbeziehung zum Luftfahrzeug.

Die konkrete CAS-/JTAC-Runtime bleibt Phase 5 und benötigt vor Implementierung die zuständige MOOSE-/DCS-Prüfung.

## 4. Drei Asset-Beziehungen zu einem Command Node

Für die Foundation werden drei semantische Fälle unterschieden.

### 4.1 Subordinate / organic

```text
Command Node
    ↓
subordinate asset
    ↓
direct tasking within delegated scope
```

Der Command Node darf geeignete unterstellte Assets im Rahmen seiner Tasking Authority direkt einem MissionDemand zuordnen.

### 4.2 Allocated / supporting for a defined scope

```text
higher/supporting authority
    ↓
asset/capability allocation
    ↓
command/region/time/mission scope
```

Das Asset bleibt strategisch bei CampaignState und organisatorisch bei seiner eigentlichen Struktur, kann aber für einen definierten Zeitraum, Raum oder Auftrag einer unterstützten Stelle bevorzugt beziehungsweise begrenzt zur Verfügung stehen.

OMW verwendet hierfür zunächst den neutralen Begriff `allocation`. Eine exakte Gleichsetzung mit historischem `TACON`, `OPCON` oder `TACOM` wird nicht vorgenommen.

### 4.3 External support

```text
requesting command
    ↓
Support Request
    ↓
supporting authority
    ↓
asset allocation and tasking
```

Der Requester besitzt keine Tasking Authority über das Asset.

## 5. MissionDemand entsteht aus Command-/Domain-Bedarf, nicht aus Asset-Besitz

Ein `MissionDemand` beschreibt den benötigten Effekt beziehungsweise Auftrag unabhängig davon, ob der erzeugende Command Node selbst geeignete Assets besitzt.

Beispiel:

```text
MD-000125
required effect:
  protect BLUE ground force in sector X
priority:
  urgent
```

Danach wird die Authority-Grenze geprüft.

### 5.1 Geeignetes Asset unter eigener Tasking Authority vorhanden

```text
MissionDemand
    ↓
command authority check
    ↓
asset available under direct tasking authority
    ↓
direct tasking path
```

Dafür ist kein `AIR_SUPPORT_REQUEST` an eine externe Air Authority erforderlich.

### 5.2 Benötigte Capability liegt außerhalb der Tasking Authority

```text
MissionDemand
    ↓
required capability outside requester tasking authority
    ↓
AIR_SUPPORT_REQUEST
    ↓
Air Support Authority
    ↓
AIR_TASKING_MISSION / AIR_TASKING_PLAN
    ↓
MOOSE execution
```

Damit ist `AIR_SUPPORT_REQUEST` im Foundation-Modell ausdrücklich ein Objekt für eine Authority-Grenze und nicht automatisch ein obligatorischer Schritt jedes MissionDemand.

## 6. CAS als Referenzfall

Die fachliche CAS-Referenz in `OMW-AIR-TASKING-AIRSPACE-CAS-REQUESTS` trennt Ground-Support-Bedarf von luftseitiger Asset-Zuordnung.

Das vereinfachte OMW-Zielbild lautet:

```text
ground unit / local command / TOC-like function
    ↓
MissionDemand / CAS requirement
    ↓
AIR_SUPPORT_REQUEST
    ↓
ASOC-like Air Support Authority
    ↓
select / allocate available CAS capability
    ↓
AIR_TASKING_MISSION
    ↓
CRC/AWACS-like control where modeled
    ↓
JTAC terminal control where modeled
```

Nicht zulässig ist daraus abzuleiten:

```text
local ground commander requests CAS
= local ground commander owns or commands CAS aircraft
```

### 6.1 Preplanned support

Für planbaren Bedarf kann eine Capability bereits vorab einem Raum, Zeitfenster oder Auftrag zugeordnet sein.

```text
higher air planning
    ↓
CAS capability allocation
    ↓
regional/local support scope
    ↓
request can be satisfied from allocated pool
```

### 6.2 Immediate support

Bei akutem Bedarf kann die Supporting Authority verfügbare, Ground-Alert- oder retaskbare Assets nach Priorität und Verfügbarkeit auswählen.

Die konkreten Prioritäts-, Ground-Alert- und Retasking-Regeln bleiben spätere Phasen und werden hier nicht vorweggenommen.

## 7. AAR als Gegenbeispiel mit höherer Authority-Grenze

AAR verdeutlicht, dass Request Authority weit unterhalb der eigentlichen Tasking Authority liegen kann.

```text
local / regional operation
    ↓
requires AAR capability
    ↓
AAR support requirement
    ↓
higher air-support / AAR authority
    ↓
strategic availability and priority check
    ↓
AAR mission allocation
```

Ein lokaler Command Node darf dadurch keinen Tanker direkt kommandieren.

Welche konkrete OMW-Stelle AAR, AWACS, ISR oder andere theaterweite Assets verwaltet, wird in diesem Vertrag bewusst nicht festgelegt. Diese Zuordnung benötigt die spätere Command-Node- und MOOSE-First-Prüfung.

## 8. Höheres Tasking schlägt lokale freie Disposition

Ein Command Node darf ein Asset nur innerhalb seines verbleibenden Authority-Scope einsetzen.

```text
higher-priority tasking exists
    ↓
asset committed / reserved
    ↓
local MissionDemand cannot silently override it
```

Eine spätere Repriorisierung oder ein Retasking benötigt eine explizite Authority-Regel und darf nicht aus bloßer lokaler Nähe oder Verfügbarkeit abgeleitet werden.

## 9. Request Path und Command Path sind getrennt

Ein niedriger Command Node darf künftig eine Unterstützungsanforderung direkt an die zuständige Supporting Authority richten, wenn der vereinbarte Request Scope dies erlaubt.

Damit ist nicht automatisch eine serielle Freigabekette erforderlich:

```text
squad
→ company
→ battalion
→ brigade
→ regional command
→ air support authority
```

Stattdessen kann fachlich gelten:

```text
requesting node
    ↓
authorized support channel
    ↓
supporting authority
```

Die eigene Führungskette kann dabei für Lagebild, Priorität oder Override relevant bleiben. Die exakten Regeln werden erst mit dem späteren Command-Node-Modell definiert.

## 10. MOOSE-Abbildung: Ausführungsstruktur, keine 1:1-NATO-Rekonstruktion

Die im Projekt bereits relevante MOOSE-Struktur wird als technische Ausführungshierarchie behandelt:

```text
CHIEF
    ↓
COMMANDER
    ↓
LEGION
    ├── AIRWING
    ├── BRIGADE
    └── FLEET
         ↓
COHORT
    ├── SQUADRON
    └── PLATOON
         ↓
OPSGROUP
    ├── FLIGHTGROUP
    └── ARMYGROUP
```

Phase 0 legt **keine** Gleichsetzung fest wie:

```text
ISAF IJC = CHIEF
RC-East = COMMANDER
Jalalabad = BRIGADE
```

Stattdessen gilt:

```text
OMW Command Domain
= fachliche Authority- und Request-Beziehungen

MOOSE hierarchy
= bevorzugte technische Asset-/Mission-Execution-Struktur
```

Welche MOOSE-Klasse welche Authority-Beziehung bereits ausreichend tragen kann, wird verbindlich erst in Phase 2 nach folgendem Pfad geprüft:

```text
MOOSE documentation
→ pinned Moose.lua
→ signatures / FSM / side effects
→ official demos/tests
→ smallest OMW adapter
```

Eine eigene parallele Command Engine ist nicht genehmigt.

## 11. Minimaler späterer Command-Node-Vertrag

Für Phase 1 ist als fachlicher Mindestbedarf vorgesehen:

```text
command_node_id
parent_command_node_id
authority_scope
subordinate_entity_ids
allocated_capability_refs
requestable_capability_types
supporting_authority_refs
higher_priority_tasking_refs
```

Diese Felder sind noch kein freigegebener Lua-Vertrag. Sie beschreiben lediglich die Informationen, die das spätere Domain Model voraussichtlich unterscheiden muss.

## 12. Konsequenz für MissionDemand Producer / Consumer

Die Producer-Frage wird nicht mehr als globale Single-Writer-Auswahl A/B/C behandelt.

Stattdessen gilt als Branch-Ziel:

```text
A Command/Domain Node may originate a MissionDemand
only within its defined authority and responsibility scope.

CampaignState remains the canonical persistent authority
for the resulting MissionDemand identity and state.
```

Das spätere Erzeugen eines MissionDemand benötigt daher:

```text
originating_command_node_id
responsibility / authority scope
required effect
correlation / duplicate check
CampaignState registration
```

Air Tasking, MOOSE `AUFTRAG`, Player Tasking und physische DCS-Gruppen bleiben Consumer beziehungsweise Execution-Repräsentationen und dürfen keinen zweiten parallelen MissionDemand für denselben Bedarf erzeugen.

## 13. Noch offene Eigentümerentscheidungen

Dieses Dokument trifft noch **nicht** folgende Projektentscheidungen:

- vollständige OMW-Liste aller Command Nodes;
- welche Basen, FOBs, COPs oder taktischen Einheiten eigene Command Nodes erhalten;
- welche Capability-Typen auf welcher Ebene direkt taskbar sind;
- welche Air-Support-Capabilities regional voralloziert werden;
- welche Assets nur theaterweit angefordert werden dürfen;
- konkrete Override-/Escalation-/Retasking-Regeln;
- exakte Abbildung historischer OPCON-/TACOM-/TACON-Beziehungen;
- konkrete MOOSE-`CHIEF`-/`COMMANDER`-Topologie.

Diese Punkte werden nicht stillschweigend aus historischen Quellen oder MOOSE-Klassen abgeleitet.

## 14. Phase-0-Ergebnis

Der Branch kann damit bereits folgende Architekturgrenzen festhalten:

```text
CampaignState owns strategic truth.
MissionDemand owns required campaign effect/task identity.
Command Authority determines who may originate or directly task within scope.
Support Request crosses an authority boundary.
Air Tasking allocates and plans air support.
MOOSE executes through verified framework mechanisms.
```

Kein Runtime-Code wurde geändert. Kein DCS-Test ist für diesen Architekturvertrag erforderlich. `validated_in_dcs` bleibt `false`.
