---
document_id: OMW-GROUND-ORDER-OPORD-FRAGO-FOUNDATION
status: PLANNED
document_class: ARCHITECTURE
owning_policy: OMW-GOV-001
authoritative_for:
  - planned OMW ground-order information model
  - planned relationship between OPORD, FRAGO, GroundTask, ExecutionAttempt and MOOSE execution
  - planned ground-task classification and MOOSE-first mapping boundary
  - planned ground-order persistence and restart semantics
  - planned human-readable OPORD/FRAGO views derived from structured data
not_authoritative_for:
  - a claim that OMW reproduces an original Afghanistan 2010/2011 OPORD or FRAGO
  - final runtime implementation
  - DCS runtime acceptance
  - final BLUE COMMANDER production integration
  - final ground-force ORBAT strengths
  - final frequencies, COMSEC, authentication data or historical command-net details
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/ground-order-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# 91 – Ground Order Foundation: OPORD, FRAGO und MOOSE-Ausführungsgrenze

## 1. Zweck

Dieses Dokument hält die Ground-Order-Architektur für Operation Mountain Watch vollständig fest.

Ausgangspunkt ist die bereits für Air Operations getroffene Entscheidung, dass realistische Führungsprodukte und maschinenlesbare Missionsdaten **oberhalb** der MOOSE-Ausführung liegen. Für Ground wird daher **kein frei erfundenes GTO-Kürzelformat** eingeführt.

Die Ground-Seite verwendet stattdessen eine OPORD-/FRAGO-artige Führungsstruktur und einen gemeinsamen strukturierten OMW-Auftragskern:

```text
CampaignState / MissionDemand
        ↓
OPORD
        ↓
FRAGO
        ↓
GroundTask
        ↓
ExecutionAttempt
        ↓
OMW GroundOrderAdapter
        ↓
MOOSE AUFTRAG
        ↓
BRIGADE / ARMYGROUP
        ↓
DCS
```

Der Ansatz ist ausdrücklich **MOOSE-first**. OMW implementiert keine zweite Missionsausführungsengine, keinen parallelen taktischen Mission-FSM und keine zweite Ressourcenautorität.

## 2. Autoritäts- und Quellenbasis

### 2.1 Projektquellen

Maßgeblich bleiben insbesondere:

- [`OMW-GOV-001`](00-project-governance.md)
- [`OMW-GOV-MOOSE-FIRST`](26-moose-first-development-policy.md)
- [`OMW-ARCH-CAMPAIGN-STATE`](04-campaign-state.md)
- [`OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`](37-campaign-architecture-and-dynamic-mission-design.md)
- [`OMW-AIR-TASKING-AIRSPACE-CAS-REQUESTS`](54-air-tasking-airspace-control-cas-requests-and-mission-data.md)
- [`OMW-CIED-ROUTE-CLEARANCE-CONVOY-DESIGN`](67-afghanistan-route-clearance-counter-ied-and-convoy-design.md)
- [`OMW-AIR-TASKING-PLAN-FOUNDATION`](88-air-tasking-plan-foundation.md)
- [`OMW-PLAN-MISSION-DEMAND-RESUPPLY-CAS`](90-mission-demand-resupply-and-cas-orchestration-concept.md)
- [`OMW-PLAN-ARMY-GROUND-RETURN-SETTLEMENT`](ground/ARMY-GROUND-RETURN-SETTLEMENT-DECISION-PREPARATION.md)
- [`OMW-ARMY-GROUND-DOMAIN-CONTRACT`](ground/ARMY-GROUND-FOUNDATION-DOMAIN-CONTRACT.md)

Verbindliche Grundgrenze:

```text
CampaignState
= strategische Autorität für Ressourcen, Entitäten, Verluste, Aufträge und persistente Zustände

MOOSE
= operative Auswahl und Ausführung

DCS GROUP / UNIT
= temporäre physische Repräsentation
```

### 2.2 Doktrinäre Strukturreferenz

Für die äußere Ground-Order-Darstellung wird das zeitgenössische US-Army-Fünf-Absatz-Format als Strukturreferenz verwendet:

```text
1. SITUATION
2. MISSION
3. EXECUTION
4. SUSTAINMENT
5. COMMAND AND SIGNAL
```

Relevante Doktrinreferenzen für den Szenariozeitraum beziehungsweise unmittelbaren Zeitraum:

