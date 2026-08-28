---
document_id: OMW-TEST-ARMY-GROUND-ACCEPTANCE-1
status: PLANNED
document_class: ACCEPTANCE_TEST_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - planned scope and pass/fail criteria for the first ARMY Ground Foundation DCS runtime test
  - object-contract preflight for OMW_Template_v13_ground_test.miz
not_authoritative_for:
  - accepted runtime behavior before real DCS execution
  - final multi-node ground architecture
  - restart/reconstitution acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/army-ground-foundation-reconciliation
source_commit: 998080da9a7a71dae7f713b9590dfeadb5ae93ba
validated_in_dcs: false
supersedes:
superseded_by:
---

# ARMY Ground Foundation – Acceptance 1

## 1. Ziel

Der erste DCS-Laufzeit-Test prüft ausschließlich den kleinsten MOOSE-first Ground-Lifecycle, der für die weitere Architektur kritisch ist.

```text
one Ground Node
-> one BRIGADE
-> one PLATOON
-> one physical mobile ARMYGROUP
-> one PATROLZONE AUFTRAG
-> SetReturnToLegion(false)
-> MissionDone
-> physical group stays in field
-> same physical group can receive a follow-up mission
```

Der Test ist bewusst kein vollständiger Patrol-/QRF-/CampaignState-Integrationstest.

## 2. Test node

```text
GROUND_NODE_JOYCE
```

Begründung:

- ausreichend repräsentativer operativer FOB;
- kleiner und übersichtlicher als Jalalabad/Fenty;
- keine OP-/Artillerie-Sonderlogik für den ersten Lifecycle notwendig;
- vorhandene geplante PATROL-Rolle mit eindeutigem Template.

## 3. Gepinnte MOOSE-Basis

```text
MOOSE 2.9.18
commit 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256 e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Source-geprüfte APIs für den Test:

```lua
BRIGADE:New(WarehouseName, BrigadeName)
BRIGADE:AddPlatoon(Platoon)
WAREHOUSE:SetSpawnZone(zone, maxdist)
PLATOON:New(TemplateGroupName, Ngroups, PlatoonName)
COHORT:AddMissionCapability(MissionTypes, Performance)
COHORT:CountAssets(InStock, MissionTypes, Attributes)
LEGION:AddMission(Mission)
AUFTRAG:NewPATROLZONE(Zone, Speed, Altitude, Formation)
AUFTRAG:SetReturnToLegion(false)
AUFTRAG:__Cancel(delay)
SCHEDULER:New(MasterObject, SchedulerFunction, SchedulerArguments, Start, Repeat, RandomizeFactor, Stop)
```

`BRIGADE` erbt `WAREHOUSE:SetSpawnZone(...)` und `LEGION:AddMission(...)`. `AUFTRAG:__Cancel(...)` ist der vom AUFTRAG-FSM erzeugte verzögerte `Cancel`-Eventpfad; `onafterCancel(...)` leitet die Abbruchanforderung an LEGION/OPSGROUP weiter und wartet auf `MissionDone`.

Die tatsächlich verwendete `Moose.lua` ist für diese Signaturen maßgeblich. Der aktuelle MOOSE-Demo-Review liefert weiterhin keinen direkten Referenztest für die konkrete OMW-Kombination `BRIGADE -> PLATOON -> ARMYGROUP`; Acceptance 1 bleibt deshalb erforderlich.

## 4. Required Mission Editor objects

Die Owner-erstellte Testmission muss exakt enthalten:

```text
WH_BLUE_GND_JOYCE
  STATIC or UNIT warehouse host

TPL_BLUE_GND_PATROL_MATV_4
  late activated
  4 x CHAP_MATV

ZON_BLUE_GND_JOYCE_ACCESS
  road-side handoff/materialization area

ZON_BLUE_GND_JOYCE_PATROL_TEST_01
  reachable patrol target zone
