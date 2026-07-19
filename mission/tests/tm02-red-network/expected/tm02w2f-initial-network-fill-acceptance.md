# TM02W2F Initial Network Fill Acceptance

## Purpose

TM02W2F tests the initial population of all eleven RED network nodes through a
bounded RED Commander decision model while keeping physical infantry movement
separate from the strategic network plan.

The plan starts with 112 personnel at `OMW_RED_HQ_Main`, retains 24 there, and
moves 88 personnel to the remaining ten nodes in twenty packets.

## Movement model

The RED network determines only the strategic sequence of nodes. It does not
determine a road route.

For every physical leg DCS receives exactly two ground waypoints:

1. the group's current position;
2. the centre of the next strategic RED node.

The formation is `Off Road`. Normal movement must not use roads, road snapping,
road polylines, sampled road points or automatic recovery.

A strategic movement edge is unavailable when the direct line between its RED
nodes intersects a BLUE objective zone plus the configured 250-metre buffer.
MOOSE ASTAR selects a strategic path using only the remaining safe RED-network
edges.

## Canary-gated commander profile

The player starts the test from the F10 menu. The required accelerated profile
is:

- planning interval: 30 seconds;
- command budget: four new orders per cycle;
- global active transport limit: four;
- active transports on the same first network edge: two;
- minimum interval between executor releases: 10 seconds;
- a same-edge predecessor must have at least 150 metres real displacement;
- the first released transport is the Canary;
- the Canary must prove at least 75 metres real displacement within 120 seconds.

Before the Canary passes, no second transport may be released. If the Canary
does not pass, the Commander stops releasing transports and leaves only that
single group available for diagnosis.

Tasks transition through:

`PLANNED -> ORDERED -> QUEUED/LAUNCH_PENDING -> SPAWNING -> EN_ROUTE -> ARRIVED`

All repeating timers must schedule from the current mission time. Returning a
past-due `scheduledTime + interval` value is forbidden.

## Manual travelling-group representation

The F10 menu provides two independent commands:

- `Alle Reise-Proxies entpacken`
- `Alle Reisegruppen packen`

The commands apply only to tasks whose movement state is `EN_ROUTE`. They do not
modify stationary garrisons or planned, ordered or queued tasks.

Unpacking replaces each eligible one-unit travelling proxy at its current
position with the complete group represented by that task. Packing performs the
reverse operation. Task ID, strength, current leg, target, Commander state and
accounting must be preserved.

After every manual conversion, the replacement representation receives exactly
two new `Off Road` waypoints: its current position and its current strategic
leg destination. The player issues one command; conversions are serialized at
one-second intervals.

## Required bootstrap result

- configuration version: `TM02W2F-red-direct-offroad-canary-5`;
- registry valid: true;
- planner valid: true;
- direct off-road navigation valid: true;
- safe task paths: 20 / 20;
- executor valid: true;
- Commander scheduler valid: true;
- transit representation valid: true;
- bootstrap phase: `READY`.

Expected navigation evidence includes:

- `direct_offroad_edge_compiled`;
- `direct_offroad_task_path_selected`;
- `direct_offroad_navigation_validation` with:
  - `valid=true`;
  - `maximumPhysicalWaypointsPerLeg=2`;
  - `roadsUsed=false`;
  - `automaticRecoveryEnabled=false`.

## Required planning result

- network nodes: 11;
- initial personnel: 112;
- retained at HQ: 24;
- reserved outbound: 88;
- reserved inbound: 88;
- task count: 20;
- maximum packet strength: 6;
- unresolved deficit: 0.

## Required Canary evidence

Expected events:

- `direct_offroad_commander_started`;
- exactly one initial `transport_released_to_executor` with `canary=true`;
- one `red_task_proxy_started` before Canary completion;
- `canary_passed` after at least 75 metres displacement.

Before `canary_passed`, there must be no second `red_task_proxy_started` event.

If `canary_failed` occurs, the run stops as a controlled FAIL and no additional
transport may spawn.

## Required Commander evidence after Canary PASS

Expected events include:

- `commander_cycle_completed`;
- `transport_order_issued`;
- `transport_released_to_executor`;
- `transport_launch_observed`.

No Commander cycle may issue more than four orders. No more than four physical
transports may be active globally. No more than two transports may occupy the
same first strategic network edge.

Physical spawn releases must normally be separated by at least ten seconds.
The second transport on a shared first edge must not release before its
predecessor has at least 150 metres real displacement.

## Required manual conversion evidence

At least one test cycle executes both global commands while multiple tasks are
travelling.

Expected events:

- `serialized_transit_conversion_started` with `operation=UNPACK`;
- `transit_direct_route_assigned` with `waypointCount=2`;
- `travelling_proxy_unpacked`;
- `serialized_transit_conversion_completed` with `operation=UNPACK`;
- `serialized_transit_conversion_started` with `operation=PACK`;
- `transit_direct_route_assigned` with `waypointCount=2`;
- `travelling_group_packed`;
- `serialized_transit_conversion_completed` with `operation=PACK`.

For every successful global command:

- `errorCount=0`;
- conversions occur serially rather than in one simulation frame;
- no task changes target or current leg;
- no personnel appear or disappear;
- movement continues after conversion.

## Hard FAIL conditions

Any of the following is a hard FAIL:

- `CREATING PATH MAKES TOO LONG`;
- more than two physical waypoints assigned to a normal leg;
- any normal route with `On Road` formation;
- any road snapping or road-polyline compilation;
- `proxy_relocated_terminal_safe_path`;
- `proxy_relocated_along_safe_path`;
- `proxy_relocated_on_safe_path`;
- aliases containing `_RECOVERY` or `_TERMINAL`;
- any automatic recovery spawn or destroy operation;
- more than one proxy spawn before Canary PASS;
- any repeating timer catch-up storm;
- DCS failing to return cleanly from the mission.

## Required final result

- task count: 20;
- arrived task count: 20;
- destroyed task count: 0;
- failed task count: 0;
- current personnel: 112;
- in-transit personnel: 0;
- total losses: 0;
- accounted personnel: 112;
- accounting valid: true;
- remaining reserved inbound: 0;
- remaining reserved outbound: 0;
- expected inventory match: true;
- execution complete: true.

Final node strengths must equal the configured target map:

- HQ Main: 24;
- SUBHQ Left: 10;
- SUBHQ Right: 10;
- Central 01: 8;
- Central 02: 8;
- Central 03: 10;
- Central 04: 10;
- Left 01: 8;
- Left 02: 8;
- Right 01: 8;
- Right 02: 8.
