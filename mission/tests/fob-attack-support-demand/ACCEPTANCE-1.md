---
document_id: OMW-STAGE-2-FOB-ATTACK-HIT-ACCEPTANCE-1
status: PLANNED
document_class: DCS_ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 2 DCS acceptance plan for MOOSE EVENTS.Hit qualification
  - Fortress infantry sentry target and PASS criteria
  - acceptance-local CampaignState/GroundBase bootstrap contract
not_authoritative_for:
  - runtime validation before the documented DCS run
  - production CampaignState startup architecture
  - production infantry loss/return settlement
  - CAS aircraft dispatch
  - general attack severity classification
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - dedicated TST_BLUE_GND_FORTRESS_HIT_TARGET Acceptance-1 target plan
  - Acceptance-1 plan requiring a separately preloaded Ground Base
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Stage 2 – FOB Attack Hit Acceptance 1

## 1. Ziel

Der Test bestätigt den Stage-2-Runtime-Pfad mit einer realen OMW-Fortress-Infanterierepräsentation statt einer künstlichen BLUE-Testzielgruppe:

```text
one fresh authoritative acceptance CampaignState
-> current GroundInitialStock
-> GroundBase Attach
-> commit 9 GROUND_PERSONNEL at GROUND_NODE_FORTRESS
-> MOOSE BRIGADE / PLATOON / Warehouse materialization
-> existing TPL_BLUE_GND_INF_RIFLE_SQUAD_9
-> AUFTRAG:NewONGUARD(...) at Fortress patrol-test zone
-> real RED weapon hit on the materialized squad
-> MOOSE EVENTS.Hit
-> OMW_FobAttackHitAdapter
-> OMW_FobAttackDemandPolicy
-> MissionDemand CAS_IMMEDIATE
-> repeated real hit at same installation
-> active_duplicate
-> exactly one active CAS demand
```

Nicht Bestandteil dieses Tests:

```text
production CampaignState startup/persistence
infantry casualty / return / restart settlement
AUFTRAG:NewCAS(...)
COMMANDER:AddMission(...) for CAS
AIRWING/SQUADRON dispatch
CAS success/failure
attack severity model
native world.addEventHandler
```

## 2. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Verwendeter Framework-Pfad:

```text
BRIGADE:New(...)
WAREHOUSE:SetSpawnZone(...) through BRIGADE
PLATOON:New(...)
COHORT:AddMissionCapability(AUFTRAG.Type.ONGUARD, ...)
LEGION:AddMission(...)
AUFTRAG:NewONGUARD(...)
AUFTRAG:SetReturnToLegion(false)
BRIGADE OnAfterArmyOnMission
ARMYGROUP OnAfterMissionExecute
BASE:New()
BASE:HandleEvent(EVENTS.Hit, callback)
BASE:UnHandleEvent(EVENTS.Hit)
SCHEDULER:New(...)
```

`AUFTRAG:NewONGUARD(Coordinate)` ist im tatsächlich gepinnten `Moose.lua` als öffentlicher GROUND/NAVAL-Auftrag vorhanden. Für den Hit-Pfad wird kein paralleler DCS-World-Eventhandler verwendet.

## 3. Bestehende OMW-Objekte

Der Acceptance-Harness setzt folgende bereits definierte OMW-Namen voraus:

```text
WH_BLUE_GND_FORTRESS
ZON_BLUE_GND_FORTRESS_ACCESS
ZON_BLUE_GND_FORTRESS_PATROL_TEST_01
TPL_BLUE_GND_INF_RIFLE_SQUAD_9
```

Das Rifle-Squad-Template ist im aktuellen Ground-Template-Vertrag als

```text
7 x Soldier M4
2 x Soldier M249
```

dokumentiert und ausdrücklich als wiederverwendbare physische Repräsentation für Fußpatrouille und lokale Sicherung vorgesehen.

Der Harness legt dafür branch-/testlokal an:

```text
BRIGADE alias: BDE_BLUE_GND_FORTRESS_STAGE2_A1
PLATOON alias: PLT_BLUE_GND_FORTRESS_SENTRY_STAGE2_A1
Mission name: OMW_STAGE2_A1_FORTRESS_SENTRY
```

Diese Aliase behaupten keine zusätzliche strategische Organisation oder Ressource.

