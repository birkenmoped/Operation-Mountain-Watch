---
document_id: OMW-MOOSE-GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-SOURCE-REVIEW
status: SUPERSEDED
document_class: TECHNICAL_EVIDENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - historical record of the initial Stage 1D-P source review
not_authoritative_for:
  - current Air PERSONNEL delivery settlement
  - current physical return proof
  - current Fortress LZ representation
  - current OMW_FlightPath offset calibration
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
  - OMW-MOOSE-GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-ACCEPTANCE-4-FINAL
source_branch: agent/automatic-response-orchestration-continuation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Stage 1D-P – Initial PERSONNEL Ground/Air Source Review

Dieses Dokument bleibt als historischer Entwicklungsnachweis erhalten, ist aber für den Air-Pfad **SUPERSEDED**.

Weiterhin gültige fachliche Entscheidungen:

```text
GROUND_PERSONNEL = transferable strategic CampaignState headcount
reorder trigger = strictly below 80% target
exactly 80% = no demand
resupply quantity = refill to 100%
ordinary PERSONNEL resupply != physical Infantry GROUP transport
TROOPTRANSPORT is not used for meta-PERSONNEL resupply
CampaignState remains sole strategic resource authority
Jalalabad CH-47 remains a Jalalabad AIRWING/SQUADRON asset
no hard Ground/Air travel timeout
```

Durch spätere reale DCS-Läufe korrigierte Annahmen:

```text
Fortress Invisible FARP as intermediate landing
-> rejected for this AIRWING scope

LegionAssetReturned as physical home-return proof
-> rejected alone; physical Jalalabad OnAfterLanded must precede it

MissionDone near Fortress as delivery instant with mission egress
-> rejected; MissionDone occurs later at/after egress

second Takeoff as mandatory delivery proof
-> rejected after Acceptance-2 false negative

heading -90 degrees as OMW right-hand lane
-> rejected by runtime observation; accepted tested OMW calibration uses +90 degrees
```

Der aktuelle vollständige Vertrag und die exakte Acceptance-Provenienz stehen in:

```text
docs/moose/GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-ACCEPTANCE-4-FINAL.md
```

Accepted settlement for that exact scope:

```text
matching FLIGHTGROUP/OPSGROUP OnAfterTaskDone
-> match air.mission:GetGroupWaypointTask(flightGroup) by Task.id
-> <= 250 m from OMW_BLUE_LZ_FORTRESS_01
-> CampaignState MarkDelivered
-> MissionDemand SUCCESS

later:
physical OnAfterLanded at Jalalabad
-> LegionAssetReturned
-> PASS
```
