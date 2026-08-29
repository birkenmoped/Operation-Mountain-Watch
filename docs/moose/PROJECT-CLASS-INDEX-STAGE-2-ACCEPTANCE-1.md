---
document_id: OMW-MOOSE-CLASS-INDEX-STAGE-2-ACCEPTANCE-1
status: PLANNED
document_class: MOOSE_CLASS_REGISTER_ADDENDUM
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Stage 2 MOOSE class evidence pending DCS Acceptance 1
not_authoritative_for:
  - master PROJECT-CLASS-INDEX status on main
  - DCS runtime validation before Acceptance 1 is executed
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - dedicated BLUE test-target version of Stage 2 Acceptance 1
  - Acceptance-1 standalone CampaignState/GroundBase bootstrap variant
  - dedicated Fortress patrol-test-zone dependency for ONGUARD
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Stage 2 Acceptance 1 – MOOSE class evidence

## 1. Pinned framework

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## 2. Branch-local class status

| Klasse/Pfad | Status vor DCS-Lauf | Stage-2-Verwendung |
|---|---|---|
| `BRIGADE` | bereits in anderen Ground-Scopes `VALIDATED_FOR_DOCUMENTED_SCOPE`; neuer Infantry-Sentry-Scope noch nicht validiert | Fortress operational domain for one existing rifle-squad template through the public Warehouse/Legion lifecycle |
| `LEGION` / `WAREHOUSE` | existing framework hierarchy; Stage-2 guard-point use source-reviewed | `BRIGADE -> LEGION -> WAREHOUSE`; public `WAREHOUSE:GetCoordinate()` supplies the Fortress guard coordinate from `WH_BLUE_GND_FORTRESS` |
| `PLATOON` / `COHORT` | `SOURCE_REVIEWED` plus prior Ground lifecycle evidence; new infantry/ONGUARD combination pending | `PLATOON:New(TPL_BLUE_GND_INF_RIFLE_SQUAD_9, 1, ...)`, `AddMissionCapability(AUFTRAG.Type.ONGUARD, 100)` |
| `AUFTRAG` / `NewONGUARD` | `SOURCE_REVIEWED` for this exact mission type; acceptance staged | public GROUND/NAVAL ONGUARD mission at the runtime Fortress warehouse coordinate; no ME guard zone and no custom sentry task |
| `ARMYGROUP` / `OPSGROUP` lifecycle | prior Ground scopes validated; new infantry ONGUARD scope pending | `OnAfterArmyOnMission` correlation and `OnAfterMissionExecute` proof before dynamic group registration as attack target |
| `BASE` | `SOURCE_REVIEWED` / acceptance staged | `BASE:New()`, `HandleEvent(EVENTS.Hit, ...)`, `UnHandleEvent(EVENTS.Hit)` for the MOOSE-first Hit listener |
| `EVENTS.Hit` | `SOURCE_REVIEWED` / acceptance staged | real RED-on-BLUE hit against the dynamically materialized Fortress infantry group |
| `SCHEDULER` | already elsewhere `VALIDATED_FOR_DOCUMENTED_SCOPE`; new Stage-2 scope not independently validated | five-second post-BRIGADE-start orchestration and two-second PASS evaluation; no World/frame scan |

No status is raised to `VALIDATED_FOR_DOCUMENTED_SCOPE` by source or CI alone.

## 3. Source evidence for the guard point

The pinned `Moose.lua` establishes this inheritance chain:

```text
BRIGADE:New(...)
-> LEGION:New(...)
-> WAREHOUSE:New(...)
```

and publicly exposes:

```lua
function WAREHOUSE:GetCoordinate()
  return self.warehouse:GetCoord()
end
```

Therefore the Stage-2 Sentry can derive its guard point directly from the Fortress physical warehouse structure through:

```lua
brigade:GetCoordinate()
```

No Mission-Editor trigger zone is required for this coordinate.

The pinned `Moose.lua` also exposes:

```lua
AUFTRAG:NewONGUARD(Coordinate)
```

for `GROUND` / `NAVAL`; the OPSGROUP routing path has an explicit ONGUARD/ARMOREDGUARD branch.

## 4. Existing OMW physical template

The current Ground template contract defines:

```text
TPL_BLUE_GND_INF_RIFLE_SQUAD_9
  7 x Soldier M4
  2 x Soldier M249
```

as a reusable physical representation suitable for local security. Acceptance 1 reuses this template and does not request a new dedicated BLUE test target.

## 5. CampaignState boundary

Acceptance 1 uses the already loaded and attached OMW Ground context from the current test mission:

```text
OMW.AirOps.CampaignContext
-> existing OMW_Ground_Base.lua
-> existing mission GroundBase.Attach(...)
-> OMW.Ground.Base.GetContext()
-> consume nine GROUND_PERSONNEL from GROUND_NODE_FORTRESS
```

The Stage-2 bundle creates no CampaignState and no parallel Ground context.

CampaignState remains strategic authority. BRIGADE/PLATOON/Warehouse only materialize the physical squad. Infantry casualty/return/restart settlement remains outside this acceptance.

## 6. Negative boundary

Not used:

```text
TST_BLUE_GND_FORTRESS_HIT_TARGET
ZON_BLUE_GND_FORTRESS_PATROL_TEST_01
dedicated Mission-Editor guard zone
second CampaignState store
Acceptance-specific Ground startup bridge
SPAWN direct materialization
world.addEventHandler
MIST
native timer.scheduleFunction
custom/native Sentry task
AUFTRAG:NewCAS
COMMANDER:AddMission for CAS
AIRWING/SQUADRON dispatch
```

## 7. Reconciliation

After a real Acceptance-1 run with complete provenance:

```text
PASS -> reconcile only the exactly observed BRIGADE/PLATOON/WAREHOUSE:GetCoordinate/ONGUARD/EVENTS.Hit scope into master PROJECT-CLASS-INDEX and VERIFIED-METHODS
FAIL -> no status increase; document the failure and required correction
```
