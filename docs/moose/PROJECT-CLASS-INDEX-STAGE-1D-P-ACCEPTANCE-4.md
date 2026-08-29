---
document_id: OMW-MOOSE-CLASS-INDEX-STAGE-1D-P-ACCEPTANCE-4
status: DRAFT
document_class: MOOSE_CLASS_REGISTER_SUPPLEMENT
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Stage 1D-P Acceptance-4 class evidence supplement
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/automatic-response-orchestration-continuation
validated_in_dcs: true
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
docs/moose/GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-ACCEPTANCE-4-RUNTIME-RESULT.md
```

Formal `ACCEPTED_TECHNICAL_BASELINE` promotion remains blocked only by the missing SHA-256 of the exact tested `.miz`.
