---
document_id: OMW-GROUND-FUEL-REFUELLING-ZONE-ACCEPTANCE-2
status: ACCEPTED_TECHNICAL_BASELINE
document_class: ACCEPTANCE_PLAN_AND_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Stage 1B2 MOOSE-native Ground FUELSUPPLY acceptance result
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
acceptance_branch: agent/automatic-response-orchestration
acceptance_commit: 2bd930729ed12a073f5364dc139281b60151acf0
acceptance_mission: OMW_Template_v19.miz
acceptance_mission_sha256: 603422efaffa860041089d0f1ad41d35642a7863bc1c7b658e0b8f15a6eb63f2
dcs_version: 2.9.28.26385 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
validated_in_dcs: true
---

# Stage 1B2 – MOOSE-native Ground FUELSUPPLY Acceptance

## 1. Ergebnis

Stage 1B2 ist für die unten exakt dokumentierte Provenienz technisch akzeptiert.

```text
CampaignState
-> MissionDemand RESUPPLY
-> CampaignState TRANSFER Joyce -> Honaker
-> MOOSE BRIGADE / PLATOON / ARMYGROUP
-> AUFTRAG:NewFUELSUPPLY(destinationZone)
-> BRIGADE:AddMission(mission)
-> road-aligned materialization
-> destination-zone proof
-> MissionExecute
-> exact-once CampaignState delivery
-> MissionDemand SUCCESS
-> MissionDone
-> normal MOOSE ReturnToLegion
-> Returned
-> Warehouse AddAsset
-> PASS
```

CampaignState bleibt alleinige strategische Ressourcenautorität.

## 2. Akzeptierte Provenienz

```text
TestId: GROUND-FUEL-REFUELLING-ZONE-ACCEPTANCE-2
Build commit: 2bd930729ed12a073f5364dc139281b60151acf0
BuilderVersion: GROUND-FUEL-REFUELLING-ZONE-ACCEPTANCE-2-3
GeneratedUtc: 2026-08-23T23:08:54Z
Bundle SHA-256: 8CBDFA12B1A052517D82CB20A460CA665415353FE38ED2F1C50928BE6C7966A0
Builder SHA-256: BD5C8657B759A8915F471AC54B56C375DCC7865B745EA208AC7B3DF822B6A023
Acceptance source SHA-256: 8FAD1F29E2054C5CE621549AA167BFF2A6DE45EE7C39EAEDF57AD3E234029287
OMW_MissionDemand.lua SHA-256: E348E75B87135B99D780E07CA6B6FB7C3C530E048E9C6DE790328D147DE32848
OMW_ResourceDemandPolicy.lua SHA-256: BDC20ACEDAB60F662093077B8320220EBB71C6C641CC604C4356231B8405913C
OMW_GroundRoadSpawnAdapter.lua SHA-256: 1A81FB2E5270C493373CF5BF6EC01F5AFED47004BF25C4225524121155D983E8

DCS: 2.9.28.26385 MT
Mission: OMW_Template_v19.miz
Executed MIZ SHA-256: 603422EFAFFA860041089D0F1AD41D35642A7863BC1C7B658E0B8F15A6EB63F2
Mission file LastWriteTime after test verification: 2026-08-24 20:46:49 local
Owner confirmation: mission was not saved or otherwise modified after the successful Build-2-3 DCS run before hashing

MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## 3. Strategischer Testvertrag

```text
JOYCE GROUND_FUEL_PACKAGE   40 -> 22
HONAKER GROUND_FUEL_PACKAGE 36 -> 18 -> 36
TransferQuantity: 18
Template: TPL_BLUE_CONVOY_FUEL_LIGHT_06
Physical tankers: 2 x M978 HEMTT Tanker
```

Nicht aus diesem Test abzuleiten:

```text
1 M978 = X GROUND_FUEL_PACKAGE
DCS fuel quantity = CampaignState quantity
MOOSE Warehouse fuel = CampaignState fuel
```

## 4. Beobachteter Build-2-3-Lifecycle

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

Terminaler Zustand:

```text
originFinal=22
destinationFinal=36
transferQuantity=18
physicalMission=ONESHOT_FUELSUPPLY
demandStatus=SUCCESS
spawnCount=1
missionExecuteCount=1
destinationObserved=true
missionDoneCount=1
returnedCount=1
warehouseAddAssetCount=1
```

## 5. Build-2-1/2-2-Historie

Build 2-1 war wegen einer falschen synchronen Zielzonenannahme im Harness `HARNESS_LOGIC_ERROR / INCONCLUSIVE`.

Build 2-2 bestätigte FUELSUPPLY-Ausführung bis Delivery, verwendete jedoch `BRIGADE:AddRefuellingZone(...)`. Der gepinnte MOOSE-Source und der Runtime-Lauf bestätigten, dass diese API eine persistente Service-Registrierung ist und nach Missionsende erneut FUELSUPPLY erzeugt. Sie ist damit für einen einzelnen strategischen CampaignState-Transfer nicht geeignet.

## 6. Architekturentscheidung

Für `GROUND_FUEL_PACKAGE` gilt:

```text
CampaignState = sole strategic fuel authority
preferred physical executor = one-shot MOOSE FUELSUPPLY
AUFTRAG:NewFUELSUPPLY(destinationZone)
-> BRIGADE:AddMission(mission)
-> normal MOOSE ReturnToLegion
```

Nicht für One-Shot-Transfers verwenden:

```text
BRIGADE:AddRefuellingZone(...)
```

Stage 1C `AUFTRAG:NewNOTHING` bleibt akzeptierte technische Evidenz für einen neutralen Meta-Resource-Bewegungspfad, ist aber nicht mehr der bevorzugte Fuel-Executor.

## 7. Grenzen

Nicht durch Stage 1B2 validiert:

```text
M978 package capacity authority
DCS-native fuel quantity as CampaignState authority
MOOSE Warehouse fuel as CampaignState authority
production-generic RESUPPLY executor
combat/loss handling specific to this fuel path
restart/replay handling specific to an in-flight fuel transfer
multiplayer/performance behavior beyond separately accepted contracts
```

## 8. Status

```text
stage: 1B2
status: ACCEPTED_TECHNICAL_BASELINE
validated_in_dcs: true
runtime_result: PASS
formal_acceptance: COMPLETE
executed_miz_sha256: 603422EFAFFA860041089D0F1AD41D35642A7863BC1C7B658E0B8F15A6EB63F2
bundle_sha256: 8CBDFA12B1A052517D82CB20A460CA665415353FE38ED2F1C50928BE6C7966A0
fuel_preferred_physical_executor: MOOSE_ONE_SHOT_FUELSUPPLY
```