- U.S. Army FM 5-0, *The Operations Process*, 26 March 2010, Change 1 dated 18 March 2011.
- U.S. Army ATTP 3-21.9, *SBCT Infantry Rifle Platoon and Squad*, 8 December 2010, als zusätzliche Referenz für WARNO-/OPORD-/FRAGO-Anwendung auf unterer taktischer Ebene.

Diese Quellen liefern die **Doktrinstruktur**, nicht einen originalen Afghanistan-OPORD für OMW. OMW behauptet ausdrücklich nicht, einen formatgetreuen historischen ISAF-/US-Army-Befehl aus 2010/2011 zu reproduzieren.

### 2.3 Tatsächlich verwendeter MOOSE-Stand

Für diese Foundation wurde die vom Projektinhaber bereitgestellte aktuelle Missionsdatei geprüft:

```text
mission artifact:
OMW_Template_v15.miz

MIZ SHA-256:
c2b57957635df36cd3f2b2532c4285b8ae65c69262252f605eb6c7625fc0aceb

embedded Moose.lua:
l10n/DEFAULT/Moose.lua

Moose.lua SHA-256:
e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915

MOOSE commit recorded in embedded source:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
```

Diese Artefaktprüfung ist eine **statische Source-Prüfung**, keine DCS-Runtime-Acceptance.

## 3. Grundentscheidung: kein Ground-ATO und kein erfundenes GTO

Die Air-Tasking-Foundation verwendet ATO-/ACO-/SPINS-Strukturen als luftstreitkraftspezifische fachliche Referenz. Ground übernimmt davon nur die gemeinsame Architekturidee:

```text
structured mission data
+ stable IDs
+ demand linkage
+ timing
+ support relationships
+ execution result
```

Die äußere Ground-Darstellung erfolgt dagegen über passende reale Führungsprodukte:

```text
OPORD
FRAGO
optional later: WARNO
mission-specific movement / convoy / fire-support products where useful
```

Nicht vorgesehen ist:

```text
invented GTO message syntax
USMTF parser for Ground
one OPORD per DCS group
one FRAGO = one MOOSE object
persistent serialization of MOOSE/DCS controller objects
```

## 4. Schichtenmodell

### 4.1 CampaignState / MissionDemand

CampaignState und MissionDemand beantworten:

- Warum besteht ein Bedarf?
- Welche strategischen Ressourcen sind verfügbar oder gebunden?
- Welche stabile Demand-ID gehört zum Auftrag?
- Welche strategischen Folgen hat das Ergebnis?

MissionDemand ist keine MOOSE-Mission und kein Ressourcenledger.

### 4.2 OPORD

Der OPORD ist ein längerlebender Operationsrahmen. Er definiert insbesondere:

- Area of Operations;
- Mission des ausgebenden Verbandes;
- Commander's Intent;
- Concept of Operations;
- Standing Tasks für Untergebene;
- allgemeine Coordinating Instructions;
- Sustainment-Konzept;
- Command Relationships.

Ein OPORD kann viele FRAGOs und viele einzelne GroundTasks überleben.

### 4.3 FRAGO

Der FRAGO ändert, präzisiert oder ergänzt den bestehenden OPORD. Typischerweise enthält er nur die geänderten Teile und kennzeichnet unveränderte Abschnitte als `NO CHANGE`.

Ein FRAGO kann mehrere GroundTasks sowie Cross-Domain-Support-Requests erzeugen.

### 4.4 GroundTask

Ein `GroundTask` ist der normalisierte, maschinenlesbare militärische Einzelauftrag innerhalb des OMW-Domainmodells.

Er ist **nicht identisch** mit einem MOOSE-`AUFTRAG`.

### 4.5 ExecutionAttempt

Ein `ExecutionAttempt` ist genau ein physischer Versuch, einen GroundTask auszuführen.

Ein GroundTask kann wegen Restart, Abbruch, Replan oder erneuter Freigabe mehrere ExecutionAttempts besitzen.

### 4.6 MOOSE Runtime

MOOSE übernimmt die physische Ausführung:

```text
AUFTRAG
-> LEGION/BRIGADE mission handling
-> ARMYGROUP
-> DCS
```

`BRIGADE` erbt in der geprüften `Moose.lua` von `LEGION`; die Missionsübergabe erfolgt über den geerbten `LEGION:AddMission(...)`-Pfad. In der geprüften Source ist **kein separat definierter `BRIGADE:AddMission`-Methodenkörper** vorhanden. Diese Unterscheidung korrigiert eine frühere verkürzte Formulierung in der Konzeptdiskussion.

