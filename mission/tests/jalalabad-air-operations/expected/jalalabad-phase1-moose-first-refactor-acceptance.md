# Jalalabad Phase 1 – MOOSE-first Refactoring Acceptance Contract

Status: **IMPLEMENTED / LOCAL BUILD AND DCS VALIDATION PENDING**  
BuilderVersion: `JBAD-AIR-OPS-PHASE1-11-MOOSE-FIRST`  
Review source: `docs/29-jalalabad-air-operations-moose-code-review.md`  
Implementation: `docs/31-jalalabad-air-operations-moose-first-refactor-implementation.md`

## 1. Scope

This contract is the mandatory architecture before:

- copying the node to another airfield;
- adding dynamic player-request tasking;
- implementing the full UH-60 MEDEVAC lead/guard package;
- treating the Phase-1 harness as production mission code.

The repository implementation is complete. Runtime acceptance remains open until the local build and DCS tests pass.

## 2. Public MOOSE API gate

Forbidden in the canonical runtime:

```text
squadron.assets
cfg.Airwing.missionqueue
mission.groupdata
opsgroup.groupname
opsgroup.group
_DATABASE.Templates.Groups
```

Required public replacements:

```text
SQUADRON:CountAssets
AIRWING:CountAssetsOnMission
AIRWING:CountMissionsInQueue
AIRWING:OnAfterFlightOnMission
OPSTRANSPORT:GetCarriers
GROUP:GetTemplate
GROUP:GetTemplateRoutePoints
FLIGHTGROUP/OPSGROUP callbacks and state queries
```

Acceptance:

- [x] no canonical runtime dependence on the forbidden private containers;
- [x] public API behavior replaces field introspection;
- [x] builder rejects reintroduction of the forbidden patterns;
- [x] pinned MOOSE commit is recorded in the bundle header;
- [ ] locally built bundle passes all static builder gates.

## 3. Native operational authorities

### AUFTRAG

AUFTRAG is the operational authority for RECON, CAS, static sling cargo, freight and abort missions.

- [x] physical success uses `AUFTRAG:AddConditionSuccess` where applicable;
- [x] native AUFTRAG callbacks provide the mission-state timeline;
- [x] no second custom SUCCESS/FAILED/CANCELLED/DONE mission FSM;
- [x] no post-hoc terminal-state normalization;
- [x] required SQUADRON and payload use public AUFTRAG methods;
- [ ] isolated DCS AUFTRAG tests pass.

### OPSTRANSPORT

OPSTRANSPORT is the operational authority for group, vehicle and storage logistics.

- [x] group transport uses `OPSTRANSPORT:New`;
- [x] storage logistics uses `OPSTRANSPORT:AddCargoStorage`;
- [x] carrier requirements use `SetRequiredCarriers`;
- [x] exact carrier SQUADRON recruitment uses `LEGION.RecruitCohortAssets`;
- [x] generic fallback uses `AIRWING:RecruitAssetsForTransport`;
- [x] assignment uses `AIRWING:TransportAssign`;
- [x] cancellation uses `AIRWING:TransportCancel`;
- [ ] isolated DCS OPSTRANSPORT tests pass.

The acceptance harness may classify a DCS run after observing MOOSE, but it must not rewrite the operational state.

## 4. Object-bound lifecycle

Required after MOOSE assigns an asset:

- [x] exact FLIGHTGROUP reference is obtained from `AIRWING:OnAfterFlightOnMission` or `OPSTRANSPORT:GetCarriers`;
- [x] callbacks are attached once to that concrete object;
- [x] runtime names remain assertions, not the primary object locator;
- [x] DCS Engine/Takeoff/Land/Shutdown/Loss events are scoped to the already-bound GROUP;
- [x] final Jalalabad landing compares actual event Place identity;
- [x] no global type-only/provisional event ownership remains;
- [ ] DCS logs confirm no missed early events.

## 5. Generic native logistics lifecycle

### 5.1 GROUP_CARGO

Required MOOSE evidence:

- [x] `OPSTRANSPORT:OnAfterLoaded` records the exact cargo and carrier;
- [x] carrier `OnAfterLoadingDone` is recorded;
- [x] `OPSTRANSPORT:OnAfterUnloaded` records the exact cargo and carrier;
- [x] carrier `OnAfterUnloadingDone` is recorded;
- [x] `OPSTRANSPORT:OnAfterDelivered` is the native terminal authority;
- [x] `GetNcargoDelivered() == GetNcargoTotal()` is required;
- [ ] DCS confirms the complete sequence.

Independent physical acceptance:

- [x] pickup landing must be inside the configured pickup zone;
- [x] drop-off landing must be inside the configured deploy zone;
- [x] exact cargo identity is checked;
- [x] cargo must be alive in the deploy zone;
- [x] cargo disappearance or distance alone is not proof of loading;
- [ ] UH-60 group-cargo DCS test passes.

### 5.2 STORAGE_CARGO

- [x] fuel, weapons and equipment use `AddCargoStorage`;
- [x] item weight and total cargo weight are passed to MOOSE recruitment;
- [x] carrier SQUADRON can be selected by contract;
- [x] optional `VerifyDelivered` callback may verify warehouse inventory without controlling transport execution;
- [ ] first concrete STORAGE_CARGO mission and DCS test are still pending.

