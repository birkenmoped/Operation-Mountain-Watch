# TM02A physical RED relay acceptance

## Scope

This contract accepts only one manually requested, fully physical transfer of six
RED fighters between two directly adjacent RED nodes.

It does not accept an autonomous Red Director, multiple concurrent movements,
virtualization, persistent mission restart, warehouses, recruitment, combat target
selection, teleport, unstuck, automatic reroute, or recovery.

## Build under test

```text
MOOSE: vendor/moose/Moose.lua, release 2.9.18
project bundle: mission/tests/tm02-red-relay/dist/TM02A.lua
configuration: TM02A-red-relay-foundation-1
```

The mission must load `vendor/moose/Moose.lua` before `dist/TM02A.lua`.

## Mission Editor prerequisites

Required group:

```text
TPL_TEST_RED_PACKET_06_01
```

Required zones:

```text
ZONE_TM02A_SOURCE
ZONE_TM02A_ROUTE_01
ZONE_TM02A_DESTINATION
```

The group must be RED coalition, contain exactly six ground infantry units, and
use Late Activation. Record the selected DCS country and exact unit types in the
result document.

The source and destination zones must be large enough for full-group membership.
The route anchor must be placed on a practically traversable segment between the
two directly adjacent nodes.

## F10 commands

```text
OMW Tests
└── TM02A
    ├── Validate configuration
    ├── Show RED relay status
    ├── Start one relay transfer
    └── Show active movement
```

## Initial expected domain state

```text
source garrisonAlive:       24
source minimumGarrison:     18
source availableSurplus:     6
destination garrisonAlive:   6
destination minimumGarrison:12
movement:                  NONE
initial personnel total:    30
```

## Execution

1. Start the mission and inspect `dcs.log`.
2. Confirm one `startup`, one native API pass, one MOOSE API pass, one
   `configuration_valid`, one `bootstrap_outcome outcome=READY`, and one
   `menu_ready` event.
3. Select `Show RED relay status` and record the initial values.
4. Select `Start one relay transfer` exactly once.
5. Confirm that exactly one runtime group is created from the template.
6. Immediately select `Start one relay transfer` again.
7. Confirm that the second request is rejected and no second group appears.
8. Observe the runtime group moving through the configured route anchor toward
   the direct destination node.
9. After the full living group is inside `ZONE_TM02A_DESTINATION`, select
   `Show active movement`.
10. Select `Show active movement` a second time.
11. Select `Show RED relay status` and save the final log segment.

## Mandatory log sequence

The successful path must contain these events in causal order:

```text
red_relay_start_requested
red_relay_reserved
red_relay_physical
red_relay_en_route
red_relay_started
red_relay_start_rejected
red_relay_arrival_credited
red_relay_arrived
red_relay_movement_status
red_relay_status
```

The exact log line order may include diagnostic status events between these items.

## Acceptance criteria

PASS requires all of the following:

1. Bootstrap outcome is `READY`.
2. Exactly four Mission Editor objects are validated: one template and three zones.
3. Exactly one movement ID is created: `TEST.TM02.MOVEMENT.001`.
4. Reservation removes exactly six fighters from the source before spawn.
5. Source garrison becomes 18 and never falls below its minimum of 18.
6. Exactly one physical runtime group exists.
7. The runtime group contains exactly six living units at spawn.
8. The Late Activation template remains inactive.
9. The movement representation is `PHYSICAL`; no virtual representation exists.
10. The assigned route contains one anchor plus the destination waypoint.
11. The configured destination is the source node's direct successor.
12. The repeated start command is rejected and creates no duplicate group or movement.
13. No teleport, automatic unstuck, automatic reroute, respawn, or recovery occurs.
14. The complete living group reaches `ZONE_TM02A_DESTINATION`.
15. Arrival credits exactly six survivors once.
16. Destination garrison changes from 6 to 12.
17. Repeated movement status does not credit arrival again.
18. Final movement state is `ARRIVED` and representation remains `PHYSICAL`.
19. Final source plus destination personnel equals the initial total of 30.
20. No `[OMW][TM02A] level=ERROR` event exists.
21. PR #8 remains open, draft, and unmerged; no TM02 code is added to its head branch.

## Immediate failure conditions

FAIL if any of these occurs:

- movement is spawned before CampaignState reservation;
- source minimum garrison is violated;
- a second physical group or movement appears;
- the destination is not the direct successor;
- the template activates instead of producing a separate runtime group;
- survivor count increases after a previous observation;
- arrival is credited more than once;
- a destroyed or failed movement is respawned;
- any automatic teleport, unstuck, reroute, or silent state correction occurs;
- hidden BLUE warehouse, trigger-zone, or mission data affects the decision;
- any TM02A ERROR event occurs.

## Evidence to archive

Create a result document under:

```text
mission/tests/tm02-red-relay/results/YYYY-MM-DD-tm02a-physical-relay.md
```

Record:

- DCS version;
- mission filename and mission revision;
- bundle build timestamp and configuration version;
- MOOSE version, embedded build commit, and SHA-256;
- RED country and exact six unit types;
- zone radii and approximate segment length;
- runtime group name;
- start, arrival, and final status log excerpts;
- observed group count at spawn and arrival;
- explicit PASS or FAIL for every criterion above.

## Follow-up regression

After the no-loss baseline passes, run a separate deterministic casualty test.
That regression must prove that observed survivor count can only decrease, only
survivors are credited, and no lost fighter is recreated. It must not introduce
a production combat system merely to damage the test group.
