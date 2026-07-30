# Bagram Air Operations Runtime Baseline

Status: `HH60G_CONTROLLED_SPAWN_PASS_FIXED_WING_MOVEMENT_ACTIVE`

This test family constructs the binding Bagram AIRWING/SQUADRON inventory, validates the complete parking contract, and advances runtime acceptance through controlled MOOSE recruitment and integration waves.

## Binding logical inventory

```text
13 F-15E   / 335th EFS
13 F-16C   / 121st EFS
20 C-130   / 774th EAS
 6 HH-60G  / 83rd ERQS
10 UH-60   / A/1-169 AVN, TF Phoenix
13 CH-47   / B/7-158 AVN Bagram pool share
```

Active implementation exclusions:

```text
OH-58D
MC-12W
EC-130H
EA-6B
separate Army MEDEVAC inventory
```

## Runtime source files

```text
src/01-bagram-bootstrap.lua
src/02-dump-airbase-parking.lua
src/03-validate-bagram-parking-contract.lua
src/05-construct-bagram-squadrons.lua
src/11-validate-and-start-complete-node.lua
src/20-test-hh60g-controlled-spawn-cleanup.lua
src/21-test-fixed-wing-bagram-jalalabad.lua
```

## Acceptance and results

```text
expected/bagram-airwing-squadron-baseline-acceptance.md
expected/bagram-controlled-spawn-despawn-acceptance.md
expected/bagram-hh60g-controlled-spawn-cleanup-acceptance.md
expected/bagram-jalalabad-fixed-wing-movement-acceptance.md

results/2026-07-30-bagram-airwing-baseline-fail-template-contract.md
results/2026-07-30-bagram-parking-contract-pass.md
results/2026-07-30-bagram-hh60g-controlled-spawn-cleanup-pass.md
```

## Inventory semantics

The four one-ship template families use one MOOSE asset group per logical airframe:

```text
C-130: 20 groups x 1 aircraft
HH-60G: 6 groups x 1 aircraft
UH-60: 10 groups x 1 aircraft
CH-47: 13 groups x 1 aircraft
```

The fighter templates are two-ship authoring seeds:

```text
F-15E: 6 groups x 2 aircraft = 12 MOOSE-controlled aircraft + 1 logical reserve
F-16C: 6 groups x 2 aircraft = 12 MOOSE-controlled aircraft + 1 logical reserve
```

No fourteenth fighter airframe may be created. Clients, Late Activation templates and statics represent the logical inventories and are not added to them.

## Accepted AIRWING baseline

The corrected DCS run proved:

- warehouse-anchor discovery;
- one `AW_US_BAGRAM` instance;
- exactly six SQUADRON objects;
- exact group-count and logical-reserve accounting;
- all six actual Mission Editor template names;
- AIRWING start with 75 logical airframes;
- no spontaneous tasking.

Accepted markers:

```text
PASS: AW_US_BAGRAM started with exactly 6 squadrons and 75 logical airframes.
ACCOUNTING: MOOSE-managed=73 fighterLogicalReserve=2 total=75.
```

## Accepted parking contract

```text
187 parking nodes
179 initially free
8 client-reserved
30 effective blacklist entries
```

The eight binding client reservations are:

```text
128 CLIENT_US_BGRM_F15E_01
 42 CLIENT_US_BGRM_F15E_02
119 CLIENT_US_BGRM_F16_01
 12 CLIENT_US_BGRM_F16_02
 21 CLIENT_US_BGRM_C130_01
111 CLIENT_US_BGRM_C130_02
 88 CLIENT_US_BGRM_CH47F_01
 85 CLIENT_US_BGRM_CH47F_02
```

Accepted effective blacklist:

```text
4,11,12,16,21,25,26,27,35,42,44,64,71,72,81,82,85,88,106,111,119,120,121,125,126,128,141,142,149,185
```

## Accepted HH-60G increment

The isolated MOOSE-native HH-60G test passed:

```text
requiredPayloadBound=true
one OPSGROUP
one aircraft
alive spawn
mission executing
cancel successful
opsGroups=0
aliveGroups=0
TEST_PASS spawnedExactlyOne=true cleanupComplete=true
```

The test switch is now disabled:

```lua
HH60GControlledSpawn = false
```

The source harness remains in the bundle for reproducibility and logs `SKIP` while disabled.

## Active integration increment

The active test is:

```text
Bagram -> Jalalabad Fixed-Wing Movement
```

First wave:

```text
2 x F-15E two-ship groups
2 x F-16C two-ship groups
4 x C-130 single-ship groups
= 8 groups / 12 aircraft
```

The test validates:

- exact recruitment from three Bagram squadrons;
- Bagram stock withdrawal;
- parallel parking and startup exposure;
- 30-second dispatch spacing;
- taxi and takeoff;
- flight to Jalalabad using native MOOSE `FLIGHTGROUP` methods;
- landing and transient parking at Jalalabad;
- return of all assets to the original Bagram legion;
- full stock restoration;
- coexistence with the existing Jalalabad AIRWING and `OMW_BLUE_COMMANDER`;
- no second COMMANDER creation.

Active switch:

```lua
FixedWingBagramToJalalabad = true
```

BuilderVersion:

```text
BGRAM-JBAD-FIXED-WING-WAVE-1
```

The detailed contract is `expected/bagram-jalalabad-fixed-wing-movement-acceptance.md`.

## Later increments

Not yet accepted:

- combat CAS execution;
- OPSTRANSPORT;
- CSAR execution;
- UH-60 and CH-47 operational movement;
- loss persistence;
- maintenance, repair and replacement timing;
- permanent cohort relocation between airfields.