## 5. OPORD Information Contract

### 5.1 Header

Geplanter strukturierter Kern:

```text
orderId
version
status
operationName
issuingHeadquartersId
issueLocationId
issuedAt
effectiveFrom
effectiveUntil
references
taskOrganizationRef
supersedes
```

Menschenlesbare View, beispielhaft:

```text
OPERATION ORDER OPORD-KUNAR-001
OPERATION MOUNTAIN WATCH

Issuing Headquarters: TF BRONCO
Place of Issue: FOB FENTY / JALALABAD
DTG: ...
Effective: ...
Time Zone Used Throughout: ZULU
References: ...
Task Organization: ...
```

Beispielwerte sind OMW-Designbeispiele und keine Behauptung eines originalen historischen Befehls.

### 5.2 Paragraph 1 – Situation

Geplanter Inhalt:

```text
Area of Interest
Area of Operations
Enemy Forces
Friendly Forces
Civil / interagency considerations where relevant
Attachments and Detachments
Terrain / weather / constraints where relevant
```

Die Situation referenziert strategische und operative Lageinformationen. Sie besitzt diese nicht als zweite Wahrheit.

```text
OPORD situation assessment
!= CampaignState enemy state
```

### 5.3 Paragraph 2 – Mission

Die Mission soll mindestens die klassische Semantik abbilden:

```text
WHO
WHAT
WHEN
WHERE
WHY
```

Beispiel:

```text
TF BRONCO conducts security and stability operations
in Kunar and Nangarhar beginning [TIME]
in order to maintain freedom of movement,
protect assigned positions and disrupt insurgent activity.
```

Der Mission Statement ist kein technischer MOOSE-Task.

### 5.4 Paragraph 3 – Execution

Geplante Unterstruktur:

```text
Commander's Intent
  Purpose
  Key Tasks
  End State

Concept of Operations
Scheme of Ground Operations / Maneuver
Fires
Reconnaissance / Intelligence
Protection
Stability / Partner Operations where relevant
Tasks to Subordinate Units
Coordinating Instructions
```

Commander's Intent soll strukturiert referenzierbare Key Tasks enthalten, zum Beispiel:

```text
MAINTAIN_FREEDOM_OF_MOVEMENT
PROTECT_KEY_INSTALLATIONS
SUSTAIN_DEPENDENT_POSITIONS
DISRUPT_INSURGENT_ACTIVITY
```

Diese Key Tasks dürfen später Demand-Erzeugung erklären, sind aber selbst kein Scheduler und kein automatischer MOOSE-Dispatcher.

### 5.5 Standing Tasks

`Tasks to Subordinate Units` des OPORD werden intern als längerfristige `StandingTask`-Beziehungen repräsentiert.

Beispiel:

```text
StandingTask:
TF Cacti -> MAINTAIN_DEPENDENT_INSTALLATIONS

GroundTask:
GND-0042 -> conduct one specific resupply convoy
```

Verbindliche Trennung:

```text
StandingTask != GroundTask
```

### 5.6 Paragraph 4 – Sustainment

Der OPORD beschreibt das Sustainment-Konzept, besitzt aber keinen Bestand.

Beispiel für die vorhandene Ground-Hierarchie:

```text
BAGRAM
-> JALALABAD / FENTY
-> JOYCE / WRIGHT / BOSTICK
-> direct dependent COP/OP according to Ground Domain Contract
```

Der direkte Parent darf im normalen Ressourcenfluss nicht übersprungen werden.

```text
OPORD describes support relationship
CampaignState owns actual quantity and availability
```

### 5.7 Paragraph 5 – Command and Signal

OMW modelliert nur funktional notwendige Command-/Control-Beziehungen.

Nicht erfunden werden:

```text
historical frequencies without source
COMSEC fills
passwords
authentication tables
unverified command nets
```

## 6. FRAGO Information Contract

### 6.1 Grundformat

Der geplante äußere FRAGO behält die fünf Paragraphen bei:

```text
FRAGMENTARY ORDER <FRAGO-ID>
TO OPORD <PARENT-OPORD-ID>

References
Time Zone Used Throughout
Task Organization

1. SITUATION
2. MISSION
3. EXECUTION
4. SUSTAINMENT
5. COMMAND AND SIGNAL

ACKNOWLEDGE
```

