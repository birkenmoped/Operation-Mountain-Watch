---
document_id: OMW-MOOSE-GROUND-FUEL-REFUELLING-ZONE-SOURCE-REVIEW
status: SOURCE_REVIEWED
document_class: TECHNICAL_SOURCE_REVIEW
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Stage 1B2 MOOSE source review for Ground FUELSUPPLY execution
not_authoritative_for:
  - repository-wide production Fuel executor selection before merge to main
  - formal Stage 1B2 accepted baseline without complete executed-MIZ provenance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
validated_in_dcs: true
---

# Ground FUELSUPPLY – MOOSE Source Review

## 1. Geprüfter Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Maßgeblich ist die tatsächlich verwendete `Moose.lua`.

## 2. AUFTRAG:NewFUELSUPPLY

Der gepinnte Source bestätigt:

```lua
function AUFTRAG:NewFUELSUPPLY(Zone)
  local mission=AUFTRAG:New(AUFTRAG.Type.FUELSUPPLY)
  mission:_TargetFromObject(Zone)
  mission.optionROE=ENUMS.ROE.WeaponHold
  mission.optionAlarm=ENUMS.AlarmState.Auto
  mission.missionFraction=1.0
  mission.categories={AUFTRAG.Category.GROUND}
  mission.DCStask=mission:GetDCSMissionTask()
  return mission
end
```

Der FUELSUPPLY-SpecialTask bleibt am Ziel aktiv, bis eine Lifecycle-Aktion ihn beendet. `TaskCancel` behandelt FUELSUPPLY als abschließbaren SpecialTask.

Für einen einzelnen strategischen CampaignState-Transfer ist `AUFTRAG:NewFUELSUPPLY(Zone)` die kleinste direkte MOOSE-Abstraktion, die genau einen FUELSUPPLY-Auftrag repräsentiert.

## 3. BRIGADE:AddRefuellingZone

Der gepinnte Source enthält:

```lua
function BRIGADE:AddRefuellingZone(RefuellingZone)
  local supplyzone={}
  supplyzone.zone=RefuellingZone
  supplyzone.mission=nil
  supplyzone.marker=MARKER:New(supplyzone.zone:GetCoordinate(), "Refuelling Zone"):ToCoalition(self:GetCoalition())
  table.insert(self.refuellingZones, supplyzone)
  return supplyzone
end
```

Der BRIGADE-Statuslauf verwaltet diese Zone persistent:

```lua
if (not supplyzone.mission) or supplyzone.mission:IsOver() then
  supplyzone.mission=AUFTRAG:NewFUELSUPPLY(supplyzone.zone)
  self:AddMission(supplyzone.mission)
end
```

Damit ist `AddRefuellingZone(...)` kein One-Shot-Transfer-Dispatcher. Die Methode registriert einen dauerhaft zu verwaltenden Refuelling-Service. Sobald die aktuelle Mission over ist, erzeugt BRIGADE erneut FUELSUPPLY.

## 4. Reale Stage-1B2-Runtime-Evidenz Build 2-2

Der DCS-Lauf mit Build `GROUND-FUEL-REFUELLING-ZONE-ACCEPTANCE-2-2` bestätigte genau diese Source-Semantik:

```text
FUELSUPPLY assigned
-> convoy reaches Honaker
-> destination zone observed
-> MissionExecute observed
-> CampaignState delivery committed
-> mission cancelled / MissionDone
-> BRIGADE creates replacement FUELSUPPLY
-> acceptance detects MULTIPLE_FUELSUPPLY_MISSIONS_ASSIGNED
```

Daher gilt branch-lokal:

```text
BRIGADE:AddRefuellingZone for persistent service: SOURCE + RUNTIME CONSISTENT
BRIGADE:AddRefuellingZone for one-shot strategic transfer: NOT SUITABLE
```

## 5. Reale Stage-1B2-Runtime-Evidenz Build 2-3

Build 2-3 ersetzte ausschließlich die persistente Service-Registrierung durch einen einzelnen MOOSE-Auftrag:

```text
AUFTRAG:NewFUELSUPPLY(destinationZone)
-> BRIGADE:AddMission(mission)
```

