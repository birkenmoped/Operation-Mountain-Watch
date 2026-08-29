---
document_id: OMW-HANDOFF-AUTOMATIC-RESPONSE-ORCHESTRATION-CONTINUATION-2026-08-29
status: PLANNED
document_class: DEVELOPMENT_ORDER_AND_HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local continuation order after accepted Ground RESUPPLY orchestration scope
  - current Stage 1D-P PERSONNEL runtime status and next formal gate
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/automatic-response-orchestration-continuation
validated_in_dcs: partial
base_branch: main
base_commit: 99d4d88d9b9eea2026fe525ebab4e29ff60cdbfa
---

# Automatic Response Orchestration – Continuation

## 1. Ausgangspunkt

Der Nachfolgebranch basiert auf dem nach `main` integrierten Ground-RESUPPLY-Parent-Scope:

```text
main merge PR: #135
main merge commit: 99d4d88d9b9eea2026fe525ebab4e29ff60cdbfa
```

Akzeptierter Parent-Scope:

```text
Stage 1A  AMMO RESUPPLY                ACCEPTED_TECHNICAL_BASELINE
Stage 1C  meta RESUPPLY via NOTHING    ACCEPTED_TECHNICAL_BASELINE
Stage 1B2 one-shot FUELSUPPLY          ACCEPTED_TECHNICAL_BASELINE
Stage 1D-S SUPPLY via NOTHING          ACCEPTED_TECHNICAL_BASELINE
```

## 2. Stage 1D-S – unverändert akzeptiert

```text
status: ACCEPTED_TECHNICAL_BASELINE
runtime_result: PASS
build_commit: 4771420480a994ce7356abc618ae0a3189dc105e
builder_version: GROUND-SUPPLY-RESUPPLY-NOTHING-ACCEPTANCE-1-2
bundle_sha256: C805C996A2028629251F833F0E0D0ED06F462C15271A1166E0DB8DF0BA105CE3
mission: OMW_Template_v20_GroundWorks.miz
mission_sha256: BA556641A9ECAD629FDBE62AEA5CC30E22E081B81B4188C136855026F70D0907
dcs: 2.9.29.27278 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_sha256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Ground-RESUPPLY bleibt außerhalb der aktuellen Air-PERSONNEL-Korrektur. Es ist kein weiterer Ground-Convoy-Retest erforderlich, solange der Ground-Lifecycle nicht verändert wird.

## 3. Stage 1D-P – verbindlicher PERSONNEL-Vertrag

Owner-Entscheidung:

```text
resourceId: GROUND_PERSONNEL
PERSONNEL is strategic CampaignState headcount
reorder trigger: strictly below 80% of target
exactly 80%: no demand
resupply quantity: refill to 100% target
critical threshold: none in this stage
```

Supply parent:

```text
Jalalabad -> Fortress
Jalalabad -> Joyce
Jalalabad -> Wright
Jalalabad -> Bostick
Joyce     -> Honaker
```

Ordinary PERSONNEL resupply does not require visible Infantry GROUP cargo. Physical FOB/COP -> OP/AO troop deployment remains a separate tactical scope; `AUFTRAG:NewTROOPTRANSPORT(...)` remains a candidate there, not for meta-PERSONNEL resupply.

## 4. Initial combined PERSONNEL acceptance – what remained valid

The combined Stage 1D-P test established:

```text
Ground Joyce -> Honaker PERSONNEL
-> accepted Ground NOTHING lifecycle reused successfully

