---
document_id: OMW-MOOSE-VERIFIED-METHODS-STAGE-1D-P-ACCEPTANCE-4
status: ACCEPTED_TECHNICAL_BASELINE
document_class: TECHNICAL_EVIDENCE_REGISTER_SUPPLEMENT
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Stage 1D-P Acceptance-4 method-level evidence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/automatic-response-orchestration-continuation
source_commit: be8adc3ad1e2cfa6de7a25252cd8b217caeccde3
validated_in_dcs: true
acceptance_branch: agent/automatic-response-orchestration-continuation
acceptance_commit: be8adc3ad1e2cfa6de7a25252cd8b217caeccde3
acceptance_mission: OMW_Template_v20_GroundWorks.miz
acceptance_mission_sha256: 3b93f9817379ba6c66c8c02dd2142d1eda3d88090cb8fc88973d4dac45ee6b11
dcs_version: 2.9.29.27278 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
master_register_reconciliation_required: true
---

# Verified Methods Supplement – Stage 1D-P Acceptance-4

This branch-local supplement records method-level evidence to be reconciled into `docs/moose/VERIFIED-METHODS.md` before merge/readiness closure.

Pinned MOOSE:

```text
release: 2.9.18
commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Acceptance runtime:

```text
source/builder commit: be8adc3ad1e2cfa6de7a25252cd8b217caeccde3
builder: AIR-PERSONNEL-FLIGHTPATH-RETURN-ACCEPTANCE-4-1
bundle SHA-256: C2BD325AF48BF6EA08936BCA666E4460293B60CC36FB8FE0181BC5140DF9ABD3
mission: OMW_Template_v20_GroundWorks.miz
mission SHA-256: 3B93F9817379BA6C66C8C02DD2142D1EDA3D88090CB8FC88973D4DAC45EE6B11
DCS: 2.9.29.27278 MT
runtime result: PASS
```

| Method / callback | Status | Exact evidence / limitation |
|---|---|---|
| `PATHLINE:FindByName("OMW_FlightPath")` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | real DCS path resolved successfully |
| `PATHLINE:GetCoordinates()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | 84-point owner-authored path consumed; 14-point acceptance subset selected |
| `COORDINATE:HeadingTo(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | segment heading used for lane generation |
| `COORDINATE:Translate(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | 500 m lateral lane used; OMW runtime calibration uses heading `+90°` |
| `AUFTRAG:NewLANDATCOORDINATE(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | CH-47 executed physical Fortress intermediate landing and approximately 30 s dwell |
| `AUFTRAG:SetMissionEgressCoord(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | return/egress composition worked; also proves MissionDone occurs later than LANDAT task completion |
| `AUFTRAG:AssignSquadrons(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | mission bound to `SQ_US_JBAD_CH47_HEAVYLIFT` |
| `AUFTRAG:GetGroupWaypointIndex(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | used to compose corridor around mission waypoint |
| `AUFTRAG:GetGroupEgressWaypointUID(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | used to compose return corridor before mission egress |
| `AUFTRAG:GetGroupWaypointTask(flightGroup)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | used to identify the exact LANDAT task for settlement |
| `FLIGHTGROUP:AddWaypoint(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | 14 outbound and 13 return corridor waypoints installed and flown |
| `FLIGHTGROUP/OPSGROUP OnAfterTaskDone` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | matching LANDAT task completed at 4.1 m from Fortress LZ; authoritative physical delivery signal for this scope |
| `FLIGHTGROUP OnAfterMissionDone` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | observed only later after delivery; diagnostic when mission egress exists, not delivery instant |
| `FLIGHTGROUP OnAfterLanded` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | physical Jalalabad home landing confirmed before asset return |
| `OPSGROUP:Get2DDistance(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Fortress task settlement accepted at 4.1 m; acceptance radius 250 m |
| `AIRWING:AddMission(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Jalalabad AIRWING dispatched the bound CH-47 mission |
| `AIRWING OnAfterFlightOnMission` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | physical assigned flight captured before route insertion |
| `LEGION/AIRWING OnAfterLegionAssetReturned` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | observed after physical Jalalabad landing; not sufficient alone as physical RTB proof |

Rejected settlement interpretations from real runtime:

```text
second OnAfterTakeoff near Fortress
-> not reliable as mandatory delivery signal in this tested composition

MissionDone near Fortress
-> wrong when mission egress exists; event is mission-level and later

LegionAssetReturned alone
-> wrong as physical home-return proof
```

Detailed evidence:

```text
docs/moose/GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-ACCEPTANCE-4-FINAL.md
```

This supplement is branch-local `ACCEPTED_TECHNICAL_BASELINE`; repository-wide normative effect still requires merge to `main` or an explicit governance decision.