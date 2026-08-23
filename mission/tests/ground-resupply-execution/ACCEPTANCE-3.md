---
document_id: OMW-GROUND-META-RESUPPLY-NOTHING-ACCEPTANCE-1
status: PLANNED
document_class: ACCEPTANCE_PLAN_AND_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local acceptance plan and result for generic MissionDemand-driven Ground meta-resource RESUPPLY via AUFTRAG NOTHING
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
validated_in_dcs: true
---

# Ground Meta RESUPPLY Acceptance 1 – AUFTRAG NOTHING

## 1. Ziel

Erster Fixture bleibt bewusst `GROUND_FUEL_PACKAGE`:

```text
HONAKER FUEL 36
-> test-only consumption 18
-> HONAKER FUEL 18 / REORDER
-> one MissionDemand RESUPPLY
-> CampaignState TRANSFER 18 Joyce -> Honaker
-> TPL_BLUE_CONVOY_FUEL_LIGHT_06
-> BRIGADE / PLATOON / ARMYGROUP
-> AUFTRAG:NewNOTHING(Honaker ACCESS)
-> OnRoad 27 kt
-> destination-zone proof
-> CampaignState DELIVERED
-> MissionDemand SUCCESS
-> mission cancel / MissionDone
-> 30 s delayed RTZ issue
-> same ARMYGROUP RTZ Joyce ACCESS / OnRoad
-> Returned
-> Warehouse AddAsset
-> physical cleanup
```

Erwarteter strategischer Endzustand:

```text
JOYCE FUEL   40 -> 22
HONAKER FUEL 36 -> 18 -> 36
```

## 2. Architekturgrenze

```text
CampaignState = alleinige strategische Ressourcenautorität
MissionDemand = Demand-/Assignment-Zustand
AUFTRAG NOTHING = nur neutrale physische Bewegung / Aufenthalt
DCS group = temporäre physische Repräsentation
```

Nicht definiert:

```text
DCS fuel quantity
1 M978 = X GROUND_FUEL_PACKAGE
FUEL_LIGHT_06 capacity
physical cargo authority
```

## 3. MOOSE-First Nachweis

Gepinnter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Source-seitig bestätigt:

```lua
AUFTRAG:NewNOTHING(RelaxZone)
```

sowie `AUFTRAG.Type.NOTHING`, `AUFTRAG.SpecialTask.NOTHING`, Ground/Naval-Kategorie, zone objective, FullStop bei Ausführung und TaskCancel -> TaskDone. Eine dedizierte offizielle Demo für den OMW-Roundtrip ist nicht belegt.

## 4. Physischer Vertrag

```text
PLATOON:AddMissionCapability(AUFTRAG.Type.NOTHING, 100)
AUFTRAG:NewNOTHING(destinationZone)
AUFTRAG:SetMissionSpeed(27)
AUFTRAG:SetFormation(ENUMS.Formation.Vehicle.OnRoad)
AUFTRAG:SetReturnToLegion(false)
BRIGADE:AddMission(...)
ARMYGROUP:RTZ(originZone, ENUMS.Formation.Vehicle.OnRoad)
```

Die owner-approved `OMW_GroundRoadSpawnAdapter`-Ausnahme wird unverändert wiederverwendet.

## 5. Acceptance-Abschlussvertrag

Die früheren harten Fahrzeit-Gates waren ein Harness-Fehler und sind ab Build 1-4 vollständig entfernt.

```text
OutboundTravelTimeoutSec = none
ReturnTravelTimeoutSec = none
AcceptanceCompletion = event-driven
DestinationCheckIntervalSec = 15
DestinationExecutionGraceSec = 90
ReturnIssueDelaySec = 30
ReturnSettlementDelaySec = 12
```

Der Test endet damit nicht mehr aufgrund einer angenommenen DCS-Fahrzeit. Er wartet auf den tatsächlichen Lifecycle:

```text
start -> destination entered -> MissionExecute -> delivery -> MissionDone -> RTZ -> Returned -> AddAsset -> PASS
```

`DestinationExecutionGraceSec = 90` ist kein Travel-Timeout. Diese Frist beginnt erst nach beobachtetem Eintritt in die Zielzone und prüft ausschließlich, ob der MOOSE-FSM danach `MissionExecute` liefert.

## 6. Historische Harness-False-Fails

Build 1-1 nutzte `OutboundTimeoutSec = 600`; Build 1-2 nutzte `OutboundTimeoutSec = 1800`; Build 1-3 behielt zusätzlich `ReturnTimeoutSec = 1800`. Diese harten Fahrzeit-Gates waren für die reale DCS-Ground-AI-Fahrt ungeeignet. Nach `fail()` setzte der Harness `state.failed=true`; spätere Lifecycle-Callbacks wurden dadurch absichtlich ignoriert.

Diese Läufe beweisen daher keinen Routing-, Delivery- oder RTZ-Fehler von `NewNOTHING`.

## 7. Build 1-4 – reale lokale Build-Evidenz

Owner-lokal am 23.08.2026 erfolgreich gebaut und unabhängig nachgehasht:

