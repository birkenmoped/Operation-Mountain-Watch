---
document_id: OMW-MOOSE-GROUND-RESUPPLY-EXECUTION-SOURCE-REVIEW
status: ACCEPTED_TECHNICAL_BASELINE
document_class: TECHNICAL_SOURCE_REVIEW
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local MOOSE source review for physical Ground RESUPPLY execution
  - accepted Stage 1A AMMOSUPPLY lifecycle
  - failed Stage 1B FUELSUPPLY OMW meta-resupply experiment
  - source-reviewed Stage 1C AUFTRAG NOTHING meta-resupply replacement
not_authoritative_for:
  - production generic Ground RESUPPLY executor
  - AUFTRAG NOTHING runtime acceptance before dedicated DCS test
  - CAS or CSAR execution
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# Ground RESUPPLY Execution – MOOSE Source Review

## 1. Geprüfter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Maßgeblich für API-Verfügbarkeit ist die tatsächlich verwendete `Moose.lua`. Dokumentation und offizielle Beispiele ergänzen den Source, ersetzen ihn aber nicht.

## 2. Strategische Grenze

```text
CampaignState = einzige strategische Ressourcenautorität
MissionDemand = Demand-/Assignment-Zustand
MOOSE = physische operative Ausführung
DCS groups = temporäre physische Repräsentation
```

`GROUND_AMMO_PACKAGE`, `GROUND_FUEL_PACKAGE` und `GROUND_SUPPLY_PACKAGE` sind strategische CampaignState-Waren. Physische Trucks oder Tanker definieren keine Package-Kapazität.

## 3. Stage 1A – AMMO / akzeptierte technische Baseline

DCS-bestätigt:

```text
BRIGADE / PLATOON / ARMYGROUP
AUFTRAG:NewAMMOSUPPLY(destinationZone)
SetMissionSpeed(27)
SetFormation(OnRoad)
SetReturnToLegion(false)
CampaignState delivery after destination-zone proof
MissionDone
30 s settlement
same ARMYGROUP RTZ Joyce ACCESS / OnRoad
Returned
LEGION/Warehouse AddAsset
physical cleanup
```

Provenienz:

```text
Acceptance source/build commit: 2d72bcdfc113342a2180b6cd9c84486da790052c
BuilderVersion: GROUND-AMMO-RESUPPLY-ACCEPTANCE-1-5
Bundle SHA-256: 752B3E6F0B77D1B62C750421DDE36202C81B98632FEFBF6A273F913202DF8339
DCS: 2.9.28.26385 MT
Executed mission: OMW_Template_v18.miz
MIZ SHA-256: 2FDF31A2E07409CF392D45BFF5FC69750958C670AE3E12FF28D0B4FD8AECC90D
Result: PASS
```

## 4. Stage 1B – FUELSUPPLY / Fehlpfad für OMW-Meta-Ware

`AUFTRAG:NewFUELSUPPLY(Zone)` existiert im gepinnten Source. Der Source verknüpft `FUELSUPPLY` zudem mit `BRIGADE:AddRefuellingZone(...)`; ein dedizierter offizieller Warehouse-to-Warehouse-Meta-Fuel-Roundtrip wurde nicht gefunden.

Der reale DCS-Lauf zeigte:

```text
ROAD_ALIGNED_WAREHOUSE_SPAWN
GROUP_MATERIALIZED
ARMY_ON_MISSION mission=FUELSUPPLY
-> no OnAfterMissionExecute
-> no DELIVERY_CONFIRMED
-> no MissionDone
-> no RTZ
FAIL OUTBOUND_TIMEOUT
missionExecuteCount=0
missionDoneCount=0
```

Damit gilt für OMW:

```text
AUFTRAG:NewFUELSUPPLY(Zone)
= available MOOSE API
= refuelling-zone concept candidate
= REJECTED_FOR_CURRENT_OMW_META_RESUPPLY_EXECUTOR
```

Das ist keine generelle Fehleraussage über MOOSE `FUELSUPPLY`.

Resultat:

```text
mission/tests/ground-resupply-execution/results/2026-08-22-ground-fuel-resupply-acceptance-1-fail-1.md
```

## 5. WAREHOUSE SELFPROPELLED – geprüft, aber nicht ausgewählt

Der gepinnte Source und MOOSE Warehouse Example 15 belegen:

```text
WAREHOUSE:AddRequest(...)
WAREHOUSE.TransportType.SELFPROPELLED
```

für selbstfahrende Ground-Assets zwischen Warehouses, einschließlich `M978` und `M818` im Beispiel.

Der Source zeigt jedoch beim Ziel-Handoff:

```text
onafterArrived
-> route toward receiving warehouse
-> warehouse:__AddAsset(60, group)
-> physical group absorbed into destination warehouse stock
```

