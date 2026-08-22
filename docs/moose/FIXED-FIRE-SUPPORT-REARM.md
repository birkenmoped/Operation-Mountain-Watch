---
document_id: OMW-MOOSE-FIXED-FIRE-SUPPORT-REARM
status: PLANNED
document_class: TECHNICAL_ARCHITECTURE_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-reviewed MOOSE composition for local fixed-fire-support ammunition materialization and rearm
  - source-reviewed support return-to-stock lifecycle for Bostick, Wright, Fortress and Honaker
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/ground-ammo-rearm-integration
source_commit: 5c4bbe44bee994c5dd9b1c9cfec011e7a67c8158
validated_in_dcs: false
---

# MOOSE Fixed Fire Support Rearm

## 1. Zweck und Status

Dieses Dokument beschreibt den revidierten MOOSE-first-Pfad für lokalen Munitionsnachschub der festen OMW-Feuerunterstützungsstellungen Bostick, Wright, Fortress und Honaker.

```text
Status: SOURCE_REVIEWED / DCS_PENDING
```

Der frühere Bostick-Vertical-Slice und der erste kombinierte Acceptance-2-Lauf bleiben historische technische Evidenz für ihre exakte Provenienz. Sie validieren nicht den hier beschriebenen Local-Spawn-/Return-to-stock-Pfad.

## 2. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## 3. Source-verifizierte MOOSE-Verträge

### 3.1 Lokale Warehouse-Materialisierung

Im gepinnten Source vorhanden:

```lua
WAREHOUSE:SetSpawnZone(Zone, MaxDist)
WAREHOUSE:SetValidateAndRepositionGroundUnits(Switch)
WAREHOUSE:AddAsset(Group)
```

Für Fixed Fire Support wird eine dedizierte Mission-Editor-Spawnzone innerhalb der jeweiligen FOB/COP-Anlage verwendet. `SetValidateAndRepositionGroundUnits(true)` lässt MOOSE die Ground-Unit-Position vor Materialisierung auf eine geeignete freie Bodenposition korrigieren.

Der private `OMW_GroundRoadSpawnAdapter` ist **nicht** Teil dieses Fixed-Fire-Support-Pfades. Er bleibt auf die dokumentierten Road-/Convoy-Verwendungen begrenzt.

### 3.2 ARTY-Rearm und Rückkehr

Im gepinnten Source vorhanden:

```lua
ARTY:SetRearmingGroup(Group)
ARTY:SetRearmingGroupOnRoad(false)
ARTY:SetRearmingDistance(100)
ARTY:Rearm()
```

`ARTY:onafterRearm(...)` speichert die aktuelle Koordinate der RearmingGroup als `RearmingGroupCoord`.

`ARTY:onafterRearmed(...)`:

```text
wenn Entfernung RearmingGroup -> RearmingGroupCoord > RearmingDistance
-> MOOSE _Move(...) zurück zur gemerkten Ausgangskoordinate

sonst
-> ClearTasks()
```

OMW erzeugt deshalb keinen eigenen Return-Wegpunkt und keine parallele Routinglogik.

### 3.3 Return-to-stock-Handoff

Nach `OnAfterRearmed` startet OMW nur einen kleinen MOOSE-`SCHEDULER`-Watch:

```text
Intervall: 5 s
Timeout: 300 s
Rückkehrgrenze: 100 m
```

Der Watch prüft ausschließlich die Distanz des bekannten M1083 zu seiner vor dem Rearm gespeicherten Ausgangskoordinate. Sobald die MOOSE-ARTY-Rückkehrgrenze erreicht ist, wird der bekannte physische Support über den öffentlichen Warehouse-Pfad zurückgegeben:

```lua
WAREHOUSE:AddAsset(Group)
```

Damit bleibt der Asset-/Stock-Lifecycle MOOSE-owned. Es gibt keinen nativen DCS-Destroy-Aufruf, keinen Teleport und keine zweite Ressourcenbuchhaltung.

## 4. Strategische Autorität

```text
CampaignState
-> einzige strategische Autorität für GROUND_AMMO_PACKAGE

MOOSE WAREHOUSE/BRIGADE/PLATOON
-> operativer Support-Assetpool und Materialisierung

MOOSE ARTY
-> physischer Rearm-/Return-Lifecycle

DCS GROUP
-> temporäre physische Repräsentation des M1083
```

Die Rückgabe des M1083 an Warehouse-Stock erstattet **keine** strategische Munition. Die lokale `GROUND_AMMO_PACKAGE`-Transaktion bleibt nach erfolgreichem Rearm `CONSUMED`.

## 5. Mission-Editor-Vertrag

Der aktuelle Mission-Editor-Vertrag verwendet pro Standort eine dedizierte lokale Resupply-Zone:

```text
ZON_BLUE_GND_BOSTICK_RESUPPLY
ZON_BLUE_GND_WRIGHT_RESUPPLY
ZON_BLUE_GND_FORTRESS_RESUPPLY
ZON_BLUE_GND_HONAKER_RESUPPLY
```

Anforderung:

```text
- innerhalb der jeweiligen FOB/COP-Anlage
- nahe dem lokalen Warehouse
- freier, für einen M1083 geeigneter Boden
- nicht als Straßen-/Convoy-Zone auslegen
- Abstand zu HESCOs, Gebäuden, Statics und anderen Ground Units berücksichtigen
```

Die bestehenden ACCESS-Zonen behalten ihre bisherigen Ground-/Convoy-Verträge und werden nicht entfernt.

Die vom Projektinhaber bereitgestellte `OMW_Template_v15(10).miz` enthält diese vier `*_RESUPPLY`-Zonen. Die MIZ wurde nur read-only geprüft; die konkrete DCS-Tauglichkeit der Bodenflächen bleibt bis zum Lauf offen.

## 6. Acceptance-Grenze

Der nächste kombinierte Acceptance-2-Lauf muss pro Standort nachweisen:

```text
fire
-> ammo decrease
-> local Warehouse M1083 materialization in *_RESUPPLY zone
-> exactly one CampaignState ammo package consumed
-> ARTY Rearmed
-> ARTY-owned support return
-> WAREHOUSE AddAsset return-to-stock
-> no physical support group remains
-> SITE_PASS
```

Aggregate PASS nur bei vier `SITE_PASS`.

Aktueller Buildstand:

```text
Source commit:
5c4bbe44bee994c5dd9b1c9cfec011e7a67c8158

BuilderVersion:
GROUND-FIRE-SUPPORT-ACCEPTANCE-2-3

Bundle SHA-256:
C3526CE2863C94D4F351D438219B744D23B2A11C09A59094944332DBEDD59B31

Build/Hash:
owner-local build + independent Get-FileHash MATCH
```

Bis zum nächsten DCS-Lauf gilt:

```text
Local spawn: SOURCE_REVIEWED / DCS_PENDING
ARTY support return: SOURCE_REVIEWED / DCS_PENDING for this composition
Warehouse AddAsset cleanup: SOURCE_REVIEWED / DCS_PENDING for this composition
Honaker 2B11 end-to-end: DCS_PENDING
```
