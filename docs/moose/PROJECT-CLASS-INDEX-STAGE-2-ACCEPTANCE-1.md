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
  - Stage 2 Acceptance-1 EVENTS.Hit qualification evidence
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
| `BRIGADE` | bereits in anderen Ground-Scopes `VALIDATED_FOR_DOCUMENTED_SCOPE`; neuer Infantry-Security-Scope noch nicht validiert | Fortress operational domain for one existing rifle-squad template through public Warehouse/Legion lifecycle |
| `LEGION` / `WAREHOUSE` | existing framework hierarchy; Stage-2 anchor use source-reviewed | `BRIGADE -> LEGION -> WAREHOUSE`; public `WAREHOUSE:GetCoordinate()` supplies Fortress guard/security anchor from `WH_BLUE_GND_FORTRESS` |
| `PLATOON` / `COHORT` | `SOURCE_REVIEWED` plus prior Ground lifecycle evidence; new infantry/ONGUARD combination pending | `PLATOON:New(TPL_BLUE_GND_INF_RIFLE_SQUAD_9, 1, ...)`, `AddMissionCapability(AUFTRAG.Type.ONGUARD, 100)` |
| `AUFTRAG` / `NewONGUARD` | `SOURCE_REVIEWED` for this exact mission type; acceptance staged | keeps a real BLUE local-security squad at the Warehouse-derived installation anchor |
| `ARMYGROUP` / `OPSGROUP` lifecycle | prior Ground scopes validated; new infantry ONGUARD scope pending | `OnAfterArmyOnMission` and `OnAfterMissionExecute` prove the Sentry is executing before the perimeter monitor starts |
| `ZONE_RADIUS` | `SOURCE_REVIEWED`; DCS Stage-2 runtime pending | runtime 1000 m circular security perimeter from `warehouseCoordinate:GetVec2()`; no ME security zone |
| `OPSZONE` | `SOURCE_REVIEWED`; DCS Stage-2 runtime pending | BLUE-owned installation perimeter; scans hostile Ground presence and raises FSM `Attacked` |
| `OPSZONE:SetObjectCategories` | `SOURCE_REVIEWED`; DCS Stage-2 runtime pending | restricts scan to `Object.Category.UNIT`; Statics do not satisfy BLUE presence in this acceptance |
| `OPSZONE:SetUnitCategories` | `SOURCE_REVIEWED`; DCS Stage-2 runtime pending | restricts units to `Unit.Category.GROUND_UNIT` |
| `OPSZONE:SetCaptureThreatlevel` | `SOURCE_REVIEWED`; DCS Stage-2 runtime pending | Acceptance value `0`: any RED Ground unit inside the security perimeter is alarm-worthy |
| `OPSZONE:SetCaptureNunits` | `SOURCE_REVIEWED`; DCS Stage-2 runtime pending | Acceptance value `1` |
| `OPSZONE:SetDrawZone` / `SetMarkZone` | `SOURCE_REVIEWED`; DCS Stage-2 runtime pending | runtime security perimeter stays off the F10 map |
| `OPSZONE.UpdateSeconds` | source-verified public class field consumed by `onafterStart`; no dedicated setter exists in pinned source | Acceptance-only value `5` seconds to avoid the class default 120-second evaluation interval during manual DCS testing |
| `OPSZONE OnAfterAttacked` | `SOURCE_REVIEWED`; DCS Stage-2 runtime pending | `OnAfterAttacked(From, Event, To, AttackerCoalition)` is the MOOSE-first boundary that emits the qualified installation threat |
| `SCHEDULER` | already elsewhere `VALIDATED_FOR_DOCUMENTED_SCOPE`; new Stage-2 scope not independently validated | five-second post-BRIGADE-start orchestration and PASS evaluation; no custom presence scan |

No status is raised to `VALIDATED_FOR_DOCUMENTED_SCOPE` by source or CI alone.

## 3. Source evidence for runtime security zone

The pinned `Moose.lua` explicitly demonstrates:

```lua
OPSZONE:New(
  ZONE_RADIUS:New("OpsZoneTwo", mycoordinate:GetVec2(), 5000),
  coalition.side.BLUE
)
```

`OPSZONE:New` accepts `ZONE_RADIUS`, creates internal unit/group scan sets for that zone, and records the supplied coalition as the initial owner.

