---
document_id: OMW-EVIDENCE-BAGRAM-F15E-PAYLOAD-2026-08-01
status: BINDING
document_class: MISSION_EDITOR_PAYLOAD_DECISION
owning_policy: OMW-GOV-001
authoritative_for:
  - Bagram F-15E CAS payload working baseline
  - Bagram F-15E strike payload working baseline
  - Mission Editor task selection for the F-15E strike authoring seed
  - intended MOOSE 2.9.18 CAS and STRIKE payload mapping
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - earlier F-15E CAS seed with AGM-65K and four-air-to-air-missile load
  - earlier F-15E strike seed with twelve Mk-82AIR and three external tanks
superseded_by:
source_branch: docs/bagram-air-operations-manifest
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Bagram F-15E CAS and Strike Payload Decision – 2026-08-01

## 1. Status and evidence boundary

This document records the project-owner-approved Mission Editor working baseline discussed and configured on 1 August 2026 for the Bagram F-15E templates.

Evidence available at the time of this decision:

- Mission Editor screenshots supplied in the Bagram working chat;
- project discussion of contemporary Bagram F-15E imagery;
- the actual MOOSE 2.9.18 `AUFTRAG` source mapping for `CAS` and `STRIKE`;
- the current branch implementation, which still registers only the CAS F-15E seed.

The following has **not** yet been completed:

- extraction and audit of the final saved `.miz` payload CLSIDs and fuze values;
- DCS runtime validation of takeoff, AI weapon employment, return and inventory handling;
- MOOSE runtime registration of the second F-15E strike payload;
- validation that the displayed Mission Editor mass values remain identical after the final save.

This is therefore a binding authoring decision for the active branch, but not a DCS acceptance result.

## 2. Common F-15E configuration

Both F-15E authoring seeds use the same common aircraft and sensor configuration:

```text
Aircraft: F-15E module representation used by the current mission
Formation seed: 2 aircraft
External fuel tanks: 2
LANTIRN navigation pod: installed
Targeting pod: installed
Internal gun: retained
Air-to-air contingency load: 1 x AIM-9M + 1 x AIM-120 per aircraft
```

The exact AIM-120 subvariant and the exact pod CLSIDs must be read from the final `.miz`; they are not inferred from the screenshots alone.

The air-to-air missiles are recorded as contingency carriage visible on Bagram-era imagery, not as protection against a Taliban air threat.

The sensor pods do not distinguish CAS from strike. Role separation is created by mission tasking, target type, rules of engagement and the air-to-ground payload.

## 3. CAS payload baseline

Mission Editor authoring seed:

```text
TPL_AIR_US_BGRM_F15E_CAS_2SHIP
Mission Editor task: CAS
Payload name: OMW Standard CAS
```

Per aircraft:

```text
3 x GBU-54/B
3 x GBU-38
2 x external fuel tank
1 x AIM-9M
1 x AIM-120
LANTIRN navigation pod
Targeting pod
internal M61A1
```

Intended role:

- dynamic close air support;
- fixed targets with known or generated coordinates using GBU-38;
- moving, relocating or laser-updated targets using GBU-54/B;
- armed overwatch and flexible target prosecution in a COIN environment.

The `3 + 3` mix is selected because the DCS F-15E CFT load options permit a symmetrical three-store GBU-38/GBU-54 arrangement. DCS does not provide a corresponding three-store GBU-12 CFT option; a GBU-12/GBU-38 mix would therefore create an avoidable one-bomb lateral quantity difference.

Screenshot-observed Mission Editor values for the configured CAS seed:

```text
Internal fuel: 30,518 lb / 100 percent
Weapons:        5,884 lb
Total mass:    75,339 lb
Displayed load: 93 percent of 81,000 lb maximum
```

These values remain subject to final `.miz` audit.

## 4. Strike payload baseline

Mission Editor authoring seed:

```text
TPL_AIR_US_BGRM_F15E_STRIKE_2SHIP
Mission Editor task: Bodenangriff / Ground Attack
MOOSE mission type: AUFTRAG.Type.STRIKE
Payload name: OMW Standard STRIKE
```

Per aircraft:

