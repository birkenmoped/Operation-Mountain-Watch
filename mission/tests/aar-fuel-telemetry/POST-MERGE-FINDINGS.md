---
document_id: OMW-TEST-AAR-FUEL-POST-MERGE-FINDINGS
status: DRAFT
document_class: TEST_RESULT_AND_DESIGN_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local record of AAR fuel-telemetry findings after the last accepted AAR merge to main
  - branch-local design decisions for KC-135 initial fuel, LRC transit planning and FuelLow recalibration
  - explicit record of failed assumptions and rejected test approaches
not_authoritative_for:
  - production AAR values before owner-approved promotion and DCS acceptance
  - undocumented KC-135 performance outside the cited AFMAN and measured DCS telemetry
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/aar-fuel-telemetry-calibration
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# AAR fuel telemetry – post-merge findings and recalibration record

## 1. Scope

This document consolidates all relevant AAR findings, agreements, corrections, failed assumptions and current calibration candidates developed after the previous accepted AAR runtime finalization was merged to `main`.

The accepted production baseline itself remains unchanged until an explicit owner-approved promotion is implemented and validated. The branch-local work described here must therefore not be read as a silent replacement of the accepted production values.

Accepted AAR production provenance before this workstream:

```text
Acceptance commit: 5e7dbec37f53155f39c63c25590cf6b4e35814ca
Mission: OMW_Template_v9_AirOps_rdy.miz
Mission SHA-256: c9e3978a4bbb35ebbfe5ae362021b5f8870129d6c8b06b58147424dde71a94e3
Bundle SHA-256: f33b0a5a6212d9a1103dfa2e0ab677777142ca771a2f5007a3ab1c7fee594cbf
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Result: PASS
```

## 2. Fixed MOOSE / DCS baseline

All branch-local tests use the same pinned MOOSE baseline:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

The most recent real DCS run documented here used:

```text
DCS: 2.9.28.26385 MT
Mission: OMW_Template_v10_AirOps_rdy.miz
Test ID: AAR-FUEL-TELEMETRY-4
```

Mission SHA-256 and Candidate-4 bundle SHA-256 were not captured in the conversation and therefore remain unknown. This prevents promotion of this exact run to a complete `ACCEPTED_TECHNICAL_BASELINE` even where individual observed behaviors are positive.

## 3. Spawn speed correction

### 3.1 Problem observed with 300-kt in-air materialization

The original in-air KC-135 materialization used the production transit-route value of `300 kt` as the SPAWN initial speed. In DCS this produced an unrealistic initial energy state at high altitude: low indicated airspeed, excessive angle of attack and a prolonged stabilization phase.

### 3.2 Tested correction

The branch-local telemetry tests separate the two meanings explicitly:

```text
SPAWN:InitSpeedKnots(...)  = physical in-air materialization speed
AUFTRAG/waypoint speed     = MOOSE route command
```

Candidate setting:

```text
In-air spawn initial speed: 480 kt
MOOSE transit route speed:  300 kt
```

The 480-kt materialization state was visually and operationally plausible in DCS and eliminated the previously observed low-energy spawn behavior. It must not be interpreted as a request to change the MOOSE route speed to 480 kt.

## 4. LRC transit altitude planning

The KC-135 operating manual states that tanker missions should be planned to and from the AAR track or anchor at Long Range Cruise and optimum altitude. The exact KC-135R/T optimum-altitude schedule is not available in the supplied public material; the concrete OMW levels therefore remain a reconstructed planning estimate.

OMW owner decision:

```text
No routine weight-based step climb.
Use one planned directional LRC level for each transit direction.
```

The Afghanistan IFR semi-circular direction rule is retained:

```text
magnetic track 000-179 deg -> odd flight level
magnetic track 180-359 deg -> even flight level
```

Current directional planning candidate:

```text
MANAS -> Afghanistan:      FL340
Afghanistan -> MANAS:      FL350
AL_UDEID -> Afghanistan:   FL350
Afghanistan -> AL_UDEID:   FL340
```

The intent is to cruise at the planned directional level and transition naturally to the track altitude. A routine fuel-burn-driven step-climb schedule is explicitly not part of the design.

## 5. NewORBIT mission-altitude finding

Source review of the pinned MOOSE revealed that `AUFTRAG:NewORBIT` defaults to:

```text
missionAltitude = orbitAltitude * 0.9
missionFraction = 0.9
```

