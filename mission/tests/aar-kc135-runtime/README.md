---
document_id: OMW-TEST-AAR-KC135-RUNTIME-INDEX
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - KC-135 AAR runtime acceptance test layout
  - exact active template set and expected test markers
  - source-reviewed MOOSE paths used by the acceptance harness
not_authoritative_for:
  - DCS runtime acceptance before an owner-run test
  - final ingress-/egress-gate map-edge clearance
  - historical tanker callsign authenticity
  - production support-concurrency limits beyond the binding AirOps baseline
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by: []
source_branch: agent/aar-rc-east-runtime-scope
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# KC-135 AAR Runtime Acceptance

## 1. Acceptance-2 – owner-run evidence 2026-08-14

`AAR-KC135-RUNTIME-ACCEPTANCE-2` used all five prepared KC-135 templates as an explicitly authorized stress-test exception. The productive limit remained `maxConcurrentSupportMissions = 2`.

Observed/logged for the exact owner-run DCS 2.9.28.26385 test stand:

- all five KC-135 spawned;
- delayed seed-fuel readback was plausible at approximately 90/90/90/96/96 percent;
- all five `AUFTRAG:TANKER` missions reached `EXECUTING`;
- the required 180-second simultaneous `EXECUTING` dwell completed before accelerated FuelLow was armed;
- all five produced the expected `FuelLow -> AUFTRAG:Cancel() -> Egress` path;
- all five reached their assigned gate within the 10-NM handoff radius and were removed by MOOSE `OPSGROUP:Despawn(1, true)`;
- the project owner visually confirmed that the tankers flew racetrack patterns.

The same test exposed two production-design findings rather than MOOSE failures:

1. the south gate is too close to the normal visible mission area and must move substantially farther south;
2. near-simultaneous materialization of several tankers from the same gate/domain is unsuitable for production.

The exact log/debrief SHA-256 values were not supplied with this observation set. Therefore this document does not promote the whole AAR subsystem to `VALIDATED`.

## 2. Owner decisions after Acceptance-2

Binding design input for the next runtime test:

```text
same gate/domain minimum materialization separation: 60 s
simultaneous materialization from different gate domains: allowed
new Mission Editor tanker/receiver templates: not allowed/needed
manual radio/TACAN checks: one or at most two representative tankers
Boom refueling check: AI receiver required
```

Gate relocation candidates for Acceptance-3:

```text
OMW_TANKER_GATE_S
old: N29.9818333333 E64.6116666667
candidate: N28.90264890 E64.61166667
approximate displacement: 120 km south

OMW_TANKER_GATE_NE
old: N38.1211666667 E70.3600000000
candidate: N37.64268794 E70.96231552
approximate displacement: 75 km southeast
```

These are **candidate test coordinates**, not yet BINDING/VALIDATED map-edge positions. Acceptance-3 must prove that DCS can spawn, route and hand off aircraft there without visible materialization in the normal player area.

## 3. Acceptance-3 scope

Test ID:

```text
AAR-KC135-RUNTIME-ACCEPTANCE-3
```

Active tanker exemplars:

| Area | Existing template | Gate domain | Radio | TACAN |
|---|---|---|---:|---|
| Clancy | `OMW_AAR_KC135_CLANCY` | SOUTH | 241.600 AM | 60X / CLA |
| Nelson | `OMW_AAR_KC135_NELSON` | NORTH_EAST | 384.400 AM | 47X / NEL |

Clancy and Nelson may materialize simultaneously because they use different gate domains. Acceptance-3 does **not** start Homer, Krusty or Patty and therefore no longer reproduces the five-aircraft stress exception.

Manual owner observation is limited to the two representative tanker assignments above. Radio/TACAN behavior of the other prepared tanker configurations remains configuration-equivalent but is not claimed as individually DCS-tested from these two observations.

## 4. Existing AI Boom receiver – no new `.miz` template

Acceptance-3 reuses the existing Bagram foundation:

```text
AW_US_BGRM_455_AEW
-> SQ_US_BGRM_F16C_121_EFS
-> TPL_AIR_US_BGRM_F16C_CAS_2SHIP
```

No new Mission Editor receiver group is introduced and the harness does not mutate the `.miz`.

The receiver is recruited through the existing Bagram AIRWING/SQUADRON and its registered F-16C CAS payload. The test creates only an `AUFTRAG:NewCAS()` runtime mission restricted to the existing F-16C squadron/payload. Once the resulting `FLIGHTGROUP` is airborne and Clancy is executing its tanker mission, the test invokes the source-reviewed MOOSE `FLIGHTGROUP:Refuel()` FSM path. `OnAfterRefueled` plus fuel telemetry provides the positive AI Boom-refueling marker.

