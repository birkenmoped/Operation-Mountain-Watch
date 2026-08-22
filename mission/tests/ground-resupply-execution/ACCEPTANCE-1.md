---
document_id: OMW-GROUND-AMMO-RESUPPLY-ACCEPTANCE-1
status: ACCEPTED_TECHNICAL_BASELINE
document_class: ACCEPTANCE_PLAN_AND_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local DCS acceptance baseline for the first MissionDemand-driven physical Ground AMMO RESUPPLY vertical slice
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
validated_in_dcs: true
---

# Ground AMMO RESUPPLY Acceptance 1 – Joyce nach Honaker

## 1. Ziel und Ergebnis

```text
Honaker AMMO 40
-> test-only consumption 20
-> Honaker AMMO 20
-> ResourceDemandPolicy = REORDER
-> one RESUPPLY MissionDemand
-> CampaignState TRANSFER Joyce -> Honaker / 20
-> protected TPL_BLUE_CONVOY_LIGHT_06
-> MOOSE AUFTRAG AMMOSUPPLY
-> physical arrival in Honaker ACCESS zone
-> CampaignState DELIVERED
-> Honaker AMMO 40
-> MissionDemand SUCCESS
-> 30 s post-MissionDone settlement window
-> same ARMYGROUP RTZ Joyce ACCESS / OnRoad
-> Returned
-> Warehouse AddAsset
-> physical cleanup
```

Ergebnis:

```text
PASS
Stage 1A = ACCEPTED_TECHNICAL_BASELINE for the exact documented provenance
```

Erwarteter und bestätigter strategischer Endzustand:

```text
JOYCE AMMO   44 -> 24
HONAKER AMMO 40 -> 20 -> 40
```

## 2. Strategische / operative Grenze

```text
CampaignState = alleinige strategische Ressourcen-/Cargo-Autorität
MissionDemand = Demand-/Assignment-Zustand
MOOSE BRIGADE / PLATOON / ARMYGROUP / AUFTRAG = physische Ausführung
DCS group = temporäre physische Repräsentation
```

`OPSTRANSPORT` wird in diesem Slice nicht verwendet. Der physische Convoy definiert keine strategische Kapazität. Insbesondere ist aus diesem Test nicht abzuleiten:

```text
1 M1083 = X GROUND_AMMO_PACKAGE
TPL_BLUE_CONVOY_LIGHT_06 = X packages
TPL_BLUE_CONVOY_STANDARD_07 = Y packages
```

## 3. Physischer MOOSE-Vertrag

```text
BRIGADE:New(...)
PLATOON:New(TPL_BLUE_CONVOY_LIGHT_06, 1, ...)
PLATOON:AddMissionCapability(AUFTRAG.Type.AMMOSUPPLY, 100)
BRIGADE:AddPlatoon(...)
AUFTRAG:NewAMMOSUPPLY(destinationZone)
AUFTRAG:SetMissionSpeed(27)
AUFTRAG:SetFormation(ENUMS.Formation.Vehicle.OnRoad)
AUFTRAG:SetReturnToLegion(false)
BRIGADE:AddMission(...)
ARMYGROUP:RTZ(originZone, ENUMS.Formation.Vehicle.OnRoad)
```

Die bereits owner-approved `OMW_GroundRoadSpawnAdapter`-Ausnahme wird ausschließlich für road-aligned Materialisierung verwendet. Kein neuer Router, kein eigener Dispatcher und kein Despawn/Respawn-Fallback wurden eingeführt.

## 4. Delivery-/Return-Gate

Delivery ist fail-closed:

```text
OnAfterMissionExecute
AND exact Mission == acceptance AMMOSUPPLY mission
AND ARMYGROUP:IsInZone(ZON_BLUE_GND_HONAKER_ACCESS) == true
-> CampaignState MarkDelivered
-> MissionDemand DELIVERED / SUCCESS
```

Rückgabe:

```text
MissionDone
-> 30 s settlement window
-> ARMYGROUP:RTZ(Joyce ACCESS, OnRoad)
-> Returned
-> MOOSE ARMYGROUP:onafterReturned
-> legion:__AddAsset(10, group, 1)
-> 12 s final verification window
-> physical cleanup
```

Der 30-s-Delay übernimmt die bereits in Ground Acceptance 4 bestätigte Schutzgrenze gegen die Race-Condition zwischen `MissionDone`, nachlaufender AUFTRAG-Auswertung und einem zu früh gesetzten RTZ.

## 5. Acceptance Build 1-5 – reale lokale Provenienz

