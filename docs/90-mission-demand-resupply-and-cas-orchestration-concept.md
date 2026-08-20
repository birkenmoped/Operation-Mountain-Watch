---
document_id: OMW-PLAN-MISSION-DEMAND-RESUPPLY-CAS
status: PLANNED
document_class: IMPLEMENTATION_CONCEPT
owning_policy: OMW-GOV-001
authoritative_for:
  - planned MissionDemand generation for logistics resupply and immediate CAS
  - planned orchestration boundary between CampaignState and MOOSE execution
  - implementation sequence and acceptance gates for cross-domain demand handling
not_authoritative_for:
  - completed runtime implementation
  - validated DCS behavior
  - final threshold quantities or priority values
  - final player tasking UI
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/mission-demand-resupply-cas-concept
source_commit: PENDING
validated_in_dcs: false
---

# 90 – MissionDemand-Orchestrierung für Resupply und Immediate CAS

## 1. Zweck

Dieses Dokument beschreibt den geplanten nächsten Integrationslayer zwischen den bereits vorhandenen OMW-Foundations.

Die erste produktive Zielsetzung umfasst zwei exemplarische, aber architektonisch wiederverwendbare Reaktionsketten:

```text
A) RESOURCE SHORTAGE
FOB/COP stock below threshold
-> MissionDemand RESUPPLY
-> resource reservation
-> transport selection
-> MOOSE execution
-> delivery settlement

B) TROOPS IN CONTACT
BLUE convoy/group attacked
-> support request
-> MissionDemand CAS
-> air tasking allocation
-> MOOSE AUFTRAG
-> mission execution
-> result settlement
```

Beide Ketten müssen dieselbe Grundregel einhalten:

```text
CampaignState decides strategic truth and need.
MOOSE performs operational selection and execution.
DCS groups are temporary physical representations.
```

Es wird keine zweite Missions-, Ressourcen- oder Bestandsautorität neben CampaignState aufgebaut.

## 2. Bestehende Grundlagen

Bereits vorhanden und nicht neu zu implementieren:

```text
CampaignState resource quantities/reservations/credits
MissionDemand architecture contract
Ground CampaignState adapter and settlement
Ground BRIGADE / PLATOON / ARMYGROUP lifecycle evidence
AirOps AIRWING / SQUADRON foundations
Air Tasking Plan foundation
AAR MissionDemand precedent
MOOSE COMMANDER / AUFTRAG execution model
```

Die verbindliche Architektur steht insbesondere in:

```text
docs/04-campaign-state.md
docs/05-logistics.md
docs/37-campaign-architecture-and-dynamic-mission-design.md
docs/54-air-tasking-airspace-control-cas-requests-and-mission-data.md
docs/88-air-tasking-plan-foundation.md
docs/moose/GROUND-OPERATIONS.md
```

## 3. MOOSE-First-Prüfung – aktueller Konzeptstand

Geprüfter MOOSE-Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
```

Im tatsächlich verwendeten `Moose.lua` sind für diesen Scope mindestens folgende öffentliche Pfade vorhanden:

```lua
COMMANDER:AddMission(Mission)
COMMANDER:AddOpsTransport(Transport)
COMMANDER:AddBrigade(Brigade)

AUFTRAG:NewCAS(...)
AUFTRAG:NewFromTarget(Target, AUFTRAG.Type.CAS)

OPSTRANSPORT:New(CargoGroups, PickupZone, DeployZone)
OPSTRANSPORT:AddPathTransport(...)

BRIGADE / PLATOON / ARMYGROUP operational lifecycle

BASE:HandleEvent(EVENTS.Hit, ...)
SCHEDULER:New(...)
```

MOOSE selbst soll daher übernehmen:

```text
mission execution
asset selection through COMMANDER/AIRWING/BRIGADE where suitable
AUFTRAG lifecycle
OPSTRANSPORT lifecycle where suitable
DCS event dispatch through MOOSE event handling
physical group lifecycle
```

OMW-eigene Logik bleibt auf die Domänenlücke begrenzt:

```text
Why is a mission required?
Which strategic resource is required?
Which MissionDemand owns the task?
Which demand has priority?
Which strategic reservation belongs to it?
How is the MOOSE result reconciled back into CampaignState?
```

Die finale Wahl einzelner MOOSE-Konstruktoren und Callbacks ist vor Runtime-Code nochmals gegen Signatur, Events/FSMs und offizielle Beispiele zu prüfen.

## 4. Neue logische Schichten

Es sollen keine monolithischen Manager entstehen. Vorgesehen sind kleine, klar getrennte Module.

```text
CampaignState
    |
    +-- Demand Detection
    |      +-- ResourceDemandPolicy
    |      +-- TacticalSupportEventAdapter
    |
    +-- MissionDemand Registry
    |
    +-- Demand Planning
    |      +-- ResupplyPlanner
    |      +-- AirSupportRequestPlanner
    |
    +-- Execution Adapters
           +-- Ground/Transport MOOSE Adapter
           +-- Air Tasking MOOSE Adapter
