---
document_id: OMW-AWACS-EXTERNAL-LIFECYCLE-ACCEPTANCE
status: PLANNED
document_class: DCS_ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - AWACS external-lifecycle acceptance plan and staged validation boundaries
  - Acceptance-1 routing lifecycle criteria and subsequent AWACS acceptance gates
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/awacs-external-lifecycle-foundation
source_commit: GIT_HISTORY
validated_in_dcs: partial
supersedes:
superseded_by:
---

# AWACS External Lifecycle – Acceptance Plan

Status: `ROUTING LIFECYCLE PASS / PARTIAL DCS VALIDATION`

## 1. Testgegenstand

```text
Template:          OMW_C2_E3A_WIZARD
Platform:          E-3A
Strategic source:  OFFMAP_AL_DHAFRA
External spawn:    N31°30'42.29" E069°13'47.32" approximately
FIR ingress:       ROSIE
AEW area:          APOC
Callsign family:   WIZARD
Primary frequency: 357.300 MHz AM
Track:             FL320 / 300 kt / 017°T / 30 NM leg
FIR egress:        ROSIE
External handoff:  spawn coordinate
```

The external spawn coordinate is the computed point 15 NM before the period-correct ROSIE fix on the ZHOB-to-ROSIE geometry. It is an OMW materialization abstraction and not a historical Pakistan ATS claim.

## 2. Staging mission provenance

Owner-supplied mission used to confirm the current E-3 Mission Editor template before runtime integration:

```text
Mission artifact:        OMW_Template_v19(4).miz
MIZ SHA-256:              38f4cb47bbbf6ea66b678467c406d82e4ce0e2cf3cd9d89ccd0efcb9d60b6884
internal mission SHA-256: 93e2f752f5123c1cf7c7f6efb186ef2f7a470845ba484355649ca8a201430c00
```

Read-only template inspection confirmed:

```text
Group:       OMW_C2_E3A_WIZARD
Unit:        OMW_C2_E3A_WIZARD_01
Type:        E-3A
Task:        AWACS
Late Act.:   true
Callsign:    Wizard11
Frequency:   357.300 MHz AM
Fuel:        65000 kg
Skill:       Excellent
```

This is staging provenance only. It is not an AWACS runtime PASS and does not validate the branch bundle.

## 3. Local source/build provenance – 2026-08-23

Owner-executed local verification from the dedicated AWACS worktree:

```text
Worktree: P:\DCS-DEV\Operation-Mountain-Watch-AWACS
Branch:   agent/awacs-external-lifecycle-foundation
Tested source commit: bde8a6e8d006b7c8d744b739510b08aa9812d48b
Pre-build git status: clean
Post-build git status: clean
```

The existing AAR production source gate passed unchanged on the AWACS branch:

```text
AAR production finalization source gate: PASS
CampaignStateAuthority: true
StrategicTurnaroundTimer: false
LossRecredit: false
RestoreReconciliation: true
StandardTracks: 4
ReserveTracks: 2
FIRFixRouting: true
ExternalSpawnHandoffSeparated: true
AirwaysRouting: false
```

AWACS foundation build output:

```text
BuilderVersion: OMW-AIROPS-AWACS-FOUNDATION-1
Scope: AWACS_EXTERNAL_LIFECYCLE_FOUNDATION
Template: OMW_C2_E3A_WIZARD
StrategicSource: OFFMAP_AL_DHAFRA
FIRFix: ROSIE
PrimaryArea: APOC
Callsign: WIZARD
FrequencyMHzAM: 357.300
TrackAltitudeFt: 32000
TrackSpeedKt: 300
TrackHeadingTrueDeg: 17
TrackLegNm: 30
LateApproachNm: 30
StationCycleSec: 21600
MaxPhysicalAircraft: 2
AutomaticRefuelDispatch: false
DCSValidated: false
MizMutation: false
```

Real local SHA-256 values reported by the owner after the final build:

```text
OMW_AWACS_Foundation.lua
639841A552343F4D0F7180F657A4A0B3141FB0B9AF3ED6F1D9915EC955444FC2

OMW_AWACS_Controller.lua
6ED1C54465764B5745F1071A59439F29DC08A93D1875492D25FF5BA889BD13BD

OMW_AWACS_CampaignStateAdapter.lua
2E2129959EDC131C3FAA51B7E9A1F64B46D82F1F4C57968AECAB070DD1EA2754

OMW_AirOps_AWACS_Bootstrap.lua
60E039A6C13D2B952AB33AB8FE2D7E6113B652A6EE75D252BC7466A834143344

OMW_AARStrategicStock.lua
2B53644DC2966B142B975B31F469CBE8AD5E8088A86ADC36940A7E745322D00C

OMW_AirOpsCampaignStateInitializer.lua
5D16C40DFDBF8841AE15E0CC62C52F6922953A4F561071E2C018DB9DD43B41E8

OMW_AirOps_Warehouse_Base.lua
01A9CA70988198ECBD76F4D1CAB4304261F2CC56911584B44741C0D49C7B146C
```

