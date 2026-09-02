---
document_id: OMW-TEST-STAGE3-BUILD-1-13-RETURN-LIFECYCLE-2026-09-02
status: PLANNED
document_class: TEST_EVIDENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - exact-provenance Stage 3 build 1-13 DCS runtime observations on 2026-09-02
  - CAS route-order failure
  - premature attack-incident closure relative to the wider tactical response
  - CH-47 pickup/corridor-order failure
  - QRF missing post-response return
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

Builder-Hash und anschließend ausgeführtes `Get-FileHash -Algorithm SHA256` stimmten überein.

## 2. Ergebnisgrenze

Der Acceptance-Source erreichte im DCS-Log zwar seinen internen `[STAGE 3][PASS]`. Dieser interne PASS ist **kein Projekt-VALIDATED**, weil mehrere bindende physische Abläufe verletzt wurden.

```text
Stage-3 internal script gate: PASS
Project acceptance: FAIL
validated_in_dcs: false
```

Positiv bestätigt wurden Guard-Materialisierung/PATHLINE-Grundlage, Mixed-6-QRF-Materialisierung, Wright-Live-ARTY, lokales M1083-Rearm, CampaignState-AMMO `16 -> 15`, genau ein strategischer RESUPPLY, physischer CH-47/Slingload-Pickup, Wright-Delivery und Wiederherstellung auf `30 / 30`, CH-47-Landung/AIRWING-Recovery sowie physischer AH-64-Einsatz mit Waffenabgabe.

## 3. CAS route-order FAIL

Owner-confirmed Sollablauf:

```text
CAS request
-> AH-64 spawn Jalalabad
-> common-route entry
-> R500
-> WEST
-> leave WEST near AO
-> CAS / S&D
-> recover to WEST near AO
-> WEST reverse
-> R500 reverse
-> Jalalabad
-> land / AIRWING recovery
```

Beobachtet wurde dagegen zunächst ein Direktflug Richtung AO, anschließend Umkehr zum Jalalabad-seitigen Routenanfang und erst danach der lange R500/WEST-Corridor.

Der Log zeigt für Build 1-13 die komplette Route mit bis zu `outbound index 36 / UID 40` und `returnRoute index 35 / UID 75`.

Source-Review ergab die konkrete Ursache:

```lua
local ingressCoordinate = resolved.outbound[#resolved.outbound]
```

Damit wurde der native MOOSE-AUFTRAG-Ingress auf das AO-seitige **Ende** des Korridors gesetzt. Gepinnter MOOSE-Source zeigt, dass `RouteToMission` den nativen Mission-Ingress vor den Mission-Execution-Waypoint legt. Die nächste Revision verwendet daher:

```lua
local ingressCoordinate = resolved.outbound[1]
```

und injiziert danach nur die verbleibenden Corridor-Punkte `2..N`.

## 4. Premature response-closure FAIL

Build 1-13 schloss den OMW-Attack-Incident bereits um ungefähr `18:28:05`, nachdem die damals gespeicherten bekannten Incident-Participants tot waren. Das war für die **gesamte** Response-Kette zu früh: der AH-64-PATROLZONE-Auftrag erreichte `Executing` erst ungefähr `18:48:22` und lieferte die erste bestätigte Waffenabgabe ungefähr `18:48:58`.

Damit ist belegt:

```text
known incident participant list empty
!= wider tactical response area clear
```

Für Build 1-14 wird deshalb die Response-Closure nicht mehr allein an `HasAliveParticipants()==false` gebunden. Zusätzlich wird mit öffentlichen MOOSE-`SET_GROUP`-Filtern geprüft, ob im gemeinsamen 5-NM-QRF/CAS-Taktikraum noch aktive RED-Ground-GROUPs vorhanden sind:

```text
SET_GROUP:New()
-> FilterCoalitions("red")
-> FilterCategoryGround()
-> FilterActive(true)
-> FilterZones({tacticalZone})
-> FilterOnce()
-> CountAlive()
```

Erst bei `CountAlive()==0` wird die Response mit `TACTICAL_AREA_CLEAR` geschlossen, CAS beendet, QRF zurückgerufen und der 5-Sekunden-OPSZONE-Alarm-Scan gestoppt. Das ist ein Acceptance-spezifisches Completion-Gate; es ersetzt keine allgemeine CampaignState- oder Detection-Autorität.

## 5. CH-47 pickup/corridor-order FAIL

Owner-confirmed Sollablauf:

```text
RESUPPLY request
-> CH-47 + slingload spawn
-> slingload pickup
-> common-route entry
-> R500 toward Wright
-> leave route / deliver
-> rejoin R500
-> R500 reverse
-> Jalalabad
-> land / AIRWING recovery
```

Build 1-13 installierte die Corridor-Route bereits beim `FlightOnMission`-Callback. Der reale Log belegt:

```text
18:29:20  CH-47 assigned / loading
18:29:22  AIR-AMMO outbound + return corridor installed
18:40:31  physical cargo pickup / IN_TRANSIT
18:45:49  delivered at Wright / Wright 30/30
19:05:24  landed Jalalabad
19:05:25  AIRWING recovery
```

Damit wurde der Korridor **vor** dem Slingload-Pickup aktiviert. Build 1-14 verschiebt die Corridor-Installation hinter den vorhandenen physischen Pickup-Nachweis: erst wenn der Cargo-Static die Jalalabad-Pickup-Zone tatsächlich verlassen hat, wird `IN_TRANSIT` gesetzt, der temporäre Pickup-Scheduler gestoppt und die R500-Outbound/Return-Route installiert.

## 6. QRF recovery FAIL

Build 1-13 materialisierte die owner-approved Mixed-6-QRF korrekt, hatte aber keinen Post-Response-Return. Überlebende blieben nach Ende der Kampfhandlungen im Feld stehen.

Der gepinnte MOOSE-Source bietet hierfür den öffentlichen Lifecycle:

```text
AUFTRAG:SetReturnToLegion(true)
mission:Cancel()
-> OPSGROUP MissionDone
-> ARMYGROUP RTZ
-> ARMYGROUP Returned
-> LEGION/Warehouse asset return
```

Build 1-14 aktiviert `SetReturnToLegion(true)` bereits am QRF-AUFTRAG und ruft `Cancel()` erst nach dem oben beschriebenen `TACTICAL_AREA_CLEAR` auf. Strategische PERSONNEL-Rückgabe erfolgt erst bei physischem `ARMYGROUP:OnAfterReturned` über den vorhandenen `GroundPersonnelDeploymentLedger:SettleReturned(survivors)`. Für das exakt bekannte `TPL_BLUE_GND_QRF_MIXED_6` werden dabei lebende Infanteristen gezählt und das einzelne `CHAP_MATV` nicht als PERSONNEL gewertet.

## 7. Post-combat performance FAIL

Owner-Beobachtung:

```text
combat phase: good/normal FPS
return/post-combat phase: severe CPU/main-thread degradation
```

Screenshots zeigen DCS in der Rückkehrphase als `CPU BOUND (main thread)` mit starken Frame-Time-Spikes. Im Log treten in dieser Phase wiederholt `ModelTimeQuantizer: SAME MODEL TIME` und `ANTIFREEZE ENABLED` auf. Diese Meldungen sind **Symptome**, kein bewiesener Root Cause.

Build 1-13 ließ zudem vermeidbare periodische Acceptance-Arbeit weiterlaufen:

```text
Honaker OPSZONE updateSeconds=5
Stage-3 finish check every 2 seconds
```

Build 1-14 ändert deshalb nur klar begründete Cleanup-Punkte:

```text
TACTICAL_AREA_CLEAR
-> FobThreatOpsZoneAdapter:Stop()
-> MOOSE OPSZONE:Stop()

Stage-3 completion check
-> 10-second cadence statt 2 seconds
-> SCHEDULER:Stop() on PASS/FAIL
```

Der Guard-Patrol bleibt absichtlich aktiv. Es wird ausdrücklich **nicht** behauptet, dass diese Cleanup-Maßnahmen allein den FPS-Einbruch beheben. Das ist im nächsten DCS-Lauf zu verifizieren.

## 8. MOOSE-first Basis Build 1-14

Im tatsächlich gepinnten `Moose.lua` wurden geprüft:

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
SET_GROUP FilterCoalitions / FilterCategoryGround / FilterActive / FilterZones / FilterOnce / CountAlive
OPSZONE:Stop()
```

Kein MIST, kein nativer DCS-Controller, kein Teleport und kein paralleles Missionssystem werden eingeführt.

## 9. Build 1-14 Acceptance-Fokus

```text
CAS:
  no initial Jalalabad -> AO shortcut
  common-route entry first
  R500 -> WEST -> CAS -> WEST reverse -> R500 reverse -> Jalalabad

Response completion:
  known participants dead is not sufficient
  zero active RED ground groups in shared 5-NM tactical area required

CH-47:
  slingload pickup before corridor ingress
  Wright delivery
  R500 return

QRF:
  no return while tactical RED remains
  tactical clear -> Cancel/ReturnToLegion
  physical return to Honaker
  Returned/Warehouse callback
  personnel settlement

Performance:
  compare return/post-combat main-thread behavior against Build 1-13
```

Die weiterhin unbefriedigende AH-64-Waffenwahl bzw. fehlende verlässliche Hellfire-/Standoff-Wirkung bleibt ein separater Follow-up-Punkt und wird nicht mit der Routingkorrektur vermischt.
