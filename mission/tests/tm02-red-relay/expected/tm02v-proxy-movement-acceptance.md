# TM02V RED dynamic proxy-fill acceptance

## Purpose

TM02V validates the proxy representation for the original RED network objective: fill every configured shelter to its target strength from an authoritative HQ personnel pool.

No movement list, packet count, packet strength, or destination assignment is hard-coded. Packets are generated from current deficits at runtime.

```text
current deficit -> exact packet strength -> own leader proxy -> own route -> visible destination group
```

Every logical packet owns its own physical leader proxy, route, coordinate, marker, representation state, launch slot and runtime identity. A proxy is never shared.

## Initial state for this acceptance

```text
HQ: 100
A:   0 / 10
B:   0 / 10
AA:  0 / 10
AB:  0 / 10
BA:  0 / 10
BB:  0 / 10
Recorded losses: 0
Total: 100
```

## Dynamic generation doctrine

The controller calculates for every shelter:

```text
deficit = targetStrength - currentGarrison - inboundPersonnel
```

When a dispatch slot is free, it generates a packet with:

```text
strength = min(packetMaxStrength, deficit, available HQ personnel)
```

For this acceptance all deficits are 10, so six ten-person packets are expected. This is an outcome of the configured state, not a fixed movement plan.

The same controller must also accept partial deficits from 1 through 10 and select the corresponding existing template automatically.

## Top-down fill barrier

Depth 1 must be completed first:

```text
HQ -> A
HQ -> B
```

Only after A and B both reach 10 may depth 2 dispatch:

```text
HQ -> A -> AA
HQ -> A -> AB
HQ -> B -> BA
HQ -> B -> BB
```

Intermediate nodes are transit nodes for leaf-bound packets and are not debited or credited during pass-through.

## Concurrency and proxies

```text
maxActivePackets = 3
launchSlotCount = 3
```

Each active packet has exactly one independent leader proxy derived from unit slot 1 of its own strength template.

For a ten-person packet:

```text
TPL_TEST_RED_PACKET_10_01 -> unit slot 1 -> one-man proxy
```

The three launch slots are spatially separated inside the HQ zone. The proxies may later converge physically because of DCS routing, but they must remain different runtime groups and different packet identities.

## Representation cycle

Each packet independently supports:

```text
NONE
-> LEADER_PROXY
-> PHYSICAL
-> LEADER_PROXY
-> PHYSICAL_GARRISON
```

At the final destination a packed packet automatically materializes as the complete survivor group. The physical group remains visible in the destination zone.

Manual pack and unpack commands apply only to the selected packet.

## Dynamic F10 menu

```text
OMW Tests
└── TM02V Dynamic Proxy Fill
    ├── Validate test
    ├── Start automatic proxy fill
    ├── Show network and packet status
    ├── Toggle packet markers
    └── Packet NNN -> destination
        ├── Show status
        ├── Force unpack
        └── Force pack
```

Packet submenus are created when the runtime dispatcher generates the packets. There are no configured packet menus before the fill starts.

## Expected no-loss sequence

Immediately after start:

```text
Generated packets: 2
Active packets: 2
HQ: 80
Targets: A and B
```

No AA, AB, BA or BB packet may exist before A and B are full.

After A and B arrive:

```text
event=red_proxy_fill_level_advanced previousDepth=1 currentDispatchDepth=2
```

The controller then generates leaf packets as slots permit. With three active slots, three leaf packets start first and the fourth starts automatically when a slot becomes free.

No second F10 start command is permitted or required.

## Final state

```text
HQ: 40
A:  10 / 10
B:  10 / 10
AA: 10 / 10
AB: 10 / 10
BA: 10 / 10
BB: 10 / 10
In transit: 0
Recorded losses: 0
Total deficit: 0
Accounted: 100 / 100
```

Six visible physical garrison groups must remain in the six shelter zones.

## Mandatory startup evidence

```text
event=red_proxy_leader_adapter_installed launchSlotCount=3
event=red_proxy_validation configurationValid=true missionObjectsValid=true dynamicPacketGeneration=true initialDeficit=60
event=startup configurationVersion=TM02V-red-proxy-dynamic-fill-5 configuredMovementCount=0 initialHqPersonnel=100 initialShelterDeficit=60
```

`configuredMovementCount=0` is intentional. Packets must be generated from live deficits.

## Mandatory dispatch evidence

Depth 1:

```text
event=red_proxy_packet_generated destinationNodeId=RED_SHELTER_A strength=10 targetDepth=1
event=red_proxy_packet_generated destinationNodeId=RED_SHELTER_B strength=10 targetDepth=1
```

Depth 2, only after the fill-level transition:

```text
event=red_proxy_packet_generated destinationNodeId=RED_SHELTER_AA strength=10 targetDepth=2
event=red_proxy_packet_generated destinationNodeId=RED_SHELTER_AB strength=10 targetDepth=2
event=red_proxy_packet_generated destinationNodeId=RED_SHELTER_BA strength=10 targetDepth=2
event=red_proxy_packet_generated destinationNodeId=RED_SHELTER_BB strength=10 targetDepth=2
```

Every generated packet must have its own `packetId`, proxy runtime group name and marker ID.

## Mandatory completion evidence

```text
event=red_proxy_network_completed
generatedPacketCount=6
arrivedPacketCount=6
destroyedPacketCount=0
hqPersonnel=40
shelterPersonnel=60
inTransitPersonnel=0
totalLosses=0
totalDeficit=0
accountedPersonnel=100
accountingValid=true
allSheltersAtTarget=true
networkComplete=true
```

## Variable-deficit regression

Outside DCS, the same controller is also tested with:

```text
A deficit 1
B deficit 2
AA deficit 3
AB deficit 4
BA deficit 5
BB deficit 6
```

It must dynamically generate strengths `1, 2, 3, 4, 5, 6`, respect the same top-down barrier and finish every shelter at 10.

## PASS criteria

TM02V passes only when:

- all six shelters finish at target strength;
- packets are generated from deficits rather than a fixed movement list;
- A and B are completed before any leaf packet dispatch;
- every simultaneously active packet has its own proxy and launch slot;
- each packet follows its own route and marker;
- automatic dispatch continues when earlier packets arrive;
- manual pack or unpack affects only the selected packet;
- destination materialization uses the exact survivor strength;
- all six destination groups remain physically visible;
- accounting remains exactly 100;
- no `[OMW][TM02V] level=ERROR` event occurs.

## Automatic FAIL conditions

The test fails if:

- only selected shelters are serviced;
- the controller stops after a fixed number of packets while deficits remain;
- packets or destinations are hard-coded in `config.movements`;
- a leaf packet starts before A and B are full;
- two logical packets share one proxy;
- a destination is overfilled;
- personnel are duplicated or disappear from accounting;
- an arrival or subsequent dispatch requires a diagnostic F10 command.
