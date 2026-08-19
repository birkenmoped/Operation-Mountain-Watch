---
document_id: OMW-MOOSE-GROUND-OPERATIONS
status: PLANNED
document_class: TECHNICAL_ARCHITECTURE_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - planned MOOSE ground-operations evaluation scope
  - source-reviewed behavior of ARMYGROUP, BRIGADE, PLATOON, COHORT, OPSGROUP and OPSTRANSPORT for the ARMY ground foundation
  - required tests for ground asset selection, movement, return and transport
not_authoritative_for:
  - accepted ground runtime architecture
  - final BRIGADE topology
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - unclassified MOOSE ground-operations reference
superseded_by:
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# MOOSE-Bodenoperationen in Operation Mountain Watch

## 1. Status

```text
PLANNED – Source-Review erweitert; Ground Acceptance 1 vorbereitet, noch nicht in DCS ausgeführt
```

Der vollständige frühere Prüf- und Klassenentwurf bleibt erhalten:

- [`Legacy-MOOSE-Ground-Operations`](../evidence/source-records/legacy-moose-ground-operations.md)

Source-Review ist kein DCS-Runtime-Nachweis.

## 2. Geprüfte MOOSE-Provenienz

Für den Ground-Review und Acceptance 1 gilt:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Der eingebettete Hash der Owner-erstellten Testmission `OMW_Template_v13_ground_test.miz` stimmt mit diesem gepinnten Artefakt überein. Die `.miz` wurde ausschließlich gelesen.

## 3. Ground-OPS-Hierarchie

```text
COMMANDER
    |
    +-- BRIGADE / operational Ground Node
            |
            +-- PLATOON / role and asset pool
                    |
                    +-- ARMYGROUP
                            |
                            +-- physical DCS GROUP
```

Für die aktuelle Foundation ist eine operative MOOSE-`BRIGADE` je Root Ground Node geplant. Eine MOOSE-`BRIGADE` ist keine historische Brigadeformation. `CampaignState` bleibt strategische Ressourcenautorität; BRIGADE/WAREHOUSE, PLATOON und ARMYGROUP sind operative Auswahl- und Repräsentationsschichten.

## 4. Source-verifizierte Klassen und Verträge

### 4.1 `COMMANDER`

Source-verifiziert:

```lua
COMMANDER:AddBrigade(Brigade)
COMMANDER:AddMission(Mission)
COMMANDER:AddOpsTransport(Transport)
```

`AddBrigade` delegiert auf `AddLegion`. Für OMW bleibt `MissionDemand` die fachliche Tasking-Autorität; `COMMANDER` ist Ausführungs-/Selektionsschicht.

### 4.2 `BRIGADE` / `WAREHOUSE`

Source-verifiziert:

```lua
BRIGADE:New(WarehouseName, BrigadeName)
BRIGADE:AddPlatoon(Platoon)
BRIGADE:AddAssetToPlatoon(Platoon, Nassets)
BRIGADE:AddRetreatZone(RetreatZone)
BRIGADE:AddRearmingZone(RearmingZone)
BRIGADE:AddRefuellingZone(RefuellingZone)
BRIGADE:LoadBackAssetInPosition(Templatename, Position)
WAREHOUSE:SetSpawnZone(Zone, MaxDist)
```

`BRIGADE:New(...)` verwendet einen benannten `UNIT`- oder `STATIC`-Host als Warehouse-Repräsentation. `AddPlatoon` registriert die PLATOON-Assetgruppen im LEGION-/WAREHOUSE-Pool und bindet den PLATOON an die Brigade.

`WAREHOUSE:SetSpawnZone(...)` ist im tatsächlich verwendeten Source vorhanden und setzt die Spawnzone des Warehouse. Acceptance 1 verwendet diese Methode, um `ZON_BLUE_GND_JOYCE_ACCESS` als kontrollierte Materialisierungszone vorzugeben. Diese Ground-Verwendung ist bis zum DCS-Lauf nur `SOURCE_REVIEWED`.

`LoadBackAssetInPosition(...)` bleibt ein Risikopfad: die Funktion materialisiert eine gespeicherte Ground-Gruppe über `SPAWN:SpawnFromCoordinate(Position)` und ist nicht als transparente Reconstitution in beobachtbaren Bereichen freigegeben.

### 4.3 `PLATOON` / `COHORT`

Source-verifiziert:

```lua
PLATOON:New(TemplateGroupName, Ngroups, PlatoonName)
COHORT:AddMissionCapability(MissionTypes, Performance)
COHORT:SetMissionRange(Range)
COHORT:CanMission(Mission)
COHORT:CountAssets(InStock, MissionTypes, Attributes)
```

