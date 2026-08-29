---
document_id: OMW-MOOSE-GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-ACCEPTANCE-4-FINAL
status: ACCEPTED_TECHNICAL_BASELINE
document_class: TECHNICAL_EVIDENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Stage 1D-P Air PERSONNEL Acceptance-4 final acceptance
  - LANDATCOORDINATE TaskDone delivery settlement
  - OMW_FlightPath Jalalabad-Fortress physical return
  - Stage 1D-P Air meta-PERSONNEL runtime lessons
not_authoritative_for:
  - repository-wide production architecture before merge or explicit governance adoption
  - tactical Infantry GROUP transport
  - other rotary-wing corridors, LZs, aircraft types, DCS versions or MOOSE versions
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - OMW-MOOSE-GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-ACCEPTANCE-4-RUNTIME-RESULT
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
runtime_result: PASS
accepted_technical_baseline: true
---

# Stage 1D-P – Air PERSONNEL Acceptance-4 Final

## 1. Finaler Status

Stage 1D-P Air PERSONNEL ist für den exakt unten dokumentierten technischen Stand eine branch-lokale `ACCEPTED_TECHNICAL_BASELINE`.

Der reale DCS-Lauf bestätigte:

```text
Jalalabad CH-47 materialization
-> physical takeoff
-> OMW_FlightPath outbound corridor
-> LANDATCOORDINATE at OMW_BLUE_LZ_FORTRESS_01
-> physical intermediate landing / about 30 s dwell
-> matching MOOSE TaskDone at 4.1 m from Fortress LZ
-> CampaignState transfer DELIVERED
-> MissionDemand SUCCESS
-> physical departure from Fortress
-> OMW_FlightPath return corridor
-> physical landing at Jalalabad
-> afterwards LegionAssetReturned
-> PASS
```

## 2. Exakte Acceptance-Provenienz

```text
Branch:
agent/automatic-response-orchestration-continuation

Source / builder commit:
be8adc3ad1e2cfa6de7a25252cd8b217caeccde3

BuilderVersion:
AIR-PERSONNEL-FLIGHTPATH-RETURN-ACCEPTANCE-4-1

TestId:
AIR-PERSONNEL-FLIGHTPATH-RETURN-ACCEPTANCE-4

Bundle:
OMW_Air_PERSONNEL_FlightPath_Return_Acceptance_4.lua

Bundle SHA-256:
C2BD325AF48BF6EA08936BCA666E4460293B60CC36FB8FE0181BC5140DF9ABD3

Mission:
OMW_Template_v20_GroundWorks.miz

Mission SHA-256:
3B93F9817379BA6C66C8C02DD2142D1EDA3D88090CB8FC88973D4DAC45EE6B11

DCS:
2.9.29.27278 MT

MOOSE release:
2.9.18

MOOSE commit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

Moose.lua SHA-256:
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915

dcs.log SHA-256:
83BB6CECB0DEE23DC4DF7ACAEE3D344347B5E73A101ADEF1536E740090937FF5

debrief.log SHA-256:
AC694CDECBBD2A76547A63BC1375C5AEC2B6FC9424D7EAEDD2F7EDF14994C40F
```

The owner-supplied final `.miz` copy was inspected read-only. Its container SHA-256 is the mission hash above. The embedded acceptance bundle matches exactly:

```text
l10n/DEFAULT/OMW_Air_PERSONNEL_FlightPath_Return_Acceptance_4.lua
SHA-256 C2BD325AF48BF6EA08936BCA666E4460293B60CC36FB8FE0181BC5140DF9ABD3
```

The same `.miz` also contains the pinned/accepted supporting runtime artifacts:

```text
l10n/DEFAULT/Moose.lua
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915

l10n/DEFAULT/OMW_AirOps_Warehouse_Base.lua
69AF63173E599D1A6DB81A86552B06E01252F01B8A03CB26E95AEF51192D4EA9

l10n/DEFAULT/OMW_Ground_Base.lua
21C37B57B1E6269B938791CBB87503DD0530DDF6560B2C2AF53B53C7E6605CC1
```

No `.miz` mutation was performed by ChatGPT.

