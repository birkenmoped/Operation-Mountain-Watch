# AGENTS.md

## Project

Operation Mountain Watch is a dynamic multiplayer COIN campaign for DCS World on the Afghanistan map.

## Language

- Source code, identifiers, logs, and commit messages: English.
- Design documentation: German.
- Player-facing text: German and English where practical.

## Binding implementation governance

- `docs/00-project-governance.md` is binding and has precedence over older or more specific documentation.
- Operation Mountain Watch is MOOSE-first.
- Identify, evaluate, and use all available and applicable MOOSE capabilities before proposing native DCS scripting, custom project code, or a hybrid fallback.
- A technical discussion of MOOSE limitations or disadvantages does not authorize a non-MOOSE implementation.
- Only the project owner may approve bypassing, replacing, or supplementing an applicable MOOSE capability with native DCS or custom code.
- Before requesting such approval, document the requirement, MOOSE capabilities evaluated, test evidence, precise limitation, proposed fallback, and lifecycle, persistence, performance, maintenance, compatibility, and testing impact.
- Until explicit project-owner approval exists, non-MOOSE work is exploratory only and must not be presented as the accepted implementation direction.
- Every approved exception must be recorded in an ADR or equivalently explicit decision document.

## Architecture

- Use MOOSE as the mandatory DCS scripting foundation.
- Prefer MOOSE CTLD and MOOSE CSAR.
- Do not add MIST unless a concrete dependency is documented in an ADR and explicitly approved by the project owner under GOV-001.
- `CampaignState` is the authoritative source for strategic state and resources.
- DCS groups are temporary physical representations of strategic entities.
- Do not let CampaignState, CTLD, MOOSE Warehouse, and DCS warehouses independently own the same resource.

## MOOSE dependency

- Use the pinned MOOSE release recorded in `vendor/moose/VERSION.md`.
- The initial selected baseline is release `2.9.18` from the `master-ng` release family.
- Use the static readable include at `vendor/moose/Moose.lua`.
- Preserve the exact upstream filename and case: `Moose.lua`.
- Load MOOSE before all project scripts that reference MOOSE classes.
- Load exactly one MOOSE include file in a mission.
- Do not load `Moose.lua` and `Moose_.lua` together.
- Do not use `Moose_Include_Dynamic` for mission runtime.
- Do not depend on an unpinned `master-ng` or `develop` branch.
- A development-branch exception requires a separate ADR, an exact full commit SHA, and explicit project-owner approval.
- Do not edit vendored MOOSE source files.
- Verify every MOOSE API against the vendored source or matching stable documentation.
- Do not use develop-branch documentation as the sole evidence for release behavior.
- A MOOSE version or build-variant update requires all relevant MOOSE test missions to be rerun.

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
5. Confirm that the configured MOOSE version and include variant match `vendor/moose/VERSION.md`.
6. Confirm that the implementation follows GOV-001 or references an explicit project-owner-approved exception.
