# TM02N RED tree-fill acceptance

## Purpose

TM02N validates automatic distribution of one authoritative 100-person RED pool into six physical shelters arranged as a two-level tree.

```text
                         RED_HQ (100)

          RED_SHELTER_A (10)       RED_SHELTER_B (10)

      AA (10)       AB (10)       BA (10)       BB (10)
```

Every shelter has one fixed `targetStrength` of 10. That value is simultaneously its required minimum and permitted maximum. No shelter reserve is allowed.

## Required Mission Editor objects

Late Activation group:

```text
TPL_TEST_RED_PACKET_10_01
```

The template must contain exactly ten RED ground infantry units.

Zones:

```text
ZONE_TM02N_HQ
ZONE_TM02N_A
ZONE_TM02N_B
ZONE_TM02N_AA
ZONE_TM02N_AB
ZONE_TM02N_BA
ZONE_TM02N_BB
```

Use open, traversable ground. Each zone must fully contain a ten-unit infantry group. Place recognizable static landmarks beside, not inside, each route endpoint.

## Automatic packet plan

```text
001: HQ -> A -> AA
002: HQ -> B -> BA
003: HQ -> A -> AB
004: HQ -> B -> BB
005: HQ -> A
006: HQ -> B
```

Each packet has stable metadata, strength 10, one final destination, and a direct parent-child route. A and B are pass-through nodes for leaf packets; passing packets are not credited to their garrisons.

At most two packets may be physically active at once.

## F10 commands

```text
OMW Tests
└── TM02N RED Tree Fill
    ├── Validate network
    ├── Start automatic fill
    ├── Show all node stocks
    └── Show active packets
```

Only `Start automatic fill` changes the run from idle to active. Status commands are read-only.

## Expected initial inventory

```text
HQ: 100
A:   0 / 10
B:   0 / 10
AA:  0 / 10
AB:  0 / 10
BA:  0 / 10
BB:  0 / 10
in transit: 0
accounted: 100
```

## Expected final inventory

```text
HQ: 40
A:  10 / 10
B:  10 / 10
AA: 10 / 10
AB: 10 / 10
BA: 10 / 10
BB: 10 / 10
in transit: 0
losses: 0
accounted: 100
all shelters at target: true
```

## Acceptance criteria

PASS requires all of the following:

1. Configuration and all eight Mission Editor objects validate.
2. Exactly six packet identities are created.
3. Every packet strength is exactly 10.
4. No more than two packets are active simultaneously.
5. HQ stock is reduced only when a packet physically dispatches.
6. Every route uses direct parent-child edges only.
7. A and B may relay leaf packets without counting them as local garrison.
8. Each final arrival credits survivors exactly once.
9. No shelter ever exceeds target strength 10.
10. All six shelters finish at exactly 10.
11. HQ finishes at exactly 40.
12. No packet remains queued or moving.
13. `HQ + shelters + in transit + losses` remains exactly 100.
14. No packet survivor count increases.
15. No duplicate physical or logical packet exists.
16. No teleport, virtual representation, automatic unstuck, or hidden BLUE data is used.
17. No `[OMW][TM02N] level=ERROR` event exists.

## Required evidence

Preserve the log from startup through `red_network_completed`, including:

```text
red_network_validation
red_network_start_requested
red_packet_dispatched
red_packet_leg_started
red_packet_leg_arrived
red_packet_arrived
red_network_inventory
red_network_completed
```

Record the exact infantry type, zone radii, route geometry, observed simultaneous group count, and final F10 inventory report.
