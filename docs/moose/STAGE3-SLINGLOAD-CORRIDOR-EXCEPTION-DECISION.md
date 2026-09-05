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

Nach der dokumentierten MOOSE-Fähigkeitsprüfung in `STAGE3-CAS-CARGOTRANSPORT-ROUTE-LIFECYCLE-GAP.md` hat der Projektinhaber die eng begrenzte Ausnahme freigegeben, die beide Anforderungen gleichzeitig erhält:

```text
physical external CH-47 slingload
AND
owner-authored R500 pickup-to-Wright route
```

Die Freigabe gilt ausschließlich für die bestätigte Lücke zwischen physisch bestätigtem Slingload-Pickup und Wright-seitigem Delivery-Task. Sie ist keine allgemeine Native-DCS-Routingfreigabe.

## 2. Gepinnter MOOSE-Stand

```text
release: 2.9.18
commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

`AUFTRAG:NewCARGOTRANSPORT(StaticCargo, DropZone)` erzeugt den DCS-Helikoptertask `CargoTransportation` mit physischer Cargo-`groupId` und ME-Drop-Zone-`zoneId`. Die geprüfte öffentliche AUFTRAG-API stellt keinen frei parametrierbaren Route/Path-Parameter für die aktive Phase zwischen physischem Pickup und Drop bereit.

`OPSTRANSPORT:AddPathTransport(...)` bietet MOOSE-native Transportpfade, aber das geprüfte Storage/Cargobay-Modell erhält nicht den hier geforderten sichtbaren externen Slingload. `AUFTRAG:NewOPSTRANSPORT()` ist im gepinnten Stand nicht als aktive öffentliche Funktion verfügbar.

Es wurde kein verifizierter öffentlicher MOOSE-Weg und kein offizielles Beispiel gefunden, das gleichzeitig bietet:

```text
AIRWING/AUFTRAG AI execution
physical external slingload
arbitrary owner-authored pickup-to-drop PATHLINE
```

## 3. DCS-Nachweis Focus 1-2 / 1-3

Die realen DCS-Läufe bestätigten inzwischen:

```text
physical pickup: PASS
PauseMission task release: PASS
external slingload survives PauseMission/TaskCancel/TaskDone: PASS
R500 outbound handoff: PASS
physical Wright delivery: FAIL
```

Focus 1-3 zeigte zusätzlich, dass `PauseMission()` selbst korrekt arbeitet:

```text
executing/executing
-> PauseMission
-> executing/paused
-> original mission task released
-> mission remains paused across UpdateRoute and T+1/2/3/5 seconds
```

Die frühere Annahme, `PauseMission()` beende den CARGOTRANSPORT unmittelbar, ist damit verworfen.

## 4. Gepinnte MOOSE-Lifecycle-Ursache

Die nachfolgende Quellprüfung identifizierte einen generischen MOOSE-Lifecycle, der exakt mit dem später beobachteten Verlust des `PAUSED`-Status zusammenpasst.

`FLIGHTGROUP:_CheckGroupDone()` zählt verbleibende Missionen und pausierte Missionen. Wenn alle verbleibenden Missionen pausiert sind, ruft MOOSE selbst `UnpauseMission()` auf:

```lua
if nPaused > 0 and nPaused == nMissions then
  local missionpaused = self:_GetPausedMission()
  self:UnpauseMission()
  return
end
```

`OPSGROUP:onafterUnpauseMission()` setzt anschließend `mission.unpaused=true`, startet die Mission erneut über `MissionStart(mission)` und entfernt ihre ID aus `pausedmissions`.

Damit ist das bisherige Design

```text
only remaining AUFTRAG stays PAUSED for the entire long R500 pickup-to-Wright leg
```

mit dem normalen MOOSE-`_CheckGroupDone()`-Housekeeping nicht stabil.

Der DCS-Log enthält wegen des verwendeten Verbosity-Levels keinen direkten Textbeleg für die interne `_CheckGroupDone()`-Zeile. Die Ursache ist daher `SOURCE_CONFIRMED_AND_RUNTIME_CONSISTENT`, nicht als bereits DCS-direkt beobachteter Callback markiert. Der nächste Lauf muss die abgefangene `UnpauseMission`-Transition ausdrücklich loggen.

## 5. MOOSE-first Korrektur

MOOSE-FSMs stellen für Events dokumentierte Transition Handler bereit. `OnBefore<Event>` beziehungsweise `onbefore<Event>` werden vor dem Zustandsübergang aufgerufen; Rückgabe `false` verwirft die Transition.

Da `UnpauseMission` ein reguläres OPSGROUP-FSM-Event ist, wird die kleinste Korrektur als MOOSE-eigener Lifecycle-Hook umgesetzt:

```lua
function flightGroup:OnBeforeUnpauseMission(From, Event, To, ...)
  if approvedSlingloadPickupToDropHandoffStillActive then
    return false
  end
  return true
