# TM02V overlapping proxy launch failure

Date: 2026-07-17
Configuration: `TM02V-red-proxy-movement-3`
Outcome: FAIL - physical proxies existed but were visually superimposed.

## Observed runtime state

The controller created three different logical packets and three different DCS runtime groups:

```text
TM02V_RED_PROXY_001_G001#001
TM02V_RED_PROXY_002_G001#001
TM02V_RED_PROXY_003_G001#001
```

It reported `packetCount=3`, `activePacketCount=3`, `inTransitPersonnel=13`, and valid accounting.

The groups were not virtual-only. Each packet reported `representationState=LEADER_PROXY` and an independent runtime group name.

## Failure

All three proxies were spawned with `SpawnInZone(sourceZone, false)`. With a one-unit derived template and deterministic zone spawning, this placed all three leaders at effectively the same point.

At 20:09:13 their horizontal positions differed by only a few centimetres. At 20:10:31 they were still within a few centimetres of one another. DCS therefore rendered them as one overlapping infantryman even though three physical groups existed.

Manual unpacking exposed the independent packet identities because each full group then became separately visible.

## Correction

Configuration version 4 assigns a deterministic launch offset to every packet:

```text
Packet 001: x -12 m, y 0 m
Packet 002: x   0 m, y 0 m
Packet 003: x +12 m, y 0 m
```

The leader-proxy adapter now uses absolute unit positions inside the HQ zone and emits one `red_proxy_launch_slot_applied` event per packet. Duplicate offsets and offsets outside the source zone fail validation at runtime.

## Version 4 acceptance requirement

Immediately after `Start all proxy movements`:

- three proxy infantrymen must be visibly distinct;
- three `red_proxy_launch_slot_applied` events must contain different coordinates;
- three `red_proxy_packet_started` events must contain different runtime group names;
- all three packet status records must remain `LEADER_PROXY` unless individually unpacked;
- a single visible stacked proxy is a FAIL even when metadata reports three packets.
