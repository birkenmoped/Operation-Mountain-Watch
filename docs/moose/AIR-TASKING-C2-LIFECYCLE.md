---
document_id: OMW-MOOSE-AIR-TASKING-C2-LIFECYCLE
status: DRAFT
document_class: MOOSE_INTEGRATION_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local MOOSE integration reference for Air Tasking C2, AUFTRAG, and OPSGROUP lifecycle
  - source-reviewed class and callback relationships inherited from the Air Tasking foundation
not_authoritative_for:
  - repository-wide architecture beyond BINDING documents on main
  - new DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-shared-runtime-multi-demand
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# MOOSE Air Tasking C2 / Lifecycle

## 1. Zweck

Diese Datei fasst die fuer die Air-Tasking-Foundation source-geprueften MOOSE-Klassen, Verantwortungsgrenzen und Lifecycle-Hooks zusammen. Sie ergaenzt die verbindliche Architektur aus `docs/88-air-tasking-plan-foundation.md` und ersetzt weder die MOOSE-Dokumentation noch bestehende Accepted-Baselines.

## 2. Gepinnter MOOSE-Stand

```text
MOOSE context: develop
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Die historische Phase-2-Pruefung auf `agent/air-tasking-plan-foundation` verwendete denselben gepinnten Source. Die Main-Reconciliation erfindet keine neuen MOOSE-Methoden und erweitert den nachgewiesenen DCS-Scope nicht.

## 3. Projektpfad

```text
CampaignState / MissionDemand
        ↓
Air Tasking Domain
        ↓
small OMW adapter
        ↓
COMMANDER
        ↓
AIRWING / BRIGADE
        ↓
SQUADRON / PLATOON
        ↓
AUFTRAG
        ↓
FLIGHTGROUP / ARMYGROUP
        ↓
DCS
```

`CHIEF` bleibt fuer diesen Pfad `REJECTED_FOR_PROJECT_USE`, weil dessen Strategie-/Response-Semantik mit CampaignState/MissionDemand/Air-Tasking-Autoritaet ueberlappen wuerde.

## 4. Klassenrollen

### `COMMANDER`

Source-gepruefte operative Rolle:

```text
LEGION aggregation
mission queue
native capability / asset recruitment
mission assignment / cancellation
OpsOnMission callback
```

Im historischen Source-Review wurden insbesondere folgende Methoden/Hooks gegen den gepinnten Stand geprueft:

```text
COMMANDER:New(...)
COMMANDER:AddLegion(...)
COMMANDER:AddAirwing(...)
COMMANDER:AddMission(...)
COMMANDER:CanMission(...)
COMMANDER:RecruitAssetsForMission(...)
COMMANDER:MissionAssign(...)
COMMANDER:MissionCancel(...)
COMMANDER:OnAfterOpsOnMission(...)
```

`COMMANDER:CanMission(...)` ersetzt keine CampaignState-Verfuegbarkeits- oder Ressourcenpruefung.

### `AIRWING` / `BRIGADE`

Beide bilden `LEGION`-Layer mit Cohort-/Assetverwaltung und Mission Queue:

```text
AIRWING -> SQUADRON -> FLIGHTGROUP
BRIGADE -> PLATOON -> ARMYGROUP
```

Relevante Hooks:

```text
AIRWING:OnAfterFlightOnMission(...)
BRIGADE:OnAfterArmyOnMission(...)
```

Autonome Generatoren oder interne Bestandszaehler duerfen keine zweite strategische Ressourcenautoritaet neben CampaignState erzeugen.

### `SQUADRON` / `PLATOON` / `COHORT`

Gemeinsamer Capability-Vertrag im geprueften Scope:

```text
COHORT:AddMissionCapability(MissionTypes, Performance)
```

OMW liefert strategische Anforderungen und Constraints; MOOSE liefert operative Capability-/Performance-Eignung.

### `AUFTRAG`

`AUFTRAG` ist ein temporaeres MOOSE-Runtime-Missionsobjekt und nicht der persistente OMW-Missionsdatensatz.

Historisch source-gepruefte Kandidaten fuer OMW-Profile:

```text
AAR     -> NewTANKER(...)
CAS     -> NewCAS(...) / NewCASENHANCED(...)
ISR     -> NewRECON(...)
CSAR    -> dedicated MOOSE CSAR/AICSAR family; NewRESCUEHELO is not generic CSAR
AIRLIFT -> NewTROOPTRANSPORT / NewCARGOTRANSPORT / NewFREIGHTTRANSPORT
ESCORT  -> NewESCORT(...)
```

Negative Source-Feststellung fuer den gepinnten Stand:

```text
AUFTRAG:NewOPSTRANSPORT(...)
= implementation commented out
= not callable
```

### `OPSGROUP` / `FLIGHTGROUP` / `ARMYGROUP`

Source-gepruefter gemeinsamer Missionsunterbau:

```text
OPSGROUP:AddMission(...)
OPSGROUP:GetMissionByID(...)
OPSGROUP:GetMissionByTaskID(...)
OPSGROUP:GetMissionCurrent()
OPSGROUP:IsOnMission(...)
```

Lifecycle-Hooks:

```text
OPSGROUP:OnAfterMissionStart(...)
OPSGROUP:OnAfterMissionExecute(...)
OPSGROUP:OnAfterMissionCancel(...)
OPSGROUP:OnAfterMissionDone(...)
```

Ground-Pathfinding bleibt gemaess Governance unabhaengig davon unzuverlaessig und benoetigt eigene DCS-Acceptance.

### `SCHEDULER`

Die reconcilierten AAR-Air-Tasking-Module verwenden MOOSE `SCHEDULER` fuer eine begrenzte Runtime-Beobachtung:

```text
Controller.GetStation(...)
+ SCHEDULER every 5 seconds
```

Zweck ist nur die Air-Tasking-interne Korrelation bereits vorhandener AAR-Runtimes. Der Observer ersetzt weder AAR-Lifecycle noch CampaignState-Settlement.

## 5. AUFTRAG-FSM-Grenze

Historisch source-gepruefte Kernzustaende:

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

Projektregel:

```text
MOOSE DONE != OMW mission success
```

Technische Beendigung einer MOOSE-Ausfuehrung darf nicht automatisch als erfolgreicher Campaign-Effekt verbucht werden.

## 6. Authority-/Resource-Grenze

```text
CampaignState / OMW
= strategic availability
= reservation
= settlement
= persistence
= stable IDs

