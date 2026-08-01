---
document_id: OMW-EVIDENCE-BAGRAM-F16C-CAS-PAYLOAD-2026-08-01
status: BINDING
document_class: MISSION_EDITOR_PAYLOAD_DECISION
owning_policy: OMW-GOV-001
authoritative_for:
  - Bagram F-16C CAS historical payload working interpretation
  - Bagram F-16C CAS Vanilla-DCS substitution baseline
  - Bagram F-16C outer-wing air-to-air and clean-station configuration
  - Mission Editor payload contract for TPL_AIR_US_BGRM_F16_CAS_2SHIP
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - earlier proposed four-air-to-air-missile F-16C CAS configuration
  - earlier unqualified proposal of a historically exact GBU-12 and GBU-38 mix
superseded_by:
source_branch: docs/bagram-air-operations-manifest
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Bagram F-16C CAS Payload Decision – 2026-08-01

## 1. Status and evidence boundary

This document records the project-owner-approved working baseline discussed on 1 August 2026 for the Bagram F-16C CAS template.

The decision separates three different subjects:

1. the visually supported 2011 Bagram configuration;
2. the capabilities of the real GBU-38 and GBU-54 load;
3. the closest functional substitution available on the unmodified DCS F-16C Block 50.

Evidence reviewed during the decision included the project-supplied contemporary Bagram photographs:

```text
110309-F-XA488-095.jpg
110309-F-XA488-120.jpg
110309-F-XA488-141.jpg
110715-F-DE377-002.jpg
```

The images show Bagram F-16 operations and weapon loading but are not an official aircraft load sheet. Identification of the two JDAM-family variants is therefore recorded as the binding project working interpretation, not as a claim that every aircraft and every sortie carried an identical load.

The following has not yet been completed:

- extraction and audit of the final saved `.miz` payload CLSIDs;
- DCS external-model inspection of stations 2 and 8 after saving the empty stations;
- DCS runtime validation of AI employment of both GBU-38 and GBU-12;
- verification of the exact AIM-120 subvariant and targeting-pod CLSID used in the mission;
- validation of takeoff, return and AIRWING inventory handling.

This is a binding Mission Editor authoring decision, but not a DCS runtime acceptance result.

## 2. Historical 2011 working interpretation

The supplied Bagram imagery supports the following working interpretation per aircraft:

```text
2 x GBU-38 JDAM
2 x GBU-54 Laser JDAM
2 x 370-gallon external fuel tank
2 x AIM-120 on the wingtip stations
Targeting pod
internal M61A1
```

Bomb carriage is interpreted as:

```text
Station 3:
  BRU-57
  1 x GBU-38
  1 x GBU-54

Station 7:
  BRU-57
  1 x GBU-38
  1 x GBU-54
```

The working identification is based on the visible JDAM-family bodies and the differing nose/seeker appearance. It is not derived from a published station-by-station load record.

The real capability set was therefore:

```text
4 x GPS/INS-capable 500-lb precision weapon
2 of those weapons additionally laser-capable
2 x moving or relocating target capability through laser guidance
0 weapons requiring laser designation for ordinary fixed-coordinate employment
```

The GBU-54 was a dual-mode weapon. It must not be documented as equivalent to a pure laser-guided GBU-12.

## 3. Outer-wing air-to-air configuration

The Bagram CAS working baseline uses:

```text
Station 1: AIM-120
Station 2: clean
Station 8: clean
Station 9: AIM-120
```

`Clean` means:

```text
no AIM-9
no additional AIM-120
no LAU-129 launcher or underwing missile adapter intended on station 2 or 8
```

The wingtip AIM-120 carriage is retained as the visually supported and aerostructurally normal F-16 configuration. It does not imply a Taliban air threat.

Additional AIM-9 missiles on stations 2 and 8 are not part of the Bagram CAS standard. The relevant photographs do not provide a basis for the previously proposed four-missile air-to-air load.

Because DCS controls the rendered external hardware, the final mission must be visually checked to confirm that empty stations 2 and 8 are displayed without an unintended launcher or pylon.

## 4. DCS representation limits

The native DCS F-16C Block 50 used by OMW cannot reproduce the historical working interpretation exactly:

```text
GBU-54 is not available on the represented DCS F-16C configuration.
A mixed GBU-38 and GBU-54 pair on one BRU-57 is therefore unavailable.
A GBU-38 and GBU-12 mixed pair on one BRU-57 is also not a valid DCS carriage solution.
GBU-38 uses BRU-57 paired carriage.
GBU-12 uses TER-9A paired carriage.
```

An exact visual, station and capability match is therefore impossible in unmodified DCS.