This explained previously observed mission-approach values exactly:

```text
NELSON: 27,500 ft * 0.9 = 24,750 ft
PATTY:  24,000 ft * 0.9 = 21,600 ft
```

The branch-local candidate therefore uses:

```lua
mission:SetMissionAltitude(profile.altitudeFt)
```

This keeps MOOSE responsible for mission generation while preventing the undesired 90-percent mission-waypoint altitude.

## 6. Failed routing assumption – Candidate 3

### 6.1 What was changed

Candidate 3 moved the MOOSE mission ingress away from the published FIR fix:

```text
before:
SetMissionIngressCoord(EGPAN/PINAX/DAVER)

after:
SetMissionIngressCoord(60-NM late approach)
```

The published FIR fix was then intended to be reinserted ahead of the mission with delayed `FLIGHTGROUP:AddWaypoint(...)` after `AddMission(...)`.

### 6.2 Why this was wrong

This unnecessarily replaced a previously accepted routing contract:

```text
External Spawn
-> published FIR ingress fix
-> AAR mission
```

The project owner had not approved replacing that accepted contract. The change was therefore both technically fragile and outside the intended decision boundary.

### 6.3 DCS result

Candidate 3 showed that the new FL340/FL350 transit levels and the exact track-altitude correction were effective, but the mandatory FIR ingress was no longer reliable. LISA/MOE visibly missed PINAX and the southern routes did not reliably preserve DAVER.

Decision:

```text
Candidate-3 inbound routing: REJECTED
```

The accepted `SetMissionIngressCoord(EGPAN/PINAX/DAVER, ...)` contract must not be replaced by this approach.

## 7. Failed routing assumption – Candidate 4

### 7.1 Corrected intent

Candidate 4 restored the accepted FIR ingress as the primary MOOSE mechanism:

```text
SetMissionIngressCoord(EGPAN/PINAX/DAVER)
```

The additional 60-NM late-approach point was intended to be inserted only after MOOSE had built the FIR-ingress-to-mission route.

### 7.2 Real DCS result

The good result:

```text
NELSON/PATTY    -> EGPAN passed
LISA/MOE        -> PINAX passed
KRUSTY/MILHOUSE -> DAVER passed
```

The FIR-ingress regression introduced by Candidate 3 was therefore corrected.

The failed result:

```text
LRC late-approach injection has no MOOSE mission waypoint UID
```

This occurred for the Candidate-4 runtimes, so the 60-NM late-approach point was not inserted.

The telemetry harness nevertheless printed:

```text
RESULT PASS allTracks=6 samplesPerTrack=3 points=SPAWN,INGRESS,TRACK fuelLowExcluded=true
```

That `PASS` is only a fuel-telemetry completion result. It is not an LRC-routing acceptance result.

Decision:

```text
Candidate-4 late-approach adapter: FAILED
Candidate-4 FIR ingress restoration: PASSED in the observed DCS run
Candidate-4 overall LRC routing: NOT ACCEPTED
```

## 8. Clarification of the 60-NM late-approach concept

The 60-NM point is not a new northern or southern FIR point and is not a replacement for External Spawn or FIR Ingress.

It was only intended as a calculated per-track transition point:

```text
External Spawn
-> FIR Ingress
-> remain at directional LRC altitude
-> approximately 60 NM before the individual AAR track
-> begin descent
-> track
```

Owner clarification after the test:

- the point is not required for the fuel-calibration method;
- if MOOSE/DCS produces an acceptable natural descent from FIR Ingress to the track, the extra point is not operationally mandatory;
- descending toward the track can reduce fuel flow relative to level cruise, while the outbound climb from track altitude back to return cruise altitude increases fuel flow;
- therefore the decisive FuelLow problem is the outbound/return profile, not the existence of the 60-NM inbound point.

The 60-NM point remains an optional routing experiment, not an accepted production requirement.

## 9. Fuel telemetry comparison rule

A correction was made during analysis: comparing absolute SPAWN fuel percentages across Test 1/2/4 is not the agreed basis for route-consumption calibration.

The agreed comparison quantity is:

```text
fuel at FIR INGRESS
-
fuel at TRACK
=
INGRESS -> TRACK burn
```

This makes the starting percentage irrelevant for the consumption comparison of that route segment.

For recalibration, Test 4 is the sole current calculation basis. Test 1 and Test 2 are retained only as historical comparison/sensitivity data and are not averaged into the new calibration.

