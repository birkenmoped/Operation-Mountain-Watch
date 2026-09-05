---
document_id: OMW-MOOSE-STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE
status: PLANNED
document_class: MOOSE_IMPLEMENTATION_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - focused Stage 3 AH-64 CAS route and execution acceptance
  - focused Stage 3 CH-47 slingload route acceptance
  - rejection and remediation of the 2026-09-05 focused test-fixture failure
  - focused 2026-09-05 DCS evidence for CAS success and CH-47 post-pickup lifecycle failure
  - Focus 1-3 diagnosis of the CARGOTRANSPORT paused lifecycle
  - Focus 1-4 MOOSE OnBeforeUnpauseMission correction
  - removal of IncidentParticipants as tactical completion evidence in this acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
supersedes:
superseded_by:
validated_in_dcs: false
---

# Stage 3 – Focused CAS + Air-AMMO Resupply Acceptance

## 1. Zweck und Scope

Dieser Acceptance-Pfad isoliert nur:

```text
AH-64 CAS
CH-47 external slingload resupply
```

Bewusst ausgeschlossen:

```text
Guard
QRF
ARTY
CampaignState strategic accounting
```

Ein Fehler eines Teilpfads darf den anderen Teilpfad nicht unterdrücken. Acceptance-Beobachtung darf keine künstliche Runtime-Voraussetzung erzeugen.

## 2. MOOSE-Basis

```text
MOOSE 2.9.18
commit 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA256 E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## 3. Historischer Rejected-Run 1-1

Der erste fokussierte Lauf ist `REJECTED`.

```text
Git commit: 31fb168b12dd893ed94ba71155a7edf86043e69d
BuilderVersion: STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE-1-1
Bundle SHA256: 9ABAED9388293DF31A201DE0F2C334BF384F3CCB8B3FB6B3FB9CC2DF938643D4
MizMutation: false
```

Ursache war ein vom Acceptance-Fixture erfundener Typ-Gate auf `cargo:GetID() == number`. Die gepinnte MOOSE-Implementierung verwendet eine String-ID. Zusätzlich setzte der alte gemeinsame `state.failed` beide unabhängigen Teilpfade außer Betrieb. Beides ist entfernt.

Verbindlicher Fixture-Vertrag:

```text
CAS failure      != stop RESUPPLY
RESUPPLY failure != stop CAS
observation      != invented runtime prerequisite
```

## 4. CAS – eingefrorener erfolgreicher Focus-Pfad

Der aktuelle CAS-Pfad verwendet:

```text
AUFTRAG:NewCAS
SetMissionIngressCoord
SetMissionEgressCoord
SetMissionWaypointRandomization(0)
SetEngageDetected
SetROE(ENUMS.ROE.OpenFire)
SetROT(ENUMS.ROT.PassiveDefense)
```

Acceptance-Geometrie:

```text
Jalalabad
-> OMW_FlightPath_R500 @ 500 ft AGL
-> OMW_FlightPath_WEST @ 2500 ft AGL
-> explicit ingress
-> Honaker CAS
-> explicit egress
-> WEST reverse
-> R500 reverse
-> Jalalabad
```

Die Acceptance-Freigabe erfolgt testbedingt 90 Sekunden nach dem ersten real bestätigten AH-64-Waffeneinsatz. Das ist kein Produktionskriterium.

Nicht zulässig als CAS-/Gefechtsabschluss:

```text
IncidentParticipants == 0
KNOWN_ATTACKERS_NEUTRALIZED
OPSZONE Defeated allein
Alarmzonen-Ausgang allein
```

### DCS Focus 1-2 CAS result

Der reale Lauf bestätigte:

```text
AH-64 dispatch Jalalabad
R500 outbound
WEST outbound
CAS attack
real weapon employment
acceptance release
WEST reverse
R500 reverse
Jalalabad landing
AIRWING recovery
```

Der CAS-Pfad wird in Focus 1-3/1-4 funktional nicht geändert.

## 5. CH-47 – Sollpfad

```text
MOOSE AUFTRAG:NewCARGOTRANSPORT
-> physical external slingload pickup Jalalabad
-> public MOOSE PauseMission / original task release
-> owner-approved R500 outbound handoff
-> Wright-side CargoTransportation waypoint task for same cargo/drop IDs
-> physical delivery Wright
-> original AUFTRAG Success
-> R500 reverse
-> Jalalabad
-> AIRWING recovery
```

Die eng begrenzte DCS-Task-Ausnahme ist in `STAGE3-SLINGLOAD-CORRIDOR-EXCEPTION-DECISION.md` dokumentiert und bereits vom Projektinhaber freigegeben. Es gibt keine allgemeine Native-DCS-Routingfreigabe.

## 6. DCS Focus 1-2 – CH-47 Befund

```text
Git commit: b0b862cc0a51e478ef8210dff426727b1cb3071e
BuilderVersion: STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE-1-2
Bundle SHA256: BDB15116D7761B621831BC2D7075FA0820DEA186371DED787556723BED9B019B
Mission: OMW_Template_v21_GroundWorks_RadioPresets_v1.7(2).miz
Mission SHA256: 569A22453588FBE9950BBEC78A29F7002F017AF64BB96C47B75FEC8ED096B900
DCS: 2.9.29.27468 MT
MizMutation: false
```

Bestätigt:

```text
physical pickup
cargo/drop identity preserved
PauseMission requested
source CargoTransportation task released
external slingload survived TaskCancel/TaskDone
R500 route installed and flown
```

Nicht bestätigt:

```text
physical Wright delivery
```

Der CH-47 flog später mit weiterhin angehängter Last die Rückroute.

## 7. DCS Focus 1-3 – Lifecycle-Diagnose

Provenienz:

```text
Git commit: 7063cee05307c3f3aeb959fd9c0ab896fcfb66c6
BuilderVersion: STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE-1-3
Bundle SHA256: FED684961B5DC0988A5893168849615F37515FC53611D4671E18D2E2DFE3E6C6
Mission: OMW_Template_v21_GroundWorks_RadioPresets_v1.8.miz
DCS: 2.9.29.27468 MT
MizMutation: false
```

Der reale Lauf widerlegt die Hypothese, `PauseMission()` beende den Auftrag unmittelbar.

Beobachtete Folge:

```text
BEFORE PauseMission:
  missionState=executing
  groupStatus=executing
  current mission/task present

