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
| `BRIGADE` | bereits in anderen Ground-Scopes `VALIDATED_FOR_DOCUMENTED_SCOPE`; neuer Infantry-Sentry-Scope noch nicht validiert | Fortress operational domain for materialization of one existing rifle-squad template through the public Warehouse/Legion lifecycle |
| `PLATOON` / `COHORT` | `SOURCE_REVIEWED` plus prior Ground lifecycle evidence; new infantry/ONGUARD combination pending | `PLATOON:New(TPL_BLUE_GND_INF_RIFLE_SQUAD_9, 1, ...)`, `AddMissionCapability(AUFTRAG.Type.ONGUARD, 100)` |
| `AUFTRAG` / `NewONGUARD` | `SOURCE_REVIEWED` for this exact mission type; acceptance staged | public GROUND/NAVAL ONGUARD mission at `ZON_BLUE_GND_FORTRESS_PATROL_TEST_01`; no custom sentry task |
| `ARMYGROUP` / `OPSGROUP` lifecycle | prior Ground scopes validated; new infantry ONGUARD scope pending | `OnAfterArmyOnMission` correlation and `OnAfterMissionExecute` proof before the dynamic group is registered as an attack target |
| `BASE` | `SOURCE_REVIEWED` / acceptance staged | `BASE:New()`, `HandleEvent(EVENTS.Hit, ...)`, `UnHandleEvent(EVENTS.Hit)` for the MOOSE-first Hit listener |
| `EVENTS.Hit` | `SOURCE_REVIEWED` / acceptance staged | real RED-on-BLUE hit against the dynamically materialized Fortress infantry group |
| `SCHEDULER` | already elsewhere `VALIDATED_FOR_DOCUMENTED_SCOPE`; new Stage-2 scope not independently validated | low-frequency post-start orchestration and 2-s PASS evaluation; no World/frame scan |

No status is raised to `VALIDATED_FOR_DOCUMENTED_SCOPE` by source or CI alone.

## 3. Source evidence for ONGUARD

The pinned `Moose.lua` exposes:

```lua
AUFTRAG:NewONGUARD(Coordinate)
```

for `GROUND` / `NAVAL`. It creates `AUFTRAG.Type.ONGUARD`, targets the supplied coordinate, configures OpenFire/Auto alarm state and constructs the mission DCS task. The OPSGROUP routing path contains an explicit ONGUARD/ARMOREDGUARD branch.

Therefore the Stage-2 sentry uses MOOSE `ONGUARD` directly rather than a project-specific DCS task.

## 4. Existing OMW physical template

The current Ground template contract already defines:

```text
TPL_BLUE_GND_INF_RIFLE_SQUAD_9
  7 x Soldier M4
  2 x Soldier M249
```

as a reusable physical representation suitable for local security. Acceptance 1 reuses this template and does not request a new dedicated BLUE test target.

## 5. CampaignState boundary

The acceptance reads the already-attached authoritative Ground context through `OMW.Ground.Base.GetContext()` and consumes nine `GROUND_PERSONNEL` from `GROUND_NODE_FORTRESS` for the test deployment.

This is campaign-domain bookkeeping, not MOOSE resource authority. BRIGADE/PLATOON/Warehouse only materialize the physical squad. Infantry casualty/return/restart settlement remains outside this acceptance.

## 6. Negative boundary

Not used:

```text
TST_BLUE_GND_FORTRESS_HIT_TARGET
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
PASS -> reconcile only the exactly observed BRIGADE/PLATOON/ONGUARD/EVENTS.Hit scope into master PROJECT-CLASS-INDEX and VERIFIED-METHODS
FAIL -> no status increase; document the failure and required correction
```
