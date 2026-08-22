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
| `COHORT` | `VALIDATED_FOR_DOCUMENTED_SCOPE` + `SOURCE_REVIEWED` | AirOps-Lifecycle praktisch bestätigt; Ground-Review bestätigt `AddMissionCapability`, `SetMissionRange`, `CanMission`, `CountAssets`; Stage-1A bestätigt AMMOSUPPLY-Capability für den LIGHT_06-PLATOON; Stage-1B FUELSUPPLY-Capability ist source-reviewed/DCS-pending |
| `FLIGHTGROUP` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | AAR FuelLow, Dead/OnAfterDead, GetCoordinate, `AddWaypoint(...)`, `AddMission(...)` und `OnAfterPassingWaypoint(...)`; Acceptance 7 bestätigte FIR -> 60-NM -> AUFTRAG sowie Egress -> External Handoff |
| `COMMANDER` | `VALIDATED_FOR_DOCUMENTED_SCOPE` + `SOURCE_REVIEWED` | dokumentierter COMMANDER-Lifecycle; Ground-Review bestätigt `AddBrigade(...)` und `AddOpsTransport(...)` source-seitig; MissionDemand bleibt OMW-Tasking-Autorität |
| `AUFTRAG` | `VALIDATED_FOR_DOCUMENTED_SCOPE` + `SOURCE_REVIEWED` | AAR-Methoden, Ground-Acceptance-1 bis -6 sowie Stage-1A `NewAMMOSUPPLY`, 27-kt OnRoad execution, `SetReturnToLegion(false)` und erfolgreicher Joyce-Honaker-Joyce-Lifecycle praktisch bestätigt; `NewFUELSUPPLY(Zone)`/`Type.FUELSUPPLY` für Stage 1B source-reviewed/DCS-pending; keine CampaignState-Autorität |
| `SPAWN` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | area-spezifische AAR-Templates und externe Materialisierung praktisch bestätigt; Ground Stage-1A/1B verwenden keinen direkten SPAWN-Pfad |
| `SCHEDULER` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | allgemeine OMW-Nutzung praktisch bestätigt; Ground Stage-1A verwendet One-shot-Koordination für 30-s Return-Settlement und 12-s AddAsset-Verifikation; Stage 1B übernimmt diese Lifecycle-Koordination testweise, kein hochfrequentes Polling |
| `USERFLAG` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Warehouse-Acceptance-Readiness-Pfade sowie Ground `OMW_GROUND_READY` Set/Get-Readback und Mission-Editor-Gates in dokumentierten Scopes |
| `GROUP`, `UNIT`, `STATIC`, `ZONE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Wrapper-/Objektauflösung in dokumentierten Scopes; Ground-Acceptance-6 bestätigt GetSize, GetUnits, test-only Destroy(false) und SetLife(50); Stage-1A bestätigt ZONE-basierte Destination-/Return-Gates |
| `COORDINATE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | `Get2DDistance(...)`, `GetIntermediateCoordinate(...)` und `HeadingTo(...)` im dokumentierten AirOps-Scope |
| `BRIGADE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` + `INTERNAL_RESTRICTED` | Ground-Acceptance-1 bis -6 sowie Stage-1A bestätigen Assetpool, LIGHT_06-Materialisierung, AMMOSUPPLY-Dispatch, Callback-Lifecycle und Warehouse-Rückgabe; Stage-1B Fuel-Light-Dispatch ist staged/DCS-pending; road-aligned private Warehouse-Spawn-Ausnahme bleibt begrenzt |
| `PLATOON` | `VALIDATED_FOR_DOCUMENTED_SCOPE` + `SOURCE_REVIEWED` | Ground-Acceptance-1 bis -6 sowie Stage-1A bestätigen Assetselektion, `TPL_BLUE_CONVOY_LIGHT_06`, AMMOSUPPLY-Capability und Rückgabe im dokumentierten Scope; Stage-1B `TPL_BLUE_CONVOY_FUEL_LIGHT_06`/FUELSUPPLY-Capability source-reviewed/DCS-pending |
| `ARMYGROUP` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Acceptance 1–6 sowie Stage-1A bestätigen MissionDone-Persistenz, mobilen `RTZ(..., OnRoad)`, `Returning`, `Returned` und Warehouse-Handoff; Stage-1A bestätigt denselben physischen LIGHT_06-Hin-/Rückweg nach 30-s Settlement; Stage-1B Fuel-Kombination DCS-pending; immobiler Teleportpfad bleibt ausgeschlossen |
| `OPSGROUP` | `VALIDATED_FOR_DOCUMENTED_SCOPE` + `SOURCE_REVIEWED` | AirOps-Methoden sowie Ground-MissionDone-/Return-Pfade praktisch bestätigt; Stage-1B FUELSUPPLY SpecialTask/TaskCancel source-reviewed; Cargo-Pfade bleiben source-reviewed |
| `OPSTRANSPORT` | `SOURCE_REVIEWED` | Constructor, Cargo/Carrier-Zonen, `AddPathTransport`, Disembark- und Carrier-Verträge geprüft; Stage-1A AMMO und Stage-1B FUEL benötigen OPSTRANSPORT nicht; taktischer OMW-Transport benötigt eigenen DCS-Test |
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
embedded Moose.lua SHA-256: e3b750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
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

