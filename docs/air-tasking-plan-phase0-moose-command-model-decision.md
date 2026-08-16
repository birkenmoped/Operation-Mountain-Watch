---
document_id: OMW-AIR-TASKING-PLAN-PHASE0-MOOSE-COMMAND-MODEL
status: PLANNED
document_class: ARCHITECTURE_DECISION
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local owner decision to use a historically plausible MOOSE-centered command model
  - boundary between OMW authority metadata and MOOSE asset/mission execution
  - rejection of a 1:1 NATO C2 simulation for the Air Tasking foundation
not_authoritative_for:
  - repository-wide authority until integrated to main
  - final OMW command-node inventory
  - exact historical OPCON, TACOM or TACON reproduction
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

# Air Tasking Plan – Phase 0 MOOSE-centered Command Model Decision

## 1. Owner decision

Der Projektinhaber hat für die OMW-Command-/Air-Tasking-Foundation folgende Zielrichtung festgelegt:

```text
HISTORISCH PLAUSIBEL
+
AUTHORITY-GRENZEN SICHTBAR
+
MOOSE ALS AUSFUEHRUNGS- UND ASSET-MANAGEMENT
+
KEINE 1:1-NATO-C2-SIMULATION
```

Diese Entscheidung ersetzt keine bestehende Governance. Sie konkretisiert den branch-lokalen Command-Authority-Vertrag fuer die weitere Phase-0-/Phase-1-/Phase-2-Arbeit.

## 2. Konsequenz

OMW bildet reale ISAF-/NATO-Prinzipien nur so weit ab, wie sie fuer glaubwuerdige Missionsentstehung, Asset-Verfuegbarkeit, Unterstuetzungsanforderungen und Prioritaeten relevant sind.

Nicht Ziel ist eine eigene vollstaendige Simulation von:

```text
OPCOM
OPCON
TACOM
TACON
TOC / ASOC / CAOC als vollstaendige technische C2-Systeme
mehrstufigen realen Genehmigungswegen
nationalen Caveats als generische Runtime-Engine
```

Historische Begriffe und Strukturen bleiben Referenz fuer Plausibilitaet und konkrete spaetere Einzelfallentscheidungen.

## 3. MOOSE-first Ausfuehrungsprinzip

Die technische Ausfuehrung soll soweit wie moeglich innerhalb der tatsaechlich verwendeten MOOSE-Strukturen verbleiben:

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

Welche dieser Ebenen fuer OMW produktiv genutzt werden und welche konkrete Topologie entsteht, wird erst nach der verbindlichen MOOSE-First-Pruefung gegen Dokumentation, gepinnte `Moose.lua` und relevante offizielle Beispiele festgelegt.

Eine eigene parallele Command-/Dispatcher-Engine ist nicht genehmigt.

## 4. OMW ergaenzt nur die fehlende fachliche Authority-Semantik

OMW darf oberhalb beziehungsweise neben der MOOSE-Ausfuehrung nur die Informationen halten, die fuer die Kampagnensemantik notwendig sind und von MOOSE nicht automatisch als OMW-Kampagnenwahrheit bereitgestellt werden.

Dazu gehoeren konzeptionell:

```text
home_command
current allocation / support relationship
authority_scope
request authority
MissionDemand correlation
CampaignState reservation / availability correlation
higher-priority commitment
```

Diese Begriffe sind noch keine freigegebenen Lua-Felder oder ein festes Runtime-Schema.

## 5. Keine unnoetige Ein-Zustands-Matrix

Die Foundation modelliert `LOCAL`, `ALLOCATED`, `SUPPORT` und `COMMITTED` nicht als eine einzige kuenstliche Zustandsmaschine.

Sie beschreiben unterschiedliche Sachverhalte:

```text
LOCAL / SUBORDINATE
= Asset liegt innerhalb direkter Tasking Authority eines Command Nodes.

ALLOCATED
= Asset oder Capability ist fuer einen definierten Raum, Zeitraum oder Zweck einer anderen Authority beziehungsweise Support-Funktion zugeordnet.

SUPPORT REQUEST
= ein Requester benoetigt eine Capability ausserhalb seiner aktuellen Tasking Authority.

COMMITTED
= ein Asset ist bereits durch einen Auftrag, eine Reservation oder hoeher priorisiertes Tasking gebunden.
```

Ein Asset kann daher beispielsweise gleichzeitig:

```text
home_command = JALALABAD
allocated_to = CAS_SUPPORT_EAST
committed_to = CAS mission
```

sein. `home_command` bleibt dabei von der aktuellen Tasking-/Allocation-Beziehung getrennt.

## 6. Referenzfall Jalalabad / AH-64

### 6.1 Lokal verfuegbarer AH-64

```text
home_command = JALALABAD
current tasking authority = JALALABAD
available = true
```

Bei geeignetem lokalen MissionDemand kann Jalalabad den AH-64 innerhalb seiner Missionsregeln direkt fuer CAS oder einen anderen zulaessigen Auftrag einsetzen.

```text
Jalalabad MissionDemand
    ↓
local suitable asset available
    ↓
direct tasking
    ↓
MOOSE mission execution
```

Dafuer ist kein externer Air Support Request erforderlich.

### 6.2 AH-64 wurde fuer CAS-Unterstuetzung alloziert

Ein Jalalabad-basierter AH-64 kann fuer einen definierten Zeitraum oder Auftrag einer CAS-Support-Funktion zugeordnet sein.

```text
home_command = JALALABAD
allocated_to = CAS_SUPPORT_EAST
current tasking authority = CAS_SUPPORT_EAST
```

