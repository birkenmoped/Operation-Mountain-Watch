# 25 – Jalalabad final validation and operational baseline

## Status

Jalalabad / FOB Fenty is accepted as the validated local Air Operations baseline.

This document supersedes the pending/open status sections in older Jalalabad documents. The historical decision and test chronology in `docs/21-jalalabad-air-operations-manifest.md` remains valid, but its former sections describing the complete-node DCS test as outstanding are no longer current.

Authoritative final result:

```text
[OMW][AirOps.JBAD.COMPLETE] RESULT: COMPLETE. Jalalabad AirOps node OPERATIONAL; AIRWING started; COMMANDER linked; missionsQueued=0; spontaneousSpawns=0.
```

Detailed test evidence:

```text
mission/tests/jalalabad-air-operations/results/2026-07-24-jalalabad-complete-node-pass.md
```

## Validated repository and bundle baseline

```text
Source branch:   feature/jalalabad-air-operations-diagnostics
Source commit:   6cee9a5db7abf1934d0f86bf9fdf91a0446374d0
BuilderVersion:  JBAD-AIR-OPS-COMPLETE-5
Embedded bundle: l10n/DEFAULT/OMW_AirOps_Jalalabad.lua
```

The final validation mission embedded exactly this bundle.

## Validated logical inventory

```text
24 OH-58D
 8 AH-64D
 8 UH-60-family
 8 CH-47 heavy-lift aircraft
```

Logical inventory, active aircraft, visible statics and virtual reserve remain separate layers. Permanent losses reduce the logical inventory; a surviving virtual-reserve airframe may perform a later sortie but is not an external replacement.

## Validated Mission Editor baseline

```text
6 required Client groups
5 Late-Activation AI template groups
20 visible aircraft statics
11 functional zones
1 warehouse anchor
0 optional UH-60L Client groups in the mod-free baseline
```

Validated DCS type names:

```text
OH-58D: OH58D
AH-64D: AH-64D_BLK_II
UH-60A: UH-60A
CH-47F: CH-47Fbl1
```

## Validated MOOSE structure

```text
AW_US_JALALABAD
├── SQ_US_JBAD_OH58D_6_6_CAV
├── SQ_US_JBAD_AH64D_B_1_10_AVN
├── SQ_US_JBAD_UH60_UTILITY_MEDEVAC
└── SQ_US_JBAD_CH47_HEAVYLIFT
```

Validated asset representation:

```text
OH-58D: 24 aircraft / 12 two-ship asset groups / RECON
AH-64D: 8 aircraft / 4 two-ship asset groups / CAS
UH-60:  8 aircraft / 8 single-ship asset groups / TRANSPORT, LAND, GROUNDESCORT
CH-47:  8 aircraft / 8 single-ship asset groups / TROOPTRANSPORT, CARGOTRANSPORT, LAND
```

MEDEVAC remains modeled as two independently taskable single-ship DCS groups coordinated as one logical package:

```text
1 lead + 1 cover
no single-ship fallback
```

The later runtime coordinator that atomically reserves, starts, tasks and releases both aircraft remains a separate implementation and validation item.

## Validated parking model

Core runtime demand:

```text
6 reserved Client positions
4 dynamic AI reserve positions
= 10 runtime positions

+ 2 optional UH-60L Client positions
= 12 positions with the optional mod variant
```

Late-Activation templates are authoring seeds and are not counted as permanently occupied runtime parking positions.

### Intentional CH-47 reservations

The following visible CH-47 statics intentionally occupy real DCS parking nodes:

```text
STATIC_AIR_US_JBAD_CH47_01 -> TerminalID 49
STATIC_AIR_US_JBAD_CH47_02 -> TerminalID 37
STATIC_AIR_US_JBAD_CH47_03 -> TerminalID 23
STATIC_AIR_US_JBAD_CH47_04 -> TerminalID 35
```

The corresponding MOOSE parking blacklist is:

```text
23,35,37,49
```

`AIRWING:SetSafeParkingOn()` protects Client positions. The parking validator confirmed all four intended reservations, zero undeclared overlaps and seven remaining visual CH-47 positions after five statics and two Client slots.

## Runtime acceptance

The final debrief ran for 81.562 seconds. The AIRWING and COMMANDER were active for approximately 66 seconds after activation.

No Jalalabad AI aircraft spawned, started engines, took off, landed, crashed or was lost without an assigned mission. The only engine-start event belonged to an unrelated existing OH-58D at Bagram.

No relevant OMW Lua or timer error occurred.

## Scope of this acceptance

This PASS closes the local Jalalabad Air Operations node assembly and startup validation.

It confirms:

- Mission Editor names, counts and types;
- warehouse and airbase association;
- SQUADRON inventories and asset-group sizes;
- payload registration;
- parking blacklist and Safe Parking setup;
- AIRWING start;
- COMMANDER linkage and start;
- absence of spontaneous Jalalabad sorties.

It does not yet validate:

- tactical AUFTRAG generation and completion;
- OPSTRANSPORT cargo and troop flows;
- dynamic load/unload-zone behavior;
- the runtime 1+1 MEDEVAC coordinator;
- persistent loss accounting across mission restarts;
- persistent visual ramp/static redistribution;
- combat damage, recovery and replacement-state integration.

These are follow-on campaign capabilities and must not reopen the already accepted basic Jalalabad node assembly unless a regression is demonstrated.

## Repository workflow remains binding

The project-wide build and transfer process remains documented in:

```text
docs/22-test-mission-build-transfer-and-validation-workflow.md
```

The generated bundle must always be rebuilt from repository sources, reselected in Mission Editor `DO SCRIPT FILE`, and the `.miz` saved before a DCS validation run.