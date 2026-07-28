---
document_id: OMW-EVIDENCE-SHINDAND-SATELLITE-2013
status: BINDING
document_class: VISUAL_EVIDENCE_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - project-side visual observations from the supplied Shindand satellite imagery
  - post-period ramp geometry and area-use evidence
not_authoritative_for:
  - exact 2010 or 2011 Shindand ORBAT
  - unit identity without independent evidence
  - mission-ready or maintenance status
scenario_period: 2010-08-01/2011-12-31
observation_date: 2013-09-30
evidence_class: POST_PERIOD_CONTEXT
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/document-shindand-air-operations
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Shindand Satellite Observations – 30 September 2013

## 1. Purpose and evidence boundary

This record preserves the project-side visual interpretation of the supplied Google Earth imagery for Shindand Air Base dated **30 September 2013**.

The imagery is outside the binding Operation Mountain Watch scenario period of 1 August 2010 through 31 December 2011. It is therefore classified as:

```text
POST_PERIOD_CONTEXT
```

It may be used for:

- apron and parking geometry;
- separation of operational areas;
- approximate capacity;
- visual density and scene composition;
- placement guidance for statics, clients and functional zones.

It may not by itself establish:

- an exact 2010/2011 aircraft inventory;
- permanent unit identity;
- readiness or maintenance status;
- a separate active OMW SQUADRON;
- additional campaign stock.

## 2. Supplied image set

The working set contained:

- one base overview;
- the large northeastern rotary-wing apron;
- the eastern/Camp Shindand apron;
- eastern hardened shelters and southeastern apron;
- northwestern training apron;
- southwestern legacy/industrial areas.

The original image files remain user-supplied working evidence and are not embedded in this repository document.

## 3. Northeastern rotary-wing apron

### 3.1 Clear visual count

```text
14 UH-60-like helicopters
 2 CH-47 helicopters
 0 clearly visible AH-64
```

One faint or ghosted rotorcraft-like image was ambiguous and is not included in the confirmed count.

### 3.2 Interpretation

The apron is suitable as the primary OMW US-Army rotary-wing operating area because it provides:

- multiple aligned medium-helicopter positions;
- visibly usable heavy-lift positions;
- sufficient separation for a mixed AH-64/UH-60/CH-47 presentation;
- an area layout consistent with later US rotary-wing use.

The visible 2013 count is a snapshot and not the source of the binding OMW `8/8/4` inventory.

### 3.3 Temporal limitation

The expanded northeastern rotary-wing apron is treated as a late-period or post-development facility. Its completed geometry is suitable for the OMW foundation build, but it must not be presented as proof that the same completed ramp state and the same formation existed throughout the entire 2010–2011 scenario.

## 4. Eastern / Camp Shindand apron

### 4.1 Visual observations

```text
6 large single-rotor helicopters, visually consistent with Mi-17/Hip family
1 large twin-engine transport, visually consistent with C-27A/G.222 family
1 small high-wing aircraft, visually consistent with Cessna 208B family
```

These identifications are visual working assessments and not formal airframe serial identification.

### 4.2 Mission-design use

This area should primarily represent:

- Afghan Air Force and air-advisor operations;
- training and support traffic;
- fixed-wing and Mi-17 activity separate from the US-Army rotary-wing pool.

Aircraft placed here do not draw from `AW_US_SHINDAND` unless explicitly assigned by a later project decision.

## 5. Northwestern training apron

### 5.1 Visual observations

```text
5 Mi-17-like helicopters
several small high-wing training aircraft
```

The small aircraft are visually compatible with Cessna 208B and possibly Cessna 182 family aircraft. Exact counting was obstructed by map overlays and image resolution.

### 5.2 Mission-design use

This area is appropriate for:

- Afghan rotary-wing training;
- fixed-wing training aircraft;
- air-advisor atmosphere;
- non-US-Army static scene composition.

It should remain organizationally and logically separated from the US-Army AIRWING inventory.

## 6. Hardened shelters and southeastern apron

### 6.1 Hardened shelters

Approximately 26 hardened shelters are visible. They appeared largely empty in the supplied imagery.

Recommended use:

- legacy airbase character;
- limited storage or maintenance scenery;
- controlled mission-specific use only;
- no automatic assumption of hidden aircraft inventory.

### 6.2 Southeastern apron

The southeastern apron appeared substantially empty.

Recommended use:

- reserve geometry;
- temporary staging;
- future functional zones after collision and parking tests;
- no unvalidated dynamic spawn use.

## 7. Southwestern legacy and industrial areas

The southwestern areas appeared lower-use and compatible with:

- storage;
- maintenance atmosphere;
- industrial or legacy airbase scenery;
- non-operational static composition.

They should not be used for normal AIRWING spawn or recovery without a dedicated parking and taxi validation.

## 8. OMW area assignment

| Area | primary OMW function | inventory boundary |
|---|---|---|
| northeastern rotary apron | US-Army AH-64/UH-60/CH-47 operations | `AW_US_SHINDAND` |
| eastern/Camp Shindand apron | Afghan Air Force, air-advisor and mixed support activity | separate from US-Army stock |
| northwestern apron | Afghan training activity | separate from US-Army stock |
| hardened shelters | legacy/maintenance/storage atmosphere | no hidden stock inferred |
| southeastern apron | reserve and later validated functional use | no automatic spawn use |
| southwestern areas | low-use, storage and industrial scenery | no normal AIRWING use |

## 9. Relationship to the active Shindand decision

The binding OMW inventory is a project decision documented in:

- [`OMW-AIR-ACTIVE-ORBAT`](../19-active-air-orbat-decisions.md);
- [`OMW-AIR-SHINDAND-MANIFEST`](../shindand-air-operations-manifest.md).

```text
8 AH-64D
8 UH-60 including MEDEVAC
4 CH-47
```

The satellite imagery supports geometry and visual plausibility. It does not independently prove this exact inventory.

## 10. Visual scene guidance

The accepted initial US-Army static presentation is:

```text
4 AH-64 statics
4 UH-60 statics
1 CH-47 static
```

This produces nine visible US-Army helicopter statics while preserving room for clients, AI and virtual reserve within the logical `8/8/4` ceiling.

The 2013 northeastern-apron observation of 14 UH-60-like and two CH-47 aircraft is not reproduced literally because:

- the imagery is post-period;
- the active OMW inventory is smaller;
- clients and AI must use the same logical stock;
- excessive statics would block dynamic parking and create double counting.

## 11. Unresolved visual and technical work

Still required:

- Shindand parking and terminal-ID dump;
- exact mapping of statics to nearby parking nodes;
- heavy-lift suitability test;
- rotor-clearance test;
- AI taxi, takeoff, landing and recovery test;
- functional-zone placement;
- separate Afghan-training scene manifest if that scene becomes operational rather than atmospheric.
