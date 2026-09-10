---
document_id: OMW-MOOSE-STAGE3-BUILD-1-14-RETURN-LIFECYCLE-SOURCE-REVIEW
status: PLANNED
document_class: MOOSE_TECHNICAL_RECONCILIATION
owning_policy: OMW-GOV-001
authoritative_for:
  - pinned-MOOSE source review for Stage 3 build 1-14 CAS route ordering
  - pinned-MOOSE source review for Stage 3 mixed-QRF return lifecycle
  - pinned-MOOSE source review for Stage 3 tactical-clear and OPSZONE cleanup
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
supersedes:
superseded_by:
validated_in_dcs: false
---

# Stage 3 Build 1-14 – MOOSE Return-Lifecycle Source Review

## 1. Zweck

Build 1-13 bestätigte physische CAS-, ARTY-, QRF- und CARGOTRANSPORT-Ausführung, zeigte aber falsche Flugreihenfolgen, fehlenden QRF-RTB und einen massiven Main-Thread-Einbruch in der Rückkehr-/Post-Combat-Phase.

Diese Datei dokumentiert die MOOSE-first-Prüfung für die Korrekturen in Build 1-14. Sie ist **kein** DCS-Validierungsnachweis.

## 2. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Maßgeblich war die tatsächlich projektseitig verwendete `Moose.lua`. Ein anderer Commit oder Hash erfordert erneute Prüfung.

## 3. CAS – native AUFTRAG ingress/egress ownership

Im gepinnten MOOSE-Source wurden folgende öffentliche Methoden geprüft:

```lua
AUFTRAG:SetMissionIngressCoord(...)
AUFTRAG:SetMissionEgressCoord(...)
AUFTRAG:GetGroupWaypointIndex(...)
AUFTRAG:GetGroupEgressWaypointUID(...)
FLIGHTGROUP:AddWaypoint(...)
FLIGHTGROUP:UpdateRoute()
```

Der relevante `OPSGROUP:RouteToMission`-Pfad fügt den optionalen Mission-Ingress **vor** dem eigentlichen Mission-Execution-Waypoint ein und den Egress nach der Mission.

Daraus folgt für den owner-defined OMW-Corridor zwingend:

```text
native mission ingress
= corridor entry nearest Jalalabad/origin
!= corridor end nearest Honaker/AO
```

Build 1-13 verwendete fälschlich:

```lua
local ingressCoordinate = resolved.outbound[#resolved.outbound]
```

Build 1-14 verwendet deshalb:

```lua
local ingressCoordinate = resolved.outbound[1]
```

Der native Ingress repräsentiert damit den ersten owner-authored Corridor-Punkt. Der Adapter injiziert anschließend nur `resolved.outbound[2..N]` zwischen Ingress und Mission. Nach dem Mission-Waypoint werden die Return-Punkte bis zum nativen Jalalabad-seitigen Egress eingefügt.

Alle injizierten Punkte erhalten weiterhin `waypoint.missionUID = mission.auftragsnummer`, damit MOOSE sie dem AUFTRAG-Lifecycle zuordnen kann. Es wird kein nativer DCS-Controller verwendet.

Status:

```text
method existence/signatures        SOURCE REVIEWED
RouteToMission ordering            SOURCE REVIEWED
Build-1-14 composition             SOURCE REVIEWED
physical route order               DCS PENDING
altitude/profile behavior          DCS PENDING
```

Für diese exakte Kombination wurde in den geprüften offiziellen MOOSE-Demos kein direkt passendes `SetMissionIngressCoord`-Beispiel gefunden. Deshalb wird keine Demo-Validierung behauptet.

## 4. CH-47 – CARGOTRANSPORT pickup before corridor injection

Build 1-13 installierte den R500-Corridor unmittelbar in `AIRWING:OnAfterFlightOnMission`. Der reale DCS-Log zeigte dadurch Corridor-Installation ungefähr elf Minuten **vor** dem physischen Slingload-Pickup.

Build 1-14 ändert nicht die MOOSE-CARGOTRANSPORT-Mechanik. `AUFTRAG:NewCARGOTRANSPORT(...)` bleibt Auftragseigentümer für Pickup und Delivery.

Der OMW-Corridor wird erst nach dem vorhandenen physischen Evidence-Gate installiert:

```text
cargo remains inside Jalalabad pickup zone
-> still loading / no corridor injection

cargo leaves pickup zone while alive
-> MarkInTransit
-> stop temporary pickup scheduler
-> install owner-authored R500 corridor
```

Damit gilt die Sollreihenfolge:

```text
spawn
-> MOOSE CARGOTRANSPORT pickup
-> R500 outbound
-> Wright delivery
-> R500 reverse
-> Jalalabad
```

Status:

```text
CARGOTRANSPORT ownership            existing / retained
pickup evidence gate               existing behavior reused
corridor-after-pickup ordering      SOURCE REVIEWED
physical runtime order              DCS PENDING
```

## 5. Mixed-6 QRF – MOOSE ReturnToLegion lifecycle

Für die Ground-QRF wurden im gepinnten MOOSE-Source geprüft:

```lua
AUFTRAG:SetReturnToLegion(true)
AUFTRAG:Cancel()
```

