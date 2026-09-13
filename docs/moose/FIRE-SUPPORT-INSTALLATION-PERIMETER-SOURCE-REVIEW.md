---
document_id: OMW-MOOSE-FIRE-SUPPORT-INSTALLATION-PERIMETER-SOURCE-REVIEW
status: DRAFT
document_class: MOOSE_SOURCE_REVIEW
owning_policy: OMW-GOV-001
authoritative_for:
  - MOOSE source evidence for six-site installation alarm perimeter resolution
  - public method signatures used by Production Base Acceptance 3 perimeter wiring
  - MOOSE source evidence for the reused QRF ACCESS-home return lifecycle
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# MOOSE Source Review – Installation Alarm Perimeters and QRF Return

## Zweck

Dieses Dokument belegt ausschließlich die im korrigierten Production-Base-Acceptance-3-Pfad verwendeten MOOSE-Methoden und ihre Signaturen im tatsächlich für OMW gepinnten MOOSE-Stand. Es trennt dabei Source-Evidence von bereits auf anderen Ground-Acceptances vorhandener DCS-Evidence. Der aktuelle sechs-Site-Acceptance-3-Pfad selbst ist noch nicht DCS-validiert.

## Gepinnter Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## Geprüfte Perimeter-Methoden

### `ZONE:FindByName(ZoneName)`

Im gepinnten `Moose.lua` vorhanden. Die Methode löst eine bereits in der MOOSE-Datenbank registrierte Mission-Editor-Zone über `_DATABASE:FindZone(ZoneName)` auf.

OMW-Nutzung im Acceptance-3-Scope für Jalalabad:

```text
OMW_BLUE_OBJECTIVE_JALALABAD_AIRPORT
-> ZONE:FindByName(...)
-> existing MOOSE zone
-> GetCoordinate()
-> Mittelpunktquelle
-> ZONE_RADIUS:New(..., 2438.4 m)
-> OPSZONE
```

Die vorhandene ME-Zone besitzt 6000 ft Radius. Seit der Owner-Entscheidung vom 13.09.2026 ist sie deshalb **nur Mittelpunktquelle**; der Acceptance-Pfad erzeugt am selben Mittelpunkt eine runtime-only `ZONE_RADIUS` mit 8000 ft / 2438.4 m. Die `.miz` wird dadurch nicht verändert.

### `ZONE_RADIUS:New(ZoneName, Vec2, Radius, DoNotRegisterZone)`

Im gepinnten `Moose.lua` vorhanden. Acceptance 3 verwendet die Klasse für alle sechs owner-defined Alarmperimeter. Bei Jalalabad stammt die Mittelpunktkoordinate aus der vorhandenen MOOSE-Zone; bei den übrigen fünf Sites aus der Warehouse-/BRIGADE-Koordinate.

### `ZONE_BASE:GetCoordinate(Height)`

Im gepinnten `Moose.lua` vorhanden. Acceptance 3 verwendet die Koordinate der vorhandenen Jalalabad-Zone als geometrischen Mittelpunktanker und für die physische Fixture-Route.

### `WAREHOUSE:GetCoordinate()`

Im gepinnten `Moose.lua` vorhanden und liefert die Koordinate des dem Warehouse zugrunde liegenden MOOSE-Wrappers. `BRIGADE` verwendet den LEGION-/WAREHOUSE-Vererbungsweg; damit kann der vorhandene BRIGADE-/Warehouse-Anker ohne native DCS-Parallelauflösung verwendet werden.

OMW-Nutzung im Acceptance-3-Scope:

```text
COP Fortress
FOB Joyce
FOB Wright
COP Honaker-Miracle
FOB Bostick

existing BRIGADE / MOOSE Warehouse
-> GetCoordinate()
-> ZONE_RADIUS:New(... owner-defined radius ...)
-> OPSZONE
```

### `COORDINATE:GetIntermediateCoordinate(ToCoordinate, Fraction)`

Im gepinnten `Moose.lua` vorhanden. Wenn der zweite Parameter größer als `1` ist, interpretiert die Implementierung ihn als Distanz entlang des Vektors und normiert ihn auf die tatsächliche Vektorlänge.

Acceptance 3 nutzt dies ausschließlich zur Berechnung eines physischen RED-Fixture-Zielpunkts bei 65 % des owner-defined Alarmradius sowie für die QRF-Road-Anchor-Suche in Ausrückrichtung. Es entsteht keine produktive RED-C2-Logik.

### `CONTROLLABLE:RouteGroundTo(ToCoordinate, Speed, Formation, DelaySeconds, ...)`

Im gepinnten `Moose.lua` mit dieser öffentlichen Signatur vorhanden. Acceptance 3 verwendet die Methode für die beobachtbare physische Bewegung der bereits vorhandenen late-activated RED-Testfixtures in die Alarmperimeter. Es gibt keinen Teleport, Respawn oder native-DCS-Ersatzpfad.

## Geprüfter QRF-Auftrag

### `AUFTRAG:NewGROUNDATTACK(Target, Speed, Formation)`

Im gepinnten Source vorhanden. Der aktuelle QRF-Pfad übergibt das durch den Incident gebundene physische hostile `GROUP` als Target. Damit muss kein künstlicher Incident-Koordinaten-Targettyp erzeugt werden und MOOSE bleibt für Auftrag, Recruitment und physische Ausführung zuständig.

### `AUFTRAG:SetReturnToLegion(Switch)`

Im gepinnten Source vorhanden. Für Ground-/Naval-Missionen setzt die Methode das Mission-Flag `legionReturn`. Der QRF-Factory-Pfad setzt ausdrücklich:

```lua
mission:SetReturnToLegion(true)
```