### 5.3 STATIC_SLING_CARGO

- [x] static sling cargo remains native `AUFTRAG:NewCARGOTRANSPORT`;
- [x] no artificial OPSTRANSPORT group-cargo events are invented for a Static;
- [x] native AUFTRAG success and physical Static-in-drop-zone are both required;
- [ ] CH-47 DCS regression test passes.

### 5.4 STATIC_FREIGHT_CARGO

- [x] contract reserves native AUFTRAG FREIGHTTRANSPORT authority;
- [ ] concrete freight object and test mission are not yet defined.

### 5.5 DYNAMIC_CARGO

- [x] MOOSE `DynamicCargoLoaded` is observed;
- [x] MOOSE `DynamicCargoUnloaded` is observed;
- [x] MOOSE `DynamicCargoRemoved` is observed;
- [ ] concrete DCS Dynamic Cargo scenario is not yet defined.

## 6. Intermediate landing and final despawn

Pinned-MOOSE fact:

```text
SQUADRON:SetDespawnAfterLanding(false)
sets despawnAfterLanding=true in the pinned version.
```

Acceptance:

- [x] UH-60 squadron-wide despawn setter is omitted;
- [x] CH-47 squadron-wide despawn setter is omitted;
- [x] builder rejects a real `SetDespawnAfterLanding(false)` call;
- [x] final despawn is armed on the exact FLIGHTGROUP only after native delivery plus physical objective confirmation;
- [ ] UH-60 survives pickup landing;
- [ ] UH-60 survives deploy landing;
- [ ] CH-47 survives every operational intermediate landing required by its logistics profile;
- [ ] final RTB landing performs the intended despawn and stock return.

## 7. Package model invariants

```text
OH58D: 12 asset groups × grouping 2 = 24 aircraft
AH64D:  4 asset groups × grouping 2 =  8 aircraft
UH60:   8 asset groups × grouping 1 =  8 aircraft
CH47:   8 asset groups × grouping 1 =  8 aircraft
```

- [x] package contract remains the single source for inventory and grouping;
- [x] no lifecycle fix changes a physical group model;
- [x] OH-58D and AH-64D remain physical two-ships;
- [x] UH-60 remains single-ship assets;
- [x] CH-47 remains a physical single-ship;
- [ ] all package models pass DCS runtime validation.

## 8. Override-chain removal

Removed:

```text
14a-phase1-lifecycle-corrections.lua
14b-phase1-sequence-finalization.lua
16-phase1-moose-compatibility.lua
17-phase1-operational-safety.lua
18-phase1-readiness-and-recon-telemetry.lua
19-phase1-oh58-formation-recovery-counting.lua
20-phase1-uh60-transport-lifecycle.lua
```

Target state:

- [x] no chained method replacement across the removed sources;
- [x] one mission/transport factory;
- [x] one acceptance observer;
- [x] one generic logistics adapter;
- [x] one small dispatch/watchdog/acceptance controller;
- [x] one readiness/routing/telemetry module;
- [x] builder order is no longer a hidden override mechanism;
- [x] no new corrective monkey-patch source was added.

## 9. Polling policy

Polling remains allowed only for:

- bounded timeout watchdog;
- periodic fuel telemetry;
- final inventory-release stability confirmation;
- independent physical objective checks.

Polling is not the primary source for:

- [x] AUFTRAG mission state;
- [x] OPSTRANSPORT state;
- [x] cargo loaded/unloaded/delivered state;
- [x] mission queue size;
- [x] asset counts;
- [x] FLIGHTGROUP ownership.

## 10. Custom code that remains valid

The refactor preserves these project-owned responsibilities:

- ORBAT and package contracts;
- Mission Editor naming contracts;
- Jalalabad parking and static reservations;
- client-slot protection;
- terrain and corridor acceptance;
- exact runtime test invariants;
- result and incident documentation;
- campaign persistence boundaries;
- later player-request policy and package selection.

## 11. Static validation

- [x] builder has deterministic canonical source order;
- [x] builder rejects obsolete override files;
- [x] builder rejects forbidden private-field patterns;
- [x] builder requires the named native MOOSE APIs;
- [x] MOOSE APIs were checked against the pinned source;
- [ ] local PowerShell builder execution passes;
- [ ] locally built complete Lua bundle parses successfully;
- [ ] bundle header contains the expected local Git commit.

The execution container could not clone GitHub or execute Windows PowerShell because external DNS/network access was unavailable. The local project build is therefore mandatory.

## 12. DCS validation order

1. UH-60 OPSTRANSPORT group-cargo flow.
2. CH-47 static sling CARGOTRANSPORT.
3. OH-58D physical two-ship RECON and recovery corridor.
4. AH-64D physical two-ship CAS.
5. UH-60 abort/release.
6. Complete sequence only after all isolated tests pass.

## 13. Final gate

```text
No additional airfield and no dynamic player tasking
until the local build, all isolated DCS tests and the
consolidated full sequence pass.
```