Reale Build-Identität:

```text
Build commit: 2bd930729ed12a073f5364dc139281b60151acf0
BuilderVersion: GROUND-FUEL-REFUELLING-ZONE-ACCEPTANCE-2-3
Bundle SHA-256: 8CBDFA12B1A052517D82CB20A460CA665415353FE38ED2F1C50928BE6C7966A0
DCS: 2.9.28.26385 MT
Mission name: OMW_Template_v19.miz
Executed MIZ SHA-256: PENDING_OWNER_EVIDENCE
```

Der reale DCS-Lauf beobachtete vollständig:

```text
MISSION_QUEUED
-> ROAD_ALIGNED_WAREHOUSE_SPAWN
-> GROUP_MATERIALIZED
-> ARMY_ON_MISSION FUELSUPPLY
-> DESTINATION_ZONE_ENTERED
-> MISSION_EXECUTE_OBSERVED
-> DELIVERY_CONFIRMED
-> MISSION_DONE
-> MOOSE ReturnToLegion
-> RETURNED_HANDOFF
-> RETURN_RTZ_ACTIVE
-> WAREHOUSE_ADD_ASSET
-> PASS
```

Damit sind die zuvor nur source-seitig erwarteten One-Shot- und Return-Semantiken praktisch bestätigt. Die formale `ACCEPTED_TECHNICAL_BASELINE` bleibt jedoch bis zur Rücklieferung des exakten ausgeführten MIZ-Hashes gesperrt.

## 6. ReturnToLegion

`AUFTRAG:SetReturnToLegion(Switch)` kann den Return explizit überschreiben. Ohne `false` entscheidet der OPSGROUP-Default.

Der gepinnte OPSGROUP-Source setzt für Ground-/Naval-Gruppen den Return-to-Legion-Pfad standardmäßig aktiv. Nach abgeschlossenem Mission-/Task-Queue-Pfad kann `_CheckGroupDone(...)` für eine ARMYGROUP mit LEGION den RTZ-Pfad zur Legion-Spawnzone auslösen.

Build 2-3 verwendete keinen projektspezifischen RTZ-Aufruf. Der DCS-Lauf bestätigte den normalen MOOSE-ReturnToLegion-Pfad bis `Returned` und `Warehouse AddAsset`.

## 7. OMW-Architekturgrenze

```text
CampaignState GROUND_FUEL_PACKAGE
= sole strategic resource authority

FUELSUPPLY / BRIGADE / PLATOON / ARMYGROUP / M978
= physical operational execution only
```

Nicht zulässig ist die Ableitung:

```text
M978 physical fuel quantity
-> authoritative CampaignState package quantity
```

Für einen One-Shot-CampaignState-Transfer ist nach Source- und Runtime-Evidenz der bevorzugte physische Pfad:

```text
AUFTRAG:NewFUELSUPPLY
-> BRIGADE:AddMission
```

`BRIGADE:AddRefuellingZone` bleibt für persistente Refuelling-Service-Anforderungen geeignet, nicht für einen einzelnen strategischen Transfer.

## 8. Acceptance

Maßgebliches Acceptance-Dokument:

```text
mission/tests/ground-resupply-execution/ACCEPTANCE-4.md
```

Formale Grenze:

```text
runtime_result: PASS
validated_in_dcs: true
formal_acceptance: BLOCKED_BY_MISSING_EXECUTED_MIZ_SHA256
```

## 9. Status

```text
AUFTRAG:NewFUELSUPPLY: SOURCE_REVIEWED + DCS_OBSERVED
BRIGADE:AddRefuellingZone persistent replacement behavior: SOURCE_REVIEWED + DCS_OBSERVED
FUELSUPPLY SpecialTask cancel path: SOURCE_REVIEWED + DCS_OBSERVED
MOOSE default Ground ReturnToLegion completion for one-shot FUELSUPPLY: DCS_OBSERVED
preferred one-shot Fuel executor: MOOSE FUELSUPPLY
formal Stage 1B2 accepted technical baseline: BLOCKED_BY_MISSING_EXECUTED_MIZ_SHA256
```