```

ChatGPT mutiert keine `.miz`.

### 4.1 Read-only object-contract preflight – v13

Vom Projektinhaber bereitgestelltes Artefakt:

```text
Mission artifact: OMW_Template_v13_ground_test.miz
MIZ SHA-256: 6d12a55affc971de1de4d5e463c956fcb2e08a0d2de478ff13419747a825e7e8
internal mission SHA-256: 22d13cb7b0da0a6fb9ddc02bf9b99c4da50d2c96b31bdc6a353616a4188c6b80
embedded Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
embedded MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
```

Read-only inspection confirms:

```text
WH_BLUE_GND_JOYCE
  category: STATIC
  DCS type: HESCO_generator
  x=119063.74810988
  y=443069.84287213

TPL_BLUE_GND_PATROL_MATV_4
  lateActivation=true
  4 units
  each type=CHAP_MATV
  skill=High

ZON_BLUE_GND_JOYCE_ACCESS
  center x=118891.33372138
  center y=442576.88110835
  radius=152.4 m

ZON_BLUE_GND_JOYCE_PATROL_TEST_01
  center x=113940.01874642
  center y=434531.02338035
  radius=182.88 m
```

Geometric preflight:

```text
representative template position -> ACCESS center: ~638 m
ACCESS center -> PATROL_TEST_01 center: ~9.45 km
```

Damit ist der **strukturelle ME-Objektvertrag** für Acceptance 1 erfüllt. Die Geometrie beweist ausdrücklich **nicht**, dass DCS Ground AI die Strecke zuverlässig auf Straße beziehungsweise Gelände fährt; genau das ist Teil des realen DCS-Laufs.

Jedes erneute Speichern oder Verändern der `.miz` invalidiert diese Hash-/Objektvertragszuordnung und verlangt den erneuten Smoke gemäß `OMW-TEST-MISSION-BUILD-TRANSFER-VALIDATION`.

## 5. Planned runtime objects

```text
BDE_BLUE_GND_JOYCE

PLT_BLUE_GND_JOYCE_PATROL
  template: TPL_BLUE_GND_PATROL_MATV_4
  Ngroups: 1 for Acceptance 1 only
  mission capability: PATROLZONE
```

Acceptance 1 verwendet bewusst nur eine Assetgruppe, obwohl die Production-Rollenbaseline zusätzliche Joyce-Assets vorsieht.

Runtime source/build contract:

```text
source:
mission/tests/army-ground-foundation/src/01-army-ground-acceptance-1.lua

builder:
tools/build-army-ground-acceptance-1.ps1

bundle:
mission/tests/army-ground-foundation/dist/OMW_Army_Ground_Acceptance_1.lua

BuilderVersion / Test-ID:
ARMY-GROUND-ACCEPTANCE-1-1
```

Der Builder verändert keine `.miz`.

## 6. Mission sequence

### Phase A – startup

Expected:

```text
warehouse host resolved
BRIGADE constructed
ACCESS zone assigned as WAREHOUSE spawn zone
PLATOON constructed
PLATOON added to BRIGADE
BRIGADE started
one PATROLZONE-capable asset available after start
```

Failure of any required Mission Editor object lookup is an immediate test FAIL.

### Phase B – first mission

Create a ground PATROLZONE AUFTRAG against:

```text
ZON_BLUE_GND_JOYCE_PATROL_TEST_01
```

The mission uses:

```text
SetReturnToLegion(false)
```

The acceptance harness schedules `AUFTRAG:__Cancel(...)` after the first ARMYGROUP is on mission. This exercises the normal AUFTRAG/LEGION/OPSGROUP cancellation-to-`MissionDone` path instead of directly deleting or respawning the group.

Expected:

```text
one Joyce patrol asset selected
one physical group materialized
no second duplicate group
vehicle group moves toward / operates in patrol zone
```

### Phase C – mission completion

Expected:

```text
MissionDone occurs
physical ARMYGROUP remains alive and present
no Returned -> Warehouse physical removal occurs
acceptance bookkeeping remains FIELD_DEPLOYED / COMMITTED
asset is not credited as newly available strategic stock
```

### Phase D – follow-up assignment

A second PATROLZONE mission is queued after MissionDone.

Expected:

```text
same ARMYGROUP object/name is selected
same physical group remains usable
no additional physical group is spawned for the same asset
follow-up mission begins on the existing group
```

## 7. CampaignState boundary in Acceptance 1

The first runtime test does not implement the complete CampaignState adapter yet.

It preserves the invariant in local test bookkeeping:

```text
before physical materialization:
  reservation state = RESERVED / COMMITTED

