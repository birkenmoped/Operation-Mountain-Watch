---
document_id: OMW-MOOSE-GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-FLIGHTPATH-RETURN-SOURCE-REVIEW
status: SOURCE_REVIEWED
document_class: TECHNICAL_EVIDENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 1D-P Air PERSONNEL FlightPath and physical-return source review
  - OMW_FlightPath use as preferred rotary-wing corridor
  - Fortress normal-LZ intermediate landing contract
not_authoritative_for:
  - DCS runtime validation of FlightPath routing
  - production-wide rotary-wing routing beyond the documented acceptance scope
  - physical infantry-group transport
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/automatic-response-orchestration-continuation
validated_in_dcs: false
---

# Stage 1D-P – Air PERSONNEL FlightPath / Physical Return Source Review

## 1. Anlass

Der erste kombinierte Stage-1D-P-Lauf bestätigte den strategischen PERSONNEL-Transfer Jalalabad -> Fortress, zeigte aber für den Air-Lifecycle ein nicht akzeptables Verhalten: Der CH-47 landete am Fortress-Ziel und wurde dort unmittelbar als AIRWING/LEGION-Asset zurückgegeben beziehungsweise entfernt, anstatt physisch nach Jalalabad zurückzufliegen.

Der Air-Teil dieses Laufs ist deshalb **kein technischer PASS** für den geforderten physischen Rückkehr-Lifecycle.

Der Ground-Pfad Joyce -> Honaker wird durch diese Korrektur nicht neu entworfen.

## 2. MOOSE-Source-Befund

Geprüfter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Im gepinnten Source ist für `FLIGHTGROUP:onafterArrived(...)` dokumentiert und implementiert, dass ein AI-AIRWING-Asset bei `Arrived` an das Legion/AIRWING zurückgegeben wird. Der Source enthält dabei selbst den offenen Hinweis, dass nicht geprüft wird, ob die aktuelle Basis tatsächlich die AIRWING-Heimatbasis ist.

Damit ist eine Intermediate-Landung auf einer DCS-Airbase-/FARP-Repräsentation für diesen OMW-Scope ungeeignet, weil sie den Airwing-Rückgabe-Lifecycle vorzeitig auslösen kann.

## 3. Normale LZ statt Intermediate-FARP

Für den neuen Acceptance-Pfad ist Fortress daher eine normale Mission-Editor-Triggerzone:

```text
OMW_BLUE_LZ_FORTRESS_01
```

Sie dient nur als präziser physischer Landing-Anker. Sie besitzt für diesen Scope keine FARP-/AIRBASE-Rückgabe-Semantik.

Der gepinnte Source bestätigt:

```text
FLIGHTGROUP:onafterLandAt(...)
-> GROUP:TaskLandAtVec2(Coordinate:GetVec2(), Duration)

FLIGHTGROUP:onafterLandedAt(...)
-> FSM-Nachweis der Zwischenlandung
```

Die offizielle MOOSE-Demo `Ops/Flightgroup/Flightgroup - 040 - Helo Land At` verwendet denselben Grundpfad: Helikopter landet an einer normalen Koordinate, wartet für eine definierte Dauer und setzt danach seinen Flug fort.

## 4. OMW_FlightPath als bevorzugter Corridor

Die owner-erstellte Mission-Editor-Linie

```text
OMW_FlightPath
```

wird von MOOSE automatisch als `PATHLINE` registriert. Der gepinnte Source bestätigt:

```text
PATHLINE:FindByName(Name)
PATHLINE:GetCoordinates()
COORDINATE:HeadingTo(ToCoordinate)
COORDINATE:Translate(Distance, Angle, Keepalt, Overwrite)
```

Der Acceptance-Pfad verwendet die gezeichnete Talachse als **bevorzugten**, nicht zwingenden Corridor:

```text
Jalalabad
-> so früh wie sinnvoll auf OMW_FlightPath
-> dem Corridor so lange wie sinnvoll folgen
-> missionbedingt bei Fortress ausscheren
-> OMW_BLUE_LZ_FORTRESS_01
-> nach der Zwischenlandung Corridor wieder aufnehmen
-> entlang OMW_FlightPath zurück
-> Jalalabad
```

Der Missionszweck darf die Corridor-Bindung verlassen. Die Linie ist kein geographischer Zwangspfad für jede Missionsphase.

## 5. Richtungsabhängige laterale Trennung

Owner-Entscheidung:

```text
Sollspur = 500 m rechts der OMW_FlightPath-Referenzlinie,
bezogen auf die jeweilige Flugrichtung.
```

Die Source-geprüfte Umsetzung verwendet je Segment:

