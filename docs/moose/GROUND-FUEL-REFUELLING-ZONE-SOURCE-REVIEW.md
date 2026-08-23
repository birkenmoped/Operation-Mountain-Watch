---
document_id: OMW-MOOSE-GROUND-FUEL-REFUELLING-ZONE-SOURCE-REVIEW
status: SOURCE_REVIEWED
document_class: TECHNICAL_SOURCE_REVIEW
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Stage 1B2 MOOSE source review for BRIGADE RefuellingZone/FUELSUPPLY execution
not_authoritative_for:
  - DCS runtime validation
  - production Fuel executor selection
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Ground Fuel RefuellingZone / FUELSUPPLY – MOOSE Source Review

## 1. Geprüfter Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Maßgeblich ist die tatsächlich verwendete `Moose.lua`.

## 2. BRIGADE:AddRefuellingZone

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

Der BRIGADE-Statuslauf erzeugt für registrierte Refuelling Zones selbstständig FUELSUPPLY-Missionen:

```lua
if (not supplyzone.mission) or supplyzone.mission:IsOver() then
  supplyzone.mission=AUFTRAG:NewFUELSUPPLY(supplyzone.zone)
  self:AddMission(supplyzone.mission)
end
```

Damit ist `BRIGADE:AddRefuellingZone(...)` der MOOSE-native Einstieg, wenn die BRIGADE den Refuelling-Service verwalten soll.

## 3. AUFTRAG:NewFUELSUPPLY

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

Für den FUELSUPPLY-SpecialTask erzeugt MOOSE am Ziel keine zusätzliche DCS-Tankmengen-Autorität. Der OPSGROUP-Pfad bleibt dort aktiv und wartet auf eine spätere Lifecycle-Aktion.

`TaskCancel` behandelt `AUFTRAG.SpecialTask.FUELSUPPLY` als unmittelbar abschließbaren SpecialTask und führt damit in den normalen `TaskDone`/`MissionDone`-Lifecycle.

## 4. ReturnToLegion

`AUFTRAG:SetReturnToLegion(Switch)` kann den Mission-Return explizit überschreiben. Ohne Override entscheidet der OPSGROUP-Default.

Der gepinnte OPSGROUP-Source setzt bei `SetReturnToLegion(nil)` beziehungsweise ohne `false` den Ground-/Naval-Return auf `true`. Nach abgeschlossenem Mission-/Task-Queue-Pfad ruft `_CheckGroupDone(...)` bei vorhandener LEGION und `legionReturn=true` für ARMYGROUP `RTZ(self.legion.spawnzone)` auf.

Stage 1B2 verwendet deshalb bewusst **keinen** projektspezifischen expliziten RTZ-Aufruf. Der Test soll den MOOSE-eigenen Return-Pfad beobachten.

## 5. Offizielle Beispiele

Die offiziellen MOOSE-Missions-Repositories wurden nach `AddRefuellingZone` / `FUELSUPPLY` durchsucht. In der durchgeführten Suche wurde kein direkt passendes offizielles Demonstrationsbeispiel für den vollständigen `BRIGADE:AddRefuellingZone -> FUELSUPPLY -> ReturnToLegion`-Pfad gefunden.

Das ist kein Negativbeweis über die API. Für Stage 1B2 sind deshalb der gepinnte Source und der reproduzierbare DCS-Acceptance-Test maßgeblich.

## 6. OMW-Architekturgrenze

```text
CampaignState GROUND_FUEL_PACKAGE
= sole strategic resource authority

BRIGADE / FUELSUPPLY / ARMYGROUP / M978
= physical operational execution only
```

Nicht zulässig ist die Ableitung:

```text
M978 physical fuel quantity
-> authoritative CampaignState package quantity
```

## 7. Stage-1B2-Testgrenze

```text
BRIGADE:AddRefuellingZone(Honaker ACCESS)
-> MOOSE-created FUELSUPPLY
-> existing FUEL-capable PLATOON
-> road-aligned warehouse materialization
-> destination MissionExecute proof
-> exact-once CampaignState settlement
-> FUELSUPPLY cancel
-> normal MOOSE ReturnToLegion
-> Returned -> Warehouse AddAsset
```

Keine harten Outbound-/Return-Fahrzeit-Timeouts.

Acceptance:

```text
mission/tests/ground-resupply-execution/ACCEPTANCE-4.md
```

## 8. Status

```text
BRIGADE:AddRefuellingZone: SOURCE_REVIEWED
AUFTRAG:NewFUELSUPPLY: SOURCE_REVIEWED
FUELSUPPLY SpecialTask cancel path: SOURCE_REVIEWED
MOOSE default Ground ReturnToLegion path: SOURCE_REVIEWED
Stage 1B2 runtime: NOT_YET_RUN
```