sowie der nachfolgende MOOSE-Lifecycle über:

```text
OPSGROUP MissionDone / _CheckGroupDone
-> ARMYGROUP RTZ
-> ARMYGROUP Returned
-> LEGION / Warehouse return
```

`SetReturnToLegion(true)` ist für den hier verwendeten Ground-AUFTRAG relevant; Air-Groups haben einen eigenen Rückkehrpfad.

Build 1-14 setzt `SetReturnToLegion(true)` am QRF-`AUFTRAG:NewONGUARD(...)`. Die Mission wird nach taktischer Freigabe mit `Cancel()` beendet. Erst `ARMYGROUP:OnAfterReturned` dient als physischer Rückkehrbeleg für die strategische PERSONNEL-Abrechnung.

Der bestehende `OMW_GroundPersonnelDeploymentLedger` wird unverändert als strategischer Adapter verwendet:

```text
deployment
-> reserve 5 GROUND_PERSONNEL

physical Returned
-> count surviving infantry in exact mixed-6 template
-> SettleReturned(survivors)
-> release deployment reservation
-> consume confirmed casualties only
```

Die Identifikation des einen Nicht-PERSONNEL-Assets ist acceptance-spezifisch und basiert auf der aktuellen Mission-Editor-Zusammensetzung:

```text
TPL_BLUE_GND_QRF_MIXED_6
1 x CHAP_MATV
3 x Soldier M4
2 x Soldier M249
```

Status:

```text
SetReturnToLegion API               SOURCE REVIEWED
Cancel/MissionDone/RTZ/Returned     SOURCE REVIEWED
ARMYGROUP Returned in project       previously validated in documented Ground scopes
Build-1-14 QRF application          DCS PENDING
PERSONNEL settlement                DCS PENDING for this mixed-6 acceptance
```

## 6. Response completion – 5-NM tactical-clear gate

Build 1-13 bewies, dass die gespeicherte Participant-Liste des Attack-Incidents für das Ende der gesamten Response zu eng war: sie war bereits leer, lange bevor der AH-64-PATROLZONE-Auftrag tatsächlich `Executing` erreichte.

Build 1-14 verwendet deshalb für das **Acceptance-Completion-Gate** zusätzlich öffentliche MOOSE-`SET_GROUP`-Filter:

```lua
SET_GROUP:New()
  :FilterCoalitions("red")
  :FilterCategoryGround()
  :FilterActive(true)
  :FilterZones({ tacticalZone })
  :FilterOnce()
  :CountAlive()
```

Die Response wird erst beendet, wenn:

```text
known attack participants alive == 0
AND
active RED ground groups in shared 5-NM CAS/QRF tactical zone == 0
```

Dieses Gate ist eine Stage-3-Acceptance-Definition für das Ende des konkreten taktischen Ereignisses. Es wird **nicht** als neue strategische Detection-/CampaignState-Autorität eingeführt.

Status:

```text
SET_GROUP methods                   SOURCE REVIEWED
5-NM completion composition         SOURCE REVIEWED
physical tactical-clear behavior    DCS PENDING
```

## 7. OPSZONE und Acceptance-Scheduler cleanup

Der bereits vorhandene `OMW_FobThreatOpsZoneAdapter` besitzt `Stop()`, das den zugrunde liegenden MOOSE-`OPSZONE:Stop()`-Pfad verwendet.

Build 1-14 stoppt den Honaker-Alarm-OPSZONE erst nach `TACTICAL_AREA_CLEAR`. Während des laufenden Angriffs bleibt der 5-Sekunden-Scan aktiv.

Zusätzlich wird der Stage-3-Completion-Scheduler von zwei auf zehn Sekunden reduziert und auf `PASS`/`FAIL` gestoppt. Das ist eine Acceptance-Hygienemaßnahme; es wird **nicht** behauptet, dass diese beiden Scheduler allein den beobachteten FPS-Einbruch verursachten.

Status:

```text
OPSZONE:Stop                       SOURCE REVIEWED
adapter Stop path                   SOURCE REVIEWED
post-response FPS effect            DCS PENDING
```

## 8. Nicht Bestandteil dieses Fixes

Die Build-1-13-Waffenwirkung der AH-64 war weiterhin unbefriedigend: wenige ungelenkte Raketen, danach überwiegend Gun und kein belastbarer Hellfire-/Standoff-Einsatz. Dieses Thema bleibt getrennt von Route-/Return-Lifecycle und wird nicht durch Build 1-14 als gelöst dargestellt.

Ebenfalls noch offen ist die beobachtete Slingload-Spawnposition außerhalb des gewünschten Camp-Bereichs. Der aktuelle Source verwendet weiterhin `InitValidateAndRepositionStatic(true,120)`. Eine Änderung daran erfolgt erst nach separater Prüfung der Pickup-Zone/ME-Geometrie.

## 9. Acceptance-Grenze

```text
Build 1-14 source                  REMOTE / SOURCE REVIEWED
Builder provenance                 LOCAL BUILD PENDING
DCS route order                    PENDING
DCS QRF return                     PENDING
DCS performance                    PENDING
validated_in_dcs                   false
```
