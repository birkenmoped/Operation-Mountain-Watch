---
document_id: OMW-GROUND-SUPPLY-RESUPPLY-NOTHING-ACCEPTANCE-1-PASS-1
status: ACCEPTED_TECHNICAL_BASELINE
document_class: ACCEPTANCE_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local accepted runtime evidence for Stage 1D-S Ground SUPPLY RESUPPLY via AUFTRAG NOTHING
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

# Stage 1D-S Ground SUPPLY RESUPPLY – Runtime PASS 1

## 1. Ergebnis

```text
TestId: GROUND-SUPPLY-RESUPPLY-NOTHING-ACCEPTANCE-1
BuilderVersion: GROUND-SUPPLY-RESUPPLY-NOTHING-ACCEPTANCE-1-2
Runtime result: PASS
Formal ACCEPTED_TECHNICAL_BASELINE: YES
```

Der DCS-Lauf erreichte den vollständigen Stage-1D-S-Lifecycle von Joyce nach Honaker, buchte `GROUND_SUPPLY_PACKAGE` exakt einmal in CampaignState und führte denselben `ARMYGROUP` anschließend über den expliziten MOOSE-RTZ-Pfad nach Joyce zurück.

## 2. Build-Provenienz

```text
Branch: agent/automatic-response-orchestration-continuation
Build Git HEAD: 4771420480a994ce7356abc618ae0a3189dc105e
BuilderVersion: GROUND-SUPPLY-RESUPPLY-NOTHING-ACCEPTANCE-1-2
GeneratedUtc: 2026-08-29T09:55:12Z
Bundle SHA-256: C805C996A2028629251F833F0E0D0ED06F462C15271A1166E0DB8DF0BA105CE3
Acceptance source SHA-256: E9C2CA3C5172A87459104A10045DB0AA5478947725AFE9BC9AB9150526F5D013
MissionDemand source SHA-256: E348E75B87135B99D780E07CA6B6FB7C3C530E048E9C6DE790328D147DE32848
ResourceDemandPolicy source SHA-256: BDC20ACEDAB60F662093077B8320220EBB71C6C641CC604C4356231B8405913C
GroundRoadSpawnAdapter SHA-256: 1A81FB2E5270C493373CF5BF6EC01F5AFED47004BF25C4225524121155D983E8
```

## 3. MOOSE-/DCS-/MIZ-Provenienz

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915

DCS: 2.9.29.27278 MT
Executed mission path from debrief: C:\Users\Sven\Saved Games\DCS.openbeta\Missions\OMW_Template_v20_GroundWorks.miz
Uploaded executed-mission copy SHA-256: BA556641A9ECAD629FDBE62AEA5CC30E22E081B81B4188C136855026F70D0907

