---
document_id: OMW-TEST-ARMY-GROUND-ACCEPTANCE-1
status: PLANNED
document_class: ACCEPTANCE_TEST_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - planned scope and pass/fail criteria for the first ARMY Ground Foundation DCS runtime test
not_authoritative_for:
  - accepted runtime behavior before real DCS execution
  - final multi-node ground architecture
  - restart/reconstitution acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
supersedes:
superseded_by:
---

# ARMY Ground Foundation – Acceptance 1

## 1. Ziel

Der erste DCS-Laufzeit-Test soll ausschließlich den kleinsten MOOSE-first Ground-Lifecycle prüfen, der für die weitere Architektur kritisch ist.

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
PLATOON:New(TemplateGroupName, Ngroups, PlatoonName)
BRIGADE:AddPlatoon(Platoon)
COHORT:AddMissionCapability(...)
LEGION:AddMission(Mission)
AUFTRAG:NewPATROLZONE(Zone, Speed, Altitude, Formation)
AUFTRAG:SetReturnToLegion(false)
```

`BRIGADE` erbt `LEGION:AddMission(...)`.

## 4. Required Mission Editor objects

The owner-created test mission must contain exactly named prerequisites:

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

No `.miz` mutation is performed by ChatGPT.

## 5. Planned runtime objects

```text
BDE_BLUE_GND_JOYCE

PLT_BLUE_GND_JOYCE_PATROL
  template: TPL_BLUE_GND_PATROL_MATV_4
  Ngroups: 1 for Acceptance 1 only
  mission capability: PATROLZONE
```

Acceptance 1 deliberately uses one asset group even though the production role baseline may contain additional Joyce assets.

## 6. Mission sequence

### Phase A – startup

Expected:

```text
warehouse host resolved
BRIGADE constructed
PLATOON constructed
PLATOON added to BRIGADE
BRIGADE started
one PATROLZONE-capable asset available
```

Failure of any required Mission Editor object lookup is an immediate test FAIL.

### Phase B – first mission

Create a ground PATROLZONE AUFTRAG against:

```text
ZON_BLUE_GND_JOYCE_PATROL_TEST_01
```

The mission must use:

```text
SetReturnToLegion(false)
```

Expected:

```text
one Joyce patrol asset selected
one physical group materialized
no second duplicate group
vehicle group moves toward / operates in patrol zone
```

### Phase C – mission completion

The first mission must be ended through its normal AUFTRAG lifecycle/test completion path.

Expected:

```text
MissionDone occurs
physical ARMYGROUP remains alive and present
no Returned -> Warehouse physical removal occurs
asset is not credited as newly available strategic stock
```

### Phase D – follow-up assignment

A second simple ground mission is assigned to the same operational asset after the first mission is complete.

Expected:

```text
same physical group remains usable
no additional physical group is spawned for the same asset
follow-up mission begins on the existing group
```

## 7. CampaignState boundary in Acceptance 1

The first runtime test does not implement the complete CampaignState adapter yet.

It must nevertheless preserve the invariant in its test bookkeeping:

```text
before physical materialization:
  reservation state = RESERVED / COMMITTED

after MissionDone with SetReturnToLegion(false):
  reservation remains FIELD_DEPLOYED / COMMITTED
  NOT AVAILABLE
```

No MOOSE Warehouse count or Returned event may be treated as strategic credit.

The later production adapter will implement the authoritative CampaignState mutation path.

## 8. Required log evidence

The runtime test must emit deterministic log lines with at least:

```text
OMW_GND_A1 START
OMW_GND_A1 WAREHOUSE_RESOLVED
OMW_GND_A1 BRIGADE_STARTED
OMW_GND_A1 PLATOON_READY
OMW_GND_A1 MISSION1_QUEUED
OMW_GND_A1 GROUP_MATERIALIZED <group-name>
OMW_GND_A1 MISSION1_DONE
OMW_GND_A1 GROUP_STILL_ALIVE <group-name>
OMW_GND_A1 MISSION2_QUEUED
OMW_GND_A1 SAME_GROUP_REUSED <group-name>
OMW_GND_A1 PASS
```

Any unexpected second materialization for the same asset must log:

```text
OMW_GND_A1 FAIL DUPLICATE_GROUP
```

Any visible/automatic removal after MissionDone must log FAIL when detectable from the test harness.

## 9. PASS criteria

All must be true:

```text
[ ] exact required ME objects resolved
[ ] BRIGADE starts successfully
[ ] PLATOON asset is available
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

A pathfinding FAIL does not automatically disprove the entire BRIGADE/PLATOON architecture; it must be classified separately as route/terrain failure if the lifecycle up to that point is correct.

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
mission filename
mission SHA-256
runtime/test bundle SHA-256
DCS version
Moose.lua SHA-256 / commit
relevant dcs.log excerpt
PASS/FAIL observations
```

`VALIDATED` is forbidden before that real DCS evidence exists.
