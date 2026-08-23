---
document_id: OMW-GROUND-META-RESUPPLY-NOTHING-ACCEPTANCE-1
status: PLANNED
document_class: ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local acceptance plan and result for generic MissionDemand-driven Ground meta-resource RESUPPLY via AUFTRAG NOTHING
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
validated_in_dcs: false
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

sowie `AUFTRAG.Type.NOTHING`, `AUFTRAG.SpecialTask.NOTHING`, Ground/Naval-Kategorie, zone objective, FullStop bei Ausführung und TaskCancel->TaskDone. Eine dedizierte offizielle Demo für den OMW-Roundtrip ist nicht belegt.

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

Build 1-1 nutzte `OutboundTimeoutSec = 600`; Build 1-2 nutzte `OutboundTimeoutSec = 1800`. Beide Werte waren für die reale Joyce→Honaker-DCS-Fahrzeit ungeeignet. Nach `fail()` setzte der Harness `state.failed=true`; spätere Lifecycle-Callbacks wurden dadurch absichtlich ignoriert.

Diese Läufe beweisen daher keinen Routing- oder RTZ-Fehler von `NewNOTHING`.

## 7. DCS-Lauf mit Build 1-3 – partielle positive Runtime-Evidenz

Der reale DCS-Lauf mit Build 1-3 erreichte erstmals die entscheidende Hinweg-/Delivery-/RTZ-Kette:

```text
DESTINATION_ZONE_ENTERED
DELIVERY_CONFIRMED
MISSION_DONE
AUFTRAG success
RETURN_RTZ_ACTIVE
RETURN_RTZ_ISSUED
```

Damit ist für den getesteten Stand real belegt:

```text
AUFTRAG NOTHING transport
-> destination-zone detection
-> CampaignState DELIVERED
-> MissionDemand SUCCESS
-> MissionDone
-> same ARMYGROUP RTZ issued
```

Der Lauf endete anschließend ausschließlich mit dem noch vorhandenen `RETURN_TIMEOUT seconds=1800`, bevor `Returned`/`AddAsset` beobachtet werden konnten. Dieser Return-Timeout wird deshalb nicht als produktiver oder funktionaler Fehler gewertet.

Ausgeführte Mission laut debrief:

```text
C:\Users\Sven\Saved Games\DCS.openbeta\Missions\OMW_Template_v19.miz
DCS: 2.9.28.26385 MT
```

## 8. Build 1-4 – reale lokale Build-Evidenz

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

Build 1-4 ist damit ein realer lokaler BUILD PASS. `NewNOTHING` ist jedoch erst dann vollständig runtime-accepted, wenn ein DCS-Lauf `Returned -> Warehouse AddAsset -> PASS` dokumentiert.

## 9. Mission-Editor-Integration für Build 1-4

Das bestehende Stage-1C-`DO SCRIPT FILE` muss im DCS Mission Editor erneut auf folgende Datei gesetzt werden:

```text
mission\tests\ground-resupply-execution\dist\OMW_Ground_Meta_Resupply_NOTHING_Acceptance_1.lua
```

Erwarteter eingebetteter Bundle-Hash:

```text
C881C82C3F699914E18FFE64DE73E650E20AF82B55B3F486154C40059F44CB65
```

Die zuletzt funktionierende Honaker-ACCESS-Geometrie soll unverändert bleiben. Kein weiterer Timeout- oder Formationstest ist Bestandteil dieses Acceptance-Laufs.

## 10. Status

```text
Build 1-4: BUILD PASS
MIZ integration: OWNER ACTION REQUIRED
DCS final runtime acceptance: PENDING
VALIDATED: false
```