Unveränderte Teile werden als `NO CHANGE` ausgegeben, statt den vollständigen OPORD zu duplizieren.

### 6.2 Header-Felder

```text
fragoId
parentOrderId
version
status
issuingHeadquartersId
issuedAt
effectiveAt
references
taskOrganizationChanged
supersedes
```

### 6.3 Situation

Der FRAGO enthält nur relevante Änderungen, zum Beispiel:

```text
Enemy Forces: changed
Friendly Forces: NO CHANGE
Terrain and Weather: NO CHANGE
```

Intern werden nach Möglichkeit stabile Incident-, Assessment-, Area- oder Threat-Referenzen gespeichert statt Lageinformationen zu duplizieren.

### 6.4 Mission

Normalfall bei einem spezifischen taktischen Auftrag:

```text
2. MISSION.
NO CHANGE.
```

Nur wenn sich die Mission des adressierten Verbandes tatsächlich ändert, wird ein neuer Mission Statement eingetragen.

### 6.5 Execution

Hier liegen typischerweise die wesentlichen FRAGO-Änderungen:

```text
Commander's Intent change or NO CHANGE
Concept of Operations change
Movement / Maneuver
Fires
Protection
Tasks to Subordinate Units
Coordinating Instructions
Assessment / Completion Criteria
```

`Tasks to Subordinate Units` erzeugt einen oder mehrere `GroundTask`-Datensätze.

### 6.6 Coordinating Instructions

Geeignete strukturierte Felder:

```text
earliestStart
latestStart
desiredEnd
routeId
assemblyAreaId
releasePointId
roeProfileId
nslProfileId
minimumForce
maximumForce
supportRequestIds
holdCriteria
abortCriteria
completionCriteria
```

Diese Informationen dürfen nicht durch immer neue zusammengesetzte Task-Typen ersetzt werden.

### 6.7 Sustainment

Der FRAGO referenziert Ressourcen- und Cargo-Verpflichtungen:

```text
manifestId
resourceCommitmentId
sourceNodeId
destinationNodeId
```

Er besitzt keinen zweiten Bestand.

### 6.8 Command and Signal

Nur geänderte beziehungsweise für den Auftrag funktional relevante Beziehungen werden ausgegeben.

## 7. GroundTask Contract

Geplanter generischer Kern:

```text
taskId
parentOrderId
parentFragoId
demandId
missionDemandId

issuingAuthorityId
assignedFormationId
assignedEntityId optional

sourceNodeId
destinationNodeId
areaId
objectiveId
routeId

taskType
purpose

earliestStart
latestStart
desiredEnd
priority

requiredAssets
resourceCommitmentId
supportRequestIds

roeProfileId
formationProfileId

status
executionAttemptIds
result
```

Der Datensatz soll nur stabile IDs und Domaininformationen persistieren. MOOSE-Objektreferenzen werden nicht persistiert.

## 8. Ground-Task-Klassifikation und MOOSE-First-Mapping

Die folgende Tabelle ist eine **Planungs- und Mapping-Baseline**, kein DCS-Runtime-Nachweis.

