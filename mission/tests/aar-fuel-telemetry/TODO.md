---
document_id: OMW-TEST-AAR-FUEL-CALIBRATION-TODO
status: DRAFT
document_class: WORKLIST
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local worklist for the current AAR fuel, speed and LRC transit recalibration workstream
  - current target state, completed findings and remaining validation steps
not_authoritative_for:
  - production AAR values before owner-approved promotion and DCS acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/aar-fuel-telemetry-calibration
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# AAR Fuel / Speed / LRC Recalibration – To-do

## 1. Branch / Workstream ID

```text
Branch: agent/aar-fuel-telemetry-calibration
Workstream ID: OMW-TEST-AAR-FUEL-CALIBRATION-TODO
Branch head before creation of this worklist:
0a89404743bacd634fa832b8e28447e0b519ebfe
```

The branch remains a test/calibration branch. Production AAR Lua and `.miz` files are not to be silently changed from this worklist.

## 2. Goal of the current work

The goal is to convert the accepted AAR runtime into a technically and operationally better calibrated KC-135 implementation without changing the accepted strategic/resource architecture.

Target state:

```text
- physically plausible in-air KC-135 materialization;
- clear separation of IAS/KIAS, TAS and GS semantics;
- stable MOOSE route-speed semantics;
- directional LRC transit levels based on the Afghanistan odd/even IFR rule;
- exact AAR track altitude instead of the MOOSE NewORBIT 90-percent mission-altitude default;
- preserved mandatory FIR routing through EGPAN / PINAX / DAVER;
- initial fuel derived from measured DCS consumption and the virtual source-base -> External Spawn leg;
- FuelLow derived from complete recovery requirements rather than a convenience threshold;
- AFMAN-based 45-minute reserve and planned-landing minimum included in FuelLow planning;
- direct outbound telemetry for track departure -> FIR egress -> External Handoff before final FuelLow promotion;
- no unapproved replacement of already accepted routing contracts;
- final production changes only after owner approval and documented DCS validation.
```

The accepted CampaignState/off-map stock lifecycle, callsign-family rules, standard/reserve track roles and FIR/External separation remain unchanged by this workstream.

## 3. Current state – completed / established

### 3.1 Speed semantics and in-air spawn

Established from the branch-local DCS tests:

```text
IAS / KIAS = indicated aerodynamic airspeed
TAS        = true airspeed relative to the air mass
GS         = ground speed, including wind effect
```

Current candidate contract:

```text
SPAWN:InitSpeedKnots(480)
= initial physical in-air materialization only

MOOSE route speed = 300 kt
= transit route command

Track speed
= existing area/profile-specific mission value
```

The earlier 300-kt in-air materialization created an implausibly low-energy KC-135 state at high altitude. The 480-kt spawn initialization produced a plausible DCS energy state. `480 kt` must not be interpreted as `480 KIAS` or a permanent 480-kt GS command.

Status:

```text
480-kt in-air materialization: branch-local DCS evidence positive
300-kt transit route command: retained
production promotion: pending
```

### 3.2 Directional LRC cruise levels

OMW uses the Afghanistan/ICAO semi-circular IFR rule by magnetic track:

```text
000-179 deg magnetic -> odd flight level
180-359 deg magnetic -> even flight level
```

Current fixed directional LRC planning values:

```text
MANAS -> Afghanistan:      FL340  even
Afghanistan -> MANAS:      FL350  odd
AL_UDEID -> Afghanistan:   FL350  odd
Afghanistan -> AL_UDEID:   FL340  even
```

Owner decision:

```text
No routine weight/fuel-based step climb.
Use one planned directional LRC level per transit direction.
```

Status:

```text
FL340/FL350 concept: branch-local DCS evidence positive
production promotion: pending
```

### 3.3 Exact mission/track altitude

Pinned MOOSE source review found:

```text
AUFTRAG:NewORBIT default:
missionAltitude = orbitAltitude * 0.9
missionFraction = 0.9
```

This explained the previously observed values such as NELSON 24,750 ft for a 27,500-ft track and PATTY 21,600 ft for a 24,000-ft track.

Current branch-local correction candidate:

```lua
mission:SetMissionAltitude(profile.altitudeFt)
```

Status:

```text
exact track-altitude behavior: visually positive in DCS
production promotion: pending
```

### 3.4 FIR ingress contract restored

Mandatory routing remains:

```text
NELSON / PATTY    -> EGPAN
LISA / MOE        -> PINAX
KRUSTY / MILHOUSE -> DAVER
```

Candidate 3 wrongly replaced the accepted MOOSE mission ingress with a calculated late-approach point and attempted to add the FIR fix afterward. This caused real DCS FIR-routing regressions and was an unapproved architecture change.

Candidate 4 restored:

```text
AUFTRAG:SetMissionIngressCoord(EGPAN/PINAX/DAVER)
```

The real Candidate-4 DCS run confirmed passage of all three required FIR fixes for the six tracks.

Status:

```text
Candidate-3 routing approach: REJECTED
FIR ingress restoration in Candidate 4: PASS for observed run
accepted FIR contract: preserve
```

### 3.5 Optional 60-NM late-approach experiment

The 60-NM point was only intended as a per-track transition point between FIR ingress and track to delay descent from LRC altitude.

Candidate 4 failed to insert it because the assumed MOOSE mission-waypoint UID was not available at the chosen adapter timing.

Owner clarification:

```text
- the 60-NM point is not required for fuel calibration;
- it is not a new northern/southern FIR point;
- a plausible natural MOOSE/DCS descent is acceptable;
- the point is an optional experiment, not a production requirement;
- no timer-tuning trial-and-error is required to pursue it.
```

Status:

```text
60-NM late-approach: optional / not required for target state
Candidate-4 adapter: FAILED
```

### 3.6 Test-4 fuel calibration basis

For the current recalculation, only Test 4 is the calculation basis. Test 1/2 remain comparison/sensitivity evidence only.

Agreed metric:

```text
fuel at FIR INGRESS
-
fuel at TRACK
=
INGRESS -> TRACK burn
```

The absolute SPAWN starting percentage is irrelevant to this segment-consumption comparison.

Observed maximum DCS KC-135 fuel mass:

```text
90,700 kg
```

Test-4 measured values:

| Track | Source | FIR->Track | Burn | Time | kg/NM | kg/h |
|---|---|---:|---:|---:|---:|---:|
| NELSON | MANAS | 123.698 NM | 3.8939 % | 1101.100 s | 28.55 | 11,547 |
| PATTY | MANAS | 210.823 NM | 6.3108 % | 2151.149 s | 27.15 | 9,579 |
| LISA | MANAS | 416.794 NM | 11.3373 % | 4018.014 s | 24.67 | 9,213 |
| MOE | MANAS | 225.206 NM | 6.4283 % | 2049.047 s | 25.89 | 10,244 |
| MILHOUSE | AL_UDEID | 235.241 NM | 6.3600 % | 2572.570 s | 24.52 | 8,072 |
| KRUSTY | AL_UDEID | 257.455 NM | 7.2062 % | 2930.928 s | 25.39 | 8,028 |

Distance-weighted domain rates:

```text
MANAS:     25.98 kg/NM
AL_UDEID:  24.97 kg/NM
```

Status:

```text
Test-4 inbound fuel basis: usable for recalculation
not a complete outbound/FuelLow validation
```

### 3.7 Initial-fuel recalculation

External points remain:

```text
MANAS external point:     N38.83163 E70.95271
AL_UDEID external point:  N28.90264890 E64.61166667
```

Planning distances:

```text
Manas International -> MANAS External Spawn: 300.005 NM
Al Udeid AB -> AL_UDEID External Spawn:      746.241 NM
```

Using only Test-4 domain rates:

```text
MANAS initial-fuel candidate:     91.4067 %
AL_UDEID initial-fuel candidate:  79.4558 %
```

These represent the estimated remaining fuel after the virtual source-base -> External Spawn flight.

Status:

```text
calculation complete
production/template adoption pending owner approval and final validation
```

### 3.8 FuelLow doctrine and current candidates

OMW adopts AFMAN 11-2KC-135 Volume 3 (2019) as the best available KC-135 operational baseline for the 2010-2011 campaign period until a better period-specific source is found.

Planning requirements adopted:

```text
- 45-minute reserve for alternate/diversion planning;
- planned landing fuel not below 13,000 lb;
- 9,200 lb retained as minimum/emergency operational boundary.
```

The 45-minute reserve currently exceeds the 13,000-lb floor for all six Test-4 measured flow rates and is therefore the controlling reserve term in the present candidate calculation.

Current branch-local FuelLow candidates:

```text
NELSON:    24 %
PATTY:     25 %
LISA:      33 %
MOE:       29 %
MILHOUSE:  37 %
KRUSTY:    39 %
```

These are not final because the actual outbound climb/return fuel consumption has not yet been directly measured.

## 4. Remaining steps to target state

### Step 1 – Freeze the accepted inbound routing contract

Do not alter:

```text
External Spawn
-> EGPAN / PINAX / DAVER
-> AAR track
```

Do not reintroduce Candidate-3-style ingress replacement. The optional 60-NM point is not required for the next test.

### Step 2 – Prepare the next telemetry build for outbound measurement

Extend the branch-local telemetry only as necessary to record, per sortie:

```text
TRACK departure fuel
FIR EGRESS fuel
EXTERNAL HANDOFF fuel
```

Required supporting telemetry should include at least:

