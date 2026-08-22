---
document_id: OMW-MOOSE-CLASS-INDEX
status: BINDING
document_class: MOOSE_CLASS_REGISTER
owning_policy: OMW-GOV-001
authoritative_for:
  - project MOOSE class statuses
  - planned MOOSE integration candidates
  - scope boundaries of class-level evidence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - class index without consolidated AIRWING lifecycle evidence
superseded_by:
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# MOOSE-Projektklassenindex

## 1. Zweck

Dieser Index führt den Projektstatus der für **Operation Mountain Watch** relevanten MOOSE-Klassen und Module. Der vollständige frühere Klassenindex bleibt als Source-Evidence erhalten:

- [`Legacy-MOOSE-Klassenindex`](../evidence/source-records/legacy-moose-project-class-index.md)

Technische Lifecycle-Details:

- [`OMW-MOOSE-AIRWING-SQUADRON-WAREHOUSE-LIFECYCLE`](AIRWING-SQUADRON-WAREHOUSE-LIFECYCLE.md)
- [`OMW-MOOSE-VERIFIED-METHODS`](VERIFIED-METHODS.md)
- [`OMW-MOOSE-VERIFIED-METHODS-AAR-ACCEPTANCE-7`](VERIFIED-METHODS-AAR-ACCEPTANCE-7.md)
- [`OMW-MOOSE-STORAGE-WAREHOUSE-RESOURCE-FOUNDATION`](STORAGE-WAREHOUSE-RESOURCE-FOUNDATION.md)
- [`OMW-MOOSE-ISR-FAC-CAS-AAR`](ISR-FAC-CAS-AAR.md)
- [`OMW-MOOSE-AAR-LRC-TRANSIT`](AAR-LRC-TRANSIT.md)
- [`OMW-MOOSE-GROUND-OPERATIONS`](GROUND-OPERATIONS.md)
- [`OMW-MOOSE-MISSION-DEMAND-RESUPPLY-CAS-SOURCE-REVIEW`](MISSION-DEMAND-RESUPPLY-CAS-SOURCE-REVIEW.md)
- [`OMW-MOOSE-GROUND-RESUPPLY-EXECUTION-SOURCE-REVIEW`](GROUND-RESUPPLY-EXECUTION-SOURCE-REVIEW.md)

## 2. Statusbedeutung

```text
CANDIDATE
PLANNED
IN_USE_PARTIAL
VALIDATED_FOR_DOCUMENTED_SCOPE
VALIDATED_CONFIGURATION_AND_SOURCE_PATH
SOURCE_REVIEWED
INTERNAL_RESTRICTED
REJECTED_FOR_PROJECT_USE
```

`SOURCE_REVIEWED` bedeutet ausschließlich, dass Dokumentation beziehungsweise tatsächlich gepinnter Source für den beschriebenen Pfad geprüft wurden. Der Status enthält **keinen** DCS-Laufzeitnachweis.

## 3. Aktuell besonders relevante Klassen

