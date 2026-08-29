---
document_id: OMW-MOOSE-GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-FLIGHTPATH-ACCEPTANCE-2-RUNTIME-FINDINGS
status: DRAFT
document_class: TECHNICAL_EVIDENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 1D-P Air PERSONNEL Acceptance-1 through Acceptance-4 runtime findings
  - corrected delivery-settlement selection for LANDATCOORDINATE with egress
  - OMW_FlightPath runtime calibration findings
not_authoritative_for:
  - ACCEPTED_TECHNICAL_BASELINE until exact tested MIZ SHA-256 is recorded
  - production-wide rotary-wing corridor validation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/automatic-response-orchestration-continuation
validated_in_dcs: true
---

# Stage 1D-P – FlightPath Acceptance Runtime Findings

## 1. Acceptance-1 – Corridor, coarse leave point and lateral offset

Acceptance-1 proved the basic MOOSE composition:

```text
Jalalabad CH-47
-> OMW_FlightPath
-> Fortress normal-LZ landing
-> dwell
-> departure
-> return flight
```

The initial FlightPath contained 43 points. The nearest selected owner-authored point before Fortress was still sufficiently coarse that DCS visibly continued to that point and then turned back toward Fortress. This was a route-authoring/granularity effect, not a need for a parallel custom route engine.

The owner then refined `OMW_FlightPath` with points before valley cuts, branches and before/at FOB/COP locations. The tested later stand contains 84 points; the Jalalabad-Fortress acceptance subset uses 14 corridor points.

Acceptance-1 also showed visually that the initially implemented `heading - 90 degrees` produced the wrong side for the intended OMW traffic convention. Later acceptances therefore use the owner-runtime-calibrated value:

```text
right-hand OMW lane = heading + 90 degrees
```

This is an OMW/DCS calibration for this path and is not promoted to a general mathematical statement about every MOOSE coordinate use.

## 2. Fixed corridor contract

Owner decision:

```text
OMW_FlightPath = preferred rotary-wing valley centerline
nominal lane = 500 m right of centerline relative to current travel direction
mission purpose may leave/rejoin the corridor when required
```

For the accepted test geometry:

```text
PATHLINE points: 84
corridor points Jalalabad -> Fortress: 14
outbound inserted waypoints: 14
return inserted waypoints: 13
right offset: 500 m
rightHeadingDeltaDeg: +90
corridor altitude: 500 ft AGL
leave/rejoin mode: nearest owner-authored PATHLINE waypoint
```

No dynamic terrain scan, segment-projection engine, native DCS route dispatcher or duplicate route database was introduced.

## 3. Acceptance-2 – physical mission correct, settlement false negative

The owner visually confirmed the complete physical sequence:

```text
Jalalabad takeoff
-> outbound FlightPath
-> Fortress approach
-> visible intermediate landing
-> approximately 30 s dwell
-> physical departure
-> return FlightPath
-> physical return to Jalalabad
```

Acceptance-2 nevertheless failed because the harness incorrectly made strategic PERSONNEL delivery depend on a second `FLIGHTGROUP:OnAfterTakeoff(...)` callback near Fortress.

The physical departure was visible, but no second callback usable by that harness path was observed. Therefore `deliveryCommitted` stayed false and the later home landing produced:

```text
FAIL reason=AIR_HOME_LANDED_BEFORE_DELIVERY
```

Conclusion:

```text
second Takeoff callback != robust delivery authority for this LANDATCOORDINATE resupply scope
```

No speculative Pinnacle-landing special rule is derived from this failure.

## 4. Acceptance-3 – MissionDone is too late when egress exists

Acceptance-3 moved settlement to the matching `LANDATCOORDINATE` mission `MissionDone` event plus a 250 m Fortress distance check.

This also failed for a source-backed reason: the mission has an egress coordinate. In the pinned MOOSE lifecycle, mission-level completion waits for the egress path. In the real run, `MissionDone` arrived only after the CH-47 had already departed Fortress and was approximately 48.6 km from the LZ.

Conclusion:

```text
MissionDone = mission-level completion
MissionDone != LANDATCOORDINATE task-completion instant when an egress exists
```

`MissionDone` remains useful as a lifecycle diagnostic, but not as Fortress PERSONNEL-delivery authority in this composition.

## 5. Acceptance-4 – correct MOOSE-first TaskDone settlement

Acceptance-4 uses the MOOSE task lifecycle rather than inferring delivery from takeoff or mission-level completion:

```text
FLIGHTGROUP / OPSGROUP OnAfterTaskDone
-> obtain assigned mission task with air.mission:GetGroupWaypointTask(flightGroup)
-> require matching Task.id
-> require flight group within 250 m of OMW_BLUE_LZ_FORTRESS_01
-> CampaignState MarkDelivered
-> MissionDemand SUCCESS
```

The real DCS run produced:

```text
AIR_DELIVERY_CONFIRMED_ON_LANDAT_TASK_DONE
lz=OMW_BLUE_LZ_FORTRESS_01
distanceM=4.1
landTaskDoneCount=1
quantity=33
campaignStateStatus=DELIVERED
demandStatus=SUCCESS
```

The later mission-level callback was only diagnostic:

```text
AIR_MISSION_DONE_DIAGNOSTIC ... deliveryCommitted=true
```

Physical home return then completed in the required order:

```text
AIR_HOME_LANDED ... airbase=Jalalabad deliveryConfirmed=true
AIR_LEGION_ASSET_RETURNED ... homeLandingConfirmed=true
PASS ... final=447/160 ... physicalReturn=JALALABAD
```

## 6. Correct authority split

The successful runtime path preserves the project architecture:

```text
MOOSE
-> physical carrier mission/task/lifecycle proof

CampaignState
-> sole strategic GROUND_PERSONNEL quantity/status authority

MissionDemand
-> demand/reservation/success authority
```

At the matching Fortress `TaskDone`, OMW performs exact-once `MarkDelivered` and marks the demand `SUCCESS`. MOOSE does not become a second strategic PERSONNEL store.

## 7. Return proof learned from the foreign-FARP failure

The earlier combined Stage 1D-P run used an Invisible FARP at Fortress. The CH-47 landed and was immediately returned/despawned there through the AIRWING/LEGION lifecycle instead of physically flying home.

The corrected contract is:

```text
Fortress intermediate stop
-> normal trigger-zone/coordinate LZ
-> no FARP/AIRBASE semantics

home return proof
-> FLIGHTGROUP OnAfterLanded at Jalalabad
-> only afterwards LegionAssetReturned
```

Therefore:

```text
MissionDone alone != physical RTB
LegionAssetReturned alone != physical RTB
```

## 8. Strategic PERSONNEL contract remains unchanged

```text
resourceId: GROUND_PERSONNEL
reorder trigger: strictly below 80% target
exactly 80%: no demand
refill quantity: to 100% target
Fortress simulated 160 -> 127
80% floor: 128
transfer: 33
final: Jalalabad 447 / Fortress 160
```

Ordinary PERSONNEL resupply remains abstract strategic headcount. `TROOPTRANSPORT` and physical Infantry GROUP cargo remain separate tactical-deployment concerns.

## 9. Acceptance-4 runtime provenance

```text
branch: agent/automatic-response-orchestration-continuation
source/builder commit: be8adc3ad1e2cfa6de7a25252cd8b217caeccde3
builder: AIR-PERSONNEL-FLIGHTPATH-RETURN-ACCEPTANCE-4-1
bundle SHA-256: C2BD325AF48BF6EA08936BCA666E4460293B60CC36FB8FE0181BC5140DF9ABD3
mission: OMW_Template_v20_GroundWorks.miz
mission SHA-256: PENDING OWNER HASH
DCS: 2.9.29.27278 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
dcs.log SHA-256: 83BB6CECB0DEE23DC4DF7ACAEE3D344347B5E73A101ADEF1536E740090937FF5
debrief.log SHA-256: AC694CDECBBD2A76547A63BC1375C5AEC2B6FC9424D7EAEDD2F7EDF14994C40F
runtime result: PASS
```

The missing exact tested `.miz` SHA-256 is the only remaining provenance item before this branch-local result can be labelled `ACCEPTED_TECHNICAL_BASELINE` under `OMW-GOV-001`. No repeat DCS run is required if the returned hash is for the unchanged mission file that produced this PASS.

## 10. Explicit exclusions retained

```text
No MIST.
No native DCS world event handler.
No native DCS route dispatcher.
No MissionScripting.lua modification.
No TROOPTRANSPORT for meta-PERSONNEL resupply.
No OPSTRANSPORT strategic PERSONNEL ownership.
No physical Infantry GROUP cargo for ordinary PERSONNEL resupply.
No hard outbound or return travel timeout.
No automated MIZ mutation.
```

The detailed consolidated evidence is in:

```text
docs/moose/GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-ACCEPTANCE-4-RUNTIME-RESULT.md
```