Dies ist keine neue OMW-Rückkehr-FSM, sondern aktiviert den MOOSE-eigenen Rückkehrpfad nach Mission-Ende beziehungsweise Mission-Cancel.

## Geprüfter BRIGADE-/ARMYGROUP-Home-Pfad

### `WAREHOUSE:SetSpawnZone(...)` / `LEGION:_CreateFlightGroup(asset)`

Die site-lokale vorhandene ACCESS-Zone wird im QRF-Runtime dem `BRIGADE` als Spawn-Zone gesetzt. Im gepinnten `LEGION:_CreateFlightGroup(asset)` wird für BRIGADE-Assets ein `ARMYGROUP` erzeugt und anschließend:

```lua
opsgroup.homezone=self.spawnzone
```

gesetzt.

Damit ist die ACCESS-Zone nicht nur der akzeptierte physische Ausrück-/Materialisierungspunkt, sondern zugleich die MOOSE-Homezone des daraus entstandenen QRF-ARMYGROUP.

### `ARMYGROUP:onafterRTZ(...)`

Der gepinnte Source verwendet bei fehlendem explizitem Zone-Argument:

```lua
local zone=Zone or self.homezone
```

und routet mobile Ground-Gruppen physisch in diese Zone. Befindet sich die Gruppe bereits in der Zone, folgt unmittelbar `Returned()`; andernfalls wird ein Waypoint in der Homezone ergänzt. Für mobile QRF-Gruppen wird damit kein Teleportpfad benötigt.

### `ARMYGROUP:onafterReturned(...)`

Der gepinnte Source führt bei vorhandener Legion aus:

```lua
self.legion:__AddAsset(10, self.group, 1)
```

Damit bleibt auch der Warehouse-Handoff MOOSE-eigen. Acceptance 3 implementiert keine parallele AddAsset-/Despawn-Logik; der Harness beobachtet nur `RTZ`, `Returned`, `BRIGADE OnAfterAddAsset` und die anschließende Entfernung der physischen Gruppe.

## Bereits vorhandene DCS-Evidence außerhalb des aktuellen A3-Laufs

Der Rückkehrpfad ist nicht neu. Die Ground-Acceptances haben ihn bereits für ihren exakt dokumentierten Stand praktisch bestätigt:

```text
ARMY Ground Acceptance 6:
MissionDone -> ARMYGROUP:RTZ(existing site ACCESS zone, OnRoad)
-> Returned -> Warehouse AddAsset -> physical group removal

ARMY Ground Acceptance 7:
Normal Return / Teilverlust / beschädigter Rückkehrer
-> derselbe physische MOOSE-Rückkehrpfad
-> exactly-once CampaignState settlement
```

Zusätzlich nutzte der historische Honaker-Stage-3-QRF-Pfad `SetReturnToLegion(true)` und eine explizite taktische Missionfreigabe. Aus dessen Honaker-spezifischer Gefechtsgeometrie wird hier keine allgemeine sechs-Site-Geometrie abgeleitet.

Diese historische/branchgebundene Evidence erlaubt die **Wiederverwendung** des Lifecycles, ersetzt aber nicht den noch ausstehenden DCS-Nachweis der aktuellen sechs-Site-Integration.

## Bereits verwendeter OPSZONE-Pfad

Die korrigierte Acceptance baut keine zweite Threat-Engine. Der vorhandene OMW-Adapter bleibt zuständig:

```text
MOOSE ZONE_RADIUS
-> OPSZONE:New(...)
-> SetObjectCategories({ Object.Category.UNIT })
-> SetUnitCategories({ Unit.Category.GROUND_UNIT })
-> MOOSE OPSZONE FSM / OnAfterAttacked
-> OMW_FobThreatOpsZoneAdapter
-> OMW_FireSupStratResupply_PerimeterBridge
-> PROXIMITY_INTRUSION
```

`OPSZONE` bleibt Framework-Autorität für die physische Presence-/Threat-Qualifikation.

## Mission-End-Abgrenzung

Verbindlich bleibt:

```text
alarm/security perimeter
= threat-detection / response-trigger boundary
!= tactical mission-end condition
```

Daher setzt der InstallationIncidentBridge für den initialen QRF-Demand `cancelWhenIncidentClosed=false`. Der Acceptance-Harness erzeugt seine deterministische Testfreigabe erst nach beobachteter physischer QRF-Reaktion über `Base:ExpireDemand(...)`. Das ist eine Acceptance-only Steuerung und keine produktive Tactical-Completion-Policy.

## Abgrenzung

```text
SOURCE_REVIEWED current six-site integration
!= DCS VALIDATED current six-site integration
```

Der nächste reale DCS-Lauf muss noch belegen:

- dass alle sechs Perimeter mit der festgelegten Geometrie starten;
- dass die sechs Fixtures unter realem Ground-AI-/Terrain-Verhalten die jeweiligen Perimeter erreichen;
- dass MOOSE `OPSZONE` an allen sechs Sites die RED-Präsenz qualifiziert;
- dass daraus sechs `PROXIMITY_INTRUSION`-Evidence-Items und sechs authoritative Incidents entstehen;
- dass exakt ein initialer QRF-Demand pro Incident erzeugt und durch MOOSE physisch ausgeführt wird;
- dass alle sechs QRFs im jeweiligen ACCESS materialisieren und mindestens 25 m physisch auf ihr Ziel reagieren;
- dass die Acceptance-only Missionfreigabe den MOOSE-ReturnToLegion-Pfad auslöst;
- dass alle sechs QRFs per `RTZ` in die jeweilige ACCESS-Homezone zurückfahren;
- dass `Returned -> Warehouse AddAsset -> physical removal` an allen sechs Sites beobachtet wird.