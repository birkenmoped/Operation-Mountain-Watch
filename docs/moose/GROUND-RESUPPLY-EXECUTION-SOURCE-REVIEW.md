---
document_id: OMW-MOOSE-GROUND-RESUPPLY-EXECUTION-SOURCE-REVIEW
status: ACCEPTED_TECHNICAL_BASELINE
document_class: TECHNICAL_SOURCE_REVIEW
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local MOOSE source review for physical Ground RESUPPLY execution
  - accepted Stage 1A AMMOSUPPLY lifecycle
  - timeout-contaminated Stage 1B FUELSUPPLY experiment
  - accepted Stage 1C AUFTRAG NOTHING meta-resupply path
not_authoritative_for:
  - production generic Ground RESUPPLY executor outside the accepted Stage 1C fixture
  - operational RefuellingZone/FUELSUPPLY acceptance
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
30 s delayed RTZ issue
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

## 4. Stage 1B – FUELSUPPLY / timeout-kontaminierter Versuch

`AUFTRAG:NewFUELSUPPLY(Zone)` existiert im gepinnten Source. Der Source verknüpft `FUELSUPPLY` zudem mit `BRIGADE:AddRefuellingZone(...)`; ein dedizierter offizieller Warehouse-to-Warehouse-Meta-Fuel-Roundtrip wurde nicht gefunden.

Der damalige reale DCS-Lauf erreichte:

```text
ROAD_ALIGNED_WAREHOUSE_SPAWN
GROUP_MATERIALIZED
ARMY_ON_MISSION mission=FUELSUPPLY
```

Danach setzte der Acceptance-Harness bei `OUTBOUND_TIMEOUT seconds=1800` auf `failed=true`, bevor `MissionExecute` beobachtet wurde.

Die spätere Stage-1C-Evidenz zeigt, dass harte Fahrzeit-Gates auf dieser Strecke ungeeignet sind. Der Stage-1B-Lauf wird deshalb nicht mehr als Beweis eines FUELSUPPLY-Routing- oder Return-Fehlers verwendet.

Klassifikation:

```text
FUELSUPPLY strategic meta-resupply runtime result:
HARNESS_TIMEOUT_CONTAMINATED / INCONCLUSIVE
```

FUELSUPPLY bleibt als MOOSE-nativer Kandidat für eine getrennte operative RefuellingZone-Rolle relevant.

Detail:

```text
mission/tests/ground-resupply-execution/ACCEPTANCE-2.md
```

## 5. WAREHOUSE SELFPROPELLED – geprüft, aber nicht ausgewählt

Der gepinnte Source und MOOSE Warehouse Example 15 belegen `WAREHOUSE:AddRequest(...)` mit `WAREHOUSE.TransportType.SELFPROPELLED` für selbstfahrende Ground-Assets zwischen Warehouses, einschließlich `M978` und `M818` im Beispiel.

Der Ziel-Handoff führt jedoch zu `warehouse:__AddAsset(60, group)` und physischer Aufnahme in das Ziel-Warehouse. Eine Rückfahrt würde eine neue Materialisierung erfordern. Das passt nicht zum owner-bestätigten OMW-Vertrag eines kontinuierlichen Hin-/Rückwegs mit demselben ARMYGROUP.

## 6. Stage 1C – strategischer Meta-RESUPPLY via AUFTRAG NOTHING

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

Weiter bestätigt:

```text
AUFTRAG.Type.NOTHING
AUFTRAG.SpecialTask.NOTHING
SpecialTask.NOTHING -> ground/naval __FullStop(0.1)
TaskCancel NOTHING -> done=true -> TaskDone
TaskDone -> MissionDone lifecycle for current mission
```

Damit ist `NOTHING` für OMW semantisch neutral: Es beansprucht keine Fuel-, Ammo- oder Cargo-Autorität.

