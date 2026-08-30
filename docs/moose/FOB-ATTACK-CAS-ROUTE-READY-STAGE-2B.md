---
document_id: OMW-MOOSE-FOB-ATTACK-CAS-ROUTE-READY-STAGE-2B
status: PLANNED
document_class: TECHNICAL_ARCHITECTURE_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Stage 2B CAS corridor route-readiness analysis
  - source evidence for FLIGHTGROUP OnAfterUpdateRoute corridor installation
not_authoritative_for:
  - DCS validation of the corrected corridor
  - production-wide helicopter routing policy
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Stage 2B – MOOSE route-ready CAS corridor

## Anlass

Der reale Fortress-Gesamtlauf mit dem Stage-2B-Bundle aus Commit

```text
8d900cf5f87082e79a46e9ba53602aa1e6ff6810
```

materialisierte und dispatchte den Jalalabad-AH-64D, führte ihn aber nicht über den vorgesehenen `OMW_FlightPath`-Korridor. Der Acceptance-Harness protokollierte:

```text
CAS_CORRIDOR_INSTALL_FAILED reason=MISSION_ROUTE_UIDS_NOT_READY
```

Der Lauf ist deshalb kein DCS-PASS für den CAS-Korridor.

## MOOSE-first-Prüfung

Geprüfter Framework-Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

### AIRWING / LEGION-Zeitpunkt

`LEGION:onafterOpsOnMission(...)` löst für einen AIRWING unmittelbar `FlightOnMission(OpsGroup, Mission)` aus. `AIRWING OnAfterFlightOnMission` beweist daher die Zuordnung des FLIGHTGROUP zum AUFTRAG, aber nicht, dass die zugehörige MOOSE-Missionsroute bereits vollständig aufgebaut ist.

### OPSGROUP MissionStart / RouteToMission

Der gepinnte Source zeigt:

```text
OPSGROUP:onafterMissionStart
-> Mission status STARTED
-> RouteToMission(Mission, 3)
```

`RouteToMission` wird damit verzögert ausgeführt. Erst innerhalb dieses Pfades erzeugt MOOSE die für den Korridor benötigten gruppenspezifischen Missionsanker und schreibt sie über:

```text
AUFTRAG:SetGroupWaypointIndex(...)
AUFTRAG:SetGroupEgressWaypointUID(...)
```

Vor diesem Zeitpunkt dürfen

```text
AUFTRAG:GetGroupWaypointIndex(...)
AUFTRAG:GetGroupEgressWaypointUID(...)
```

legitim `nil` liefern.

### FLIGHTGROUP UpdateRoute

Der gepinnte Source dokumentiert den öffentlichen FSM-Callback:

```lua
function FLIGHTGROUP:OnAfterUpdateRoute(From, Event, To, n, N)
```

und `FLIGHTGROUP:AddWaypoint(Coordinate, Speed, AfterWaypointWithID, Altitude, Updateroute)` als öffentlichen Einfügepfad. Für Hubschrauber erzeugt `AddWaypoint` dabei Radar-/AGL-Waypoints (`WaypointAltType.RADIO`).

Der `UpdateRoute`-Lifecycle ist daher der MOOSE-native Zeitpunkt, an den die Korridorinstallation gebunden werden kann, wenn die gruppenspezifischen AUFTRAG-Route-UIDs beim früheren `AIRWING FlightOnMission` noch fehlen.

## Korrektur

`OMW_HelicopterFlightPathCorridor` Schema 2 verwendet weiterhin ausschließlich die bereits geprüften MOOSE-APIs und die owner-authored PATHLINE-Geometrie.

```text
AIRWING FlightOnMission
-> Corridor.Resolve(OMW_FlightPath)
-> Corridor.Install(...)

route UIDs already present
-> insert corridor immediately

route UIDs not present
-> arm FLIGHTGROUP OnAfterUpdateRoute
-> let MOOSE RouteToMission build its route
-> OnAfterUpdateRoute
-> insert corridor using MOOSE AddWaypoint
```

Es wird kein eigener DCS-Router, kein `world`-Handler und kein neuer Mission-Editor-Trigger eingeführt.

Die bisherige Acceptance-Retry-Schleife bleibt nur als Beobachtungs-/Synchronisationshilfe bestehen. Die eigentliche Bereitschaft zum Einfügen wird nicht mehr ausschließlich durch geratenes Timer-Timing bestimmt, sondern durch den MOOSE-FSM-Callback.

## Deduplizierung

Nach erfolgreicher Installation wird das Ergebnis am FLIGHTGROUP für genau den betreffenden AUFTRAG zwischengespeichert. Weitere Acceptance-Aufrufe erhalten dieses Ergebnis, ohne dieselben Korridor-Waypoints erneut einzufügen.

## Unit-/CI-Gate

Der Contract-Test muss beide Pfade prüfen:

```text
1. route UIDs already ready -> immediate installation
2. route UIDs initially nil
   -> OnAfterUpdateRoute armed
   -> existing callback preserved
   -> route UIDs become available
   -> exactly one corridor installation
   -> subsequent call returns cached result
```

Der GitHub-MissionDemand-Workflow bleibt nur ein Syntax-/Contract-Gate. Er ersetzt den DCS-Test nicht.

## DCS-Gate

Der nächste vollständige Fortress-Lauf muss sichtbar und im Log nachweisen:

```text
CAS dispatch
-> AH-64D materialized
-> corridor installation succeeds
-> AH-64D follows the intended valley corridor
-> CAS executes at Fortress
```

Zusätzlich bleibt der vollständige Stage-2B-Abnahmescope bestehen: Infantry Guard, QRF, Threat Clear, CAS RTB/Landed/Arrived, nativer Ground ReturnToLegion, Returned/origin Warehouse und CampaignState-Settlement.

Der im vorigen Lauf beobachtete RED/HESCO-Pathfinding-Fall bleibt eine getrennte DCS-Ground-AI-Frage. Er wird nicht durch Teleport, Auto-Kill oder einen parallelen Präsenzscanner kaschiert.
