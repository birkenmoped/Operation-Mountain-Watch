---
document_id: OMW-STAGE-2-FOB-ATTACK-HIT-ACCEPTANCE-1
status: PLANNED
document_class: DCS_ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 2 DCS acceptance plan for MOOSE EVENTS.Hit qualification
  - Fortress infantry sentry target and PASS criteria
not_authoritative_for:
  - runtime validation before the documented DCS run
  - production infantry loss/return settlement
  - CAS aircraft dispatch
  - general attack severity classification
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - dedicated TST_BLUE_GND_FORTRESS_HIT_TARGET Acceptance-1 target plan
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Stage 2 – FOB Attack Hit Acceptance 1

## 1. Ziel

Der Test bestätigt den Stage-2-Runtime-Pfad mit einer realen OMW-Fortress-Infanterierepräsentation statt einer künstlichen BLUE-Testzielgruppe:

```text
attached authoritative OMW Ground CampaignState
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

## 4. CampaignState-Gate

Der Test erzeugt keinen zweiten CampaignState-Store. Er verlangt, dass `OMW.Ground.Base` bereits mit dem autoritativen Store verbunden ist und liest diesen über:

```text
OMW.Ground.Base.GetContext()
```

Für die neun Soldaten wird genau eine Consumption-Transaktion angelegt:

```text
node: GROUND_NODE_FORTRESS
resource: GROUND_PERSONNEL
quantity: 9
transaction: STAGE2-A1-FORTRESS-SENTRY-PERSONNEL
```

Auf einem frischen aktuellen Ground-Bestand entspricht dies erwartungsgemäß:

```text
160 -> 151 available GROUND_PERSONNEL
```

Das eigentliche PASS-Kriterium ist jedoch `before - 9`, damit kein Ausgangswert geraten wird.

Wichtig: Acceptance 1 validiert nur die **Disposition/Commitment-Grenze** für diese Testgruppe. Tote, Überlebende, Rückkehr, Recredit und Restart dieser Infanteriegruppe werden hier nicht abgewickelt und nicht als produktiv validiert.

## 5. Mission-Editor-Gate

ChatGPT verändert die `.miz` nicht. Eine zusätzliche BLUE-Zielgruppe wie

```text
TST_BLUE_GND_FORTRESS_HIT_TARGET
```

ist ausdrücklich **nicht mehr erforderlich**.

Für den Lauf müssen die in Abschnitt 3 genannten bestehenden Fortress-Objekte/Templates in der tatsächlich verwendeten Mission vorhanden sein. Zusätzlich wird ein RED-Angreifer benötigt, der die materialisierte Rifle-Squad-Gruppe real beschießt. AI oder tester-kontrolliert ist zulässig; mindestens zwei echte RED-on-BLUE `EVENTS.Hit`-Ereignisse müssen an der dynamischen Runtime-Gruppe eintreffen.

Keine Trigger-Explosion, kein künstlicher Event-Aufruf und kein Native-DCS-Testhandler ersetzt die realen Treffer.

## 6. Bundle und Ladegrenze

Builder:

```text
tools/build-fob-attack-hit-acceptance-1.ps1
```

Output:

```text
mission/tests/fob-attack-support-demand/dist/OMW_FOB_Attack_Hit_Acceptance_1.lua
```

Der Acceptance-Bundle setzt voraus, dass der normale OMW Ground Base **vorher geladen und attached** wurde. Er enthält selbst keinen zweiten Ground Base und keinen zweiten strategischen Store.

Eingebettet werden nur:

```text
scripts/campaign/OMW_MissionDemand.lua
scripts/campaign/OMW_FobAttackDemandPolicy.lua
scripts/ground/OMW_FobAttackHitAdapter.lua
mission/tests/fob-attack-support-demand/src/01-fob-attack-hit-acceptance-1.lua
```

## 7. Runtime-Ablauf

Vor dem Angriff müssen im `dcs.log` nacheinander insbesondere erscheinen:

```text
PERSONNEL_COMMITTED ... quantity=9
SENTRY_QUEUED ... TPL_BLUE_GND_INF_RIFLE_SQUAD_9
SENTRY_ON_MISSION ...
SENTRY_ONGUARD_EXECUTING ...
READY targetGroup=<dynamic MOOSE/DCS runtime group> ...
```

Erst ab `READY` ist der dynamische Runtime-Gruppenname im Hit-Adapter registriert.

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
1. Ground Base ist bereits erfolgreich attached; kein zweiter CampaignState wird erstellt.
2. Genau 9 Fortress GROUND_PERSONNEL werden für die Test-Sentry-Deployment-Transaktion committed/consumed.
3. TPL_BLUE_GND_INF_RIFLE_SQUAD_9 wird über MOOSE BRIGADE/PLATOON/Warehouse materialisiert.
4. Dieselbe Runtime-Gruppe erreicht AUFTRAG ONGUARD und wird danach dynamisch im Hit-Adapter registriert.
5. MOOSE EVENTS.Hit liefert mindestens zwei reale RED-on-BLUE Treffer an dieser Gruppe.
6. Beide Treffer werden als BLUE_GROUND_COP_FORTRESS qualifiziert.
7. Erster Treffer erzeugt genau einen CAS_IMMEDIATE Demand.
8. Zweiter Treffer erzeugt keinen zweiten Demand und liefert active_duplicate.
9. MissionDemand führt danach genau einen aktiven Demand für Fortress.
10. Kein CAS-AUFTRAG/COMMANDER/AIRWING/SQUADRON-Dispatch wird ausgeführt.
11. Kein world.addEventHandler/MIST/MissionScripting.lua-Pfad wird verwendet.
12. dcs.log enthält den expliziten PASS-Eintrag.
```

## 9. Nicht aus Acceptance 1 ableiten

Ein PASS beweist nicht:

```text
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