## 5. Binding Vanilla-DCS functional substitute

Mission Editor authoring seed:

```text
TPL_AIR_US_BGRM_F16_CAS_2SHIP
Mission Editor task: CAS
Payload working name: OMW F-16 CAS Functional GBU-54 Substitute
```

Per aircraft, the binding working payload is:

```text
Station 1: 1 x AIM-120
Station 2: clean
Station 3: BRU-57 with 2 x GBU-38
Station 4: 370-gallon external fuel tank
Station 5R: targeting pod; exact type and CLSID to be audited
Station 6: 370-gallon external fuel tank
Station 7: TER-9A with 2 x GBU-12
Station 8: clean
Station 9: 1 x AIM-120
Internal: M61A1
```

The lateral assignment of GBU-38 to station 3 and GBU-12 to station 7 is the current authoring default. Mirroring it is not a new payload concept, but any change must be recorded in the final `.miz` audit so that both aircraft in the two-ship seed remain identical.

No AIM-9 is carried in the standard CAS configuration.

No ECM pod is assumed by this decision. A centerline or other ECM installation requires separate image, source or final-mission evidence.

## 6. Purpose and limitations of the substitute

The DCS substitute preserves the following operational choice:

```text
2 x GPS/INS weapon for fixed coordinate targets and adverse visibility
2 x laser-guided weapon for self-, JTAC- or buddy-lased targets
4 x total 500-lb precision weapons
```

It does not preserve the full real capability:

| Capability | Historical working interpretation | DCS substitute |
|---|---:|---:|
| Total 500-lb precision weapons | 4 | 4 |
| GPS/INS-capable weapons | 4 | 2 |
| Laser-capable weapons | 2 | 2 |
| Dual-mode weapons | 2 | 0 |
| Weapons usable without laser | 4 | 2 |
| Laser-required weapons | 0 | 2 |
| Moving-target laser option | 2 | 2 |

The GBU-12 is therefore a functional stand-in for the laser mode of the unavailable GBU-54. It is not documented as the visually confirmed 2011 standard weapon on the reviewed aircraft.

## 7. Rejected or non-standard alternatives

### 7.1 Four air-to-air missiles

Rejected as the standard Bagram CAS configuration:

```text
2 x wingtip AIM-120
2 x AIM-9 on stations 2 and 8
```

The additional heaters add no required capability for the documented COIN CAS task and are not supported by the reviewed standard-load imagery.

### 7.2 Four GBU-38

```text
4 x GBU-38 on two BRU-57
```

This would be visually and aerodynamically closer to the JDAM-family carriage and would retain four GPS-capable weapons. It would, however, remove the laser-guided target option that the real GBU-54 provided.

It is therefore not the selected universal CAS baseline. It may later be considered as an adverse-weather or fixed-coordinate client preset, but it does not require a second KI template unless a later MOOSE-first payload-selection test proves that a separate seed is necessary.

### 7.3 GBU-12 and GBU-38 described as historically exact

Rejected. The `2 x GBU-38 + 2 x GBU-12` configuration is an explicit DCS capability substitute and must never be presented as the exact photographed 2011 load.

## 8. Mission Editor and runtime contract

The final F-16C CAS seed must satisfy all of the following:

```text
exactly 2 aircraft in the authoring seed
Late Activation enabled
Uncontrolled disabled
Mission Editor task CAS
both aircraft have identical payloads
stations 2 and 8 empty
no AIM-9 carried
2 x GBU-38 on one BRU-57
2 x GBU-12 on one TER-9A
2 x external fuel tank
2 x wingtip AIM-120
targeting pod installed
```

The exact weapon, rack, missile, tank and targeting-pod CLSIDs must be extracted from the final `.miz`; they must not be inferred from Mission Editor labels alone.

The AIRWING and SQUADRON implementation must use the template as a payload and spawn seed only. It must not count the two template aircraft as additional inventory.

## 9. Acceptance still required

Before this payload may be called runtime-accepted, the following checks remain mandatory:

```text
final .miz extraction and complete CLSID audit
both aircraft have identical rack and store assignments
station 2 and station 8 render clean without unintended launchers
wingtip missiles render and identify as the intended AIM-120 variant
targeting-pod type and station are confirmed
CAS AUFTRAG selects the F-16C CAS payload
AI can employ GBU-38 against a valid coordinate target
AI can employ GBU-12 with valid laser support
AI does not attempt invalid weapon use against unsupported target types
representative Bagram hot-and-high takeoff succeeds
safe landing and return restore the correct logical inventory
no spontaneous activation of the Late Activation template
no relevant Lua, payload, pylon, parking or tasking error
```