| Klasse | Projektstatus | Geltungsgrenze |
|---|---|---|
| `AIRBASE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Auflösung, ID, Parkingdump und airfield-spezifische Kalibrierung |
| `AIRWING` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Konstruktion, Stockregistrierung, SQUADRON-Bindung und direkter AUFTRAG-Dispatch; externe OMW-AAR-Pools verwenden bewusst kein AIRWING |
| `SQUADRON` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Foundation-Bestände und post-start Assetbindung |
| `WAREHOUSE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` + `INTERNAL_RESTRICTED` | AirOps-Stock-/Asset-Lifecycle, Ground-Materialisierung und dokumentierte mobile Return-Handoffs praktisch bestätigt; Stage 1A Joyce-Honaker bestätigt `Returned -> AddAsset -> physical cleanup`; private road-aligned Ausnahme bleibt auf dokumentierten Scope begrenzt; SELFPROPELLED ist source-reviewed, aber für kontinuierlichen OMW-Hin-/Rückweg nicht ausgewählt |
| `STORAGE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | CampaignState->DCS-Warehouse Mirror/Telemetry; keine strategische Rückautorität |
| `COHORT` | `VALIDATED_FOR_DOCUMENTED_SCOPE` + `SOURCE_REVIEWED` | AirOps-Lifecycle praktisch bestätigt; Ground-Review bestätigt `AddMissionCapability`, `SetMissionRange`, `CanMission`, `CountAssets`; Stage 1A bestätigt AMMOSUPPLY-Capability; Stage 1B FUELSUPPLY-Fixture scheiterte im Runtime-Scope; Stage 1C `Type.NOTHING` ist source-reviewed/DCS-pending |
| `FLIGHTGROUP` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | AAR FuelLow, Dead/OnAfterDead, GetCoordinate, `AddWaypoint(...)`, `AddMission(...)` und `OnAfterPassingWaypoint(...)`; Acceptance 7 bestätigte FIR -> 60-NM -> AUFTRAG sowie Egress -> External Handoff |
| `COMMANDER` | `VALIDATED_FOR_DOCUMENTED_SCOPE` + `SOURCE_REVIEWED` | dokumentierter COMMANDER-Lifecycle; Ground-Review bestätigt `AddBrigade(...)` und `AddOpsTransport(...)` source-seitig; MissionDemand bleibt OMW-Tasking-Autorität |
| `AUFTRAG` | `VALIDATED_FOR_DOCUMENTED_SCOPE` + `SOURCE_REVIEWED` | Stage 1A `NewAMMOSUPPLY` samt Joyce-Honaker-Joyce-Lifecycle praktisch bestätigt; Stage 1B `NewFUELSUPPLY` ist für den OMW-Meta-RESUPPLY-Scope nach DCS-FAIL geschlossen; Stage 1C `NewNOTHING(Zone)`/`Type.NOTHING`/`SpecialTask.NOTHING` source-reviewed und owner-approved für Acceptance, DCS-pending; keine CampaignState-Autorität |
| `SPAWN` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | area-spezifische AAR-Templates und externe Materialisierung praktisch bestätigt; Ground Stage 1A/1B/1C verwenden keinen direkten SPAWN-Pfad |
| `SCHEDULER` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | allgemeine OMW-Nutzung praktisch bestätigt; Stage 1A verwendet 30-s Return-Settlement und 12-s AddAsset-Verifikation; Stage 1C ergänzt bounded 15-s Zielzonenchecks und 90-s MissionExecute-Grace als Acceptance-only Fail-fast-Diagnostik |
| `USERFLAG` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Warehouse-Acceptance-Readiness-Pfade sowie Ground `OMW_GROUND_READY` Set/Get-Readback und Mission-Editor-Gates in dokumentierten Scopes |
| `GROUP`, `UNIT`, `STATIC`, `ZONE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Wrapper-/Objektauflösung in dokumentierten Scopes; Stage 1A bestätigt ZONE-basierte Destination-/Return-Gates; Stage 1C verwendet dieselbe Zone-Grenze für den neutralen NOTHING-Executor |
| `COORDINATE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | `Get2DDistance(...)`, `GetIntermediateCoordinate(...)` und `HeadingTo(...)` im dokumentierten AirOps-Scope |
| `BRIGADE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` + `INTERNAL_RESTRICTED` | Ground-Acceptance 1–6 und Stage 1A bestätigen Assetpool, Materialisierung, Callback-Lifecycle und Warehouse-Rückgabe; Stage 1C verwendet denselben BRIGADE-Lifecycle mit `Type.NOTHING`, DCS-pending; road-aligned private Warehouse-Spawn-Ausnahme bleibt begrenzt |
| `PLATOON` | `VALIDATED_FOR_DOCUMENTED_SCOPE` + `SOURCE_REVIEWED` | Stage 1A bestätigt Assetselektion/AMMOSUPPLY; Stage 1C verwendet `TPL_BLUE_CONVOY_FUEL_LIGHT_06` mit `AddMissionCapability(AUFTRAG.Type.NOTHING, 100)`, DCS-pending |
| `ARMYGROUP` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Acceptance 1–6 sowie Stage 1A bestätigen mobilen `RTZ(..., OnRoad)`, `Returning`, `Returned` und Warehouse-Handoff; Stage 1C plant denselben physischen ARMYGROUP für NOTHING-Hinweg und RTZ-Rückweg, DCS-pending |
| `OPSGROUP` | `VALIDATED_FOR_DOCUMENTED_SCOPE` + `SOURCE_REVIEWED` | Ground MissionDone-/Return-Pfade praktisch bestätigt; gepinnter Source bestätigt `SpecialTask.NOTHING -> __FullStop(0.1)` und `TaskCancel NOTHING -> TaskDone`; Stage 1C Runtime DCS-pending |
| `OPSTRANSPORT` | `SOURCE_REVIEWED` | Constructor, Cargo/Carrier-Zonen, `AddPathTransport`, Disembark- und Carrier-Verträge geprüft; für Stage 1A und Stage 1C nicht erforderlich; taktischer OMW-Transport benötigt eigenen DCS-Test |
| `AMMOTRUCK` | `SOURCE_REVIEWED` | gepinnter Source und offizieller Demo-Anwendungsfall für automatische Artillerie-Rearm-Versorgung geprüft; `reloads` ist Rearm-Zykluszahl, keine CampaignState-Menge; kein OMW-AMMOTRUCK-Runtime-PASS |
| `ARTY` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Ground-Ammo-Rearm-Acceptance 1 bestätigt Bostick-L118-Rearm-Pfad im dokumentierten Scope |
| `CTLD`, `CSAR`, `AICSAR` | `PLANNED` / teilweise verwendet | separate Acceptance erforderlich |
| `INTEL` | `PLANNED` | taktisches Lagebild; Laufzeitnachweis offen |
| `INTEL_DLINK` | `CANDIDATE` | Aggregation getrennter Netze; Performance offen |
| `PLAYERRECCE` | `CANDIDATE` | spielergeführte Aufklärung; Multiplayerprüfung offen |
| `TARS` | `CANDIDATE` | verzögerte Foto-/IMINT-Aufklärung; Verfügbarkeit offen |
| `DETECTION_*` | `PLANNED` | Spezialfälle; kein paralleles strategisches Lagebild neben `INTEL` |
| `Core.Astar`, `PATHLINE`, `MOVEMENT` | `PLANNED` | Routing und Bewegungsbegrenzung |
| `_DATABASE` | `INTERNAL_RESTRICTED` | nur Diagnose/Validierung; road-aligned Ground-Adapter greift ausschließlich im bereits owner-approved Scope auf den gepinnten Warehouse-Spawnvertrag zu |
| `CHIEF` | `REJECTED_FOR_PROJECT_USE` | aktuelle Produktionsarchitektur `NOT_USED` |