## 4. CampaignState-/GroundBase-Bootstrap

Acceptance 1 ist ab BuilderVersion `FOB-ATTACK-HIT-ACCEPTANCE-1-3` selbständig. Das Bundle enthält die bereits vorhandenen produktiven Module:

```text
scripts/campaign/OMW_CampaignState.lua
scripts/logistics/OMW_GroundInitialStock.lua
scripts/ground/OMW_GroundCampaignStateAdapter.lua
scripts/ground/OMW_GroundAmmoRearmAdapter.lua
scripts/ground/OMW_GroundRuntimeIntegration.lua
scripts/ground/OMW_GroundBase.lua
```

Die Acceptance-Bootstrap-Datei

```text
mission/tests/fob-attack-support-demand/src/00-stage2-ground-context-bootstrap.lua
```

führt ausschließlich für diese Testmission folgende Komposition aus:

```text
current GroundInitialStock.Rows
-> CampaignState.New(...)
-> exactly one fresh acceptance store
-> GroundBase.Configure(...)
-> OMW.Ground.Base = GroundBase
-> GroundBase.Attach(store, CampaignState, restored=false)
```

Es wird **kein zweiter Store** erzeugt. Deshalb darf für diesen Acceptance-Lauf vor dem Stage-2-Bundle weder ein separates CampaignState-Startup-Bundle noch `OMW_Ground_Base.lua` geladen werden.

Diese Bootstrap-Komposition ist keine Entscheidung über den späteren produktiven CampaignState-Startup/Persistence-Pfad. Sie beseitigt ausschließlich die unnötige externe Startup-Abhängigkeit der Acceptance-Mission.

Für die neun Soldaten wird danach genau eine Consumption-Transaktion angelegt:

```text
node: GROUND_NODE_FORTRESS
resource: GROUND_PERSONNEL
quantity: 9
transaction: STAGE2-A1-FORTRESS-SENTRY-PERSONNEL
```

Auf dem frischen aktuellen Ground-Bestand gilt:

```text
160 -> 151 available GROUND_PERSONNEL
```

Wichtig: Acceptance 1 validiert nur die **Disposition/Commitment-Grenze** für diese Testgruppe. Tote, Überlebende, Rückkehr, Recredit und Restart dieser Infanteriegruppe werden hier nicht abgewickelt und nicht als produktiv validiert.

## 5. Mission-Editor-Gate

ChatGPT verändert die `.miz` nicht. Eine zusätzliche BLUE-Zielgruppe wie

```text
TST_BLUE_GND_FORTRESS_HIT_TARGET
```

ist ausdrücklich **nicht erforderlich**.

Für den Lauf müssen die in Abschnitt 3 genannten bestehenden Fortress-Objekte/Templates in der tatsächlich verwendeten Mission vorhanden sein. Zusätzlich wird ein RED-Angreifer benötigt, der die materialisierte Rifle-Squad-Gruppe real beschießt. AI oder tester-kontrolliert ist zulässig; mindestens zwei echte RED-on-BLUE `EVENTS.Hit`-Ereignisse müssen an der dynamischen Runtime-Gruppe eintreffen.

Keine Trigger-Explosion, kein künstlicher Event-Aufruf und kein Native-DCS-Testhandler ersetzt die realen Treffer.

## 6. Bundle und Ladevertrag

Builder:

```text
tools/build-fob-attack-hit-acceptance-1.ps1
```

Output:

```text
mission/tests/fob-attack-support-demand/dist/OMW_FOB_Attack_Hit_Acceptance_1.lua
```

Ab BuilderVersion `FOB-ATTACK-HIT-ACCEPTANCE-1-3` ist für diese Acceptance im Mission Editor nur folgende Lua-Reihenfolge vorgesehen:

```text
1. Moose.lua
2. OMW_FOB_Attack_Hit_Acceptance_1.lua
```

Nicht zusätzlich laden:

```text
OMW_Ground_Base.lua
separates CampaignState startup bundle
ältere Stage-2 Acceptance bundles
```

Zwischen `Moose.lua` und dem Acceptance-Bundle ist kein erfundener Zeitdelay erforderlich; die Reihenfolge der `MISSION START / DO SCRIPT FILE` Actions ist die Abhängigkeit. Der Acceptance-Harness startet die Fortress-BRIGADE anschließend selbst. Fünf Sekunden nach deren `OnAfterStart` wird die Sentry-Mission vorbereitet.

