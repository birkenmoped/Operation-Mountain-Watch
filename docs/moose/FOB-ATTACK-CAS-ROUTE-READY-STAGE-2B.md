---
document_id: OMW-MOOSE-FOB-ATTACK-CAS-ROUTE-READY-STAGE-2B
status: BINDING
document_class: TECHNICAL_ARCHITECTURE_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 2B CAS corridor route-readiness behavior
  - MOOSE FLIGHTGROUP OnAfterUpdateRoute integration used by the accepted Fortress path
not_authoritative_for:
  - production-wide helicopter routing policy for unrelated mission types
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: 7c40e43395788b1a7dd5e0c179264abb34834ec4
validated_in_dcs: true
---

# Stage 2B – MOOSE route-ready CAS corridor

Frühere Läufe scheiterten mit:

```text
CAS_CORRIDOR_INSTALL_FAILED reason=MISSION_ROUTE_UIDS_NOT_READY
```

Die gepinnte `Moose.lua` zeigte zwei Ursachen:

```text
AIRWING FlightOnMission can occur before delayed OPSGROUP:RouteToMission(Mission, 3)
NewCAS does not guarantee a separate mission egress coordinate/UID
```

Der akzeptierte Vertrag lautet daher:

```text
mission waypoint UID = required
egress waypoint UID = optional
route not ready = defer to FLIGHTGROUP OnAfterUpdateRoute
```

Der Adapter verwendet ausschließlich öffentliche MOOSE-Waypoint-/FSM-Pfade. Kein timer-only Ready-Guessing, kein eigener DCS-Router.

Finaler DCS-Nachweis vom 30.08.2026:

```text
CAS_CORRIDOR_INSTALLED
pathline=OMW_FlightPath
corridorPoints=14
outboundWaypoints=14
returnWaypoints=13
altitudeFtAGL=500
```

Die sichtbare Hin- und Rückroute durch das Tal wurde vom Projektinhaber bestätigt. Exakte Provenienz: `../../mission/tests/fob-attack-support-demand/RESULT-2.md`.