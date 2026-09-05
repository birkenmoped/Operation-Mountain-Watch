---
document_id: OMW-MOOSE-STAGE3-BUILD-1-16-ONE-SHOT-ROUTE-TASK-CHAIN
status: PLANNED
document_class: MOOSE_TECHNICAL_RECONCILIATION
owning_policy: OMW-GOV-001
authoritative_for:
  - pinned-MOOSE source review for Stage 3 build 1-16 one-shot CAS route/task chaining
  - Stage 3 incident-participant response completion rule
  - Stage 3 Honaker Guard/QRF access-zone materialization source review
  - Stage 3 Jalalabad dedicated Slingload pickup-zone contract
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
supersedes:
superseded_by:
validated_in_dcs: false
---

# Stage 3 Build 1-16 – One-shot Route-/Task-Chain

## 1. Ziel

Build 1-16 reduziert die in Build 1-15 zu komplex gewordene Hubschrauber-Routinglogik auf eine einmalig erzeugte MOOSE-Wegpunkt-/Task-Kette.

Die Zielsequenz für CAS ist:

```text
Jalalabad
-> gemeinsamer Korridor / R500
-> WEST
-> PATROLZONE/CAS execution
-> WEST reverse
-> R500 reverse
-> Jalalabad
```

Für Air-AMMO:

```text
Jalalabad Slingload pickup
-> R500 outbound
-> Wright delivery
-> R500 reverse
-> Jalalabad
```

## 2. MOOSE-Provenienz

