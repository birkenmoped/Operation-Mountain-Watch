---
document_id: OMW-MOOSE-GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-FLIGHTPATH-RETURN-SOURCE-REVIEW
status: SUPERSEDED
document_class: TECHNICAL_EVIDENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - historical Stage 1D-P FlightPath and physical-return source review
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
  - OMW-MOOSE-GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-ACCEPTANCE-4-FINAL
source_branch: agent/automatic-response-orchestration-continuation
source_commit: 99d4d88d9b9eea2026fe525ebab4e29ff60cdbfa
validated_in_dcs: true
---

# Stage 1D-P – Air PERSONNEL FlightPath / Physical Return Source Review

Dieses Source-Review dokumentiert den Entwicklungsweg zum später akzeptierten Stage-1D-P-Air-Pfad. Die maßgebliche aktuelle technische Evidenz steht in:

```text
docs/moose/GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-ACCEPTANCE-4-FINAL.md
```

Die wesentlichen, durch den späteren Acceptance-4-PASS bestätigten Befunde bleiben:

```text
- Fortress intermediate landing uses a normal LZ/coordinate, not a foreign FARP/AIRBASE.
- OMW_FlightPath is consumed through MOOSE PATHLINE.
- OMW_FlightPath is preferred, not a hard geographic constraint.
- nominal lane is 500 m right of travel direction; tested OMW calibration is heading +90 degrees.
- owner-authored path points are used for leave/rejoin; no dynamic terrain scanner is introduced.
- LANDATCOORDINATE remains the MOOSE-native physical mission.
- matching OnAfterTaskDone for the exact LANDAT task near Fortress is the accepted delivery signal.
- MissionDone with mission egress is later mission-level completion, not the Fortress delivery instant.
- second Takeoff is not mandatory delivery authority.
- physical Jalalabad OnAfterLanded must precede LegionAssetReturned for RTB proof.
```

Pinned MOOSE for the accepted scope:

```text
release: 2.9.18
commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Final accepted mission provenance is recorded only in the Final Acceptance document.