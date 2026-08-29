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
source_branch: agent/automatic-response-orchestration-continuation
validated_in_dcs: false
superseded_by:
  - OMW-MOOSE-GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-ACCEPTANCE-4-RUNTIME-RESULT
---

# Stage 1D-P – Initial PERSONNEL Ground/Air Source Review

Dieses Dokument bleibt als historischer Entwicklungsnachweis erhalten, ist aber für den Air-Pfad **SUPERSEDED**.

Die weiterhin gültigen fachlichen Entscheidungen aus der ursprünglichen Review sind:

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

Die folgenden ursprünglichen Air-Annahmen wurden durch reale DCS-Läufe widerlegt beziehungsweise präzisiert und dürfen **nicht** weiter als aktuelle Architektur gelesen werden:

```text
1. Fortress as Invisible FARP for intermediate AIRWING landing
   -> rejected for this scope because foreign-FARP Arrived/Legion return caused premature despawn.

2. LegionAssetReturned as sufficient physical home-return proof
   -> rejected; physical Jalalabad OnAfterLanded must precede LegionAssetReturned.

3. MissionDone near Fortress as LANDATCOORDINATE delivery proof
   -> rejected when mission egress exists; MissionDone occurs only later at/after egress.

4. second Takeoff callback as mandatory delivery proof
   -> rejected after Acceptance-2 false negative.

5. heading -90 degrees as the OMW right-hand lane
   -> rejected by owner visual runtime calibration; current tested OMW path uses +90 degrees.
```

Der aktuelle vollständige Source-/Runtime-Vertrag steht in:

```text
docs/moose/GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-ACCEPTANCE-4-RUNTIME-RESULT.md
docs/moose/GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-FLIGHTPATH-ACCEPTANCE-2-RUNTIME-FINDINGS.md
docs/moose/GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-FLIGHTPATH-RETURN-SOURCE-REVIEW.md
```

Current MOOSE/DCS-bounded settlement:

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

See the Acceptance-4 report for the exact branch/commit/bundle/DCS/MOOSE/log provenance and the still-pending exact tested MIZ SHA-256.
