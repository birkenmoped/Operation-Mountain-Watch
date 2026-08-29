---
document_id: OMW-MOOSE-GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-FLIGHTPATH-RETURN-SOURCE-REVIEW
status: SOURCE_REVIEWED
document_class: TECHNICAL_EVIDENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 1D-P Air PERSONNEL FlightPath and physical-return source review
  - OMW_FlightPath use as preferred rotary-wing corridor
  - Fortress normal-LZ intermediate landing contract
  - source explanation for TaskDone versus MissionDone with mission egress
not_authoritative_for:
  - production-wide rotary-wing routing beyond the documented acceptance scope
  - physical infantry-group transport
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/automatic-response-orchestration-continuation
validated_in_dcs: true
---

# Stage 1D-P – Air PERSONNEL FlightPath / Physical Return Source Review

## 1. Pinned MOOSE

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Documentation alone was not treated as proof; the actual pinned `Moose.lua` and relevant official FlightGroup landing example were used.

## 2. Foreign FARP limitation and normal Fortress LZ

The original combined PERSONNEL acceptance landed the Jalalabad AIRWING CH-47 on a Fortress Invisible FARP. The helicopter was then returned/despawned there instead of physically returning home.

The pinned source explains the risk: `FLIGHTGROUP:onafterArrived(...)` can call `ReturnToLegion(1)` for an AIRWING flight, and the source contains a TODO noting that the current base is not checked against the AIRWING home base.

For this scope the intermediate destination is therefore an ordinary Mission Editor trigger-zone/coordinate LZ:

```text
OMW_BLUE_LZ_FORTRESS_01
```

It is intentionally not an AIRBASE/FARP for the intermediate landing.

The physical home-return contract is:

```text
OnAfterLanded at Jalalabad
-> home landing proof
-> afterwards LegionAssetReturned
```

`LegionAssetReturned` alone is insufficient.

## 3. OMW_FlightPath via MOOSE PATHLINE

The owner-authored Mission Editor line:

```text
OMW_FlightPath
```

is registered by MOOSE as a `PATHLINE`. Relevant public methods used by the accepted path include:

```text
PATHLINE:FindByName(...)
PATHLINE:GetCoordinates(...)
COORDINATE:HeadingTo(...)
COORDINATE:Translate(...)
FLIGHTGROUP:AddWaypoint(...)
```

No native `env.mission` parsing, duplicate route database or custom DCS route dispatcher is used.

Owner decision:

```text
OMW_FlightPath is a preferred valley corridor.
Mission purpose may leave/rejoin it when required.
Nominal lane is 500 m right of the reference line relative to direction of travel.
```

After the first DCS run the owner refined the line with additional points before valley cuts, at branches and before/at FOB/COP locations. The later tested geometry contains 84 total path points and uses a 14-point Jalalabad-Fortress subset.

## 4. Right-side runtime calibration

The initial source-review assumption used:

```text
heading - 90 degrees
```

The owner visually observed that this appeared on the wrong side in the actual OMW/DCS route. The accepted later test path therefore uses:

```text
heading + 90 degrees
```

for the OMW right-hand lane.

This is explicitly a runtime calibration for this path and not a general statement that redefines MOOSE coordinate mathematics.

## 5. Owner-authored leave/rejoin points

The current implementation deliberately uses the nearest suitable owner-authored PATHLINE point rather than inventing a terrain-aware projection system.

Tested current geometry:

```text
OMW_FlightPath total points: 84
Jalalabad -> Fortress corridor points: 14
originWaypointIndex: 1
destinationWaypointIndex: 14
nearest Fortress corridor point: approximately 692.4 m from LZ
outbound inserted waypoints: 14
return inserted waypoints: 13
```

No dynamic terrain scan is used.

## 6. AUFTRAG routing composition

The physical mission remains MOOSE-native:

```text
AUFTRAG:NewLANDATCOORDINATE(...)
AUFTRAG:SetMissionEgressCoord(...)
AUFTRAG:AssignSquadrons(...)
AIRWING:AddMission(...)
```

The corridor is composed with MOOSE waypoint APIs around the mission waypoint/egress lifecycle.

