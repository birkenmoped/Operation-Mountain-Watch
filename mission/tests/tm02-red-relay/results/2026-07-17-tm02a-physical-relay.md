# TM02A physical RED relay result — 2026-07-17

## Result

**INCOMPLETE — physical routing demonstrated; final arrival accounting not sampled.**

The corrected three-waypoint bundle loaded successfully. The operator subsequently confirmed that the complete six-unit runtime infantry group physically traversed the route and reached the configured destination point. The supplied log sampled movement status before that arrival and contains no later `Show active movement` invocation, so the final destination-zone membership and CampaignState arrival credit remain unproven in recorded evidence.

## Environment

- DCS: `2.9.27.25340` (`x86_64`, MT)
- Mission theatre: Afghanistan
- Mission filename/revision: not recorded in the supplied log
- TM02A configuration: `TM02A-red-relay-foundation-1`
- TM02A bundle build timestamp: `2026-07-17T16:12:18Z`
- MOOSE release: `2.9.18`
- Embedded MOOSE build commit: `73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`
- Expected `Moose.lua` SHA-256: `e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915`
- RED country and exact unit types: not recorded
- Zone radii and approximate segment length: not recorded

## Run under test

- TM02A startup: `2026-07-17 16:13:41.026`
- Transfer requested: `2026-07-17 16:14:10.108`
- Runtime group: `TM02A_RED_RELAY_001#001`
- Recorded movement status sample: `2026-07-17 16:14:36.211`
- Mission stopped: `2026-07-17 16:20:29.683`
- Operator observation: the complete group reached the destination point after the recorded status sample

## Demonstrated

- bootstrap outcome was `READY`;
- native and MOOSE API validation passed;
- exactly four required Mission Editor objects were validated;
- reservation removed exactly six fighters before spawn;
- source garrison became 18 and accounting remained valid at 30;
- exactly one physical runtime group was registered;
- survivor count was six;
- representation state was `PHYSICAL`;
- movement state became `EN_ROUTE`;
- duplicate start was rejected;
- corrected route diagnostics were active:
  - `startWaypointIncluded=true`;
  - `routeAssignmentDelaySeconds=1`;
  - `routeAnchorCount=1`;
  - `totalWaypointCount=3`;
- the complete runtime group physically traversed the route and reached the destination point, per operator observation;
- no `[OMW][TM02A] level=ERROR` event occurred.

## Recorded log excerpt

```text
2026-07-17 16:14:10.108 INFO SCRIPTING: [OMW][TM02A] level=INFO event=red_relay_reserved ... sourceGarrisonAlive=18 sourceMinimumGarrison=18 survivorCount=6
2026-07-17 16:14:10.111 INFO SCRIPTING: [OMW][TM02A] level=INFO event=red_relay_physical ... runtimeGroupName=TM02A_RED_RELAY_001#001 survivorCount=6
2026-07-17 16:14:10.112 INFO SCRIPTING: [OMW][TM02A] level=INFO event=red_relay_started ... routeAssignmentDelaySeconds=1 speedKph=5 startWaypointIncluded=true totalWaypointCount=3
2026-07-17 16:14:31.591 INFO SCRIPTING: [OMW][TM02A] level=INFO event=red_relay_start_rejected movementId=TEST.TM02.MOVEMENT.001 reason=spawn was already attempted
2026-07-17 16:14:36.211 INFO SCRIPTING: [OMW][TM02A] level=INFO event=red_relay_movement_status arrivalCredited=false destinationZoneMembership=false movementState=EN_ROUTE representationState=PHYSICAL routeAssigned=true runtimeGroupName=TM02A_RED_RELAY_001#001 survivorCount=6
```

The status sample occurred only about 26 seconds after the transfer request and therefore predates the operator-observed arrival.

## Still unproven in recorded evidence

- all six living units were simultaneously inside `ZONE_TM02A_DESTINATION` when inspected;
- `red_relay_arrival_credited` was emitted exactly once;
- `red_relay_arrived` was emitted;
- destination garrison changed from 6 to 12;
- repeated status inspection did not credit arrival twice;
- final movement state was `ARRIVED`.

## Required completion run

Repeat the same mission without changing the route. After the group has stopped at the destination:

1. select `Show active movement`;
2. select `Show active movement` a second time;
3. select `Show RED relay status`;
4. preserve the resulting log.

Expected final evidence:

```text
red_relay_arrival_credited
red_relay_arrived
red_relay_movement_status ... destinationZoneMembership=true arrivalCredited=true movementState=ARRIVED
red_relay_status ... sourceGarrisonAlive=18 destinationGarrisonAlive=12 accountedPersonnel=30 accountingValid=true
```

If the group has reached the waypoint but `destinationZoneMembership=false` remains, enlarge or reposition `ZONE_TM02A_DESTINATION` so the complete six-unit formation—not only its lead unit or route endpoint—is inside the zone.