```text
Build Git HEAD: 2d72bcdfc113342a2180b6cd9c84486da790052c
BuilderVersion: GROUND-AMMO-RESUPPLY-ACCEPTANCE-1-5
GeneratedUtc: 2026-08-22T18:27:19Z
Acceptance bundle SHA-256: 752B3E6F0B77D1B62C750421DDE36202C81B98632FEFBF6A273F913202DF8339
Builder SHA-256: A55103F0DF919365EF40DF4DB459E4E6AB96D858CF973D9F92B59BB48A75ACFD
Acceptance source SHA-256: 794CA80C717586A796154F605074AC9AB61B27668B216C5A5A8718B772FD76F4
MissionDemand source SHA-256: E348E75B87135B99D780E07CA6B6FB7C3C530E048E9C6DE790328D147DE32848
ResourceDemandPolicy source SHA-256: BDC20ACEDAB60F662093077B8320220EBB71C6C641CC604C4356231B8405913C
GroundRoadSpawnAdapter source SHA-256: 1A81FB2E5270C493373CF5BF6EC01F5AFED47004BF25C4225524121155D983E8
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
OutboundTimeoutSec: 1800
ReturnTimeoutSec: 1800
ReturnIssueDelaySec: 30
ReturnSettlementDelaySec: 12
PhysicalTemplate: TPL_BLUE_CONVOY_LIGHT_06
TransferQuantity: 20
PackagePerTruckCapacityDefined: false
```

## 6. Laufhistorie

```text
Run 1: FAIL / stale embedded Ground production thresholds
Run 2: FAIL / delivery and RTZ acceptance confirmed; global timeout cut return window
Run 3: FAIL / LIGHT_06 delivery confirmed; 2-s post-MissionDone RTZ race reproduced; RETURN_TIMEOUT
Run 4: PASS / 30-s settlement window; full Joyce-Honaker-Joyce roundtrip; Returned; Warehouse AddAsset; cleanup
```

Historische Ergebnisdateien:

```text
mission/tests/ground-resupply-execution/results/2026-08-22-ground-ammo-resupply-acceptance-1-fail-1.md
mission/tests/ground-resupply-execution/results/2026-08-22-ground-ammo-resupply-acceptance-1-fail-2.md
mission/tests/ground-resupply-execution/results/2026-08-22-ground-ammo-resupply-acceptance-1-fail-3.md
mission/tests/ground-resupply-execution/results/2026-08-22-ground-ammo-resupply-acceptance-1-pass-1.md
```

## 7. PASS-Provenienz – Lauf 4

```text
DCS: 2.9.28.26385 MT
Executed mission path: C:\Users\Sven\Saved Games\DCS.openbeta\Missions\OMW_Template_v18.miz
Uploaded artifact: OMW_Template_v18(1).miz
MIZ SHA-256: 2FDF31A2E07409CF392D45BFF5FC69750958C670AE3E12FF28D0B4FD8AECC90D
internal mission SHA-256: 38B207278365CD977E74FF3C9000C6A7C5B13EEE3E5B1BB154F1775055D02AF6
Acceptance bundle SHA-256: 752B3E6F0B77D1B62C750421DDE36202C81B98632FEFBF6A273F913202DF8339
Ground production bundle SHA-256: E616D35F5EBDBDDD4275785091D47F57445348D1FF4BB4CFBE7DEE0F0B12D78E
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
dcs.log SHA-256: 0C0B5784A0AA1C67E0BE57CEEF90006FBEEE40805D7A589D8EF8DC6DC3BFDFDF
debrief.log SHA-256: C9EA7398241DEA3323B39FAD8F28D97D27B5A1CB1EE05A79433BA26896666DEB
```

Reale Pflichtmarker:

```text
18:34:20.456 DELIVERY_CONFIRMED ... quantity=20 ... campaignStateStatus=DELIVERED demandStatus=SUCCESS
18:34:21.457 MISSION_DONE deliveryCommitted=true returnIssueDelaySec=30
18:34:30.913 AUFTRAG ... Mission 3 [Ammo Supply] success!
18:34:51.463 RETURN_RTZ_ACTIVE
18:34:51.463 RETURN_RTZ_ISSUED ... Joyce ... OnRoad
18:36:23.101 RETURNED_HANDOFF
18:36:33.109 WAREHOUSE_ADD_ASSET
18:36:35.110 PASS originFinal=24 destinationFinal=40 transferQuantity=20 template=TPL_BLUE_CONVOY_LIGHT_06 demandStatus=SUCCESS spawnCount=1 returnedCount=1 warehouseAddAssetCount=1
```

Die Owner-Beobachtung bewertet die konfigurierte Marschgeschwindigkeit von 27 kt für `TPL_BLUE_CONVOY_LIGHT_06` visuell als passend. Dieser Acceptance-PASS definiert dadurch noch keine generische Geschwindigkeitspolitik für andere Convoy-Klassen.

## 8. Nicht Teil dieser Acceptance

```text
package-per-truck capacity
automatic LIGHT_06 / STANDARD_07 selection
STANDARD_07 runtime
FUEL RESUPPLY
generic SUPPLY
multiple concurrent demands
convoy under attack / support reaction
carrier-loss and abort settlement
external process/server persistence
production orchestration scheduler
CAS / BLUE COMMANDER
CSAR
```

## 9. Aktueller Status

```text
Stage 1A Ground AMMO Joyce -> Honaker: ACCEPTED_TECHNICAL_BASELINE
MOOSE-first full roundtrip: PASS for exact documented scope
CampaignState transfer settlement: PASS for exact documented scope
Production runtime orchestration: NOT YET CREATED
Next development gate: Stage 1B Ground FUEL or owner-selected next orchestration stage
```
