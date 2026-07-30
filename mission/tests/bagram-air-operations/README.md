# Bagram Air Operations Runtime Baseline

Status: `AIRWING_AND_PARKING_CONTRACT_PASS_CONTROLLED_SPAWN_PENDING`

This test family constructs the binding Bagram AIRWING/SQUADRON inventory without spontaneous tasking, validates the complete parking contract, and now proceeds to isolated controlled spawn/despawn tests.

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

## Files

```text
src/01-bagram-bootstrap.lua
src/02-dump-airbase-parking.lua
src/03-validate-bagram-parking-contract.lua
src/05-construct-bagram-squadrons.lua
src/11-validate-and-start-complete-node.lua
expected/bagram-airwing-squadron-baseline-acceptance.md
expected/bagram-controlled-spawn-despawn-acceptance.md
results/2026-07-30-bagram-airwing-baseline-fail-template-contract.md
results/2026-07-30-bagram-parking-contract-pass.md
```

## Inventory semantics

The four one-ship template families use one MOOSE asset group per logical airframe:

```text
C-130: 20 groups x 1 aircraft
HH-60G: 6 groups x 1 aircraft
UH-60: 10 groups x 1 aircraft
CH-47: 13 groups x 1 aircraft
```

The fighter templates are two-ship authoring seeds. They therefore use:

```text
F-15E: 6 groups x 2 aircraft = 12 MOOSE-controlled aircraft + 1 logical reserve
F-16C: 6 groups x 2 aircraft = 12 MOOSE-controlled aircraft + 1 logical reserve
```

No fourteenth fighter airframe may be created.

Clients, Late Activation templates and statics are representations of these logical inventories and are not added to them.

## Accepted AIRWING baseline

The corrected DCS run proved:

- warehouse-anchor discovery;
- one `AW_US_BAGRAM` instance;
- exactly six SQUADRON objects;
- exact group-count and logical-reserve accounting;
- all six actual Mission Editor template names;
- AIRWING start with 75 logical airframes;
- no spontaneous tasking.

Accepted completion markers:

```text
PASS: AW_US_BAGRAM started with exactly 6 squadrons and 75 logical airframes.
ACCOUNTING: MOOSE-managed=73 fighterLogicalReserve=2 total=75.
```

## Accepted parking contract

The validated Bagram parking table contains:

```text
187 parking nodes
179 initially free
8 client-reserved
30 effective blacklist entries after static-aircraft overlap detection
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

The accepted effective blacklist is:

```text
4,11,12,16,21,25,26,27,35,42,44,64,71,72,81,82,85,88,106,111,119,120,121,125,126,128,141,142,149,185
```

Accepted parking markers:

```text
[OMW][AirOps.BGRAM.ParkingContract] RESULT: PASS clients=8 blacklistCount=30 ... AIRWING_START_BLOCKED=false
[OMW][AirOps.BGRAM.Finalize] PARKING: contract validated blacklistCount=30 ...
```

## Next isolated increment

The next boundary is not operational tasking. Each active aircraft class is tested independently for one controlled MOOSE recruitment, safe spawn on a non-blacklisted position, and cleanup/inventory reconciliation.

Test order:

```text
HH-60G
UH-60 Utility
CH-47
C-130
F-15E
F-16C
```

The detailed acceptance contract is `expected/bagram-controlled-spawn-despawn-acceptance.md`.

AUFTRAG execution, OPSTRANSPORT, CSAR execution, loss persistence and repair timing remain later isolated increments.
