---
document_id: OMW-MOOSE-GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-FLIGHTPATH-ACCEPTANCE-2-RUNTIME-FINDINGS
status: SUPERSEDED
document_class: TECHNICAL_EVIDENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - historical Stage 1D-P Acceptance-1 through Acceptance-3 runtime findings
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
  - OMW-MOOSE-GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-ACCEPTANCE-4-FINAL
source_branch: agent/automatic-response-orchestration-continuation
source_commit: PENDING_MERGE
validated_in_dcs: true
---

# Stage 1D-P – Iterative FlightPath Runtime Findings

Dieses Dokument bewahrt die Entwicklungsbefunde aus Acceptance-1 bis Acceptance-3. Die endgültige technische Aussage steht in:

```text
docs/moose/GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-ACCEPTANCE-4-FINAL.md
```

Historisch relevante Korrekturen:

```text
Acceptance-1
-> basic MOOSE FlightPath/LANDAT path worked
-> coarse FlightPath caused visible Fortress detour
-> heading -90 degrees appeared on the wrong side
-> owner refined FlightPath; later OMW calibration uses +90 degrees

Acceptance-2
-> physical Fortress landing/dwell/departure/return worked
-> mandatory second Takeoff as delivery authority caused false negative
-> rejected as settlement signal

Acceptance-3
-> MissionDone near Fortress was attempted
-> mission egress delayed MissionDone until about 48.6 km from Fortress
-> MissionDone retained only as later mission-level diagnostic

Acceptance-4
-> matching OnAfterTaskDone for exact LANDAT task within 250 m of Fortress LZ
-> exact-once CampaignState MarkDelivered
-> MissionDemand SUCCESS
-> physical Jalalabad OnAfterLanded before LegionAssetReturned
-> PASS
```

The final accepted mission/hash/MOOSE provenance is intentionally maintained only in the Final Acceptance document.