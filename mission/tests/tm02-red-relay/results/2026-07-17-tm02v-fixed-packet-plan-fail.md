# TM02V fixed packet-plan finding

## Result

FAIL — the multi-proxy mechanism worked, but the test scope was incorrectly reduced to three preconfigured movements.

## Observed behavior

The controller started and tracked three independent packets. Each packet could be packed and unpacked independently and could materialize at its configured destination.

After those three packets arrived, no new packets were generated because version 3/4 used a fixed `config.movements` list. The controller had no deficit scanner or continuing dispatcher.

## Why this is incorrect

The RED network objective never changed:

```text
fill every shelter to its configured target strength
```

Packet count, strengths and destinations are derived data. They must not be treated as the primary configuration.

The fixed plan also initialized some shelters as already occupied only in metadata. That prevented the test from proving visible physical occupation of all six shelters.

## Required correction

Version 5 removes `config.movements` and restores the authoritative model:

```text
HQ stock + current shelter inventories + in-transit packets + losses = total personnel
```

The runtime dispatcher now:

1. scans shelter deficits;
2. observes inbound personnel;
3. creates exact-strength packets from 1 through 10;
4. enforces the top-down depth barrier;
5. assigns one independent proxy and launch slot per active packet;
6. dispatches replacement packets whenever a slot becomes free;
7. continues until every shelter reaches target strength.

For the primary acceptance, HQ starts with 100 and all six shelters start at 0/10. The expected result is six dynamically generated ten-person packets and six visible physical garrisons.
