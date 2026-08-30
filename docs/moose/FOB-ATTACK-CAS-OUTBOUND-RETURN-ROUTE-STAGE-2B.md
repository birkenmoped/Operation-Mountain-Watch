---
document_id: OMW-MOOSE-STAGE-2B-CAS-OUTBOUND-RETURN-ROUTE
status: PLANNED
document_class: MOOSE_TECHNICAL_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Stage 2B CAS outbound and return route source analysis
  - branch-local route-readiness correction before the next DCS acceptance run
not_authoritative_for:
  - DCS validation of the visible AH-64D valley route
  - production-wide helicopter routing before acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Stage 2B – CAS Hin- und Rückflug über `OMW_FlightPath`

## Anlass

Vor dem nächsten DCS-Lauf wurde der aktuelle Stage-2B-Stand erneut gegen die tatsächlich gepinnte `Moose.lua` geprüft.

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Der vorherige Lauf zeigte für die AH-64D einen direkten Hin- und Rückflug über das Gebirge. Die erneute Prüfung hatte zwei Ziele:

1. nachweisen, wann der MOOSE-Missions-Waypoint tatsächlich verfügbar ist;
2. prüfen, ob die vor dem CAS-Auftrag eingefügten Rückweg-Waypoints beim Missionsabschluss erhalten bleiben oder durch `RTB()` verworfen werden.

## MOOSE-Dokumentation

Die aktuelle MOOSE-Dokumentation weist die relevanten öffentlichen APIs aus:

```text
AUFTRAG:SetMissionIngressCoord(...)
AUFTRAG:SetMissionEgressCoord(...)
AUFTRAG:GetGroupWaypointIndex(...)
AUFTRAG:GetGroupEgressWaypointUID(...)
FLIGHTGROUP:AddWaypoint(...)
FLIGHTGROUP:OnAfterUpdateRoute(...)
FLIGHTGROUP:RTB(...)
```

`SetMissionEgressCoord(...)` definiert nur einen einzelnen Egress-Punkt. Für den vollständigen owner-authored Talverlauf bleibt deshalb die vorhandene `PATHLINE`-Geometrie mit `FLIGHTGROUP:AddWaypoint(...)` erforderlich.

In den offiziellen MOOSE-Missionssammlungen wurde für `SetMissionEgressCoord(...)` beziehungsweise einen vollständigen Hin-/Rückkorridor kein belastbarer Demonstrationsfall gefunden. Es wird daher kein nicht gefundener Demo-Präzedenzfall behauptet; für die konkrete Semantik ist die gepinnte `Moose.lua` maßgeblich.

## Route-Bereitschaft

`OPSGROUP:RouteToMission(...)` erzeugt den gruppenspezifischen Missions-Waypoint und speichert dessen UID über:

```text
mission:SetGroupWaypointIndex(self, waypoint.uid)
```

Ein Egress-Waypoint wird nur erzeugt, wenn:

```text
mission:GetMissionEgressCoord() ~= nil
```

Darum ist bei `AUFTRAG:NewCAS(...)` der Missions-Waypoint-UID das notwendige Ready-Kriterium; ein Egress-UID ist optional.

Der Corridor-Adapter darf bei noch nicht vorhandener Mission-UID nicht fehlschlagen, sondern bindet sich an den MOOSE-FSM-Callback:

```text
FLIGHTGROUP OnAfterUpdateRoute
```

und versucht die Installation nach dem MOOSE-Routenaufbau erneut.

## Gefundener Stage-2B-Vertragsfehler

Im Stand `9241af2a53d6c4a3e41def85a58acf20e393a3dd` bestand ein String-Vertragsfehler:

```text
Corridor-Adapter:
MISSION_ROUTE_UID_NOT_READY

Acceptance-Harness:
MISSION_ROUTE_UIDS_NOT_READY
```

Wenn der erste Acceptance-Aufruf vor dem MOOSE-`RouteToMission`-Abschluss erfolgte, konnte der Harness den legitimen Pending-Zustand deshalb als Fehler behandeln.

Die Korrektur vereinheitlicht den bestehenden Acceptance-Vertrag auf:

