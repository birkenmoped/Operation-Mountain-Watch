---
document_id: OMW-MOOSE-AIR-TASKING-C2-LIFECYCLE
status: DRAFT
document_class: MOOSE_INTEGRATION_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local MOOSE integration reference for Air Tasking C2, AUFTRAG, and OPSGROUP lifecycle
  - branch-local source-reviewed class and callback relationships for the Air Tasking foundation
not_authoritative_for:
  - repository-wide architecture beyond merged BINDING documents on main
  - new DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# MOOSE Air Tasking C2 / Lifecycle

## 1. Zweck

Diese Datei fasst die für die Air-Tasking-Foundation source-geprüften MOOSE-Klassen, Verantwortungsgrenzen und Lifecycle-Hooks zusammen. Sie ersetzt weder die allgemeine MOOSE-Dokumentation noch die detaillierten Phase-2-Verifikationsdokumente.

## 2. Verifikationsbaseline

```text
mission artifact: OMW_Template_v12_groundworks.miz
mission SHA-256: 3c634370d43d57ed4788c55d991c903441cdfa57709581af61debb4105f9a078
embedded source: l10n/DEFAULT/Moose.lua
MOOSE context: develop
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

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

`CHIEF` wird für diesen Pfad nicht verwendet und bleibt `REJECTED_FOR_PROJECT_USE`.

## 4. Klassenrollen

### `COMMANDER`

Source-geprüfte Rolle:

```text
operative C2 / mission queue
LEGION aggregation
native capability / asset recruitment
mission assignment / cancellation
OpsOnMission callback
```

Wichtige Methoden/Hooks im geprüften Scope:

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

`CanMission(...)` ist keine CampaignState-Verfügbarkeitsprüfung.

### `AIRWING` / `BRIGADE`

Beide sind `LEGION`-Layer mit eigener Mission Queue und Cohort-/Asset-Verwaltung.

```text
AIRWING -> SQUADRON -> FLIGHTGROUP
BRIGADE -> PLATOON -> ARMYGROUP
```

Relevante Hooks:

```text
AIRWING:OnAfterFlightOnMission(...)
BRIGADE:OnAfterArmyOnMission(...)
```

Autonome Missionsgeneratoren und Storage-/Resource-Seiteneffekte dürfen OMW-Authority nicht umgehen.

### `SQUADRON` / `PLATOON` / `COHORT`

Gemeinsamer Capability-Vertrag:

```text
COHORT:AddMissionCapability(MissionTypes, Performance)
```

OMW definiert strategische Anforderungen und Constraints; MOOSE-Cohorts liefern operative Capability-/Performance-Eignung.

### `AUFTRAG`

`AUFTRAG` ist das temporäre MOOSE-Runtime-Missionsobjekt und **nicht** der persistente OMW-Missionsdatensatz.

Für die aktuell profilierten OMW-Missionstypen:

```text
AAR     -> NewTANKER(...)
CAS     -> NewCAS(...) / NewCASENHANCED(...)
ISR     -> NewRECON(...) for physical recon execution
CSAR    -> dedicated MOOSE CSAR/AICSAR family; NewRESCUEHELO is not generic CSAR
AIRLIFT -> NewTROOPTRANSPORT / NewCARGOTRANSPORT / NewFREIGHTTRANSPORT
ESCORT  -> NewESCORT(...)
```

Wichtige negative Source-Feststellung:

```text
AUFTRAG:NewOPSTRANSPORT(...)
= implementation commented out
= not callable at this embedded baseline
```

### `OPSGROUP` / `FLIGHTGROUP` / `ARMYGROUP`

Gemeinsamer Missionsunterbau:

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

`FLIGHTGROUP` ergänzt Flight-Lifecycle wie FuelLow, RTB, Arrived und Dead. `ARMYGROUP` ergänzt Ground-/Movement-/Rearm-/Retreat-Ereignisse. Ground-Pathfinding bleibt unabhängig davon gemäß Governance unzuverlässig.

## 5. AUFTRAG-FSM

Source-geprüfte Kernzustände:

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

Wesentliche Regel:

```text
DONE != SUCCESS != FAILED
```

`DONE` ist technische Beendigung der MOOSE-Ausführung und darf nicht pauschal als erfolgreicher Kampagneneffekt interpretiert werden.

## 6. Authority-/Resource-Grenze

```text
CampaignState / OMW
= strategic availability
= reservation
= settlement
= persistence
= authority
= stable IDs

