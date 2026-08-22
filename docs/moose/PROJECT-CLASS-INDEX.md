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
source_branch: agent/army-ground-foundation-reconciliation
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
| `WAREHOUSE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` + `INTERNAL_RESTRICTED` | AirOps-Stock-/Asset-Lifecycle, Ground-Materialisierung und dokumentierte mobile Return-Handoffs praktisch bestätigt; Stage-1A Joyce-Honaker bestätigt `Returned -> AddAsset -> physical cleanup`; private road-aligned Ausnahme bleibt auf dokumentierten Scope begrenzt |
| `STORAGE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | CampaignState->DCS-Warehouse Mirror/Telemetry; keine strategische Rückautorität |
| `COHORT` | `VALIDATED_FOR_DOCUMENTED_SCOPE` + `SOURCE_REVIEWED` | AirOps-Lifecycle praktisch bestätigt; Ground-Review bestätigt `AddMissionCapability`, `SetMissionRange`, `CanMission`, `CountAssets`; Stage-1A bestätigt AMMOSUPPLY-Capability, Stage-1B FUELSUPPLY-Capability ist source-reviewed/DCS-pending |
| `FLIGHTGROUP` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | AAR FuelLow, Dead/OnAfterDead, GetCoordinate, `AddWaypoint(...)`, `AddMission(...)` und `OnAfterPassingWaypoint(...)`; Acceptance 7 bestätigte FIR -> 60-NM -> AUFTRAG sowie Egress -> External Handoff |
| `COMMANDER` | `VALIDATED_FOR_DOCUMENTED_SCOPE` + `SOURCE_REVIEWED` | dokumentierter COMMANDER-Lifecycle; Ground-Review bestätigt `AddBrigade(...)` und `AddOpsTransport(...)` source-seitig; MissionDemand bleibt OMW-Tasking-Autorität |
| `AUFTRAG` | `VALIDATED_FOR_DOCUMENTED_SCOPE` + `SOURCE_REVIEWED` | AAR-Methoden, Ground-Acceptance-1 bis -6 sowie Stage-1A `NewAMMOSUPPLY`, 27-kt OnRoad execution, `SetReturnToLegion(false)` und Joyce-Honaker-Joyce praktisch bestätigt; `NewFUELSUPPLY(Zone)` und `Type.FUELSUPPLY` sind für Stage 1B source-reviewed/DCS-pending; keine CampaignState-Autorität |
| `SPAWN` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | area-spezifische AAR-Templates und externe Materialisierung praktisch bestätigt; Ground Stage-1A/1B verwenden keinen direkten SPAWN-Pfad |
| `SCHEDULER` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | allgemeine OMW-Nutzung praktisch bestätigt; Ground Stage-1A verwendet One-shot-Koordination für 30-s Return-Settlement und 12-s AddAsset-Verifikation; Stage 1B übernimmt diese Koordination testweise, kein hochfrequentes Polling |
| `USERFLAG` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Warehouse-Acceptance-Readiness-Pfade sowie Ground `OMW_GROUND_READY` Set/Get-Readback und Mission-Editor-Gates in dokumentierten Scopes |
| `GROUP`, `UNIT`, `STATIC`, `ZONE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Wrapper-/Objektauflösung in dokumentierten Scopes; Ground-Acceptance-6 bestätigt GetSize, GetUnits, test-only Destroy(false) und SetLife(50); Stage-1A bestätigt ZONE-basierte Destination-/Return-Gates |
| `COORDINATE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | `Get2DDistance(...)`, `GetIntermediateCoordinate(...)` und `HeadingTo(...)` im dokumentierten AirOps-Scope |
| `BRIGADE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` + `INTERNAL_RESTRICTED` | Ground-Acceptance-1 bis -6 sowie Stage-1A bestätigen Assetpool, LIGHT_06-Materialisierung, AMMOSUPPLY-Dispatch, Callback-Lifecycle und Warehouse-Rückgabe; Stage 1B Fuel-Light-Dispatch ist staged/DCS-pending; road-aligned private Warehouse-Spawn-Ausnahme bleibt begrenzt |
| `PLATOON` | `VALIDATED_FOR_DOCUMENTED_SCOPE` + `SOURCE_REVIEWED` | Ground-Acceptance-1 bis -6 sowie Stage-1A bestätigen Assetselektion, `TPL_BLUE_CONVOY_LIGHT_06`, AMMOSUPPLY-Capability und Rückgabe; Stage 1B `TPL_BLUE_CONVOY_FUEL_LIGHT_06`/FUELSUPPLY-Capability ist source-reviewed/DCS-pending |
| `ARMYGROUP` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Acceptance 1–6 sowie Stage-1A bestätigen MissionDone-Persistenz, mobilen `RTZ(..., OnRoad)`, `Returning`, `Returned` und Warehouse-Handoff; Stage 1B nutzt denselben öffentlichen Return-Lifecycle, dessen Fuel-spezifische Kombination DCS-pending ist; immobiler Teleportpfad bleibt ausgeschlossen |
| `OPSGROUP` | `VALIDATED_FOR_DOCUMENTED_SCOPE` + `SOURCE_REVIEWED` | AirOps-Methoden sowie Ground-MissionDone-/Return-Pfade praktisch bestätigt; FUELSUPPLY SpecialTask/TaskCancel für Stage 1B source-reviewed; Cargo-Pfade bleiben source-reviewed |
| `OPSTRANSPORT` | `SOURCE_REVIEWED` | Constructor, Cargo/Carrier-Zonen, `AddPathTransport`, Disembark- und Carrier-Verträge geprüft; Stage-1A/1B benötigen OPSTRANSPORT nicht; taktischer OMW-Transport benötigt eigenen DCS-Test |
| `AMMOTRUCK` | `SOURCE_REVIEWED` | gepinnter Source und offizieller Demo-Anwendungsfall für automatische Artillerie-Rearm-Versorgung geprüft; `reloads` ist Rearm-Zykluszahl, keine CampaignState-Menge; kein OMW-AMMOTRUCK-Runtime-PASS |
| `ARTY` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Ground-Ammo-Rearm-Acceptance-1 bestätigt den Bostick-Fixed-Battery-Pfad mit `New`, `AssignTargetCoord`, `GetAmmo`, `SetRearmingGroup`, `SetRearmingGroupOnRoad`, `Rearm` sowie CeaseFire/BeforeRearm/Rearmed-Callbacks; keine pauschale Validierung anderer Batterien, Supply-Typen oder MOOSE-Versionen |
| `CTLD`, `CSAR`, `AICSAR` | `PLANNED` / teilweise verwendet | separate Acceptance erforderlich |
| `INTEL` | `PLANNED` | taktisches Lagebild; Laufzeitnachweis offen |
| `INTEL_DLINK` | `CANDIDATE` | Aggregation getrennter Netze; Performance offen |
| `PLAYERRECCE` | `CANDIDATE` | spielergeführte Aufklärung; Multiplayerprüfung offen |
| `TARS` | `CANDIDATE` | verzögerte Foto-/IMINT-Aufklärung; Verfügbarkeit offen |
| `DETECTION_*` | `PLANNED` | Spezialfälle; kein paralleles strategisches Lagebild neben `INTEL` |
| `Core.Astar`, `PATHLINE`, `MOVEMENT` | `PLANNED` | Routing und Bewegungsbegrenzung |
| `_DATABASE` | `INTERNAL_RESTRICTED` | nur Diagnose/Validierung; aktueller AAR- und Ground-RESUPPLY-Pfad verwendet `_DATABASE` nicht direkt |
| `CHIEF` | `REJECTED_FOR_PROJECT_USE` | aktuelle Produktionsarchitektur `NOT_USED` |

## 4. ARMY Ground Foundation – Source-Review und Acceptance-1-Staging 18.08.2026

### 4.1 Geprüfter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Owner-erstellte Acceptance-1-Mission, read-only geprüft:

```text
Mission artifact: OMW_Template_v13_ground_test.miz
Mission SHA-256: 6d12a55affc971de1de4d5e463c956fcb2e08a0d2de478ff13419747a825e7e8
internal mission SHA-256: 22d13cb7b0da0a6fb9ddc02bf9b99c4da50d2c96b31bdc6a353616a4188c6b80
embedded Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

