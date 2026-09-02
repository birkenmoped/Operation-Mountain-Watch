---
document_id: OMW-TEST-STAGE3-BUILD-1-13-RETURN-LIFECYCLE-2026-09-02
status: PLANNED
document_class: TEST_EVIDENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - exact-provenance Stage 3 build 1-13 DCS runtime observations on 2026-09-02
  - CAS route-order failure
  - CH-47 pickup/corridor-order failure
  - QRF missing post-incident return
  - post-combat main-thread performance degradation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: 08cebb9835936b30079ce0b387864f2bf44bad52
supersedes:
superseded_by:
validated_in_dcs: false
---

# Stage 3 Build 1-13 – Return-Lifecycle Runtime FAIL 2026-09-02

## 1. Exakte Build-Provenienz

Realer lokaler Build des Projektinhabers:

```text
BuilderVersion: STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-13
GitCommit: 08cebb9835936b30079ce0b387864f2bf44bad52
MOOSECommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
MooseLuaSHA256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
Bundle SHA256: 9C0C425E52C0E5B0E4E9941C6FE568FAD855C85BB8920F70DC38C6221861AE61
MizMutation: false
```

Der Builder-Hash und ein unmittelbar danach ausgeführtes `Get-FileHash -Algorithm SHA256` stimmten überein.

## 2. Ergebnisgrenze

Der Acceptance-Source erreichte im DCS-Log zwar seinen internen `[STAGE 3][PASS]` und bestätigte unter anderem Wright `30/30`, CH-47-Landung und AIRWING-Recovery. Dieser interne PASS ist **kein Projekt-VALIDATED**, weil die visuelle und zeitliche Runtime-Sequenz mehrere bindende Sollabläufe verletzt.

```text
Stage-3 internal script gate: PASS
Project acceptance: FAIL
validated_in_dcs: false
```

## 3. Positiv bestätigte Build-1-13-Funktionen

Realer DCS-Lauf bestätigte:

```text
Honaker Guard PATHLINE preflight resolved
Guard physically materialized
mixed-6 QRF physically materialized
Wright live ARTY fire executed
local M1083 rearm executed
CampaignState Wright AMMO crossed 16 -> 15
one strategic RESUPPLY demand created
Jalalabad CH-47 physically spawned
physical slingload pickup occurred
physical Wright delivery occurred
Wright strategic stock restored to 30 / 30
CH-47 returned to Jalalabad and AIRWING recovery event fired
AH-64 physically spawned, reached AO and employed weapons
```

## 4. CAS route-order FAIL

Owner-confirmed intended sequence:

```text
CAS request
-> AH-64 spawn Jalalabad
-> fly to common-route entry
-> common route / R500
-> branch WEST
-> WEST toward AO
-> leave WEST near AO
-> CAS / S&D
-> recover to WEST near AO
-> WEST reverse
-> common route / R500 reverse
-> Jalalabad
-> land / recovery
```

Observed Build-1-13 behavior:

```text
AH-64 spawn
-> initial direct flight toward AO
-> turn back toward the Jalalabad-side route beginning
-> then traverse injected R500/WEST corridor
-> CAS
-> return sequence with large route stack
```

The logged corridor contained approximately the complete outbound plus return path at once. The CAS route profile reached outbound index 36 / UID 40 and return-route index 35 / UID 75.

Root cause found in source review after the DCS run:

```lua
-- build 1-13 adapter behavior
local ingressCoordinate = resolved.outbound[#resolved.outbound]
```

The adapter made the native MOOSE AUFTRAG ingress the **last** corridor coordinate near the AO. Pinned `Moose.lua` RouteToMission semantics place native ingress before the mission execution waypoint. Therefore MOOSE first routed toward the AO-side ingress, after which the injected route forced the aircraft back through the earlier corridor points.

The next source revision changes native ingress to:

```lua
local ingressCoordinate = resolved.outbound[1]
```

and injects only outbound points `2..N` after that native ingress.

## 5. CH-47 pickup/corridor-order FAIL

Owner-confirmed intended sequence:

```text
RESUPPLY request
-> CH-47 + slingload spawn
-> CH-47 picks up slingload
-> common-route entry
-> common route / R500 toward Wright
-> leave route at Wright
-> deliver
-> rejoin route near Wright
-> R500 reverse
-> Jalalabad
-> land / recovery
```

Observed Build-1-13 behavior:

```text
CH-47 assigned
-> corridor installed before physical pickup
-> CH-47 flew outbound without slingload
-> returned to Jalalabad pickup area
-> physical slingload pickup
-> subsequent transport/delivery
```