## 7. Stage-1C Acceptance-Vertrag

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
-> destination-zone proof
-> CampaignState DELIVERED
-> MissionDemand SUCCESS
-> mission cancel / MissionDone
-> 30 s delayed RTZ issue
-> same ARMYGROUP RTZ Joyce ACCESS / OnRoad
-> Returned
-> Warehouse AddAsset
```

Keine Ableitung:

```text
DCS fuel quantity
1 M978 = X packages
FUEL_LIGHT_06 capacity
```

## 8. Harness-Korrektur

Die früheren Stage-1C-Builds verwendeten harte Outbound-/Return-Fahrzeit-Gates. Diese wurden durch die tatsächliche DCS-Ground-AI-Fahrzeit selbst zu einer Fehlerquelle.

Ab Build 1-4 gilt deshalb:

```text
OutboundTravelTimeoutSec = none
ReturnTravelTimeoutSec = none
AcceptanceCompletion = event-driven
DestinationCheckIntervalSec = 15
DestinationExecutionGraceSec = 90
ReturnIssueDelaySec = 30
ReturnSettlementDelaySec = 12
```

`DestinationExecutionGraceSec = 90` beginnt erst nach tatsächlichem Eintritt in die Zielzone und ist daher kein Travel-Timeout.

## 9. Build 1-4 – reale lokale Evidenz

```text
Branch: agent/automatic-response-orchestration
Git HEAD: 8803505edf07120bc6d1673b41f69067e8db0211
BuilderVersion: GROUND-META-RESUPPLY-NOTHING-ACCEPTANCE-1-4
Bundle SHA-256: C881C82C3F699914E18FFE64DE73E650E20AF82B55B3F486154C40059F44CB65
Builder SHA-256: 9F7E3DFAE967BA39C373190A11495EC5AFD39357B0C1001A12F952606816B636
Acceptance source SHA-256: 21A54365C6138425CF5CDF4965F9E6F3396889477708B37A23BCBCFD77897C0C
GroundRoadSpawnAdapter SHA-256: 1A81FB2E5270C493373CF5BF6EC01F5AFED47004BF25C4225524121155D983E8
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
Result: BUILD PASS
```

## 10. Stage 1C – DCS Runtime PASS und technische Baseline

Der Build-1-4-DCS-Lauf erreichte vollständig:

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

Vollständige Acceptance-Provenienz:

```text
Acceptance branch: agent/automatic-response-orchestration
Acceptance commit: 8803505edf07120bc6d1673b41f69067e8db0211
DCS: 2.9.28.26385 MT
Executed mission path: C:\Users\Sven\Saved Games\DCS.openbeta\Missions\OMW_Template_v19.miz
Executed MIZ SHA-256: D788AF36535D3ACD1866D15FFB5D354B2C44B5F8EE40D4BAF6FD1D97B7C0F8A5
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
dcs.log SHA-256: 7F89D79C10C8C61BB7994CE762C2554124212501FC019E83F5A34C87C54A67DD
debrief.log SHA-256: 21D917BC43A00F429A22B1EE697E64A62EC9B487254D330F5A7B1F574A253FA2
```

Stage 1C ist damit für genau diesen dokumentierten Stand `ACCEPTED_TECHNICAL_BASELINE`. Der Nachweis bestätigt den strategischen Meta-Ressourcen-Roundtrip, nicht einen allgemeinen produktiven Executor für alle Ground-RESUPPLY-Fälle.

Detailresultat:

```text
mission/tests/ground-resupply-execution/results/2026-08-23-ground-meta-resupply-nothing-acceptance-1-pass-1.md
```

## 11. Implementierungsstatus

```text
Stage 1A AMMO / AMMOSUPPLY: ACCEPTED_TECHNICAL_BASELINE
Stage 1B FUEL / FUELSUPPLY strategic meta-resupply experiment: INCONCLUSIVE / HISTORICAL_TEST_FIXTURE
WAREHOUSE SELFPROPELLED: SOURCE_REVIEWED / NOT_SELECTED_FOR_CONTINUOUS_ROUNDTRIP
Stage 1C AUFTRAG NOTHING: ACCEPTED_TECHNICAL_BASELINE FOR DOCUMENTED STRATEGIC META-RESUPPLY FIXTURE
GROUND_FUEL_PACKAGE: RETAIN AS CAMPAIGNSTATE META RESOURCE
Fuel convoy templates: RETAIN AS PHYSICAL REPRESENTATIONS
Operational RefuellingZone/FUELSUPPLY: SEPARATE FUTURE ACCEPTANCE
Production generic executor: NOT YET CREATED
```