Pinned MOOSE for this build:

```text
Release:           2.9.18
Commit:            73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## 4. MOOSE-first path under test

```text
SPAWN:New(template)
-> SPAWN:InitCallSign(...)
-> SPAWN:InitHeading(...)
-> SPAWN:InitSpeedKnots(...)
-> SPAWN:SpawnFromCoordinate(...)
-> FLIGHTGROUP:New(...)
-> FLIGHTGROUP:AddWaypoint(ROSIE, FL340)
-> FLIGHTGROUP:AddWaypoint(30-NM late approach, FL350)
-> OnAfterPassingWaypoint confirms ROSIE UID
-> OnAfterPassingWaypoint confirms late-approach UID
-> FLIGHTGROUP:AddMission(AUFTRAG:NewAWACS(...))
-> AUFTRAG:SetMissionAltitude(FL320)
-> APOC racetrack
-> AUFTRAG:Cancel()
-> AUFTRAG:SetMissionEgressCoord(ROSIE, FL340, 300 kt)
-> physical ROSIE egress passage
-> FLIGHTGROUP:AddWaypoint(external handoff, FL340)
-> external handoff / Despawn
```

## 5. Required DCS acceptance observations

1. E-3 materializes at the external point, outside Kabul FIR, without a visible teleport inside Afghanistan.
2. Initial energy state is plausible for E-3; `400 kt` is a staging value and must be corrected if DCS behavior is implausible.
3. E-3 physically crosses ROSIE before the late-approach point.
4. Cruise profile remains high until late approach; no premature descent to track altitude.
5. After the 30-NM late-approach passage, the AWACS mission is added and the aircraft transitions naturally to FL320 / 300 kt.
6. APOC racetrack geometry is approximately 017°T with 30 NM leg.
7. Native DCS AWACS service is available as WIZARD on 357.300 MHz AM while on mission.
8. Planned station timing does not trigger an early replacement.
9. Relief materializes early enough to arrive before planned handover; outgoing aircraft remains station owner until physical relief arrival.
10. On scheduled egress, outgoing E-3 leaves APOC and returns to FL340 / 300 kt toward ROSIE.
11. E-3 physically crosses ROSIE outbound before external handoff routing is added.
12. E-3 despawns only at the external handoff and the CampaignState E-3 is recredited exactly once.
13. Aircraft loss consumes the committed E-3 permanently and increments only the loss audit resource.
14. Restart reconciliation recredits unresolved physical commitments but preserves documented losses.

## 6. DCS Acceptance 1 – routing lifecycle PASS – 2026-08-23

### 6.1 Exact provenance

The owner supplied the actual mission and logs from the successful routing lifecycle run. Hashes below were calculated directly from those uploaded artifacts. The `.miz` was also unpacked read-only and the embedded runtime bundle hashes were verified.

```text
Branch:                  agent/awacs-external-lifecycle-foundation
Tested source commit:    bde8a6e8d006b7c8d744b739510b08aa9812d48b
Mission:                 OMW_Template_v19(8).miz
Mission SHA-256:         d788af36535d3acd1866d15ffb5d354b2c44b5f8ee40d4baf6fd1d97b7c0f8a5
DCS:                     2.9.28.26385 MT
MOOSE release:           2.9.18
MOOSE commit:            73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Embedded Moose.lua SHA:  e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Embedded Warehouse SHA:  01a9ca70988198ecbd76f4d1cab4304261f2cc56911584b44741c0d49c7b146c
Embedded AWACS SHA:      639841a552343f4d0f7180f657a4a0b3141fb0b9af3ed6f1d9915ec955444fc2
Controller source SHA:   6ed1c54465764b5745f1071a59439f29dc08a93d1875492d25ff5ba889bd13bd
dcs.log SHA-256:         593d02d455db0cae04cfd0e7651671d3af1d76ab430ff3232da7b19dac391c2f
debrief.log SHA-256:     32df4af4943f5ca3d2a98dde61e452054b5183fd21fa9f6b78750894ec106eb7
Result:                   PASS for routing lifecycle scope only
```

### 6.2 Important log provenance note

The supplied `dcs.log` contains two mission attempts from the same DCS process. The earlier attempt at `15:48:30.867` failed before AWACS materialization because an older Warehouse bundle did not contain `OFFMAP_AL_DHAFRA`:

```text
[OMW][CampaignState] unknown nodeId=OFFMAP_AL_DHAFRA
```

That mismatch was corrected by rebuilding and embedding the Warehouse production base. The later run beginning with AWACS materialization at `15:57:57.133` is the successful Acceptance-1 run documented here. The final uploaded `.miz` contains the corrected Warehouse bundle hash `01a9ca...b146c` and the final AWACS bundle hash `639841...44fc2`.

The earlier failed attempt is retained as diagnostic history and is not counted as the Acceptance-1 result.

### 6.3 Runtime evidence

The successful run logged the required lifecycle in order:

```text
15:57:57.133 MATERIALIZED
  runtime=AWACS-0001
  role=ACTIVE
  source=AL_DHAFRA
  spawnToRosieNm=15.06
  rosieToApocNm=61.25
  firToLateNm=31.25
  callsign=Wizard1-1
  frequencyMHz=357.300

