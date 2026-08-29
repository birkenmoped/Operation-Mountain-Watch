---
document_id: OMW-STAGE-2-FOB-ATTACK-HIT-ACCEPTANCE-1
status: PLANNED
document_class: DCS_ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 2 DCS acceptance plan for MOOSE EVENTS.Hit qualification
  - Fortress infantry sentry target and PASS criteria
  - production-stack load order used by Stage 2 Acceptance 1
not_authoritative_for:
  - runtime validation before the documented DCS run
  - infantry casualty / survivor-return / restart settlement
  - CAS aircraft dispatch
  - general attack severity classification
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - dedicated TST_BLUE_GND_FORTRESS_HIT_TARGET Acceptance-1 target plan
  - standalone Acceptance-1 CampaignState/GroundBase bootstrap plan
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Stage 2 – FOB Attack Hit Acceptance 1

## 1. Ziel

Der Test bestätigt Stage 2 gegen den normalen OMW-Produktionsstack statt gegen einen Acceptance-eigenen Parallelstack:

```text
Moose.lua
-> OMW_AirOps_Warehouse_Base.lua
   -> exactly one authoritative OMW.AirOps.CampaignContext
   -> AirOps/AAR/Ground strategic stock seeded once
   -> OMW_WAREHOUSE_READY = 1
-> OMW_Ground_Base.lua
   -> OMW.Ground.Base
   -> OMW_GROUND_READY = 0
-> OMW_Ground_Startup.lua
   -> attach OMW.Ground.Base to OMW.AirOps.CampaignContext
   -> OMW_GROUND_READY = 1
-> Stage 2 Acceptance bundle
   -> commit 9 Fortress GROUND_PERSONNEL
   -> MOOSE BRIGADE / PLATOON / Warehouse materialization
   -> TPL_BLUE_GND_INF_RIFLE_SQUAD_9
   -> AUFTRAG:NewONGUARD(...)
   -> real RED hit
   -> MOOSE EVENTS.Hit
   -> CAS_IMMEDIATE MissionDemand
   -> repeated hit -> active_duplicate
   -> exactly one active CAS demand
```

Es wird kein eigener Acceptance-CampaignState erzeugt.

## 2. Produktions- und Autoritätsgrenze

Der Warehouse-Production-Base ist der bestehende Besitzer der NEW-Erzeugung des einzigen autoritativen CampaignState-Kontexts. Er registriert ihn als:

```text
OMW.AirOps.CampaignContext
```

und seeded dabei bereits die genehmigten AirOps-, AAR- und Ground-Bestände. `CampaignState` bleibt alleinige strategische Ressourcenautorität.

`OMW_Ground_Base.lua` erzeugt keinen Store. Der neue kleine Produktions-Startup-Bridge

```text
scripts/ground/OMW_GroundStartup.lua
```

verbindet ausschließlich `OMW.Ground.Base` mit dem bereits existierenden `OMW.AirOps.CampaignContext`. Er erzeugt weder CampaignState noch DCS-/MOOSE-Assets.

## 3. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Verwendeter MOOSE-Pfad im eigentlichen Acceptance-Slice:

```text
BRIGADE:New(...)
PLATOON:New(...)
COHORT:AddMissionCapability(AUFTRAG.Type.ONGUARD, ...)
LEGION:AddMission(...)
AUFTRAG:NewONGUARD(...)
AUFTRAG:SetReturnToLegion(false)
BRIGADE OnAfterArmyOnMission
ARMYGROUP OnAfterMissionExecute
BASE:HandleEvent(EVENTS.Hit, callback)
BASE:UnHandleEvent(EVENTS.Hit)
SCHEDULER:New(...)
```

Für Startup-/Ready-Gates wird der vorhandene MOOSE-`USERFLAG`-Pfad verwendet. Kein paralleler `world.addEventHandler`, kein MIST und keine `MissionScripting.lua`-Änderung.

## 4. Bestehende Mission-Editor-Objekte

Erforderlich:

```text
WH_BLUE_GND_FORTRESS
ZON_BLUE_GND_FORTRESS_ACCESS
ZON_BLUE_GND_FORTRESS_PATROL_TEST_01
TPL_BLUE_GND_INF_RIFLE_SQUAD_9
```

Das Rifle-Squad-Template ist die bestehende 9-Mann-Darstellung:

```text
7 x Soldier M4
2 x Soldier M249
```

Keine zusätzliche BLUE-Testzielgruppe ist erforderlich.

## 5. Zu bauende Runtime-Artefakte

```text
tools/build-air-ops-warehouse-production-base.ps1
-> mission/runtime/logistics/OMW_AirOps_Warehouse_Base.lua

tools/build-ground-production-base.ps1
-> mission/ground-operations/dist/OMW_Ground_Base.lua

tools/build-ground-startup.ps1
-> mission/ground-operations/dist/OMW_Ground_Startup.lua

tools/build-fob-attack-hit-acceptance-1.ps1
-> mission/tests/fob-attack-support-demand/dist/OMW_FOB_Attack_Hit_Acceptance_1.lua
```

Der Stage-2-Builder enthält nur MissionDemand, FOB-Attack-DemandPolicy, den MOOSE-Hit-Adapter und den Acceptance-Harness. Er enthält ausdrücklich **keinen** `CampaignState.New(...)`, keinen GroundBase und keinen Ground-Startup-Parallelpfad.

