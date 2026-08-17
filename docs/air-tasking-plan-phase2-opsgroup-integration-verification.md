---
document_id: OMW-AIR-TASKING-PLAN-PHASE2-OPSGROUP-INTEGRATION-VERIFICATION
status: DRAFT
document_class: MOOSE_CAPABILITY_VERIFICATION
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Phase-2 source review of FLIGHTGROUP and ARMYGROUP mission/lifecycle integration for Air Tasking
  - branch-local OPSGROUP mission-correlation boundary
not_authoritative_for:
  - repository-wide architecture beyond merged BINDING documents on main
  - new DCS runtime acceptance
  - final adapter field mapping before remaining Phase-2 reviews
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Air Tasking Plan Phase 2 – FLIGHTGROUP / ARMYGROUP Integration Verification

## 1. Zweck und Baseline

Diese Prüfung untersucht, wie `FLIGHTGROUP` und `ARMYGROUP` als physische Runtime-Repräsentationen an `AUFTRAG` gekoppelt werden und welche nativen MOOSE-Schnittstellen für Statusbeobachtung und Lifecycle-Korrelation vorhanden sind.

Geprüfte Baseline:

```text
mission artifact: OMW_Template_v12_groundworks.miz
mission SHA-256: 3c634370d43d57ed4788c55d991c903441cdfa57709581af61debb4105f9a078
embedded source: l10n/DEFAULT/Moose.lua
embedded Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
embedded MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
MOOSE context: develop
```

Keine neue DCS-Acceptance wird behauptet.

## 2. Gemeinsamer OPSGROUP-Unterbau

`FLIGHTGROUP` und `ARMYGROUP` verwenden den gemeinsamen `OPSGROUP`-Missionsunterbau. Damit müssen Mission Queue, current-mission tracking und die grundlegenden Mission Events nicht getrennt für Air und Ground nachgebaut werden.

Source-geprüfte öffentliche Methoden:

```text
OPSGROUP:AddMission(Mission)
OPSGROUP:GetMissionByID(id)
OPSGROUP:GetMissionByTaskID(taskid)
OPSGROUP:GetMissionCurrent()
OPSGROUP:IsOnMission(MissionUID)
```

### `AddMission(...)`

Der native Pfad:

```text
Mission:AddOpsGroup(self)
Mission:SetGroupStatus(self, SCHEDULED)
Mission:Scheduled()
missionqueue <- Mission
```

Damit ist die physische Gruppe direkt im AUFTRAG registriert und der Mission-Status wird über den MOOSE-Unterbau fortgeschrieben.

### Current mission correlation

`GetMissionCurrent()` löst die aktuelle MOOSE-Mission über die interne `currentmission`-UID auf. `IsOnMission(...)` kann allgemein oder gegen eine konkrete AUFTRAG-UID prüfen.

Für OMW gilt dennoch:

```text
AUFTRAG.auftragsnummer
= MOOSE runtime UID
!= OMW mission_id
```

Der spätere Adapter muss die Zuordnung explizit halten; die MOOSE-UID wird nicht zur persistenten OMW-Identität.

## 3. Mission Start / Execute / Done auf OPSGROUP

Source-geprüfte FSM callbacks:

```text
OPSGROUP:OnAfterMissionStart(From, Event, To, Mission)
OPSGROUP:OnAfterMissionExecute(From, Event, To, Mission)
OPSGROUP:OnAfterMissionCancel(From, Event, To, Mission)
OPSGROUP:OnAfterMissionDone(From, Event, To, Mission)
```

### MissionStart

Der native Callback setzt:

```text
self.currentmission = Mission.auftragsnummer
Mission group status = STARTED
Mission:__Started(3)
```

### MissionExecute

Der native Callback setzt:

```text
Mission group status = EXECUTING
Mission:Executing()
```

und aktiviert missionsspezifische Runtime-Optionen, soweit im AUFTRAG konfiguriert.

### MissionDone

Der native Callback setzt:

```text
Mission group status = DONE
self.currentmission = nil   [wenn dies die aktuelle Mission war]
mission waypoints removed
```

Damit existiert eine vollständige native Verbindung:

```text
OPSGROUP physical lifecycle
        ↕
AUFTRAG group status / mission status
```

Eine zweite OMW-Laufzeit-Missionsqueue ist nicht erforderlich.

## 4. FLIGHTGROUP

Source-geprüft vorhanden:

```text
FLIGHTGROUP:New(group)
```

und umfangreiche eigene Flight-Lifecycle-Events, unter anderem:

```text
ElementSpawned
ElementParking
ElementEngineOn
ElementTaxiing
ElementTakeoff
ElementAirborne
ElementLanded
ElementArrived
ElementDestroyed
ElementDead
Spawned
Parking
Taxiing
Takeoff
Airborne
Cruise
Landing
Landed
Arrived
Dead
FuelLow
FuelCritical
RTB
Refuel
Refueled
```