```text
heading = current:HeadingTo(next)
right-hand coordinate = current:Translate(500, heading - 90, false, false)
```

Für Gegenverkehr liegen die Sollspuren damit auf gegenüberliegenden Seiten der Referenzlinie und ungefähr 1000 m auseinander, soweit die Mission-Editor-gezeichnete Talachse den entsprechenden Raum bereitstellt.

Für den Acceptance-Lauf wird eine 500-ft-AGL-Waypoint-Höhe verwendet. `FLIGHTGROUP:AddWaypoint(...)` verwendet für Helikopter im gepinnten Source `WaypointAltType.RADIO`; der explizite Altitude-Parameter wird in Fuß übergeben.

## 6. AUFTRAG-/FLIGHTGROUP-Routing

Der bestehende Missionsauftrag bleibt:

```text
AUFTRAG:NewLANDATCOORDINATE(...)
```

Zusätzlich wird der MOOSE-eigene Mission-Egress verwendet:

```text
AUFTRAG:SetMissionEgressCoord(...)
```

Der gepinnte `OPSGROUP:RouteToMission(...)`-Source bestätigt, dass bei Air-Gruppen ein Mission-Waypoint und danach ein Egress-Waypoint angelegt werden. `MissionDone` wird bei vorhandenem Egress erst nach Passieren des Egress-Waypoints ausgelöst.

Nach Erzeugung dieser AUFTRAG-Waypoints werden mit öffentlichen MOOSE-Waypoint-Methoden die Corridor-Waypoints eingefügt:

```text
AUFTRAG:GetGroupWaypointIndex(...)
AUFTRAG:GetGroupEgressWaypointUID(...)
OPSGROUP:GetWaypointIndex(...)
OPSGROUP:GetWaypointUIDFromIndex(...)
FLIGHTGROUP:AddWaypoint(...)
```

Dadurch entsteht für den Acceptance-Scope:

```text
current route
-> outbound right-offset OMW_FlightPath points
-> LANDATCOORDINATE Fortress
-> return right-offset OMW_FlightPath points
-> AUFTRAG egress near Jalalabad
-> normal MOOSE aircraft return
-> physical Jalalabad landing
-> LegionAssetReturned
```

Es wird kein Native-DCS-Routing-Dispatcher eingeführt.

## 7. Delivery- und Return-Nachweis

Strategische Delivery erfolgt erst bei physischer Zwischenlandung:

```text
FLIGHTGROUP OnAfterLandedAt
AND IsAirborne() == false
AND distance to OMW_BLUE_LZ_FORTRESS_01 <= 100 m
-> CampaignState MarkDelivered
-> MissionDemand SUCCESS
```

Der finale Acceptance-PASS ist strenger als der erste Stage-1D-P-Test:

```text
Delivery at Fortress
AND MissionDone only after return-corridor egress
AND FLIGHTGROUP OnAfterLanded at Jalalabad
AND only afterwards AIRWING OnAfterLegionAssetReturned
-> PASS
```

`LegionAssetReturned` allein gilt ausdrücklich **nicht** als physischer Rückkehrnachweis.

## 8. Unveränderte strategische Werte

```text
Origin:       GROUND_NODE_JALALABAD
Destination:  GROUND_NODE_FORTRESS
Resource:     GROUND_PERSONNEL
Initial:      Jalalabad 480 / Fortress 160
Shortage:     Fortress -33 -> 127
80% floor:    128
Transfer:     33
Expected:     Jalalabad 447 / Fortress 160
Squadron:     SQ_US_JBAD_CH47_HEAVYLIFT
Template:     TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP
```

Warehouse-/Ground-Resource-Authority bleibt unverändert. Für diese Korrektur ist kein weiterer Umbau der produktiven Warehouse- oder Ground-Base erforderlich.

## 9. DCS-offene Punkte

Folgendes ist **SOURCE_REVIEWED / STAGED**, aber noch nicht DCS-validiert:

```text
- tatsächliche Waypoint-Reihenfolge nach Corridor-Insertion;
- CH-47 folgt der 500-m-Rechtsspur ausreichend stabil;
- LANDATCOORDINATE auf normaler Triggerzone landet am vorgesehenen Fortress-Punkt;
- Wiederstart nach 30 s Dwell;
- Return-Corridor wird vollständig geflogen;
- MissionDone tritt erst am Egress nahe Jalalabad ein;
- physische Landung in Jalalabad erfolgt vor LegionAssetReturned.
```

Erst der reale DCS-Lauf mit exakter Commit-/Bundle-/MIZ-/MOOSE-Provenienz darf diesen Air-Pfad zu einer akzeptierten technischen Baseline machen.