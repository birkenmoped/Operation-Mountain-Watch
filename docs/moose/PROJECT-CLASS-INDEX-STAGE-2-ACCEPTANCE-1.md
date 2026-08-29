---
document_id: OMW-MOOSE-CLASS-INDEX-STAGE-2-ACCEPTANCE-1
status: VALIDATED_FOR_DOCUMENTED_SCOPE
document_class: MOOSE_CLASS_REGISTER_ADDENDUM
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Stage 2 MOOSE class evidence validated by DCS Acceptance 1
not_authoritative_for:
  - master PROJECT-CLASS-INDEX status on main before merge/reconciliation
  - broader OPSZONE behavior outside the exact documented Acceptance-1 scope
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - Stage 2 Acceptance-1 EVENTS.Hit qualification evidence
  - dedicated BLUE test-target version of Stage 2 Acceptance 1
  - Acceptance-1 standalone CampaignState/GroundBase bootstrap variant
  - dedicated Fortress patrol-test-zone dependency for ONGUARD
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: e3bc977e35ab3a06a5417124684250ae50a15a8b
validated_in_dcs: true
---

# Stage 2 Acceptance 1 – MOOSE class evidence

## 1. Pinned framework

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## 2. Branch-local class status after DCS Acceptance 1

| Klasse/Pfad | Status | Stage-2-Verwendung |
|---|---|---|
| `BRIGADE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` for this Acceptance-1 composition | Fortress operational domain for one existing rifle-squad template through public Warehouse/Legion lifecycle |
| `LEGION` / `WAREHOUSE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` for Warehouse-coordinate anchor use | `BRIGADE -> LEGION -> WAREHOUSE`; public `WAREHOUSE:GetCoordinate()` supplies Fortress guard/security anchor from `WH_BLUE_GND_FORTRESS` |
| `PLATOON` / `COHORT` | `VALIDATED_FOR_DOCUMENTED_SCOPE` for this infantry/ONGUARD composition | `PLATOON:New(TPL_BLUE_GND_INF_RIFLE_SQUAD_9, 1, ...)`, `AddMissionCapability(AUFTRAG.Type.ONGUARD, 100)` |
| `AUFTRAG` / `NewONGUARD` | `VALIDATED_FOR_DOCUMENTED_SCOPE` for this Fortress local-security mission | keeps a real BLUE local-security squad at the Warehouse-derived installation anchor |
| `ARMYGROUP` / `OPSGROUP` lifecycle | `VALIDATED_FOR_DOCUMENTED_SCOPE` for the observed sentry mission path | `OnAfterArmyOnMission` and `OnAfterMissionExecute` proved the Sentry executing before the perimeter monitor started |
| `ZONE_RADIUS` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | runtime 1000 m circular security perimeter from `warehouseCoordinate:GetVec2()`; no ME security zone |
| `OPSZONE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | BLUE-owned installation perimeter detected hostile RED Ground presence and raised FSM `Attacked` |
| `OPSZONE:SetObjectCategories` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | scan restricted to `Object.Category.UNIT`; Statics did not satisfy BLUE presence in this acceptance |
| `OPSZONE:SetUnitCategories` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | units restricted to `Unit.Category.GROUND_UNIT` |
| `OPSZONE:SetCaptureThreatlevel` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Acceptance value `0`; defended-zone `Attacked` path qualified RED presence |
| `OPSZONE:SetCaptureNunits` | `VALIDATED_FOR_DOCUMENTED_SCOPE` only as configured capture-branch parameter | value `1`; not the defended-zone `Attacked` unit threshold |
| `OPSZONE:SetDrawZone` / `SetMarkZone` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | runtime security perimeter remained unmarked/undrawn |
| `OPSZONE.UpdateSeconds` | `VALIDATED_FOR_DOCUMENTED_SCOPE` for direct field override before `Start()` | Acceptance-only value `5` seconds; production cadence remains undecided |
| `OPSZONE OnAfterAttacked` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | `OnAfterAttacked(From, Event, To, AttackerCoalition)` emitted the qualified installation threat |
| `SCHEDULER` | existing validated class; Acceptance-1 orchestration observed | five-second post-BRIGADE-start orchestration and PASS evaluation; no custom presence scan |

Validation is limited to the exact runtime composition documented below. It does not generalize to arbitrary OPSZONE ownership/capture/contested scenarios.

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
-> RED satisfying capture unit/threat criteria can enter capture processing

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
CaptureNunits      = 1 (capture semantics retained explicitly)
DrawZone           = false
MarkZone           = false
UpdateSeconds      = 5 (Acceptance only)
```

