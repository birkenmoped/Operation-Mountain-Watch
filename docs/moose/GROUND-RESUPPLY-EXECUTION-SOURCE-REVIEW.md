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

Der reale DCS-Lauf zeigte `ARMY_ON_MISSION mission=FUELSUPPLY`, aber kein `MissionExecute`, keine Delivery, kein MissionDone und keinen RTZ. Damit wird `FUELSUPPLY` für den aktuellen OMW-Meta-RESUPPLY-Executor nicht weiterverwendet. Das ist keine generelle Fehleraussage über MOOSE `FUELSUPPLY`.

Resultat:

```text
mission/tests/ground-resupply-execution/results/2026-08-22-ground-fuel-resupply-acceptance-1-fail-1.md
```

## 5. WAREHOUSE SELFPROPELLED – geprüft, aber nicht ausgewählt

Der gepinnte Source und MOOSE Warehouse Example 15 belegen `WAREHOUSE:AddRequest(...)` mit `WAREHOUSE.TransportType.SELFPROPELLED` für selbstfahrende Ground-Assets zwischen Warehouses, einschließlich `M978` und `M818` im Beispiel.

Der Ziel-Handoff führt jedoch zu `warehouse:__AddAsset(60, group)` und physischer Aufnahme in das Ziel-Warehouse. Eine Rückfahrt würde eine neue Materialisierung erfordern. Das passt nicht zum owner-bestätigten OMW-Vertrag eines kontinuierlichen Hin-/Rückwegs mit demselben ARMYGROUP.

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
-> 30 s settlement
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

## 8. Stage-1C Lauf 1 – korrigierte Diagnose

Build `GROUND-META-RESUPPLY-NOTHING-ACCEPTANCE-1-1` verwendete:

```text
OutboundTimeoutSec = 600
DestinationCheckIntervalSec = 15
DestinationExecutionGraceSec = 90
```

Der Harness meldete nach 600 Simulationssekunden `OUTBOUND_TIMEOUT` und setzte `state.failed=true`. Der Convoy fuhr laut Owner-Beobachtung danach physisch weiter bis Honaker, kehrte jedoch nicht zurück.

Die statische Geometrie erklärt den fehlenden Return ohne Annahme eines MOOSE-Routingfehlers: Joyce-ACCESS und Honaker-ACCESS liegen rund 16,9 km Luftlinie auseinander. Bei 27 kt (~50 km/h) beträgt die theoretische Mindestfahrzeit bereits rund 1.218 Sekunden, noch ohne Straßendetouren oder AI-Verlangsamung. Ein 600-s-Outbound-Fenster war daher zu kurz.

Nach `state.failed=true` verlassen die Stage-1C-Callbacks für MissionExecute, MissionDone und RTZ den Harness. Deshalb konnte die spätere physische Ankunft keine Delivery-/Return-Kette mehr auslösen.

Der DCS-Marker `CREATING PATH MAKES TOO LONG!!!!!` bleibt als diagnostischer Hinweis erhalten, ist aber aus diesem Lauf nicht als Root Cause des fehlenden Returns nachgewiesen.

Klassifikation:

```text
HARNESS_FALSE_FAIL_OUTBOUND_TIMEOUT_TOO_SHORT
AUFTRAG NOTHING runtime acceptance: NOT YET PROVEN
```

Detail:

```text
mission/tests/ground-resupply-execution/results/2026-08-23-ground-meta-resupply-nothing-acceptance-1-fail-1.md
```

## 9. Korrigierter Acceptance-Vertrag

```text
OutboundTimeoutSec = 1800
DestinationCheckIntervalSec = 15
DestinationExecutionGraceSec = 90
ReturnTimeoutSec = 1800
ReturnIssueDelaySec = 30
ReturnSettlementDelaySec = 12
```

`1800` entspricht wieder dem Stage-1A-Outbound-Fenster. Der Fail-fast-Schutz wird nicht entfernt: Nach tatsächlichem Eintritt in Honaker ACCESS muss `MissionExecute` weiterhin binnen 90 Sekunden folgen.

Korrigierter Source-/Builder-Stand:

```text
mission/tests/ground-resupply-execution/src/03-ground-meta-resupply-nothing-acceptance.lua
OUTBOUND_TIMEOUT_SEC = 1800

tools/build-ground-meta-resupply-nothing-acceptance-1.ps1
BuilderVersion = GROUND-META-RESUPPLY-NOTHING-ACCEPTANCE-1-2
```

## 10. Implementierungsstatus

```text
Stage 1A AMMO / AMMOSUPPLY: ACCEPTED_TECHNICAL_BASELINE
Stage 1B FUEL / FUELSUPPLY meta-resupply: FAILED / CLOSED
WAREHOUSE SELFPROPELLED: SOURCE_REVIEWED / NOT_SELECTED_FOR_CONTINUOUS_ROUNDTRIP
Stage 1C AUFTRAG NOTHING source: SOURCE_REVIEWED / OWNER_APPROVED_FOR_ACCEPTANCE
Stage 1C run 1: HARNESS_FALSE_FAIL_OUTBOUND_TIMEOUT_TOO_SHORT
Stage 1C corrected harness: STAGED / OWNER BUILD PENDING / DCS RETEST PENDING
GROUND_FUEL_PACKAGE: RETAIN AS CAMPAIGNSTATE META RESOURCE
Fuel convoy templates: RETAIN AS PHYSICAL REPRESENTATIONS
production generic executor: NOT YET CREATED
```
