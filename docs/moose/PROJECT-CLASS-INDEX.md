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
source_branch: agent/automatic-response-orchestration-continuation
source_commit: GIT_HISTORY
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
- [`OMW-MOOSE-AWACS-EXTERNAL-LIFECYCLE`](AWACS-EXTERNAL-LIFECYCLE.md)
- [`OMW-MOOSE-AWACS-FUEL-DRIVEN-AAR`](AWACS-FUEL-DRIVEN-AAR-LIFECYCLE.md)
- [`OMW-MOOSE-GROUND-OPERATIONS`](GROUND-OPERATIONS.md)
- [`OMW-MOOSE-QRF-RESPONSE-CLEARANCE-LIFECYCLE`](QRF-RESPONSE-CLEARANCE-LIFECYCLE.md)
- [`OMW-MOOSE-MISSION-DEMAND-RESUPPLY-CAS-SOURCE-REVIEW`](MISSION-DEMAND-RESUPPLY-CAS-SOURCE-REVIEW.md)
- [`OMW-MOOSE-AIR-TASKING-C2-LIFECYCLE`](AIR-TASKING-C2-LIFECYCLE.md)
- [`OMW-MOOSE-STAGE3-CAS-TACTICAL-CORRIDOR`](STAGE3-CAS-TACTICAL-CORRIDOR-DECISION.md)
- [`OMW-MOOSE-STAGE3-CAS-LIFECYCLE-RECOVERY-LAW`](STAGE3-CAS-LIFECYCLE-RECOVERY-LAW.md)
- [`OMW-MOOSE-SUPPORT-REQUEST-LIFECYCLE-LAW`](MOOSE-SUPPORT-REQUEST-LIFECYCLE-LAW.md)
- [`Stage 1D-P Air PERSONNEL Acceptance-4`](GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-ACCEPTANCE-4-FINAL.md)

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
| `AIRWING` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Konstruktion, Stockregistrierung, SQUADRON-Bindung und direkter AUFTRAG-Dispatch; Stage 1D-P bestätigt Jalalabad-CH-47-Dispatch und `LegionAssetReturned` erst nach physischer Jalalabad-Landung; externe OMW-AAR-/AWACS-Pools verwenden bewusst kein AIRWING |
| `SQUADRON` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Foundation-Bestände und post-start Assetbindung; Stage 1D-P bindet `SQ_US_JBAD_CH47_HEAVYLIFT` explizit an den akzeptierten Auftrag |
| `WAREHOUSE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` + `INTERNAL_RESTRICTED` | AirOps-Stock-/Asset-Lifecycle und Acceptance 3-2 Ground-Materialisierung praktisch bestätigt; die private road-aligned Ausnahme ist auf den dokumentierten Branch-/MOOSE-/MIZ-Scope begrenzt |
| `STORAGE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | CampaignState->DCS-Warehouse Mirror/Telemetry; keine strategische Rückautorität |
| `COHORT` | `VALIDATED_FOR_DOCUMENTED_SCOPE` + `SOURCE_REVIEWED` | AirOps-Lifecycle praktisch bestätigt; Ground-Review bestätigt `AddMissionCapability`, `SetMissionRange`, `CanMission`, `CountAssets` und 75-NM-Ground-Default source-seitig |
| `FLIGHTGROUP` | `VALIDATED_FOR_DOCUMENTED_SCOPE` + `SOURCE_REVIEWED` | AAR/AWACS-Lifecycles praktisch bestätigt; Stage 1D-P bestätigt `AddWaypoint(...)`, `OnAfterTaskDone`, späteres `OnAfterMissionDone` als Diagnose und physisches `OnAfterLanded` in Jalalabad im akzeptierten CH-47-Return-Scope. Stage 3 CAS Tactical Corridor: `AddWaypoint(...)`/`OnAfterUpdateRoute` ist source-reviewed für owner-authored dynamische Segmente; keine DCS-Validierung dieses neuen CAS-Pfads. |
| `COMMANDER` | `VALIDATED_FOR_DOCUMENTED_SCOPE` + `SOURCE_REVIEWED` | dokumentierter COMMANDER-Lifecycle; Ground-Review bestätigt `AddBrigade(...)` und `AddOpsTransport(...)` source-seitig; MissionDemand bleibt OMW-Tasking-Autorität |
| `AUFTRAG` | `VALIDATED_FOR_DOCUMENTED_SCOPE` + `SOURCE_REVIEWED` | AAR-, AWACS- und Ground-Lifecycles praktisch bestätigt; Stage 1D-P bestätigt `NewLANDATCOORDINATE(...)`, `SetMissionEgressCoord(...)`, `AssignSquadrons(...)` sowie gruppenspezifische Waypoint-/Egress-/Task-Abfragen. Stage 3 CAS Tactical Corridor source-reviewt `NewPATROLZONE`, `SetMissionIngressCoord`, `SetMissionWaypointCoord` und `SetMissionEgressCoord`. QRF-Clearance source-reviewt `NewPATROLZONE`, `GetOpsGroups`, `SetReturnToLegion`, `SetTeleport`, `Cancel` und `IsOver`; DCS-Validierung dieses neuen QRF-Pfads offen. Keine CampaignState-Autorität. |
| `SPAWN` | `VALIDATED_FOR_DOCUMENTED_SCOPE` + `SOURCE_REVIEWED` | area-spezifische AAR-Templates und externe Materialisierung praktisch bestätigt; AWACS bestätigt `OMW_C2_E3A_WIZARD`, LISA und MOE external materialization im dokumentierten Scope |
| `SCHEDULER` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | allgemeine OMW-Nutzung praktisch bestätigt; AWACS verwendet einen 5-Sekunden-Monitor ausschließlich zur Lifecycle-/Fuel-Koordination, keinen Frame-Scan |
| `USERFLAG` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Warehouse-Acceptance-Readiness-Pfade sowie Ground BASE-3 `OMW_GROUND_READY` Set/Get-Readback und Mission-Editor-Gate im dokumentierten Ground-Ammo-Rearm-Acceptance-1-Scope |
| `GROUP`, `UNIT`, `STATIC`, `ZONE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Wrapper-/Objektauflösung in dokumentierten Scopes; Acceptance-1-v13-Objektvertrag read-only bestätigt, Ground-Acceptance-6 bestätigt GetSize, GetUnits, test-only Destroy(false) und SetLife(50) im dokumentierten Verlust-/Schaden-Return-Scope |
| `COORDINATE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | `Get2DDistance(...)`, `GetIntermediateCoordinate(...)`, `HeadingTo(...)` sowie Stage-1D-P-`Translate(...)` im jeweils dokumentierten AirOps-/FlightPath-Scope |
| `BRIGADE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` + `INTERNAL_RESTRICTED` | Acceptance 1–6 bestätigen Ground-Assetpool, Materialisierung, Callback-Lifecycle und die parallelen Rückgabevarianten; die road-aligned private Warehouse-Spawn-Ausnahme bleibt auf Acceptance-3-2 und den gepinnten MOOSE-Stand begrenzt |
| `PLATOON` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Acceptance 1–6 bestätigen dokumentierte Assetselektion, Wiederverwendung und Rückgabevarianten im Ground-Scope; keine allgemeine Produktionsfreigabe |
| `ARMYGROUP` | `VALIDATED_FOR_DOCUMENTED_SCOPE` + `SOURCE_REVIEWED` | Acceptance 1–6 bestätigen MissionDone-Persistenz, Same-group-Follow-up sowie mobilen RTZ/Returned-Handoff einschließlich paralleler Teilverlust-/Schadenrückgabe. QRF-Clearance source-reviewt `SetPatrolAdInfinitum`, `EnableHuntingPatrol` und `DisableHuntingPatrol`; DCS-Validierung der neuen Clearance-Phase offen. Immobiler Teleportpfad bleibt ausgeschlossen. |
| `OPSGROUP` | `VALIDATED_FOR_DOCUMENTED_SCOPE` + `SOURCE_REVIEWED` | AirOps-/Ground-Pfade praktisch bestätigt; Stage 1D-P bestätigt TaskDone-Lifecycle und `Get2DDistance(...)` als Zielnäheprüfung für das LANDAT-Settlement. QRF-Clearance source-reviewt `AddMission(...)` und den FSM-Pfad `__MissionDone(...)` für den Same-group-Phasenwechsel; DCS-Validierung offen. Cargo-Pfade bleiben source-reviewed. |
| `LEGION` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Ground-Returned-Handoffs und Stage 1D-P Air-Asset-Return praktisch bestätigt; `LegionAssetReturned` allein ist im Air-PERSONNEL-Scope ausdrücklich kein physischer RTB-Nachweis |
| `OPSTRANSPORT` | `SOURCE_REVIEWED` | Constructor, Cargo/Carrier-Zonen, `AddPathTransport`, Disembark- und Carrier-Verträge geprüft; taktischer OMW-Transport benötigt eigenen DCS-Test |
| `AMMOTRUCK` | `SOURCE_REVIEWED` | gepinnter Source und offizieller Demo-Anwendungsfall für automatische Artillerie-Rearm-Versorgung geprüft; `reloads` ist Rearm-Zykluszahl, keine CampaignState-Menge; kein OMW-AMMOTRUCK-Runtime-PASS |
| `ARTY` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Ground-Ammo-Rearm-Acceptance-1 bestätigt den Bostick-Fixed-Battery-Pfad mit `New`, `AssignTargetCoord`, `GetAmmo`, `SetRearmingGroup`, `SetRearmingGroupOnRoad`, `Rearm` sowie CeaseFire/BeforeRearm/Rearmed-Callbacks; keine pauschale Validierung anderer Batterien, Supply-Typen oder MOOSE-Versionen |
| `CTLD`, `CSAR`, `AICSAR` | `PLANNED` / teilweise verwendet | separate Acceptance erforderlich |
| `INTEL` | `PLANNED` | taktisches Lagebild; Laufzeitnachweis offen |
| `INTEL_DLINK` | `CANDIDATE` | Aggregation getrennter Netze; Performance offen |
| `PLAYERRECCE` | `CANDIDATE` | spielergeführte Aufklärung; Multiplayerprüfung offen |
| `TARS` | `CANDIDATE` | verzögerte Foto-/IMINT-Aufklärung; Verfügbarkeit offen |
| `DETECTION_*` | `PLANNED` | Spezialfälle; kein paralleles strategisches Lagebild neben `INTEL` |
| `PATHLINE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Stage 1D-P Acceptance-4 bestätigt `OMW_FlightPath` als MOOSE-resolvierte, owner-authored 84-Punkte-Linie; 14 Punkte wurden im Jalalabad->Fortress-Scope tatsächlich verwendet; keine allgemeine Validierung anderer Pathlines |
| `Core.Astar`, `MOVEMENT` | `PLANNED` | Routing und Bewegungsbegrenzung außerhalb des akzeptierten `PATHLINE`-Scopes |
| `_DATABASE` | `INTERNAL_RESTRICTED` | nur Diagnose/Validierung; aktueller AAR- und Ground-Acceptance-1-Pfad verwendet `_DATABASE` nicht |
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

