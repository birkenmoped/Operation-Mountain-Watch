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
- the project owner visually confirmed racetrack patterns.

The same run established the need for farther-out gates and at least 60 seconds between materializations inside one gate/runtime domain. Different gate domains may materialize simultaneously.

## 2. Acceptance-3 – observed partial failure

`AAR-KC135-RUNTIME-ACCEPTANCE-3` narrowed the test to Clancy and Nelson and used the relocated gate candidates:

```text
OMW_TANKER_GATE_S  = N28.90264890 E64.61166667
OMW_TANKER_GATE_NE = N37.64268794 E70.96231552
```

Confirmed in the owner-run DCS 2.9.28.26385 log:

- both tanker seeds started at the relocated candidates;
- both produced plausible delayed 90/96-percent fuel readback;
- both reached `AUFTRAG:TANKER -> EXECUTING`;
- the existing Bagram F-16C receiver mission was added to the AIRWING;
- Nelson/Texaco 1-1 answered on 384.400 MHz AM.

Observed failures/limits:

- Nelson 47X produced no usable TACAN indication in the F-16;
- Nelson materialized facing north although its track lies south of the gate;
- both tankers used 300 KIAS; this is not accepted as a universal receiver-compatible value, especially for A-10 service;
- the Bagram F-16C mission was added but no receiver was assigned/materialized in the observed run, so Boom refueling and post-refuel FuelLow/Egress were not reached.

Acceptance-3 is therefore recorded as `HISTORICAL_TEST_FIXTURE`, not `VALIDATED`. Detailed findings are in `docs/moose/AAR-RUNTIME-ACCEPTANCE-3.md`.

## 3. Acceptance-4 scope

Test ID:

```text
AAR-KC135-RUNTIME-ACCEPTANCE-4
```

Active exemplars:

| Area | Existing template | Gate domain | Orbit speed | Radio | DCS runtime TACAN |
|---|---|---|---:|---:|---|
| Clancy | `OMW_AAR_KC135_CLANCY` | SOUTH | 220 KIAS | 241.600 AM | 60Y / CLA |
| Nelson | `OMW_AAR_KC135_NELSON` | NORTH_EAST | 300 KIAS | 384.400 AM | 47Y / NEL |

The source/planning TACAN values are not overwritten by this test. Acceptance-4 explicitly separates the DCS-runtime Y-band beacon configuration from those source fields.

Clancy's 220 KIAS is a targeted A-10-compatible acceptance value. It is supported by a period-adjacent official USAF type reference describing KC-135 refueling of A-10s at approximately 220 knots. It is not automatically generalized to every OMW tanker/receiver pairing. Nelson remains at 300 KIAS for this fast-jet/northern exemplar until a complete receiver-oriented speed matrix is established.

## 4. MOOSE-first runtime corrections

Pinned runtime:

```text
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Relevant public paths verified in the actual pinned `Moose.lua` now include:

```text
AUFTRAG:NewTANKER(...)
AUFTRAG:SetRadio(...)
AUFTRAG:SetTACAN(...)
COORDINATE:HeadingTo(...)
SPAWN:InitHeading(...)
SPAWN:SpawnFromCoordinate(...)
FLIGHTGROUP:New(...)
AUFTRAG:SetMissionEgressCoord(...)
AUFTRAG:Cancel()
AUFTRAG:NewCAS(...)
AUFTRAG:AssignSquadrons({...})
AUFTRAG:AddRequiredPayload(...)
AUFTRAG:SetRequiredAssets(min,max)
AUFTRAG:CountOpsGroups()
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

The pinned MOOSE source documents Y as the aircraft/Air-to-Air tanker TACAN path. Acceptance-4 therefore uses 60Y and 47Y instead of forcing X.

For airborne materialization the harness uses only MOOSE public APIs:

```lua
local spawnHeadingDeg = gateCoord:HeadingTo(trackCoord)
local spawner = SPAWN:New(spec.template)
spawner:InitHeading(spawnHeadingDeg)
local group = spawner:SpawnFromCoordinate(gateCoord)
```