## 10. Test-4 measured fuel data

Maximum DCS KC-135 fuel mass observed by the telemetry wrapper:

```text
90,700 kg
```

Test-4 `INGRESS -> TRACK` values:

| Track | Source | Planned FIR->Track | Burn | Time | Derived burn kg | Derived kg/NM | Derived kg/h |
|---|---|---:|---:|---:|---:|---:|---:|
| NELSON | MANAS | 123.698 NM | 3.8939 % | 1101.100 s | 3,532 kg | 28.55 | 11,547 |
| PATTY | MANAS | 210.823 NM | 6.3108 % | 2151.149 s | 5,724 kg | 27.15 | 9,579 |
| LISA | MANAS | 416.794 NM | 11.3373 % | 4018.014 s | 10,283 kg | 24.67 | 9,213 |
| MOE | MANAS | 225.206 NM | 6.4283 % | 2049.047 s | 5,830 kg | 25.89 | 10,244 |
| MILHOUSE | AL_UDEID | 235.241 NM | 6.3600 % | 2572.570 s | 5,769 kg | 24.52 | 8,072 |
| KRUSTY | AL_UDEID | 257.455 NM | 7.2062 % | 2930.928 s | 6,536 kg | 25.39 | 8,028 |

The domain-level recalibration uses a distance-weighted rate from Test 4 only:

```text
MANAS domain:     25.98 kg/NM
AL_UDEID domain:  24.97 kg/NM
```

## 11. Initial-fuel recalibration

The off-map physical spawn point represents an aircraft that has already flown from its real source base. Therefore the template spawn fuel must represent:

```text
100 percent at source base
-
virtual source-base -> External Spawn burn
```

External points in the accepted controller:

```text
MANAS external point:     N38.83163 E70.95271
AL_UDEID external point:  N28.90264890 E64.61166667
```

Great-circle planning distances used for the branch-local recalculation:

```text
Manas International -> MANAS External Spawn:       300.005 NM
Al Udeid AB -> AL_UDEID External Spawn:            746.241 NM
```

Using only the Test-4 domain rates:

```text
MANAS virtual burn
= 300.005 NM * 25.98 kg/NM
= approximately 7,794 kg

AL_UDEID virtual burn
= 746.241 NM * 24.97 kg/NM
= approximately 18,634 kg
```

Derived initial-fuel candidates:

```text
MANAS:     91.4067 %
AL_UDEID:  79.4558 %
```

Correction note: an earlier conversational value of `79.4581 %` for AL UDEID resulted from rounded intermediate distance/arithmetic. Recalculation with the stated 746.241-NM great-circle distance yields `79.4558 %`; this is the value to preserve in documentation until a newer calibration replaces it.

These are branch-local planning candidates, not yet production template values.

## 12. FuelLow planning model

FuelLow is not merely a percentage at which a replacement should be convenient. It represents the point at which the active tanker must leave the track immediately to protect the aircraft and complete recovery.

The return problem is asymmetric with the inbound route:

```text
Inbound:
cruise -> descent to track altitude

Outbound:
track altitude -> climb to directional return cruise altitude -> cruise -> FIR egress -> External Handoff -> virtual continuation to source/recovery base
```

The outbound climb is expected to consume more fuel than a same-distance level-cruise segment, while inbound descent can consume less. Existing Test 1/2 data may therefore be used only as conservative sensitivity references until direct outbound telemetry is available.

## 13. AFMAN fuel-planning baseline adopted for OMW 2010-2011

Best available operational source:

```text
AFMAN 11-2KC-135, Volume 3
KC-135 Operations Procedures
10 September 2019
```

Relevant Chapter 14 requirements:

```text
14.4.8.1 Minimum Planned Fuel at Begin Descent Point
includes descent, approach and landing, alternate/missed approach,
and holding/minimum landing fuel.

14.4.9 Alternate
plan a 45-minute fuel reserve at the alternate.

14.4.10 Planned Landing Fuel
never plan to land with less than 13,000 lb remaining.

14.4.11 Minimum or Emergency Fuel Advisory
land before reaching 9,200 lb remaining.
```

The manual is later than the OMW campaign period. Owner decision:

```text
The 2019 AFMAN values are the best available KC-135 operational values currently available to OMW.
They are adopted as the OMW planning baseline for the 2010-2011 campaign period unless a better period-specific source is later found.
```