Embedded Stage 1D-S bundle SHA-256: C805C996A2028629251F833F0E0D0ED06F462C15271A1166E0DB8DF0BA105CE3
Embedded Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
Trigger: triggerOnce
Trigger gates: OMW_WAREHOUSE_READY == 1; OMW_GROUND_READY == 1; c_time_after(30)
```

## 4. Log-Provenienz

```text
dcs(20260829-100257).log SHA-256: 8212FFF3181E3D394ACE916707055E8A5D7CD195AA7AB55B3E6C020CDACB4162
debrief(20260829-100257).log SHA-256: 87345A4D0595A082C2CA64693F02117A43529977C5EA82ABF9E4CB2A7479D763
```

Der bekannte externe Shutdown-Fehler

```text
bhHook.lua:168: attempt to index upvalue 'tcp' (a nil value)
```

trat erst nach dem terminalen PASS beim Beenden von DCS auf und gehört nicht zum Stage-1D-S-Bundle.

## 5. Runtime-Sequenz

```text
09:58:35 START
09:58:35 DEMAND_RESERVED
09:58:35 PHYSICAL_EXECUTION_READY
09:58:40 MISSION_QUEUED
09:59:36 ROAD_ALIGNED_WAREHOUSE_SPAWN
09:59:36 GROUP_MATERIALIZED
09:59:41 ARMY_ON_MISSION
10:01:13 DESTINATION_ZONE_ENTERED
10:01:19 MISSION_EXECUTE_OBSERVED
10:01:19 DELIVERY_CONFIRMED
10:01:20 MISSION_DONE
10:01:31 AUFTRAG success
10:01:32 RETURN_RTZ_ACTIVE
10:01:32 RETURN_RTZ_ISSUED
10:02:21 RETURNED_HANDOFF
10:02:23 WAREHOUSE_ADD_ASSET
10:02:23 PASS
```

Terminaler Marker:

```text
PASS originFinal=28 destinationFinal=40 transferQuantity=20 resource=GROUND_SUPPLY_PACKAGE template=TPL_BLUE_CONVOY_LIGHT_06 physicalMission=NOTHING demandStatus=SUCCESS spawnCount=1 missionExecuteCount=1 destinationObserved=true missionDoneCount=1 returnIssued=true returnedCount=1 warehouseAddAssetCount=1
```

## 6. Strategischer Nachweis

```text
JOYCE GROUND_SUPPLY_PACKAGE   48 -> 28
HONAKER GROUND_SUPPLY_PACKAGE 40 -> 20 -> 40
TransferQuantity: 20
MissionDemand: SUCCESS
```

Die physische Gruppe war `TPL_BLUE_CONVOY_LIGHT_06` mit sechs Fahrzeugen. Der RoadSpawnAdapter meldete die road-aligned Materialisierung, anschließend wurde genau ein `ARMY_ON_MISSION` für `AUFTRAG NOTHING` beobachtet.

## 7. Ankunft und Rückkehr

Die Zielzonenbeobachtung war diesmal eindeutig:

```text
DESTINATION_ZONE_ENTERED
MISSION_EXECUTE_OBSERVED destinationObserved=true inDestinationZone=true
DELIVERY_CONFIRMED
```

Nach `MISSION_DONE` wurde der bereits aus Stage 1C akzeptierte explizite Return-Vertrag verwendet:

```text
SetReturnToLegion(false)
-> MissionDone
-> 30 s delayed return issue
-> ARMYGROUP:RTZ(ZON_BLUE_GND_JOYCE_ACCESS, OnRoad)
-> Returned
-> Warehouse AddAsset
```

Die reale Rückfahrt wurde optisch durch den Projektinhaber beobachtet und durch die MOOSE-Events `RETURN_RTZ_ACTIVE`, `RETURN_RTZ_ISSUED`, `RETURNED_HANDOFF` und `WAREHOUSE_ADD_ASSET` bestätigt.

## 8. Regressionserkenntnis

Der unmittelbar vorherige Stage-1D-S-Detour war unnötig. Der erste SUPPLY-Harness hatte den bereits in Stage 1C bestandenen NOTHING-Return-Vertrag verändert und dadurch ein schon gelöstes Problem erneut geöffnet. Die erfolgreiche Korrektur bestand ausschließlich darin, den bewährten Stage-1C-Lifecycle wiederherzustellen und nur die fachlich erforderlichen SUPPLY-Daten zu ändern.

Nicht als Lösung eingeführt wurden:

```text
keine neue interne Zielzone
keine eigene Ground-Routinglogik
kein Native-DCS-Dispatcher
kein MIST
keine zweite Warehouse-Ressourcenautorität
```

Diese Regression ist für Folgearbeiten als Prozessfehler festzuhalten: Bei vorhandener `ACCEPTED_TECHNICAL_BASELINE` darf ein Nachfolgeharness den bewiesenen Lifecycle nicht ohne nachgewiesenen fachlichen Grund verändern.

## 9. Status und nächster Scope

```text
stage: 1D-S
status: ACCEPTED_TECHNICAL_BASELINE
validated_in_dcs: true
runtime_result: PASS
next_stage: 1D-P PERSONNEL source/design reconciliation
```

Stage 1D-P darf nicht automatisch denselben NOTHING-Executor übernehmen. `AUFTRAG:NewTROOPTRANSPORT(...)` ist zunächst gegen die reale PERSONNEL-Repräsentation und die CampaignState-Autoritätsgrenze zu reconciliieren.
