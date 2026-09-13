---
document_id: OMW-MOOSE-FIRE-SUPPORT-INSTALLATION-PERIMETER-SOURCE-REVIEW
status: SOURCE_REVIEWED
document_class: MOOSE_SOURCE_REVIEW
owning_policy: OMW-GOV-001
authoritative_for:
  - MOOSE source evidence for six-site installation alarm perimeter resolution
  - public method signatures used by Production Base Acceptance 3 perimeter wiring
  - MOOSE source evidence reused by the Honaker-derived QRF mission and Ground return lifecycle
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# MOOSE Source Review – Installation Alarm Perimeters and QRF Lifecycle

## 1. Gepinnter Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

`SOURCE_REVIEWED` ist kein DCS-PASS.

## 2. Perimeter-Pfad

Im gepinnten Source geprüft und im aktuellen Acceptance-Pfad verwendet:

```text
ZONE:FindByName(...)
ZONE_RADIUS:New(...)
ZONE_BASE:GetCoordinate(...)
WAREHOUSE / BRIGADE GetCoordinate()
COORDINATE:GetIntermediateCoordinate(...)
CONTROLLABLE:RouteGroundTo(...)
OPSZONE physical UNIT / GROUND_UNIT qualification
```

Jalalabad:

```text
OMW_BLUE_OBJECTIVE_JALALABAD_AIRPORT
-> ZONE:FindByName(...)
-> GetCoordinate()
-> midpoint only
-> runtime ZONE_RADIUS 2438.4 m / 8000 ft
-> OPSZONE
```

Die vorhandene 6000-ft-ME-Zone wird nicht als Alarmradius wiederverwendet. Keine `.miz`-Mutation.

Die anderen fünf Standorte verwenden die vorhandene Warehouse-/BRIGADE-Koordinate als Mittelpunkt ihrer runtime-only `ZONE_RADIUS`.

## 3. Accepted QRF Mission Contract

Die aktuelle Fire-Support-QRF-Integration darf den bereits dokumentierten Honaker-Vertrag nicht durch einen alternativen MOOSE-Auftrag ersetzen.

Source-/Projektvertrag:

```text
AUFTRAG:NewONGUARD(TargetCoordinate)
AUFTRAG:SetEngageDetected(Range, TargetTypes, EngageZone)
AUFTRAG:SetReturnToLegion(true)
AUFTRAG:SetTeleport(false)
```

OMW-Konfiguration:

```text
initial coordinate: physical hostile GROUP coordinate from incident evidence
engage range: 5 NM
target types: {"Ground Units"}
engage zone: site-local 5 NM tactical ZONE_RADIUS around BRIGADE coordinate
return: SetReturnToLegion(true)
```

Referenzimplementierung:

```text
mission/tests/stage3-honaker-wright-full-response/
  src/01-honaker-wright-full-response-acceptance.lua
```

Die zwischenzeitliche Fire-Support-Substitution durch `AUFTRAG:NewGROUNDATTACK(...)` ist verworfen. Sie ist **nicht** die akzeptierte QRF-Baseline.

## 4. QRF Release Authority

Der Honaker-Vertrag trennt lokale Incident-Completion und QRF-Missionsende.

Verbindlich:

```text
perimeter clear != QRF release
incident close   != QRF release
movement distance != QRF release
```

Der QRF-Auftrag darf erst nach expliziter Supported-Element-/C2-Freigabe gecancelt werden. Die konkrete CAS-gekoppelte Honaker-Freigabe wird nicht automatisch zur generischen Six-Site-Policy erklärt.

Acceptance 3 besitzt daher **keine** eigene QRF-Release-Logik.

## 5. ACCESS / Homezone / Return

Die site-lokale ACCESS-Zone wird dem `BRIGADE` als Spawnzone zugeordnet. Der gepinnte MOOSE-Pfad setzt sie für daraus erzeugte `ARMYGROUP`-Instanzen als Homezone.

Bereits vorhandene Ground-Evidence:

```text
ARMY Ground Acceptance 6:
MissionDone / explicit return
-> ARMYGROUP:RTZ(existing site ACCESS zone, OnRoad)
-> Returned
-> Warehouse AddAsset
-> physical group removal

ARMY Ground Acceptance 7:
normal return / partial loss / damaged survivor
-> same MOOSE physical return lifecycle
-> exactly-once strategic settlement
```

Fire Support implementiert dafür keinen eigenen Return-FSM.

## 6. Road-aligned Materialization

Owner-approved project exception:

```text
scripts/ground/OMW_GroundRoadSpawnAdapter.lua
```

Einführungscommit:

```text
623dfd51fbf47043a2ff822f2ac489de123c1783
Add approved Ground road spawn adapter
```

Der Adapter verändert nur die vorbereitete Ground-WAREHOUSE-Spawn-Geometrie. BRIGADE, WAREHOUSE, PLATOON, ARMYGROUP und AUFTRAG bleiben MOOSE-owned.

Der Adapter verlangt vom Aufrufer eine bereits qualifizierte Road-Geometrie. Das bedeutet ausdrücklich: Die Existenz des Adapters legitimiert **keine neue dynamische Routing-/Anchor-Policy**. Jede caller-seitige Road-Geometrie muss gegen bereits akzeptierte Ground-Geometrie reconciliert werden.

## 7. Acceptance-3-Grenze

Acceptance 3 prüft aktuell ausschließlich:

```text
6 site perimeters
-> PROXIMITY_INTRUSION
-> authoritative incidents
-> exactly one initial QRF demand each
-> ACCESS materialization
-> ONGUARD mission type
-> physical QRF response >=25 m
```

Die 25 m sind ausschließlich Beobachtung physischer Bewegung. Acceptance 3 ruft weder `ExpireDemand(...)` noch `Cancel()` auf und prüft in diesem Scope keinen künstlich ausgelösten Rückweg.

## 8. Anti-Regression

Verbindlicher Guardrail:

```text
docs/moose/FIRE-SUPPORT-ACCEPTED-IMPLEMENTATION-MATRIX.md
tests/mission-demand/test_fire_support_qrf_accepted_contract.lua
```

Der automatisierte Vertrag blockiert insbesondere:

```text
GROUNDATTACK substitution
missing SetEngageDetected
missing SetReturnToLegion(true)
movement-driven Acceptance release
Acceptance-owned supported-element release token
```

## 9. Statusgrenze

```text
MOOSE signatures / source path: SOURCE_REVIEWED
Honaker QRF semantics: existing documented baseline
Ground return mechanics: existing documented DCS evidence in their exact scopes
current six-site Fire Support integration: NOT DCS VALIDATED
```