end
```

Geltungsgrenze:

```text
confirmed physical pickup
-> source CARGOTRANSPORT PauseMission
-> OnBeforeUnpauseMission rejects automatic restart while pickup-to-drop handoff is active
-> R500 outbound
-> Wright-side CargoTransportation waypoint task
-> physical Wright delivery
-> unpause guard released
-> original AUFTRAG:Success()
-> R500 reverse
-> Jalalabad / AIRWING recovery
```

Das ist kein Acceptance-Gate über einen diagnostischen Sollwert. Es ist ein verifizierter öffentlicher MOOSE-FSM-Extension-Point, der ausschließlich verhindert, dass das Framework seinen absichtlich pausierten Source-AUFTRAG während des genehmigten Route-Handoffs selbst wieder startet.

Es werden keine `pausedmissions`, `currentmission`, `taskcurrent` oder andere MOOSE-Interna verändert. Diese Felder dürfen weiterhin nur diagnostisch gelesen werden.

## 6. Narrow exception implementation

Runtime:

```text
scripts/air-operations/OMW_SlingloadCorridorHandoff.lua
```

MOOSE bleibt autoritativ für:

```text
AIRWING / SQUADRON asset selection
AUFTRAG:NewCARGOTRANSPORT
physical cargo identity
initial approach and slingload pickup
PauseMission / TaskDone lifecycle
UnpauseMission FSM transition handling
FLIGHTGROUP waypoint ownership
AIRWING / LEGION aircraft lifecycle
CampaignState resource settlement
```

Nur nach physisch bestätigtem Pickup verwendet die bestehende owner-approved Ausnahme:

```text
FLIGHTGROUP:GetWaypointCurrentUID()
FLIGHTGROUP:AddWaypoint() for R500 outbound
FLIGHTGROUP:AddTaskWaypoint() at Wright-side route exit
  with same DCS CargoTransportation groupId / zoneId
FLIGHTGROUP:AddWaypoint() for R500 return
one FLIGHTGROUP:UpdateRoute()
```

Die physische Lieferung wird aus Cargo-Wrapper + Drop-Zone nachgewiesen. Erst danach wird der ursprüngliche AUFTRAG per `Success()` abgeschlossen.

## 7. Explicit boundaries

Nicht freigegeben und nicht verwendet:

```text
raw DCS controller task replacement
coalition.addGroup()
coalition.addStaticObject()
teleport
MissionScripting.lua mutation
MIST
direct strategic resource mutation outside CampaignState
high-frequency/frame polling
manual mutation of MOOSE paused/current/task queues
fake keepalive/dummy AUFTRAG
```

Der Delivery-Monitor bleibt bei fünf Sekunden und ist reine physische Delivery-Beobachtung. Die Lifecycle-Diagnostik ist keine Missionsautorität.

## 8. Required DCS acceptance

Der nächste Focus-Lauf muss beweisen:

```text
CH-47 spawn
-> physical slingload pickup at Jalalabad
-> PauseMission / source task release
-> BLOCKED_AUTO_UNPAUSE_BEFORE_PHYSICAL_DELIVERY observed at least when MOOSE attempts restart
-> R500 outbound
-> no direct pickup-to-Wright shortcut
-> Wright-side CargoTransportation task
-> physical slingload release in Wright drop zone
-> original AUFTRAG Success only after physical delivery
-> R500 reverse
-> Jalalabad landing
-> AIRWING recovery
```

CAS bleibt funktional eingefroren und muss nur regressionsfrei bleiben:

```text
Jalalabad -> R500 -> WEST -> CAS -> WEST reverse -> R500 reverse -> Jalalabad
```

## 9. Status

```text
owner exception approval: YES, narrow Stage-3 slingload corridor scope only
MOOSE gap documented: YES
PauseMission survival in DCS: YES
MOOSE auto-unpause lifecycle: SOURCE CONFIRMED
MOOSE OnBeforeUnpauseMission correction: SOURCE COMPLETE / CI REQUIRED
physical Wright delivery with correction: PENDING DCS
production validation: NO
```
