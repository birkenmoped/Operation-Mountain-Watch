---
document_id: OMW-STAGE-2-FOB-ATTACK-HIT-ACCEPTANCE-1
status: PLANNED
document_class: DCS_ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 2 DCS acceptance plan for MOOSE EVENTS.Hit qualification
  - Fortress infantry sentry target and PASS criteria
  - use of the existing OMW mission runtime stack
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
  - dedicated Fortress patrol-test-zone dependency for the Sentry guard point
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Stage 2 – FOB Attack Hit Acceptance 1

## 1. Ziel

Der Test bestätigt Stage 2 gegen den bereits in der aktuellen OMW-Testmission vorhandenen Runtime-Stack:

```text
existing Moose.lua
-> existing OMW_AirOps_Warehouse_Base.lua
   -> authoritative OMW.AirOps.CampaignContext
   -> OMW_WAREHOUSE_READY = 1
-> existing OMW_Ground_Base.lua
-> existing mission GroundBase.Attach(...) trigger
   -> same OMW.AirOps.CampaignContext
   -> OMW_GROUND_READY = 1
-> Stage 2 Acceptance bundle
   -> commit 9 Fortress GROUND_PERSONNEL
   -> MOOSE BRIGADE / PLATOON / Warehouse materialization
   -> TPL_BLUE_GND_INF_RIFLE_SQUAD_9
   -> derive guard coordinate from WH_BLUE_GND_FORTRESS through BRIGADE/WAREHOUSE:GetCoordinate()
   -> AUFTRAG:NewONGUARD(...)
   -> real RED hit
   -> MOOSE EVENTS.Hit
   -> CAS_IMMEDIATE MissionDemand
   -> repeated hit -> active_duplicate
   -> exactly one active CAS demand
```

Es wird kein eigener Acceptance-CampaignState erzeugt und kein zusätzlicher Ground-startup bridge benötigt.

## 2. Produktions- und Autoritätsgrenze

Die bereits eingebettete Warehouse Production Base ist Besitzer des gemeinsamen autoritativen CampaignState-Kontexts:

```text
OMW.AirOps.CampaignContext
```

`OMW_Ground_Base.lua` erzeugt keinen zweiten Store. Die aktuelle Testmission führt bereits den erforderlichen Attach aus:

```lua
OMW.Ground.Base.Attach({
  store = OMW.AirOps.CampaignContext.store,
  campaignState = OMW.AirOps.CampaignContext.campaignState,
  restored = OMW.AirOps.CampaignContext.restored == true,
})
```

Der Stage-2-Harness verlangt nur einen aktiven `OMW.Ground.Base.GetContext()` und erzeugt keine zweite strategische Autorität.

## 3. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Verwendeter MOOSE-Pfad:

```text
BRIGADE:New(...)
LEGION -> WAREHOUSE inheritance
WAREHOUSE:GetCoordinate()
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

Der gepinnte `Moose.lua` bestätigt, dass `BRIGADE` von `LEGION`, `LEGION` von `WAREHOUSE` erbt und `WAREHOUSE:GetCoordinate()` die Koordinate der physischen Warehouse-Struktur zurückgibt. Daher wird kein Mission-Editor-Triggerpunkt für den Guard-Auftrag benötigt.

## 4. Bestehende Mission-Editor-Objekte

Erforderlich:

```text
WH_BLUE_GND_FORTRESS
ZON_BLUE_GND_FORTRESS_ACCESS
TPL_BLUE_GND_INF_RIFLE_SQUAD_9
```

Nicht erforderlich:

```text
ZON_BLUE_GND_FORTRESS_PATROL_TEST_01
zusätzliche Guard-/Sentry-Triggerzone
TST_BLUE_GND_FORTRESS_HIT_TARGET
zusätzliche BLUE-Infanteriegruppe im Mission Editor
```

Das Rifle-Squad-Template ist die bestehende 9-Mann-Darstellung:

```text
7 x Soldier M4
2 x Soldier M249
```

## 5. Stage-2-Bundle

Builder:

```text
tools/build-fob-attack-hit-acceptance-1.ps1
```

Output:

```text
mission/tests/fob-attack-support-demand/dist/OMW_FOB_Attack_Hit_Acceptance_1.lua
```

Der Stage-2-Builder enthält nur MissionDemand, FOB-Attack-DemandPolicy, den MOOSE-Hit-Adapter und den Acceptance-Harness. Er enthält keinen CampaignState, keinen GroundBase und keinen zusätzlichen Ground-startup bridge.

Für die aktuelle `OMW_Template_v20_GroundWorks`-Testmission bleiben die bereits eingebetteten `OMW_AirOps_Warehouse_Base.lua`, `OMW_Ground_Base.lua` und der bestehende GroundBase-Attach-Trigger unverändert.

## 6. Fortress-Sentry und PERSONNEL

Der Acceptance-Harness reserviert/consumed genau:

```text
node: GROUND_NODE_FORTRESS
resource: GROUND_PERSONNEL
quantity: 9
transaction: STAGE2-A1-FORTRESS-SENTRY-PERSONNEL
```

Bei frischem Produktionskontext entspricht dies `160 -> 151`; das Runtime-Kriterium bleibt `before - 9`.

Danach wird die Sentry ausschließlich aus vorhandenem Bestand materialisiert:

```text
BRIGADE alias: BDE_BLUE_GND_FORTRESS_STAGE2_A1
PLATOON alias: PLT_BLUE_GND_FORTRESS_SENTRY_STAGE2_A1
Template: TPL_BLUE_GND_INF_RIFLE_SQUAD_9
Mission: OMW_STAGE2_A1_FORTRESS_SENTRY
Mission type: AUFTRAG ONGUARD
Guard point: runtime coordinate of WH_BLUE_GND_FORTRESS via BRIGADE/WAREHOUSE:GetCoordinate()
```

Damit schützt die Testgruppe den Fortress-Warehouse-/FOB-Bereich, ohne dass der Mission Editor eine separate Guard-Zone bereitstellen muss.

Infantry casualty, survivor return, recredit und restart settlement bleiben außerhalb dieses Acceptance-Scopes.

## 7. Erster realer DCS-Lauf – FAIL vor Sentry-Start

Der Lauf vom 2026-08-29 mit `OMW_Template_v20_GroundWorks(9).miz` erreichte den bestehenden Warehouse-/Ground-Ready-Pfad, scheiterte aber vor der Sentry-Materialisierung an der falschen Harness-Annahme:

```text
[OMW][FOB-ATTACK-HIT-ACCEPTANCE-1] FAIL missing object=ZON_BLUE_GND_FORTRESS_PATROL_TEST_01
```

Die Mission enthielt diese Zone nicht. Dieser Lauf validiert Stage 2 nicht; er dokumentiert ausschließlich den fehlgeschlagenen Acceptance-Harness.

Fehlerkorrektur:

```text
vorher: externe Mission-Editor-Zone ZON_BLUE_GND_FORTRESS_PATROL_TEST_01 erforderlich
jetzt: Guard-Punkt wird aus WH_BLUE_GND_FORTRESS über BRIGADE/WAREHOUSE:GetCoordinate() abgeleitet
```

Es wird ausdrücklich **keine neue Mission-Editor-Zone** als Workaround gefordert.

## 8. Runtime-Ablauf und Angriff

Vor dem RED-Angriff müssen im `dcs.log` insbesondere erscheinen:

```text
PERSONNEL_COMMITTED ... quantity=9
SENTRY_QUEUED ... warehouse=WH_BLUE_GND_FORTRESS guardSource=warehouse-coordinate
SENTRY_ON_MISSION ...
SENTRY_ONGUARD_EXECUTING ... warehouse=WH_BLUE_GND_FORTRESS
READY targetGroup=<dynamic runtime group> ... guardSource=warehouse-coordinate
```

Erst nach `READY targetGroup=...` darf RED die materialisierte Sentry-Gruppe real beschießen.

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
1. Die bestehende Mission erreicht OMW_WAREHOUSE_READY=1 und OMW_GROUND_READY=1.
2. Stage 2 verwendet den bereits attached OMW Ground CampaignState-Kontext; kein zweiter Store wird erzeugt.
3. Genau 9 Fortress GROUND_PERSONNEL werden committed/consumed.
4. TPL_BLUE_GND_INF_RIFLE_SQUAD_9 wird über MOOSE BRIGADE/PLATOON/Warehouse materialisiert.
5. Der ONGUARD-Zielpunkt wird zur Laufzeit aus WH_BLUE_GND_FORTRESS über BRIGADE/WAREHOUSE:GetCoordinate() abgeleitet.
6. Keine zusätzliche Mission-Editor-Guard-Zone ist erforderlich.
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

Erst nach realem DCS-PASS werden dokumentiert:

```text
Git commit
BuilderVersion
Stage-2-Bundle SHA-256
MIZ filename + SHA-256
DCS version
MOOSE commit + Moose.lua SHA-256
dcs.log SHA-256
debrief.log SHA-256, soweit erzeugt
Result
```

Bis dahin bleibt `PLANNED` / `validated_in_dcs: false`.