```text
1 x GBU-31(V)1/B with Mk-84 general-purpose warhead
1 x GBU-31(V)3/B with BLU-109 penetrator warhead
2 x external fuel tank
1 x AIM-9M
1 x AIM-120
LANTIRN navigation pod
Targeting pod
internal M61A1
```

The two-ship package therefore carries in total:

```text
2 x GBU-31(V)1/B
2 x GBU-31(V)3/B
```

Intended role:

- pre-planned attack on a confirmed target complex;
- isolated storage facilities and larger surface structures;
- hardened structures, bunkers and suitable cave or tunnel entrances;
- mixed target sets containing both surface and penetrator targets.

This is a heavy precision-strike option. It is not the default weapon choice for ordinary houses in inhabited areas. Target approval, collateral-damage restrictions and the no-strike framework remain controlling.

Screenshot-observed Mission Editor values after reducing the load from two of each GBU-31 variant to one of each per aircraft:

```text
Internal fuel: 30,518 lb / 100 percent
Weapons:        6,839 lb
Total mass:    76,293 lb
Displayed load: 94 percent of 81,000 lb maximum
```

The high gross weight requires later Bagram hot-and-high takeoff and AI-behaviour testing. It is not presently a runtime acceptance.

## 5. Agreed fuze working baseline

### 5.1 GBU-31(V)1/B

General-purpose strike against a surface structure or storage target:

```text
Nose configuration: installed / plugged
Nose plug:           MXU-735
Tail fuze:           FMU-139
Arming delay:        10 s
Function delay:      0 s
```

The DSU-33 proximity option is not part of this standard strike configuration.

### 5.2 GBU-31(V)3/B

Penetrator strike against a hardened target:

```text
Tail fuze:           FMU-143
Arming delay:        12 s
Function delay:      60 ms
```

The 60 ms delay is the project working compromise for meaningful penetration without defining a special maximum-depth bunker profile. Separate 30 ms or 120 ms variants require a specific target and a separate test or payload decision.

The final saved `.miz` must be audited to prove that these values were actually stored for both aircraft in the two-ship template.

## 6. MOOSE 2.9.18 task mapping

The vendored-version check established the following mapping:

```text
AUFTRAG.Type.CAS
-> DCS mission task CAS
-> Mission Editor task CAS

AUFTRAG.Type.STRIKE
-> ENUMS.MissionTask.GROUNDATTACK
-> DCS mission task Ground Attack
-> German Mission Editor task Bodenangriff
```

`Präzisionsangriff / Pinpoint Strike` is a distinct DCS mission-task enum but is **not** the task returned by MOOSE 2.9.18 for `AUFTRAG.Type.STRIKE`.

Therefore the strike authoring seed must use:

```text
Bodenangriff
```

and not:

```text
CAS
Präzisionsangriff
```

## 7. Current implementation gap

The current Bagram runtime branch still contains only one configured F-15E template entry:

```lua
F15E = "TPL_AIR_US_BGRM_F15E_CAS_2SHIP"
```

The current F-15E SQUADRON capability is still limited to:

```lua
AUFTRAG.Type.ALERT5
AUFTRAG.Type.CAS
```

Consequently, the new strike seed exists as a Mission Editor authoring decision but is not yet recruited by the AIRWING.

A later MOOSE-first implementation increment must:

1. validate both F-15E template groups and their exact payload contracts;
2. keep one logical `SQ_US_BGRM_F15E_335_EFS` inventory;
3. register the CAS payload for `AUFTRAG.Type.CAS`;
4. register the strike payload for `AUFTRAG.Type.STRIKE`;
5. add `AUFTRAG.Type.STRIKE` to the F-15E SQUADRON mission capability;
6. prove that payload selection does not duplicate aircraft inventory;
7. validate AI weapon release, target selection, return and stock restoration.

## 8. Acceptance still required

The following checks remain mandatory before this payload baseline may be called runtime-accepted:

```text
final .miz extraction and CLSID audit
both aircraft in each two-ship have identical intended loadouts
strike template task saved as Ground Attack / Bodenangriff
fuze values saved as specified
CAS AUFTRAG selects only the CAS payload
STRIKE AUFTRAG selects only the strike payload
no spontaneous activation of either Late Activation template
Bagram takeoff test at representative hot-and-high weather
AI release test against surface and hardened targets
safe return and correct AIRWING inventory restoration
no Lua, payload, parking or tasking errors
```
