# Jalalabad Phase 1 package contract

Status: implemented in `JBAD-AIR-OPS-PHASE1-9`; DCS validation pending.

This file is the binding package model for the deterministic Phase-1 tests and the later dynamic request layer.

Authoritative background, complete incident history and mandatory regression rules:

- `docs/27-jalalabad-air-operations-phase1-postmortem-and-guardrails.md`
- `docs/28-jalalabad-air-operations-development-incident-log.md`
- `mission/tests/jalalabad-air-operations/expected/jalalabad-phase1-architecture-regression-checklist.md`
- `mission/tests/jalalabad-air-operations/results/2026-07-25-jalalabad-phase1-uh60-intermediate-landing-despawn-fail.md`

In case of contradiction, the central package contract in Lua and the stricter rule in the documents above apply. No later source file may silently redefine the package model.

| Squadron/test | Mission Editor template | Physical DCS group | Required MOOSE asset groups | Aircraft | Runtime unit names |
|---|---:|---:|---:|---:|---|
| OH-58D RECON | 2 aircraft | one physical two-ship | 1 | 2 | `<group>-01`, `<group>-02` |
| AH-64D CAS | 2 aircraft | one physical two-ship | 1 | 2 | `<group>-01`, `<group>-02` |
| UH-60 troop test | 1 lead aircraft | one single-ship | 1 | 1 | `<group>-01` |
| UH-60 MEDEVAC production package | separate lead and guard templates | two independent single-ship groups | 2 | 2 | one exact unit per group |
| CH-47 cargo | 1 aircraft | one single-ship | 1 | 1 | `<group>-01` |

## Non-negotiable rules

- `SQUADRON:New(template, Nassets, name)` receives the number of MOOSE asset groups, not the number of individual aircraft.
- The Jalalabad constructor counts are therefore `OH58D=12`, `AH64D=4`, `UH60=8`, `CH47=8`.
- `SQUADRON:SetGrouping()` must equal the physical group size defined here.
- A two-aircraft template must not be converted into two unrelated single-ship groups.
- `AUFTRAG:SetRequiredAssets()` counts physical MOOSE asset groups, not aircraft.
- Runtime event counting counts aircraft by exact unit name and groups by exact group name.
- Inventory readiness counts the actual entries in `squadron.assets` and must equal the constructor asset-group count.
- Package arithmetic must always hold: `AssetGroups * Grouping = InventoryAircraft` and `RequiredGroups * Grouping = RequiredAircraft`.
- The current UH-60 troop transport test validates one transport lead. It is not the later full MEDEVAC lead/guard package test.
- UH-60 transport and MEDEVAC assets must remain alive through operational pickup and drop-off landings; squadron-wide despawn after every landing is prohibited.
- Final UH-60 despawn may be armed only after native MOOSE unloading has completed and must occur on the subsequent final RTB landing.
- Pickup is proven by an observed pickup landing plus native MOOSE `LoadingDone`; disappearance or movement of the troop group is not proof of boarding.
- Drop-off is proven by an observed drop-off landing, native MOOSE `Unloaded` and `UnloadingDone`, and the living troop group inside the dedicated drop-off zone.
- A final base landing is identified by the actual Jalalabad airbase identity in the DCS event; a broad distance radius is insufficient.
- A native terminal state before verified drop-off is a hard transport failure.
- MOOSE templates, dynamic AIRWING spawns, visible statics, Client groups and logical inventory are separate layers.
- A routing, landing, despawn or test-controller defect must not be “fixed” by changing the tactical package model.
- Hard range or fuel limits require a documented physical or empirical basis; otherwise they are advisory telemetry only.
- A test-specific readiness failure must not block unrelated package tests.
- DCS runtime PASS requires DCS runtime evidence; syntax, bundle generation and static checks are insufficient.

## Phase-1 acceptance order

1. OH-58D physical two-ship RECON and explicit recovery corridor.
2. AH-64D physical two-ship CAS, common return and two-aircraft landing accounting.
3. UH-60 single-ship troop transport with complete native pickup/unload lifecycle and intermediate-landings survival.
4. CH-47 single-ship cargo transport.
5. UH-60 reservation/abort release.
6. Full sequence only after all isolated tests pass.
7. Full UH-60 MEDEVAC lead/guard coordination as a separate later milestone.

The dynamic player-request layer may only consume these package contracts after the deterministic tests pass in DCS.
