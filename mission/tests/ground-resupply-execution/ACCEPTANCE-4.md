---
document_id: OMW-GROUND-FUEL-REFUELLING-ZONE-ACCEPTANCE-2
status: PLANNED
document_class: ACCEPTANCE_PLAN_AND_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Stage 1B2 MOOSE-native Ground FUELSUPPLY acceptance plan and result history
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
validated_in_dcs: true
---

# Stage 1B2 – MOOSE-native Ground FUELSUPPLY Acceptance

## 1. Ziel

Vor Stage 1D wird geprüft, ob `GROUND_FUEL_PACKAGE` physisch mit dem spezialisierten MOOSE-Executor `FUELSUPPLY` ausgeführt werden kann, während `CampaignState` alleinige strategische Ressourcenautorität bleibt.

```text
CampaignState
-> MissionDemand RESUPPLY
-> CampaignState TRANSFER Joyce -> Honaker
-> MOOSE BRIGADE / PLATOON / ARMYGROUP
-> FUELSUPPLY physical execution
-> independent destination-zone proof
-> exact-once CampaignState delivery
-> MOOSE ReturnToLegion
-> Returned -> Warehouse AddAsset
```

Keine harte Outbound- oder Return-Fahrzeitbegrenzung ist zulässig.

## 2. MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Der gepinnte Source bestätigt sowohl `BRIGADE:AddRefuellingZone(Zone)` als auch `AUFTRAG:NewFUELSUPPLY(Zone)`.

Wesentliche Semantik:

```text
BRIGADE:AddRefuellingZone
= persistente Service-Registrierung
= BRIGADE erzeugt erneut FUELSUPPLY, wenn die vorherige Mission over ist

AUFTRAG:NewFUELSUPPLY
= einzelner FUELSUPPLY-Auftrag
= kann einer BRIGADE direkt per AddMission übergeben werden
```

## 3. Strategischer Testvertrag

```text
JOYCE GROUND_FUEL_PACKAGE   40 -> 22
HONAKER GROUND_FUEL_PACKAGE 36 -> 18 -> 36
TransferQuantity: 18
Template: TPL_BLUE_CONVOY_FUEL_LIGHT_06
Physical tankers: 2 x M978 HEMTT Tanker
```

Nicht definiert werden:

```text
1 M978 = X GROUND_FUEL_PACKAGE
DCS fuel quantity = CampaignState quantity
MOOSE Warehouse fuel = CampaignState fuel
```

## 4. Historie Build 2-1

```text
BuilderVersion: GROUND-FUEL-REFUELLING-ZONE-ACCEPTANCE-2-1
Build commit: cab06376b92fd185ca37c26bceb211f77f514366
Bundle SHA-256: B032595AC96CEBB00233A06F3747598F82C3295882B641EF2391965851542417
Result: HARNESS_LOGIC_ERROR / INCONCLUSIVE
```

Fehlerursache: `OnAfterMissionExecute` verlangte synchron `IsInZone(destinationZone) == true`. Dies wich unnötig von der bereits bewährten Stage-1C-Zielerkennung ab.

## 5. Build 2-2 – korrigierte Zielerkennung

Reale lokale Build-Evidenz:

```text
Build commit: a253d2c05f0cce94b25c0d79eb5602d64523bdce
BuilderVersion: GROUND-FUEL-REFUELLING-ZONE-ACCEPTANCE-2-2
GeneratedUtc: 2026-08-23T22:10:27Z
Bundle SHA-256: 351493A40AF9F2FCB4574C2DFEF7D2704B603A804C43AB1A1CBB3651E18DB0AD
Builder SHA-256: 3B874528B17027A0BFE16C16D7CCA1BBF44F88D0990D141EB7E5045CBE6FE537
Acceptance source SHA-256: 7E7E821A58E7DD55243CC763853739E81517E52CF8D915F63A229FC5A1D8A05A
Local build: PASS
```

Harness-Vertrag:

```text
MissionExecute observed
AND
destination zone observed
-> exact-once delivery settlement
```

Die Reihenfolge beider Beobachtungen ist nicht fest verdrahtet.

## 6. DCS-Lauf Build 2-2 – persistente RefuellingZone nicht für One-Shot geeignet

Testumgebung aus realem Lauf:

```text
DCS: 2.9.28.26385 MT
Mission: OMW_Template_v19.miz
MOOSE: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
Bundle SHA-256: 351493A40AF9F2FCB4574C2DFEF7D2704B603A804C43AB1A1CBB3651E18DB0AD
```

Beobachtete Sequenz:

```text
GROUP_MATERIALIZED
-> ARMY_ON_MISSION FUELSUPPLY
-> DESTINATION_ZONE_ENTERED
-> MISSION_EXECUTE_OBSERVED
-> DELIVERY_CONFIRMED
-> MISSION_DONE
-> BRIGADE erzeugt wegen persistenter RefuellingZone einen neuen FUELSUPPLY
-> FAIL MULTIPLE_FUELSUPPLY_MISSIONS_ASSIGNED
```

Der Lauf belegt damit:

```text
FUELSUPPLY dispatch: PASS
road-aligned materialization: PASS
physical movement to Honaker: PASS
destination-zone proof: PASS
MissionExecute: PASS
CampaignState exact-once delivery: PASS
MissionDemand SUCCESS: PASS

BRIGADE:AddRefuellingZone as one-shot strategic transfer dispatcher: NOT SUITABLE
Return-to-Legion completion: NOT PROVEN IN THIS RUN
```

Klassifikation:

```text
FUELSUPPLY_EXECUTION_OBSERVED
PERSISTENT_REFUELLING_ZONE_LIFECYCLE_MISMATCH
INCONCLUSIVE_FOR_COMPLETE_ONE_SHOT_FUELSUPPLY_RETURN_PATH
```

Dies ist kein Beleg gegen `FUELSUPPLY` selbst. Der MOOSE-Source erklärt das beobachtete Verhalten: registrierte Refuelling Zones erzeugen erneut eine FUELSUPPLY-Mission, wenn die vorherige Mission over ist.

## 7. Build 2-3 – kleinste MOOSE-first Korrektur

Der Test änderte ausschließlich die Missions-Erzeugung:

```text
ENTFERNT:
BRIGADE:AddRefuellingZone(destinationZone)

NEU:
AUFTRAG:NewFUELSUPPLY(destinationZone)
-> SetMissionSpeed(27 kt)
-> SetFormation(OnRoad)
-> BRIGADE:AddMission(mission)
```

Unverändert blieben:

```text
CampaignState / MissionDemand / transfer reservation
TPL_BLUE_CONVOY_FUEL_LIGHT_06
OMW_GroundRoadSpawnAdapter
Stage-1C-style destination polling
MissionExecute observation
exact-once delivery settlement
no hard travel timeout
no explicit OMW RTZ
normal MOOSE ReturnToLegion
Returned -> Warehouse AddAsset verification
```

Reale lokale Build-Evidenz für Build `2-3`:

```text
Git HEAD: 2bd930729ed12a073f5364dc139281b60151acf0
GeneratedUtc: 2026-08-23T23:08:54Z
BuilderVersion: GROUND-FUEL-REFUELLING-ZONE-ACCEPTANCE-2-3
TestId: GROUND-FUEL-REFUELLING-ZONE-ACCEPTANCE-2
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
MissionCreation: AUFTRAG:NewFUELSUPPLY -> BRIGADE:AddMission
PersistentRefuellingZone: false
DestinationProof: Stage-1C-style independent zone polling plus observed MissionExecute
DestinationCheckIntervalSec: 15
DestinationExecutionGraceSec: 90
ReturnMode: MOOSE ReturnToLegion
HardOutboundTravelTimeout: false
HardReturnTravelTimeout: false
ReturnSettlementDelaySec: 12
OPSTRANSPORT: false
MizMutation: false
Bundle SHA-256: 8CBDFA12B1A052517D82CB20A460CA665415353FE38ED2F1C50928BE6C7966A0
Builder SHA-256: BD5C8657B759A8915F471AC54B56C375DCC7865B745EA208AC7B3DF822B6A023
Acceptance source SHA-256: 8FAD1F29E2054C5CE621549AA167BFF2A6DE45EE7C39EAEDF57AD3E234029287
OMW_MissionDemand.lua SHA-256: E348E75B87135B99D780E07CA6B6FB7C3C530E048E9C6DE790328D147DE32848
OMW_ResourceDemandPolicy.lua SHA-256: BDC20ACEDAB60F662093077B8320220EBB71C6C641CC604C4356231B8405913C
OMW_GroundRoadSpawnAdapter.lua SHA-256: 1A81FB2E5270C493373CF5BF6EC01F5AFED47004BF25C4225524121155D983E8
Local build: PASS
```