OnAfter PauseMission:
  missionState=executing
  groupStatus=paused
  paused mission present

After original TaskDone:
  missionState=executing
  groupStatus=paused
  current mission=nil
  current task=nil
  paused mission remains

After UpdateRoute and T+1/T+2/T+3/T+5:
  missionState=executing
  groupStatus=paused
  paused mission remains

later:
  MissionDone
  mission/group status done
  paused mission no longer present
  CARGOTRANSPORT_ENDED_BEFORE_PHYSICAL_DELIVERY
```

Der am Wright-Waypoint registrierte `AddTaskWaypoint(CargoTransportation, outboundLast, ...)` ist nicht als unmittelbare Ursache anzusehen: Die gepinnte MOOSE-Implementierung bindet `TaskType.WAYPOINT` tatsächlich an den angegebenen Waypoint und MOOSE selbst verwendet denselben `AddTaskWaypoint(mission.DCStask, waypoint, ...)`-Mechanismus für Missionstasks.

## 8. Gepinnte MOOSE-Quellursache nach Focus 1-3

Die Quellprüfung von `FLIGHTGROUP:_CheckGroupDone()` zeigt:

```lua
local nMissions = self:CountRemainingMissison()
local nPaused = self:_CountPausedMissions()

if nPaused > 0 and nPaused == nMissions then
  local missionpaused = self:_GetPausedMission()
  self:UnpauseMission()
  return