Air Jalalabad -> Fortress PERSONNEL
-> strategic quantity transfer itself worked
-> physical-return proof was wrong because Fortress target was an Invisible FARP
```

The Ground leg is not reopened by the subsequent Air-only work.

## 5. Air PERSONNEL – corrected physical mission architecture

Current carrier contract:

```text
Origin: GROUND_NODE_JALALABAD
Destination: GROUND_NODE_FORTRESS
Resource: GROUND_PERSONNEL
Initial: Jalalabad 480 / Fortress 160
Artificial shortage: Fortress 160 -> 127
80% floor: 128
Transfer: 33
Expected final: Jalalabad 447 / Fortress 160
AIRWING: AW_US_JBAD_TF_SHOOTER_6_6_CAV
SQUADRON: SQ_US_JBAD_CH47_HEAVYLIFT
Template: TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP
Mission: AUFTRAG:NewLANDATCOORDINATE(...)
Landing target: OMW_BLUE_LZ_FORTRESS_01
```

Fortress `OMW_BLUE_LZ_FORTRESS_01` is now a normal trigger-zone/coordinate LZ for this scope, not an Intermediate FARP/AIRBASE.

Reason: the pinned MOOSE `FLIGHTGROUP:onafterArrived(...)` path can return an AIRWING AI flight to Legion after arrival at a foreign FARP/Airbase; the source itself contains a TODO about checking whether that base is actually the AIRWING home base. The first combined test visibly demonstrated the resulting premature despawn at Fortress.

## 6. Physical return contract

The accepted proof rule is now:

```text
MissionDone alone != physical return
LegionAssetReturned alone != physical return

physical FLIGHTGROUP OnAfterLanded at Jalalabad
-> homeLandingConfirmed=true
-> only afterwards LegionAssetReturned
-> eligible for PASS
```

No Native-DCS RTB dispatcher and no MOOSE override were introduced.

## 7. OMW_FlightPath corridor decisions

The owner-authored Mission Editor line:

```text
OMW_FlightPath
```

is resolved via MOOSE `PATHLINE` and is the preferred rotary-wing valley centerline.

Owner decisions:

```text
- corridor is preferred, not an absolute mission constraint;
- mission purpose may leave/rejoin when necessary;
- nominal lane is 500 m right of the centerline relative to direction of travel;
- opposite-direction traffic therefore uses the opposite geographic side where geometry permits;
- no dynamic terrain scanning;
- no parallel custom route database;
- leave/rejoin uses owner-authored FlightPath points.
```

After Acceptance-1 the owner refined the line with points before valley cuts, branches and before/at FOB/COP locations.

Tested current geometry:

```text
OMW_FlightPath points: 84
Jalalabad -> Fortress corridor subset: 14
outbound inserted waypoints: 14
return inserted waypoints: 13
nearest owner-authored Fortress path point: about 692.4 m from LZ
```

Runtime calibration:

```text
Acceptance-1 heading -90° appeared on the wrong side.
Acceptance-2 through -4 use heading +90° for the OMW right-hand lane.
```

This is an OMW/DCS runtime calibration, not a general redefinition of MOOSE coordinates.

## 8. Acceptance-iteration lessons

### Acceptance-1

```text
basic FlightPath + normal-LZ mission worked
43-point path was too coarse near Fortress
visible turn-back/detour occurred at the chosen path point
-90° offset visually used wrong side
```

Correction: owner refined FlightPath; harness uses `+90°` runtime-calibrated side.

### Acceptance-2

Physical mission visually worked end-to-end, including Fortress intermediate landing, about 30 s dwell, departure and Jalalabad return.

Harness error:

```text
second OnAfterTakeoff near Fortress was used as PERSONNEL settlement authority
-> physical departure happened
-> no usable second callback for this harness
-> false negative AIR_HOME_LANDED_BEFORE_DELIVERY
```

Decision: second takeoff is not strategic delivery authority.

### Acceptance-3

Harness moved settlement to matching `MissionDone` near Fortress.

Runtime/source result:

```text
mission has SetMissionEgressCoord
LANDATCOORDINATE task completes at Fortress
aircraft departs
MissionDone occurs only later at/after egress
real MissionDone was about 48.6 km from Fortress
```

Decision: `MissionDone` is mission-level completion/diagnostic and not the LANDAT delivery instant when egress exists.

### Acceptance-4

Final correction:

```text
FLIGHTGROUP / OPSGROUP OnAfterTaskDone
-> air.mission:GetGroupWaypointTask(flightGroup)
-> matching Task.id
-> <=250 m from Fortress LZ
-> exact-once CampaignState MarkDelivered
-> MissionDemand SUCCESS
```

Real runtime:

```text
AIR_DELIVERY_CONFIRMED_ON_LANDAT_TASK_DONE distanceM=4.1
landTaskDoneCount=1
quantity=33
campaignStateStatus=DELIVERED
demandStatus=SUCCESS

