# Bagram Air Operations Runtime Baseline

Status: `AIRWING_BASELINE_PASS_PARKING_DIAGNOSTIC_PENDING`

This test family constructs the binding Bagram AIRWING/SQUADRON inventory without spontaneous tasking and now captures the complete Bagram parking table for the next reservation decision.

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
src/05-construct-bagram-squadrons.lua
src/11-validate-and-start-complete-node.lua
expected/bagram-airwing-squadron-baseline-acceptance.md
results/2026-07-30-bagram-airwing-baseline-fail-template-contract.md
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

## Accepted baseline

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

## Parking diagnostic increment

`src/02-dump-airbase-parking.lua` is read-only. It records for every Bagram parking node:

```text
TerminalID
TerminalID0
TerminalType
Free
TOAC
OccupiedBy
x/y/z
```

It also records totals by terminal type and the overall free/occupied-or-reserved count. The output is the evidence base for the later client/static blacklist and type-specific parking pools. This diagnostic does not yet change the AIRBASE blacklist or AIRWING parking policy.

Required log prefix:

```text
[OMW][AirOps.BGRAM.ParkingDump]
```

AUFTRAG execution, OPSTRANSPORT, CSAR execution, loss persistence and repair timing remain later isolated increments.