| OMW Ground Task | Fachliche Bedeutung | Geprüfter MOOSE-Ansatz | Einordnung |
|---|---|---|---|
| `PATROL` | Präsenz-/Sicherungs-/Gebietspatrouille | `AUFTRAG:NewPATROLZONE(...)` | direkt |
| `RECON` | Raum-/Zonenaufklärung | `AUFTRAG:NewRECON(...)` | direkt |
| `OCCUPY` | Position beziehen / halten | `NewONGUARD(...)` bzw. `NewARMOREDGUARD(...)` je Asset-/Missionsprofil | direkt bis Adapter |
| `SECURE` | Raum/Stellung sichern | `NewONGUARD(...)`, `NewARMOREDGUARD(...)` oder missionsspezifisch `NewCAPTUREZONE(...)` | semantisch wählen |
| `SEIZE` | Raum gegen Widerstand nehmen | `AUFTRAG:NewCAPTUREZONE(...)` | direkt |
| `ATTACK` | Ground-Angriff gegen Ziel/Gruppe | `AUFTRAG:NewGROUNDATTACK(...)` | direkt, DCS-Verhaltensgrenze beachten |
| `DEFEND` | vorhandene Stellung verteidigen | Guard-basierte AUFTRAG-Abbildung | direkt bis Adapter |
| `ROUTE_SECURITY` | Route/MSR absichern | Kombination aus Bewegung, Patrol/Recon und Ereignislogik | zusammengesetzt; kein erfundener AUFTRAG-Typ |
| `CONVOY` | Material/Fahrzeuge entlang Route bewegen | vorhandener Ground-/Warehouse-/TM01M-Ausführungspfad, später sauberer Adapter | Sonderfall |
| `RESUPPLY` | Versorgung einer Einheit/Installation | `NewAMMOSUPPLY(...)`, `NewFUELSUPPLY(...)` soweit passend; sonst CampaignState-Transfer + Ground-Execution | teilweise direkt |
| `REARM` | Munitionsnachversorgung | `AUFTRAG:NewREARMING(...)` | direkt |
| `REINFORCE` | Kräfte an Position zuführen | Bewegung + nachfolgende Secure/Guard/Occupy-Semantik | zusammengesetzt |
| `QRF` | Bereitschaftsrolle / Reaktionskraft | Rolle, aus der konkrete GroundTasks entstehen | **kein eigener Missionstyp** |
| `WITHDRAW` | geordnete Rückverlegung | Return-/Folgemissions-Lifecycle | Lifecycle, kein erfundener AUFTRAG-Typ |
| `FIRE_SUPPORT` | Artillerieauftrag | `AUFTRAG:NewARTY(...)` | direkt |
| `BARRAGE` | Sperr-/Flächenfeuer | `AUFTRAG:NewBARRAGE(...)` | direkt |

### 8.1 GROUNDESCORT-Korrektur

Die geprüfte `AUFTRAG:NewGROUNDESCORT(...)`-Mission ist eine **Helikoptermission zum Begleiten einer Bodengruppe**. Sie ist daher nicht der Ground-Ground-Convoy-Escort-Typ.

```text
GROUND CONVOY ESCORT
!= AUFTRAG:NewGROUNDESCORT(...)
```

Eine Bodenkolonne kann stattdessen einen separaten Air-Support-Request erzeugen, der später über Air Tasking auf `NewGROUNDESCORT(...)` oder eine andere passende Luftmission abgebildet wird.

### 8.2 GROUNDATTACK-Grenze

Die aktuelle MOOSE-Implementierung behandelt Ground-Attack aufgrund von DCS-Ground-AI-Grenzen nicht wie eine präzise taktische Angriffssteuerung. OMW darf deshalb aus `GROUNDATTACK` keine Fähigkeit ableiten, exakte realweltliche Ground-Maneuver-Taktik zu erzwingen.

## 9. Tatsächlich geprüfte AUFTRAG-Funktionen

Im eingebetteten MOOSE-Stand wurden statisch nachgewiesen:

```text
AUFTRAG:NewPATROLZONE
AUFTRAG:NewRECON
AUFTRAG:NewCAPTUREZONE
AUFTRAG:NewGROUNDATTACK
AUFTRAG:NewONGUARD
AUFTRAG:NewARMOREDGUARD
AUFTRAG:NewGROUNDESCORT
AUFTRAG:NewOPSTRANSPORT
AUFTRAG:NewAMMOSUPPLY
AUFTRAG:NewFUELSUPPLY
AUFTRAG:NewREARMING
AUFTRAG:NewARTY
AUFTRAG:NewBARRAGE

AUFTRAG:SetTime
AUFTRAG:SetDuration
AUFTRAG:SetPriority
AUFTRAG:SetRequiredAssets
AUFTRAG:SetROE
AUFTRAG:SetROT
AUFTRAG:SetAlarmstate
AUFTRAG:SetFormation
AUFTRAG:SetReturnToLegion
AUFTRAG:AddConditionStart
AUFTRAG:AddConditionSuccess
AUFTRAG:AddConditionFailure

LEGION:AddMission
BRIGADE ArmyOnMission lifecycle hook
```

Nicht jede nachgewiesene Methode ist automatisch für jeden OMW-Task geeignet. Signatur, Voraussetzungen und DCS-Verhalten müssen vor produktivem Adaptercode für den konkreten Use Case erneut geprüft werden.

## 10. MOOSE Runtime Status versus OMW Domain Status

Die geprüfte `Moose.lua` besitzt für `AUFTRAG.Status`:

```text
PLANNED
QUEUED
REQUESTED
SCHEDULED
STARTED
EXECUTING
DONE
CANCELLED
SUCCESS
FAILED
```

OMW führt **keinen parallelen technischen Mission-FSM** ein.

Die persistenten OMW-Domainstatus haben eine andere Funktion und dürfen nicht 1:1 mit MOOSE gleichgesetzt werden.

### 10.1 OPORD Status

```text
DRAFT
ACTIVE
SUPERSEDED
CANCELLED
CLOSED
```

### 10.2 FRAGO Status

```text
ISSUED
EFFECTIVE
SUPERSEDED
CANCELLED
COMPLETE
```

### 10.3 GroundTask Status

Geplante Domainstatus:

```text
PLANNED
AUTHORIZED
ALLOCATED
TASKED
EXECUTING
COMPLETED
FAILED
CANCELLED
INTERRUPTED
```

Beispiele:

```text
GroundTask = TASKED
MOOSE AUFTRAG = QUEUED
```

oder nach Serverabbruch:

```text
GroundTask = INTERRUPTED
MOOSE AUFTRAG = nonexistent
```

## 11. ExecutionAttempt Contract

Ein GroundTask ist der militärische Auftrag. Ein ExecutionAttempt ist ein physischer Ausführungsversuch.

Geplanter Kern:

```text
executionId
taskId
status
resourceCommitmentId
runtimeId
startedAt
endedAt
outcome
interruptionReason
```

Beispiel:

```text
GroundTask GND-0042
  execution GND-0042-EXE-01 -> INTERRUPTED
  execution GND-0042-EXE-02 -> EXECUTING
```

Die alte physische DCS-Gruppe wird dabei nicht wiederaufgenommen. Der Auftrag kann nach Reconciliation neu ausgeführt werden.

## 12. Persistenzgrenze

Persistent beziehungsweise CampaignState-referenzierbar:

```text
OPORD
FRAGO
StandingTask
GroundTask
ExecutionAttempt metadata
MissionDemand / request relationship
resourceCommitmentId
result / history
stable IDs
```

Nicht persistent als Runtime-Objekt:

```text
MOOSE AUFTRAG object
LEGION/BRIGADE internal mission queue
ARMYGROUP object
DCS GROUP / UNIT object
current waypoint / DCS controller state
scheduler objects
MOOSE FSM object state as serialized runtime object
```

Grundsatz:

```text
GroundTask persists.
AUFTRAG does not.
```

## 13. Normaler Lifecycle

```text
CampaignState detects need
        ↓
MissionDemand / Ground Request
        ↓
OPORD authority / standing task permits action
        ↓
FRAGO issued
        ↓
GroundTask = PLANNED
        ↓
strategic feasibility / authorization
        ↓
GroundTask = AUTHORIZED
        ↓
CampaignState resource commitment
        ↓
GroundTask = ALLOCATED
        ↓
GroundOrderAdapter creates appropriate AUFTRAG
        ↓
LEGION/BRIGADE mission handling
        ↓
GroundTask = TASKED
        ↓
MOOSE physical execution
        ↓
GroundTask = EXECUTING
        ↓
result / settlement
        ↓
COMPLETED / FAILED / CANCELLED
```

`ALLOCATED` liegt bewusst vor der physischen Materialisierung. Strategische Ressourcen müssen gebunden sein, bevor MOOSE/DCS sie physisch repräsentiert.

## 14. Restart und Reconciliation

Die bereits festgelegte Ground-Settlement-Regel bleibt maßgeblich:

```text
confirmed return -> credit once
confirmed loss   -> no availability credit
active at interruption -> strategic recredit once on next startup
physical group   -> not resumed and not respawned at former position
```

Für Ground Orders folgt daraus:

| Zustand vor Restart | Restore-Behandlung |
|---|---|
| `PLANNED` | bleibt planbar |
| `AUTHORIZED` | bleibt autorisiert, Machbarkeit neu prüfen |
| `ALLOCATED` ohne bestätigte physische Ausführung | Commitment-Reconciliation erforderlich |
| `TASKED` | alter ExecutionAttempt -> `INTERRUPTED` |
| `EXECUTING` | alter ExecutionAttempt -> `INTERRUPTED` |
| `COMPLETED` | terminal, unverändert |
| `FAILED` | terminal, unverändert |
| `CANCELLED` | terminal, unverändert |
| `INTERRUPTED` | bleibt bis Replan-/Reissue-Entscheidung offen |

