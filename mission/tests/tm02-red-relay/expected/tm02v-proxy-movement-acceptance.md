# TM02V RED multi-proxy movement acceptance

## Purpose

TM02V validates several simultaneous RED movements. Every logical packet owns its own physical leader proxy, route, coordinate, marker, representation state and runtime identity.

A proxy is never shared between packets.

```text
one logical packet = one runtime leader proxy
```

The leader proxy is dynamically derived from unit slot 1 of the packet's normal strength template. No dedicated proxy template is required.

## Test packets

```text
Packet 001: strength 3, HQ -> A -> AA
Packet 002: strength 4, HQ -> A -> AB
Packet 003: strength 6, HQ -> B -> BB
```

All three packets start together and move independently.

Derived proxy sources:

```text
Packet 001 -> TPL_TEST_RED_PACKET_03_01 -> unit slot 1
Packet 002 -> TPL_TEST_RED_PACKET_04_01 -> unit slot 1
Packet 003 -> TPL_TEST_RED_PACKET_06_01 -> unit slot 1
```

Each runtime proxy must have a different group name and a different marker ID.

## Initial accounting

```text
HQ: 47
A:  10 / 10
B:  10 / 10
AA:  7 / 10
AB:  6 / 10
BA: 10 / 10
BB:  4 / 10
Recorded losses: 6
Total: 100
```

After all packets start:

```text
HQ: 34
Shelters: 47
In transit: 13
Recorded losses: 6
Total: 100
```

Final state without transit losses:

```text
HQ: 34
A:  10 / 10
B:  10 / 10
AA: 10 / 10
AB: 10 / 10
BA: 10 / 10
BB: 10 / 10
In transit: 0
Recorded losses: 6
Total: 100
```

## Per-packet metadata

Every packet must retain independent fields:

```lua
{
  packetId = "TEST.TM02.VIRTUAL.PACKET.001",
  strength = 3,
  survivorCount = 3,
  routeNodeIds = { "RED_HQ", "RED_SHELTER_A", "RED_SHELTER_AA" },
  currentLegIndex = 1,
  finalDestinationNodeId = "RED_SHELTER_AA",
  movementState = "EN_ROUTE",
  representationState = "LEADER_PROXY",
  proxyGroupName = "...",
  physicalGroupName = nil,
  currentCoordinate = { x = ..., y = ..., z = ... },
  markerId = 220201,
}
```

Changing one packet must not change any other packet's state or runtime group.

## Representation cycle

Each packet independently supports:

```text
NONE
-> LEADER_PROXY
-> PHYSICAL
-> LEADER_PROXY
-> PHYSICAL_GARRISON
```

Different packets may be in different representation states at the same mission time. For example:

```text
Packet 001: PHYSICAL
Packet 002: LEADER_PROXY
Packet 003: LEADER_PROXY
```

This is valid and required.

## F10 menu

```text
OMW Tests
└── TM02V Multi-Proxy Movement
    ├── Validate test
    ├── Start all proxy movements
    ├── Show all packet status
    ├── Toggle packet markers
    ├── Packet 001 -> RED_SHELTER_AA
    │   ├── Show status
    │   ├── Force unpack
    │   └── Force pack
    ├── Packet 002 -> RED_SHELTER_AB
    │   ├── Show status
    │   ├── Force unpack
    │   └── Force pack
    └── Packet 003 -> RED_SHELTER_BB
        ├── Show status
        ├── Force unpack
        └── Force pack
```

## DCS execution

1. Validate the test.
2. Start all proxy movements once.
3. Confirm three separate one-man RED proxies appear at HQ.
4. Confirm the three proxies have distinct runtime group names.
5. Confirm three independent map markers move with the proxies.
6. Force-unpack Packet 001 while Packets 002 and 003 remain packed.
7. Confirm Packet 001 becomes a three-man group while the other two remain one-man proxies.
8. Force-pack Packet 001 again.
9. Optionally unpack Packet 002 or Packet 003 independently.
10. Allow all packets to pass their intermediate nodes.
11. Confirm each packet materializes automatically at its own final destination.
12. Confirm AA, AB and BB reach exactly 10 personnel.
13. Confirm final accounting remains 100.

## Mandatory log evidence

Startup:

```text
event=red_proxy_leader_adapter_installed sourcePolicy=LEADER_FROM_PACKET_TEMPLATE
event=red_proxy_validation configurationValid=true missionObjectsValid=true checkedPacketCount=3
event=startup configurationVersion=TM02V-red-proxy-movement-3 packetCount=3
```

Start:

```text
event=red_proxy_packet_started packetId=TEST.TM02.VIRTUAL.PACKET.001 strength=3 activePacketCount=1
event=red_proxy_packet_started packetId=TEST.TM02.VIRTUAL.PACKET.002 strength=4 activePacketCount=2
event=red_proxy_packet_started packetId=TEST.TM02.VIRTUAL.PACKET.003 strength=6 activePacketCount=3
event=red_proxy_movements_started packetCount=3 activePacketCount=3 inTransitPersonnel=13 accountingValid=true
```

Independent transition evidence:

```text
event=red_proxy_unpacked packetId=TEST.TM02.VIRTUAL.PACKET.001 survivorCount=3
event=red_proxy_packet_status packetId=TEST.TM02.VIRTUAL.PACKET.002 representationState=LEADER_PROXY
event=red_proxy_packet_status packetId=TEST.TM02.VIRTUAL.PACKET.003 representationState=LEADER_PROXY
```

Completion:

```text
event=red_proxy_arrived packetId=TEST.TM02.VIRTUAL.PACKET.001 destinationNodeId=RED_SHELTER_AA
event=red_proxy_arrived packetId=TEST.TM02.VIRTUAL.PACKET.002 destinationNodeId=RED_SHELTER_AB
event=red_proxy_arrived packetId=TEST.TM02.VIRTUAL.PACKET.003 destinationNodeId=RED_SHELTER_BB
event=red_proxy_network_completed packetCount=3 arrivedPacketCount=3 accountedPersonnel=100 accountingValid=true allSheltersAtTarget=true networkComplete=true
```

## PASS criteria

TM02V passes only when:

- exactly three logical packets exist;
- exactly three independent proxies exist while all packets are packed;
- no proxy is shared;
- every proxy follows its packet's own route;
- every packet owns a unique marker and runtime identity;
- one packet can unpack or pack without changing the others;
- destination materialization uses the correct strength template;
- AA, AB and BB finish at exactly 10;
- HQ finishes at 34;
- no packet remains in transit;
- accounting remains exactly 100;
- no `[OMW][TM02V] level=ERROR` event occurs.

## Automatic FAIL conditions

The test fails if:

- the controller exposes only one `state.packet` singleton;
- two logical packets reference the same proxy group;
- only one movement can run at a time;
- packing or unpacking one packet changes another packet;
- a packet follows another packet's route or marker;
- a destination is overfilled;
- personnel are duplicated or lost from accounting;
- an arrival requires a diagnostic F10 command.
