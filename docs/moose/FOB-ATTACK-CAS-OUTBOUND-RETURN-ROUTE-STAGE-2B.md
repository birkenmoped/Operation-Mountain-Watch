---
document_id: OMW-MOOSE-STAGE-2B-CAS-OUTBOUND-RETURN-ROUTE
status: BINDING
document_class: MOOSE_TECHNICAL_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - accepted Stage 2B CAS outbound and return valley-route lifecycle
  - mission-owned versus corridor-waypoint lifecycle for the accepted Fortress path
not_authoritative_for:
  - unrelated helicopter mission types
  - production-wide altitude policy
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: 7c40e43395788b1a7dd5e0c179264abb34834ec4
validated_in_dcs: true
---

# Stage 2B – CAS Hin- und Rückflug über `OMW_FlightPath`

Pinned framework:

```text
MOOSE 2.9.18
commit 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256 E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## Hinflug

Nach Aufbau der gruppenspezifischen AUFTRAG-Route werden die owner-authored `OMW_FlightPath`-Waypoints zwischen den letzten vorhandenen Pre-Mission-Waypoint und den CAS-Missions-Waypoint eingefügt. Für Helikopter nutzt `FLIGHTGROUP:AddWaypoint(...)` im gepinnten Stand RADIO/AGL-Waypoints.

## Rückflug

Die Reverse-Corridor-Waypoints werden nach dem CAS-Missions-Waypoint eingefügt und nicht mit der `missionUID` des CAS-Auftrags markiert. Beim Missionsabschluss entfernt MOOSE die mission-owned Waypoints; die separat eingefügten Corridor-Waypoints bleiben bestehen. Nach ihrem Abschluss folgt der normale MOOSE-RTB-/Landing-Pfad.

Erwarteter und real beobachteter Ablauf:

```text
Jalalabad
-> OMW_FlightPath outbound
-> Fortress CAS
-> threat clear / mission closure
-> reverse OMW_FlightPath
-> RTB Jalalabad
-> Landed
-> Arrived
```

Finaler Lauf:

```text
CAS_CORRIDOR_INSTALLED
corridorPoints=14
outboundWaypoints=14
returnWaypoints=13
altitudeFtAGL=500
CAS_RTB
CAS_LANDED
CAS_ARRIVED
```

Der Projektinhaber bestätigte beide Taltransits visuell. Exakte Acceptance-Provenienz steht in `../../mission/tests/fob-attack-support-demand/RESULT-2.md`.