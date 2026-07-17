# TM02V dynamic proxy fill version 5 — DCS PASS

Date: 2026-07-17

Configuration:

```text
TM02V-red-proxy-dynamic-fill-5
packetMaxStrength=10
maxActivePackets=3
launchSlotCount=3
```

## Startup and validation

The DCS log confirmed:

```text
configuredMovementCount=0
dynamicPacketGeneration=true
initialHqPersonnel=100
initialShelterDeficit=60
configurationValid=true
missionObjectsValid=true
```

## Observed dispatch

Depth 1 generated two ten-person packets for A and B. No leaf packet was dispatched before both depth-1 shelters reached target strength.

After both arrivals, the controller logged:

```text
event=red_proxy_fill_level_advanced
previousDepth=1
currentDispatchDepth=2
```

It then generated packets for AA, AB and BA. BB was generated automatically after a launch slot became free. No second F10 start command was required.

## Completion

Observed final event:

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

All six shelters reached 10 personnel. The six destination groups remained physical. No `[OMW][TM02V] level=ERROR` event occurred during the test.

Result: **PASS**.