end
```

Damit unpausiert MOOSE absichtlich eine Mission, wenn alle verbleibenden Missionen des FLIGHTGROUP pausiert sind.

`OPSGROUP:onafterUnpauseMission()` führt anschließend aus:

```text
mission.unpaused = true
MissionStart(mission)
remove mission ID from pausedmissions
```

Das passt exakt zum real beobachteten Muster `paused -> später pausedmissions leer -> MissionDone`, auch wenn die interne `_CheckGroupDone()`-Tracezeile im DCS-Log wegen des Verbosity-Levels nicht sichtbar war.

Status dieser Ursachenzuordnung:

```text
SOURCE_CONFIRMED_AND_RUNTIME_CONSISTENT
```

Noch nicht behauptet wird:

```text
DCS log directly proved the exact internal _CheckGroupDone call
```

## 9. Focus 1-4 – kleinste MOOSE-first Korrektur

MOOSE-FSM-Transition-Handler sind dokumentierte Extension-Points. `OnBefore<Event>` darf `false` zurückgeben und damit genau die angeforderte Transition verwerfen. `UnpauseMission` ist ein reguläres OPSGROUP-FSM-Event.

Deshalb wird während genau des owner-approved Pickup-to-Drop-Handoffs eine instanzgebundene MOOSE-FSM-Guard verwendet:

```lua
function flightGroup:OnBeforeUnpauseMission(From, Event, To, ...)
  if slingloadPickupToDropHandoffActive then
    return false
  end
  return true
end
```

Die Guard:

```text
- wird unmittelbar vor dem gewollten PauseMission aktiviert;
- blockiert nur UnpauseMission solange der physische Slingload noch auf dem genehmigten R500-Pickup-to-Drop-Pfad ist;
- verändert keine MOOSE-internen queues oder IDs;
- verändert keine Route;
- beendet keinen Auftrag;
- wird vor AUFTRAG:Success nach physisch bestätigter Wright-Ablieferung freigegeben;
- kettet einen eventuell vorhandenen OnBeforeUnpauseMission-Handler und respektiert dessen false-Rückgabe;
- lässt Nicht-CARGOTRANSPORT-Pfade unberührt.
```

Runtime-Evidenz im nächsten Lauf:

```text
LIFECYCLE label=BLOCKED_AUTO_UNPAUSE_BEFORE_PHYSICAL_DELIVERY
```

Dieser Handler ist keine künstliche Acceptance-Voraussetzung. Er benutzt genau den von MOOSE angebotenen FSM-Hook, um den verifizierten generischen Auto-Unpause-Lifecycle während einer bereits owner-approved MOOSE/DCS-Handoff-Phase zu begrenzen.

## 10. Acceptance-Isolation

Das Focus-Fixture besitzt weiterhin getrennte Zustände für:

```text
fatal/shared setup failure
CAS failure
RESUPPLY failure
```

Kein CH-47-Fehler darf den eingefrorenen CAS-Pfad unterdrücken und umgekehrt.

## 11. Dateien

```text
mission/tests/stage3-cas-resupply-focused/src/01-stage3-cas-resupply-focused-acceptance.lua
scripts/air-operations/OMW_HelicopterFlightPathCorridor.lua
scripts/air-operations/OMW_SlingloadCorridorHandoff.lua
tools/build-stage3-cas-resupply-focused-acceptance-1.ps1
tests/mission-demand/test_slingload_corridor_handoff.lua
tests/mission-demand/test_focused_cas_resupply_fixture_contract.lua
```

Generiertes Bundle:

```text
mission/tests/stage3-cas-resupply-focused/dist/OMW_Stage3_CAS_Resupply_Focused_Acceptance_1.lua
```

## 12. Nächster DCS-Nachweis

Focus 1-4 muss real zeigen:

```text
CAS regression-free
CH-47 physical pickup
PauseMission / source task release
MOOSE auto-unpause attempt is blocked by OnBeforeUnpauseMission
R500 outbound
physical Wright delivery
original AUFTRAG Success only after delivery
R500 reverse
Jalalabad landing
AIRWING recovery
```

Bis dahin:

```text
CAS isolated path: DCS PASS for Focus 1-2 scope
CH-47 physical pickup/R500: DCS PASS for Focus scope
CH-47 Wright delivery: NOT VALIDATED
full Stage 3: NOT VALIDATED
```
