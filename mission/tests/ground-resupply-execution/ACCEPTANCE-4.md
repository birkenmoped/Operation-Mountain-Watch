---
document_id: OMW-GROUND-FUEL-REFUELLING-ZONE-ACCEPTANCE-2
status: PLANNED
document_class: ACCEPTANCE_PLAN_AND_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Stage 1B2 MOOSE-native Ground FUEL RefuellingZone/FUELSUPPLY acceptance plan
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Stage 1B2 – MOOSE-native Ground FUEL RefuellingZone / FUELSUPPLY Acceptance

## 1. Entscheidung und Zweck

Der Projektinhaber hat am 23.08.2026 entschieden, vor Stage 1D den normalen MOOSE-Fuel-Pfad erneut und diesmal ohne den alten Harness-Timeout zu prüfen.

Ziel ist ausdrücklich **nicht**, den timeout-kontaminierten Stage-1B-Lauf als Fehler fortzuschreiben. Stattdessen wird geprüft, ob der von MOOSE selbst vorgesehene BRIGADE-RefuellingZone-Pfad für OMW tragfähig ist.

```text
Stage 1B historical result:
HISTORICAL_TEST_FIXTURE
HARNESS_TIMEOUT_CONTAMINATED
INCONCLUSIVE

Stage 1B2 objective:
MOOSE-native BRIGADE:AddRefuellingZone(...)
-> BRIGADE creates AUFTRAG:NewFUELSUPPLY(...) itself
-> physical FUEL convoy
-> destination execution
-> exact-once CampaignState settlement
-> normal MOOSE ReturnToLegion
-> Returned -> Warehouse AddAsset
```

## 2. MOOSE-First Source Review

Geprüfter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Der tatsächlich verwendete Source bestätigt:

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

Im BRIGADE-Statuslauf gilt source-seitig:

```lua
if (not supplyzone.mission) or supplyzone.mission:IsOver() then
  supplyzone.mission=AUFTRAG:NewFUELSUPPLY(supplyzone.zone)
  self:AddMission(supplyzone.mission)
end
```

`AUFTRAG:NewFUELSUPPLY(Zone)` erzeugt einen Ground-FUELSUPPLY-Auftrag. Der OPSGROUP-SpecialTask bleibt am Ziel aktiv und wartet, bis eine spätere Lifecycle-Aktion den Auftrag beendet. `TaskCancel` behandelt FUELSUPPLY als abschließbaren SpecialTask. Nach `MissionDone` entscheidet der normale OPSGROUP-Lifecycle anhand von `legionReturn`; der Ground-Default ist Return-to-Legion, sofern er nicht ausdrücklich auf `false` gesetzt wurde.

Damit ist für Stage 1B2 kein eigener FUELSUPPLY-Dispatcher und kein expliziter OMW-RTZ-Override erforderlich.

## 3. Acceptance-Vertrag

```text
HONAKER GROUND_FUEL_PACKAGE 36
-> test-only consume 18
-> HONAKER 18 / REORDER
-> MissionDemand RESUPPLY
-> CampaignState TRANSFER 18 Joyce -> Honaker
-> TPL_BLUE_CONVOY_FUEL_LIGHT_06
-> BRIGADE / PLATOON
-> BRIGADE:AddRefuellingZone(Honaker ACCESS)
-> MOOSE creates FUELSUPPLY mission
-> road-aligned warehouse materialization
-> destination MissionExecute proof
-> CampaignState DELIVERED
-> MissionDemand SUCCESS
-> FUELSUPPLY cancel after exact-once settlement
-> MissionDone
-> normal MOOSE ReturnToLegion
-> Returned
-> Warehouse AddAsset
-> physical cleanup
```

Strategische Endwerte:

```text
JOYCE FUEL   40 -> 22
HONAKER FUEL 36 -> 18 -> 36
```

## 4. Wichtige Abgrenzungen

```text
CampaignState GROUND_FUEL_PACKAGE
= einzige strategische Fuel-Ressourcenautorität

MOOSE FUELSUPPLY
= physischer/operativer Executor

M978
= physische Repräsentation
```

Der Test definiert ausdrücklich **nicht**:

```text
1 M978 = X GROUND_FUEL_PACKAGE
DCS internal fuel quantity = CampaignState quantity
MOOSE Warehouse fuel = CampaignState fuel
```

## 5. Harness-Regeln

Der alte Fehlerpfad wird nicht wiederholt:

```text
Hard outbound travel timeout: NONE
Hard return travel timeout: NONE
Completion: event-driven
```

Es bleibt nur die bereits in anderen Ground-Acceptances verwendete kurze Settlement-Verzögerung nach `Returned`, bevor der finale Zustand geprüft wird.

Der vorhandene owner-approved `OMW_GroundRoadSpawnAdapter.lua` wird unverändert weiterverwendet. Keine neue Spawnlogik, kein MIST, keine Native-DCS-Parallelimplementierung und keine `.miz`-Mutation durch ChatGPT.

## 6. Testdateien

```text
mission/tests/ground-resupply-execution/src/04-ground-fuel-refuelling-zone-acceptance.lua
tools/build-ground-fuel-refuelling-zone-acceptance-2.ps1
mission/tests/ground-resupply-execution/dist/OMW_Ground_Fuel_Refuelling_Zone_Acceptance_2.lua
```

Builder-Version:

```text
GROUND-FUEL-REFUELLING-ZONE-ACCEPTANCE-2-1
```

## 7. Entscheidungsregel nach DCS-Test

```text
PASS
-> GROUND_FUEL_PACKAGE physical execution target becomes MOOSE RefuellingZone/FUELSUPPLY
-> Stage 1C NOTHING remains technical evidence but is no longer the preferred Fuel executor
-> reconcile production executor and documentation before adoption

FAIL with clean, non-timeout-contaminated evidence
-> analyze actual MOOSE/DCS failure cause
-> do not silently revert architecture

INCONCLUSIVE
-> no architecture change
-> Stage 1C remains the accepted strategic meta-resupply fallback evidence
```

## 8. Aktueller Status

```text
status: STAGED_FOR_LOCAL_BUILD_AND_DCS_ACCEPTANCE
validated_in_dcs: false
result: NOT_RUN
```
