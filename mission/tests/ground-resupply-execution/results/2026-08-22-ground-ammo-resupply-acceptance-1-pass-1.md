---
document_id: OMW-GROUND-AMMO-RESUPPLY-ACCEPTANCE-1-PASS-1
status: ACCEPTED_TECHNICAL_BASELINE
document_class: ACCEPTANCE_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - exact DCS runtime result of Stage-1A Ground AMMO RESUPPLY acceptance run 4 on 2026-08-22
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
validated_in_dcs: true
---

# Ground AMMO RESUPPLY Acceptance 1 – Lauf 4 – PASS

## 1. Klassifikation

```text
Result: PASS
Stage 1A: ACCEPTED_TECHNICAL_BASELINE for the exact documented scope
```

Dieser Nachweis gilt ausschließlich für die unten dokumentierte Branch-/Source-/Bundle-/MIZ-/DCS-/MOOSE-Provenienz. Er ist keine allgemeine Freigabe für andere Ressourcenarten, Convoy-Klassen, MOOSE-Versionen oder Produktionsorchestrierung.

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
Uploaded mission artifact: OMW_Template_v18(1).miz
MIZ SHA-256: 2FDF31A2E07409CF392D45BFF5FC69750958C670AE3E12FF28D0B4FD8AECC90D
internal mission SHA-256: 38B207278365CD977E74FF3C9000C6A7C5B13EEE3E5B1BB154F1775055D02AF6
dcs.log SHA-256: 0C0B5784A0AA1C67E0BE57CEEF90006FBEEE40805D7A589D8EF8DC6DC3BFDFDF
debrief.log SHA-256: C9EA7398241DEA3323B39FAD8F28D97D27B5A1CB1EE05A79433BA26896666DEB
```

Die hochgeladene Mission wurde nur read-only geprüft; ChatGPT hat keine `.miz` verändert.

## 3. Testvertrag

```text
Honaker AMMO 40
-> test-only consumption 20
-> ResourceDemandPolicy REORDER
-> one RESUPPLY MissionDemand
-> CampaignState TRANSFER 20 Joyce -> Honaker
-> TPL_BLUE_CONVOY_LIGHT_06
-> MOOSE BRIGADE / PLATOON / ARMYGROUP
-> AUFTRAG:NewAMMOSUPPLY(destinationZone)
-> OnRoad 27 kt
-> destination-zone proof
-> CampaignState DELIVERED
-> MissionDemand SUCCESS
-> MissionDone
-> 30 s settlement window
-> same ARMYGROUP RTZ Joyce ACCESS / OnRoad
-> Returned
-> MOOSE LEGION/Warehouse AddAsset
-> physical cleanup
```

CampaignState bleibt alleinige strategische Ressourcen- und Cargo-Autorität. Die physische Convoy-Gruppe definiert keine package-per-truck-Kapazität.

## 4. Reale Runtime-Marker

```text
18:34:20.456 DELIVERY_CONFIRMED ... destination=GROUND_NODE_HONAKER quantity=20 campaignStateStatus=DELIVERED demandStatus=SUCCESS
18:34:21.457 MISSION_DONE deliveryCommitted=true returnIssueDelaySec=30
18:34:30.913 AUFTRAG ... Mission 3 [Ammo Supply] success!
18:34:51.463 RETURN_RTZ_ACTIVE
18:34:51.463 RETURN_RTZ_ISSUED ... zone=ZON_BLUE_GND_JOYCE_ACCESS formation=OnRoad
18:36:23.101 RETURNED_HANDOFF
18:36:33.109 WAREHOUSE_ADD_ASSET
18:36:35.110 PASS originFinal=24 destinationFinal=40 transferQuantity=20 template=TPL_BLUE_CONVOY_LIGHT_06 demandStatus=SUCCESS spawnCount=1 returnedCount=1 warehouseAddAssetCount=1
```

Damit liegt die AUFTRAG-Abschlussauswertung vor dem RTZ-Aufruf innerhalb des 30-s-Settlement-Fensters. Der zuvor reproduzierte 2-s-Race-Pfad trat nicht erneut auf.

## 5. Akzeptierte Aussagen

```text
ResourceDemand candidate: PASS
MissionDemand reservation/AI assignment: PASS
CampaignState TRANSFER reservation: PASS
CampaignState MarkLoading: PASS
CampaignState MarkInTransit / origin debit: PASS
protected LIGHT_06 materialization: PASS
six-vehicle road-aligned spawn: PASS
AUFTRAG AMMOSUPPLY outbound execution: PASS
Honaker destination-zone proof: PASS
CampaignState MarkDelivered / destination credit: PASS
MissionDemand SUCCESS: PASS
30-s post-MissionDone settlement window: PASS
same physical ARMYGROUP RTZ: PASS
physical return to Joyce: PASS
Returned callback: PASS
Warehouse AddAsset: PASS
physical retirement after warehouse handoff: PASS
final strategic stocks Joyce 24 / Honaker 40: PASS
```

Owner visual observation: Convoy speed at the configured 27 kt was visually acceptable. This observation does not define a generic production speed policy for other convoy classes.

## 6. Nicht durch diesen PASS validiert

```text
package-per-truck capacity
automatic LIGHT_06 / STANDARD_07 selection
STANDARD_07 runtime
FUEL RESUPPLY
generic GROUND_SUPPLY_PACKAGE execution
multiple simultaneous resupply demands
convoy attack / support reaction
carrier losses during transfer
abort/recovery paths
external process/server restart persistence
production orchestration scheduler
CAS / BLUE COMMANDER
CSAR
```

## 7. Ergebnis

```text
Stage 1A Ground AMMO Joyce -> Honaker:
ACCEPTED_TECHNICAL_BASELINE

MOOSE-first physical path:
BRIGADE -> PLATOON -> ARMYGROUP -> AUFTRAG AMMOSUPPLY -> RTZ -> Returned -> Warehouse AddAsset

CampaignState strategic transfer:
PASS for the exact documented transaction and mission scope
```
