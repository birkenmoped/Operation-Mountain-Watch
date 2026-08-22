---
document_id: OMW-GROUND-FUEL-RESUPPLY-ACCEPTANCE-1
status: DRAFT
document_class: ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local DCS acceptance plan for the first MissionDemand-driven physical Ground FUEL RESUPPLY vertical slice
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Ground FUEL RESUPPLY Acceptance 1 – Joyce nach Honaker

## 1. Ziel

```text
Honaker FUEL 36
-> test-only consumption 18
-> Honaker FUEL 18
-> ResourceDemandPolicy = REORDER
-> one RESUPPLY MissionDemand
-> CampaignState TRANSFER Joyce -> Honaker / 18
-> one protected FUEL_LIGHT_06 convoy FUELSUPPLY mission
-> physical arrival in Honaker ACCESS zone
-> CampaignState DELIVERED
-> Honaker FUEL 36
-> MissionDemand SUCCESS
-> complete convoy RTZ Joyce
-> Returned
-> Warehouse AddAsset / physical cleanup
```

Erwarteter strategischer Endzustand:

```text
JOYCE FUEL   40 -> 22
HONAKER FUEL 36 -> 18 -> 36
```

## 2. Strategische / operative Grenze

```text
CampaignState = alleinige strategische Ressourcen-/Cargo-Autorität
MissionDemand = Demand-/Assignment-Zustand
MOOSE BRIGADE / PLATOON / ARMYGROUP / AUFTRAG = physische Ausführung
DCS group = temporäre physische Repräsentation
```

Der physische Convoy definiert keine strategische Tankkapazität. Insbesondere ist aus diesem Test nicht abzuleiten:

```text
1 M978 HEMTT Tanker = X GROUND_FUEL_PACKAGE
TPL_BLUE_CONVOY_FUEL_LIGHT_06 = X packages
TPL_BLUE_CONVOY_FUEL_STD_07 = Y packages
```

## 3. v19 Template-Preflight

Owner-Mission, durch ChatGPT ausschließlich read-only geprüft:

```text
artifact: OMW_Template_v19.miz
MIZ SHA-256: B89DBE7B755D25B43384B158F3D25921C70847820F71B837F12F86C5D863A8A6
internal mission SHA-256: 6B15369398C3B5989B676DB473127489C236F5948737AA3242FDB182FD515B95
```

Für Stage 1B ausgewähltes Fixture:

```text
TPL_BLUE_CONVOY_FUEL_LIGHT_06
lateActivation = true
units = 6
1  CHAP_MATV
2  M978 HEMTT Tanker
3  MaxxPro_MRAP
4  M978 HEMTT Tanker
5  MaxxPro_MRAP
6  CHAP_MATV
```

Zusätzlich vorhanden:

```text
TPL_BLUE_CONVOY_FUEL_STD_07
lateActivation = true
units = 7
1  CHAP_MATV
2  M978 HEMTT Tanker
3  MaxxPro_MRAP
4  M978 HEMTT Tanker
5  MaxxPro_MRAP
6  M978 HEMTT Tanker
7  CHAP_MATV

TPL_BLUE_CONVOY_MIXED_LIGHT_06
lateActivation = true
units = 6
1  CHAP_MATV
2  CHAP_M1083
3  MaxxPro_MRAP
4  M978 HEMTT Tanker
5  MaxxPro_MRAP
6  CHAP_MATV

TPL_BLUE_CONVOY_MIXED_STD_07
lateActivation = true
units = 7
1  CHAP_MATV
2  CHAP_M1083
3  MaxxPro_MRAP
4  M978 HEMTT Tanker
5  MaxxPro_MRAP
6  CHAP_M1083
7  CHAP_MATV
```

Stage 1B verwendet nur `TPL_BLUE_CONVOY_FUEL_LIGHT_06`. Die anderen neuen Templates definieren noch keine automatische Auswahlregel.

## 4. MOOSE-First Source Review

Geprüfter Projektstand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Bestätigt in tatsächlicher `Moose.lua`:

```lua
AUFTRAG:NewFUELSUPPLY(Zone)
```

Source-seitig bestätigt:

```text
AUFTRAG.Type.FUELSUPPLY
AUFTRAG.SpecialTask.FUELSUPPLY
ground mission path
WeaponHold
AlarmState.Auto
same OPSGROUP special-task family as AMMOSUPPLY
TaskCancel handling for FUELSUPPLY
```

Die aktuelle Online-MOOSE-Dokumentation führt `AUFTRAG:NewFUELSUPPLY(Zone)` ausdrücklich als `[GROUND] Create a FUEL SUPPLY mission`.

