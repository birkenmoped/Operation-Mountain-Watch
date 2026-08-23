# AWACS External Lifecycle – Acceptance Plan

Status: `STAGED / NOT VALIDATED IN DCS`

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

## 3. MOOSE-first path under test

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

Pinned MOOSE:

```text
Release:           2.9.18
Commit:            73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## 4. Required DCS acceptance observations

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

## 5. Fuel calibration – mandatory before production validation

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

## 6. AAR acceptance boundary

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

## 7. Provenance required for PASS

A PASS must record:

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
```

Until that record exists, this foundation is not `VALIDATED`.