```text
fuel percent
fuel kg
elapsed time
relevant distance
track/source identity
```

The test must preserve:

```text
480-kt spawn initialization
300-kt transit route speed
FL340/FL350 directional LRC levels
exact mission/track altitude
accepted FIR ingress/egress routing
existing external handoff lifecycle
```

No `.miz` mutation by ChatGPT. The generated test Lua path and exact Mission Editor replacement step must be handed to the owner.

### Step 3 – DCS outbound validation run

Run the controlled DCS test and capture real evidence for all six tracks where practicable:

```text
track departure
climb toward return LRC level
FIR egress passage
external handoff
```

Acceptance questions:

```text
- does the tanker climb naturally from track altitude to the correct return LRC level?
- are return levels directional and correct: MANAS return FL350, AL_UDEID return FL340?
- is EGPAN/PINAX/DAVER still passed on egress?
- is External Handoff reached naturally?
- what is actual TRACK -> FIR EGRESS fuel burn?
- what is actual TRACK -> External Handoff fuel burn?
- how large is the real climb penalty compared with the inbound/descent proxy?
```

### Step 4 – Final FuelLow calculation

Use the measured outbound data, not a guessed mirrored inbound rate, to calculate each track's recovery requirement:

```text
FuelLow =
actual/derived track -> recovery requirement
+ AFMAN 45-minute reserve
with planned landing fuel >= 13,000 lb
```

The virtual External Handoff -> source-base continuation must remain included in recovery planning.

Compare the result with the current candidates:

```text
NELSON 24
PATTY 25
LISA 33
MOE 29
MILHOUSE 37
KRUSTY 39
```

Revise only where the new measured outbound evidence requires it.

### Step 5 – Confirm final initial-fuel values

Reconfirm whether the Test-4 domain rates remain the accepted basis for virtual source-base -> External Spawn fuel.

Current candidates:

```text
MANAS:     91.4067 %
AL_UDEID:  79.4558 %
```

If the final approved transit configuration remains the same as Test 4 for the relevant calibration segment, no recalculation from older tests is required.

### Step 6 – Owner decision for production promotion

Before production modification, obtain explicit owner approval for the final package:

```text
- 480-kt SPAWN initialization;
- 300-kt route-speed retention;
- FL340/FL350 directional LRC levels;
- exact track mission altitude;
- final MANAS/AL_UDEID initial-fuel values;
- final per-track FuelLow values;
- no mandatory 60-NM late-approach point unless separately approved.
```

### Step 7 – Production implementation

After approval, make the smallest necessary production changes in the AAR controller/configuration and relevant template/build path.

Preserve:

```text
CampaignState authority
strategic off-map pool semantics
FIR routing
callsign family identity
standard/reserve roles
relief lifecycle
external handoff exact-once settlement
```

No `.miz` mutation by ChatGPT. Any required Mission Editor/template change must be specified to the owner after the source/build work is committed and pushed.

### Step 8 – Documentation / MOOSE register update

Update the binding AAR documentation and MOOSE project records with the final accepted values and exact evidence boundary.

At minimum review/update as applicable:

```text
docs/29-isaf-2009-2013-air-to-air-refueling.md
docs/moose/AAR-LRC-TRANSIT.md
docs/moose/PROJECT-CLASS-INDEX.md
docs/moose/VERIFIED-METHODS.md
mission/tests/aar-fuel-telemetry/POST-MERGE-FINDINGS.md
this worklist
```

Only methods/behaviors with real documented DCS evidence may be promoted to validated status.

### Step 9 – Diff, syntax, documentation validation and remote commit

Before handoff:

```text
- review complete diff;
- run available Lua/build checks;
- run documentation validator;
- verify no unintended `.miz` or production-scope changes;
- verify pinned MOOSE provenance;
- commit and push to the intended remote branch.
```

### Step 10 – Local owner verification

After the remote commit, provide the owner only the necessary numbered PowerShell steps for:

```text
git pull
build
hash verification
```

Real local console output and hashes become the evidence for the next step.

### Step 11 – Final DCS acceptance and merge readiness

The workstream reaches its target only after the final production candidate has documented real DCS evidence for the affected scope.

Required end state:

```text
- correct 480-kt materialization behavior;
- correct 300-kt route behavior;
- correct directional FL340/FL350 transit;
- correct exact track altitude;
- mandatory FIR ingress/egress preserved;
- initial fuel matches approved Test-4-derived source-domain model;
- FuelLow covers measured recovery plus adopted AFMAN reserve requirements;
- relief and strategic settlement regressions absent;
- complete mission/bundle/DCS/MOOSE provenance recorded;
- documentation updated;
- owner approves merge/readiness decision.
```

`VALIDATED` is only assigned to the exact scope proven by the documented DCS run.
