---
document_id: OMW-TEST-SCENERY-DISCOVERY-01
status: HISTORICAL_TEST_FIXTURE
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-MOOSE-FIRST
authoritative_for:
  - original native-DCS scenery discovery test procedure
not_authoritative_for:
  - production settlement classification
  - production terrain metadata architecture
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by: []
source_branch: agent/towns-discovery
source_commit: PENDING_MERGE
validated_in_dcs: false
production_architecture: false
moose_first_review: SOURCE_REVIEWED_FOR_TOWNS_ONLY
native_dcs_exception_approved: false
---

# OMW TOWNS Scenery Discovery Test 01

## Status and governance

This is a one-time DCS map-data discovery test created before the project-wide MOOSE-first exception procedure was established.

```text
HISTORICAL_TEST_FIXTURE
NOT_PRODUCTION_ARCHITECTURE
NATIVE_DCS_EXCEPTION_NOT_APPROVED
```

The current reconciliation confirms that MOOSE `TOWNS` is the correct framework path for named terrain town references. It does **not** establish that MOOSE provides an equivalent abstraction for arbitrary scenery-density scans. The native scenery-search fixture therefore remains historical only and may not become production architecture without the full MOOSE-first gap review and explicit owner approval required by `OMW-GOV-MOOSE-FIRST`.

## Purpose

The test checks whether DCS exposes useful `SCENERY` objects around selected map positions. It answers the prerequisite question before building a larger settlement classifier:

> Can physical map scenery around a coordinate be measured reliably enough to distinguish empty, isolated, sparse and dense areas?

The density labels are provisional. They describe only the number of searchable DCS `SCENERY` objects and are not interpreted as city, village or inhabited terrain.

## Current implementation

```text
mission/tests/towns-scenery-discovery/dist/OMW_TOWNS_SCENERY_DISCOVERY_TEST.lua
```

The historical fixture uses the native DCS mission-scripting API. This describes the existing implementation; it is not an approved statement that MOOSE is unnecessary.

## Required MOOSE-first follow-up before production use

A future production proposal must at least check against the then-pinned MOOSE artifact and official examples:

- MOOSE `SCENERY` wrappers and lookup methods;
- applicable `SET_*` classes;
- zone and coordinate search mechanisms;
- schedulers and controlled batch execution;
- map-marker and message helpers;
- whether MOOSE already wraps the same native search call;
- whether a small native callback is still technically required.

The result must be added to the project MOOSE documentation and, if a fallback remains necessary, to an owner-approved exception record.

## Mission Editor setup

Create an Afghanistan test mission and add one `MISSION START` trigger:

1. `DO SCRIPT FILE` -> `OMW_TOWNS_SCENERY_DISCOVERY_TEST.lua`

No `MissionScripting.lua` modification, file access, `io`, `lfs` or `require` is used.

## Built-in reference points

The first prototype scans nine embedded `towns.lua` references:

```text
Kabul
Jalalabad
Bagram
Sultanpur
Chaparhar
Asadabad
Parun
Kamdesh
Nari
```

These points compare large cities, smaller settlements and less-developed map regions.

## Optional manual probe zones

Create circular Mission Editor trigger zones at desired positions:

```text
OMW_SCENERY_PROBE_01
OMW_SCENERY_PROBE_02
...
OMW_SCENERY_PROBE_20
```

The zone centre is scanned. The zone radius is recorded as context but does not change the configured scan radii.

Recommended first probes:

```text
OMW_SCENERY_PROBE_01  centre of a clearly visible unnamed settlement
OMW_SCENERY_PROBE_02  known empty control area
OMW_SCENERY_PROBE_03  dense part of Jalalabad
OMW_SCENERY_PROBE_04  visible building compound without orange settlement fill
```

## Runtime behaviour

The test runs once after mission start. It does not continuously inspect the map.

For every reference point and probe-zone centre it performs one `SCENERY` search out to 1,000 m and derives cumulative counts for:

```text
100 m
250 m
500 m
1,000 m
```

Points are processed at 0.25-second intervals to avoid a same-frame scan burst.

## Output

Each point produces one structured `dcs.log` line:

```text
[OMW-SCENERY-DISCOVERY] RESULT|id=...|label=...|source=...|class=...|counts=100m=... 250m=... 500m=... 1000m=...|nearest_m=...|types=...
```

After completion, the script creates one F10 marker per result containing:

- provisional density class;
- cumulative object counts;
- distance to the nearest scenery object;
- up to five frequent DCS scenery type names.

F10 menu:

```text
F10 Other
└── OMW Tests
    └── Scenery Discovery
        ├── Scan starten
        ├── Zusammenfassung
        ├── Ergebnismarker anzeigen
        └── Ergebnismarker entfernen
```

## Provisional classes

```text
SCENERY_NONE
SCENERY_ISOLATED
SCENERY_LOW
SCENERY_MEDIUM
SCENERY_HIGH
SCENERY_VERY_HIGH
```

The thresholds are configurable and must be calibrated against the visible Afghanistan map before any operational settlement meaning is assigned.

## Acceptance boundary

The historical fixture can be retained as an evidence collector. No convoy, infantry, settlement-classification or production metadata system may be built on it without a new MOOSE-first review, any required owner-approved exception, and reproducible DCS acceptance evidence.