Only after `AI_BOOM_REFUELED_PASS` does Acceptance-3 arm the 99-percent accelerated FuelLow threshold for the two tanker exemplars. This reuses the Acceptance-2 MOOSE `FuelLow -> Cancel -> Mission Egress -> <=10 NM -> Despawn` path to verify the **relocated** gate candidates in both directions.

## 5. MOOSE-first source review

Pinned runtime:

```text
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Relevant public paths verified in the actual pinned `Moose.lua`:

```text
SPAWN:New(...):SpawnFromCoordinate(...)
FLIGHTGROUP:New(...)
AUFTRAG:NewTANKER(...)
AUFTRAG:SetRadio(...)
AUFTRAG:SetTACAN(...)
AUFTRAG:SetMissionEgressCoord(...)
AUFTRAG:Cancel()
AUFTRAG:NewCAS(...)
AUFTRAG:AssignSquadrons({...})
AUFTRAG:AddRequiredPayload(...)
AUFTRAG:SetRequiredAssets(min,max)
AIRWING:AddMission(...)
AIRWING:OnAfterFlightOnMission(...)
FLIGHTGROUP:IsAirborne()
FLIGHTGROUP:Refuel(...)
FLIGHTGROUP:OnAfterRefueled(...)
FLIGHTGROUP:GetFuelMin()
FLIGHTGROUP:SetFuelLowThreshold(...)
FLIGHTGROUP:OnAfterFuelLow(...)
OPSGROUP:Despawn(delay,noEventRemoveUnit)
SCHEDULER
```

`FLIGHTGROUP` explicitly defines the FSM transitions `Refuel -> Going4Fuel` and `Refueled -> Cruising`. Its refuel handler uses the DCS refueling task internally. OMW therefore does not implement a parallel native-DCS receiver controller.

## 6. Expected Acceptance-3 markers

```text
TANKER_START_PASS area=CLANCY ...
TANKER_START_PASS area=NELSON ...
SEED_FUEL_PASS area=CLANCY ...
SEED_FUEL_PASS area=NELSON ...
TANKER_EXECUTING_PASS area=CLANCY ...
TANKER_EXECUTING_PASS area=NELSON ...
RECEIVER_MISSION_ADDED_PASS template=TPL_AIR_US_BGRM_F16C_CAS_2SHIP ...
RECEIVER_ASSIGNED_PASS ...
AI_BOOM_REFUEL_ORDER_PASS ... tankerArea=CLANCY ...
AI_BOOM_REFUELED_PASS ... fuelBeforePct=... fuelAfterPct=...
ACCELERATED_FUEL_LOW_ARMED thresholdPct=99 afterAiBoomRefueled=true
FUEL_LOW_PASS area=CLANCY ... action=CANCEL_TO_EGRESS
FUEL_LOW_PASS area=NELSON ... action=CANCEL_TO_EGRESS
EGRESS_GATE_PASS area=CLANCY ... action=DESPAWN_OFFMAP_HANDOFF
EGRESS_GATE_PASS area=NELSON ... action=DESPAWN_OFFMAP_HANDOFF
HARNESS_READY ... newMissionEditorTemplates=0 mizMutation=false
```

## 7. Acceptance-3 criteria

A useful owner run must establish:

1. Clancy and Nelson spawn at the relocated candidate gates and reach their racetracks;
2. their materialization/despawn locations are no longer objectionably visible from the normal player mission area;
3. one south and one north/east tanker can coexist without requiring same-domain staggering;
4. Clancy 241.600 AM / 60X and Nelson 384.400 AM / 47X are practically checked as representative radio/TACAN assignments;
5. the existing Bagram F-16C asset is recruited through its existing AIRWING/SQUADRON/payload path;
6. MOOSE orders that receiver into the refueling FSM and DCS completes the Boom-refueling task;
7. `AI_BOOM_REFUELED_PASS` is accompanied by plausible fuel telemetry;
8. after the AI Boom proof, both tankers execute `FuelLow -> Cancel -> Egress` and reach the relocated gate candidates within 10 NM before MOOSE despawn;
9. no new Mission Editor template, no MIST/native event handler and no `.miz` mutation are required.

The productive same-domain 60-second materialization separation is a runtime scheduling requirement for later mission activation logic. Acceptance-3 documents the rule but does not manufacture multiple same-domain tankers merely to retest the already observed clustering problem.

## 8. Source / Builder / Dist

```text
mission/tests/aar-kc135-runtime/src/01-aar-kc135-runtime-acceptance.lua
tools/build-aar-kc135-runtime-acceptance.ps1
mission/tests/aar-kc135-runtime/dist/OMW_AAR_KC135_Runtime_Acceptance.lua
```

`dist/` is builder-generated only.