## 3. PERSONNEL-Vertrag

```text
resourceId: GROUND_PERSONNEL
target: 100%
resupply trigger: strictly below 80%
exactly 80%: no demand
requested quantity: refill to 100%
critical threshold: none in this stage
```

Acceptance values:

```text
Jalalabad initial: 480
Fortress target: 160
simulated Fortress shortage: 127
Fortress 80% floor: 128
transfer quantity: 33
final: Jalalabad 447 / Fortress 160
```

`CampaignState` remains the sole strategic quantity/status authority. MOOSE supplies the physical carrier, mission and lifecycle evidence. OMW performs the strategic settlement exactly once after the matching physical MOOSE evidence.

## 4. Meta-PERSONNEL versus tactical troop transport

Ordinary PERSONNEL resupply remains abstract strategic headcount. A ground or air carrier may physically represent the movement without a visible Infantry GROUP cargo.

Separate later scope:

```text
FOB/COP -> OP deployment
FOB/COP/base -> AO insertion/extraction
-> real Infantry GROUP
-> MOOSE TROOPTRANSPORT remains a candidate
```

Therefore this accepted meta-PERSONNEL scope intentionally does not use `TROOPTRANSPORT`, CTLD troop cargo or OPSTRANSPORT as strategic resource authority.

## 5. Intermediate LZ contract

A foreign DCS FARP/AIRBASE is rejected for this intermediate AIRWING landing scope because the pinned MOOSE `FLIGHTGROUP:onafterArrived(...)` path can return an AIRWING AI flight to Legion without verifying that the arrived base is its home base.

Accepted pattern:

```text
intermediate operational LZ
-> ordinary trigger-zone / coordinate anchor
-> no AIRBASE/FARP semantics

home return
-> physical Jalalabad landing
-> only afterwards LegionAssetReturned
```

`OMW_BLUE_LZ_FORTRESS_01` is therefore a normal Mission Editor trigger-zone landing anchor in the accepted mission.

## 6. Physical RTB proof

The following are explicitly insufficient alone:

```text
MissionDone
ReturnToLegion
LegionAssetReturned
```

Accepted home-return evidence:

```text
FLIGHTGROUP OnAfterLanded at Jalalabad
-> homeLandingConfirmed=true
-> afterwards LegionAssetReturned
```

The Acceptance-4 PASS observed exactly this sequence.

## 7. OMW_FlightPath corridor contract

`OMW_FlightPath` is an owner-authored Mission Editor line resolved by MOOSE as `PATHLINE`. It is the preferred rotary-wing valley centerline, not a hard geographic constraint. Mission purpose may leave the corridor where required.

Accepted tested geometry:

```text
PATHLINE points: 84
Jalalabad -> Fortress corridor points used: 14
outbound waypoints: 14
return waypoints: 13
corridor altitude: 500 ft AGL
```

The owner deliberately added points before valley cuts, branches and at/near FOB/COP locations. The harness uses the nearest suitable owner-authored PATHLINE waypoint as leave/rejoin anchor. No automatic segment projection, dynamic terrain scanner, native route parser or parallel FlightPath database is introduced.

## 8. Lateral separation

Owner decision:

```text
nominal lane = 500 m right of OMW_FlightPath
relative to current direction of travel
```

Acceptance-1 visually showed that `heading - 90°` appeared on the wrong side in this exact OMW/DCS path. Acceptance-2 through Acceptance-4 therefore use the runtime-calibrated implementation:

```text
right-hand lane = heading + 90°
```

This is an OMW runtime calibration for this tested composition and must not be generalized into a universal MOOSE coordinate-system claim.

## 9. Lessons from Acceptance-1 through Acceptance-4

### Acceptance-1

```text
physical route concept worked
coarse FlightPath caused visible Fortress detour/U-turn
heading -90° appeared on wrong side
```

Correction: owner refined `OMW_FlightPath` and lane side was runtime-calibrated.

### Acceptance-2

Physical behavior was visually correct, but delivery settlement was incorrectly bound to a mandatory second `OnAfterTakeoff` callback. The helicopter visibly departed Fortress, yet the harness did not receive a callback usable for that assumption. Result was a false negative.