Solange diese Allocation gilt, darf Jalalabad das Asset nicht stillschweigend fuer einen konkurrierenden lokalen Auftrag disponieren.

Benötigen Jalalabad oder eine untergeordnete Einheit CAS, entsteht der Support-Pfad:

```text
Jalalabad / subordinate unit
    ↓
CAS requirement
    ↓
AIR_SUPPORT_REQUEST
    ↓
CAS supporting authority
    ↓
asset selection
```

Die Supporting Authority kann dabei denselben Jalalabad-basierten AH-64 wieder dem Request zuweisen. Das Asset unterstuetzt dann seine Herkunftskraefte, ohne dass der lokale Requester waehrend der Allocation direkte Tasking Authority ueber das Asset besitzt.

### 6.3 Kein lokales geeignetes Asset verfuegbar

```text
MissionDemand
    ↓
no suitable asset under current local tasking authority
    ↓
AIR_SUPPORT_REQUEST
    ↓
supporting authority
    ↓
allocate available CAS capability
```

Das zugewiesene Asset kann aus Jalalabad, einer anderen Basis oder einem bereits vorallozierten Support-Pool stammen. Die konkrete Auswahl soll soweit moeglich durch die spaeter verifizierte MOOSE-Ausfuehrungsstruktur erfolgen und nicht durch eine parallele OMW-Asset-Dispatcher-Engine.

## 7. Hoeher priorisierte und theaterweite Assets

Nicht jede Capability soll lokal taskbar sein.

AAR ist der klare Referenzfall fuer eine hoeher liegende Authority-Grenze:

```text
local / regional requirement
    ↓
AAR support request / planning requirement
    ↓
higher air-support authority
    ↓
availability / priority / allocation
    ↓
MOOSE execution through the existing AAR architecture
```

Welche weiteren Capability-Typen ausschliesslich oder ueberwiegend hoeher disponiert werden, bleibt eine spaetere Projektentscheidung und wird nicht pauschal in Phase 0 festgelegt.

## 8. MissionDemand- und Support-Grundregel

Die Entscheidung bestaetigt folgende Trennung:

```text
MissionDemand
= required effect / task

AIR_SUPPORT_REQUEST
= request for air capability across an authority boundary

AIR_TASKING_MISSION
= concrete air-side planning/allocation record

MOOSE AUFTRAG / OPSGROUP
= physical execution representation
```

Damit gilt ausdruecklich:

```text
need for air support
!= automatically AIR_SUPPORT_REQUEST
```

Wenn der originierende Command Node ein geeignetes Asset unter aktueller Tasking Authority besitzt, kann der Bedarf direkt in den MOOSE-Tasking-Pfad gehen.

Wenn die Capability ausserhalb der aktuellen Tasking Authority liegt, wird die Authority-Grenze durch einen Support Request sichtbar.

## 9. CampaignState bleibt strategische Autoritaet

Unveraendert gilt:

```text
CampaignState
= authoritative for strategic existence, inventory, availability,
  reservations, losses, repairs and persistent MissionDemand state
```

Weder MOOSE-Kommandostruktur noch Allocation-/Support-Beziehungen duerfen eine zweite strategische Ressourcenhoheit erzeugen.

## 10. Phase-2-Pruefauftrag

Vor der produktiven Command-Topologie ist in Phase 2 gezielt zu pruefen, wie weit MOOSE die benoetigte Hierarchie und Delegation bereits traegt.

Mindestens zu untersuchen:

```text
CHIEF
COMMANDER
AIRWING
BRIGADE
SQUADRON
PLATOON
AUFTRAG
FLIGHTGROUP
ARMYGROUP
```

Dabei sind insbesondere zu klaeren:

```text
mission assignment at each supported level
asset selection and availability
existing mission priorities / assignment restrictions
legion/cohort relationships
mission cancellation / reassignment behavior
relevant FSM events and callbacks
whether temporary allocation can be represented by existing MOOSE mechanisms
```

Erst wenn eine konkrete erforderliche Authority-Funktion durch MOOSE nicht ausreichend abbildbar ist, darf eine kleine OMW-Ergaenzung entworfen werden. Eine Nicht-MOOSE- oder Parallelimplementierung benoetigt weiterhin die ausdrueckliche Eigentuemergenehmigung nach `OMW-GOV-MOOSE-FIRST`.

## 11. Bewusst offen

Diese Owner-Entscheidung legt noch nicht fest:

```text
- vollstaendige OMW Command-Node-Liste;
- exakte regionale Command-Topologie;
- welche einzelnen Basen, FOBs, COPs oder taktischen Einheiten eigene Command Nodes erhalten;
- welche konkreten Assets wann lokal, regional oder theaterweit taskbar sind;
- konkrete Prioritaets-, Override-, Escalation- oder Retasking-Regeln;
- exakte MOOSE CHIEF/COMMANDER-Konfiguration;
- genaue CAS-, JTAC-, AAR- oder ISR-Runtime-Verfahren.
```

Diese Entscheidungen werden erst getroffen, wenn sie fuer das Domain Model beziehungsweise die verifizierte MOOSE-Integration notwendig werden.

## 12. Ergebnis

Der weitere Foundation-Weg lautet damit:

```text
historical command principles as plausibility reference
    ↓
minimal OMW authority boundaries
    ↓
MOOSE-native command / asset / mission mechanisms wherever sufficient
    ↓
small OMW adapter only for proven domain gaps
    ↓
CampaignState remains strategic truth
```

Kein Runtime-Code und keine `.miz` wurden durch diese Entscheidung geaendert. Ein DCS-Test ist fuer diese reine Architekturentscheidung nicht erforderlich. `validated_in_dcs` bleibt `false`.