## 4. ARMY Ground Foundation – bestehender Nachweisrahmen

Gepinnter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Die Ground-Acceptance-Reihe bestätigte schrittweise BRIGADE/PLATOON/ARMYGROUP, mobilen RTZ, Returned und Warehouse-Handoff. Die private road-aligned Warehouse-Spawn-Ausnahme bleibt auf den dokumentierten owner-approved Scope begrenzt.

## 5. AAR – gepinnter und Acceptance-7-validierter MOOSE-Scope

```text
Accepted source commit: 7d55a1383cbf3f52ea776d7354b37dbe5a920466
Builder/Test-ID: AAR-PRODUCTION-FINAL-ACCEPTANCE-7
Mission artifact: OMW_Template_v10_AirOps_rdy(5).miz
Mission SHA-256: 16d0a9b26a648c2dbcbd727b41afc93a28648620f8e2f8c357a770751e48cca5
Bundle SHA-256: 3338d0baa67593be6bff9c22b3ed72b3a8e837cd00820d060eefe920faf91ee2
DCS: 2.9.28.26385 MT
Result: PASS
```

Der AAR-Routing-/Fuel-/Lifecycle-PASS wird nicht auf Ground-OPS übertragen.

## 6. Architekturgrenze

```text
CampaignState = strategic authority
MOOSE BRIGADE / PLATOON / WAREHOUSE / AUFTRAG = operational execution
DCS GROUP / UNIT / STATIC = physical representation
```

