# TM02V maximum-six parallel packet test version 6 — DCS PASS

Date: 2026-07-18

Configuration:

```text
TM02V-red-proxy-dynamic-fill-6
packetMaxStrength=6
maxActivePackets=6
launchSlotCount=6
```

## Test purpose

This is an isolated technical boundary test. It validates packet-size limiting, independent concurrent proxies, automatic follow-on dispatch, destination materialization and exact personnel accounting.

It is deliberately not an efficient production distribution policy. Because each empty shelter has target strength ten and every packet is capped at six, the fixed test tree necessarily generates two HQ-origin packets for every shelter:

```text
6 + 4 = 10
```

The later TM02W network commander replaces this fixed behavior with multiple sources, cost-based routing, movable node personnel and bounded command decisions.

## Startup and validation

The DCS log confirmed:

```text
configurationValid=true
missionObjectsValid=true
dynamicPacketGeneration=true
initialDeficit=60
launchSlotCount=6
maxActivePackets=6
checkedNodeCount=7
checkedStrengthTemplateCount=10
```

## Observed dispatch

Depth 1 generated:

```text
A: packet 001 strength 6, packet 002 strength 4
B: packet 003 strength 6, packet 004 strength 4
```

No depth-2 packet was dispatched until A and B had both reached ten personnel.

Depth 2 generated:

```text
AA: packets 005/006 strengths 6/4
AB: packets 007/008 strengths 6/4
BA: packets 009/010 strengths 6/4
BB: packets 011/012 strengths 6/4
```

The active packet count reached six. BB packets were generated automatically when launch slots became available; no second start command was required.

## Completion

Observed final event:

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

All six shelters reached exactly ten personnel and retained separate six-person and four-person destination groups. No `[OMW][TM02V] level=ERROR` event was observed during the test.

An unrelated DCS `WRADIO` menu assertion occurred while using the radio menu. It did not stop TM02V, alter packet state or prevent successful completion. The known unrelated `bhHook.lua` TCP error occurred during mission shutdown.

Result: **PASS**.

TM02V is complete and frozen as the packet/proxy/representation/accounting test stage. Efficiency, network-source selection and commander behavior continue in TM02W.