Ground-COHORTs erhalten standardmäßig 75 NM Mission Range. `CanMission(...)` prüft Duty, Mission Capability und Target Distance; eine `Mission.engageRange` kann die effektive Range erweitern.

Acceptance 1 verwendet `CountAssets(true, AUFTRAG.Type.PATROLZONE)` erst nach BRIGADE-Start als positives Asset-Gate. Das ist source-seitig plausibel, aber noch nicht Ground-DCS-validiert.

### 4.4 `AUFTRAG`, `ARMYGROUP` und MissionDone

Source-verifiziert:

```lua
AUFTRAG:NewPATROLZONE(Zone, Speed, Altitude, Formation)
AUFTRAG:SetReturnToLegion(false)
AUFTRAG:__Cancel(Delay)
```

`NewPATROLZONE(...)` ist für Ground-Gruppen vorgesehen. `SetReturnToLegion(false)` setzt `mission.legionReturn=false`. Beim MissionDone-Pfad übernimmt OPSGROUP diesen Wert; für eine Ground-Group, die nicht zur Legion zurückkehren soll, hält der Source-Pfad die Gruppe an ihrer aktuellen Position, statt `Returned -> WAREHOUSE AddAsset` auszulösen.

Acceptance 1 verwendet den vom AUFTRAG-FSM erzeugten verzögerten `__Cancel(...)`-Eventpfad, um Mission 1 über den normalen Cancel-/MissionDone-Lifecycle zu beenden. Es wird weder eine native DCS-Löschung noch eine eigene Parallel-Missionssteuerung eingeführt.

Der normale Return-Pfad bleibt separat:

```text
ARMYGROUP:onafterReturned(...)
-> LEGION/WAREHOUSE AddAsset
-> physical group removed through Despawn/Destroy
```

Deshalb darf ein produktiver Return erst an einer nicht beobachtbaren Handoff-Grenze erfolgen.

`ARMYGROUP` RTZ bleibt differenziert:

```text
mobile ARMYGROUP
-> physical waypoint routing

immobile ARMYGROUP outside return zone
-> Teleport(...)
```

Der immobile Teleport-Pfad ist für beobachtbare OMW-Bereiche ausgeschlossen.

### 4.5 `SCHEDULER`

Acceptance 1 verwendet `SCHEDULER:New(...)` ausschließlich als kleine One-shot-Testkoordination für:

```text
post-start asset gate
MissionDone -> follow-up mission delay
```

Kein Frame-Scan und kein hochfrequenter Polling-Scheduler wird eingeführt. Die allgemeine MOOSE-SCHEDULER-Nutzung ist in anderen OMW-Scopes praktisch bestätigt; die konkrete Ground-Acceptance bleibt bis zum Testlauf unvalidiert.

### 4.6 `OPSTRANSPORT` und Cargo

Source-verifiziert:

```lua
OPSTRANSPORT:New(CargoGroups, PickupZone, DeployZone)
OPSTRANSPORT:SetEmbarkZone(...)
OPSTRANSPORT:SetDisembarkZone(...)
OPSTRANSPORT:SetDisembarkActivation(...)
OPSTRANSPORT:SetDisembarkCarriers(...)
OPSTRANSPORT:SetDisembarkInUtero(...)
OPSTRANSPORT:AddPathTransport(PathGroup, Reversed, Radius, TransportZoneCombo)
OPSTRANSPORT:SetRequiredCarriers(...)
OPSTRANSPORT:SetTime(...)
OPSTRANSPORT:SetPriority(...)
```

`AddPathTransport` kann einen vordefinierten Mission-Editor-Pfad verwenden. Der normale coordinate-based Unload materialisiert Cargo über `OPSGROUP:_Respawn(...)`; der konkrete OP-Reinforcement-Einsatz bleibt deshalb DCS-testpflichtig und ist nicht Teil von Acceptance 1.

## 5. Offizielle MOOSE-Demos und Tests

Die offiziellen MOOSE-Missionsrepositories wurden nach `BRIGADE`, `ARMYGROUP`, `OPSTRANSPORT` und `PLATOON` durchsucht. Für BRIGADE, ARMYGROUP und OPSTRANSPORT wurde im aktuellen Review kein direkter aktueller Klassenverwendungs-Treffer gefunden. Der geprüfte `WHS-020 - Self Propelled Ground Troops`-Demo verwendet WAREHOUSE direkt und beweist nicht die OMW-Hierarchie.

Das Fehlen eines gefundenen Beispiels ist kein Beweis, dass es historisch nie eines gab. Maßgeblich bleibt der tatsächlich verwendete Source; die OMW-Kombination benötigt einen eigenen DCS-Test.

## 6. OMW-Ausschlüsse

