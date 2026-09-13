---
document_id: OMW-MOOSE-FIRE-SUPPORT-INSTALLATION-PERIMETER-SOURCE-REVIEW
status: SOURCE_REVIEWED
document_class: MOOSE_SOURCE_REVIEW
owning_policy: OMW-GOV-001
authoritative_for:
  - MOOSE source evidence for six-site installation alarm perimeter resolution
  - public method signatures used by Production Base Acceptance 3 perimeter wiring
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# MOOSE Source Review – Installation Alarm Perimeters

## Zweck

Dieses Dokument belegt ausschließlich die im korrigierten Production-Base-Acceptance-3-Pfad verwendeten MOOSE-Methoden und ihre Signaturen im tatsächlich für OMW gepinnten MOOSE-Stand. Es ist kein DCS-Laufzeitnachweis.

## Gepinnter Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## Geprüfte Methoden

### `ZONE:FindByName(ZoneName)`

Im gepinnten `Moose.lua` vorhanden. Die Methode löst eine bereits in der MOOSE-Datenbank registrierte Mission-Editor-Zone über `_DATABASE:FindZone(ZoneName)` auf.

OMW-Nutzung im Acceptance-3-Scope:

```text
OMW_BLUE_OBJECTIVE_JALALABAD_AIRPORT
-> ZONE:FindByName(...)
-> existing MOOSE zone
-> OPSZONE:New(zone, coalition.side.BLUE)
```

Damit wird für Jalalabad keine parallele zweite `ZONE_RADIUS` erzeugt.

### `ZONE_BASE:GetCoordinate(Height)`

Im gepinnten `Moose.lua` vorhanden. Acceptance 3 verwendet die Koordinate der bereits vorhandenen Jalalabad-Zone als Incident-/QRF-Referenzkoordinate und als geometrischen Anker für die physische Fixture-Route.

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

Acceptance 3 nutzt dies ausschließlich zur Berechnung eines physischen RED-Fixture-Zielpunkts bei 65 % des owner-defined Alarmradius. Es entsteht keine produktive RED-C2-Logik.

### `CONTROLLABLE:RouteGroundTo(ToCoordinate, Speed, Formation, DelaySeconds, ...)`

Im gepinnten `Moose.lua` mit dieser öffentlichen Signatur vorhanden. Acceptance 3 verwendet die Methode für die beobachtbare physische Bewegung der bereits vorhandenen late-activated RED-Testfixtures in die Alarmperimeter. Es gibt keinen Teleport, Respawn oder native-DCS-Ersatzpfad.

## Bereits verwendeter OPSZONE-Pfad

Die korrigierte Acceptance baut keine zweite Threat-Engine. Der vorhandene OMW-Adapter bleibt zuständig:

```text
MOOSE zone
-> OPSZONE:New(...)
-> SetObjectCategories({ Object.Category.UNIT })
-> SetUnitCategories({ Unit.Category.GROUND_UNIT })
-> MOOSE OPSZONE FSM / OnAfterAttacked
-> OMW_FobThreatOpsZoneAdapter
-> OMW_FireSupStratResupply_PerimeterBridge
-> PROXIMITY_INTRUSION
```

Der Adapter wurde lediglich so erweitert, dass neben einer zur Laufzeit erzeugten `ZONE_RADIUS` auch eine bereits aufgelöste MOOSE-Zone übergeben werden kann. `OPSZONE` bleibt in beiden Fällen Framework-Autorität für die physische Presence-/Threat-Qualifikation.

## Abgrenzung

```text
SOURCE_REVIEWED
!= DCS VALIDATED
```

Der folgende reale DCS-Lauf muss noch belegen:

- dass alle sechs Perimeter mit der festgelegten Geometrie starten;
- dass die sechs Fixtures unter realem Ground-AI-/Terrain-Verhalten die jeweiligen Perimeter erreichen;
- dass MOOSE `OPSZONE` an allen sechs Sites die RED-Präsenz qualifiziert;
- dass daraus sechs `PROXIMITY_INTRUSION`-Evidence-Items und sechs authoritative Incidents entstehen;
- dass exakt ein initialer QRF-Demand pro Incident erzeugt und durch MOOSE physisch ausgeführt wird.
