# TM02A physical RED relay result — 2026-07-17

## Result

**FAIL — physical movement/arrival not demonstrated.**

The corrected three-waypoint bundle loaded successfully and the domain transaction remained valid, but the runtime infantry group did not demonstrate successful physical transit to the destination during the observed mission run.

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

## Latest run under test

- TM02A startup: `2026-07-17 16:13:41.026`
- Transfer requested: `2026-07-17 16:14:10.108`
- Runtime group: `TM02A_RED_RELAY_001#001`
- Movement status sampled: `2026-07-17 16:14:36.211`
- Mission stopped: `2026-07-17 16:20:29.683`

## Positive evidence

The latest run proves all of the following:

- bootstrap outcome was `READY`;
- native and MOOSE API validation passed;
- exactly four required Mission Editor objects were validated;
- source accounting began at `24 / minimum 18 / surplus 6`;
- reservation removed exactly six fighters before spawn;
- source garrison became 18 and accounting remained valid at 30;
- exactly one physical runtime group was registered;
- survivor count was six;
- representation state was `PHYSICAL`;
- movement state became `EN_ROUTE`;
- duplicate start was rejected;
- the corrected route bundle was loaded with:
  - `startWaypointIncluded=true`;
  - `routeAssignmentDelaySeconds=1`;
  - `routeAnchorCount=1`;
  - `totalWaypointCount=3`;
- no `[OMW][TM02A] level=ERROR` event occurred.

## Relevant log excerpts

```text
2026-07-17 16:13:41.026 INFO SCRIPTING: [OMW][TM02A] level=INFO event=startup buildTimestamp=2026-07-17T16:12:18Z configurationVersion=TM02A-red-relay-foundation-1 ...
2026-07-17 16:13:41.026 INFO SCRIPTING: [OMW][TM02A] level=INFO event=bootstrap_outcome detail=TM02A configuration validation completed outcome=READY
2026-07-17 16:14:10.108 INFO SCRIPTING: [OMW][TM02A] level=INFO event=red_relay_reserved ... sourceGarrisonAlive=18 sourceMinimumGarrison=18 survivorCount=6
2026-07-17 16:14:10.111 INFO SCRIPTING: [OMW][TM02A] level=INFO event=red_relay_physical ... runtimeGroupName=TM02A_RED_RELAY_001#001 survivorCount=6
2026-07-17 16:14:10.112 INFO SCRIPTING: [OMW][TM02A] level=INFO event=red_relay_started ... routeAssignmentDelaySeconds=1 speedKph=5 startWaypointIncluded=true totalWaypointCount=3
2026-07-17 16:14:31.591 INFO SCRIPTING: [OMW][TM02A] level=INFO event=red_relay_start_rejected movementId=TEST.TM02.MOVEMENT.001 reason=spawn was already attempted
2026-07-17 16:14:36.211 INFO SCRIPTING: [OMW][TM02A] level=INFO event=red_relay_movement_status arrivalCredited=false destinationZoneMembership=false failureReason=none movementState=EN_ROUTE representationState=PHYSICAL routeAssigned=true runtimeGroupName=TM02A_RED_RELAY_001#001 survivorCount=6
```

## Failed or unproven acceptance criteria

- The runtime group was not proven to move through the route anchor.
- The complete living group was not proven to enter `ZONE_TM02A_DESTINATION`.
- No `red_relay_arrival_credited` event occurred.
- No `red_relay_arrived` event occurred.
- Destination garrison did not change from 6 to 12 in the recorded evidence.
- Final movement state remained unproven; the last sampled state was `EN_ROUTE`.

## Current diagnosis

The earlier stale-bundle condition is excluded: the latest run contains all three corrected route diagnostics. The controller constructed and submitted a three-point route without raising a TM02A error.

The remaining failure is therefore downstream of route construction and submission. The supplied log cannot distinguish among:

1. blocked or non-traversable source-zone egress, including FOB walls/static objects;
2. route-anchor or destination coordinates not connected to a usable ground path;
3. DCS ground-AI refusal to execute the handcrafted mixed `Off Road` / `On Road` route for the selected infantry types;
4. movement occurring too slowly or outside the sampled observation, although the operator reported no visible movement.

## Required next isolation test

Run one minimal geometry-control test before changing CampaignState:

1. place `ZONE_TM02A_SOURCE`, `ZONE_TM02A_ROUTE_01`, and `ZONE_TM02A_DESTINATION` on open, flat terrain with no walls, buildings, trees, steep slope, or narrow gate;
2. keep the same six-unit Late Activation template and corrected bundle;
3. place the route anchor directly on a clearly traversable road or open track;
4. observe the group for at least 60 seconds;
5. record whether the lead unit changes position;
6. invoke `Show active movement` after observation and archive the log.

If the group moves in the geometry-control mission, the defect is Mission Editor path geometry. If it remains stationary, replace the handcrafted waypoint route with MOOSE's dedicated ground-routing API in the next code revision.
