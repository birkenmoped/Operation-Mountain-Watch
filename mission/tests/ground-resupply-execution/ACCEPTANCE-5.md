---
document_id: OMW-GROUND-SUPPLY-RESUPPLY-NOTHING-ACCEPTANCE-1
status: ACCEPTED_TECHNICAL_BASELINE
document_class: ACCEPTANCE_PLAN_AND_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Stage 1D-S Ground SUPPLY RESUPPLY acceptance via AUFTRAG NOTHING
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/automatic-response-orchestration-continuation
source_commit: 4771420480a994ce7356abc618ae0a3189dc105e
validated_in_dcs: true
acceptance_branch: agent/automatic-response-orchestration-continuation
acceptance_commit: 4771420480a994ce7356abc618ae0a3189dc105e
acceptance_mission: OMW_Template_v20_GroundWorks.miz
acceptance_mission_sha256: ba556641a9ecad629fdbe62aea5cc30e22e081b81b4188c136855026f70d0907
dcs_version: 2.9.29.27278 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
---

# Stage 1D-S – Ground SUPPLY RESUPPLY via AUFTRAG NOTHING

## 1. Ergebnis

Stage 1D-S ist für die unten exakt dokumentierte Provenienz technisch akzeptiert.

```text
CampaignState SUPPLY shortage
-> MissionDemand RESUPPLY
-> CampaignState TRANSFER Joyce -> Honaker
-> MOOSE BRIGADE / PLATOON / ARMYGROUP
-> AUFTRAG:NewNOTHING(Honaker ACCESS)
-> OnRoad 27 kt
-> destination-zone proof
-> exact-once CampaignState delivery
-> MissionDemand SUCCESS
-> mission cancel / MissionDone
-> delayed explicit ARMYGROUP:RTZ(Joyce ACCESS, OnRoad)
-> physical return
-> Returned
-> Warehouse AddAsset
-> physical cleanup
-> PASS
```

CampaignState bleibt alleinige strategische Ressourcenautorität. Weder DCS Warehouse noch MOOSE Warehouse erhalten eine strategische SUPPLY-Mengenhoheit.

## 2. Akzeptierte Provenienz

```text
TestId: GROUND-SUPPLY-RESUPPLY-NOTHING-ACCEPTANCE-1
Branch: agent/automatic-response-orchestration-continuation
Build Git HEAD: 4771420480a994ce7356abc618ae0a3189dc105e
BuilderVersion: GROUND-SUPPLY-RESUPPLY-NOTHING-ACCEPTANCE-1-2
GeneratedUtc: 2026-08-29T09:55:12Z
Bundle SHA-256: C805C996A2028629251F833F0E0D0ED06F462C15271A1166E0DB8DF0BA105CE3
Acceptance source SHA-256: E9C2CA3C5172A87459104A10045DB0AA5478947725AFE9BC9AB9150526F5D013
OMW_MissionDemand.lua SHA-256: E348E75B87135B99D780E07CA6B6FB7C3C530E048E9C6DE790328D147DE32848
OMW_ResourceDemandPolicy.lua SHA-256: BDC20ACEDAB60F662093077B8320220EBB71C6C641CC604C4356231B8405913C
OMW_GroundRoadSpawnAdapter.lua SHA-256: 1A81FB2E5270C493373CF5BF6EC01F5AFED47004BF25C4225524121155D983E8

DCS: 2.9.29.27278 MT
Mission: OMW_Template_v20_GroundWorks.miz
Uploaded executed-mission copy SHA-256: BA556641A9ECAD629FDBE62AEA5CC30E22E081B81B4188C136855026F70D0907
dcs.log SHA-256: 8212FFF3181E3D394ACE916707055E8A5D7CD195AA7AB55B3E6C020CDACB4162
debrief.log SHA-256: 87345A4D0595A082C2CA64693F02117A43529977C5EA82ABF9E4CB2A7479D763

MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Die hochgeladene Mission enthält exakt den akzeptierten Stage-1D-S-Bundle-Hash sowie den gepinnten Moose.lua-Hash. Der Acceptance-Trigger ist `triggerOnce` mit `OMW_WAREHOUSE_READY == 1`, `OMW_GROUND_READY == 1` und `c_time_after(30)`.

## 3. Strategischer Testvertrag

```text
RESOURCE: GROUND_SUPPLY_PACKAGE
RESOURCE_CLASS: GROUND_SUPPLY
UNIT: count