Acceptance-1-Harness und Builder sind auf dem Branch vorhanden:

```text
mission/tests/army-ground-foundation/src/01-army-ground-acceptance-1.lua
tools/build-army-ground-acceptance-1.ps1
BuilderVersion: ARMY-GROUND-ACCEPTANCE-1-1
```

Der Harness plant genau einen Joyce-BRIGADE-/PLATOON-PATROLZONE-Pfad und prüft `MissionDone -> physical stay -> same ARMYGROUP follow-up` sowie Dublettenfreiheit. Das ist **STAGED / SOURCE_REVIEWED**, kein Runtime-PASS.

Wichtige historische Grenzen dieses frühen Staging-Abschnitts werden durch spätere Acceptance-Ergebnisse teilweise superseded; für aktuelle Runtime-Aussagen sind die späteren Addenda maßgeblich.

### 4.3 Official example review

Die offiziellen MOOSE-Mission-Repositories wurden für BRIGADE, ARMYGROUP, OPSTRANSPORT und PLATOON durchsucht. Kein direkter aktueller Klassenverwendungsbeleg für die komplette OMW-Kombination wurde gefunden. `WHS-020 - Self Propelled Ground Troops` verwendet WAREHOUSE direkt und ist kein Acceptance-Beweis für `BRIGADE -> PLATOON -> ARMYGROUP`.

Details:

- [`OMW-MOOSE-GROUND-OPERATIONS`](GROUND-OPERATIONS.md)
- [`Ground Acceptance 1`](../../mission/tests/army-ground-foundation/ACCEPTANCE-1.md)

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

Für den dokumentierten AAR-Scope sind source-geprüft und, soweit unten genannt, praktisch bestätigt:

```text
AUFTRAG:NewTANKER(...)
AUFTRAG:SetMissionAltitude(...)
AUFTRAG:SetMissionEgressCoord(...)
AUFTRAG:Cancel()

SPAWN:InitCallSign(...)
SPAWN:InitHeading(...)
SPAWN:InitSpeedKnots(...)
SPAWN:SpawnFromCoordinate(...)
UNIT:GetSTN()
UNIT:Explode(...) [test-only]
GROUP:GetCallsign()

FLIGHTGROUP:New(...)
FLIGHTGROUP:GetFuelMin()
FLIGHTGROUP:SetFuelLowThreshold(...)
FLIGHTGROUP:SetFuelLowRTB(false)
FLIGHTGROUP FuelLow callback
FLIGHTGROUP Dead/OnAfterDead FSM event
FLIGHTGROUP:GetCoordinate()
FLIGHTGROUP:AddWaypoint(...)
FLIGHTGROUP:AddMission(...)
FLIGHTGROUP/OPSGROUP PassingWaypoint FSM event
FLIGHTGROUP OnAfterPassingWaypoint callback override

OPSGROUP:SwitchRadio(...)
OPSGROUP:TurnOffRadio()
OPSGROUP:SwitchTACAN(...)
OPSGROUP:TurnOffTACAN()
OPSGROUP:Despawn(...)

COORDINATE:GetIntermediateCoordinate(...)
COORDINATE:Get2DDistance(...)
COORDINATE:HeadingTo(...)
SCHEDULER:New(...)

UNIT:GetFuel()
UNIT:GetCurrentFuelKgs()
UNIT:GetFuelMassMax()
```

`FLIGHTGROUP:AddWaypoint(...)` plus `OnAfterPassingWaypoint(...)` ist für die dokumentierte AAR-Acceptance-7-Provenienz praktisch bestätigt. Der dortige Routing-/Fuel-/Lifecycle-PASS wird nicht auf Ground-OPS übertragen.

