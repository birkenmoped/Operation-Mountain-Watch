---
document_id: OMW-MOOSE-STAGE3-BUILD-1-18-SLINGLOAD-ACTIVE-TASK-ROUTE-HANDOFF
status: PLANNED
document_class: MOOSE_IMPLEMENTATION_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 3 Build 1-17 CH-47 route failure diagnosis
  - Stage 3 Build 1-18 CARGOTRANSPORT task-release remediation
  - isolated validation gate before another full Stage 3 DCS run
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
supersedes:
superseded_by:
validated_in_dcs: false
---

# Stage 3 Build 1-18 – Slingload Active-Task Route Handoff

## 1. Status

Build 1-17 ist für den CH-47-Routenpfad ein realer DCS-Fehltest.

```text
status: FAIL
validated_in_dcs: false
```

Reale lokale Build-Provenienz des getesteten Bundles:

```text
GitCommit: 0a453afac88bd3d7a572ff94484d77ed2531a519
BuilderVersion: STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-17
GeneratedUtc: 2026-09-05T10:44:36Z
MOOSECommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
MooseLuaSHA256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
Bundle SHA256: 44592C08332383AFE63A3CC7924171FEAA69EABF7745B6EBF07A94845522693F
Independent SHA256: 44592C08332383AFE63A3CC7924171FEAA69EABF7745B6EBF07A94845522693F
MizMutation: false
```

Owner-Beobachtung im realen DCS-Lauf:

```text
CH-47 nimmt den Slingload auf,
fliegt danach aber weiterhin direkte Luftlinie statt OMW_FlightPath_R500.
```

Diese Beobachtung reicht aus, um Build 1-17 für den Air-AMMO-Routenpfad als `FAIL` zu behandeln. Ein weiterer vollständiger Stage-3-Lauf mit demselben Mechanismus ist nicht zulässig.

## 2. Nachträglich nachgewiesene Ursache

Build 1-17 installierte nach bestätigtem Pickup zusätzliche FLIGHTGROUP-Waypoints und rief anschließend:

```lua
flightGroup:UpdateRoute()
```

Der zu diesem Zeitpunkt laufende MOOSE-`AUFTRAG:NewCARGOTRANSPORT` besaß jedoch weiterhin einen aktuellen Task.

Die tatsächlich verwendete gepinnte `Moose.lua` wurde nach dem Fehltest erneut gegen diesen exakten Pfad geprüft. `FLIGHTGROUP:onbeforeUpdateRoute` verweigert einen normalen Route-Update, solange ein nicht ausdrücklich zugelassener aktueller Task vorhanden ist (`taskcurrent > 0`). `CARGOTRANSPORT` gehört nicht zur dort zugelassenen Sondermenge.

Damit war der Build-1-17-Ansatz logisch widersprüchlich:

```text
CARGOTRANSPORT task still current
-> OMW adds R500 waypoints
-> OMW calls FLIGHTGROUP:UpdateRoute()
-> pinned MOOSE rejects route update while task is current
-> active CargoTransportation keeps its direct route
-> CH-47 flies direct line
```

Das ist kein ungeklärtes DCS-Pathfinding-Phänomen, sondern ein OMW-Implementierungs- und Reviewfehler.

## 3. Fehler im Offline-Regressionstest

Der bisherige Test

```text
tests/mission-demand/test_slingload_corridor_handoff.lua
```

mockte `UpdateRoute()` lediglich als erfolgreichen Zähleraufruf. Er modellierte die reale MOOSE-Vorbedingung `taskcurrent > 0` nicht.

Dadurch konnte der Test grün werden, obwohl die tatsächlich verwendete `Moose.lua` denselben Route-Update zur Laufzeit ablehnt.

Diese Lücke war besonders schwerwiegend, weil der Test gerade dazu dienen sollte, weitere lange DCS-Fehltests zu verhindern.

## 4. MOOSE-first Korrektur für Build 1-18

Es wird kein zusätzlicher Native-DCS-Routencontroller eingeführt.

Nach physisch bestätigtem Pickup gilt jetzt:

```text
MOOSE AUFTRAG:CARGOTRANSPORT active
-> FLIGHTGROUP:GetTaskCurrent()
-> FLIGHTGROUP:GetMissionCurrent()
-> public MOOSE PauseMission()
-> MOOSE TaskCancel / TaskDone lifecycle
-> erst wenn kein aktueller Task mehr besteht:
     GetWaypointCurrentUID
     AddWaypoint für R500 outbound
     AddTaskWaypoint mit demselben DCS CargoTransportation task am Wright-seitigen Exit
     AddWaypoint für R500 reverse
     UpdateRoute exactly once
-> physical delivery
-> AUFTRAG:Success()
-> normal AIRWING/LEGION recovery
```

Verwendete öffentliche MOOSE-Pfade wurden in der tatsächlich verwendeten `Moose.lua` geprüft:

```text
OPSGROUP/FLIGHTGROUP:GetTaskCurrent
OPSGROUP/FLIGHTGROUP:GetMissionCurrent
OPSGROUP/FLIGHTGROUP:PauseMission
OPSGROUP TaskCancel / TaskDone lifecycle
FLIGHTGROUP:GetWaypointCurrentUID
FLIGHTGROUP:AddWaypoint
FLIGHTGROUP:AddTaskWaypoint
FLIGHTGROUP:UpdateRoute
AUFTRAG:Success
```

Die bereits owner-approved enge Ausnahme bleibt auf genau einen DCS-`CargoTransportation`-Waypoint-Task für dieselbe Cargo-/Drop-Identität begrenzt.

Nicht hinzugefügt werden:

```text
Controller:setTask route ownership
coalition.addGroup
coalition.addStaticObject
teleport
parallel AIRWING implementation
parallel CampaignState authority
```

## 5. Neue Regression gegen den konkreten Fehler

Der Offline-Test modelliert jetzt ausdrücklich einen laufenden CARGOTRANSPORT-Task.

Sein `UpdateRoute()` schlägt absichtlich fehl, falls der simulierte aktuelle Task noch besteht. Geprüft wird:

```text
first handoff attempt:
  current CARGOTRANSPORT task exists
  -> PauseMission requested exactly once
  -> zero UpdateRoute calls

retry while task still current:
  -> wait
  -> no second PauseMission
  -> zero UpdateRoute calls

simulated MOOSE TaskDone:
  current task cleared
  -> route handoff succeeds
  -> UpdateRoute exactly once
  -> outbound R500 waypoints present
  -> same CargoTransportation groupId/zoneId re-issued at route exit
  -> return route present
```

Der Shared-Corridor-Wrapper übersetzt die beiden temporären Task-Release-Zustände in den bereits vorhandenen, begrenzten `MISSION_ROUTE_UIDS_NOT_READY`-Retryvertrag. Es wird kein permanenter Scheduler eingeführt.

## 6. DCS-Restunsicherheit

Offline und aus MOOSE-Source beweisbar ist:

```text
Build 1-17 UpdateRoute was requested while MOOSE had a current disallowed task.
Pinned MOOSE can reject that route update.
Build 1-18 waits for public MOOSE task release before UpdateRoute.
```

Nicht offline beweisbar ist:

```text
ob DCS den bereits physisch aufgenommenen externen Slingload während
PauseMission -> TaskCancel -> TaskDone unverändert am CH-47 belässt,
und ob der danach neu gesetzte R500-Weg tatsächlich physisch abgeflogen wird.
```

Dieser Punkt benötigt einen DCS-Test.

## 7. Geänderte Testreihenfolge

Nach den wiederholten langen Fehltests wird nicht erneut sofort die komplette Honaker/Wright/ARTY/CAS/CH-47-Kette gestartet.

Verbindliche Reihenfolge für diesen Fehlerpfad:

```text
1. Source-/MOOSE-Prüfung
2. Regression mit realer MOOSE-UpdateRoute-Vorbedingung
3. CI
4. lokaler Build + unabhängiger Hash
5. isolierter CH-47-Test:
     pickup -> MOOSE task release -> R500 outbound -> Wright delivery -> R500 reverse -> Jalalabad
6. erst nach erfolgreichem isoliertem Test wieder vollständiger Stage-3-Acceptance-Lauf
```

Ein isolierter Test darf nur den CH-47-/CARGOTRANSPORT-/R500-Pfad enthalten und darf keine erneute 30-Minuten-Gesamtmission erforderlich machen.

## 8. Builder

Der vollständige Stage-3-Builder wird ab dieser Korrektur als

```text
STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-18
```

geführt.

Build 1-18 ist bis zu realer DCS-Verifikation weiterhin ausschließlich:

```text
PLANNED
validated_in_dcs: false
```