Ein späterer Rücktransport würde aus dem Ziel-Warehouse erneut materialisiert. Das passt nicht zum bestätigten OMW-Vertrag eines kontinuierlich sichtbaren Hin-/Rückwegs mit demselben ARMYGROUP. Deshalb wird SELFPROPELLED für diesen Scope nicht als Acceptance-Pfad gewählt.

## 6. Stage 1C – Owner-approved Ersatz: AUFTRAG NOTHING

Owner-Entscheidung 22.08.2026:

```text
physical meta-resupply contract via AUFTRAG:NewNOTHING(destinationZone): APPROVED FOR ACCEPTANCE
```

Der tatsächlich verwendete Source bestätigt:

```lua
function AUFTRAG:NewNOTHING(RelaxZone)
  local mission=AUFTRAG:New(AUFTRAG.Type.NOTHING)
  mission:_TargetFromObject(RelaxZone)
  mission.optionROE=ENUMS.ROE.WeaponHold
  mission.optionAlarm=ENUMS.AlarmState.Auto
  mission.missionFraction=1.0
  mission.categories={AUFTRAG.Category.GROUND, AUFTRAG.Category.NAVAL}
  mission.DCStask=mission:GetDCSMissionTask()
  return mission
end
```

`GetDCSMissionTask()` erzeugt für `AUFTRAG.Type.NOTHING` einen `AUFTRAG.SpecialTask.NOTHING`.

Der OPSGROUP-Ausführungspfad bestätigt:

```text
SpecialTask.NOTHING
-> ground/naval group __FullStop(0.1)
```

Der TaskCancel-Pfad bestätigt ausdrücklich:

```text
SpecialTask.NOTHING -> done=true -> TaskDone
```

und der allgemeine `TaskDone`-Pfad führt für die aktuelle Mission in den Mission-Done-Lifecycle.

Damit ist `NOTHING` für OMW semantisch neutral: Es bewegt die physische Repräsentation zu einer Zone und lässt sie dort stehen, ohne eine Fuel-, Ammo- oder Cargo-Autorität zu beanspruchen.

## 7. Stage-1C Acceptance-Vertrag

Der erste Fixture bleibt absichtlich Fuel, damit gegenüber Stage 1B nur die physische Missionssemantik geändert wird:

```text
HONAKER GROUND_FUEL_PACKAGE 36
-> consume 18
-> 18 / REORDER
-> MissionDemand RESUPPLY
-> CampaignState TRANSFER 18 Joyce -> Honaker
-> TPL_BLUE_CONVOY_FUEL_LIGHT_06
-> BRIGADE / PLATOON / ARMYGROUP
-> AUFTRAG:NewNOTHING(Honaker ACCESS)
-> OnRoad 27 kt
-> exact destination-zone proof
-> CampaignState DELIVERED
-> MissionDemand SUCCESS
-> mission cancel / MissionDone
-> 30 s settlement
-> same ARMYGROUP RTZ Joyce ACCESS / OnRoad
-> Returned
-> Warehouse AddAsset
-> physical cleanup
```

Keine Ableitung:

```text
DCS fuel quantity
1 M978 = X packages
FUEL_LIGHT_06 capacity
```

## 8. Fail-fast Verbesserung

Der Ersatz-Harness enthält einen bounded MOOSE-SCHEDULER-Gate:

```text
OutboundTimeoutSec = 600
DestinationCheckIntervalSec = 15
DestinationExecutionGraceSec = 90
```

Sobald der ARMYGROUP tatsächlich in der Zielzone erkannt wird, muss `MissionExecute` binnen 90 Sekunden folgen. Sonst:

```text
FAIL reason=DESTINATION_EXECUTION_TIMEOUT
```

Damit wird der bei Stage 1B beobachtete Zielstillstand ohne Lifecycle-Fortschritt deutlich früher beendet.

## 9. Implementierungsstatus

```text
Stage 1A AMMO / AMMOSUPPLY: ACCEPTED_TECHNICAL_BASELINE
Stage 1B FUEL / FUELSUPPLY meta-resupply: FAILED / CLOSED
WAREHOUSE SELFPROPELLED: SOURCE_REVIEWED / NOT_SELECTED_FOR_CONTINUOUS_ROUNDTRIP
Stage 1C AUFTRAG NOTHING: SOURCE_REVIEWED / OWNER_APPROVED_FOR_ACCEPTANCE / DCS_PENDING
GROUND_FUEL_PACKAGE: RETAIN AS CAMPAIGNSTATE META RESOURCE
Fuel convoy templates: RETAIN AS PHYSICAL REPRESENTATIONS
production generic executor: NOT YET CREATED
```

Staged files:

```text
mission/tests/ground-resupply-execution/src/03-ground-meta-resupply-nothing-acceptance.lua
mission/tests/ground-resupply-execution/ACCEPTANCE-3.md
tools/build-ground-meta-resupply-nothing-acceptance-1.ps1
```
