# TM02V RED proxy movement acceptance

## Purpose

TM02V validates one virtual six-person RED movement whose current world position is carried by one physical proxy unit. The full group is not present while packed. The proxy follows the real DCS route and provides the authoritative coordinate required for later BLUE-distance and line-of-sight checks.

The representation cycle under test is:

```text
NONE
-> PROXY
-> PHYSICAL
-> PROXY
-> PHYSICAL_GARRISON
```

The logical personnel packet remains authoritative throughout. The one-unit proxy is a position carrier only and is never counted as personnel.

## Scenario

```text
RED_HQ (40)
  |
  v
RED_SHELTER_A (10 / 10)
  |
  v
RED_SHELTER_AA (4 / 10)
```

The packet strength is six. The initial authoritative total remains 100:

```text
HQ:                 40
all shelters:       54
recorded losses:     6
in transit:           0
accounted:          100
```

After dispatch:

```text
HQ:                 34
all shelters:       54
virtual in transit:  6
recorded losses:     6
accounted:          100
```

Expected final state without transit losses:

```text
HQ:                 34
all shelters:       60
AA:              10 / 10
in transit:           0
recorded losses:     6
accounted:          100
```

## Required Mission Editor objects

Reuse the ten RED Late Activation strength templates from TM02R:

```text
TPL_TEST_RED_PACKET_01_01
TPL_TEST_RED_PACKET_02_01
TPL_TEST_RED_PACKET_03_01
TPL_TEST_RED_PACKET_04_01
TPL_TEST_RED_PACKET_05_01
TPL_TEST_RED_PACKET_06_01
TPL_TEST_RED_PACKET_07_01
TPL_TEST_RED_PACKET_08_01
TPL_TEST_RED_PACKET_09_01
TPL_TEST_RED_PACKET_10_01
```

Add one dedicated RED Late Activation proxy group:

```text
TPL_TEST_RED_PROXY_01
```

The proxy template must contain exactly one ground infantry unit. It is a technical position carrier and must not be counted in any inventory.

Reuse all seven TM02N zones:

```text
ZONE_TM02N_HQ
ZONE_TM02N_A
ZONE_TM02N_B
ZONE_TM02N_AA
ZONE_TM02N_AB
ZONE_TM02N_BA
ZONE_TM02N_BB
```

The active route is:

```text
ZONE_TM02N_HQ
-> ZONE_TM02N_A
-> ZONE_TM02N_AA
```

Use open traversable ground. The HQ, A, and AA zones must fully contain the corresponding one-unit proxy or six-unit physical group.

## F10 commands

```text
OMW Tests
└── TM02V Proxy Movement
    ├── Validate test
    ├── Start proxy movement
    ├── Show movement status
    ├── Force unpack
    ├── Force pack
    └── Toggle proxy marker
```

`Show movement status` and `Toggle proxy marker` do not alter personnel accounting or movement ownership.

## Start behavior

Select `Start proxy movement` once.

Expected effects:

1. six logical personnel are removed from HQ;
2. one physical proxy unit spawns in `ZONE_TM02N_HQ`;
3. the packet enters `movementState=EN_ROUTE`;
4. the packet enters `representationState=PROXY`;
5. the proxy receives the route HQ -> A;
6. the automatic monitor starts;
7. the debug marker follows the current proxy coordinate.

The proxy is not an additional soldier. The in-transit count remains six, not seven.

## Debug marker

When enabled, one map marker follows the active representation and reports:

```text
packet identity
representation state
movement state
logical survivor strength
current route leg
straight-line distance to the next node
```

The marker is test instrumentation. It must not be used as player-facing intelligence in the final mission.

## Manual unpack test

While the packet is represented by the moving proxy, select `Force unpack`.

Expected atomic transition:

1. read the proxy coordinate;
2. spawn the six-unit physical template at that coordinate;
3. validate the full group and assign the remaining current leg;
4. only after successful validation, destroy the proxy;
5. set `representationState=PHYSICAL`.

The full group must appear where the proxy was located. The personnel count remains six.

## Manual pack test

While the full group is physically moving, select `Force pack`.

Expected atomic transition:

1. count physical survivors;
2. record any decrease as transit losses;
3. read the physical group coordinate;
4. spawn and route one proxy at that coordinate;
5. only after successful validation, destroy the full group;
6. set `representationState=PROXY`.

If the physical group has fewer than six survivors, the packet keeps the reduced survivor count. A later unpack must use the matching 1..10 template and must not resurrect losses.

## Relay behavior

At A, the active representation remains unchanged. The controller only advances the packet from leg 1 to leg 2 and assigns route A -> AA.

No personnel are credited to A, and A remains at 10 / 10.

## Automatic destination materialization

When a packed proxy reaches AA:

1. capture the proxy coordinate;
2. spawn the physical group matching the current survivor count at that coordinate;
3. validate it;
4. destroy the proxy;
5. set `representationState=PHYSICAL_GARRISON`;
6. credit survivors to AA exactly once;
7. set `movementState=ARRIVED`;
8. leave the physical group visible in the destination zone.

When an already unpacked physical group reaches AA, no second spawn occurs. That group becomes the visible destination garrison representation and is credited exactly once.

## Acceptance sequence

Recommended operator sequence:

1. `Validate test`;
2. `Start proxy movement`;
3. observe the moving marker and one-unit proxy;
4. use `Force unpack` during leg HQ -> A;
5. verify six visible units appear at the former proxy position;
6. use `Force pack`;
7. verify the six-unit group disappears and one proxy remains;
8. allow the proxy to cross A;
9. optionally repeat unpack/pack on leg A -> AA;
10. allow the proxy to reach AA;
11. verify automatic visible six-unit materialization inside AA;
12. use `Show movement status` and preserve the log.

## PASS criteria

PASS requires all of the following:

1. Ten strength templates, one proxy template, and seven zones validate.
2. Initial accounting is exactly 100.
3. Dispatch reduces HQ from 40 to 34 and places six logical personnel in transit.
4. Only one proxy unit physically represents the packed packet.
5. The proxy position changes along the real DCS route.
6. The debug marker follows the active representation.
7. Manual unpack occurs at the proxy coordinate.
8. Manual unpack creates exactly six physical units before any losses.
9. Manual pack preserves the current survivor count.
10. Manual pack returns to exactly one proxy representation.
11. No stable state contains both a living proxy and a living full group.
12. Crossing A advances the leg without changing A's garrison.
13. Reaching AA automatically materializes the matching physical group.
14. The final physical group remains visible in the AA target zone.
15. Arrival credit occurs exactly once.
16. AA finishes at 10 / 10 without transit losses.
17. HQ finishes at 34 without transit losses.
18. `HQ + shelters + in transit + losses` remains exactly 100.
19. The proxy is never counted as personnel.
20. No survivor count increase is accepted.
21. No `[OMW][TM02V] level=ERROR` event exists.

## Required log events

Preserve the log from startup through final arrival, including:

```text
red_proxy_validation
startup
red_proxy_movement_started
red_proxy_monitor_started
red_proxy_leg_started
red_proxy_unpacked
red_proxy_packed
red_proxy_leg_arrived
red_proxy_arrived
red_proxy_movement_status
```

Record the proxy infantry type, strength-template infantry type, zone radii, observed marker movement, unpack coordinate, pack coordinate, final AA group count, and final inventory.