```text
MOOSE release:
2.9.18

MOOSE commit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

Moose.lua SHA256:
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Dokumentation allein wurde nicht als Verfügbarkeitsnachweis verwendet. Die nachfolgenden Pfade wurden gegen den tatsächlich gepinnten `Moose.lua`-Stand geprüft.

## 3. Verifizierte öffentliche MOOSE-Bausteine

Für die Route-/Task-Kette relevant und im gepinnten Source vorhanden:

```text
AUFTRAG:SetMissionIngressCoord(...)
AUFTRAG:SetMissionEgressCoord(...)
AUFTRAG:GetGroupWaypointIndex(...)
AUFTRAG:GetGroupEgressWaypointUID(...)
AUFTRAG:NewPATROLZONE(...)
AUFTRAG:NewCARGOTRANSPORT(...)
FLIGHTGROUP:AddWaypoint(...)
OPSGROUP:AddTaskWaypoint(...)
FLIGHTGROUP:UpdateRoute(...)
FLIGHTGROUP:GetWaypointIndex(...)
FLIGHTGROUP:GetWaypointUIDFromIndex(...)
FLIGHTGROUP:GetWaypointCurrentUID(...)
```

Für Helikopter erzeugt `FLIGHTGROUP:AddWaypoint(...)` RADIO-/AGL-Wegpunkte. Mit `Updateroute=false` können mehrere Wegpunkte zunächst zu einer Kette aufgebaut und anschließend mit genau einem `UpdateRoute()` an DCS übergeben werden.

Der MOOSE-Source weist außerdem ausdrücklich auf problematische schnelle Oszillation hin, wenn Mission-Waypoints wiederholt entfernt und Routen wiederholt neu aufgebaut werden. Build 1-16 vermeidet deshalb einen dauerhaften `OnAfterUpdateRoute`-Hook.

## 4. CAS-Architektur

### 4.1 Einmalige Route

Der Stage-3-Adapter `OMW_HelicopterMissionOwnedCorridor.lua` verwendet ab Schema 5:

```text
MOOSE_ONE_SHOT_ROUTE_TASK_CHAIN
```

Ablauf:

1. `SetMissionIngressCoord(...)` setzt den ersten Korridorpunkt vor den MOOSE-Missionswegpunkt.
2. Nach Erzeugung der MOOSE-Missionsroute werden die restlichen R500/WEST-Outbound-Wegpunkte einmalig vor den Missionswegpunkt eingefügt.
3. Der existierende PATROLZONE-AUFTRAG bleibt der eigentliche Missions-/Task-Wegpunkt.
4. WEST/R500-Recovery-Wegpunkte werden einmalig hinter dem Missionswegpunkt eingefügt.
5. Recovery-Wegpunkte erhalten absichtlich keine `missionUID`, damit AUFTRAG-Abschluss/-Cancel sie nicht zusammen mit Missionswaypoints entfernt.
6. Danach erfolgt genau ein `FLIGHTGROUP:UpdateRoute()`.

Es gibt keinen permanenten `OnAfterUpdateRoute`-Interceptor mehr.

Lediglich wenn der MOOSE-Missionswegpunkt unmittelbar beim `FlightOnMission`-Callback noch nicht aufgelöst werden kann, wird maximal achtmal in Ein-Sekunden-Abständen versucht, die einmalige Route zu installieren. Nach Erfolg oder Fail endet dieser Scheduler.

### 4.2 Abschlussbedingung

Build 1-15 koppelte die Response zusätzlich an sämtliche aktiven RED Ground Groups in einer 5-NM-Zone. Der DCS-Test zeigte, dass dadurch der CAS-Auftrag nach Vernichtung der tatsächlichen Angreifer unnötig offen blieb.

Build 1-16 verwendet deshalb:

```text
zero living known attack-incident participants
```

als autoritative Response-Abschlussbedingung.

Die 5-NM-SET_GROUP-Abfrage bleibt ausschließlich Diagnose:

```text
TACTICAL_RED_GROUND_GROUPS_DIAGNOSTIC
```

Sie blockiert CAS-/QRF-Recovery nicht.

## 5. Guard-/QRF-Materialisierung

Der gepinnte MOOSE-Source bestätigt `WAREHOUSE:SetSpawnZone(zone,maxdist)`. `BRIGADE` erbt über `LEGION` den Warehouse-Lifecycle. Offizielle MOOSE-Warehouse-Demos verwenden `SetSpawnZone(...)` mit Mission-Editor-Zonen zur gezielten physischen Asset-Materialisierung.

Stage 3 verwendet daher:

```text
ZON_BLUE_GND_HONAKER_ACCESS
```

als physische Spawn-Zone für Guard und QRF, während der Honaker-BRIGADE-/Warehouse-Knoten weiterhin die organisatorische und strategische Basis bleibt.

Damit wird die Ground-AI nicht erst innerhalb des ummauerten COP erzeugt und anschließend zum Straßennetz gezwungen.

## 6. Slingload-Pickup

Der allgemeine Logistikanker `OMW_LOG_NODE_JALALABAD` ist nicht mehr physische Slingload-Spawnposition.

Der Mission Owner hat getrennte physische Logistikflächen festgelegt:

```text
ZON_BLUE_LOG_SLG_<LOCATION>_01
ZON_BLUE_LOG_ACG_<LOCATION>_01
```

Stage 3 verwendet:

```text
ZON_BLUE_LOG_SLG_JALALABAD_01
```

Der Cargo-Spawn erfolgt am expliziten ME-Zonenmittelpunkt ohne automatische Reposition:

```lua
:InitCoordinate(pickup:GetCoordinate())
:InitValidateAndRepositionStatic(false)
```

## 7. Externer Slingload – verbleibende genehmigte Ausnahme

Die frühere MOOSE-Prüfung bleibt gültig: Für `AUFTRAG:NewCARGOTRANSPORT(...)` wurde im gepinnten Stand kein öffentlicher MOOSE-Hook nachgewiesen, mit dem der bereits aktive physische DCS-`CargoTransportation`-Task zwischen Pickup und Drop beliebig über eine owner-authored PATHLINE geführt werden kann.

Die bereits vom Mission Owner genehmigte, eng begrenzte Ausnahme bleibt deshalb bestehen:

```text
physical pickup confirmed
-> public FLIGHTGROUP waypoint APIs
-> one-shot R500 outbound chain
-> same DCS CargoTransportation task at Wright route exit
-> physical delivery
-> one-shot R500 return chain
```

Nicht verwendet werden:

```text
raw Controller task assignment
coalition.addGroup
coalition.addStaticObject
teleport
MIST
MissionScripting.lua modification
```

Die Ausnahme ist separat dokumentiert in:

```text
docs/moose/STAGE3-SLINGLOAD-CORRIDOR-EXCEPTION-DECISION.md
```

## 8. Build-1-16-Acceptance

Der folgende DCS-Test ist noch ausstehend. Der Source-Review ist ausdrücklich kein `VALIDATED`-Nachweis.

Zu prüfen sind mindestens:

```text
CAS:
- R500 -> WEST -> AO ohne initialen Direktflug
- reale CAS-Waffenwirkung
- Abschluss nach Vernichtung der bekannten Incident-Participants
- WEST reverse -> R500 reverse
- Jalalabad-Landung ohne Fuel-driven direct RTB

CH-47:
- Cargo in ZON_BLUE_LOG_SLG_JALALABAD_01
- physischer Pickup vor Korridorflug
- R500 outbound
- physische Wright-Ablieferung
- R500 reverse
- Jalalabad-Landung / AIRWING recovery

Ground:
- Guard materialisiert in ZON_BLUE_GND_HONAKER_ACCESS
- Guard erreicht PATHLINE ohne COP-Ausfahrproblem
- QRF materialisiert sichtbar im Access-Bereich
- QRF reagiert auf Incident
- QRF ReturnToLegion nach Incident-Abschluss

Performance:
- keine Route-Rebuild-/FSM-Oszillation in der Recovery-Phase
```

Erst ein dokumentierter DCS-Lauf mit exakter Build-/Commit-/Bundle-Provenienz darf diesen Scope auf `VALIDATED` setzen.