For the OMW acceptance this becomes:

```text
WH_BLUE_GND_FORTRESS
-> BRIGADE/WAREHOUSE:GetCoordinate()
-> COORDINATE:GetVec2()
-> ZONE_RADIUS(..., 1000)
-> OPSZONE(..., BLUE)
```

No Mission-Editor security trigger zone is required.

## 4. Source evidence for threat qualification

For a BLUE-owned OPSZONE the pinned `EvaluateZone()` path distinguishes two cases:

```text
Nblu == 0
-> RED satisfying threshold can enter capture processing

Nblu > 0 AND Nred > 0 AND Tred >= threatlevelCapture
-> Attacked(coalition.side.RED)
```

Therefore Stage 2 deliberately retains a real BLUE local-security squad inside the perimeter. It is not a hit target; it supplies the defended BLUE presence required for the intended `Attacked` state.

The public FSM callback signature is documented and implemented as:

```lua
OnAfterAttacked(From, Event, To, AttackerCoalition)
```

This removes the need for an OMW `EVENTS.Hit` listener for the primary installation-alarm condition.

## 5. OPSZONE scan configuration

Acceptance 1 configures:

```text
ObjectCategories   = UNIT only
UnitCategories     = GROUND_UNIT only
CaptureThreatlevel = 0
CaptureNunits      = 1
DrawZone           = false
MarkZone           = false
UpdateSeconds      = 5 (Acceptance only)
```

The pinned source documents default `UpdateSeconds = 120` and `onafterStart()` reads `self.UpdateSeconds` before starting its status timer. The five-second override is limited to the acceptance harness; production cadence remains a separate later configuration decision.

## 6. Existing OMW physical template and CampaignState boundary

The current Ground template contract defines:

```text
TPL_BLUE_GND_INF_RIFLE_SQUAD_9
  7 x Soldier M4
  2 x Soldier M249
```

Acceptance 1 uses the already loaded and attached OMW Ground context:

```text
OMW.AirOps.CampaignContext
-> existing OMW_Ground_Base.lua
-> existing mission GroundBase.Attach(...)
-> OMW.Ground.Base.GetContext()
-> consume nine GROUND_PERSONNEL from GROUND_NODE_FORTRESS
```

CampaignState remains strategic authority. BRIGADE/PLATOON/Warehouse and OPSZONE remain operational/runtime representations only.

## 7. ACCESS-zone boundary

`ZON_BLUE_GND_FORTRESS_ACCESS` remains part of the existing materialization boundary for the BRIGADE spawn path.

It is **not** reused as the installation security perimeter. Current Ground authority defines ACCESS zones as operational materialization/departure/return/handoff boundaries, not installation geometry.

## 8. Superseded Hit path

The earlier branch-local MOOSE path:

```text
BASE:HandleEvent(EVENTS.Hit, ...)
-> registered dynamic Sentry target
-> physical RED-on-BLUE hit
```

is superseded for Stage-2 primary threat qualification. Real DCS testing showed this condition is unnecessarily late and fragile for the intended alarm semantics.

Git history retains that investigation; the active implementation now uses runtime `ZONE_RADIUS -> OPSZONE -> OnAfterAttacked`.

## 9. Negative boundary

Not used by the active Stage-2 acceptance:

```text
EVENTS.Hit as mandatory trigger
EVENTS.Shot as mandatory trigger
TST_BLUE_GND_FORTRESS_HIT_TARGET
ZON_BLUE_GND_FORTRESS_SECURITY in Mission Editor
ZON_BLUE_GND_FORTRESS_PATROL_TEST_01
second CampaignState store
Acceptance-specific Ground startup bridge
SPAWN direct materialization
world.addEventHandler
MIST
native timer.scheduleFunction
custom/native presence scanner
AUFTRAG:NewCAS
COMMANDER:AddMission for CAS
AIRWING/SQUADRON dispatch
```

## 10. Reconciliation

After a real Acceptance-1 run with complete provenance:

```text
PASS
-> reconcile only the exactly observed ZONE_RADIUS / OPSZONE / OnAfterAttacked plus already observed Ground lifecycle scope into master PROJECT-CLASS-INDEX and VERIFIED-METHODS

FAIL
-> no status increase; document the observed failure and required correction
```