QRF-Clearance, owner-genehmigt 13.09.2026 und source-reviewed gegen denselben Pin:

```text
AUFTRAG:NewPATROLZONE(...)
AUFTRAG:GetOpsGroups()
AUFTRAG:SetReturnToLegion(true)
AUFTRAG:SetTeleport(false)
AUFTRAG:Cancel()
AUFTRAG:IsOver()

OPSGROUP:AddMission(...)
OPSGROUP:__MissionDone(...)

ARMYGROUP:SetPatrolAdInfinitum(true/false)
ARMYGROUP:EnableHuntingPatrol(...)
ARMYGROUP:DisableHuntingPatrol()
```

Dieser QRF-Pfad ist `SOURCE_REVIEWED` und noch nicht DCS-validiert. Details: [`OMW-MOOSE-QRF-RESPONSE-CLEARANCE-LIFECYCLE`](QRF-RESPONSE-CLEARANCE-LIFECYCLE.md).

Acceptance-1-Harness und Builder sind auf dem Branch vorhanden:

```text
mission/tests/army-ground-foundation/src/01-army-ground-acceptance-1.lua
tools/build-army-ground-acceptance-1.ps1
BuilderVersion: ARMY-GROUND-ACCEPTANCE-1-1
```

Der Harness plant genau einen Joyce-BRIGADE-/PLATOON-PATROLZONE-Pfad und prüft `MissionDone -> physical stay -> same ARMYGROUP follow-up` sowie Dublettenfreiheit. Das ist **STAGED / SOURCE_REVIEWED**, kein Runtime-PASS.

Wichtige Grenzen bleiben:

```text
- SetReturnToLegion(false) ist noch nicht im Ground-Scope DCS-validiert.
- WAREHOUSE:SetSpawnZone(...) ist für die Joyce-ACCESS-Zone source-geprüft, aber DCS-Pathfinding/Materialisierung offen.
- BRIGADE:LoadBackAssetInPosition nutzt SpawnFromCoordinate und bleibt für beobachtbare Reconstitution ausgeschlossen.
- immobile ARMYGROUP RTZ kann teleportieren und bleibt im sichtbaren OMW-Bereich ausgeschlossen.
- Returned -> WAREHOUSE AddAsset entfernt die physische Gruppe; Return-Handoff benötigt eigenen Test.
- OPSTRANSPORT coordinate unload materialisiert per _Respawn und benötigt eigenen Test.
- QRF PATROLZONE/HuntingPatrol clearance benötigt einen eigenen DCS-Acceptance-Lauf.
```

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