MOOSE
= runtime capability
= asset recruitment
= mission assignment
= physical execution
= lifecycle callbacks
```

Nicht zulaessig:

```text
MOOSE asset count as independent strategic inventory
COHORT Ngroups as CampaignState truth
MOOSE runtime UID as OMW persistent mission ID
DCS group name as persistent identity
parallel OMW capability/asset dispatcher duplicating MOOSE
```

## 7. Stable runtime correlation

```text
MD-  canonical MissionDemand
ASR- Air Support Request
ATM- Air Tasking Mission
EXE- Execution Attempt
```

Runtime-Referenzen von `AUFTRAG`, `FLIGHTGROUP`, `ARMYGROUP` oder dem akzeptierten AAR-Controller bleiben temporaer. Sie werden nicht als persistente OMW-Identitaet serialisiert.

## 8. Shared-runtime multi-demand MOOSE-First review

### 8.1 Gepruefte Anforderung

Die bestehende AAR-Controller-Baseline kann mehrere logisch getrennte MissionDemands an dieselbe physische AAR-Station und damit an denselben bereits aktiven Tanker-Runtime anbinden. Air Tasking muss in diesem Fall fuer jeden `MD-`/`ASR-`/`ATM-`-Datensatz eine eigene nachvollziehbare `EXE-`-Korrelation behalten, ohne einen zweiten Tanker, eine zweite MOOSE-Mission oder eine zweite Ressourcenautoritaet zu erzeugen.

### 8.2 MOOSE-Dokumentation und gepinnter Source

Gegen den gepinnten Source wurden insbesondere folgende Zusammenhaenge erneut geprueft:

```text
AUFTRAG can be assigned to one or multiple OPSGROUP objects
OPSGROUP:AddMission(Mission) adds AUFTRAG objects to a mission queue
OPSGROUP stores one currentmission UID
OPSGROUP:GetMissionCurrent() returns that single current AUFTRAG
OPSGROUP:_QueueUpdate() starts a next mission only when no current mission is active,
  except urgent higher-priority replacement/cancellation behavior
```

Damit kann MOOSE mehrere AUFTRAG-Objekte verwalten und ein AUFTRAG kann mehrere physische Gruppen enthalten. Der gepruefte Stand stellt jedoch keinen eigenen Domain-Vertrag bereit, mit dem mehrere unabhaengige OMW-MissionDemand-/ASR-/ATM-Datensaetze als gleichzeitige logische Verbraucher an **einen bereits laufenden AUFTRAG/FLIGHTGROUP-Runtime** gebunden und getrennt abgeschlossen werden.

Ein AUFTRAG pro MissionDemand auf denselben Tanker zu legen waere fuer diesen Fall gerade **nicht** die MOOSE-first-Loesung: `OPSGROUP` fuehrt eine Missionsqueue mit einem `currentmission`; mehrere parallele logische OMW-Requests sind keine mehreren gleichzeitig auszufuehrenden physischen Tanker-Missionen.

### 8.3 Offizielle Beispiel-Evidenz

Die MOOSE-Dokumentation verweist fuer `AIRWING` auf die offiziellen Demo-Missionen. Die geprueften Airwing-/Commander-Muster zeigen die normale Beziehung

```text
AUFTRAG -> AIRWING/COMMANDER -> FLIGHTGROUP
```

und Tanker-Patrol-/Mission-Queues. Fuer eine projektexterne Mehrfachreferenz `MissionDemand -> bestehender identischer Tanker-Runtime` wurde in den geprueften Beispielen kein entsprechender Framework-Mechanismus gefunden.

Diese negative Feststellung gilt nur fuer den geprueften MOOSE-Stand und die geprueften Klassen; sie ist kein allgemeiner Anspruch ueber zukuenftige MOOSE-Versionen.

### 8.4 Aktuelle OMW-Luecke

Die physische AAR-Baseline ist bereits fuer mehrere Demands pro Station vorbereitet:

```text
station.demandsById[missionDemandId] = selection
SubmitDemand(...) may return ACTIVE_REUSED
EndDemand(...) retains a reserve station while other demands remain
```

Die aktuelle additive Air-Tasking-Schicht bildet dagegen nur eine Korrelation pro Runtime ab:

```text
Bridge.executionByRuntimeId[runtimeId] = { record, attempt }
Bootstrap.observedByRuntimeId[runtimeId] = { runtime, record, ... }
```

Folgen bei zwei Demands auf demselben aktiven Tanker:

```text
Demand A -> runtime AAR-xxxx -> EXE A starts
Demand B -> same runtime AAR-xxxx -> no independent EXE B correlation