JOYCE   48 -> 28
HONAKER 40 -> 20 -> 40
TransferQuantity: 20
Template: TPL_BLUE_CONVOY_LIGHT_06
PhysicalMission: AUFTRAG NOTHING
```

Nicht aus diesem Test abzuleiten:

```text
1 physical truck = X GROUND_SUPPLY_PACKAGE
DCS cargo capacity = CampaignState SUPPLY quantity
MOOSE Warehouse cargo = CampaignState SUPPLY authority
```

## 4. Beobachteter Runtime-Lifecycle

Der reale DCS-Lauf bestätigte chronologisch:

```text
START
DEMAND_RESERVED
PHYSICAL_EXECUTION_READY
MISSION_QUEUED
ROAD_ALIGNED_WAREHOUSE_SPAWN
GROUP_MATERIALIZED
ARMY_ON_MISSION
DESTINATION_ZONE_ENTERED
MISSION_EXECUTE_OBSERVED
DELIVERY_CONFIRMED
MISSION_DONE
AUFTRAG success
RETURN_RTZ_ACTIVE
RETURN_RTZ_ISSUED
RETURNED_HANDOFF
WAREHOUSE_ADD_ASSET
PASS
```

Terminaler Marker:

```text
PASS originFinal=28 destinationFinal=40 transferQuantity=20 resource=GROUND_SUPPLY_PACKAGE template=TPL_BLUE_CONVOY_LIGHT_06 physicalMission=NOTHING demandStatus=SUCCESS spawnCount=1 missionExecuteCount=1 destinationObserved=true missionDoneCount=1 returnIssued=true returnedCount=1 warehouseAddAssetCount=1
```

Damit sind für diesen Scope bestätigt:

```text
exactly one physical convoy
correct CampaignState source/destination mutation
arrival observed before settlement
exact-once delivery settlement
MissionDemand SUCCESS
no second strategic Warehouse authority
explicit MOOSE ARMYGROUP RTZ return
Returned -> Warehouse AddAsset
physical cleanup
no spontaneous second mission before terminal PASS
```

## 5. Zeitverhalten

Der akzeptierte Build enthält keine harten Outbound- oder Return-Reisezeitlimits:

```text
OutboundTravelTimeoutSec: none
DestinationCheckIntervalSec: 15
DestinationExecutionGraceSec: 90 after destination-zone observation only
ReturnIssueDelaySec: 30
ReturnTravelTimeoutSec: none
ReturnSettlementDelaySec: 12
```

`DestinationExecutionGraceSec` ist keine Fahrzeitgrenze. Sie beginnt erst nach tatsächlicher Zielzonenbeobachtung. Die reale Hin- und Rückfahrt darf beliebig lange dauern.

## 6. Regression und korrigierter Fehlpfad

Der erste Stage-1D-S-Build wich unnötig vom bereits akzeptierten Stage-1C-NOTHING-Lifecycle ab. Er entfernte unter anderem den expliziten `SetReturnToLegion(false)`-/`ARMYGROUP:RTZ(...)`-Vertrag und übernahm stattdessen Teile des späteren FUELSUPPLY-Harness. Im DCS-Lauf blieb der Convoy dadurch am Ziel stehen, weil die Stage-1D-S-Gating-/Return-Kombination den bereits bewiesenen NOTHING-Rückkehrpfad nicht reproduzierte.

Die Korrektur in Build `GROUND-SUPPLY-RESUPPLY-NOTHING-ACCEPTANCE-1-2` bestand ausdrücklich nicht aus einer neuen Zielzone oder eigener Routinglogik. Stattdessen wurde der bereits akzeptierte Stage-1C-Vertrag wiederhergestellt:

```text
AUFTRAG:NewNOTHING(destinationZone)
SetMissionSpeed(27)
SetFormation(OnRoad)
SetReturnToLegion(false)
BRIGADE:AddMission(...)
destination-zone proof
exact-once delivery
mission cancel
MissionDone
30 s delay
ARMYGROUP:RTZ(originZone, OnRoad)
Returned
Warehouse AddAsset
```

Diese Regression war vermeidbar. Für Folgearbeiten gilt deshalb: bestehende `ACCEPTED_TECHNICAL_BASELINE` zuerst als unveränderte technische Referenz übernehmen und nur die fachlich zwingenden Delta-Punkte ändern.

## 7. Architekturresultat

Für normalisierte Ground-`SUPPLY`-Einheiten ist damit im exakt getesteten Scope technisch bestätigt:

```text
CampaignState SUPPLY
-> MissionDemand RESUPPLY
-> neutraler physischer MOOSE AUFTRAG NOTHING
-> destination-zone evidence
-> CampaignState settlement
-> expliziter MOOSE RTZ lifecycle
```

Dies ist keine generische Freigabe für `PERSONNEL` oder `VEHICLE`. Stage 1D-P und Stage 1D-V bleiben getrennte Design-/Source-Reconciliation-Schritte.

## 8. Status

```text
stage: 1D-S
status: ACCEPTED_TECHNICAL_BASELINE
validated_in_dcs: true
runtime_result: PASS
bundle_sha256: C805C996A2028629251F833F0E0D0ED06F462C15271A1166E0DB8DF0BA105CE3
mission_sha256: BA556641A9ECAD629FDBE62AEA5CC30E22E081B81B4188C136855026F70D0907
next_stage: 1D-P PERSONNEL source/design reconciliation
```
