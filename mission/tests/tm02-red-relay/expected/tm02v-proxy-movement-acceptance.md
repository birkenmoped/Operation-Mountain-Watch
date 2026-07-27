# TM02V RED dynamic proxy-fill acceptance — maximum packet strength 6

## Purpose

TM02V validates that the dynamic dispatcher can fill every configured shelter to ten personnel even when no single movement group may contain more than six personnel.

No packet list, packet count, packet strength or destination assignment is configured in advance. Every packet is generated from the live deficit.

```text
shelter target 10
packet maximum 6
expected composition per empty shelter: 6 + 4
```

Every generated packet owns its own leader proxy, route, coordinate, marker, launch slot, runtime group identity and pack/unpack lifecycle.

## Initial state

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

## Runtime generation rule

For every shelter:

```text
deficit = targetStrength - currentGarrison - inboundPersonnel
packet strength = min(packetMaxStrength, deficit, available HQ personnel)
```

For this acceptance:

```text
packetMaxStrength = 6
maxActivePackets = 6
launchSlotCount = 6
```

An empty ten-person shelter therefore requires two independently tracked packets:

```text
first packet:  6
second packet: 4
combined inbound or arrived strength: 10
```

No generated packet may have strength 7, 8, 9 or 10.

## Top-down barrier

Depth 1 must be completed first:

```text
HQ -> A: 6 + 4
HQ -> B: 6 + 4
```

Expected first dispatch wave:

```text
Packet 001: strength 6 -> A
Packet 002: strength 4 -> A
Packet 003: strength 6 -> B
Packet 004: strength 4 -> B
```

Immediately after initial dispatch:

```text
Generated packets: 4
Active packets:    4
HQ:               80
In transit:       20
A inbound:        10
B inbound:        10
```

The two unused launch slots must remain free. No leaf-bound packet may exist before A and B both physically reach ten personnel and their inbound counts return to zero.

Only then may the controller log:

```text
event=red_proxy_fill_level_advanced
previousDepth=1
currentDispatchDepth=2
```

## Depth-2 dispatch

The four leaf shelters also require `6 + 4` each:

```text
AA: 6 + 4
AB: 6 + 4
BA: 6 + 4
BB: 6 + 4
```

The dispatcher iterates the configured shelter order. With six active slots, the expected first depth-2 wave is:

```text
Packet 005: strength 6 -> AA
Packet 006: strength 4 -> AA
Packet 007: strength 6 -> AB
Packet 008: strength 4 -> AB
Packet 009: strength 6 -> BA
Packet 010: strength 4 -> BA
```

Packets for BB must be generated automatically as launch slots become free:

```text
Packet 011: strength 6 -> BB
Packet 012: strength 4 -> BB
```

A second F10 start command is prohibited and unnecessary.

## Concurrency and launch slots

Six deterministic launch positions exist inside the HQ zone:

```text
Slot 1: x=-10, y=-6
Slot 2: x=  0, y=-6
Slot 3: x= 10, y=-6
Slot 4: x=-10, y= 6
Slot 5: x=  0, y= 6
Slot 6: x= 10, y= 6
```

Every simultaneously active packet must have:

- a unique packet ID;
- a unique runtime proxy group;
- a unique launch slot;
- a unique marker ID;
- its own route and representation state.

The active count must never exceed six. Releasing a slot at arrival or destruction must allow the dispatcher to create the next required packet automatically.

## Proxy derivation

The leader proxy is derived from unit slot 1 of the packet's own strength template.

```text
strength 6 -> TPL_TEST_RED_PACKET_06_01 -> unit slot 1
strength 4 -> TPL_TEST_RED_PACKET_04_01 -> unit slot 1
```

No dedicated proxy template is used.

## Representation cycle

Each packet independently supports:

```text
NONE
-> LEADER_PROXY
-> PHYSICAL
-> LEADER_PROXY
-> PHYSICAL_GARRISON
```

Manual pack or unpack commands affect only the selected packet. A packed packet automatically materializes at its final destination with its exact survivor strength.

## Expected physical destination state

Because the maximum group size is six, each completed shelter contains two physical garrison groups:

```text
one six-person group
one four-person group
combined shelter strength: 10
```

Expected final physical group count:

```text
2 groups per shelter x 6 shelters = 12 destination groups
```

The controller may not merge them into a ten-person group because that would violate the configured group-size maximum.

## F10 menu

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

Packet submenus are created dynamically for all twelve packets as they are generated.

## Mandatory startup evidence

```text
event=red_proxy_leader_adapter_installed launchSlotCount=6
event=red_proxy_validation configurationValid=true missionObjectsValid=true dynamicPacketGeneration=true initialDeficit=60 maxActivePackets=6 launchSlotCount=6
event=startup configurationVersion=TM02V-red-proxy-dynamic-fill-6 configuredMovementCount=0 initialHqPersonnel=100 initialShelterDeficit=60 maxActivePackets=6 launchSlotCount=6
```

## Mandatory dispatch evidence

Depth 1 must generate exactly four packets with strengths:

```text
A: 6, 4
B: 6, 4
```

Depth 2 must generate exactly eight packets with strengths:

```text
AA: 6, 4
AB: 6, 4
BA: 6, 4
BB: 6, 4
```

Across the complete run:

```text
generatedPacketCount = 12
all generated strengths are 4 or 6
maximum observed activePacketCount <= 6
```

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

Mandatory completion event:

```text
event=red_proxy_network_completed
generatedPacketCount=12
arrivedPacketCount=12
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

## PASS criteria

TM02V passes only when:

- all six shelters finish at exactly ten personnel;
- every empty shelter is filled by multiple packets because the packet cap is six;
- no packet exceeds six personnel;
- A and B are completed before any leaf packet dispatch;
- up to six independent proxies can exist simultaneously;
- no proxy, launch slot, marker or runtime group is shared by active packets;
- the dispatcher continues after earlier arrivals until all twelve packets have arrived;
- every destination retains a six-person and a four-person physical group;
- accounting remains exactly 100;
- no `[OMW][TM02V] level=ERROR` event occurs.

## Automatic FAIL conditions

The test fails if:

- any generated packet has strength greater than six;
- any shelter stops at six, four or another value below ten;
- a ten-person packet is generated or materialized;
- the controller assumes one packet per shelter;
- a leaf packet starts before A and B are full;
- active packet count exceeds six;
- two active packets share one proxy or launch slot;
- BB dispatch requires another manual start command;
- a destination is overfilled;
- personnel are duplicated or disappear from accounting.