Log chronology proves the ordering defect:

```text
18:29:20  CH-47 assigned; manifest loading
18:29:22  AIR-AMMO outbound/return corridor profile installed
18:40:31  Air-AMMO cargo picked up / IN TRANSIT
18:45:49  Air-AMMO delivered at Wright / Wright 30/30
19:05:24  CH-47 landed Jalalabad
19:05:25  CH-47 recovered by AIRWING
```

The next source revision therefore does not call the corridor installer in `OnAfterFlightOnMission`. It waits until the existing physical-pickup evidence detects that the slingload has left the Jalalabad pickup zone, stops that temporary polling scheduler, marks the transfer `IN_TRANSIT`, and only then injects the outbound/return corridor.

## 6. QRF recovery FAIL

Observed:

```text
mixed-6 QRF deployed physically
combat/incident ended
surviving QRF remained at its last field position
no automatic return to Honaker occurred
```

Build 1-13 created `AUFTRAG:NewONGUARD` but did not set or trigger a post-incident MOOSE recovery lifecycle.

Pinned MOOSE 2.9.18 provides the required public path:

```text
AUFTRAG:SetReturnToLegion(true)
mission:Cancel()
-> OPSGROUP MissionDone
-> ARMYGROUP RTZ to legion spawn zone
-> ARMYGROUP Returned
-> LEGION/Warehouse asset return
```

The next source revision uses this path and settles the existing `GroundPersonnelDeploymentLedger` only after physical `ARMYGROUP:OnAfterReturned`, using surviving infantry count and excluding the single `CHAP_MATV` vehicle from the five-person strategic reservation.

## 7. Post-combat performance FAIL

Owner observation is important and narrows the problem:

```text
combat phase: normal/good frame rate
return/post-combat phase: severe main-thread degradation
```

Screenshots showed DCS reporting CPU/main-thread bound behavior, with the frame rate dropping into approximately the 10-30 FPS range and pronounced frame-time spikes.

The DCS log contains repeated `ModelTimeQuantizer: SAME MODEL TIME` / `ANTIFREEZE ENABLED` warnings during and after the return phase. These warnings are treated as **symptoms/evidence of simulation stress, not a proven OMW root cause**.

Build 1-13 also left avoidable periodic work active after the incident:

```text
Honaker OPSZONE: updateSeconds=5 continued after attack-incident closure
Stage-3 finish scheduler: repeated every 2 seconds and continued even after internal PASS
```

The next source revision performs bounded cleanup:

```text
attack incident truly closed
-> FobThreatOpsZoneAdapter:Stop()
-> MOOSE OPSZONE:Stop()

Stage-3 PASS or FAIL
-> stop Stage-3 finish scheduler
```

The Guard patrol remains active by design. No claim is made that these two cleanup changes alone explain or fix the complete FPS problem; Build 1-14 must verify the return phase again in DCS.

## 8. MOOSE-first basis for next revision

Verified in the pinned `Moose.lua`:

```text
AUFTRAG:SetMissionIngressCoord(...)
AUFTRAG:SetMissionEgressCoord(...)
AUFTRAG:GetGroupWaypointIndex(...)
AUFTRAG:GetGroupEgressWaypointUID(...)
FLIGHTGROUP:AddWaypoint(...)
FLIGHTGROUP:UpdateRoute()
AUFTRAG:SetReturnToLegion(true)
AUFTRAG:Cancel()
OPSGROUP MissionDone / _CheckGroupDone
ARMYGROUP RTZ / Returned
OPSZONE:Stop()
```

No MIST, native DCS controller, teleport, direct coalition spawn, or parallel mission system is introduced.

## 9. Build 1-14 acceptance focus

The next DCS run must distinguish four independent gates:

```text
CAS route order:
  no initial direct Jalalabad -> AO leg
  route entry first
  R500 -> WEST -> CAS -> WEST reverse -> R500 reverse -> Jalalabad

CH-47 route order:
  slingload pickup first
  corridor only after pickup
  Wright delivery
  route return

QRF recovery:
  incident closure -> Cancel/ReturnToLegion
  physical return to Honaker
  Returned/Warehouse callback
  personnel reservation settlement

performance:
  no severe sustained main-thread/FPS collapse during return/post-combat phase
  compare log timing and screenshots against Build 1-13
```

Weapon-employment quality for AH-64 (limited rockets followed mainly by gun, no satisfactory Hellfire/standoff behavior observed) remains a separate follow-up issue and is not silently conflated with the route-order correction.
