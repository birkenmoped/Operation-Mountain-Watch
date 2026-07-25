# Jalalabad Phase 1 package contract

Status: implemented in `JBAD-AIR-OPS-PHASE1-11-MOOSE-FIRST`; local build and DCS validation pending.

This file is the binding package model for the deterministic Phase-1 tests and the later dynamic request layer.

Authoritative background, implementation and mandatory regression rules:

- `docs/27-jalalabad-air-operations-phase1-postmortem-and-guardrails.md`
- `docs/28-jalalabad-air-operations-development-incident-log.md`
- `docs/29-jalalabad-air-operations-moose-code-review.md`
- `docs/31-jalalabad-air-operations-moose-first-refactor-implementation.md`
- `mission/tests/jalalabad-air-operations/expected/jalalabad-phase1-architecture-regression-checklist.md`
- `mission/tests/jalalabad-air-operations/expected/jalalabad-phase1-moose-first-refactor-acceptance.md`
- `mission/tests/jalalabad-air-operations/results/2026-07-25-jalalabad-phase1-moose-first-refactor-implemented.md`

In case of contradiction, the central package contract in Lua and the stricter rule in the documents above apply. No later source file may silently redefine the package model.

| Squadron/test | Mission Editor template | Physical DCS group | Required MOOSE asset groups | Aircraft | Native operation authority |
|---|---:|---:|---:|---:|---|
| OH-58D RECON | 2 aircraft | one physical two-ship | 1 | 2 | AUFTRAG |
| AH-64D CAS | 2 aircraft | one physical two-ship | 1 | 2 | AUFTRAG |
| UH-60 troop test | 1 lead aircraft | one single-ship | 1 | 1 | OPSTRANSPORT |
| UH-60 MEDEVAC production package | separate lead and guard templates | two independent single-ship groups | 2 | 2 | coordinated AUFTRAG/OPSTRANSPORT package |
| CH-47 static sling cargo | 1 aircraft | one single-ship | 1 | 1 | AUFTRAG CARGOTRANSPORT |
| CH-47 group/storage logistics | 1 aircraft per group | one or more single-ships | contract-dependent | contract-dependent | OPSTRANSPORT |

## Non-negotiable package rules

- `SQUADRON:New(template, Nassets, name)` receives the number of MOOSE asset groups, not the number of individual aircraft.
- The Jalalabad constructor counts are `OH58D=12`, `AH64D=4`, `UH60=8`, `CH47=8`.
- `SQUADRON:SetGrouping()` must equal the physical group size defined here.
- A two-aircraft template must not be converted into two unrelated single-ship groups.
- `AUFTRAG:SetRequiredAssets()` counts physical MOOSE asset groups, not aircraft.
- Package arithmetic must hold: `AssetGroups * Grouping = InventoryAircraft` and `RequiredGroups * Grouping = RequiredAircraft`.
- Runtime names are assertions against the package contract, not the primary means of finding MOOSE runtime objects.
- The current UH-60 troop transport test validates one transport lead. It is not the later full MEDEVAC lead/guard package test.
- MOOSE templates, dynamic AIRWING spawns, visible statics, Client groups and logical inventory are separate layers.
- A routing, landing, despawn or test-controller defect must not be fixed by changing the tactical package model.

## MOOSE-first authority rules

- Mission Queue status comes from `AIRWING:CountMissionsInQueue()`.
- Asset counts come from `SQUADRON:CountAssets()` and `AIRWING:CountAssetsOnMission()`.
- AUFTRAG assets are bound through `AIRWING:OnAfterFlightOnMission()`.
- OPSTRANSPORT carriers are bound through `OPSTRANSPORT:GetCarriers()` and native transport callbacks.
- Operative success/failure/cancellation remains with AUFTRAG or OPSTRANSPORT.
- The OMW controller may classify the test but must not rewrite the native operational state.
- No direct access to `squadron.assets`, `missionqueue`, `mission.groupdata`, `opsgroup.groupname`, `opsgroup.group` or `_DATABASE.Templates.Groups` is allowed in the canonical runtime.

## Native logistics rules

### Group and vehicle cargo

Required native events:

```text
OPSTRANSPORT Loaded
carrier LoadingDone
OPSTRANSPORT Unloaded
carrier UnloadingDone
OPSTRANSPORT Delivered
```

Additional physical acceptance:

- pickup landing inside the configured pickup zone;
- exact cargo identity;
- deploy landing inside the configured deploy zone;
- living cargo in the deploy zone;
- delivered cargo count equals total cargo count.

### Storage cargo

Fuel, weapons and equipment use:

```text
OPSTRANSPORT:AddCargoStorage
LEGION.RecruitCohortAssets
AIRWING:TransportAssign
```

Carrier selection may specify UH-60, CH-47 or another capable SQUADRON. Cargo mass and total mass are passed to MOOSE recruitment.

### Static sling cargo

Static sling cargo uses native `AUFTRAG:NewCARGOTRANSPORT`. OPSTRANSPORT group-cargo events are not fabricated for static payloads. Native AUFTRAG success plus physical Static-in-drop-zone confirmation is required.

### Dynamic cargo

DCS Dynamic Cargo uses MOOSE events:

```text
DynamicCargoLoaded
DynamicCargoUnloaded
DynamicCargoRemoved
```

## Despawn rule

- UH-60 and CH-47 leave squadron-wide `SetDespawnAfterLanding` unset.
- `SQUADRON:SetDespawnAfterLanding(false)` is prohibited because the pinned MOOSE implementation enables despawn for `false`.
- The exact FLIGHTGROUP may receive `SetDespawnAfterLanding()` only after native cargo delivery and independent physical objective confirmation.
- Pickup and deploy landings must never trigger final despawn.

## Phase-1 acceptance order

1. UH-60 native OPSTRANSPORT group-cargo flow and intermediate-landings survival.
2. CH-47 native static sling CARGOTRANSPORT.
3. OH-58D physical two-ship RECON and explicit recovery corridor.
4. AH-64D physical two-ship CAS, common return and two-aircraft landing accounting.
5. UH-60 reservation/abort release.
6. Full sequence only after all isolated tests pass.
7. Full UH-60 MEDEVAC lead/guard coordination as a separate later milestone.

The dynamic player-request layer may only consume these package and logistics contracts after the deterministic tests pass in DCS.