```

### 4.1 `ResourceDemandPolicy`

Aufgabe:

- CampaignState-Bestände eines Ground-Nodes bewerten;
- Soll-, Warn- und kritische Schwellen anwenden;
- Hysterese und Cooldown berücksichtigen;
- bestehenden offenen Bedarf deduplizieren;
- bei echtem Bedarf genau einen `MissionDemand` erzeugen.

Keine Aufgabe:

- keine DCS-Gruppe spawnen;
- keine MOOSE-Warehouse-Bestände zur strategischen Wahrheit erklären;
- keine konkrete Route fahren;
- keine Lieferung selbst gutschreiben.

Vorgesehene Policy-Felder je Node/Ressource:

```text
resourceId
minimumLevel
preferredLevel
criticalLevel
reorderAmountMode
cooldownSeconds
priorityNormal
priorityCritical
allowedTransportModes
supplyParent / candidateOrigins
```

Die konkreten Werte sind eine spätere fachliche Entscheidung und werden nicht in diesem Konzept erfunden.

### 4.2 `MissionDemandRegistry`

CampaignState beziehungsweise dessen zuständige Domänenschicht bleibt Eigentümer des Bedarfs.

Für die beiden ersten Typen:

```text
RESUPPLY
CAS_IMMEDIATE
```

Mindestens erforderlich:

```text
id
missionType
origin
objective
target
priority
playerCapable
aiCapable
reservationState
expiresAt
successCriteria
failureConsequences
resourceReservation
status
createdReason
```

Deduplizierungsschlüssel für Resupply beispielsweise logisch:

```text
(destinationNodeId, resourceId, activeDemandClass)
```

Für CAS:

```text
(requestingEntityId, contactId / incidentId, activeSupportWindow)
```

## 5. Funktion A – automatische Resupply-Anforderung

### 5.1 Trigger

Bevorzugt event-driven nach einer strategischen Bestandsänderung.

Auslöser können sein:

```text
Consume
confirmed loss
mission reservation/release
delivery credit
restart reconciliation
scripted campaign event
```

Falls der aktuelle CampaignState-Store keinen geeigneten Resource-Changed-Hook besitzt, ist als kleinster Fallback ein langsamer MOOSE-`SCHEDULER` zulässig, beispielsweise zur periodischen Bewertung der wenigen strategischen Ground-Nodes. Kein Frame-Scan und kein hochfrequentes Polling.

### 5.2 Bedarfsermittlung

Beispiel ohne festgelegte Zahlen:

```text
available >= minimum
-> no demand

available < minimum
-> OPEN RESUPPLY demand if no equivalent active demand exists