```text
MISSION_ROUTE_UIDS_NOT_READY
```

Die Architektur bleibt unverändert:

```text
FlightOnMission
-> Route noch nicht fertig: MOOSE OnAfterUpdateRoute abonnieren
-> RouteToMission erzeugt Mission-UID
-> Corridor.Install(...)
-> FLIGHTGROUP:AddWaypoint(...)
```

## Hinflug

Nach verfügbarer Mission-UID wird der `OMW_FlightPath` zwischen den letzten vorhandenen Vor-Missions-Waypoint und den CAS-Missions-Waypoint eingefügt.

Für Helikopter erzeugt `FLIGHTGROUP:AddWaypoint(...)` im gepinnten MOOSE-Stand automatisch `RADIO`-Waypoints, also AGL-orientierte Wegpunkte.

Der erwartete reale Ablauf ist:

```text
Jalalabad
-> OMW_FlightPath outbound
-> Fortress CAS mission waypoint
```

Ob DCS die AH-64D diesen Verlauf sichtbar korrekt fliegen lässt, bleibt bis zum nächsten DCS-Lauf offen.

## Rückflug – wichtige Korrektur der Analyse

Die Rückweg-Waypoints werden direkt hinter dem CAS-Missions-Waypoint eingefügt, erhalten aber **kein** `missionUID`-Feld.

Das ist für den MOOSE-Lifecycle entscheidend.

`OPSGROUP:onafterMissionDone(...)` ruft auf:

```text
_RemoveMissionWaypoints(Mission)
```

`_RemoveMissionWaypoints(...)` entfernt ausschließlich Waypoints mit:

```text
wp.missionUID == Mission.auftragsnummer
```

Damit wird beim CAS-Abschluss der eigentliche Mission-Waypoint entfernt, die separat eingefügten `OMW_FlightPath`-Rückweg-Waypoints bleiben jedoch erhalten.

Anschließend ruft MOOSE `_CheckGroupDone(...)` auf. `FLIGHTGROUP:_CheckGroupDone(...)` löst `RTB()` erst aus, wenn unter anderem der finale Waypoint passiert wurde und keine Missionen/Tasks mehr vorhanden sind.

Daraus folgt source-seitig der erwartete Ablauf:

```text
CAS mission done/cancelled
-> MOOSE removes CAS mission waypoint
-> reverse OMW_FlightPath waypoints remain
-> AH-64D flies remaining reverse corridor waypoints
-> final corridor waypoint passed
-> _CheckGroupDone()
-> RTB(Jalalabad)
-> _LandAtAirbase(...)
-> landing/holding route
```

Die zuvor geäußerte Annahme, `RTB()` würde die bereits eingefügten Rückweg-Waypoints unmittelbar beim Missionsabschluss überschreiben, war daher zu früh und ist für diesen konkreten Waypoint-Aufbau nicht durch den gepinnten Source gedeckt.

`RTB()` baut tatsächlich eine eigene Landing-/Holding-Route über `_LandAtAirbase(...)`; dieser Schritt soll hier aber erst **nach dem letzten erhaltenen Tal-Rückweg-Waypoint** eintreten.

## DCS-Grenze

Source-seitig ist damit vor dem nächsten Lauf belegt:

```text
mission UID is the required CAS route anchor
NewCAS egress UID is optional
outbound corridor waypoints are inserted before the CAS waypoint
return corridor waypoints are inserted after the CAS waypoint
return corridor waypoints are not mission-owned
MissionDone removes only mission-owned waypoints
RTB is expected only after remaining final waypoint completion
```

Noch nicht DCS-validiert sind:

```text
sichtbarer AH-64D-Hinflug vollständig über den vorgesehenen Talkorridor
sichtbarer AH-64D-Rückflug über den umgekehrten Talkorridor
korrekte AGL-/RADIO-Höhenführung im realen Afghanistan-Gelände
Übergang vom letzten Tal-Waypoint in die Jalalabad-Landing-Route
```

Status:

```text
SOURCE_VERIFIED_PENDING_DCS
```