## 6. Mission-Editor-Ladereihenfolge

Die Actions werden in dieser Reihenfolge geladen:

```text
1. Moose.lua
2. OMW_AirOps_Warehouse_Base.lua
3. OMW_Ground_Base.lua
4. OMW_Ground_Startup.lua
5. OMW_FOB_Attack_Hit_Acceptance_1.lua
```

Keine willkürlichen Sekunden-Delays zwischen diesen fünf Dateien. Die Abhängigkeiten sind synchron und fail-closed:

```text
OMW_AirOps_Warehouse_Base.lua
-> OMW_WAREHOUSE_READY == 1

OMW_Ground_Base.lua
-> OMW_GROUND_BASE_LOADED == 1
-> OMW_GROUND_READY == 0

OMW_Ground_Startup.lua
-> requires OMW_WAREHOUSE_READY == 1
-> attaches exactly OMW.AirOps.CampaignContext
-> OMW_GROUND_READY == 1

Stage 2 Acceptance
-> requires active OMW.Ground.Base.GetContext()
```

Damit wird derselbe strategische Store vom Warehouse- und Ground-Stack verwendet.

## 7. Fortress-Sentry und PERSONNEL

Der Acceptance-Harness reserviert/consumed genau:

```text
node: GROUND_NODE_FORTRESS
resource: GROUND_PERSONNEL
quantity: 9
transaction: STAGE2-A1-FORTRESS-SENTRY-PERSONNEL
```

Bei frischem Produktionskontext entspricht dies `160 -> 151`; das Runtime-Kriterium bleibt `before - 9`.

Danach:

```text
BRIGADE alias: BDE_BLUE_GND_FORTRESS_STAGE2_A1
PLATOON alias: PLT_BLUE_GND_FORTRESS_SENTRY_STAGE2_A1
Mission: OMW_STAGE2_A1_FORTRESS_SENTRY
Mission type: AUFTRAG ONGUARD
Zone: ZON_BLUE_GND_FORTRESS_PATROL_TEST_01
```

Infantry casualty, survivor return, recredit und restart settlement bleiben außerhalb dieses Acceptance-Scopes.

## 8. Runtime-Ablauf und Angriff

Vor dem RED-Angriff müssen im `dcs.log` insbesondere erscheinen:

```text
[OMW][Logistics.AirOpsWarehouseProduction] READY ... groundStockSeeded=true ...
[OMW][Ground.Startup] READY authority=OMW.AirOps.CampaignContext ... warehouseReady=1 groundReady=1
PERSONNEL_COMMITTED ... quantity=9
SENTRY_QUEUED ...
SENTRY_ON_MISSION ...
SENTRY_ONGUARD_EXECUTING ...
READY targetGroup=<dynamic runtime group> ...
```

Erst nach dem letzten `READY targetGroup=...` darf RED die materialisierte Sentry-Gruppe real beschießen.

Erwartung:

```text
first real RED-on-BLUE hit
-> QUALIFIED_HIT count=1
-> DEMAND_RESULT created=true reason=nil

second real RED-on-BLUE hit while demand active
-> QUALIFIED_HIT count=2
-> DEMAND_RESULT created=false reason=active_duplicate

then
-> PASS ... activeDemands=1 ... missionType=CAS_IMMEDIATE ... installationId=BLUE_GROUND_COP_FORTRESS
```

## 9. PASS-Kriterien

Alle müssen gleichzeitig gelten:

```text
1. Warehouse Production Base erzeugt/registriert genau den gemeinsamen OMW.AirOps.CampaignContext und erreicht OMW_WAREHOUSE_READY=1.
2. OMW_Ground_Base.lua ist geladen.
3. OMW_Ground_Startup.lua attached GroundBase an exakt denselben CampaignState-Store und erreicht OMW_GROUND_READY=1.
4. Kein zweiter CampaignState-Store wird vom Stage-2-Bundle erzeugt.
5. Genau 9 Fortress GROUND_PERSONNEL werden committed/consumed.
6. TPL_BLUE_GND_INF_RIFLE_SQUAD_9 wird über MOOSE BRIGADE/PLATOON/Warehouse materialisiert.
7. Dieselbe Runtime-Gruppe erreicht AUFTRAG ONGUARD.
8. MOOSE EVENTS.Hit liefert mindestens zwei reale RED-on-BLUE Treffer.
9. Erster Treffer erzeugt genau einen CAS_IMMEDIATE Demand.
10. Zweiter Treffer liefert active_duplicate und erzeugt keinen zweiten Demand.
11. Genau ein aktiver Fortress-CAS-Demand verbleibt.
12. Kein CAS-AUFTRAG/COMMANDER/AIRWING/SQUADRON-Dispatch wird ausgeführt.
13. Kein world.addEventHandler/MIST/MissionScripting.lua-Pfad wird verwendet.
14. dcs.log enthält den expliziten PASS-Eintrag.
```

## 10. Provenienz

Erst nach realem DCS-Lauf werden dokumentiert:

```text
Git commit
BuilderVersions
SHA-256 aller vier Runtime-Bundles
MIZ filename + SHA-256
DCS version
MOOSE commit + Moose.lua SHA-256
dcs.log SHA-256
debrief.log SHA-256, soweit erzeugt
Result
```

Bis dahin bleibt `PLANNED` / `validated_in_dcs: false`.
