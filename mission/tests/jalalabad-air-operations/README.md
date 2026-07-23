# Jalalabad Air Operations

## Status: CH-47 correction required

The previously declared complete Jalalabad manifest was incomplete. It contained:

```text
24 OH-58D
 8 AH-64D
 6 UH-60-family
```

Contemporary Task Force Shooter reporting and 2011 satellite imagery confirm that Jalalabad / FOB Fenty also hosted a substantial CH-47 heavy-lift element. The node must therefore not be declared complete without CH-47.

Current evidence-based working manifest:

```text
24 OH-58D
 8 AH-64D
 6 UH-60-family
 8 CH-47 heavy-lift aircraft
```

The eight-aircraft CH-47 working count is based on the visible concentration in the 2011 satellite captures and the documented nine-aircraft RC-East heavy-lift company scale. Exact sub-unit attribution is intentionally left generic until the rotation boundary is fully reconciled.

## Valid confirmed results

The following DCS results remain valid:

- Jalalabad detected as MOOSE Airbase ID 19,
- 50 parking entries readable,
- `WH_AIR_US_JALALABAD` recognized as BLUE/USA static warehouse anchor,
- native DCS warehouse and MOOSE storage available,
- `AW_US_JALALABAD` construction and explicit airbase linking,
- OH-58D type `OH58D`, two-ship template, 24 aircraft -> 12 asset groups,
- AH-64D type `AH-64D_BLK_II`, two-ship template, 8 aircraft -> 4 asset groups.

The only withdrawn claim is that the 24/8/6 manifest represented the complete local ORBAT.

## Technical safety state

The bootstrap now records:

```text
CH47 = 8
CorrectionPending.CH47 = true
```

The final activation gate is hard-blocked while this flag is present. It must report `INCOMPLETE` and must not start the AIRWING or link the COMMANDER.

## Superseded Mission Editor instruction

Do not execute the previous file as a completion work order:

```text
expected/jalalabad-complete-node-acceptance.md
```

That file is retained only as a superseded record and is marked accordingly. A revised single-pass Jalalabad work package must add the CH-47 squadron, mission templates, player slots, pooled statics and heavy-lift parking/zone plan before the final DCS acceptance run.

## Evidence record

```text
results/2026-07-23-jalalabad-ch47-orbat-correction.md
```

## Repository workflow

The branch remains:

```text
feature/jalalabad-air-operations-diagnostics
```

Do not rebuild and re-embed the current bundle for a final acceptance run. The next usable build will be the revised CH-47-complete package.