For the defended BLUE-zone attack branch, the practical alarm condition is `Nred > 0` plus `Tred >= 0`; `CaptureNunits` is not consulted by that branch.

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

## 9. DCS Acceptance-1 runtime evidence

Observed on 2026-08-29 in DCS 2.9.29.27278:

```text
SENTRY_ON_MISSION
SENTRY_ONGUARD_EXECUTING
OPSZONE OMW_SECURITY_BLUE_GROUND_COP_FORTRESS | Starting OPSZONE v0.6.2
[FobThreatOpsZoneAdapter] started MOOSE OPSZONE security perimeter zone=OMW_SECURITY_BLUE_GROUND_COP_FORTRESS radiusM=1000 owner=2 updateSeconds=5 threatlevel=0 captureNunits=1
READY ... securityRadiusM=1000 detection=OPSZONE_ATTACKED scanSeconds=5
QUALIFIED_THREAT count=1 ... evidence=OPSZONE_ATTACKED
DEMAND_RESULT ... created=true reason=nil
PASS qualifiedThreats=1 activeDemands=1 ... missionType=CAS_IMMEDIATE installationId=BLUE_GROUND_COP_FORTRESS ... personnelBefore=160 personnelAfterCommit=151 securityRadiusM=1000 detection=OPSZONE_ATTACKED
OPSZONE OMW_SECURITY_BLUE_GROUND_COP_FORTRESS | Stopping OPSZONE
```

This validates the exact Stage-2 MOOSE-first chain:

```text
Warehouse coordinate
-> runtime ZONE_RADIUS 1000 m
-> BLUE OPSZONE
-> RED Ground presence while BLUE local-security presence remains
-> OPSZONE Attacked
-> OnAfterAttacked(..., RED)
-> qualified threat
-> one CAS_IMMEDIATE MissionDemand
```

No `EVENTS.Hit` or `EVENTS.Shot` was required for qualification.

## 10. Provenance

```text
Tested source commit: e3bc977e35ab3a06a5417124684250ae50a15a8b
BuilderVersion: FOB-ATTACK-THREAT-ACCEPTANCE-1-2
Acceptance Lua: OMW_FOB_Attack_Threat_Acceptance_1.lua
Acceptance bundle SHA-256: 9A3382BF0EE476ED105A5EEF56575C73EBE591AAA00C1C4B1DA7A55F27835650
DCS version: 2.9.29.27278
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
dcs.log SHA-256: 8C8821ABDD412258A1B2ABF18FC9AA8018767E80894B174DAFE982513B3D2B2D
debrief.log SHA-256: 081FE758DAE40933F011CE8156364BAC5EF40C13247150999F7CACE2159FD227
Owner-supplied MIZ artifact: OMW_Template_v20_GroundWorks(10).miz
Owner-supplied MIZ artifact SHA-256: 54E6562A095E771721E417CC8F5AEE0606066EA619E9E72D462E402A6D3EC118
Runtime debrief mission path: C:\Users\Sven\Saved Games\DCS.openbeta\Missions\OMW_Template_v20_GroundWorks.miz
Result: PASS
```

The filename difference between the uploaded MIZ artifact and the runtime debrief path is preserved explicitly; no identity beyond the owner-supplied test artifact is inferred from the filename alone.

## 11. Negative boundary

Not validated or used by this acceptance:

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
production OPSZONE scan cadence
```

## 12. Reconciliation

Acceptance 1 is `VALIDATED_FOR_DOCUMENTED_SCOPE` on this branch. On merge, reconcile only the exactly observed Stage-2 `ZONE_RADIUS / OPSZONE / OnAfterAttacked` scope plus the observed Ground lifecycle composition into the master `PROJECT-CLASS-INDEX` / `VERIFIED-METHODS` documentation. No broader OPSZONE behavior is implied.