### 4.2 Source-verifizierte Ground-Pfade

```text
COMMANDER:AddBrigade(...)
COMMANDER:AddOpsTransport(...)
BRIGADE:New(...)
BRIGADE:AddPlatoon(...)
BRIGADE:AddAssetToPlatoon(...)
WAREHOUSE:SetSpawnZone(...)
PLATOON:New(...)
COHORT:AddMissionCapability(...)
COHORT:SetMissionRange(...)
COHORT:CanMission(...)
COHORT:CountAssets(...)
AUFTRAG:NewPATROLZONE(...)
AUFTRAG:SetReturnToLegion(false)
AUFTRAG:__Cancel(...)
ARMYGROUP mission / RTZ / Returned paths
OPSGROUP:onafterMissionDone(...) legionReturn=false hold-in-place path
OPSTRANSPORT constructors/path/disembark methods
```

Die späteren Acceptance-Addenda sind für aktuelle Runtime-Aussagen maßgeblich.

### 4.3 Official example review

Die offiziellen MOOSE-Mission-Repositories wurden für BRIGADE, ARMYGROUP, OPSTRANSPORT und PLATOON durchsucht. Kein direkter aktueller Klassenverwendungsbeleg für die komplette OMW-Kombination wurde gefunden. `WHS-020 - Self Propelled Ground Troops` verwendet WAREHOUSE direkt und ist kein Acceptance-Beweis für `BRIGADE -> PLATOON -> ARMYGROUP`.