```text
Branch: agent/automatic-response-orchestration
Git HEAD: 8803505edf07120bc6d1673b41f69067e8db0211
BuilderVersion: GROUND-META-RESUPPLY-NOTHING-ACCEPTANCE-1-4
GeneratedUtc: 2026-08-23T15:24:27Z
Bundle SHA-256: C881C82C3F699914E18FFE64DE73E650E20AF82B55B3F486154C40059F44CB65
Independent bundle SHA-256: C881C82C3F699914E18FFE64DE73E650E20AF82B55B3F486154C40059F44CB65
Builder SHA-256: 9F7E3DFAE967BA39C373190A11495EC5AFD39357B0C1001A12F952606816B636
Acceptance source SHA-256: 21A54365C6138425CF5CDF4965F9E6F3396889477708B37A23BCBCFD77897C0C
GroundRoadSpawnAdapter SHA-256: 1A81FB2E5270C493373CF5BF6EC01F5AFED47004BF25C4225524121155D983E8
MissionDemand source SHA-256: E348E75B87135B99D780E07CA6B6FB7C3C530E048E9C6DE790328D147DE32848
ResourceDemandPolicy source SHA-256: BDC20ACEDAB60F662093077B8320220EBB71C6C641CC604C4356231B8405913C
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
OutboundTravelTimeoutSec: none
DestinationCheckIntervalSec: 15
DestinationExecutionGraceSec: 90
ReturnTravelTimeoutSec: none
ReturnIssueDelaySec: 30
ReturnSettlementDelaySec: 12
AcceptanceCompletion: event-driven
FUELSUPPLY: false
OPSTRANSPORT: false
MizMutation: false
```

## 8. DCS-Lauf mit Build 1-4 – Runtime PASS

DCS-Version laut `dcs.log`:

```text
DCS 2.9.28.26385 MT
```

Ausgeführte Mission laut `debrief.log`:

```text
C:\Users\Sven\Saved Games\DCS.openbeta\Missions\OMW_Template_v19.miz
```

Der Acceptance-Lifecycle wurde vollständig erreicht:

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

Terminaler Harness-Befund:

```text
PASS originFinal=22 destinationFinal=36 transferQuantity=18 template=TPL_BLUE_CONVOY_FUEL_LIGHT_06 physicalMission=NOTHING demandStatus=SUCCESS spawnCount=1 returnedCount=1 warehouseAddAssetCount=1
```

Damit ist runtime-seitig für den beobachteten Stand bestätigt:

```text
CampaignState shortage
-> MissionDemand RESUPPLY
-> one physical Fuel-Light convoy
-> AUFTRAG NOTHING Joyce -> Honaker
-> destination-zone detection
-> CampaignState DELIVERED
-> MissionDemand SUCCESS
-> MissionDone
-> same ARMYGROUP RTZ Joyce
-> Returned
-> Warehouse AddAsset
-> physical cleanup
```

Die nach Upload berechneten SHA-256 der Testlogs lauten:

```text
dcs(20260823-153336).log: 7F89D79C10C8C61BB7994CE762C2554124212501FC019E83F5A34C87C54A67DD
debrief(20260823-153334).log: 21D917BC43A00F429A22B1EE697E64A62EC9B487254D330F5A7B1F574A253FA2
```

Detailresultat:

```text
results/2026-08-23-ground-meta-resupply-nothing-acceptance-1-pass-1.md
```

## 9. Provenienzgrenze vor ACCEPTED_TECHNICAL_BASELINE

Der Runtime-PASS ist real und dokumentiert. Für die formale Hochstufung dieses Dokuments auf `ACCEPTED_TECHNICAL_BASELINE` fehlt jedoch noch die nach `docs/DOCUMENT-METADATA-POLICY.md` verpflichtende SHA-256 der **exakt ausgeführten** `OMW_Template_v19.miz` mit Build 1-4.

Bis diese Hashprovenienz vorliegt, gilt daher:

```text
Build 1-4: BUILD PASS
DCS runtime lifecycle: PASS
Acceptance mission path: OMW_Template_v19.miz
Acceptance mission SHA-256: PENDING_OWNER_HASH
Formal ACCEPTED_TECHNICAL_BASELINE promotion: BLOCKED_MISSING_MIZ_SHA256
```

Es wird keine Mission-SHA aus einem älteren v19-Stand übernommen oder geraten.

## 10. Architekturresultat

Der DCS-Lauf bestätigt `AUFTRAG:NewNOTHING(...)` für den getesteten **strategischen Meta-Ressourcen-Roundtrip** als funktionalen physischen Executor. Daraus folgt keine Fuel-/Cargo-Autorität für MOOSE oder DCS.

`AUFTRAG:NewFUELSUPPLY(...)` bleibt davon getrennt. Der frühere Stage-1B-Lauf war timeout-kontaminiert und ist kein Runtime-Gegenbeweis. FUELSUPPLY bleibt als MOOSE-nativer Kandidat für einen späteren separaten operativen RefuellingZone-Service relevant.

## 11. Status

```text
Build 1-4: PASS
DCS runtime: PASS
Full Joyce -> Honaker -> Joyce roundtrip: PASS
CampaignState final quantities: PASS (Joyce 22 / Honaker 36)
MissionDemand final status: PASS / SUCCESS
Returned handoff: PASS
Warehouse AddAsset: PASS
Formal ACCEPTED_TECHNICAL_BASELINE: PENDING exact executed MIZ SHA-256
```