The 45-minute reserve and 13,000-lb planned-landing floor must not be blindly added twice. For OMW, FuelLow planning must ensure the complete return/diversion requirement and then ensure the resulting planned landing fuel is not below the AFMAN floor.

DCS-mass equivalents using the observed 90,700-kg full fuel mass:

```text
13,000 lb = approximately 5,897 kg = approximately 6.50 %
9,200 lb  = approximately 4,173 kg = approximately 4.60 %
```

At the measured Test-4 fuel-flow rates, 45 minutes of fuel is greater than the 13,000-lb floor for all six tracks, so the 45-minute planning reserve is currently the controlling reserve term.

## 14. Current branch-local FuelLow candidates

Using the conservative return-distance model discussed in the workstream, plus the 45-minute AFMAN reserve, the current branch-local candidates are:

```text
NELSON:    24 %
PATTY:     25 %
LISA:      33 %
MOE:       29 %
MILHOUSE:  37 %
KRUSTY:    39 %
```

These replace neither the accepted production values nor the current production controller yet.

They are deliberately higher than several accepted legacy thresholds because the revised model now accounts for:

- the complete return path to the physical/virtual source recovery domain;
- the long AL UDEID recovery distance;
- a conservative allowance for climb/return-profile consumption;
- the AFMAN 45-minute reserve;
- the AFMAN planned-landing floor.

## 15. Remaining evidence gap for final FuelLow

The most useful next telemetry addition is direct outbound measurement:

```text
TRACK departure fuel
FIR EGRESS fuel
EXTERNAL HANDOFF fuel
```

This will quantify the actual DCS climb and outbound return consumption rather than using an inbound/proxy estimate.

Until this exists, the FuelLow values in section 14 are planning candidates, not validated production thresholds.

## 16. Explicit record of corrected analytical mistakes

The following mistakes/assumptions were identified and corrected during this workstream:

1. `SetMissionIngressCoord(...)` was moved from the accepted FIR fix to a late-approach point without owner approval. This was an unnecessary architecture change and caused FIR-routing regression. Rejected.
2. Candidate 3 assumed delayed `AddWaypoint(...)` after `AddMission(...)` would reliably reconstruct the FIR route. DCS disproved this.
3. Candidate 4 assumed the MOOSE mission-waypoint UID would be available at the chosen scheduled injection time. DCS disproved this; the adapter failed with `no MOOSE mission waypoint UID`.
4. The fuel-telemetry harness `RESULT PASS` was initially at risk of being read as an LRC-routing PASS. It only proves completion of SPAWN/INGRESS/TRACK telemetry and must not be used as route acceptance.
5. Absolute SPAWN fuel percentage was incorrectly discussed as limiting comparison of Test 1/2/4. For the agreed `INGRESS -> TRACK` consumption comparison it is irrelevant.
6. Test 1/2 were initially proposed as inputs to the new calibration average. Owner correction: Test 4 alone is the new calculation basis; older tests are comparison/sensitivity evidence only.
7. A request was made for already-derivable Source->External distances. Those distances are calculable from the fixed source/external coordinates and should not have been requested as missing owner input.
8. The 60-NM late-approach concept was initially described too prominently relative to the real fuel problem. It is an optional inbound transition aid; the more important unknown for FuelLow is the outbound climb and return profile.
9. A provisional AL Udeid recalculation of `79.4581 %` used rounded intermediate values. The documented great-circle/rate calculation yields `79.4558 %`.

## 17. Current decision boundary

No production controller, production template or `.miz` file is changed by this documentation record.

Current branch-local direction:

```text
retain accepted FIR ingress/egress contract
retain 480-kt in-air materialization candidate
retain 300-kt MOOSE transit route command pending further evidence
retain directional FL340/FL350 LRC planning candidate
retain exact track mission altitude correction candidate
use Test 4 only for current inbound fuel-rate calibration
use 91.4067 % MANAS and 79.4558 % AL_UDEID as current initial-fuel candidates
use 24/25/33/29/37/39 % as current FuelLow candidates
adopt AFMAN 2019 45-min / 13,000-lb / 9,200-lb values as OMW 2010-2011 planning baseline
measure outbound TRACK -> EGRESS -> HANDOFF fuel before final FuelLow promotion
```

Any production promotion remains subject to owner approval, complete diff/test review, documentation validation and a documented DCS acceptance run.
