---
document_id: OMW-MOOSE-GROUND-FUEL-REFUELLING-ZONE-SOURCE-REVIEW
status: SOURCE_REVIEWED
document_class: TECHNICAL_SOURCE_REVIEW
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Stage 1B2 MOOSE source review for Ground FUELSUPPLY execution
not_authoritative_for:
  - production Fuel executor selection
  - untested one-shot FUELSUPPLY return completion
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
validated_in_dcs: false
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
AUFTRAG:NewFUELSUPPLY one-shot execution: SOURCE REVIEWED, COMPLETE RETURN TEST PENDING
```

## 5. ReturnToLegion

`AUFTRAG:SetReturnToLegion(Switch)` kann den Return explizit überschreiben. Ohne `false` entscheidet der OPSGROUP-Default.

Der gepinnte OPSGROUP-Source setzt für Ground-/Naval-Gruppen den Return-to-Legion-Pfad standardmäßig aktiv. Nach abgeschlossenem Mission-/Task-Queue-Pfad kann `_CheckGroupDone(...)` für eine ARMYGROUP mit LEGION den RTZ-Pfad zur Legion-Spawnzone auslösen.

Stage 1B2 Build 2-3 verwendet deshalb weiterhin keinen projektspezifischen RTZ-Aufruf. Genau dieser MOOSE-eigene Rückkehrpfad ist Teil des nächsten DCS-Tests.

## 6. OMW-Architekturgrenze

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

## 7. Stage-1B2 Build 2-3 Testgrenze

```text
AUFTRAG:NewFUELSUPPLY(Honaker ACCESS)
-> BRIGADE:AddMission
-> existing FUELSUPPLY-capable PLATOON
-> road-aligned warehouse materialization
-> MissionExecute observation
-> independent destination-zone proof
-> exact-once CampaignState settlement
-> FUELSUPPLY cancel
-> normal MOOSE ReturnToLegion
-> Returned -> Warehouse AddAsset
```

Keine persistente `AddRefuellingZone(...)`-Registrierung und keine harten Outbound-/Return-Fahrzeit-Timeouts.

Acceptance:

```text
mission/tests/ground-resupply-execution/ACCEPTANCE-4.md
```

## 8. Status

```text
AUFTRAG:NewFUELSUPPLY: SOURCE_REVIEWED
BRIGADE:AddRefuellingZone persistent replacement behavior: SOURCE_REVIEWED + DCS_OBSERVED
FUELSUPPLY SpecialTask cancel path: SOURCE_REVIEWED + DCS_OBSERVED
MOOSE default Ground ReturnToLegion completion for one-shot FUELSUPPLY: DCS_TEST_PENDING
production Fuel executor selection: NOT_YET_ACCEPTED
```