Nicht zulässig:

```text
restore former DCS position
respawn old group at former location
serialize/restore ARMYGROUP controller state
blindly re-add every previous AUFTRAG
```

## 15. Reissue und Replan nach Unterbrechung

Ein unterbrochener ExecutionAttempt führt nicht automatisch zur Fortsetzung.

```text
requirement still valid?
  no  -> GroundTask CANCELLED
  yes -> situation materially changed?
           no  -> new ExecutionAttempt / reissue
           yes -> replan, normally via changed/new FRAGO
```

Es wird kein irreführender physischer Status `RESUMED` benötigt.

## 16. Ergebnisvertrag

Ein bloßes `SUCCESS/FAILED` reicht für Campaign Settlement und Debrief nicht aus.

Geplanter strukturierter Result-Kern:

```text
objectiveAchieved
taskCompleted
unitsCommitted
unitsReturned
unitsLost
cargoDelivered
cargoLost
destinationReached
duration
abortReason
failureReason
```

Dadurch können unter anderem unterschieden werden:

```text
objective achieved with losses
all units survived but cargo not delivered
supporting task cancelled without invalidating main objective
```

## 17. FRAGO Completion Semantics

Ein FRAGO kann mehrere Aufgaben enthalten:

```text
FRAGO-0042
  GroundTask A: CONVOY
  GroundTask B: ROUTE_SECURITY
  Air Support Request C: optional overwatch
```

Daher wird nicht jede untergeordnete Aufgabe automatisch gleich gewichtet.

Geplante Rolle:

```text
REQUIRED
SUPPORTING
OPTIONAL
```

Ein FRAGO ist `COMPLETE`, wenn seine definierten Completion Criteria erfüllt sind. Das muss nicht bedeuten, dass jede optionale oder unterstützende Mission `SUCCESS` erreicht.

## 18. Cross-Domain-Verknüpfung

Ground und Air sollen dieselbe stabile Provenienzkette verwenden, aber unterschiedliche Führungsprodukte behalten.

Beispiel:

```text
Campaign event / MissionDemand
        ↓
FRAGO-0042
        ├── GND-0042-A CONVOY
        └── ASR-0042-A armed overwatch / escort request
                     ↓
              Air Tasking Plan
                     ↓
              MOOSE Air AUFTRAG
```

Damit bleibt ATO-artige Planung luftstreitkraftspezifisch, während Ground OPORD/FRAGO verwendet.

## 19. QRF-Grundsatz

`QRF` ist in OMW zunächst eine **Rolle / Readiness-Beziehung**, kein technischer Ground-Missionstyp.

```text
role = QRF
homeNode = <node>
readiness = AVAILABLE
```

Ein Ereignis erzeugt daraus einen konkreten Auftrag, beispielsweise:

```text
REINFORCE
SECURE
ATTACK
ROUTE_SECURITY
```

Es wird kein eigener erfundener `AUFTRAG.Type.QRF` eingeführt.

## 20. Route Security und Convoy

Route Security wird nicht auf einen erfundenen einzelnen MOOSE-Typ reduziert. Die verbindliche Route-Clearance-/C-IED-Baseline beschreibt Bewegung, Detection, Security, C2, Recovery und EOD als getrennte beziehungsweise kombinierbare Fähigkeiten.

Daraus folgt:

```text
ROUTE_SECURITY
-> movement / route plan
-> patrol / recon where appropriate
-> event-driven halt/check/response behavior
-> optional support relationships
-> return / settlement
```

Reguläre Logistikkonvois verwenden weiterhin die verbindlichen OMW-Templates aus Dokument 67. TM01M bleibt ein physischer Convoy-Ausführungsbestandteil, nicht die Architekturvorlage für den Ground Order Domain Layer.

## 21. WARNO als spätere Erweiterung

Ein `WARNO` ist fachlich sinnvoll, um Vorbereitung vor endgültiger Ausführungsfreigabe abzubilden:

```text
MissionDemand / probable operation
-> WARNO
-> preparation
-> FRAGO
-> execution authorization
```

WARNO ist **nicht Bestandteil der ersten Foundation-Pflicht**. Der erste Scope bleibt:

```text
OPORD
FRAGO
GroundTask
ExecutionAttempt
```

## 22. Menschenlesbare Views

