---
document_id: OMW-MOOSE-STAGE3-CAS-CARGOTRANSPORT-ROUTE-LIFECYCLE-GAP
status: PLANNED
document_class: MOOSE_TECHNICAL_RECONCILIATION
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 3 Build 1-14 route-lifecycle source review after local build
  - CAS cancellation versus recovery-route ownership
  - MOOSE 2.9.18 CARGOTRANSPORT routing capability boundary
  - decision boundary for physical slingload routing
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
supersedes:
superseded_by:
validated_in_dcs: false
---

# Stage 3 – CAS / CARGOTRANSPORT Route-Lifecycle Gap

## 1. Anlass

Nach dem realen lokalen Build von Stage-3 Build `1-14` wurde vor einem weiteren DCS-Lauf die Route-Lifecycle-Reihenfolge erneut gegen den tatsächlich gepinnten MOOSE-Stand geprüft.

Build `1-14` ist deshalb **nicht für einen DCS-Acceptance-Lauf freigegeben**. Zwei Punkte wurden nach dem Build als noch nicht korrekt geschlossen erkannt:

```text
CAS return corridor survives AUFTRAG cancellation     NOT YET TRUE
physical slingload outbound corridor after pickup     NO PUBLIC MOOSE PATH FOUND
```

Der Build bleibt historische lokale Build-Provenienz, aber kein DCS-validierter Stand.

## 2. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Maßgeblich ist die tatsächlich verwendete `Moose.lua`.

Zusätzlich geprüft wurden die öffentliche MOOSE-AUFTRAG-Dokumentation und die offiziellen MOOSE-Demo-/Repository-Suchen. Für `AUFTRAG:NewCARGOTRANSPORT()` wurde kein offizielles Beispiel gefunden, das einen frei vorgegebenen Flugweg zwischen physischem Slingload-Pickup und dem durch den DCS-`CargoTransportation`-Task bestimmten Drop-Ziel einfügt.

## 3. CAS – Build-1-14-Outbound ist strukturell korrigiert

Build `1-14` änderte den nativen AUFTRAG-Ingress von der AO-Seite auf den ersten owner-authored Corridor-Punkt:

```lua
local ingressCoordinate = resolved.outbound[1]
```

Der gepinnte `OPSGROUP:RouteToMission()`-Pfad erzeugt für FLIGHTGROUPS:

```text
existing route
-> optional mission ingress
-> mission execution waypoint
-> optional mission egress
```

Der Stage-3-Adapter fügt `resolved.outbound[2..N]` zwischen nativen Ingress und Missionswegpunkt ein.

Damit ist der Outbound-Sourcepfad logisch:

```text
Jalalabad
-> common-route entry
-> R500
-> WEST
-> PATROLZONE/CAS
```

Dieser Teil bleibt DCS-pending, ist aber source-seitig konsistent mit `RouteToMission()`.

## 4. CAS – Build-1-14-Return ist noch nicht korrekt

Der Build-1-14-Adapter markiert derzeit sowohl Outbound- als auch Return-Waypoints mit:

```lua
waypoint.missionUID = mission.auftragsnummer
```

Die CAS-Closure ruft über `OMW_FobAttackCasDispatchAdapter:RequestMissionClosure()`:

```lua
mission:Cancel()
```

Der gepinnte MOOSE-Pfad ist:

```text
AUFTRAG:Cancel()
-> LEGION/OPSGROUP:MissionCancel()
-> current task cancel / MissionDone
-> OPSGROUP:_RemoveMissionWaypoints(Mission)
```

`OPSGROUP:_RemoveMissionWaypoints()` entfernt **alle** Waypoints, deren `missionUID` der AUFTRAG-ID entspricht.

Damit werden in Build `1-14` beim taktischen CAS-Ende auch die als Mission-Waypoints markierten Recovery-Waypoints entfernt. Anschließend kann MOOSE seinen normalen Aircraft-RTB-Pfad verwenden; der owner-authored

```text
WEST reverse -> R500 reverse
```

ist dadurch nicht garantiert.

### 4.1 MOOSE-first Korrekturrichtung

Der kleinste source-seitig belegte MOOSE-first Ansatz ist:

```text
Outbound corridor points
-> mission-owned (`missionUID` set)

PATROLZONE mission waypoint
-> MOOSE AUFTRAG-owned

Recovery corridor points after mission waypoint
-> normal FLIGHTGROUP waypoints (`missionUID` deliberately NOT set)

TACTICAL_AREA_CLEAR
-> AUFTRAG:Cancel()
-> MOOSE removes only AUFTRAG-owned mission/outbound waypoints
-> recovery waypoints remain
-> FLIGHTGROUP continues WEST reverse -> R500 reverse
-> normal AIRWING/base return remains after recovery route
```

The pinned `_CheckGroupDone()` path explicitly keeps an AI group moving when no tasks/missions remain but final waypoints have not yet been passed: it calls `Cruise()` while `#self.waypoints > 0` and the final waypoint is still pending.

This correction uses public `FLIGHTGROUP:AddWaypoint()` / `UpdateRoute()` behavior and MOOSE's own mission-cleanup mechanism. It does not require a native DCS controller. It still requires DCS validation before acceptance.

## 5. CARGOTRANSPORT – exact pinned-MOOSE behavior

