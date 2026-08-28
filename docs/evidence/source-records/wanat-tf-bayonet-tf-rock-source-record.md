---
document_id: OMW-EVIDENCE-WANAT-TF-BAYONET-TF-ROCK-SOURCE-RECORD
status: BINDING
document_class: SOURCE_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - provenance and scope of the Wanat source package
  - extraction boundaries for document 74
not_authoritative_for:
  - active OMW ORBAT
  - 2010-2011 force strengths without corroboration
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: docs/afghanistan-aip-kaia-lop
source_commit: ea64ec9c73c56923ea72d71789a530ecb0e69958
validated_in_dcs: false
supersedes: []
superseded_by: []
---

# Wanat, TF Bayonet and TF Rock – Source Record

## 1. Source files

| Supplied file | Source identity | Scope |
|---|---|---|
| `Wanat.pdf` | Combat Studies Institute Press, *Wanat: Combat Action in Afghanistan, 2008*, 2010 | researched historical narrative, 268 pages |
| `2. Wanat VSR Walkbook 2021.0.docx` | Army University Press / Combat Studies Institute virtual staff-ride walkbook | 78-page instructional narrative and virtual-terrain guide |
| `3. Wanat VSR Visuals 2021.0.pptx` | Army University Press / Combat Studies Institute staff-ride visuals | organization charts, maps, position diagrams, operational graphics and timelines |

## 2. Source class

```yaml
source_class: OFFICIAL_US_ARMY_HISTORICAL_AND_EDUCATIONAL_SOURCE_PACKAGE
primary_historical_study: Wanat.pdf
supporting_staff_ride_material:
  - 2. Wanat VSR Walkbook 2021.0.docx
  - 3. Wanat VSR Visuals 2021.0.pptx
historical_period: 2006-2008
principal_event: 2008-07-13
scenario_fit: PRE_PERIOD_CONTEXT
```

## 3. Extracted subject areas

- RC-East command and force-density context;
- 173rd ABCT / TF Bayonet organization and strengths;
- FOB Fenty/Jalalabad resident functions;
- TF Out Front / 2-17 Air Cavalry aircraft inventory and task allocation;
- TF Rock strength, AO, population and force-density figures;
- company, platoon and outpost dispositions;
- FOB Blessing functions and artillery support;
- COP Bella, Ranch House and Kahler garrisons;
- QRF, MEDEVAC, attack aviation and escort posture;
- indirect-fire, CAS, ISR, SIGINT and HUMINT support;
- historical radio nets, frequencies and callsigns;
- logistics, terrain, road, HLZ and weather constraints;
- enemy observation, warning, IED and complex-attack planning;
- COIN, infrastructure and population-effect lessons.

## 4. Source precedence

The 2010 CSI study is used as the principal narrative authority because it is the researched historical publication closest to the underlying records and interviews. The 2021 staff-ride products are used for:

- visual organization data;
- terrain orientation;
- position-level personnel layouts;
- operational graphics;
- teaching-derived synthesis.

When exact figures differ, both scopes are preserved and the difference is explained.

## 5. Important source-reported figures

### 5.1 173rd ABCT organic organization

```text
1-91 Cavalry: 305
1-503 Infantry: 665
2-503 Infantry: 665
4-319 Field Artillery: 307
173rd STB: 514
173rd BSB: 939
organic total: 3,395
```

### 5.2 TF Bayonet deployed context

```text
approximately 3,000 U.S. soldiers
five battalions
excludes TF Out Front
1-503 Infantry detached
```

### 5.3 TF Out Front / 2-17 Air Cavalry

```text
14 OH-58D
6 UH-60
4 CH-47
6 AH-64
3 HH-60 air ambulance
33 helicopters total
```

AH-64 source allocation:

```text
2 QRF alert
2 CH-47 escort
2 maintenance or battle-damage repair
```

### 5.4 TF Rock

```text
1,000 organic U.S.
400 additional U.S. advisors/support
2,500 Afghan security personnel
525,000 population
2,300 square miles
14 dispersed bases by 13 July 2008
```

### 5.5 Outposts

```text
COP Bella: approximately 24 U.S.
COP Ranch House: approximately 24 U.S. + 22 ANA + 15 ASG
COP Kahler: 49 U.S. + 24 ANA
```

## 6. Known anomalies and limits

- Walkbook cover states `13 AUG 2008`; internal content and all other evidence concern the battle of `13 July 2008`.
- Brigade organic strength and deployed task-force strength use different scopes.
- Position-level Wanat diagrams may reflect movement and overlap; they are not independently additive.
- Historical radio values are not DCS-runtime authority.
- Staff-ride graphics simplify some organizations for teaching.
- Aircraft serviceability and allocation are source snapshots, not invariant readiness ratios.
- No source establishes the same units or strengths for 2010-2011.

## 7. Repository treatment

The original PDF, DOCX and PPTX are not committed to the repository. Document 74 contains paraphrased and normalized factual extraction with explicit source qualification. Personal rosters are not reproduced except where a command role is operationally necessary; the detailed individual casualty sequence remains in the source package rather than the OMW force-posture reference.

## 8. Resulting project document

- [`OMW-HIST-WANAT-TF-BAYONET-TF-ROCK-FORCE-POSTURE`](../../74-wanat-tf-bayonet-tf-rock-force-posture-2007-2008.md)