Strukturierte Ground-Order-Daten sollen eine gemeinsame Quelle für mehrere Views bilden:

```text
structured ground-order data
    ├── commander OPORD view
    ├── FRAGO view
    ├── player task card
    ├── F10 tasking information
    ├── future kneeboard
    └── debrief / history
```

Diese Views dürfen keine zweite Auftragswahrheit erzeugen.

## 23. Beispiel: Convoy-FRAGO

Das folgende Beispiel illustriert die geplante Darstellung und ist **kein historischer Originalbefehl**:

```text
FRAGMENTARY ORDER FRAGO-KUNAR-0042
TO OPORD OPORD-KUNAR-001

1. SITUATION.

a. Enemy Forces.
Insurgent activity has been reported along the designated route.

b. Friendly Forces.
NO CHANGE.

2. MISSION.
NO CHANGE.

3. EXECUTION.

a. Commander's Intent.
NO CHANGE.

b. Concept of Operations.
A designated logistics element conducts movement from the source
installation to the supported installation using the approved route.

c. Tasks to Subordinate Units.
(1) Logistics Element: conduct convoy movement.
(2) Security Element: provide assigned security.

d. Coordinating Instructions.
Depart within the assigned time window.
Use the approved route.
Do not enter a route segment marked closed.

4. SUSTAINMENT.
Cargo and vehicle commitment according to referenced CampaignState
commitment and manifest.

5. COMMAND AND SIGNAL.
NO CHANGE.
```

## 24. Geplanter Datensatz – Beispiel

Nur als Schemaillustration, nicht als produktive Lua-API:

```lua
local GroundTask = {
  taskId = "GND-0042",
  parentOrderId = "OPORD-KUNAR-001",
  parentFragoId = "FRAGO-KUNAR-0042",
  demandId = "DEMAND-...",
  missionDemandId = "MISSION-DEMAND-...",

  issuingAuthorityId = "...",
  assignedFormationId = "...",
  sourceNodeId = "...",
  destinationNodeId = "...",

  taskType = "CONVOY",
  purpose = "RESUPPLY",
  routeId = "...",

  earliestStart = nil,
  latestStart = nil,
  desiredEnd = nil,

  resourceCommitmentId = "...",
  supportRequestIds = {},

  status = "PLANNED",
  executionAttemptIds = {},
  result = nil,
}
```

Diese Tabelle ist bewusst kein implementiertes Modul und keine genehmigte konkrete Runtime-Signatur.

## 25. Nicht Teil dieser Foundation

Nicht implementiert oder behauptet werden:

```text
automatic OPORD generator
automatic FRAGO generator
complete US Army staff-order reproduction
historically exact Afghanistan 2010/2011 OPORD text
USMTF/ADatP parser for Ground
persistent MOOSE object serialization
generic custom Ground mission FSM
custom parallel Ground dispatcher
final BLUE COMMANDER integration
final player F10 / kneeboard UI
full WARNO lifecycle
historical command-net/frequency reconstruction
DCS runtime acceptance
```

## 26. Implementierungssequenz

Vor produktivem Runtime-Code:

1. diesen Information Contract gegen aktuelle Ground- und MissionDemand-Baselines reconciliieren;
2. MOOSE-Dokumentation und die tatsächlich verwendete `Moose.lua` je konkret verwendetem AUFTRAG-Typ erneut prüfen;
3. relevante offizielle MOOSE-Demos/Tests prüfen;
4. minimale Adaptergrenze je GroundTask-Typ festlegen;
5. keine MOOSE-Funktion parallel nachbauen;
6. zuerst einen kleinen vertikalen Nachweis wählen, bevorzugt einen bereits vorhandenen Ground-Execution-Pfad;
7. Syntax-, Contract- und Restart-/Idempotenztests dokumentieren;
8. DCS-Acceptance nur für den exakt getesteten Branch-, Commit-, Missions-, Bundle-, DCS- und MOOSE-Stand vergeben.

## 27. Acceptance-Grenze

Dieses Dokument ist eine Architektur-/Informationsmodell-Foundation.

```text
validated_in_dcs: false
```

Die statische Prüfung von `OMW_Template_v15.miz` und der eingebetteten `Moose.lua` bestätigt nur das Vorhandensein der genannten Source-APIs und den geprüften Artefaktstand. Sie bestätigt **kein** noch nicht ausgeführtes Ground-Order-Runtime-Verhalten.
