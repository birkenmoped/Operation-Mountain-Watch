# TM02N RED tree-fill DCS result - 2026-07-17

## Result

**PASS for configuration version `TM02N-red-tree-fill-1`, superseded by the new top-down ordering requirement.**

The DCS run proved the physical multi-packet network, stable packet metadata, two-packet concurrency limit, relay routing, exactly-once arrivals, and complete personnel accounting. It also exposed that the original packet plan filled leaf shelters before A and B. Version 2 changes that order and requires a new DCS confirmation.

## Environment

- DCS: 2.9.27.25340, MT
- Theatre: Afghanistan
- MOOSE: static include, commit `73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`
- TM02N build timestamp: `2026-07-17T17:36:43Z`
- configuration: `TM02N-red-tree-fill-1`
- run start request: `2026-07-17 17:46:46.734`
- completion: `2026-07-17 17:52:38.241`

## Demonstrated

- all seven nodes and six packet definitions validated;
- six physical ten-person packets dispatched with stable packet IDs;
- no more than two packets were active simultaneously;
- leaf packets traversed A or B and continued to their final destinations;
- every packet arrived with ten survivors;
- final HQ stock was 40;
- A, B, AA, AB, BA, and BB each finished at 10;
- in-transit personnel finished at zero;
- total losses remained zero;
- final accounting was 100 / valid;
- no `[OMW][TM02N] level=ERROR` event occurred.

## Final recorded state

```text
red_packet_arrived ... destinationNodeId=RED_SHELTER_B destinationGarrison=10 survivorCount=10
red_network_completed ... accountedPersonnel=100 accountingValid=true activePacketCount=0 allSheltersAtTarget=true arrivedPacketCount=6 hqPersonnel=40 inTransitPersonnel=0 queuedPacketCount=0 shelterPersonnel=60 totalLosses=0
red_network_inventory ... accountedPersonnel=100 accountingValid=true activePacketCount=0 allSheltersAtTarget=true hqPersonnel=40 inTransitPersonnel=0 networkComplete=true shelterPersonnel=60 totalLosses=0
```

## Ordering finding

The version-1 plan dispatched AA and BA first. During the run, AA and BA were already at 10 while A and B still reported zero. A and B were filled only by packets 005 and 006 at the end.

That behavior satisfied the version-1 contract but does not satisfy the revised operational requirement. TM02N version 2 therefore enforces:

```text
A and B to 10
then
AA, AB, BA, and BB to 10
```

All replacement groups still originate at HQ, so intermediate shelters are never emptied by forwarding.

## Diagnostic correction

The `red_network_completed` event in version 1 carried `networkComplete=false` because the snapshot was created before `state.completed` was assigned. A later manual inventory correctly reported `networkComplete=true`. Version 2 updates the completion snapshot before logging.

## Decision

- Accept version 1 as proof of multi-packet routing and accounting.
- Do not use version 1 as proof of top-down fill order.
- Re-run DCS with `TM02N-red-tree-fill-2` before closing PR #10.