Ein Klassenstatus wird nur angehoben, wenn MOOSE-Version/Commit, OMW-Source, Mission, Hashes, beobachtetes Verhalten und Einschränkungen dokumentiert sind.

## Addendum 2026-08-21 – Ground Ammo Rearm

```text
AMMOTRUCK = SOURCE_REVIEWED
ARTY      = VALIDATED_FOR_DOCUMENTED_SCOPE
```

`ARTY` wurde im dokumentierten Bostick-Acceptance-Scope praktisch bestätigt. `AMMOTRUCK` bleibt source-reviewed.

## Addendum 2026-08-19 – `WAREHOUSE` / `_DATABASE` road-aligned Ausnahme

```text
Owner approval: 2026-08-19
Pinned MOOSE: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Internal symbols: WAREHOUSE:_SpawnAssetGroundNaval(...), WAREHOUSE:_SpawnAssetPrepareTemplate(...), _DATABASE:Spawn(template)
Scope: dokumentierte Ground-Warehouse-Materialisierung
Status: INTERNAL_RESTRICTED / OWNER_APPROVED
```

Der Adapter ändert ausschließlich vorbereitete Spawn-Geometrie. Assetreservation, Queue, callbacks und MOOSE-Lifecycle bleiben Framework-owned.

## Addendum 2026-08-22 – Stage 1A Ground AMMO RESUPPLY

```text
Branch: agent/automatic-response-orchestration
Acceptance source/build commit: 2d72bcdfc113342a2180b6cd9c84486da790052c
BuilderVersion: GROUND-AMMO-RESUPPLY-ACCEPTANCE-1-5
Bundle SHA-256: 752B3E6F0B77D1B62C750421DDE36202C81B98632FEFBF6A273F913202DF8339
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Executed MIZ: OMW_Template_v18.miz
MIZ SHA-256: 2FDF31A2E07409CF392D45BFF5FC69750958C670AE3E12FF28D0B4FD8AECC90D
Result: PASS
```

Praktisch bestätigt: `NewAMMOSUPPLY`, OnRoad 27 kt, fail-closed delivery, 30-s MissionDone-Settlement, derselbe ARMYGROUP RTZ und `Returned -> AddAsset`.

## Addendum 2026-08-22 – Stage 1B Ground FUELSUPPLY FAIL

```text
Branch: agent/automatic-response-orchestration
BuilderVersion: GROUND-FUEL-RESUPPLY-ACCEPTANCE-1-1
Bundle SHA-256: A2C71E86244A2E6869E8A0A3D7384D917875064B11102CDA410A7DBD9C1C6922
Physical fixture: TPL_BLUE_CONVOY_FUEL_LIGHT_06
DCS: 2.9.28.26385 MT
Result: FAIL / OUTBOUND_TIMEOUT
missionExecuteCount=0
missionDoneCount=0
```

`NewFUELSUPPLY` wird daher für den abstrakten OMW-Meta-RESUPPLY-Executor nicht weiterverwendet.

## Addendum 2026-08-22 – Stage 1C AUFTRAG NOTHING source review

Owner-approved Acceptance-Vertrag:

```text
CampaignState meta resource
-> MissionDemand RESUPPLY
-> BRIGADE / PLATOON / ARMYGROUP
-> AUFTRAG:NewNOTHING(destination ACCESS)
-> destination proof
-> MarkDelivered / MissionDemand SUCCESS
-> __Cancel
-> MissionDone
-> 30 s settlement
-> same ARMYGROUP RTZ origin
-> Returned -> AddAsset
```

Source-reviewed:

```text
AUFTRAG:NewNOTHING(RelaxZone)
AUFTRAG.Type.NOTHING
AUFTRAG.SpecialTask.NOTHING
PLATOON:AddMissionCapability(AUFTRAG.Type.NOTHING, ...)
OPSGROUP NOTHING execution -> __FullStop(0.1)
TaskCancel NOTHING -> TaskDone
```

Acceptance-only Fail-fast:

```text
OutboundTimeoutSec=600
DestinationCheckIntervalSec=15
DestinationExecutionGraceSec=90
```

Status: `SOURCE_REVIEWED / OWNER_APPROVED_FOR_ACCEPTANCE / DCS_PENDING`.
