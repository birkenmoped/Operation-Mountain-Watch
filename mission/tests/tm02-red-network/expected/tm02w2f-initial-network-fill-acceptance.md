# TM02W2F Initial Network Fill Acceptance

## Purpose

TM02W2F stress-tests the initial population of all eleven RED network nodes.
The plan starts with 112 personnel at `OMW_RED_HQ_Main`, retains 24 there,
and moves 88 personnel to the remaining ten nodes.

The optimization order is:

1. minimum completion time by releasing all twenty minimal packet tasks concurrently;
2. minimum task count by using packet strength six whenever possible;
3. minimum safe route distance through the validated W1 movement graph.

## Manual travelling-group representation

The F10 menu must provide two independent commands:

- `Alle Reise-Proxies entpacken`
- `Alle Reisegruppen packen`

The commands apply only to tasks whose movement state is `EN_ROUTE`.
They must not modify stationary garrisons or queued tasks.

Unpacking replaces every eligible one-unit travelling proxy at its current
position with the complete group represented by that task. Packing replaces
every eligible complete travelling group at its current position with a
one-unit proxy. In both directions the task ID, strength, current leg, target,
remaining safe route and accounting state must be preserved.

Repeated use is allowed. A command with no eligible groups is a successful
no-op.

## Required bootstrap result

- configuration version: `TM02W2F-red-initial-network-fill-3`
- registry valid: true
- planner valid: true
- navigation valid: true
- safe task paths: 20 / 20
- executor valid: true
- transit representation valid: true
- bootstrap phase: `READY`

## Required planning result

- network nodes: 11
- initial personnel: 112
- retained at HQ: 24
- reserved outbound: 88
- reserved inbound: 88
- task count: 20
- maximum packet strength: 6
- unresolved deficit: 0

## Required manual conversion evidence

At least one test cycle must execute both global commands while multiple tasks
are travelling.

Expected events:

- `all_travelling_proxies_unpacked`
- `travelling_proxy_unpacked`
- `all_travelling_groups_packed`
- `travelling_group_packed`

For every successful global command:

- `convertedCount` equals `eligibleCount`;
- `errorCount=0`;
- no task changes target or current leg;
- no personnel appear or disappear;
- movement continues after conversion.

## Navigation restriction

`proxy_relocated_terminal_safe_path` is forbidden in TM02W2F. Any occurrence
is a hard FAIL, even if the final accounting is correct.

The inherited watchdog is configured with only 20-metre recovery increments
for this test. Manual representation changes themselves must not advance a
task along its route.

## Required final result

- task count: 20
- arrived task count: 20
- destroyed task count: 0
- failed task count: 0
- current personnel: 112
- in-transit personnel: 0
- total losses: 0
- accounted personnel: 112
- accounting valid: true
- remaining reserved inbound: 0
- remaining reserved outbound: 0
- expected inventory match: true
- execution complete: true

Final node strengths must equal the configured target map:

- HQ Main: 24
- SUBHQ Left: 10
- SUBHQ Right: 10
- Central 01: 8
- Central 02: 8
- Central 03: 10
- Central 04: 10
- Left 01: 8
- Left 02: 8
- Right 01: 8
- Right 02: 8
