# TM02V RED leader-proxy movement acceptance

## Purpose

TM02V validates a RED movement whose authoritative strength remains in metadata while one real infantryman carries the current DCS world position. The proxy is not a separate Mission Editor template. It is derived dynamically from unit slot 1 of the normal group template that already represents the movement strength.

For this acceptance:

```text
Logical packet: 6 personnel
Source template: TPL_TEST_RED_PACKET_06_01
Proxy: unit slot 1 from that template
Route: RED_HQ -> RED_SHELTER_A -> RED_SHELTER_AA
```

A ten-person movement would analogously derive its proxy from unit slot 1 of `TPL_TEST_RED_PACKET_10_01`.

## Representation doctrine

```text
NONE
-> LEADER_PROXY
-> PHYSICAL
-> LEADER_PROXY
-> PHYSICAL_GARRISON
```

The one physical leader is only the positional representation of the complete logical packet. It is never counted as an additional person.

The authoritative accounting invariant remains:

```text
HQ + shelter garrisons + logical personnel in transit + recorded losses = 100
```

## Required Mission Editor objects

No dedicated proxy group is required.

Use the existing Late Activation infantry templates:

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

Each template must contain exactly the strength encoded in its name. Unit slot 1 must be the intended group leader because that slot is retained when the dynamic one-unit proxy template is built.

Reuse the existing zones:

```text
ZONE_TM02N_HQ
ZONE_TM02N_A
ZONE_TM02N_B
ZONE_TM02N_AA
ZONE_TM02N_AB
ZONE_TM02N_BA
ZONE_TM02N_BB
```

## Dynamic leader-proxy construction

At runtime TM02V:

1. selects the standard template matching the movement strength;
2. copies its MOOSE spawn template;
3. retains only `units[1]`;
4. preserves category, country and coalition metadata;
5. creates a one-unit runtime spawner with `SPAWN:NewFromTemplate`;
6. spawns that derived leader at the required coordinate or in the source zone.

For the six-person acceptance, both initial proxy spawn and later repacking use the leader definition from `TPL_TEST_RED_PACKET_06_01`. No `TPL_TEST_RED_PROXY_01` object may be required.

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

## Test sequence

1. Start the mission and confirm successful validation.
2. Select `Start proxy movement`.
3. Confirm that exactly one infantryman appears in `ZONE_TM02N_HQ`.
4. Confirm that status still reports logical strength 6.
5. Observe the moving debug marker and proxy along HQ -> A.
6. Select `Force unpack` before A.
7. Confirm that exactly six physical infantrymen replace the proxy at its current position.
8. Select `Force pack`.
9. Confirm that the six-man group is replaced by one leader proxy and that logical strength remains 6.
10. Let the proxy pass A and continue toward AA.
11. Let it enter `ZONE_TM02N_AA`.
12. Confirm automatic materialization of six visible infantrymen in AA.
13. Confirm the final group remains visible and the proxy no longer exists.

## Required logs

Successful bootstrap must include:

```text
configurationVersion=TM02V-red-proxy-movement-2
event=red_proxy_leader_adapter_installed
sourcePolicy=LEADER_FROM_MOVEMENT_TEMPLATE
sourceTemplate=TPL_TEST_RED_PACKET_06_01
sourceUnitIndex=1
```

Each proxy creation must include:

```text
event=red_proxy_leader_template_derived
sourceTemplate=TPL_TEST_RED_PACKET_06_01
sourceUnitIndex=1
```

Validation must report:

```text
event=red_proxy_validation
configurationValid=true
missionObjectsValid=true
missingObjects=none
```

The log must not contain `TPL_TEST_RED_PROXY_01` as a required or missing object.

## Expected accounting

Initial:

```text
HQ: 40
shelters: 54
recorded losses: 6
accounted: 100
```

En route:

```text
HQ: 34
shelters: 54
logical in transit: 6
recorded losses: 6
accounted: 100
physical proxy count: 1, not added to personnel
```

Final without transit losses:

```text
HQ: 34
AA: 10 / 10
all shelters: 60
in transit: 0
recorded losses: 6
accounted: 100
```

## Acceptance criteria

PASS requires all of the following:

1. No dedicated proxy template exists or is required.
2. The standard six-person template validates.
3. Unit slot 1 of the six-person template is used to derive the proxy.
4. The packed representation contains exactly one living runtime unit.
5. Logical packet strength remains six while packed.
6. The debug marker follows the proxy coordinate.
7. Manual unpack creates exactly six physical units at the proxy position.
8. The old proxy is removed only after the full group has spawned and accepted its route.
9. Manual pack creates exactly one derived leader proxy at the physical group position.
10. The old physical group is removed only after the proxy has spawned and accepted its route.
11. Transit losses, when present, reduce logical survivor count and increase recorded losses exactly once.
12. The proxy is never counted as additional personnel.
13. A is crossed as a relay without changing its garrison.
14. Arrival at AA automatically materializes the physical survivor group.
15. Arrival credit occurs exactly once.
16. AA reaches 10 / 10 without transit losses.
17. Final accounting remains exactly 100.
18. No `[OMW][TM02V] level=ERROR` event exists.
