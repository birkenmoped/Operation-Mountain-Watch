# AGENTS.md

## Project

Operation Mountain Watch is a dynamic multiplayer COIN campaign for DCS World on the Afghanistan map.

## Language

- Source code, identifiers, logs, and commit messages: English.
- Design documentation: German.
- Player-facing text: German and English where practical.

## Architecture

- Use MOOSE as the primary DCS scripting framework.
- Prefer MOOSE CTLD and MOOSE CSAR.
- Do not add MIST unless a concrete dependency is documented in an ADR.
- `CampaignState` is the authoritative source for strategic state and resources.
- DCS groups are temporary physical representations of strategic entities.
- Do not let CampaignState, CTLD, MOOSE Warehouse, and DCS warehouses independently own the same resource.

## Lua conventions

- Avoid global variables; modules return tables.
- Use stable entity IDs independent of DCS group names.
- Validate DCS objects before accessing them.
- Log state transitions and failures with entity IDs.
- Do not run high-frequency schedulers without documented justification.
- Do not scan all world objects every simulation frame.
- Keep DCS/MOOSE adapters separate from campaign-domain logic where possible.

## DCS constraints

- Treat ground pathfinding as unreliable.
- Use validated routes, road anchors, assembly areas, and withdrawal points.
- Never teleport, spawn, or despawn units where players can reasonably observe the transition.
- Do not modify `MissionScripting.lua` automatically.
- Do not write outside the configured persistence directory.
- Do not claim a DCS or MOOSE behavior works until it is verified in-game or by current primary documentation.

## Verification

Before completing a change:

1. Run available Lua syntax checks and unit tests.
2. Review the complete diff.
3. State which behavior still requires an in-game DCS test.
4. Record test results for pathfinding, multiplayer synchronization, dynamic cargo, or AI behavior when relevant.
