---
document_id: OMW-STAGE-2-FOB-ATTACK-SUPPORT-DEMAND
status: PLANNED
document_class: DOMAIN_AND_MOOSE_SOURCE_REVIEW
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 2 FOB/COP threat-to-MissionDemand contract
  - separation of MOOSE perimeter threat qualification from MissionDemand creation
  - active-demand dedupe boundary for repeated threat evidence
not_authoritative_for:
  - DCS runtime validation before documented Acceptance 1
  - CAS aircraft dispatch or BLUE COMMANDER execution
  - final attack severity or priority classification
  - arbitrary time-based attack cooldowns
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - Stage 2 requirement for a real RED-on-BLUE EVENTS.Hit before support demand creation
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Stage 2 – FOB/COP threat -> support demand

## 1. Corrected operational scope

Stage 2 models an automatic response to a possible or ongoing attack on a BLUE Ground installation:

```text
hostile RED ground presence inside installation security perimeter
-> MOOSE OPSZONE Attacked
-> qualified installation threat incident
-> MissionDemand CAS_IMMEDIATE
```

A physical hit on BLUE is no longer required. The operational reason is explicit: a FOB/COP can raise an alarm and request support when hostile forces are detected inside its security perimeter, before BLUE casualties occur.

Stage 2 still creates no CAS AUFTRAG and dispatches no aircraft. CAS execution remains a later BLUE-response stage.

## 2. Existing MissionDemand authority

`scripts/campaign/OMW_MissionDemand.lua` remains the only MissionDemand registry and already provides:

```text
MissionDemand.Type.CAS_IMMEDIATE
Registry:Create(...)
activeByDedupeKey
idempotent_existing
active_duplicate
terminal release of dedupeKey
snapshot/restore of active demands
```

`scripts/campaign/OMW_FobAttackDemandPolicy.lua` remains framework-independent. It accepts only a qualified incident and creates the existing CAS_IMMEDIATE demand shape.

No second support-request registry or resource authority is introduced.

## 3. Incident contract

Required domain fields remain:

```text
incidentId       stable, non-empty
installationId   stable OMW installation identity
priority         finite number supplied by the incident classifier
```

Operational metadata may include:

```text
position
reportedTarget.targetKind = INSTALLATION_SECURITY_PERIMETER
reportedTarget.targetName = runtime security-zone name
reportedTarget.radiusM
reportedTarget.evidence = OPSZONE_ATTACKED
```

The policy still does not invent attack severity or arbitrary cooldowns.

## 4. Dedupe

The existing key remains:

```text
CAS_IMMEDIATE|FOB_ATTACK|<installationId>
```

Therefore:

```text
same incidentId
-> idempotent_existing

new incident same installation while demand nonterminal
-> active_duplicate

terminal demand
-> dedupe key released
```

The DCS acceptance needs to prove one real OPSZONE threat creates one demand. Repeated-threat dedupe remains contract-tested in CI and does not require manufacturing two physical hits in DCS.

## 5. MOOSE-first source review

Pinned framework:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

The actual pinned `Moose.lua` confirms the direct runtime path:

```lua
ZONE_RADIUS:New(name, coordinate:GetVec2(), radiusM)
OPSZONE:New(zone, coalition.side.BLUE)
OPSZONE:SetObjectCategories(...)
OPSZONE:SetUnitCategories(...)
OPSZONE:SetCaptureThreatlevel(...)
OPSZONE:SetCaptureNunits(...)
OPSZONE:SetDrawZone(...)
OPSZONE:SetMarkZone(...)
OPSZONE:Start()
function opsZone:OnAfterAttacked(From, Event, To, AttackerCoalition)
```

`OPSZONE:EvaluateZone()` for a BLUE-owned zone raises `Attacked(coalition.side.RED)` when BLUE presence remains in the zone and RED presence is present with sufficient configured threat level. `IsContested()` explicitly means RED and BLUE are both present.

For Acceptance 1 the runtime settings are intentionally simple:

```text
security radius         = 1000 m
object categories       = UNIT only
unit categories         = GROUND_UNIT only
attack threat threshold = 0
owner                    = BLUE
scan interval           = 5 s (Acceptance only)
F10 draw/marker          = disabled
```

Important source nuance: `SetCaptureNunits(...)` participates in the capture branch when the owning side is absent; the defended-zone `Attacked` branch checks `Nred > 0` plus the configured threat threshold. Therefore Stage 2 does **not** depend on `SetCaptureNunits(1)` as an attack trigger. The adapter still sets it explicitly to `1` so subsequent capture semantics retain the MOOSE default rather than being left implicit.

Threat level `0` is intentional for this Stage-2 rule: mere hostile RED ground presence in the security perimeter is sufficient to raise the installation alarm. This is an OMW design decision for the current acceptance, not a universal MOOSE default recommendation.

## 6. Runtime perimeter source

No Mission-Editor security trigger zone is required.

The installation anchor is the already source-reviewed MOOSE Warehouse coordinate:

```text
BRIGADE -> LEGION -> WAREHOUSE:GetCoordinate()
```

Acceptance 1 derives:

```text
WH_BLUE_GND_FORTRESS
-> brigade:GetCoordinate()
-> coordinate:GetVec2()
-> ZONE_RADIUS("OMW_SECURITY_BLUE_GROUND_COP_FORTRESS", ..., 1000)
-> OPSZONE(..., BLUE)
```

This is separate from `ZON_BLUE_GND_FORTRESS_ACCESS`. The Ground reconstitution/access contract defines ACCESS zones as operational materialization/departure/return/handoff boundaries, not installation geometry. ACCESS therefore remains unchanged and is not repurposed as a security perimeter.

## 7. BLUE-presence requirement

Pinned MOOSE source also establishes an important runtime condition: for a BLUE-owned OPSZONE, `Attacked` due presence is raised when BLUE remains present and RED is detected. If no BLUE unit is present, capture-state logic applies instead.

Acceptance 1 therefore retains the already staged Fortress 9-man rifle squad as a real local-security representation:

```text
9 GROUND_PERSONNEL
-> TPL_BLUE_GND_INF_RIFLE_SQUAD_9
-> MOOSE BRIGADE / PLATOON
-> AUFTRAG:NewONGUARD(warehouse coordinate)
-> BLUE ground presence at installation
```

The squad is no longer a special hit target. It only provides the physical local-security element and proves the defended-zone condition.

## 8. Superseded Hit path

The earlier experimental path was:

```text
registered dynamic BLUE Sentry
-> RED must physically hit that exact runtime group
-> EVENTS.Hit
-> CAS_IMMEDIATE
```

Real DCS runs showed that this is unnecessarily fragile for the operational requirement: RED can be in fire contact with the installation without producing a qualifying hit on the exact registered group.

That path is removed from the active Stage-2 implementation. Git history preserves the investigation and failed/partial acceptance evidence. No `world.addEventHandler`, MIST, or native replacement is introduced.

## 9. Active implementation

```text
scripts/ground/OMW_FobThreatOpsZoneAdapter.lua
mission/tests/fob-attack-support-demand/src/01-fob-attack-threat-acceptance-1.lua
tests/mission-demand/test_fob_threat_opszone_adapter.lua
tools/build-fob-attack-threat-acceptance-1.ps1
```

The adapter owns only MOOSE runtime qualification and delegates the qualified incident to `OMW_FobAttackDemandPolicy`.

## 10. Acceptance boundary

Acceptance 1 must prove:

```text
existing authoritative CampaignState reused
-> 9 Fortress GROUND_PERSONNEL consumed
-> rifle squad materialized and ONGUARD
-> runtime 1000 m ZONE_RADIUS created from Warehouse coordinate
-> BLUE OPSZONE started
-> actual RED ground presence in perimeter
-> OnAfterAttacked(..., RED)
-> one CAS_IMMEDIATE MissionDemand
-> PASS
```

No hit, casualty, shot event, manual ME security zone, CAS dispatch, MIST, or native DCS world-event handler is required.

DCS runtime status remains `PLANNED` until that exact path passes with recorded provenance.