Bis zur expliziten Acceptance sind ausgeschlossen:

```text
1. BRIGADE:LoadBackAssetInPosition(...) in player-observable areas
2. ARMYGROUP RTZ for immobile groups when outside the return zone
3. arbitrary SpawnFromCoordinate reconstitution
4. Returned -> WAREHOUSE AddAsset at a player-observable return boundary
5. OPSTRANSPORT coordinate unload/materialization in visible areas without DCS verification
6. arbitrary Ground-AI routes without validated road/withdrawal anchors
```

`AUFTRAG:SetReturnToLegion(false)` ist nicht ausgeschlossen, sondern der primäre MOOSE-first-Acceptance-Kandidat für live-session field persistence. Der Status bleibt vor dem realen DCS-Lauf `SOURCE_REVIEWED`.

## 7. Acceptance 1 – gestagter Teststand

Owner-Testmission:

```text
OMW_Template_v13_ground_test.miz
MIZ SHA-256: 6d12a55affc971de1de4d5e463c956fcb2e08a0d2de478ff13419747a825e7e8
internal mission SHA-256: 22d13cb7b0da0a6fb9ddc02bf9b99c4da50d2c96b31bdc6a353616a4188c6b80
embedded Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Read-only bestätigt:

```text
WH_BLUE_GND_JOYCE
  STATIC / HESCO_generator

TPL_BLUE_GND_PATROL_MATV_4
  late activated
  4 x CHAP_MATV

ZON_BLUE_GND_JOYCE_ACCESS
  radius 152.4 m

ZON_BLUE_GND_JOYCE_PATROL_TEST_01
  radius 182.88 m

ACCESS -> PATROL_TEST_01
  ~9.45 km center distance