## 5. AAR – gepinnter und Acceptance-7-validierter MOOSE-Scope

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Acceptance-7-Provenienz:

```text
Accepted source commit: 7d55a1383cbf3f52ea776d7354b37dbe5a920466
Builder/Test-ID: AAR-PRODUCTION-FINAL-ACCEPTANCE-7
Mission artifact: OMW_Template_v10_AirOps_rdy(5).miz
Mission SHA-256: 16d0a9b26a648c2dbcbd727b41afc93a28648620f8e2f8c357a770751e48cca5
Bundle SHA-256: 3338d0baa67593be6bff9c22b3ed72b3a8e837cd00820d060eefe920faf91ee2
DCS: 2.9.28.26385 MT
Result: PASS
```

Die vollständigen AAR-Verträge und Accepted-Provenienz bleiben in den zuständigen AAR-Dokumenten. Diese Ground-Aktualisierung ändert daran nichts.

## 6. Architekturgrenze

```text
CampaignState = strategic authority
MOOSE BRIGADE / PLATOON / WAREHOUSE = operational mirror/selection
DCS GROUP / UNIT / STATIC = physical representation
```

## 7. Nachweisregel

Ein Klassenstatus wird nur angehoben, wenn MOOSE-Version/Commit, OMW-Source, Mission, Hashes, beobachtetes Verhalten und Einschränkungen dokumentiert sind. `VALIDATED_FOR_DOCUMENTED_SCOPE` gilt ausschließlich für die jeweils explizit dokumentierte Provenienz und Wirkung.

## Addendum 2026-08-21 – Ground Ammo Rearm Source Review

```text
AMMOTRUCK = SOURCE_REVIEWED
ARTY      = SOURCE_REVIEWED
```

`AMMOTRUCK` besitzt im gepinnten Source automatische Low-Ammo-Erkennung, Truck-Zuweisung, Anfahrt, Unloading sowie Return/Home-FSM-Pfade. Das offizielle MOOSE-Beispiel unter `Functional/AmmoTruck` bestätigt den vorgesehenen Artillerie-Rearm-Anwendungsfall. `reloads` ist eine Zahl von Rearm-Vorgängen und keine Granaten- oder CampaignState-Paketmenge.

## Addendum 2026-08-19 – `WAREHOUSE` / `_DATABASE` interne Acceptance-3-2-Ausnahme

~~~text
Owner approval: 2026-08-19
Pinned MOOSE: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Internal symbols: WAREHOUSE:_SpawnAssetGroundNaval(...), WAREHOUSE:_SpawnAssetPrepareTemplate(...), _DATABASE:Spawn(template)
Scope: sechs Acceptance-3-BRIGADE-Instanzen
Status: INTERNAL_RESTRICTED / SOURCE_REVIEWED_EXCEPTION_APPROVED_DCS_PENDING
~~~

Der freigegebene Adapter übernimmt ausschließlich road-aligned Positionen/Headings in die vom Warehouse bereitete Spawn-Templatekopie; Assetreservation und MOOSE-Lifecycle bleiben erhalten.

## Addendum 2026-08-19 – Acceptance 4 return-handoff scope