runtime handoff/loss -> only the single stored record is deterministically updated
```

Zusaetzlich ist das Ende eines einzelnen Demands von der Lebensdauer der physischen Runtime zu trennen. Wenn `EndDemand(...)` den Tanker wegen weiterer Demands oder kontinuierlicher Core-Coverage beibehaelt, darf der abgeschlossene ATM-Datensatz nicht bis zum spaeteren physischen Handoff als `EXECUTING` haengen bleiben.

### 8.5 Kleinste MOOSE-kompatible Erweiterung

Die MOOSE-first-Auswertung ergibt fuer diesen Scope keinen Bedarf fuer neue physische MOOSE-Logik. Die kleinste Erweiterung bleibt eine reine OMW-Korrelationsschicht ueber dem bereits akzeptierten AAR-Runtime:

```text
one physical AAR runtime / one MOOSE tanker mission
        |
        +-- EXE for ATM A
        +-- EXE for ATM B
        +-- EXE for ATM C
```

Erforderliche Richtung fuer einen spaeteren Implementierungsschritt:

```text
runtimeId -> correlation set, not single record
observer runtimeId -> watched record set, not single record
attach every compatible active ATM to the reused runtime
loss/handoff fan out to every still-attached EXE
individual demand completion detaches/finalizes only that logical EXE when the
  controller retains the physical station for other demands/core coverage
last reserve demand completion may continue to wait for physical egress/handoff
```

Diese Erweiterung ersetzt weder `AUFTRAG`, `FLIGHTGROUP`, `SCHEDULER`, den AAR-Controller noch den Strategic Adapter. Sie fuegt keine DCS-API-Parallelsteuerung hinzu und besitzt keine strategischen Ressourcen.

### 8.6 Freigabe- und Acceptance-Grenze

Der Review dokumentiert nur die technische Luecke und die kleinste MOOSE-kompatible Adapterrichtung. Produktiver Code ist mit diesem Dokument noch nicht freigegeben oder validiert.

Vor Umsetzung sind mindestens Contract-Tests fuer folgende Faelle erforderlich:

```text
2 demands attach to same already-active runtime
1 of 2 demands completes while runtime is retained
last reserve demand completes and physical runtime egresses
shared runtime is lost and one replacement serves all still-active demands
shared runtime handoff updates all still-attached execution attempts
snapshot contains stable OMW IDs but no persisted runtimeId
```

Neue DCS-Acceptance ist erforderlich, sobald das geaenderte Verhalten in die Runtime geladen wird.

## 9. Bevorzugte Event-Hooks

Fuer spaetere allgemeine Air-Tasking-Adapter bleiben bevorzugt:

```text
COMMANDER:OnAfterOpsOnMission(...)
AIRWING:OnAfterFlightOnMission(...)
BRIGADE:OnAfterArmyOnMission(...)
AUFTRAG lifecycle callbacks
OPSGROUP MissionStart / MissionExecute / MissionCancel / MissionDone
```

Damit soll event-driven Korrelation gegen globale Frame-Scans und parallele physische FSMs bevorzugt werden.

## 10. Offizielle Beispiel-Evidenz

Im historischen Phase-2-Review wurden auf `FlightControl-Master/MOOSE_MISSIONS_UNPACKED`, Branch `develop`, unter anderem geprueft:

```text
OPS - Airwing/Airwing - 010 - Fighter Wing
OPS - Brigade/Brigade - 010 - Patrol Mission
OPS - Commander/Commander - 020 - Bombing with Airwings
```

Diese Beispiele dienten als Konstruktions-/Zusammenspiel-Evidenz; sie sind kein OMW-DCS-Acceptance-Ersatz.

## 11. DCS-Status

Dieses Dokument ist eine Source-/Example-Referenz:

```text
validated_in_dcs: false
```

Bestehende DCS-Nachweise wie AAR Acceptance-7 und `AIR-TASKING-AAR-VERTICAL-2` behalten ausschliesslich ihre exakt dokumentierte Provenienz. Sie werden hier nicht auf andere Missionstypen oder den reconcilierten aktuellen Source-Head erweitert.
