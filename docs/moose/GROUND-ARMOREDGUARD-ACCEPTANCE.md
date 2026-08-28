---
document_id: OMW-MOOSE-GROUND-ARMOREDGUARD-ACCEPTANCE
document_class: TECHNICAL_ARCHITECTURE_REFERENCE
status: PLANNED
owning_policy: OMW-GOV-001
authoritative_for:
  - source-reviewed ARMOREDGUARD behavior used by Ground Acceptance 2
  - mounted On Road to Vee observation-halt candidate contract
not_authoritative_for:
  - DCS runtime acceptance before Acceptance 2
  - per-vehicle observation sectors
  - final production patrol doctrine
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
supersedes:
superseded_by:
---

# Ground ARMOREDGUARD – Acceptance-2 Source-Review

## Gepinnter Stand

```text
MOOSE 2.9.18
commit 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256 e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## Source-geprüfter Kern

`AUFTRAG:NewARMOREDGUARD(Coordinate, Formation)` ist im tatsächlich gepinnten Source öffentlich vorhanden. Der Konstruktor:

```text
creates AUFTRAG.Type.ARMOREDGUARD
sets target from Coordinate
sets ROE OpenFire
sets AlarmState Auto
sets optionFormation to supplied formation or On Road
uses Ground category
```

`ENUMS.Formation.Vehicle` enthält für den Acceptance-2-Scope ausdrücklich:

```text
On Road
Vee
Off Road
Rank
EchelonR
EchelonL
Cone
Diamond
```

Beim Ausführen eines `ARMOREDGUARD`-/`ONGUARD`-Tasks führt der OPSGROUP-Pfad für eine ARMYGROUP `FullStop()` aus. `ARMYGROUP:onafterFullStop(...)` ersetzt die aktuelle Route durch einen Ground-Waypoint an der aktuellen Position mit Geschwindigkeit 0.

## Routing-Grenze

`OPSGROUP:RouteToMission(...)` übernimmt für Ground-Missionen grundsätzlich `mission.optionFormation`. Der geprüfte Source enthält jedoch die Sonderregel:

```text
if distance to mission waypoint < 1000 m
-> formation = Off Road
```

Deshalb wäre ein einzelner langer `ARMOREDGUARD(..., Vee)`-Auftrag für OMW ungeeignet: die Vee-Formation würde bereits für den langen Transit gelten; ein zu kurzer taktischer Endanflug würde dagegen vom Source auf Off Road gesetzt.

Acceptance 2 komponiert ausschließlich vorhandene MOOSE-Funktionalität:

```text
ARMOREDGUARD #1
On Road
-> road-side approach coordinate
-> FullStop
-> AUFTRAG cancellation
-> SetReturnToLegion(false)

same ARMYGROUP

ARMOREDGUARD #2
Vee
-> tactical leg > 1050 m
-> observation coordinate
-> FullStop
```

Das ist kein paralleler eigener Routing-FSM.

## Speed-Vertrag

`AUFTRAG:SetMissionSpeed(Speed)` erwartet laut gepinntem Source **knots** und konvertiert intern über `UTILS.KnotsToKmph(Speed)` nach `mission.missionSpeed`. Der Ground-RouteToMission-Pfad konvertiert diesen Wert bei der Wegpunktbildung wieder nach knots für ARMYGROUP.

Acceptance 2 verwendet als Testwerte:

```text
road approach: 10 kt
tactical Vee leg: 8 kt
```

Diese Werte sind technische Testparameter und keine historische Geschwindigkeitsbaseline.

## Road approach coordinate

`COORDINATE:GetClosestPointToRoad(false)` ist im gepinnten Source öffentlich und basiert auf `land.getClosestPointOnRoads("roads", ...)`.

Acceptance 2 berechnet zunächst einen Punkt ungefähr 1500 m vor dem Beobachtungsziel und snappt diesen Punkt anschließend über `GetClosestPointToRoad()` auf die nächstgelegene Straße. Die resultierende taktische Reststrecke muss >1050 m sein.

## Nicht behauptet

Der geprüfte MOOSE-Stand belegt mit diesen APIs **nicht**:

```text
independent field-of-view sector assignment per vehicle
independent turret orientation per vehicle
historically exact tactical battle drill
visually perfect Vee spacing in DCS
```

Diese Punkte dürfen nicht aus `ARMOREDGUARD` oder `Formation.Vehicle.Vee` abgeleitet werden.

## Acceptance-Verweis

- [`OMW-TEST-ARMY-GROUND-ACCEPTANCE-2`](../../mission/tests/army-ground-foundation/ACCEPTANCE-2.md)

Bis zum realen DCS-Lauf bleibt `ARMOREDGUARD` für diesen OMW-Ground-Scope `SOURCE_REVIEWED`, nicht `VALIDATED_FOR_DOCUMENTED_SCOPE`.
