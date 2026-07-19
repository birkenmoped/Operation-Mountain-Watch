# TM02W2F Initial Network Fill Acceptance

## Purpose

TM02W2F tests the initial population of all eleven RED network nodes through the
same bounded decision and execution model intended for the later RED Commander.
The plan starts with 112 personnel at `OMW_RED_HQ_Main`, retains 24 there, and
moves 88 personnel to the remaining ten nodes.

The plan still minimizes packet count and safe route distance, but physical
execution is no longer a twenty-group spawn burst.

## Accelerated commander test profile

The player starts a deliberately accelerated RED Commander from the F10 menu.
The required test profile is:

- planning interval: 30 seconds;
- command budget: four new transport orders per cycle;
- global active transport limit: eight;
- active transports on the same first network edge: two;
- minimum interval between executor releases: eight seconds;
- second transport on the same first edge requires 250 metres predecessor
  progress or expiry of a 45-second maximum hold.

Tasks transition through:

`PLANNED -> ORDERED -> QUEUED/LAUNCH_PENDING -> SPAWNING -> EN_ROUTE -> ARRIVED`

A command order and a physical spawn are separate operations. The Commander may
issue up to four orders in a cycle while the executor releases them individually
as traffic and capacity allow.

## Manual travelling-group representation

The F10 menu must provide two independent commands:

- `Alle Reise-Proxies entpacken`
- `Alle Reisegruppen packen`

The commands apply only to tasks whose movement state is `EN_ROUTE`. They must
not modify stationäre Garnisonen, planned orders, ordered tasks or queued tasks.

Unpacking replaces every eligible one-unit travelling proxy at its current
position with the complete group represented by that task. Packing performs the
reverse operation. Task ID, strength, current leg, target, remaining safe route,
Commander state and accounting must be preserved.

The player makes one manual decision. Internally, conversions are serialized at
0.75-second intervals so DCS never receives a same-frame mass spawn/destroy
burst.

## Required bootstrap result

- configuration version: `TM02W2F-red-commander-timeslice-4`;
- registry valid: true;
- planner valid: true;
- navigation valid: true;
- safe task paths: 20 / 20;
- executor valid: true;
- Commander scheduler valid: true;
- same-group route watchdog valid: true;
- transit representation valid: true;
- bootstrap phase: `READY`.

## Required planning result

- network nodes: 11;
- initial personnel: 112;
- retained at HQ: 24;
- reserved outbound: 88;
- reserved inbound: 88;
- task count: 20;
- maximum packet strength: 6;
- unresolved deficit: 0.

## Required Commander evidence

Expected events include:

- `accelerated_commander_started`;
- `commander_cycle_completed`;
- `transport_order_issued`;
- `transport_released_to_executor`;
- `transport_launch_observed`.

No Commander cycle may issue more than four orders. No more than eight physical
transports may be active globally. No more than two transports may occupy the
same first network edge.

Initial proxy creation events must be separated rather than emitted as a single
same-time burst.

## Required manual conversion evidence

At least one test cycle must execute both global commands while multiple tasks
are travelling.

Expected events:

- `serialized_transit_conversion_started` with `operation=UNPACK`;
- `travelling_proxy_unpacked`;
- `serialized_transit_conversion_completed` with `operation=UNPACK`;
- `serialized_transit_conversion_started` with `operation=PACK`;
- `travelling_group_packed`;
- `serialized_transit_conversion_completed` with `operation=PACK`.

For every successful global command:

- `errorCount=0`;
- conversions occur serially rather than in one simulation frame;
- no task changes target or current leg;
- no personnel appear or disappear;
- movement continues after conversion.

Tasks that arrive during a serialized conversion may be counted as skipped and
must not be converted after arrival.

## Recovery restriction

TM02W2F must not relocate a group and must not create a replacement group for
technical recovery.

The only permitted automatic recovery is reassignment of the remaining safe
route to the same existing DCS group.

Expected events:

- `route_reassignment_watchdog_started` with
  `engine=SAME_GROUP_REASSIGN_ONLY_1`;
- optional `same_group_route_reassigned`.

Hard FAIL events or conditions:

- `proxy_relocated_terminal_safe_path`;
- `proxy_relocated_along_safe_path`;
- aliases containing `_RECOVERY` or `_TERMINAL`;
- any automatic recovery spawn;
- `replacementSpawnCount` greater than zero.

At most three same-group route reassignments are allowed per task. Afterwards,
`navigation_blocked` is recorded without changing the transport's personnel
accounting. A later 100-metre route progress may clear that technical block.

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