15:58:58.993 FIR_INGRESS_PASSED
  fix=ROSIE
  waypointUid=2

15:59:03.477 LATE_APPROACH_PASSED
  distanceToTrackNm=30.0
  action=ADD_AWACS_MISSION

15:59:05.836 ON_STATION
  area=APOC
  cycleSec=21600
  reliefLaunchInSec=20984

15:59:18.414 EGRESS_ORDERED
  reason=ACCEPTANCE_1_ROUTING_EGRESS
  target=ROSIE
  altitudeFt=34000
  speedKt=300

15:59:27.726 FIR_EGRESS_PASSED
  fix=ROSIE
  action=ROUTE_EXTERNAL_HANDOFF

15:59:28.065 MOOSE AUFTRAG
  Mission 3 [AWACS] success!

15:59:29.166 EXTERNAL_HANDOFF
  action=DESPAWN_AND_RECREDIT
```

The debrief state records the dedicated Acceptance-1 stop flag for the AWACS group:

```text
OMW_C2_E3A_WIZARD#001 StopTaskFlag 1
  time  = 1800.801
  value = 1
```

### 6.4 Accepted technical scope

For the exact provenance above, the following path is DCS-validated:

```text
external SPAWN materialization
-> ROSIE inbound passage
-> 30-NM late-approach passage
-> FLIGHTGROUP:AddMission(AUFTRAG:NewAWACS(...))
-> APOC ON_STATION transition
-> controlled AUFTRAG cancellation/egress order
-> ROSIE outbound passage
-> external-handoff waypoint
-> Despawn / strategic recredit path
```

This practically validates the AWACS use of the already MOOSE-first external-flight pattern and specifically confirms `AUFTRAG:NewAWACS(...)` in the documented OMW routing lifecycle.

### 6.5 Not validated by Acceptance 1

Acceptance 1 does not yet prove:

```text
observed cruise altitude and speed compliance throughout transit
observed APOC racetrack heading and 30-NM leg geometry
player-side native AWACS service usability on 357.300 MHz AM
fuel state and burn telemetry
six-hour station endurance
scheduled relief launch, arrival and physical handover
loss settlement
restart reconciliation
AWACS aerial-refuelling dispatch and tanker rendezvous policy
```

Accordingly, the complete AWACS foundation is not yet production-validated. Only the routing lifecycle scope above is accepted.

## 7. Fuel calibration – mandatory before production validation

The current Mission Editor template contains `65000 kg` fuel. No public `SPAWN:InitFuel(...)` path is assumed.

The following values are still required from DCS telemetry:

```text
External spawn fuel state
Spawn -> ROSIE burn
ROSIE -> APOC burn
APOC hourly station burn
APOC -> ROSIE -> external handoff burn
45-minute or approved AWACS reserve component
FuelLow / AAR decision threshold
```

No linear conversion from published endurance to DCS fuel percentage is accepted as a replacement for telemetry.

## 8. AAR acceptance boundary

AFCENT documents E-3 aerial refuelling over Afghanistan in 2011. The pinned MOOSE source provides `FLIGHTGROUP:Refuel(...)` and the FuelLow/refuel FSM path.

However, the current foundation intentionally returns:

```text
AWACS_AAR_DCS_ACCEPTANCE_REQUIRED
```

for active AWACS refuel dispatch. Reason: `FLIGHTGROUP:Refuel(...)` by itself does not encode the OMW policy for selecting a specific STANDARD/RESERVE tanker, preserving the desired cruise profile, or deciding whether the tanker should instead move to APOC.

Production AAR behavior therefore requires a separate acceptance covering both alternatives:

```text
A) AWACS leaves APOC -> cruise profile -> designated tanker rendezvous -> refuel -> APOC
B) reserve tanker is dispatched to an AWACS-compatible rendezvous near APOC while AWACS remains on station
```

No automatic nearest-tanker behavior is approved by this foundation.

## 9. Provenance required for complete foundation PASS

A complete foundation PASS must record:

```text
branch
commit
mission filename
mission SHA-256
bundle SHA-256
controller SHA-256
DCS version
MOOSE release / commit / SHA-256
dcs.log SHA-256
debrief.log SHA-256
observed timing / altitude / fuel telemetry
relief lifecycle evidence
loss/restart evidence
AAR evidence if automatic refuelling is enabled
```

Acceptance 1 satisfies the provenance requirement for the routing lifecycle only. The complete AWACS foundation remains partially validated until the remaining acceptance blocks are completed.
