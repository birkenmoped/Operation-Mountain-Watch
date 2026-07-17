# TM02R RED loss replenishment acceptance

## Purpose

TM02R starts from a fully manned RED shelter tree, applies deterministic simulated losses, and restores every shelter to its fixed target strength of 10 with physical replacement groups whose strengths exactly match the remaining deficits.

```text
                         RED_HQ (40)

          RED_SHELTER_A (10)       RED_SHELTER_B (10)

      AA (10)       AB (10)       BA (10)       BB (10)
```

The authoritative initial total is 100 living personnel. Simulated casualties remain in `totalLosses`; they are not recreated. Replenishment transfers surviving personnel from the HQ pool to the shelters.

The first acceptance uses `originPolicy=HQ_TO_FINAL`. Every replacement group starts at HQ and follows the parent-child route to its final shelter. This prevents any intermediate shelter from being emptied. Direct parent-source relief is deferred to a later rotation stage.

## Required Mission Editor objects

Ten RED Late Activation infantry templates are required:

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

Each template must contain exactly the number of units encoded in its name. This validates support for every replacement strength from 1 through 10, even though the first loss profile physically dispatches strengths 1 through 6.

Zones are reused from TM02N:

```text
ZONE_TM02N_HQ
ZONE_TM02N_A
ZONE_TM02N_B
ZONE_TM02N_AA
ZONE_TM02N_AB
ZONE_TM02N_BA
ZONE_TM02N_BB
```

## F10 commands

```text
OMW Tests
└── TM02R Loss Replenishment
    ├── Validate network
    ├── Apply simulated losses
    ├── Start automatic replenishment
    ├── Show all node stocks
    └── Show replenishment packets
```

`Show all node stocks` and `Show replenishment packets` are read-only.

## Initial inventory

```text
HQ: 40
A:  10 / 10
B:  10 / 10
AA: 10 / 10
AB: 10 / 10
BA: 10 / 10
BB: 10 / 10
losses: 0
accounted: 100
```

## Simulated loss profile

Select `Apply simulated losses` once.

```text
A loses 1  -> 9 / 10
B loses 2  -> 8 / 10
AA loses 3 -> 7 / 10
AB loses 4 -> 6 / 10
BA loses 5 -> 5 / 10
BB loses 6 -> 4 / 10
```

Expected state after the profile:

```text
HQ: 40
shelters: 39
recorded losses: 21
in transit: 0
accounted: 40 + 39 + 21 = 100
```

## Strict top-down replenishment

Select `Start automatic replenishment` once.

Depth 1 must complete first:

```text
Packet 001: strength 1, HQ -> A
Packet 002: strength 2, HQ -> B
```

No leaf packet may dispatch until A and B both report 10 / 10 and the controller emits:

```text
red_replenishment_level_advanced previousDepth=1 currentDispatchDepth=2
```

Depth 2 then dispatches:

```text
Packet 003: strength 3, HQ -> A -> AA
Packet 004: strength 4, HQ -> A -> AB
Packet 005: strength 5, HQ -> B -> BA
Packet 006: strength 6, HQ -> B -> BB
```

At most two replacement packets may be active simultaneously.

## Expected final inventory

```text
HQ: 19
A:  10 / 10
B:  10 / 10
AA: 10 / 10
AB: 10 / 10
BA: 10 / 10
BB: 10 / 10
in transit: 0
remaining deficit: 0
recorded losses: 21
accounted: 19 + 60 + 21 = 100
accounting valid: true
all shelters at target: true
```

## Transit-loss behavior

If a replacement packet loses personnel while moving:

1. its survivor count may only decrease;
2. the additional losses are added to `totalLosses`;
3. only survivors are credited on arrival;
4. the remaining shelter deficit creates a new exact-strength replacement packet;
5. replenishment continues until every shelter is at 10 or HQ personnel are insufficient;
6. no shelter may exceed 10.

## Acceptance criteria

PASS requires all of the following:

1. Seven zones and all ten strength templates validate.
2. Initial accounting is exactly 100.
3. The simulated profile records exactly 21 losses without changing HQ stock.
4. Post-loss shelter strengths are A9, B8, AA7, AB6, BA5, BB4.
5. Replacement packets use exact strengths 1, 2, 3, 4, 5, and 6.
6. Every replacement group spawns from the matching template.
7. A and B reach 10 before any leaf replacement packet dispatches.
8. All routes begin at HQ and use direct parent-child edges.
9. Transit through A or B does not alter their garrison count.
10. No more than two packets are active simultaneously.
11. Arrival credits survivors exactly once.
12. No shelter exceeds 10.
13. Every shelter finishes at 10.
14. HQ finishes at 19 when there are no transit losses.
15. Recorded losses remain 21 when there are no transit losses.
16. `HQ + shelters + in transit + losses` remains exactly 100.
17. No packet remains queued or moving.
18. `red_replenishment_completed` reports `networkComplete=true`.
19. No teleport, virtualization, automatic unstuck, recruitment, or hidden BLUE data is used.
20. No `[OMW][TM02R] level=ERROR` event exists.

## Required log sequence

```text
red_replenishment_validation
startup
red_shelter_losses_applied
red_loss_profile_applied
red_replenishment_start_requested
red_replenishment_packet_queued
red_replenishment_packet_dispatched
red_replenishment_packet_arrived
red_replenishment_level_advanced
red_replenishment_inventory
red_replenishment_completed
```