## 8. DCS-Lauf Build 2-3 – One-Shot FUELSUPPLY erfolgreich

Der Projektinhaber führte den exakt oben bezeichneten Build 2-3 in DCS aus. Der Lauf bestätigte den vollständigen One-Shot-Lifecycle ohne erneute FUELSUPPLY-Erzeugung.

Runtime-Umgebung:

```text
DCS: 2.9.28.26385 MT
Mission name: OMW_Template_v19.miz
Bundle SHA-256: 8CBDFA12B1A052517D82CB20A460CA665415353FE38ED2F1C50928BE6C7966A0
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
Executed MIZ SHA-256: PENDING_OWNER_EVIDENCE
```

Beobachtete Sequenz:

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

Beobachteter terminaler Zustand:

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

Damit ist runtime-seitig für diesen Lauf belegt:

```text
one-shot AUFTRAG:NewFUELSUPPLY dispatch: PASS
BRIGADE:AddMission assignment: PASS
road-aligned materialization: PASS
physical movement to Honaker: PASS
destination-zone proof: PASS
MissionExecute: PASS
CampaignState exact-once delivery: PASS
MissionDemand SUCCESS: PASS
normal MOOSE ReturnToLegion: PASS
Returned handoff: PASS
Warehouse AddAsset: PASS
no replacement FUELSUPPLY mission: PASS
```

### 8.1 Formale Provenienzgrenze

Der Runtime-PASS darf nicht mit dem Stage-1C-MIZ-Hash oder einem später gespeicherten Missionsstand ergänzt werden. Für `ACCEPTED_TECHNICAL_BASELINE` fehlt noch der reale SHA-256 der **exakt im Build-2-3-Lauf ausgeführten und gespeicherten MIZ**.

Bis dieser Hash vom Projektinhaber zurückgeliefert ist, gilt:

```text
runtime_result: PASS
validated_in_dcs: true
formal_acceptance: BLOCKED_BY_MISSING_EXECUTED_MIZ_SHA256
```

## 9. Architekturentscheidung nach Build 2-3

Die vorher definierte owner-approved Entscheidungsregel ist durch den Runtime-PASS erfüllt.

Für Fuel gilt damit als Ziel für die Produktionsreconciliation:

```text
GROUND_FUEL_PACKAGE
-> CampaignState remains sole strategic resource authority
-> preferred physical executor = one-shot MOOSE FUELSUPPLY
-> AUFTRAG:NewFUELSUPPLY(destinationZone)
-> BRIGADE:AddMission(mission)
-> no persistent BRIGADE:AddRefuellingZone for one-shot strategic transfers
-> normal MOOSE ReturnToLegion
```

Stage 1C `AUFTRAG:NewNOTHING` bleibt akzeptierte technische Evidenz für einen neutralen Meta-Resource-Bewegungspfad, ist aber nicht mehr der bevorzugte Fuel-Executor.

Nicht aus diesem Test abzuleiten:

```text
M978 package capacity authority
DCS native fuel quantity as CampaignState authority
MOOSE Warehouse fuel as CampaignState authority
production-generic RESUPPLY executor already complete
combat/loss/restart behavior beyond separately accepted contracts
```

## 10. Aktueller Status

```text
previous_build_2_1: HARNESS_LOGIC_ERROR / INCONCLUSIVE
previous_build_2_2: PERSISTENT_REFUELLING_ZONE_LIFECYCLE_MISMATCH
current_build_commit: 2bd930729ed12a073f5364dc139281b60151acf0
current_builder: GROUND-FUEL-REFUELLING-ZONE-ACCEPTANCE-2-3
current_execution_model: ONE_SHOT_AUFTRAG_NEW_FUELSUPPLY
current_bundle_sha256: 8CBDFA12B1A052517D82CB20A460CA665415353FE38ED2F1C50928BE6C7966A0
local_build_2_3: PASS
validated_in_dcs: true
runtime_result: PASS
formal_acceptance: BLOCKED_BY_MISSING_EXECUTED_MIZ_SHA256
fuel_preferred_physical_executor: MOOSE_ONE_SHOT_FUELSUPPLY
```