available <= critical
-> increase demand priority
```

Die Nachschubmenge wird nicht pauschal auf `minimum - available` beschränkt. Planbar ist eine Auffüllung bis `preferredLevel`, begrenzt durch verfügbare Herkunftsbestände und Transportkapazität.

### 5.3 Herkunftsauswahl

Der Planner bewertet nur CampaignState-Kandidaten:

```text
configured supplyParent
regional hub
alternative approved supply node
```

Prüfungen:

```text
resource availability
already reserved quantity
route/transport eligibility
operational node state
threat/route state when available
```

Erst danach wird reserviert.

### 5.4 Ressourcenreservierung

Vor physischer Ausführung:

```text
MissionDemand OPEN
-> choose origin
-> ReserveResource at origin
-> attach reservation ID to MissionDemand/CargoManifest
-> transition to assigned/planned state
```

Scheitert die Materialisierung, muss die Reservierung deterministisch erhalten, verschoben oder freigegeben werden. Ein Spawn-Versuch darf keine zweite Abbuchung auslösen.

### 5.5 Transportwahl

Gemäß Logistikbaseline:

```text
ROAD_CONVOY
HELICOPTER_INTERNAL
HELICOPTER_SLING
FIXED_WING_LANDED
FIXED_WING_AIRDROP
approved emergency mode
```

Für Version 1 wird empfohlen, nur einen bereits gut verstandenen Modus produktiv zu integrieren und weitere Modi danach hinzuzufügen.

Für Ground-Road-Resupply ist MOOSE-first zu prüfen:

```text
COMMANDER / BRIGADE asset selection
OPSTRANSPORT where the cargo/carrier model fits
AUFTRAG/ARMYGROUP where a convoy itself is the mission object
validated PATHLINE/road routing patterns from TM01M as historical evidence only
```

TM01M darf nicht als Production Runtime übernommen werden; seine road-aligned Spawn- und PATHLINE-Erkenntnisse dürfen nur dort in einen kleinen Adapter einfließen, wo MOOSE keine ausreichende öffentliche Lösung bietet und die Ausnahme genehmigt wurde.

### 5.6 Abschluss

Erfolg:

```text
physical delivery confirmed
-> cargo manifest DELIVERED
-> one-time CampaignState credit at destination
-> origin reservation/transaction finalized
-> MissionDemand SUCCESS
```

Verlust:

```text
cargo/carrier loss confirmed
-> no destination credit
-> applicable resource loss finalized
-> MissionDemand FAILED or PARTIAL according to later contract
```

Abbruch ohne bestätigten Verlust:

```text
no silent disappearance
-> reservation and physical state reconciled according to settlement contract
```

## 6. Funktion B – Convoy under attack -> Immediate CAS

### 6.1 Ereigniserfassung

MOOSE-Eventhandling ist der primäre Kandidat.

Der gepinnte MOOSE-Source unterstützt `EVENTS.Hit` über `HandleEvent`. OMW soll deshalb keinen parallelen nativen `world.addEventHandler` einführen, solange der MOOSE-Pfad ausreicht.

Der Event-Adapter nimmt nur Ereignisse an, deren Ziel einer bekannten BLUE strategic entity / MissionDemand-Ausführung zugeordnet werden kann.

### 6.2 Incident statt Hit-Spam

Ein einzelner Treffer erzeugt nicht automatisch eine neue CAS-Mission.

Der Adapter aggregiert Treffer in einen stabilen Tactical Support Incident:

```text
incidentId
requestingEntityId
firstContactTime
lastContactTime
attackerReferences
location
threatEvidence
friendlyLosses
supportState
```

Deduplizierung und Cooldown verhindern:

```text
10 hits
-> 10 CAS requests
```

Stattdessen:

```text
first valid hostile contact
-> incident opened
subsequent hits
-> same incident updated
```

### 6.3 Validierung einer CAS-Anforderung

Vor Request-Erzeugung mindestens:

```text
requesting BLUE entity still exists / mission still active
hostile contact is valid
contact location is known sufficiently
no equivalent active CAS request already covers the incident
ROE/intelligence constraints permit lethal air support
```

Nicht jeder Beschuss muss CAS ergeben. Spätere Regeln können beispielsweise QRF, artillery, disengagement oder no-support als bessere Reaktion wählen.

Version 1 darf den Scope ausdrücklich auf `CAS_IMMEDIATE` für einen klaren Testfall begrenzen.

### 6.4 AIR_SUPPORT_REQUEST

Der Tactical Incident erzeugt einen Air Support Request nach Dokument 88:

```text
request_id
request_type = CAS
requesting_entity_id
priority
created_at
required_effect_or_task
area_or_target_reference
time_constraints
status
assigned_mission_ids
```

Der Request ist noch kein MOOSE-`AUFTRAG`.

### 6.5 MissionDemand / Air Tasking

```text
Incident
-> AIR_SUPPORT_REQUEST
-> MissionDemand CAS_IMMEDIATE
-> AIR_TASKING_PLAN mission
-> OMW Air Tasking Adapter
-> MOOSE AUFTRAG
```

CampaignState prüft dabei strategische Verfügbarkeit. Der Air Tasking Plan führt keine eigene Flugzeugmenge.

### 6.6 MOOSE-Ausführung

Source-geprüfter Kandidat:

```lua
local mission = AUFTRAG:NewCAS(...)
commander:AddMission(mission)
```

Alternativ kann `AUFTRAG:NewFromTarget(Target, AUFTRAG.Type.CAS)` geeignet sein, wenn ein stabiler MOOSE-`TARGET` vorhanden ist. Die genaue Wahl wird erst nach Prüfung des Zielmodells, der CAS-Zonenparameter, TargetTypes und DCS-Verhaltens festgelegt.

`COMMANDER:AddMission(...)` ist im gepinnten Source vorhanden und setzt die Mission in die Commander-Missionsqueue. Damit soll MOOSE die Auswahl geeigneter AIRWING-/SQUADRON-Ressourcen übernehmen, soweit die bereits etablierte OMW-AirOps-Foundation dies zulässt.

### 6.7 CAS-Lifecycle und Request-Abschluss

Mindestens abzubilden:

```text
REQUESTED
PLANNED / ALLOCATED
TASKED
EXECUTING
COMPLETED
FAILED / CANCELLED
```

MOOSE-FSM-Callbacks werden bevorzugt für Statusübergänge genutzt. OMW übersetzt diese in die strategischen Request-/MissionDemand-Zustände.

Der Support Request endet nicht zwingend erst mit vollständiger Vernichtung aller Gegner. Erfolgskriterien können später beispielsweise sein:

```text
convoy can continue
hostile force disengaged
threat suppressed for defined interval
requesting entity reaches safe state
```

Die konkrete Erfolgsdefinition ist eine gesonderte Gameplay-/Operationsentscheidung.

## 7. Gemeinsame Priorisierung

Resupply und CAS dürfen nicht zwei voneinander unabhängige Prioritätssysteme entwickeln.

Vorgesehen ist eine gemeinsame MissionDemand-Priorität mit typisierten Einflussfaktoren.

Beispiele:

```text
CAS:
- troops in contact
- friendly losses
- critical mission cargo
- FOB/convoy strategic importance
- threat severity