AIR_MISSION_DONE_DIAGNOSTIC deliveryCommitted=true
AIR_HOME_LANDED airbase=Jalalabad deliveryConfirmed=true
AIR_LEGION_ASSET_RETURNED homeLandingConfirmed=true
PASS final=447/160 physicalReturn=JALALABAD
```

## 9. Acceptance-4 provenance and current formal status

```text
runtime_result: PASS
branch: agent/automatic-response-orchestration-continuation
source/builder commit: be8adc3ad1e2cfa6de7a25252cd8b217caeccde3
builder_version: AIR-PERSONNEL-FLIGHTPATH-RETURN-ACCEPTANCE-4-1
bundle: OMW_Air_PERSONNEL_FlightPath_Return_Acceptance_4.lua
bundle_sha256: C2BD325AF48BF6EA08936BCA666E4460293B60CC36FB8FE0181BC5140DF9ABD3
mission: OMW_Template_v20_GroundWorks.miz
mission_sha256: PENDING OWNER HASH
dcs: 2.9.29.27278 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_sha256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
dcs_log_sha256: 83BB6CECB0DEE23DC4DF7ACAEE3D344347B5E73A101ADEF1536E740090937FF5
debrief_log_sha256: AC694CDECBBD2A76547A63BC1375C5AEC2B6FC9424D7EAEDD2F7EDF14994C40F
```

Important governance correction: this is a **real DCS Runtime PASS**, but it is not yet labelled `ACCEPTED_TECHNICAL_BASELINE` because the exact tested MIZ SHA-256 has not yet been returned after the owner modified the FlightPath. `OMW-GOV-001` requires that hash for complete acceptance provenance.

No repeat DCS run is needed if the owner supplies the SHA-256 of the unchanged `.miz` that produced this PASS.

Detailed report:

```text
docs/moose/GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-ACCEPTANCE-4-RUNTIME-RESULT.md
```

## 10. MOOSE-first methods now relevant/validated for this scope

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

The scope is exact-version/exact-mission bounded.

## 11. Explicit exclusions

```text
No MIST.
No native DCS world event handler.
No native DCS route dispatcher.
No MissionScripting.lua modification.
No TROOPTRANSPORT for meta-PERSONNEL.
No OPSTRANSPORT strategic PERSONNEL ownership.
No physical Infantry GROUP cargo for ordinary PERSONNEL resupply.
No Intermediate Fortress FARP for this mission.
No LegionAssetReturned-only RTB proof.
No MissionDone delivery settlement when egress exists.
No second-Takeoff delivery requirement.
No hard outbound/return Air travel timeout.
No automated MIZ mutation.
```

## 12. Remaining development order

First close the provenance gate:

```text
Stage 1D-P
-> owner returns exact tested MIZ SHA-256
-> promote branch-local Acceptance-4 result to ACCEPTED_TECHNICAL_BASELINE
```

Then continue:

```text
Stage 1D-V  VEHICLE source/design reconciliation
Stage 2     FOB attacked -> support demand
Stage 3     fire support -> strategic resupply closure
Stage 4     convoy attacked -> support demand
Stage 5     BLUE/CAS automatic-response adapter
Stage 6     aircraft loss -> CSAR incident / MOOSE CSAR-first execution
Stage 7     complete end-to-end automatic response chain
Stage 8     restart / restore / idempotence
Stage 9     multiplayer / performance / failure acceptance
Stage 10    production reconciliation and merge readiness
```

## 13. Arbeitsgrenzen

```text
CampaignState = sole strategic authority
MissionDemand = demand/assignment authority
MOOSE = primary operational executor
DCS groups = temporary physical representations
```

No `.miz` mutation by ChatGPT. No second resource authority. No Native-DCS/non-MOOSE parallel implementation without explicit owner approval. No `VALIDATED` claim beyond the exact documented DCS/MOOSE scope.