Für Air Tasking sind insbesondere relevant:

```text
AIRWING:OnAfterFlightOnMission(...)
OPSGROUP:OnAfterMissionStart(...)
OPSGROUP:OnAfterMissionExecute(...)
OPSGROUP:OnAfterMissionDone(...)
FLIGHTGROUP:OnAfterDead(...)
FLIGHTGROUP:OnAfterFuelLow(...)
FLIGHTGROUP:OnAfterFuelCritical(...)
FLIGHTGROUP:OnAfterRTB(...)
FLIGHTGROUP:OnAfterArrived(...)
```

Nicht alle Events müssen in den OMW-Adapter übernommen werden. Missionsart-spezifische bestehende Adapter wie AAR dürfen ihre bereits validierten Fuel-/Egress-Verträge behalten.

Der AAR-Acceptance-7-Scope bestätigt bereits praktisch Teile dieses Unterbaus (`AddMission`, FuelLow, Dead, PassingWaypoint, Egress). Diese Phase-2-Datei erweitert diesen Acceptance-Scope nicht auf andere Missionstypen.

## 5. ARMYGROUP

Source-geprüft vorhanden:

```text
ARMYGROUP:New(group)
```

und Ground-Lifecycle-/Movement-Events, unter anderem:

```text
ElementSpawned
Spawned
UpdateRoute
GotoWaypoint
Detour
OutOfAmmo
Rearm
Rearmed
RTZ
Returned
Rearming
Retreat
Retreated
EngageTarget
Disengage
FullStop
Cruise
Hit
Unsuppressed
```

Die Mission-Anbindung erfolgt wie bei FLIGHTGROUP über den gemeinsamen `OPSGROUP`-Unterbau. Zusätzlich meldet die LEGION-Schicht für BRIGADE:

```text
BRIGADE:OnAfterArmyOnMission(From, Event, To, ArmyGroup, Mission)
```

Damit ist für den Air-Tasking-/Support-Pfad auch bei späteren Ground-bezogenen Support-Beziehungen keine parallele ARMYGROUP-Mission-Engine erforderlich.

Ground-AI-Pathfinding bleibt gemäß OMW-Governance separat als unzuverlässig zu behandeln; das Vorhandensein von ARMYGROUP-Routing-Events beweist keine beliebige Wegfindungszuverlässigkeit.

## 6. Runtime-Korrelation statt strategischer Autorität

Die Source-Prüfung bestätigt folgende Grenze:

```text
CampaignState / Air Tasking Domain
= mission identity
= strategic reservation / settlement
= persistence
= command/tasking/request authority

AUFTRAG / OPSGROUP / FLIGHTGROUP / ARMYGROUP
= runtime mission object
= physical execution object
= per-group mission status
= MOOSE lifecycle events
```

Nicht zulässig:

```text
persist FLIGHTGROUP/ARMYGROUP object as campaign truth
use DCS group name as stable mission identity
infer strategic inventory directly from OPSGROUP mission queue
scan all DCS groups to reconstruct a mapping already available through MOOSE callbacks
```

## 7. Empfohlene minimale Korrelation

Für einen späteren Execution Attempt genügt voraussichtlich eine kleine Laufzeitzuordnung:

```text
OMW execution_attempt_id
    ↔ AUFTRAG runtime reference / auftragsnummer
    ↔ FLIGHTGROUP or ARMYGROUP runtime reference
```

Persistiert werden nur die OMW-IDs und fachlich erforderlichen Ergebnisdaten. MOOSE-/DCS-Objektreferenzen werden nach Neustart neu aufgebaut und nicht serialisiert.

## 8. Statusbeobachtung

Source-geprüfte native Beobachtungspunkte:

```text
GetMissionCurrent()
IsOnMission(...)
OnAfterMissionStart(...)
OnAfterMissionExecute(...)
OnAfterMissionCancel(...)
OnAfterMissionDone(...)
FlightOnMission(...)
ArmyOnMission(...)
```

Damit ist periodisches globales Polling nicht erforderlich. Ein kleiner Adapter kann event-driven arbeiten und nur für ausdrücklich begründete Sonderfälle bounded status checks einsetzen.

## 9. Ergebnis für Phase 2

Der Manifestpunkt

```text
FLIGHTGROUP / ARMYGROUP status/lifecycle integration
```

ist für den Foundation-Scope source-seitig abgeschlossen.

Ergebnis:

```text
PASS_FOR_SOURCE_REVIEW
validated_in_dcs: false
```

MOOSE bietet bereits die benötigte Mission Queue, current-mission correlation, Assignment-/Execution-/Done callbacks sowie Flight-/Army-spezifische Lifecycle-Ereignisse.

Der nächste Phase-2-Punkt bleibt:

```text
official examples for required class combinations
```

Danach folgen Authority/Allocation-Abgleich, finale Domain-to-MOOSE-Adaptergrenze und Gate-2-Bewertung.