after MissionDone with SetReturnToLegion(false):
  reservation remains FIELD_DEPLOYED / COMMITTED
  NOT AVAILABLE
```

No MOOSE Warehouse count or Returned event is treated as strategic credit.

The later production adapter will implement the authoritative CampaignState mutation path.

## 8. Required log evidence

The runtime test emits deterministic markers including:

```text
OMW_GND_A1 START
OMW_GND_A1 WAREHOUSE_RESOLVED
OMW_GND_A1 BRIGADE_STARTED
OMW_GND_A1 PLATOON_READY
OMW_GND_A1 MISSION1_QUEUED
OMW_GND_A1 GROUP_MATERIALIZED <group-name>
OMW_GND_A1 MISSION1_CANCEL_SCHEDULED
OMW_GND_A1 MISSION1_DONE
OMW_GND_A1 GROUP_STILL_ALIVE <group-name>
OMW_GND_A1 MISSION2_QUEUED
OMW_GND_A1 SAME_GROUP_REUSED <group-name>
OMW_GND_A1 PASS
```

Any unexpected second materialization for the same asset logs:

```text
OMW_GND_A1 FAIL DUPLICATE_GROUP
```

Any automatic removal after MissionDone must log FAIL when detectable from the test harness.

## 9. PASS criteria

All must be true:

```text
[ ] exact required ME objects resolved
[ ] embedded Moose.lua hash/commit matches pinned acceptance basis
[ ] BRIGADE starts successfully
[ ] PLATOON reports exactly one in-stock PATROLZONE-capable asset after start
[ ] first PATROLZONE mission selects/materializes exactly one group
[ ] group moves/executes without immediate pathfinding failure
[ ] MissionDone with SetReturnToLegion(false) does not remove the group
[ ] same physical group remains alive after mission completion
[ ] follow-up mission reuses that group without duplicate materialization
[ ] no automatic strategic resource credit is inferred from MOOSE state
[ ] no player-visible teleport/despawn occurs
```

## 10. FAIL criteria

Any of the following is sufficient:

```text
warehouse/static cannot be resolved
PLATOON cannot register its template asset
BRIGADE cannot select the expected PATROL asset
more than one physical copy appears for one asset
MissionDone removes/despawns the group despite legionReturn=false
follow-up mission requires duplicate/re-materialized group
initial route cannot leave the ACCESS/road area in a reproducible manner
runtime Lua error
```

A pathfinding FAIL does not automatically disprove the entire BRIGADE/PLATOON architecture; it is classified separately as route/terrain failure if the lifecycle up to that point is correct.

## 11. Explicitly out of scope

Acceptance 1 does not validate:

```text
restart/reconstitution
Returned -> Warehouse handoff
OPSTRANSPORT
OP reinforcement
QRF
multi-BRIGADE selection
artillery
M978 fuel logistics
combat-loss settlement
multiplayer synchronization
full CampaignState persistence adapter
```

## 12. Required provenance after real test

The test result may only be recorded after the owner returns the real local output including:

```text
branch
source commit
BuilderVersion/Test-ID
mission filename
mission SHA-256
internal mission SHA-256
runtime/test bundle SHA-256
embedded runtime/test bundle SHA-256
DCS version
Moose.lua SHA-256 / commit
relevant dcs.log excerpt
PASS/FAIL observations
```

`VALIDATED` is forbidden before that real DCS evidence exists.
