---
document_id: OMW-MOOSE-STAGE3-SLINGLOAD-CORRIDOR-EXCEPTION-DECISION
status: PLANNED
document_class: ARCHITECTURE_EXCEPTION_DECISION
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 3 external slingload pickup-to-drop routing exception
  - exact boundary between MOOSE ownership and the narrow DCS CargoTransportation handoff
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
supersedes:
superseded_by:
validated_in_dcs: false
---

# Stage 3 – External Slingload Corridor Exception Decision

## 1. Owner decision

After the documented MOOSE capability review in `STAGE3-CAS-CARGOTRANSPORT-ROUTE-LIFECYCLE-GAP.md`, the project owner authorized continuing with the recommended option that preserves both requirements:

```text
physical external CH-47 slingload
AND
owner-authored R500 pickup-to-Wright route
```

The approval applies only to the verified capability gap between confirmed physical slingload pickup and the Wright-side delivery task. It is not a general Native-DCS routing approval.

## 2. Verified MOOSE gap

Pinned MOOSE:

```text
release: 2.9.18
commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

`AUFTRAG:NewCARGOTRANSPORT(StaticCargo, DropZone)` creates the DCS helicopter task `CargoTransportation` with the physical cargo `groupId` and Mission-Editor drop-zone `zoneId`. The reviewed public AUFTRAG API exposes no route/path parameter for the active phase between physical pickup and drop.

`OPSTRANSPORT:AddPathTransport(...)` provides MOOSE-native transport paths, but the reviewed storage/cargobay model does not preserve the currently required visible external slingload.

No verified public MOOSE API or official example was found that combines all three properties:

```text
AIRWING/AUFTRAG AI execution
physical external slingload
arbitrary owner-authored pickup-to-drop PATHLINE
```

## 3. Narrow exception design

Runtime implementation:

```text
scripts/air-operations/OMW_SlingloadCorridorHandoff.lua
```

MOOSE remains authoritative for:

```text
AIRWING / SQUADRON asset selection
AUFTRAG:NewCARGOTRANSPORT
physical cargo identity
initial approach and slingload pickup
FLIGHTGROUP waypoint ownership
AIRWING / LEGION aircraft lifecycle
CampaignState resource settlement
```

Only after Stage 3 has positively observed that the physical slingload left the Jalalabad pickup zone does the exception execute:

```text
confirmed pickup
-> FLIGHTGROUP:GetWaypointCurrentUID()
-> FLIGHTGROUP:AddWaypoint() for R500 outbound
-> FLIGHTGROUP:AddTaskWaypoint() at Wright-side route exit
   with the same DCS CargoTransportation groupId / zoneId
-> FLIGHTGROUP:AddWaypoint() for R500 return
-> one FLIGHTGROUP:UpdateRoute()
```

At the Wright-side route exit the documented DCS `CargoTransportation` task is re-issued for the same physical cargo and the same Mission-Editor drop zone. Physical delivery is then verified from the cargo wrapper being alive and inside the drop zone. Only after that evidence is the original AUFTRAG completed through its public FSM `Success` event.

## 4. Explicit boundaries

Not approved and not used by this exception:

```text
Controller:setTask()
Controller:pushTask()
coalition.addGroup()
coalition.addStaticObject()
teleport
MissionScripting.lua mutation
MIST
direct strategic resource mutation outside CampaignState
high-frequency/frame polling
```

The delivery monitor is limited to a five-second MOOSE `SCHEDULER` interval and stops after delivery or premature mission termination.

## 5. CAS remains MOOSE-only

The CAS correction does not use this exception. CAS routing remains public MOOSE only:

```text
native AUFTRAG ingress at common-route entry
-> mission-owned R500/WEST outbound FLIGHTGROUP waypoints
-> PATROLZONE / EngageDetected
-> AUFTRAG cancellation on tactical clear
-> non-mission-owned WEST/R500 recovery waypoints survive mission cleanup
-> Jalalabad recovery
```

`OMW_HelicopterMissionOwnedCorridor.lua` version 4 implements this ownership split.

## 6. Pinned-source verification used by the implementation

The actual pinned `Moose.lua` was checked for the methods and structures used here:

```text
AUFTRAG:NewCARGOTRANSPORT(...)
AUFTRAG:IsOver()
AUFTRAG Success FSM transition
OPSGROUP/FLIGHTGROUP:GetWaypointCurrentUID()
OPSGROUP/FLIGHTGROUP:AddWaypoint(...)
OPSGROUP/FLIGHTGROUP:AddTaskWaypoint(task, waypoint, description, prio, duration)
OPSGROUP/FLIGHTGROUP:UpdateRoute()
DCS CargoTransportation task structure used by AUFTRAG
```

This is source verification only. It does not prove that DCS will preserve the physical slingload across the deliberate route handoff.

## 7. Required DCS acceptance

The next acceptance must prove the exact sequence rather than only mission success:

```text
CH-47 spawn
-> physical slingload pickup at Jalalabad
-> R500 outbound after pickup
-> no direct pickup-to-Wright shortcut
-> Wright-side CargoTransportation task
-> physical slingload release in Wright drop zone
-> R500 reverse
-> Jalalabad landing
-> AIRWING recovery
```

It must also verify that the handoff does not detach, destroy, duplicate or strand the slingload and does not recreate the Build-1-13 return-phase performance collapse.

CAS must independently prove:

```text
Jalalabad
-> R500
-> WEST
-> CAS
-> WEST reverse after mission cancellation
-> R500 reverse
-> Jalalabad
```

## 8. Status

```text
owner exception approval: YES, narrow Stage-3 slingload corridor scope only
MOOSE gap documented: YES
runtime implementation: SOURCE COMPLETE
DCS validation: PENDING
production validation: NO
```