| Klasse | Status | Verwendung/Grenze |
|---|---|---|
| `ARMYGROUP` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Acceptance 4-2 bestätigt den öffentlichen mobilen `RTZ(existing Fenty ACCESS zone, OnRoad)`-Pfad einschließlich `Returning` und `Returned`; kein Teleportpfad verwendet |
| `WAREHOUSE` / `LEGION` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Acceptance 4-2 bestätigt `Returned -> __AddAsset(10) -> AddAsset -> physical group removal` für Fenty; operative Rückgabe ist keine strategische Ressourcenbuchung |

## Addendum 2026-08-22 – Ground Ammo Rearm Acceptance 1

```text
Branch: agent/ground-ammo-rearm-integration
Acceptance source/build commit: 213119ca03a6aeae529d4291b4bbe174ac0995c2
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
Executed MIZ: OMW_Template_v15.miz
MIZ SHA-256: A2AF2BD5FA9792DEF422F3B47755894E8F3220453F31F63F1594CCD61E9AF1B4
Result: PASS
```

Praktisch bestätigt wurden ARTY fixed-battery lifecycle at Bostick, CHAP_M1083 materialization, exact-once local CampaignState ammo consumption and ARTY Rearm -> Rearmed completion for that scope.

## Addendum 2026-08-22 – Stage 1A Ground AMMO RESUPPLY Acceptance

```text
Branch: agent/automatic-response-orchestration
Acceptance source/build commit: 2d72bcdfc113342a2180b6cd9c84486da790052c
BuilderVersion: GROUND-AMMO-RESUPPLY-ACCEPTANCE-1-5
Acceptance bundle SHA-256: 752B3E6F0B77D1B62C750421DDE36202C81B98632FEFBF6A273F913202DF8339
DCS: 2.9.28.26385 MT
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
Executed MIZ: OMW_Template_v18.miz
MIZ SHA-256: 2FDF31A2E07409CF392D45BFF5FC69750958C670AE3E12FF28D0B4FD8AECC90D
internal mission SHA-256: 38B207278365CD977E74FF3C9000C6A7C5B13EEE3E5B1BB154F1775055D02AF6
Result: PASS
```

Für genau diesen Provenienzsatz praktisch bestätigt:

```text
BRIGADE -> PLATOON -> ARMYGROUP protected LIGHT_06 materialization
AUFTRAG:NewAMMOSUPPLY(destinationZone)
AUFTRAG:SetMissionSpeed(27)
AUFTRAG:SetFormation(OnRoad)
AUFTRAG:SetReturnToLegion(false)
CampaignState fail-closed delivery settlement after destination-zone proof
30 s post-MissionDone settlement window
same ARMYGROUP RTZ to Joyce ACCESS / OnRoad
Returned -> LEGION/Warehouse AddAsset -> physical cleanup
```

## Addendum 2026-08-22 – Stage 1B Ground FUEL RESUPPLY source review

```text
Branch: agent/automatic-response-orchestration
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
Owner mission fixture: OMW_Template_v19.miz
MIZ SHA-256: B89DBE7B755D25B43384B158F3D25921C70847820F71B837F12F86C5D863A8A6
internal mission SHA-256: 6B15369398C3B5989B676DB473127489C236F5948737AA3242FDB182FD515B95
Runtime status: DCS_PENDING
```

Source-reviewed Stage-1B methods/classes:

```text
AUFTRAG:NewFUELSUPPLY(Zone)
AUFTRAG.Type.FUELSUPPLY
AUFTRAG.SpecialTask.FUELSUPPLY
PLATOON:AddMissionCapability(FUELSUPPLY, ...)
BRIGADE / PLATOON / ARMYGROUP FUEL fixture staging
OPSGROUP FUELSUPPLY special-task and TaskCancel handling
```

Selected physical fixture:

```text
TPL_BLUE_CONVOY_FUEL_LIGHT_06
lateActivation=true
6 vehicles = 2 x M978 HEMTT Tanker + 4 escort/security vehicles
```

The current online MOOSE documentation explicitly lists `AUFTRAG:NewFUELSUPPLY(Zone)` as a Ground FUEL SUPPLY mission. Official `MOOSE_MISSIONS` and `MOOSE_MISSIONS_UNPACKED` were searched; no dedicated current `NewFUELSUPPLY` demo was found. No runtime validation is claimed before the dedicated DCS acceptance.