Details:

- [`OMW-MOOSE-AAR-LRC-TRANSIT`](AAR-LRC-TRANSIT.md)
- [`OMW-MOOSE-VERIFIED-METHODS-AAR-ACCEPTANCE-7`](VERIFIED-METHODS-AAR-ACCEPTANCE-7.md)
- [`AAR Production Final Acceptance 7`](../../mission/tests/aar-production-integration/ACCEPTANCE-7.md)

## 6. AAR-Produktionsscope

```text
STANDARD / kontinuierlich:
NELSON FAST
PATTY SLOW
MILHOUSE SLOW
KRUSTY SLOW

RESERVE / MissionDemand:
LISA FAST
MOE FAST
```

Die vollständigen AAR-Verträge und Accepted-Provenienz bleiben in den zuständigen AAR-Dokumenten. Diese Ground-Aktualisierung ändert daran nichts.

## 7. Architekturgrenze

Die externen AAR-Pools und die Ground-OPS-Domäne bleiben getrennte Ressourcen-/Materialisierungsmodelle. Für Ground gilt insbesondere:

```text
CampaignState = strategic authority
MOOSE BRIGADE / PLATOON / WAREHOUSE = operational mirror/selection
DCS GROUP / UNIT / STATIC = physical representation
```

## 8. Nachweisregel

Ein Klassenstatus wird nur angehoben, wenn MOOSE-Version/Commit, OMW-Source, Mission, Hashes, beobachtetes Verhalten und Einschränkungen dokumentiert sind.

`VALIDATED_FOR_DOCUMENTED_SCOPE` gilt ausschließlich für die jeweils explizit dokumentierte Provenienz und Wirkung.

## Addendum 2026-08-21 – Ground Ammo Rearm Source Review

```text
AMMOTRUCK = SOURCE_REVIEWED
ARTY      = SOURCE_REVIEWED
```

`AMMOTRUCK` besitzt im gepinnten Source automatische Low-Ammo-Erkennung, Truck-Zuweisung, Anfahrt, Unloading sowie Return/Home-FSM-Pfade. Das offizielle MOOSE-Beispiel unter `Functional/AmmoTruck` bestätigt den vorgesehenen Artillerie-Rearm-Anwendungsfall. `reloads` ist eine Zahl von Rearm-Vorgängen und keine Granaten- oder CampaignState-Paketmenge.

`TruckReturning` wird erst ausgelöst, nachdem die Mindest-Unloadzeit abgelaufen ist und der Munitionsstatus des Empfängers wieder oberhalb `ammothreshold` liegt. Dieser FSM-Pfad ist daher ein geeigneter späterer OMW-Delivery-Quittierungskandidat, beweist aber **keinen Vollrearm**.

`ARTY` besitzt den detaillierteren Batterie-Rearm-Pfad einschließlich Shell-Type-Auswertung und Vollrearm-Prüfung. Für den ersten OMW-Ammo-Service bleibt `AMMOTRUCK` der kleinere Kandidat; `ARTY` wird nicht ausschließlich zur Logistik eingeführt, wenn es die Feuerunterstützungsgruppe nicht ohnehin operativ verwaltet.

Offene historische Grenze vor dem späteren Runtime-Nachweis:

```text
known MOOSE/DCS supply example: M-939 (BLUE)
current OMW generic logistics template: M1083 family
```

Details: [`OMW-MOOSE-MISSION-DEMAND-RESUPPLY-CAS-SOURCE-REVIEW`](MISSION-DEMAND-RESUPPLY-CAS-SOURCE-REVIEW.md), Abschnitt 16.

## Addendum 2026-08-19 – `WAREHOUSE` / `_DATABASE` interne Acceptance-3-2-Ausnahme

~~~text
Owner approval: 2026-08-19
Pinned MOOSE: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Internal symbols: WAREHOUSE:_SpawnAssetGroundNaval(...), WAREHOUSE:_SpawnAssetPrepareTemplate(...), _DATABASE:Spawn(template)
Scope: sechs Acceptance-3-BRIGADE-Instanzen
Status: INTERNAL_RESTRICTED / SOURCE_REVIEWED_EXCEPTION_APPROVED_DCS_PENDING
~~~

`WAREHOUSE:SetSpawnZone(...)` genügt nicht für exakt road-aligned Einzelaufstellung. Der freigegebene Adapter übernimmt ausschließlich TM01M-Positionen/Headings in die vom Warehouse bereitete Spawn-Templatekopie. Assetreservation, Queue, `__AssetSpawned`, `OnAfterAssetSpawned`, `OnAfterArmyOnMission` und `ARMYGROUP`-/`AUFTRAG`-Lifecycle dürfen dadurch nicht umgangen werden.

