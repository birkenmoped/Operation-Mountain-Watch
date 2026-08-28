---
document_id: OMW-GROUND-AMMO-RESUPPLY-ACCEPTANCE-1-PASS-1
status: ACCEPTED_TECHNICAL_BASELINE
document_class: ACCEPTANCE_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - exact DCS runtime result of Stage-1A Ground AMMO RESUPPLY acceptance run 4 on 2026-08-22
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
acceptance_branch: agent/automatic-response-orchestration
acceptance_commit: 2d72bcdfc113342a2180b6cd9c84486da790052c
acceptance_mission: OMW_Template_v18.miz
acceptance_mission_sha256: 2fdf31a2e07409cf392d45bff5fc69750958c670ae3e12ff28d0b4fd8aecc90d
dcs_version: 2.9.28.26385 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
validated_in_dcs: true
---

# Ground AMMO RESUPPLY Acceptance 1 – Lauf 4 – PASS

## 1. Klassifikation

```text
Result: PASS
Stage 1A: ACCEPTED_TECHNICAL_BASELINE for the exact documented scope
```

Dieser Nachweis gilt ausschließlich für die unten dokumentierte Branch-/Source-/Bundle-/MIZ-/DCS-/MOOSE-Provenienz.

## 2. Provenienz

```text
TestId: GROUND-AMMO-RESUPPLY-ACCEPTANCE-1
Branch: agent/automatic-response-orchestration
Acceptance source/build commit: 2d72bcdfc113342a2180b6cd9c84486da790052c
BuilderVersion: GROUND-AMMO-RESUPPLY-ACCEPTANCE-1-5
Acceptance bundle SHA-256: 752B3E6F0B77D1B62C750421DDE36202C81B98632FEFBF6A273F913202DF8339
Acceptance source SHA-256: 794CA80C717586A796154F605074AC9AB61B27668B216C5A5A8718B772FD76F4
Builder SHA-256: A55103F0DF919365EF40DF4DB459E4E6AB96D858CF973D9F92B59BB48A75ACFD
MissionDemand source SHA-256: E348E75B87135B99D780E07CA6B6FB7C3C530E048E9C6DE790328D147DE32848
ResourceDemandPolicy source SHA-256: BDC20ACEDAB60F662093077B8320220EBB71C6C641CC604C4356231B8405913C
GroundRoadSpawnAdapter source SHA-256: 1A81FB2E5270C493373CF5BF6EC01F5AFED47004BF25C4225524121155D983E8
Ground production bundle SHA-256: E616D35F5EBDBDDD4275785091D47F57445348D1FF4BB4CFBE7DEE0F0B12D78E
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
DCS: 2.9.28.26385 MT
Executed mission path: C:\Users\Sven\Saved Games\DCS.openbeta\Missions\OMW_Template_v18.miz
MIZ SHA-256: 2FDF31A2E07409CF392D45BFF5FC69750958C670AE3E12FF28D0B4FD8AECC90D
internal mission SHA-256: 38B207278365CD977E74FF3C9000C6A7C5B13EEE3E5B1BB154F1775055D02AF6
dcs.log SHA-256: 0C0B5784A0AA1C67E0BE57CEEF90006FBEEE40805D7A589D8EF8DC6DC3BFDFDF
debrief.log SHA-256: C9EA7398241DEA3323B39FAD8F28D97D27B5A1CB1EE05A79433BA26896666DEB
```

## 3. Testvertrag

```text
Honaker AMMO 40
-> test-only consumption 20
-> one MissionDemand RESUPPLY
-> CampaignState TRANSFER 20 Joyce -> Honaker
-> TPL_BLUE_CONVOY_LIGHT_06
-> MOOSE BRIGADE / PLATOON / ARMYGROUP
-> AUFTRAG:NewAMMOSUPPLY
-> destination-zone proof
-> CampaignState DELIVERED
-> MissionDemand SUCCESS
-> MissionDone
-> 30 s settlement window
-> same ARMYGROUP RTZ Joyce ACCESS / OnRoad
-> Returned
-> Warehouse AddAsset
-> physical cleanup
```

## 4. Reale Runtime-Marker

```text
DELIVERY_CONFIRMED ... quantity=20 ... campaignStateStatus=DELIVERED demandStatus=SUCCESS
MISSION_DONE deliveryCommitted=true returnIssueDelaySec=30
AUFTRAG ... Mission 3 [Ammo Supply] success!
RETURN_RTZ_ACTIVE
RETURN_RTZ_ISSUED ... zone=ZON_BLUE_GND_JOYCE_ACCESS formation=OnRoad
RETURNED_HANDOFF
WAREHOUSE_ADD_ASSET
PASS originFinal=24 destinationFinal=40 transferQuantity=20 template=TPL_BLUE_CONVOY_LIGHT_06 demandStatus=SUCCESS spawnCount=1 returnedCount=1 warehouseAddAssetCount=1
```

## 5. Scope-Grenzen

Nicht validiert sind insbesondere generische package-per-truck-Kapazität, automatische Convoy-Klassenwahl, FUEL-/Generic-SUPPLY, parallele Demands, Convoy-under-attack-Reaktionen, Loss/Abort, externer Server-Restart, CAS und CSAR.
