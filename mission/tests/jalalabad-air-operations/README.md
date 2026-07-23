# Jalalabad Air Operations

## Status

The local Jalalabad / FOB Fenty Air Operations node is validated and operational.

Authoritative final-status document:

```text
docs/25-jalalabad-final-validation-and-operational-baseline.md
```

Detailed final DCS result:

```text
results/2026-07-24-jalalabad-complete-node-pass.md
```

Validated final result:

```text
[OMW][AirOps.JBAD.COMPLETE] RESULT: COMPLETE. Jalalabad AirOps node OPERATIONAL; AIRWING started; COMMANDER linked; missionsQueued=0; spontaneousSpawns=0.
```

## Representation model

The local ORBAT is not represented 1:1 by visible statics or DCS parking positions.

```text
logical inventory = CampaignState / MOOSE reserve
visible statics    = limited visual ramp representation
active players/AI = aircraft currently in use or reserved
virtual reserve    = hangars, maintenance and unmodeled parking areas
```

A final loss permanently reduces the logical inventory. Another surviving but previously invisible inventory aircraft may perform a later sortie. That is not an external replacement.

A destroyed static is not immediately regenerated during the same running mission. A later controlled ramp update or a new mission start may place another surviving reserve airframe on a free static position.

## 2011 ramp snapshot

Minimum visible count from the evaluated snapshot:

```text
13 OH-58
 7 AH-64
 7 UH-60
 7 CH-47
 1 Mi-8
 1 UH-1
```

Mi-8 and UH-1 remain recorded as external or transient aircraft and are not currently charged to the US Task Force Shooter inventory.

## Validated logical inventory

```text
24 OH-58D
 8 AH-64D
 8 UH-60-family
 8 CH-47 heavy-lift aircraft
```

## Validated Mission Editor baseline

```text
6 required Client groups
5 Late-Activation AI template groups
20 visible aircraft statics
11 functional zones
1 warehouse anchor
0 optional UH-60L Client groups in the mod-free baseline
```

Required Client positions:

```text
2 OH-58D
2 AH-64D
2 CH-47
```

Optional mod variant:

```text
0 or 2 UH-60L Client groups
```

Validated static caps:

```text
7 OH-58D
4 AH-64D
4 UH-60A
5 CH-47
```

## Parking model

Core runtime demand:

```text
6 Client positions
4 dynamic AI reserve positions
= 10 runtime positions

+ 2 optional UH-60L positions
= 12 positions with optional mod variant
```

The seven aircraft contained in the five Late-Activation templates are authoring seeds and do not permanently consume seven runtime parking positions.

Four CH-47 statics intentionally occupy real DCS parking nodes. These nodes are removed from the MOOSE spawn pool:

```text
TerminalIDs 23,35,37,49
```

The parking validator confirmed:

```text
4 intentional reservations
7 remaining visual CH-47 positions
0 undeclared static parking overlaps
```

Client positions are protected through AIRWING Safe Parking.

## Technical structure

```text
AW_US_JALALABAD
├── SQ_US_JBAD_OH58D_6_6_CAV
├── SQ_US_JBAD_AH64D_B_1_10_AVN
├── SQ_US_JBAD_UH60_UTILITY_MEDEVAC
└── SQ_US_JBAD_CH47_HEAVYLIFT
```

Templates:

```text
TPL_AIR_US_JBAD_OH58D_RECON_2SHIP
TPL_AIR_US_JBAD_AH64D_CAS_2SHIP
TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP
TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP
TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP
```

Validated DCS types:

```text
OH58D
AH-64D_BLK_II
UH-60A
CH-47Fbl1
```

Validated SQUADRON representation:

```text
OH-58D: 24 aircraft / 12 two-ship asset groups / RECON
AH-64D: 8 aircraft / 4 two-ship asset groups / CAS
UH-60:  8 aircraft / 8 single-ship asset groups / TRANSPORT, LAND, GROUNDESCORT
CH-47:  8 aircraft / 8 single-ship asset groups / TROOPTRANSPORT, CARGOTRANSPORT, LAND
```

MEDEVAC remains modeled as:

```text
1 independent lead single-ship group
+
1 independent cover single-ship group
=
1 logical two-aircraft MEDEVAC package
```

The later runtime coordinator remains a separate follow-on capability.

## Validated infrastructure

- Jalalabad detected as MOOSE Airbase ID 19;
- 50 readable parking entries;
- warehouse anchor `WH_AIR_US_JALALABAD`;
- native DCS warehouse and MOOSE storage;
- AIRWING construction and explicit Jalalabad association;
- parking blacklist and Safe Parking;
- all four SQUADRONs;
- AIRWING start;
- COMMANDER linkage and start;
- zero queued missions;
- no spontaneous Jalalabad AI spawn during the final observation period.

## Follow-on scope

The basic node assembly is closed. Separate later validation is still required for:

- tactical AUFTRAG generation;
- OPSTRANSPORT logistics;
- runtime load/unload behavior;
- coordinated 1+1 MEDEVAC execution;
- persistent loss accounting;
- persistent ramp/static redistribution.

## Repository workflow

The binding workflow is documented in:

```text
docs/22-test-mission-build-transfer-and-validation-workflow.md
```

Core commands:

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch

git branch --show-current
git status --short
git pull --ff-only
git rev-parse HEAD

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File ".\tools\build-jalalabad-air-operations-bundle.ps1"
```

After every rebuild, `OMW_AirOps_Jalalabad.lua` must be reselected in Mission Editor `DO SCRIPT FILE` and the `.miz` saved before the DCS test.