MOOSE
= runtime capability
= asset recruitment
= mission assignment
= physical execution
= lifecycle callbacks
```

Nicht zulässig:

```text
MOOSE asset count as independent strategic inventory
COHORT Ngroups as CampaignState truth
MOOSE runtime UID as OMW mission_id
DCS group name as persistent identity
parallel OMW capability/asset dispatcher
```

## 7. Minimale Adapterkorrelation

```text
execution_attempt_id
    ↔ mission_id
    ↔ AUFTRAG runtime reference / auftragsnummer
    ↔ FLIGHTGROUP or ARMYGROUP runtime reference
```

Nur OMW-IDs und fachliche Ergebnisdaten werden persistent gehalten. Runtimeobjekte werden nicht serialisiert.

## 8. Bevorzugte Event-Hooks

```text
COMMANDER:OnAfterOpsOnMission(...)
AIRWING:OnAfterFlightOnMission(...)
BRIGADE:OnAfterArmyOnMission(...)
AUFTRAG lifecycle callbacks
OPSGROUP MissionStart / MissionExecute / MissionCancel / MissionDone
```

Diese Hooks erlauben event-driven Korrelation ohne globale Frame-Scans oder eine zweite physische Mission-FSM.

## 9. Offizielle Demo-Evidenz

Geprüft auf `FlightControl-Master/MOOSE_MISSIONS_UNPACKED`, Branch `develop`:

```text
OPS - Airwing/Airwing - 010 - Fighter Wing
OPS - Brigade/Brigade - 010 - Patrol Mission
OPS - Commander/Commander - 020 - Bombing with Airwings
```

Die Beispiele bestätigen die Kombinationen:

```text
SQUADRON -> AIRWING -> AUFTRAG -> FLIGHTGROUP
PLATOON -> BRIGADE -> AUFTRAG -> ARMYGROUP
COMMANDER -> multiple AIRWINGs -> AUFTRAG -> OPSGROUP
```

## 10. DCS-Status

Diese Datei dokumentiert Source-/Official-Example-Evidence.

```text
validated_in_dcs: false
```

Bereits vorhandene praktische DCS-Nachweise, beispielsweise für den AAR-Scope, behalten ausschließlich ihre exakt dokumentierte Provenienz und werden hier nicht auf andere Missionstypen erweitert.

## 11. Detaildokumente

- `OMW-AIR-TASKING-PLAN-PHASE2-CHIEF-VERIFICATION`
- `OMW-AIR-TASKING-PLAN-PHASE2-COMMANDER-VERIFICATION`
- `OMW-AIR-TASKING-PLAN-PHASE2-AIRWING-BRIGADE-VERIFICATION`
- `OMW-AIR-TASKING-PLAN-PHASE2-SQUADRON-PLATOON-VERIFICATION`
- `OMW-AIR-TASKING-PLAN-PHASE2-AUFTRAG-CONSTRUCTION-VERIFICATION`
- `OMW-AIR-TASKING-PLAN-PHASE2-MISSION-LIFECYCLE-VERIFICATION`
- `OMW-AIR-TASKING-PLAN-PHASE2-OPSGROUP-INTEGRATION-VERIFICATION`
- `OMW-AIR-TASKING-PLAN-PHASE2-OFFICIAL-EXAMPLES-VERIFICATION`
- `OMW-AIR-TASKING-PLAN-PHASE2-AUTHORITY-ALLOCATION-VERIFICATION`
- `OMW-AIR-TASKING-PLAN-PHASE2-ADAPTER-BOUNDARY`
- `OMW-AIR-TASKING-PLAN-PHASE2-GATE-ASSESSMENT`