This changes the initial facing only. Racetrack orientation remains the `AUFTRAG:NewTANKER()` heading.

## 5. Existing AI Boom receiver

The existing Bagram foundation remains the only receiver asset path:

```text
AW_US_BGRM_455_AEW
-> SQ_US_BGRM_F16C_121_EFS
-> TPL_AIR_US_BGRM_F16C_CAS_2SHIP
```

No new Mission Editor receiver group is introduced and the harness does not mutate the `.miz`.

Acceptance-4 does not guess at the cause of the Acceptance-3 non-assignment. It adds `AUFTRAG:CountOpsGroups()` to the summary as `receiverMissionOpsGroups`, so the next run distinguishes a mission merely being queued from an OPSGROUP actually being assigned before the `AIRWING:OnAfterFlightOnMission` callback.

## 6. Expected Acceptance-4 markers

```text
TANKER_START_PASS area=CLANCY ... spawnHeadingDeg=... speedKt=220 ... tacan=60Y ...
TANKER_START_PASS area=NELSON ... spawnHeadingDeg=... speedKt=300 ... tacan=47Y ...
SEED_FUEL_PASS area=CLANCY ...
SEED_FUEL_PASS area=NELSON ...
TANKER_EXECUTING_PASS area=CLANCY ... speedKt=220
TANKER_EXECUTING_PASS area=NELSON ... speedKt=300
RECEIVER_MISSION_ADDED_PASS ...
SUMMARY ... receiverMissionOpsGroups=...
RECEIVER_ASSIGNED_PASS ...
AI_BOOM_REFUEL_ORDER_PASS ... tankerArea=CLANCY ...
AI_BOOM_REFUELED_PASS ... fuelBeforePct=... fuelAfterPct=...
ACCELERATED_FUEL_LOW_ARMED thresholdPct=99 afterAiBoomRefueled=true
FUEL_LOW_PASS area=CLANCY ... action=CANCEL_TO_EGRESS
FUEL_LOW_PASS area=NELSON ... action=CANCEL_TO_EGRESS
EGRESS_GATE_PASS area=CLANCY ... action=DESPAWN_OFFMAP_HANDOFF
EGRESS_GATE_PASS area=NELSON ... action=DESPAWN_OFFMAP_HANDOFF
HARNESS_READY ... runtimeTacanBand=Y clancySpeedKt=220 nelsonSpeedKt=300 spawnHeadingTowardTrack=true ...
```

## 7. Acceptance-4 criteria

A useful owner run must establish:

1. Clancy and Nelson materialize at the relocated candidate gates with plausible initial heading toward their own tracks;
2. their materialization/despawn locations are not objectionably visible from the normal player mission area;
3. Clancy 241.600 AM / 60Y and Nelson 384.400 AM / 47Y provide usable representative radio/TACAN service;
4. Clancy can fly the 220-KIAS tanker track as the A-10-compatible exemplar without breaking the tanker mission;
5. Nelson remains functional at 300 KIAS;
6. both reach `AUFTRAG:TANKER -> EXECUTING` and fly their racetracks;
7. the receiver telemetry shows whether the Bagram F-16C receives an OPSGROUP assignment;
8. if assigned and airborne, the MOOSE refuel FSM is ordered and DCS completes Boom refueling;
9. only after Boom proof do the tankers execute accelerated `FuelLow -> Cancel -> Egress -> <=10 NM -> Despawn`;
10. no new Mission Editor template, MIST/native event handler or automated `.miz` mutation is introduced.

## 8. Source / Builder / Dist

```text
mission/tests/aar-kc135-runtime/src/01-aar-kc135-runtime-acceptance.lua
tools/build-aar-kc135-runtime-acceptance.ps1
mission/tests/aar-kc135-runtime/dist/OMW_AAR_KC135_Runtime_Acceptance.lua
```

`dist/` is builder-generated only.