## Addendum 2026-08-19 – Acceptance 4 return-handoff scope

| Klasse | Status | Verwendung/Grenze |
|---|---|---|
| `ARMYGROUP` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Acceptance 4-2 bestätigt den öffentlichen mobilen `RTZ(existing Fenty ACCESS zone, OnRoad)`-Pfad einschließlich `Returning` und `Returned`; kein Teleportpfad verwendet |
| `WAREHOUSE` / `LEGION` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Acceptance 4-2 bestätigt `Returned -> __AddAsset(10) -> AddAsset -> physical group removal` für Fenty; operative Rückgabe ist keine strategische Ressourcenbuchung |

## Addendum 2026-08-22 – Ground Ammo Rearm Acceptance 1

Dieses Addendum hebt ausschließlich den im folgenden Provenienzsatz praktisch bestätigten Scope an. `AMMOTRUCK` bleibt davon unberührt `SOURCE_REVIEWED`.

```text
Branch: agent/ground-ammo-rearm-integration
Acceptance source/build commit: 213119ca03a6aeae529d4291b4bbe174ac0995c2
Ground BASE-3 source/build commit: 04674c29061c6a70f54b537598442857448441b6
Warehouse BASE-3 build commit: 7da56fdfb45888e7f88d4ea5c3b0fa691f2b0423
Builder/Test-ID: GROUND-AMMO-REARM-ACCEPTANCE-1
DCS: 2.9.28.26385 MT
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
Executed MIZ: OMW_Template_v15.miz
MIZ SHA-256: A2AF2BD5FA9792DEF422F3B47755894E8F3220453F31F63F1594CCD61E9AF1B4
internal mission SHA-256: 2378F38E9B07365D25ACE38E45A23D87E2CC76F185A062FB2A46CA8EE31C1A53
Acceptance bundle SHA-256: 94C18556B80E97A30420DD551BC0CD98E978CBA2E487A6AA6B35281E1F29FDD7
Ground BASE-3 bundle SHA-256: 6DBDE7AA75E34FA6C7A42A7C97B3E407C069806666C60E8D27F8616D647383EE
Warehouse BASE-3 bundle SHA-256: FC0F8F20909DD57E5DEE3AF6414FB56B35D8671D726471DEDB6D6984E590801B
dcs.log SHA-256: 8ECFD3CACC58FF0421E55280D7CE63EFA2A6C1CDA0A09095F7A69E588290DE71
debrief.log SHA-256: B773DDB09401B7E58F4393EEEEDCE858EB98F769E1BE2DE9AB12392B10583A9E
Result: PASS
```

Praktisch bestätigt wurden für genau diesen Stand:

```text
ARTY fixed-battery lifecycle at Bostick
L118 controlled firing and observable ammo reduction
CHAP_M1083 materialization through existing Ground/Warehouse lifecycle
CampaignState local GROUND_AMMO_PACKAGE consumption exactly once in the observed run
ARTY Rearm -> Rearmed/full-ammo completion
MOOSE USERFLAG Ground readiness bridge -> Mission Editor OMW_GROUND_READY == 1
```

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

Die strategische Transfermenge `20 GROUND_AMMO_PACKAGE` bleibt unabhängig von der physischen Zahl der Fahrzeuge. `TPL_BLUE_CONVOY_LIGHT_06` ist in diesem Acceptance-Scope eine feste physische Repräsentation, keine definierte Kapazitätsklasse.

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

## Addendum 2026-08-22 – Stage 1B runtime FAIL and Stage 1C AUFTRAG NOTHING replacement

Dieses Addendum **superseded für den aktuellen Branch** die unmittelbar davor stehende `DCS_PENDING`-Aussage zu Stage 1B.

Stage 1B realer Runtime-Befund:

```text
AUFTRAG:NewFUELSUPPLY(Zone)
ROAD_ALIGNED_WAREHOUSE_SPAWN
GROUP_MATERIALIZED
ARMY_ON_MISSION mission=FUELSUPPLY
-> no MissionExecute
-> no MissionDone
-> OUTBOUND_TIMEOUT
Result: FAIL / CLOSED FOR CURRENT OMW META-RESUPPLY USE
```

Owner-approved Stage-1C-Ersatzvertrag vom 22.08.2026:

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