RESUPPLY:
- percentage below minimum
- critical resource type
- current operational demand
- remaining endurance
- isolation / route availability
```

Konkrete numerische Gewichte werden erst nach gesonderter Entscheidung eingeführt.

## 8. Spieler und KI – keine Doppelausführung

Der bestehende MissionDemand-Vertrag bleibt maßgeblich:

```text
OPEN
-> PLAYER_ASSIGNED
or
-> AI_ASSIGNED
-> ACTIVE
-> SUCCESS / FAILED / EXPIRED
```

Ein Spieler und eine KI dürfen denselben Bedarf nicht unabhängig erfüllen.

Für Version 1 wird empfohlen:

```text
AI-first vertical acceptance
```

und erst danach:

```text
player-capable task offer / retasking
```

So wird zuerst die strategische und technische Orchestrierung getestet, bevor UI- und Multiplayer-Zuweisung hinzukommen.

## 9. Persistenz und Server-Neustart

Persistiert werden:

```text
MissionDemand identity/status
strategic reservations
cargo manifest state
relevant incident/request identity where campaign-significant
```

Nicht persistiert werden:

```text
MOOSE object references
DCS group objects
scheduler IDs
callback closures
```

Bei Restart gilt der bereits etablierte Grundsatz:

```text
strategic reconciliation
!=
blind physical continuation
```

Für offene Ground-Commitments bleibt die vorhandene one-time Recredit-/Reconciliation-Semantik maßgeblich, bis ein allgemeiner cross-domain persistence contract beschlossen ist.

## 10. Implementierungsphasen

### Phase 0 – Contracts und MOOSE-Review

```text
1. MissionDemand schema against current CampaignState implementation verify
2. Air Support Request schema against document 88 verify
3. MOOSE COMMANDER/AUFTRAG CAS signatures and FSM callbacks verify
4. MOOSE OPSTRANSPORT/BRIGADE/ARMYGROUP candidates verify
5. official MOOSE examples/tests search
6. document gaps and any required exception before code
```

Ergebnis:

```text
No runtime change.
Source-reviewed implementation contract.
```

### Phase 1 – Demand Registry / Dedupe

```text
Create/query/update MissionDemand
stable IDs
state transitions
duplicate suppression
expiration/cooldown
resource reservation binding
```

Testbar ohne DCS durch Lua/unit-level tests where available.

### Phase 2 – Resupply Demand Detection

```text
resource policy
threshold crossing
hysteresis
dedupe
origin candidate selection
reservation
```

Noch keine physische Mission erforderlich.

### Phase 3 – One Resupply Execution Path

Erster vertikaler Pfad, bewusst nur ein Transportmodus und eine Route/Node-Paarung:

```text
shortage
-> MissionDemand
-> reservation
-> MOOSE execution
-> physical delivery/loss
-> settlement
```

DCS Acceptance erforderlich.

### Phase 4 – Tactical Incident Adapter

```text
MOOSE EVENTS.Hit
-> known BLUE mission/entity
-> incident aggregation
-> dedupe/cooldown
-> AIR_SUPPORT_REQUEST
```

Noch keine automatische CAS-Ausführung nötig; Request-Erzeugung isoliert prüfen.

### Phase 5 – Immediate CAS AI Vertical Slice

```text
valid incident
-> CAS MissionDemand
-> Air Tasking Mission
-> AUFTRAG:NewCAS
-> COMMANDER:AddMission
-> eligible AIRWING/SQUADRON
-> execution
-> request result
```

DCS Acceptance erforderlich.

### Phase 6 – Cross-domain priority and cancellation

Testfälle:

```text
convoy destroyed before CAS launch
threat disappears
no aircraft available
resupply origin depleted
route unavailable
mission expires
mission cancelled after reservation
partial delivery
```

### Phase 7 – Player-capable tasking

Erst nach stabiler AI-Vertikalkette:

```text
player offer
assignment lock
AI fallback
retask/cancel
multiplayer synchronization
```

## 11. Vorgesehene Modulgrenzen

Namen sind Arbeitsnamen, keine bereits implementierten Dateien:

```text
scripts/campaign/OMW_MissionDemandRegistry.lua
scripts/campaign/OMW_ResourceDemandPolicy.lua
scripts/logistics/OMW_ResupplyPlanner.lua
scripts/logistics/OMW_ResupplyExecutionAdapter.lua
scripts/operations/OMW_TacticalSupportIncident.lua
scripts/air-operations/OMW_AirSupportRequestPlanner.lua
scripts/air-operations/OMW_AirTaskingExecutionAdapter.lua
```

Die tatsächliche Dateistruktur ist vor Implementierung gegen bestehende Module zu reconciliieren. Bereits vorhandene Funktionen werden nicht dupliziert.

## 12. Logging

Jeder Übergang muss stabile IDs enthalten.

Beispielstruktur:

```text
[OMW][MissionDemand] id=... type=RESUPPLY state=OPEN reason=STOCK_BELOW_MINIMUM
[OMW][Resupply] demandId=... origin=... destination=... resource=... reserved=...
[OMW][SupportIncident] incidentId=... entityId=... state=OPEN
[OMW][AirSupport] requestId=... incidentId=... type=CAS priority=...
[OMW][AirTasking] missionId=... requestId=... state=TASKED
```

Keine DCS-Gruppennamen als alleinige strategische Identität.

## 13. Acceptance-Matrix

### Resupply

```text
R1 stock above threshold -> no demand
R2 threshold crossing -> exactly one demand
R3 repeated evaluation -> no duplicate demand
R4 origin insufficient -> no invalid reservation/spawn
R5 successful delivery -> exactly-once destination credit
R6 convoy loss -> no destination credit
R7 cancellation -> reservation reconciled
R8 restart with open commitment -> documented reconciliation only
```

### CAS

```text
C1 unrelated hit -> no request
C2 BLUE known convoy hit -> one incident
C3 repeated hits -> same incident, no request storm
C4 valid incident -> one AIR_SUPPORT_REQUEST / MissionDemand
C5 no eligible aircraft -> demand remains/terminates according policy, no fake mission
C6 eligible aircraft -> AUFTRAG assigned through MOOSE
C7 convoy destroyed before launch -> cancellation/replan
C8 CAS completes -> request and MissionDemand settled once
C9 multiplayer/player assignment later -> no duplicate AI execution
```

## 14. Nicht in Version 1

```text
full theater-wide optimizer
real-world JTAR message generator
complete ATO cycle simulation
automatic selection among every logistics mode
complex FAC/JTAC radio procedure simulation
artillery/QRF/CAS effect arbitration
multi-echelon supply forecasting
ML/heuristic mission selection
frame-level tactical scanning
```

## 15. Zielbild

Nach Abschluss der beiden vertikalen Pfade soll OMW erstmals durchgehend reagieren können:

```text
Campaign condition/event
-> authoritative MissionDemand
-> strategic reservation
-> operational planning
-> MOOSE execution
-> observed outcome
-> CampaignState settlement
```

Damit wird die bestehende Foundation nicht ersetzt, sondern erstmals domänenübergreifend orchestriert.