Decision:

```text
second takeoff is not PERSONNEL delivery authority
```

No general claim about Pinnacle-landing semantics is derived from that failed harness assumption.

### Acceptance-3

Delivery settlement was then incorrectly bound to `MissionDone` near Fortress. Because the mission has an egress, `MissionDone` occurred only later, about 48.6 km from Fortress.

Decision:

```text
MissionDone with mission egress
-> mission-level completion diagnostic
-> not LANDATCOORDINATE delivery instant
```

### Acceptance-4

Final MOOSE-first settlement:

```text
OPSGROUP / FLIGHTGROUP OnAfterTaskDone
-> compare completed Task with AUFTRAG:GetGroupWaypointTask(flightGroup)
-> require matching Task.id
-> require distance <= 250 m from Fortress LZ
-> CampaignState MarkDelivered
-> MissionDemand SUCCESS
```

Runtime evidence:

```text
distanceM=4.1
landTaskDoneCount=1
quantity=33
campaignStateStatus=DELIVERED
demandStatus=SUCCESS
```

This is the accepted delivery authority for the exact documented scope.

## 10. Accepted lifecycle

```text
CampaignState shortage below 80%
-> MissionDemand RESUPPLY
-> CampaignState reserve/transfer Jalalabad -> Fortress
-> Jalalabad AIRWING / SQ_US_JBAD_CH47_HEAVYLIFT
-> AUFTRAG:NewLANDATCOORDINATE(Fortress LZ, dwell=30 s)
-> OMW_FlightPath outbound
-> physical Fortress landing
-> matching MOOSE OnAfterTaskDone near Fortress
-> exact-once CampaignState MarkDelivered
-> MissionDemand SUCCESS
-> physical return corridor
-> MissionDone later at/after egress is diagnostic
-> physical OnAfterLanded at Jalalabad
-> LegionAssetReturned
-> PASS
```

The 30-second value is landing/dwell time, not a travel timeout. There is no hard outbound or return travel timeout.

## 11. Validated MOOSE scope

For the exact acceptance provenance above, the following were practically used/confirmed in the documented composition:

```text
PATHLINE:FindByName(...)
PATHLINE:GetCoordinates(...)
COORDINATE:HeadingTo(...)
COORDINATE:Translate(...)
AUFTRAG:NewLANDATCOORDINATE(...)
AUFTRAG:SetMissionEgressCoord(...)
AUFTRAG:AssignSquadrons(...)
AUFTRAG:GetGroupWaypointIndex(...)
AUFTRAG:GetGroupEgressWaypointUID(...)
AUFTRAG:GetGroupWaypointTask(...)
FLIGHTGROUP:AddWaypoint(...)
FLIGHTGROUP / OPSGROUP OnAfterTaskDone
FLIGHTGROUP OnAfterMissionDone
FLIGHTGROUP OnAfterLanded
OPSGROUP:Get2DDistance(...)
AIRWING:AddMission(...)
AIRWING OnAfterFlightOnMission
LEGION/AIRWING OnAfterLegionAssetReturned
```

The validation does not automatically transfer to another MOOSE hash, DCS version, aircraft type, LZ, corridor or mission composition.

## 12. Explicitly rejected paths

```text
MIST
native DCS world event handler
native DCS routing dispatcher
MissionScripting.lua modification
TROOPTRANSPORT for meta-PERSONNEL
OPSTRANSPORT as strategic PERSONNEL owner
physical Infantry GROUP cargo for ordinary PERSONNEL resupply
foreign Invisible FARP as Fortress intermediate landing for this AIRWING path
LegionAssetReturned as sole physical-return proof
MissionDone as Fortress delivery instant when mission egress exists
second Takeoff as mandatory delivery signal
hard Air travel timeout
automated MIZ mutation
dynamic terrain scanner
parallel FlightPath database
```

## 13. Governance boundary

This acceptance is technically binding only for the exact branch/commit/MIZ/bundle/DCS/MOOSE provenance documented above. Repository-wide normative effect requires merge to `main` or an explicit governance decision under `OMW-GOV-001`.
