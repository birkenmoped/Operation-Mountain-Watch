---
document_id: OMW-MOOSE-CLASS-INDEX-STAGE-2-ACCEPTANCE-2
status: BINDING
document_class: MOOSE_CLASS_REGISTER_ADDENDUM
owning_policy: OMW-GOV-001
authoritative_for:
  - accepted Stage 2B Fortress MOOSE class and lifecycle evidence
  - CAS route-ready and Ground return semantics used by the accepted Fortress path
not_authoritative_for:
  - unrelated installations or mission types
  - production-wide QRF sizing doctrine
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: 7c40e43395788b1a7dd5e0c179264abb34834ec4
validated_in_dcs: true
---

# Stage 2 Acceptance 2 – MOOSE class evidence

Pinned framework:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## Accepted Stage-2B paths

| Klasse/Pfad | Accepted Fortress use |
|---|---|
| `OPSZONE OnAfterAttacked` | RED Ground threat qualification |
| `OPSZONE OnAfterDefeated` | Threat-clear signal |
| `AUFTRAG:NewCAS` | Jalalabad AH-64D CAS mission |
| `AIRWING:AddMission` / `OnAfterFlightOnMission` | CAS dispatch and real FLIGHTGROUP evidence |
| `FLIGHTGROUP OnAfterUpdateRoute` | deferred corridor install after MOOSE route creation |
| `FLIGHTGROUP:AddWaypoint` | owner-authored outbound/reverse `OMW_FlightPath` insertion |
| `AUFTRAG:Cancel` | CAS closure after Threat Clear |
| `FLIGHTGROUP OnAfterRTB` / `OnAfterLanded` / `OnAfterArrived` | Jalalabad recovery lifecycle |
| `AUFTRAG:NewONGUARD` + `SetEngageDetected` | active-capable Fortress Guard configuration |
| `AUFTRAG:NewGROUNDATTACK` | one QRF mission per assigned RED group |
| `PLATOON:New(..., Ngroups, ...)` | multi-asset QRF acceptance pool |
| `COHORT/PLATOON:CountAssets` | physical availability bound |
| `OPSGROUP:SetReturnToLegion` default true | native origin return semantics |
| `ARMYGROUP:RTZ` / `Returned` | native Ground return lifecycle used by QRFs |
| `OPSGROUP:GetNelements` | survivor/casualty settlement evidence |
| `PATHLINE:FindByName` / `GetCoordinates` | owner-authored `OMW_FlightPath` geometry |

## Route-readiness finding

`AIRWING OnAfterFlightOnMission` may occur before delayed `OPSGROUP:RouteToMission(Mission, 3)`. Therefore Stage 2B uses `FLIGHTGROUP OnAfterUpdateRoute` when the group mission waypoint UID is not yet available.

`NewCAS` does not guarantee an egress UID. Accepted readiness contract:

```text
mission waypoint UID required
egress UID optional
```

## Ground return finding

Normal Ground assets retain their origin Legion and homezone. The accepted QRF path required no explicit OMW RTZ and no `SetReturnToLegion(false)`:

```text
MissionDone
-> native ReturnToLegion
-> origin spawnzone/homezone
-> Returned
-> origin Warehouse AddAsset
```

All three final-run QRFs reached `QRF_RETURNED_ORIGIN` at `WH_BLUE_GND_FORTRESS`.

## Acceptance boundary

Final DCS PASS provenance is recorded in `../../mission/tests/fob-attack-support-demand/RESULT-2.md`. Guard `Returned` was not observed before shutdown and remains a documented accepted limitation; no broader Ground-AI pathfinding claim is made.