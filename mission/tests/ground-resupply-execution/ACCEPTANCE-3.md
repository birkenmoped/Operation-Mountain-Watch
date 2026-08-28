---
document_id: OMW-GROUND-META-RESUPPLY-NOTHING-ACCEPTANCE-1
status: ACCEPTED_TECHNICAL_BASELINE
document_class: ACCEPTANCE_PLAN_AND_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local accepted technical baseline for MissionDemand-driven Ground meta-resource RESUPPLY via AUFTRAG NOTHING
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
acceptance_branch: agent/automatic-response-orchestration
acceptance_commit: 8803505edf07120bc6d1673b41f69067e8db0211
acceptance_mission: OMW_Template_v19.miz
acceptance_mission_sha256: d788af36535d3acd1866d15ffb5d354b2c44b5f8ee40d4baf6fd1d97b7c0f8a5
dcs_version: 2.9.28.26385 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
validated_in_dcs: true
---

# Ground Meta RESUPPLY Acceptance 1 – AUFTRAG NOTHING

## 1. Ergebnis

```text
status: ACCEPTED_TECHNICAL_BASELINE
runtime_result: PASS
```

Belegter Lifecycle:

```text
HONAKER FUEL 36
-> test-only consumption 18
-> MissionDemand RESUPPLY
-> CampaignState TRANSFER 18 Joyce -> Honaker
-> TPL_BLUE_CONVOY_FUEL_LIGHT_06
-> BRIGADE / PLATOON / ARMYGROUP
-> AUFTRAG:NewNOTHING(Honaker ACCESS)
-> OnRoad 27 kt
-> destination-zone proof
-> CampaignState DELIVERED
-> MissionDemand SUCCESS
-> MissionDone
-> delayed RTZ Joyce ACCESS / OnRoad
-> Returned
-> Warehouse AddAsset
-> physical cleanup
-> PASS
```

Strategischer Endzustand:

```text
JOYCE FUEL   40 -> 22
HONAKER FUEL 36 -> 18 -> 36
```

## 2. Architekturgrenze

```text
CampaignState = alleinige strategische Ressourcenautorität
MissionDemand = Demand-/Assignment-Zustand
AUFTRAG NOTHING = neutrale physische Bewegung / Aufenthalt
DCS group = temporäre physische Repräsentation
```

Der physische Fuel-Light-Convoy definiert keine strategische Fuel- oder Cargo-Kapazität.

## 3. MOOSE-Vertrag

```text
PLATOON:AddMissionCapability(AUFTRAG.Type.NOTHING, 100)
AUFTRAG:NewNOTHING(destinationZone)
AUFTRAG:SetMissionSpeed(27)
AUFTRAG:SetFormation(ENUMS.Formation.Vehicle.OnRoad)
AUFTRAG:SetReturnToLegion(false)
BRIGADE:AddMission(...)
ARMYGROUP:RTZ(originZone, ENUMS.Formation.Vehicle.OnRoad)
```

Die owner-approved `OMW_GroundRoadSpawnAdapter`-Ausnahme wird unverändert für road-aligned Materialisierung wiederverwendet.

## 4. Build-Provenienz

```text
Branch: agent/automatic-response-orchestration
Git HEAD: 8803505edf07120bc6d1673b41f69067e8db0211
BuilderVersion: GROUND-META-RESUPPLY-NOTHING-ACCEPTANCE-1-4
GeneratedUtc: 2026-08-23T15:24:27Z
Bundle SHA-256: C881C82C3F699914E18FFE64DE73E650E20AF82B55B3F486154C40059F44CB65
Builder SHA-256: 9F7E3DFAE967BA39C373190A11495EC5AFD39357B0C1001A12F952606816B636
Acceptance source SHA-256: 21A54365C6138425CF5CDF4965F9E6F3396889477708B37A23BCBCFD77897C0C
GroundRoadSpawnAdapter SHA-256: 1A81FB2E5270C493373CF5BF6EC01F5AFED47004BF25C4225524121155D983E8
MissionDemand source SHA-256: E348E75B87135B99D780E07CA6B6FB7C3C530E048E9C6DE790328D147DE32848
ResourceDemandPolicy source SHA-256: BDC20ACEDAB60F662093077B8320220EBB71C6C641CC604C4356231B8405913C
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Keine harten Outbound-/Return-Travel-Timeouts gehören zum akzeptierten Build 1-4.

## 5. DCS-PASS-Provenienz

```text
DCS: 2.9.28.26385 MT
Executed mission: OMW_Template_v19.miz
Executed MIZ SHA-256: D788AF36535D3ACD1866D15FFB5D354B2C44B5F8EE40D4BAF6FD1D97B7C0F8A5
dcs.log SHA-256: 7F89D79C10C8C61BB7994CE762C2554124212501FC019E83F5A34C87C54A67DD
debrief.log SHA-256: 21D917BC43A00F429A22B1EE697E64A62EC9B487254D330F5A7B1F574A253FA2
```

Beobachteter Lifecycle:

```text
START
DEMAND_RESERVED
ROAD_ALIGNED_WAREHOUSE_SPAWN
GROUP_MATERIALIZED
ARMY_ON_MISSION
DESTINATION_ZONE_ENTERED
DELIVERY_CONFIRMED
MISSION_DONE
AUFTRAG success
RETURN_RTZ_ACTIVE
RETURN_RTZ_ISSUED
RETURNED_HANDOFF
WAREHOUSE_ADD_ASSET
PASS
```

Detailresultat:

```text
results/2026-08-23-ground-meta-resupply-nothing-acceptance-1-pass-1.md
```

## 6. Architekturresultat

`AUFTRAG:NewNOTHING(...)` ist für den exakt getesteten neutralen Meta-Ressourcen-Roundtrip technisch bestätigt. Daraus folgt keine generische Produktionsfreigabe für jede Ressourcenklasse.

Nach Stage 1B2 ist für `GROUND_FUEL_PACKAGE` der spezialisierte One-Shot-FUELSUPPLY-Pfad bevorzugt. Stage 1C bleibt technische Evidenz für neutrale Meta-Ressourcenbewegung.