Relevant source-backed methods:

```text
AUFTRAG:GetGroupWaypointIndex(...)
AUFTRAG:GetGroupEgressWaypointUID(...)
AUFTRAG:GetGroupWaypointTask(...)
OPSGROUP:GetWaypointIndex(...)
OPSGROUP:GetWaypointUIDFromIndex(...)
FLIGHTGROUP:AddWaypoint(...)
```

## 7. Critical lifecycle lesson: TaskDone is the delivery instant

Three potential settlement signals were tested.

### Second Takeoff – rejected

Acceptance-2 showed the physical Fortress departure but did not provide a second `OnAfterTakeoff` usable by the harness. This produced a false negative. Therefore second Takeoff is not the delivery authority.

### MissionDone – rejected for delivery with egress

The pinned `OPSGROUP`/mission lifecycle and Acceptance-3 showed that with a mission egress, `MissionDone` occurs after egress, not at the intermediate `LANDATCOORDINATE` task. In the real run it was approximately 48.6 km from Fortress when received.

Therefore:

```text
MissionDone = mission-level completion diagnostic
MissionDone != Fortress LANDAT task completion when egress exists
```

### TaskDone – accepted for this scope

Acceptance-4 uses:

```text
FLIGHTGROUP / OPSGROUP OnAfterTaskDone
-> mission:GetGroupWaypointTask(flightGroup)
-> matching Task.id
-> Get2DDistance(Fortress LZ) <= 250 m
```

This produced the real runtime proof:

```text
AIR_DELIVERY_CONFIRMED_ON_LANDAT_TASK_DONE
distanceM=4.1
landTaskDoneCount=1
campaignStateStatus=DELIVERED
demandStatus=SUCCESS
```

Only then does OMW perform exact-once strategic settlement:

```text
CampaignState MarkDelivered
-> MissionDemand SUCCESS
```

## 8. Final physical return proof

After delivery settlement:

```text
return corridor
-> later MissionDone diagnostic
-> physical OnAfterLanded at Jalalabad
-> LegionAssetReturned
-> PASS
```

The Acceptance-4 log confirms:

```text
AIR_HOME_LANDED ... airbase=Jalalabad deliveryConfirmed=true
AIR_LEGION_ASSET_RETURNED ... homeLandingConfirmed=true
PASS ... final=447/160 ... physicalReturn=JALALABAD
```

## 9. Dwell versus timeout

The mission uses:

```text
LANDATCOORDINATE dwell: 30 s
```

The owner visually observed the CH-47 remain in the Fortress intermediate landing for approximately that period before departure.

This is not a travel deadline. The contract remains:

```text
no hard outbound travel timeout
no hard return travel timeout
```

## 10. Strategic boundaries

```text
CampaignState = sole strategic GROUND_PERSONNEL authority
MOOSE = physical execution/lifecycle authority
MissionDemand = demand/reservation/success authority
```

Ordinary PERSONNEL resupply remains abstract headcount; no `TROOPTRANSPORT`, physical Infantry GROUP cargo, CTLD troop cargo or OPSTRANSPORT strategic resource authority is introduced.

## 11. Runtime result and provenance gate

Acceptance-4 runtime result is PASS with:

```text
source/builder commit: be8adc3ad1e2cfa6de7a25252cd8b217caeccde3
builder: AIR-PERSONNEL-FLIGHTPATH-RETURN-ACCEPTANCE-4-1
bundle SHA-256: C2BD325AF48BF6EA08936BCA666E4460293B60CC36FB8FE0181BC5140DF9ABD3
DCS: 2.9.29.27278 MT
MOOSE: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
mission: OMW_Template_v20_GroundWorks.miz
mission SHA-256: PENDING OWNER HASH
```

The detailed acceptance document is:

```text
docs/moose/GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-ACCEPTANCE-4-RUNTIME-RESULT.md
```

The DCS behavior is validated for the exact runtime path, but governance promotion to `ACCEPTED_TECHNICAL_BASELINE` remains blocked only by the missing SHA-256 of the exact tested `.miz`.
