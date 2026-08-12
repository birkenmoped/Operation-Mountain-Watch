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

## Governance

- Read `docs/00-project-governance.md` before changing project authority, architecture, mission baselines, or acceptance status.
- Treat only `main` documents marked `BINDING_PROJECT_DECISION` or `BINDING` as repository-wide authority. A draft branch or branch-local PASS is limited to its documented branch, commit, mission, DCS, and MOOSE provenance.
- Do not mark a result `ACCEPTED_TECHNICAL_BASELINE` without the complete acceptance provenance required by `docs/DOCUMENT-METADATA-POLICY.md`.
- Do not change a pull request to Ready for Review, merge it, mutate a `.miz`, run a new DCS test, change a parking pool, or introduce a MOOSE override without the project owner's explicit authorization when the governing document records that action as blocked or approval-gated.
- Keep `docs/DOCUMENT-REGISTRY.md` and `docs/SUBPROJECT-REGISTRY.md` aligned with document IDs, paths, open pull requests, dependencies, and supersession state.

## MOOSE-first workflow

- Before writing project-specific Lua, check the MOOSE class documentation for the pinned branch/version, then the pinned source and official demo/test missions when needed.
- Prefer an existing MOOSE class, method, event, FSM callback, scheduler, set, wrapper, OPS class, zone, coordinate, warehouse, AIRWING, SQUADRON, AUFTRAG, or transport mechanism when it satisfies the requirement.
- Custom or native-DCS behavior that duplicates or bypasses MOOSE requires a documented gap analysis, the smallest viable extension, explicit owner approval, and reproducible testing.
- When a MOOSE module, class, method, event, or callback becomes relevant or is used, update `docs/moose/PROJECT-CLASS-INDEX.md` and the applicable topic document in the same change.
- Record practically confirmed methods in `docs/moose/VERIFIED-METHODS.md` with MOOSE branch/commit, OMW source path, limitations, and DCS test evidence. Use `VALIDATED` only after a documented DCS test.

## Documentation

- Follow `docs/DOCUMENT-METADATA-POLICY.md` for frontmatter, status, provenance, archive handling, and acceptance metadata.
- Do not leave `source_commit: PENDING_MERGE` on `main`; replace it with the exact source commit after integration.
- Preserve legacy source records and archived handoffs as historical evidence; they do not regain current authority through detail or age.
- Run `python3 tools/validate_documentation.py .` for documentation changes and review every warning as well as every error.

## Code and local-command handoff

- Present Lua source that the project owner must copy or inspect in fenced `lua` code blocks.
- Present every local Windows command sequence in fenced `powershell` code blocks. Do not use plain-text command fragments for owner handoff.
- On the project owner's Windows development machine, direct invocation such as `& .\tools\script.ps1` is blocked by the local PowerShell execution policy. Invoke repository `.ps1` builders through a child PowerShell process with an explicit process-local bypass, for example:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\build-example.ps1
```

- Do not ask the owner to change the machine-wide or user-wide PowerShell execution policy for OMW builds.
- After ChatGPT publishes the remote commit, owner handoff remains limited to numbered PowerShell steps for `git pull`, the official builder, and independent hash verification. The real console output and hashes returned by the owner are the only accepted local-build evidence.

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
5. Run the documentation validator when documentation, governance, registries, test Markdown, or documentation workflows change.