Offizielle MOOSE-Demo-Repositories wurden geprüft. Es wurde kein dedizierter aktueller `NewFUELSUPPLY`-Beispielpfad gefunden. Diese fehlende Demo-Evidenz ist dokumentiert und wird nicht durch Annahmen ersetzt.

## 5. Physischer Vertrag

```text
BRIGADE:New(...)
PLATOON:New(TPL_BLUE_CONVOY_FUEL_LIGHT_06, 1, ...)
PLATOON:AddMissionCapability(AUFTRAG.Type.FUELSUPPLY, 100)
BRIGADE:AddPlatoon(...)
AUFTRAG:NewFUELSUPPLY(destinationZone)
AUFTRAG:SetMissionSpeed(27)
AUFTRAG:SetFormation(ENUMS.Formation.Vehicle.OnRoad)
AUFTRAG:SetReturnToLegion(false)
BRIGADE:AddMission(...)
ARMYGROUP:RTZ(originZone, ENUMS.Formation.Vehicle.OnRoad)
```

Die vorhandene owner-approved `OMW_GroundRoadSpawnAdapter`-Ausnahme wird unverändert wiederverwendet. Kein neuer Dispatcher, Router, Pathfinding-Code, Native-DCS-Spawn oder MIST wird eingeführt.

## 6. Delivery-/Return-Gate

Delivery bleibt fail-closed:

```text
OnAfterMissionExecute
AND exact Mission == acceptance FUELSUPPLY mission
AND ARMYGROUP:IsInZone(ZON_BLUE_GND_HONAKER_ACCESS) == true
```

Erst danach:

```text
CampaignState MarkDelivered
MissionDemand reservationState = DELIVERED
MissionDemand SUCCESS
```

Return übernimmt den in Stage 1A DCS-bestätigten Lifecycle-Schutz:

```text
MissionDone
-> 30 s settlement window
-> ARMYGROUP:RTZ(Joyce ACCESS, OnRoad)
-> Returned
-> MOOSE LEGION __AddAsset(10,...)
-> 12 s final verification window
-> physical cleanup
```

Der 30-s-Delay ist kein Fuel-Unloading-Modell. Er schützt gegen die bereits praktisch beobachtete AUFTRAG-completion/RTZ-Race-Condition.

## 7. Builder / Source

```text
mission/tests/ground-resupply-execution/src/02-ground-fuel-resupply-acceptance.lua
tools/build-ground-fuel-resupply-acceptance-1.ps1
BuilderVersion: GROUND-FUEL-RESUPPLY-ACCEPTANCE-1-1
```

Build- und Bundle-Hashes bleiben bis zum realen owner-seitigen PowerShell-Build unbekannt.

## 8. Pflichtmarker

```text
START testId=GROUND-FUEL-RESUPPLY-ACCEPTANCE-1
DEMAND_RESERVED
PHYSICAL_EXECUTION_READY ... template=TPL_BLUE_CONVOY_FUEL_LIGHT_06
BRIGADE_STARTED
MISSION_QUEUED type=FUELSUPPLY ... speedKt=27
GROUP_MATERIALIZED ... template=TPL_BLUE_CONVOY_FUEL_LIGHT_06
ARMY_ON_MISSION ... mission=FUELSUPPLY
DELIVERY_CONFIRMED
MISSION_DONE deliveryCommitted=true returnIssueDelaySec=30
RETURN_RTZ_ISSUED
RETURN_RTZ_ACTIVE
RETURNED_HANDOFF
WAREHOUSE_ADD_ASSET
PASS ... template=TPL_BLUE_CONVOY_FUEL_LIGHT_06 ... returnedCount=1 warehouseAddAssetCount=1
```

Jeder `FAIL`, `OUTBOUND_TIMEOUT` oder `RETURN_TIMEOUT` bedeutet overall FAIL.

## 9. Nicht Teil dieses Gates

```text
package-per-tanker capacity
automatic FUEL_LIGHT_06 / FUEL_STD_07 selection
mixed-convoy automatic selection
generic SUPPLY
multiple concurrent resupply demands
convoy under attack
CAS / BLUE COMMANDER
CSAR
external process/server persistence
production orchestration scheduler
```

## 10. Aktueller Status

```text
v19 template preflight: PASS / READ-ONLY
MOOSE documentation: REVIEWED
pinned Moose.lua: REVIEWED
MOOSE official demos: REVIEWED / no dedicated FUELSUPPLY demo found
acceptance source: STAGED ON BRANCH
builder: STAGED ON BRANCH
local owner build: NOT RUN
bundle SHA-256: UNKNOWN
Mission Editor integration: NOT STARTED
DCS runtime: NOT RUN
Acceptance classification: NOT YET PASS
```
