# TM02N RED top-down tree-fill acceptance

## Purpose

TM02N validates automatic distribution of one authoritative 100-person RED pool into six physical shelters arranged as a two-level tree.

```text
                         RED_HQ (100)

          RED_SHELTER_A (10)       RED_SHELTER_B (10)

      AA (10)       AB (10)       BA (10)       BB (10)
```

Every shelter has one fixed `targetStrength` of 10. That value is simultaneously its required minimum and permitted maximum. No shelter reserve is allowed.

Configuration version `TM02N-red-tree-fill-2` changes dispatch to a strict top-down fill. Level-two packets may not dispatch until both A and B have reached 10.

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

Level 1:

```text
001: HQ -> A
002: HQ -> B
```

Only after both level-one shelters are at 10:

```text
003: HQ -> A -> AA
004: HQ -> B -> BA
005: HQ -> A -> AB
006: HQ -> B -> BB
```

All packets originate at HQ. A and B are pass-through waypoints for leaf packets; transit does not remove personnel from their established garrisons. At most two packets may be physically active at once.

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

## Mandatory top-down transition

Before any packet with `targetDepth=2` dispatches, both events below must already have occurred:

```text
red_packet_arrived ... destinationNodeId=RED_SHELTER_A targetDepth=1 destinationGarrison=10
red_packet_arrived ... destinationNodeId=RED_SHELTER_B targetDepth=1 destinationGarrison=10
```

The controller must then emit:

```text
red_network_fill_level_advanced previousDepth=1 currentDispatchDepth=2
```

Only after that event may a packet for AA, AB, BA, or BB dispatch.

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
network complete: true
```

## Acceptance criteria

PASS requires all of the following:

1. Configuration and all eight Mission Editor objects validate.
2. Exactly six packet identities are created.
3. Every packet strength is exactly 10.
4. No more than two packets are active simultaneously.
5. HQ stock is reduced only when a packet physically dispatches.
6. A and B are both filled to 10 before any level-two packet dispatches.
7. `red_network_fill_level_advanced` is emitted exactly once for depth 1 to depth 2.
8. Every route uses direct parent-child edges only.
9. Leaf packets start at HQ and may pass A or B without changing those local garrisons.
10. Each final arrival credits survivors exactly once.
11. No shelter ever exceeds target strength 10.
12. All six shelters finish at exactly 10.
13. HQ finishes at exactly 40.
14. No packet remains queued or moving.
15. `HQ + shelters + in transit + losses` remains exactly 100.
16. No packet survivor count increases.
17. No duplicate physical or logical packet exists.
18. `red_network_completed` reports `networkComplete=true`.
19. No teleport, virtual representation, automatic unstuck, or hidden BLUE data is used.
20. No `[OMW][TM02N] level=ERROR` event exists.

## Required evidence

Preserve the log from startup through `red_network_completed`, including:

```text
red_network_validation
red_network_start_requested
red_packet_dispatched
red_packet_leg_started
red_packet_leg_arrived
red_packet_arrived
red_network_fill_level_advanced
red_network_inventory
red_network_completed
```

Record the exact infantry type, zone radii, route geometry, observed simultaneous group count, and final F10 inventory report.
