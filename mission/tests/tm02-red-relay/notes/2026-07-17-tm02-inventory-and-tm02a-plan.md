# TM02 inventory and TM02A implementation plan

Date: 2026-07-17

## Verified starting point

```text
repository: birkenmoped/Operation-Mountain-Watch
base ref: feature/tm01b-convoy-caching
verified remote head: 218c62d42bad73d963a133dd271db781c8700d98
handoff present at head: yes
PR #8: open, draft, unmerged
RED branch: feature/tm02-red-side-foundation
initial RED PR base: feature/tm01b-convoy-caching
```

No RED implementation is added to PR #8. No merge is part of this work.

## Complete pre-existing TM02 inventory

At the verified base head, `mission/tests/tm02-red-relay/` contains exactly two files:

```text
README.md
config.lua
```

There are no pre-existing TM02 Lua controllers, source modules, build scripts,
distribution bundles, Mission Editor mission files, result records, or explicit
DCS acceptance contracts in that directory.

### README.md

The README defines the broader relay doctrine:

- six-fighter personnel packets;
- headquarters and relay-node minimum garrisons;
- direct predecessor/successor movement without node skipping;
- up to three simultaneous movements;
- TM02A as fully physical movement;
- TM02B as movement-only virtualization;
- a six-node chain ending at Bagram;
- three Late Activation template names and six node zones;
- a future dispatcher, route monitor, arrival accounting, and virtualization.

The README contains design acceptance criteria, but no recorded DCS execution or
accepted historical TM02 result.

### config.lua

The existing configuration describes the full six-node design and TM02B fields.
It includes:

- `RED_HQ` through `RED_TARGET_BAGRAM`;
- packet strength 6 and maximum active packets 3;
- physical and virtual speeds;
- reveal sections and virtualization settings;
- watchdog/report-only stuck detection;
- exclusions for warehouses, persistence, recruitment, hostile forces, and other systems.

The configuration does not identify a tested Mission Editor mission, a validated
route, a DCS country, exact infantry unit types, a runtime controller, a build,
or a DCS result.

## Differences from the 2026-07-17 handoff

The handoff is narrower and more authoritative for the first executable step.
The relevant differences are:

1. The old README calls the complete multi-node physical chain "TM02A". The
   handoff redefines the smallest safe first milestone as one manual physical
   transfer between two directly adjacent nodes.
2. The old configuration permits three active movements. The first milestone
   permits exactly one movement and consumes exactly one manual start command.
3. The old configuration includes TM02B virtualization and reveal-zone data.
   The first milestone has no virtual representation at all.
4. The old design explicitly excludes CampaignState integration. The handoff
   requires CampaignState to be authoritative before the first spawn.
5. The old design has no transaction/idempotency implementation. The first
   milestone reserves six fighters atomically and rejects repeated execution.
6. The old design has no code, build, structured runtime proof, or F10 contract.
   These are required for the first implementation.
7. The old design does not provide a historical DCS pass. No TM02 behavior may
   be treated as DCS-proven before the new acceptance run.

The broad `config.lua` and README remain as design history. TM02A uses a new
separate `config-tm02a.lua` so the larger design is not silently overwritten.

## Architecture constraints applied

- CampaignState owns node personnel and movement identity.
- DCS and MOOSE groups are runtime representations only.
- Reservation happens before physical spawn.
- A movement is never simultaneously virtual and physical.
- TM02A contains no virtual state transition.
- Survivor count can only stay equal or decrease.
- Arrival credit is idempotent and occurs once.
- A failed spawn or route remains visible as `FAILED`; no automatic rollback,
  respawn, teleport, unstuck, or reroute is performed.
- The controller reads no BLUE warehouse, BLUE trigger, or hidden BLUE mission data.
- MOOSE remains pinned to release 2.9.18 and the vendored readable `Moose.lua`.
- Persistence to disk is not part of TM02A; the authoritative CampaignState is
  intentionally in memory for this vertical test.

## Smallest safe TM02A milestone

Initial domain state:

```text
source node:      24 alive, minimum 18, surplus 6
destination node: 6 alive, minimum 12, surplus 0
movement packet:  6 fighters
active slots:      1
```

Controlled flow:

1. Validate required MOOSE APIs and Mission Editor objects.
2. Register the two nodes in the in-memory CampaignState.
3. Verify that the destination is the source node's direct successor.
4. Reserve exactly six fighters and reduce the source from 24 to 18.
5. Create exactly one physical six-unit runtime group from a Late Activation template.
6. Verify runtime name, alive count, source-zone membership, and inactive template.
7. Assign one deterministic MOOSE ground route through one validated anchor to the destination.
8. Reconcile survivor count when the operator selects `Show active movement`.
9. When the complete living group is inside the destination zone, credit survivors exactly once.
10. Keep the arrived physical group in place as the destination-node representation
    for the remainder of the acceptance run.

The terminal movement record is history after credit. Personnel accounting counts
terminal survivors at the destination node, not a second time as an active packet.

## Implemented files

```text
mission/tests/tm02-red-relay/config-tm02a.lua
mission/tests/tm02-red-relay/src/in_memory_red_campaign_state.lua
mission/tests/tm02-red-relay/src/physical_relay_controller.lua
mission/tests/tm02-red-relay/src/tm02a_menu.lua
mission/tests/tm02-red-relay/src/tm02a.lua
mission/tests/tm02-red-relay/dist/TM02A.lua
mission/tests/tm02-red-relay/expected/tm02a-physical-relay-acceptance.md
tools/build-tm02a-bundle.ps1
```

## Required Mission Editor objects

```text
TPL_TEST_RED_PACKET_06_01
ZONE_TM02A_SOURCE
ZONE_TM02A_ROUTE_01
ZONE_TM02A_DESTINATION
```

Template contract:

- RED coalition;
- one ground infantry group with exactly six living units;
- Late Activation enabled;
- no initial route or autonomous task required;
- template placed outside the active test corridor or otherwise kept inactive;
- a single country and unit composition chosen consistently for the test mission.

The code intentionally does not hard-code a DCS country or infantry type. The
repository did not contain a previously accepted TM02 nation/template contract.
The selected country and exact unit types must be recorded with the first DCS result.

Zone contract:

- source and destination zones must fully contain the six-unit group at spawn/arrival;
- the route anchor center must lie on a physically traversable, validated path;
- source and destination are directly adjacent in the TM02A domain graph;
- no hidden BLUE zone or warehouse data is read by the controller.

## First DCS acceptance

The first acceptance is the no-loss, one-transfer baseline defined in
`expected/tm02a-physical-relay-acceptance.md`.

It proves reservation, minimum-garrison protection, one physical group, direct
successor routing, duplicate-command rejection, arrival, exactly-once credit,
and CampaignState/physical consistency. Deliberate casualty injection is a
separate regression after this baseline because the repository currently has no
accepted method for deterministically damaging one member of a dynamically named
infantry group without adding unrelated combat logic.