`AUFTRAG:NewCARGOTRANSPORT(StaticCargo, DropZone)` creates a helicopter mission whose DCS mission task is:

```lua
{
  id = "CargoTransportation",
  params = {
    groupId = StaticCargo:GetID(),
    zoneId = DropZone.ZoneID,
    zone = DropZone,
    cargo = StaticCargo,
  }
}
```

The AUFTRAG target is the physical static cargo itself.

`OPSGROUP:RouteToMission()` therefore routes the helicopter to the cargo mission waypoint. The `CargoTransportation` task starts there and owns the physical slingload pickup/delivery operation.

This matches the real Build-1-13 runtime observation:

```text
mission route manipulation before task
-> helicopter traversed injected route without slingload
-> returned to cargo
-> CargoTransportation task picked up slingload
-> task then transported directly toward Wright
```

## 6. Why Build 1-14 still cannot enforce the requested outbound slingload route

Build `1-14` correctly delays corridor injection until physical pickup evidence exists. However the adapter then calls the legacy generic corridor installer.

That installer adds the outbound corridor **before the AUFTRAG mission waypoint**. At that time the helicopter has already reached/passed the pickup mission waypoint and the `CargoTransportation` task is active.

Therefore the desired sequence

```text
pickup
-> R500 outbound
-> Wright
```

cannot be guaranteed by inserting normal route waypoints before the already active mission task.

More importantly, interrupting/replacing the route while the cargo task is active is explicitly unsafe as a general pattern: the pinned MOOSE FREIGHTTRANSPORT implementation contains a source comment warning that `UpdateRoute` can overwrite the cargo task and therefore clears pending `UpdateRoute` FSM events before assigning its cargo-loading task.

## 7. Public MOOSE alternatives checked

### 7.1 `AUFTRAG:NewCARGOTRANSPORT`

Provides real external slingload pickup/drop, but no public parameter or method was found for a transport path between pickup and drop while the `CargoTransportation` task is executing.

### 7.2 `OPSTRANSPORT`

The pinned MOOSE release provides:

```lua
OPSTRANSPORT:New(...)
OPSTRANSPORT:AddPathTransport(PathGroup, Reversed, Radius, TransportZoneCombo)
```

and the carrier FSM explicitly uses `TransportPaths` between pickup and deploy zones.

For `STORAGE` cargo, however, the implementation removes warehouse inventory and places it in the carrier's MOOSE cargo bay. It is an internal/abstract storage transport, not the current physical external DCS slingload static used by Stage 3.

Therefore `OPSTRANSPORT` is a valid pure-MOOSE routed logistics alternative only if the Stage-3 requirement for a visibly attached external slingload is relaxed.

### 7.3 MOOSE CTLD / DYNAMICCARGO

Pinned MOOSE CTLD/DYNAMICCARGO includes player-oriented slingload support and CH-47 cargo handling, but no verified autonomous AI transport path was found that replaces `AUFTRAG:NewCARGOTRANSPORT()` for this Stage-3 AIRWING mission.

## 8. Current capability boundary

For the exact pinned MOOSE version, the review concludes:

```text
CAS outbound owner-authored route                     PUBLIC MOOSE PATH EXISTS
CAS owner-authored recovery after PATROLZONE cancel   PUBLIC MOOSE PATH EXISTS via non-mission FLIGHTGROUP recovery waypoints; DCS pending

CH-47 physical slingload pickup/drop                  PUBLIC MOOSE AUFTRAG path exists
CH-47 owner-authored return route after delivery      PUBLIC MOOSE waypoint path exists
CH-47 owner-authored route BETWEEN pickup and drop    NO PUBLIC MOOSE PATH VERIFIED

OPSTRANSPORT routed transport                         PUBLIC MOOSE path exists
OPSTRANSPORT visible external slingload               NOT PROVIDED by reviewed path
```

No official MOOSE demo/example was found that closes the missing `CARGOTRANSPORT` pickup-to-drop routing gap.

## 9. Owner decision required before runtime implementation

The project owner must choose one of the following architecture outcomes before Stage-3 resupply routing can be changed further:

```text
A. Preserve physical external slingload + exact owner-authored outbound route
   -> requires a narrowly scoped non-MOOSE/native-DCS exception for the active
      CargoTransportation phase, after the MOOSE gap documented above.

B. Preserve strict MOOSE-only routing
   -> switch the physical transport execution to OPSTRANSPORT/AddPathTransport,
      accepting that reviewed STORAGE transport is internal/abstract and not the
      current visible external slingload.

C. Preserve AUFTRAG:NewCARGOTRANSPORT without exception
   -> accept DCS/MOOSE-owned direct pickup-to-drop flight; only post-delivery return
      can be constrained to the owner-authored route.
```

No option is selected silently in this document.

## 10. Current status

```text
Build 1-14 local build provenance   CONFIRMED
Build 1-14 DCS test                 WITHHELD
CAS outbound source order           SOURCE REVIEWED
CAS recovery ownership              FIX REQUIRED / PUBLIC MOOSE PATH IDENTIFIED
CARGOTRANSPORT exact outbound path  BLOCKED_BY_VERIFIED_MOOSE_GAP
owner exception/architecture choice REQUIRED
validated_in_dcs                    false
```