## 7. Runtime-Ablauf

Vor dem Angriff müssen im `dcs.log` nacheinander insbesondere erscheinen:

```text
[OMW][FOB-ATTACK-HIT-ACCEPTANCE-1][BOOTSTRAP] READY authority=single_acceptance_campaignstate fortressPersonnel=160
PERSONNEL_COMMITTED ... quantity=9 before=160 after=151
SENTRY_QUEUED ... TPL_BLUE_GND_INF_RIFLE_SQUAD_9
SENTRY_ON_MISSION ...
SENTRY_ONGUARD_EXECUTING ...
READY targetGroup=<dynamic MOOSE/DCS runtime group> ...
```

Erst ab dem letzten `READY targetGroup=...` ist der dynamische Runtime-Gruppenname im Hit-Adapter registriert. **Erst danach darf RED feuern.**

Nach dem ersten qualifizierten Treffer:

```text
QUALIFIED_HIT count=1
DEMAND_RESULT ... created=true reason=nil
```

Nach einem zweiten realen Treffer derselben materialisierten Fortress-Gruppe, solange der erste Demand aktiv ist:

```text
QUALIFIED_HIT count=2
DEMAND_RESULT ... created=false reason=active_duplicate
```

Anschließend muss der Harness genau einen aktiven Demand bestätigen und ausgeben:

```text
PASS qualifiedHits=<n>=2 activeDemands=1 ... missionType=CAS_IMMEDIATE installationId=BLUE_GROUND_COP_FORTRESS ... personnelCommitted=9
```

Der Hit-Listener wird nach PASS über MOOSE `UnHandleEvent` beendet.

## 8. PASS-Kriterien

Alle Kriterien müssen gleichzeitig erfüllt sein:

```text
1. Das Bundle erzeugt genau einen frischen Acceptance-CampaignState aus dem aktuellen GroundInitialStock und attached GroundBase erfolgreich.
2. Fortress startet mit 160 available GROUND_PERSONNEL.
3. Genau 9 Fortress GROUND_PERSONNEL werden für die Test-Sentry-Deployment-Transaktion committed/consumed; danach 151 available.
4. TPL_BLUE_GND_INF_RIFLE_SQUAD_9 wird über MOOSE BRIGADE/PLATOON/Warehouse materialisiert.
5. Dieselbe Runtime-Gruppe erreicht AUFTRAG ONGUARD und wird danach dynamisch im Hit-Adapter registriert.
6. MOOSE EVENTS.Hit liefert mindestens zwei reale RED-on-BLUE Treffer an dieser Gruppe.
7. Beide Treffer werden als BLUE_GROUND_COP_FORTRESS qualifiziert.
8. Erster Treffer erzeugt genau einen CAS_IMMEDIATE Demand.
9. Zweiter Treffer erzeugt keinen zweiten Demand und liefert active_duplicate.
10. MissionDemand führt danach genau einen aktiven Demand für Fortress.
11. Kein CAS-AUFTRAG/COMMANDER/AIRWING/SQUADRON-Dispatch wird ausgeführt.
12. Kein world.addEventHandler/MIST/MissionScripting.lua-Pfad wird verwendet.
13. dcs.log enthält den expliziten PASS-Eintrag.
```

## 9. Nicht aus Acceptance 1 ableiten

Ein PASS beweist nicht:

```text
production CampaignState startup/persistence
Infantry casualty settlement
Infantry survivor return / recredit
cross-session restoration
production-wide sentry generation
all Fortress objects as attack triggers
CAS aircraft dispatch or mission success
arbitrary severity/priority classification
```

Diese Grenzen werden nicht durch den Testlauf erweitert.

## 10. Acceptance-Provenienz

Erst nach dem realen Lauf werden eingetragen:

```text
Git commit
BuilderVersion
Bundle SHA-256
MIZ filename
MIZ SHA-256
internal mission SHA-256, soweit nach Workflow erhoben
DCS version
MOOSE commit
Moose.lua SHA-256
dcs.log SHA-256
debrief.log SHA-256, soweit erzeugt
Result
```

Bis dahin bleibt dieser Stand `PLANNED` / `validated_in_dcs: false`.