```

Staged runtime:

```text
mission/tests/army-ground-foundation/src/01-army-ground-acceptance-1.lua
tools/build-army-ground-acceptance-1.ps1
BuilderVersion: ARMY-GROUND-ACCEPTANCE-1-1
```

Der Harness prüft:

```text
BRIGADE start
-> one post-start PATROLZONE-capable PLATOON asset
-> PATROLZONE mission 1
-> SetReturnToLegion(false)
-> AUFTRAG __Cancel
-> MissionDone
-> ARMYGROUP still alive
-> PATROLZONE mission 2
-> same ARMYGROUP reused
-> no duplicate materialization
```

Die Testmission-Geometrie ist nur ein Struktur-PASS. Road-/Terrain-Pathfinding, tatsächliches MissionDone-Verhalten und Same-Group-Reuse sind **nicht** validiert, bis der reale DCS-Lauf mit vollständiger Hashprovenienz vorliegt.

## 8. Acceptance-Reihenfolge nach Acceptance 1

Wenn Acceptance 1 bestanden ist, folgt schrittweise:

```text
1. PLATOON capability/range selection refinement
2. mobile return/handoff to a non-observable Warehouse boundary
3. QRF
4. logistics/resupply
5. OPSTRANSPORT / OP reinforcement if retained
6. Honaker artillery
7. restart/reconstitution
8. multi-node / multiplayer integration
```

## 9. Architekturgrenze

CampaignState entscheidet über strategischen Bestand, Ressourcenreservierung und strategische Folgen. MOOSE führt operative Auswahl, Materialisierung, Mission und FSM aus.

Eigene Watchguard-, Routing-, Transport- oder Reconstitution-Logik darf erst nach dokumentierter MOOSE-Lücke und ausdrücklicher Projektinhaberfreigabe produktiv werden.

## Addendum 2026-08-19 – interne Warehouse-Spawn-Ausnahme für Acceptance 3-2

Die öffentliche `WAREHOUSE`-API wurde für die gewünschte Einzelaufstellung geprüft: `SetSpawnZone(...)` begrenzt eine Zone, übernimmt jedoch keine individuellen Unitpositionen oder Headings. Im gepinnten Source erzeugt `_SpawnAssetGroundNaval(...)` eine Templatekopie, wählt `spawnzone:GetRandomCoordinate()` und verschiebt die Einheiten.

Der Projektinhaber hat für Acceptance 3-2 ausdrücklich eine einzige interne Erweiterung freigegeben. Sie übernimmt die vorhandene TM01M-Straßenpositions-/Heading-Berechnung und überschreibt nur pro BRIGADE-Instanz den Ground-Spawn-Schritt. Sie setzt absolute Werte in die durch `_SpawnAssetPrepareTemplate(...)` bereitete Kopie und ruft `_DATABASE:Spawn(template)` genau einmal auf.

~~~text
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Scope: Acceptance 3-2; sechs test-only Ground-Domains
Unverändert: Assetreservation, Request queue, __AssetSpawned, OnAfterAssetSpawned, OnAfterArmyOnMission, BRIGADE/PLATOON/ARMYGROUP/AUFTRAG, CampaignState
Guard rails: 18 m Abstand; 20 m Freiraum; 10-m Heading-Sample; Road-Snap <= 30 m; alle Positionen in ACCESS
Status: SOURCE_REVIEWED_EXCEPTION_APPROVED_DCS_PENDING
~~~

Der interne Eingriff ist versionsgebunden und darf außerhalb dieses Acceptance-Scopes nicht wiederverwendet werden. Der eigene DCS-Regressionstest muss road-aligned sichtbaren Spawn ohne Geometriekollision und die unveränderten Warehouse-/Callback-/same-ARMYGROUP-Kriterien belegen.
## Addendum 2026-08-19 – Acceptance-3-2-DCS-Nachweis

Die genehmigte interne Warehouse-Spawn-Ausnahme wurde real in DCS 2.9.28.26385 MT geprüft:

~~~text
Tested source commit: 9b4997bf024efe0fab18b4d18552117cd8eeee21
Bundle SHA-256: 1f3879c1245483ba69cb8a5cc76ea1af4f46cdd01d7c9778440f2a2c6d08ef00
MIZ SHA-256: a6ce41bc9d7ab0f352f567322401e238dcd2057c548b4ddba44fe9f32f4577cd
MOOSE SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Result: six sites PASS; owner visual acceptance
~~~

Bestätigt sind exakt für diesen Scope: die per-BRIGADE Adapterausführung vor der Warehouse-Materialisierung, vier Unitpositionen auf der Straße je Site, 74 m Marschraum, maximal 4 m Road-Snap, einmalige Assetmaterialisierung, `OnAfterAssetSpawned`-/`OnAfterArmyOnMission`-gestützter Lifecycle, `SetReturnToLegion(false)`, same-ARMYGROUP Mission 1/2 und stabiler Zielhalt. Die Ausnahme bleibt intern, versionsgebunden und nicht produktionsverallgemeinert.

## Addendum 2026-08-19 – Acceptance 4 Fenty return handoff (DCS pending)

Für Acceptance 4 ist der mobile, öffentliche Rückgabepfad source-geprüft:

```text
ARMYGROUP:RTZ(existing Fenty ACCESS zone, ENUMS.Formation.Vehicle.OnRoad)
-> temporary OnRoad detour waypoint
-> ARMYGROUP:Returned()
-> LEGION:__AddAsset(10, group, 1)
-> WAREHOUSE AddAsset / physical group removal
```

Der Test verwendet den dokumentierten mobilen Pfad. Der immobile `ARMYGROUP:onbeforeRTZ`-Teleportzweig ist ausgeschlossen. Der bestehende Fenty-ACCESS-Marker wird sowohl für Spawn/Start als auch für Rückkehr/Handoff verwendet und muss für die von MOOSE gewählte Zielkoordinate sowie vier M-ATV frei sein. Noch `SOURCE_REVIEWED / DCS_PENDING`; keine CampaignState-Buchung und keine Produktionsbaseline.

## Addendum 2026-08-19 – Acceptance-4-2-DCS-Nachweis

Der mobile öffentliche Fenty-Rückgabepfad wurde in DCS 2.9.28.26385 MT praktisch bestätigt:

~~~text
Tested source commit: ec66a29ddbd234d07f28d174a7725e4331cc31a6
Bundle SHA-256: 643637683e7e161584d5b1dbcc16b87a6691b2f32a6ae4e101229da1d35af5bd
MIZ: OMW_Template_v13_ground_test(20260819-200418).miz
MIZ SHA-256: 1564001e9aa524217a9142c35977d5cf9c0d4e8b2765c1de351ecb31a7edf3e2
internal mission SHA-256: c0b26f5af717d9db0c60551b06544348eb58d7597bf8917cdb3989f97c3cc4b7
MOOSE SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Result: PASS / owner visual acceptance
~~~

Für genau diesen Scope bestätigt: ARMYGROUP:RTZ(existing Fenty ACCESS zone, OnRoad) führte über den Returning-FSM-Zustand zu Returned; anschließend wurde der normale LEGION:__AddAsset(10, group, 1)-/Warehouse-Handoff ausgeführt. Die vier M-ATV fuhren bis zur bestehenden Fenty-ACCESS-Zone und die temporäre DCS-Gruppe wurde erst danach kontrolliert entfernt; diese sichtbare Entfernung ist erwartetes Warehouse-Verhalten. Kein Teleport wurde während Materialisierung, Anfahrt oder Rückfahrt akzeptiert. CampaignState blieb unverändert.
