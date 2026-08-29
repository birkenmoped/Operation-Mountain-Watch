---
document_id: OMW-MOOSE-CLASS-INDEX-STAGE-1D-P-ACCEPTANCE-4
status: ACCEPTED_TECHNICAL_BASELINE
document_class: MOOSE_CLASS_REGISTER_SUPPLEMENT
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Stage 1D-P Acceptance-4 class evidence supplement
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
acceptance_mission_sha256: 3B93F9817379BA6C66C8C02DD2142D1EDA3D88090CB8FC88973D4DAC45EE6B11
dcs_version: 2.9.29.27278 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
master_register_reconciliation_required: true
---

# MOOSE Class Index Supplement – Stage 1D-P Acceptance-4

This branch-local supplement records the class-level evidence that must be reconciled into `docs/moose/PROJECT-CLASS-INDEX.md` before merge/readiness closure.

Pinned MOOSE:

```text
release: 2.9.18
commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Accepted runtime provenance:

```text
source/builder commit: be8adc3ad1e2cfa6de7a25252cd8b217caeccde3
builder: AIR-PERSONNEL-FLIGHTPATH-RETURN-ACCEPTANCE-4-1
bundle SHA-256: C2BD325AF48BF6EA08936BCA666E4460293B60CC36FB8FE0181BC5140DF9ABD3
mission: OMW_Template_v20_GroundWorks.miz
mission SHA-256: 3B93F9817379BA6C66C8C02DD2142D1EDA3D88090CB8FC88973D4DAC45EE6B11
DCS: 2.9.29.27278 MT
runtime result: PASS
```

| Class | Branch-local status | Stage 1D-P Acceptance-4 evidence |
|---|---|---|
| `PATHLINE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | `OMW_FlightPath` resolved from Mission Editor line; 84 points, 14-point Jalalabad-Fortress subset used in real PASS |
| `COORDINATE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | `HeadingTo`, `Translate`, `Get2DDistance` used in tested corridor/lateral offset and LZ-distance checks |
| `AUFTRAG` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | `NewLANDATCOORDINATE`, egress, squadron binding, mission task lookup used in real PASS; MissionDone timing with egress empirically bounded |
| `FLIGHTGROUP` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | corridor waypoint insertion, initial Takeoff observation, TaskDone settlement callback, MissionDone diagnostic, physical Jalalabad Landed proof |
| `OPSGROUP` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | TaskDone lifecycle and `Get2DDistance` used in matching LANDAT task settlement |
| `AIRWING` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Jalalabad mission dispatch and FlightOnMission path used; physical home return separated from Legion return |
| `SQUADRON` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | `SQ_US_JBAD_CH47_HEAVYLIFT` explicitly bound to the acceptance mission |
| `LEGION` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | `LegionAssetReturned` observed only after physical Jalalabad landing in PASS; explicitly insufficient alone as RTB proof |

Important negative/runtime boundary:

```text
foreign FARP/AIRBASE intermediate Arrived
-> can trigger ReturnToLegion for AIRWING AI flight in pinned source
-> therefore rejected for Fortress intermediate landing in this scope
```

Detailed evidence:

```text
docs/moose/GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-ACCEPTANCE-4-FINAL.md
```

This supplement is branch-local `ACCEPTED_TECHNICAL_BASELINE`; repository-wide normative effect still requires merge to `main` or an explicit governance decision.