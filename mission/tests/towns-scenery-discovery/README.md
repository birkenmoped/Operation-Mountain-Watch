# OMW TOWNS Scenery Discovery Test 01

This is a one-time DCS map-data discovery test. It does not test convoys, infantry movement or live unit behaviour.

## Purpose

The test checks whether DCS exposes useful `SCENERY` objects around selected map positions. It is intended to answer the prerequisite question before building a larger settlement classifier:

> Can physical map scenery around a coordinate be measured reliably enough to distinguish empty, isolated, sparse and dense areas?

The density labels are provisional. They describe only the number of searchable DCS `SCENERY` objects and are not yet interpreted as city, village or inhabited terrain.

## Script

```text
mission/tests/towns-scenery-discovery/dist/OMW_TOWNS_SCENERY_DISCOVERY_TEST.lua
```

The script uses the native DCS mission-scripting API. MOOSE is not required.

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

These points provide a first comparison across large cities, smaller settlements and less-developed map regions.

## Optional manual probe zones

To test locations that have no `towns.lua` entry, create circular Mission Editor trigger zones at the desired positions:

```text
OMW_SCENERY_PROBE_01
OMW_SCENERY_PROBE_02
...
OMW_SCENERY_PROBE_20
```

The zone centre is scanned. The zone radius is recorded as context but does not change the four configured scan radii.

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

Points are processed one after another at 0.25-second intervals to avoid a same-frame scan burst.

## Output

Each point produces one structured `dcs.log` line:

```text
[OMW-SCENERY-DISCOVERY] RESULT|id=...|label=...|source=...|class=...|counts=100m=... 250m=... 500m=... 1000m=...|nearest_m=...|types=...
```

After completion, the script creates one F10 marker per result. The marker contains:

- provisional density class;
- cumulative object counts;
- distance to the nearest found scenery object;
- up to five most frequent DCS scenery type names.

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

The first version classifies only by the number of unique scenery objects within 500 m:

```text
SCENERY_NONE
SCENERY_ISOLATED
SCENERY_LOW
SCENERY_MEDIUM
SCENERY_HIGH
SCENERY_VERY_HIGH
```

The thresholds are deliberately configurable and must be calibrated against the visible Afghanistan map before any operational settlement meaning is assigned.

## First acceptance question

The first DCS run is useful when it shows whether:

1. dense visible cities return substantially higher counts than empty control areas;
2. unnamed visible settlements are detectable through manual probe zones;
3. label-only or unfinished areas return low or zero counts;
4. the reported scenery type names are stable enough to separate buildings from irrelevant scenery.

No convoy or infantry test should be built on top of this until those four observations are recorded.
