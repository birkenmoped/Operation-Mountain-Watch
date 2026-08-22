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
source_commit: ea07916ddc8e18b5f5d72e48750229dc8085ff63
validated_in_dcs: false
---

# MOOSE Fixed Fire Support Rearm

## 1. Zweck und Status

Dieses Dokument beschreibt den MOOSE-first-Pfad für lokalen Munitionsnachschub der festen OMW-Feuerunterstützungsstellungen Bostick, Wright, Fortress und Honaker.

```text
Status: SOURCE_REVIEWED / DCS_PENDING
```

## 2. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## 3. Lokale Warehouse-Materialisierung

Für Fixed Fire Support wird eine dedizierte Mission-Editor-RESUPPLY-Zone auf freiem Boden innerhalb der jeweiligen FOB/COP-Anlage verwendet.

Produktiver Kandidat:

```lua
WAREHOUSE:SetSpawnZone(Zone, MaxDist)
```

Bewusst nicht verwendet:

```lua
WAREHOUSE:SetValidateAndRepositionGroundUnits(true)
```

### 3.1 Verifizierter Defekt im gepinnten MOOSE-Stand

Die Methode `WAREHOUSE:SetValidateAndRepositionGroundUnits(...)` ist real und in MOOSE DEVELOP dokumentiert; sie wurde nicht von OMW erfunden. Der aufgerufene gepinnte Source enthält jedoch:

```lua
function UTILS.ValidateAndRepositionGroundUnits(Positions, Anchor, MaxRadius, Spacing)
  local units = Positions
  Anchor = Anchor or UTILS.GetCenterPoint(units)
```

Für den gepinnten OMW-Stand wurde keine Definition von `UTILS.GetCenterPoint(...)` gefunden. Der reale DCS-Lauf vom 22.08.2026 reproduzierte exakt:

```text
attempt to call field 'GetCenterPoint' (a nil value)
ValidateAndRepositionGroundUnits
-> _SpawnAssetGroundNaval
-> _SpawnAssetRequest
-> onafterRequest
```

Damit ist der Pfad für den gepinnten OMW-MOOSE-Stand als fehlerhaft behandelt. OMW patcht MOOSE nicht und implementiert `GetCenterPoint` nicht nach, weil der benötigte lokale Materialisierungsvertrag mit der öffentlichen `WAREHOUSE:SetSpawnZone(...)`-API und einer kontrolliert freien ME-Zone erfüllt werden kann.

Offizielle MOOSE-Warehouse-Beispiele verwenden `SetSpawnZone(...)` für Ground-Assets; im Review wurde kein offizielles Missionsbeispiel gefunden, das `SetValidateAndRepositionGroundUnits(...)` verwendet.

## 4. Mission-Editor-Vertrag

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

Der private `OMW_GroundRoadSpawnAdapter` bleibt außerhalb dieses Fixed-Fire-Support-Pfades und nur für dokumentierte Road-/Convoy-Verwendungen bestehen.

## 5. ARTY-Rearm und Rückkehr

Im gepinnten Source vorhanden:

```lua
ARTY:SetRearmingGroup(Group)
ARTY:SetRearmingGroupOnRoad(false)
ARTY:SetRearmingDistance(100)
ARTY:Rearm()
```

`ARTY:onafterRearm(...)` speichert die Ausgangskoordinate der RearmingGroup. `ARTY:onafterRearmed(...)` übernimmt bei ausreichender Distanz die physische Rückkehr zur gemerkten Ausgangskoordinate.

OMW erzeugt keinen eigenen Return-Wegpunkt. Ein MOOSE-`SCHEDULER` prüft alle 5 s die Rückkehrgrenze von 100 m; Timeout 300 s. Nach bestätigter Rückkehr erfolgt:

```lua
WAREHOUSE:AddAsset(Group)
```

Damit bleibt der operative Asset-/Stock-Lifecycle MOOSE-owned. CampaignState bleibt alleinige strategische Autorität für `GROUND_AMMO_PACKAGE`.

## 6. DCS-Lauf Revision 3 vom 22.08.2026

Revision 3 verwendete:

```text
BuilderVersion: GROUND-FIRE-SUPPORT-ACCEPTANCE-2-3
Bundle SHA-256: C3526CE2863C94D4F351D438219B744D23B2A11C09A59094944332DBEDD59B31
MIZ SHA-256: FBA4D8C5966DA375396014E2C2E8BC81B17F7595EBE5DBEF9544AD9FDD2747C5
DCS: 2.9.28.26385 MT
```

Reale Log-Artefakte:

```text
dcs(20260822-094345).log
SHA-256: 844D5D5D1E38C96E925F3186F216356A44AB7F91923CB20B33C3D1AC79434B55

debrief(20260822-094344).log
SHA-256: 5E07BB46F6709FA847C27A239934305CB9974E5569EDB86BC61DD6A3D571499A
```

Ergebnis:

```text
BOSTICK   fire/ammo-decrease/rearm-request reached
WRIGHT    fire/ammo-decrease/rearm-request reached
FORTRESS  fire/ammo-decrease/rearm-request reached
HONAKER   fire/ammo-decrease/rearm-request reached

M1083 materialization: 0/4
Aggregate: FAIL / TIMEOUT
Root cause: pinned MOOSE ValidateAndRepositionGroundUnits -> missing UTILS.GetCenterPoint
```

Dieser Lauf validiert weder Support-Materialisierung noch CampaignState-Verbrauch, Rearm-Completion, Support-Return oder Return-to-stock.

## 7. Revision 4 – aktueller Korrekturkandidat

Revision 4 entfernt ausschließlich die Nutzung des fehlerhaften MOOSE-Reposition-Pfades aus Fixed Fire Support:

```text
WAREHOUSE:SetSpawnZone(...): retained
WAREHOUSE:SetValidateAndRepositionGroundUnits(...): not called
RoadSpawnAdapter: not used
MOOSE patch/override: none
```

Der Builder muss den fehlerhaften Methodenaufruf im Fixed-Fire-Support-Modul ausdrücklich blockieren.

Geplanter nächster Acceptance-Lauf bleibt gebündelt:

```text
fire
-> ammo decrease
-> local M1083 materialization in *_RESUPPLY zone
-> exactly one CampaignState ammo package consumed
-> ARTY Rearmed
-> ARTY-owned support return
-> WAREHOUSE AddAsset return-to-stock
-> no physical support group remains
-> SITE_PASS
```

Aggregate PASS nur bei vier `SITE_PASS`.
