# Jalalabad Phase 1 – MOOSE-first Refactoring Acceptance Contract

Status: **REQUIRED BEFORE PRODUCTIONIZATION OR AIRFIELD REUSE**  
Review source: `docs/29-jalalabad-air-operations-moose-code-review.md`  
Incident addendum: `docs/30-jalalabad-air-operations-phase1-incident-addendum-and-refactor-gate.md`

## 1. Scope

This contract does not change the current PHASE1-9 DCS retest fixture. It defines the mandatory architecture for the subsequent consolidation before:

- copying the node to another airfield;
- adding dynamic player-request tasking;
- implementing the full UH-60 MEDEVAC lead/guard package;
- treating the Phase-1 harness as production mission code.

## 2. Public MOOSE API gate

The consolidated source must not directly depend on the following internal containers unless an exception is documented with the pinned MOOSE source location and a regression test:

```text
squadron.assets
cfg.Airwing.missionqueue
mission.groupdata
opsgroup.groupname
opsgroup.group
_DATABASE.Templates.Groups
```

Expected public replacements include:

```text
AIRWING:CountAssets
AIRWING:CountAssetsOnMission
AIRWING:CountMissionsInQueue
AUFTRAG:GetOpsGroups
GROUP:GetTemplate
GROUP:GetTemplateRoutePoints
FLIGHTGROUP/OPSGROUP public getters and state queries
```

Acceptance:

- [ ] no undocumented private-field access;
- [ ] all exceptions identify the exact pinned MOOSE commit;
- [ ] every exception has a static regression check;
- [ ] public API behavior is preferred over field introspection.

## 3. Single mission authority

MOOSE AUFTRAG is the only operational mission-state authority.

Required:

- [ ] start conditions use `AUFTRAG:AddConditionStart` where applicable;
- [ ] push conditions use `AUFTRAG:AddConditionPush` where applicable;
- [ ] physical success uses `AUFTRAG:AddConditionSuccess`;
- [ ] physical failure uses `AUFTRAG:AddConditionFailure`;
- [ ] native AUFTRAG callbacks provide the mission-state timeline;
- [ ] no second custom SUCCESS/FAILED/CANCELLED/DONE state machine;
- [ ] no post-hoc terminal-state normalization.

The acceptance harness may classify a DCS run as PASS or FAIL after observing MOOSE, but it must not rewrite the operational mission state.

## 4. Object-bound lifecycle

Required after MOOSE assigns an asset:

- [ ] store the concrete FLIGHTGROUP/OPSGROUP reference;
- [ ] attach callbacks once to that object;
- [ ] use object callbacks for mission start, execution, cargo, landing and loss;
- [ ] global event observation becomes diagnostic only;
- [ ] runtime names remain a test invariant, not the primary object locator;
- [ ] callbacks are attached before the first operation they must observe.

## 5. UH-60 transport lifecycle

Pickup acceptance:

- [ ] pickup landing is inside the configured load zone;
- [ ] expected cargo identity matches `TPL_GROUND_BLUE_JBAD_PHASE1_UH60_TROOPS` runtime cargo;
- [ ] expected cargo reports loaded into the expected carrier through a public MOOSE state/query;
- [ ] `LoadingDone` is observed;
- [ ] post-pickup takeoff is observed.

Drop-off acceptance:

- [ ] drop-off landing is inside `ZONE_TEST_US_JBAD_UH60_DROPOFF`;
- [ ] `Unloaded` reports the expected cargo object;
- [ ] `UnloadingDone` is observed;
- [ ] cargo is alive in the drop-off zone;
- [ ] cargo is not still loaded and not in the pickup zone;
- [ ] physical objective is confirmed before final despawn is armed.

RTB acceptance:

- [ ] post-dropoff takeoff is observed;
- [ ] final landing place equals the Jalalabad airbase object or ID;
- [ ] pickup/drop-off landings do not increment final base landing count;
- [ ] final despawn occurs only after verified objective and final RTB landing;
- [ ] one UH-60 asset group returns to stock.

## 6. Package model invariants

```text
OH58D: 12 asset groups × grouping 2 = 24 aircraft
AH64D:  4 asset groups × grouping 2 =  8 aircraft
UH60:   8 asset groups × grouping 1 =  8 aircraft
CH47:   8 asset groups × grouping 1 =  8 aircraft
```

- [ ] package contract remains the single source for inventory and grouping;
- [ ] no lifecycle fix changes a physical group model;
- [ ] OH-58D and AH-64D remain physical two-ships;
- [ ] UH-60 remains single-ship assets, with later lead/guard package coordination above the physical group layer;
- [ ] CH-47 remains a physical single-ship.

## 7. Override-chain removal

Target state:

- [ ] no chained method replacement across `14a`, `14b`, `17`, `18`, `19`, `20`;
- [ ] one mission factory;
- [ ] one acceptance observer;
- [ ] one small test-sequence controller;
- [ ] per-mission acceptance specifications are data or bounded adapters;
- [ ] builder order is not used as a hidden configuration mechanism;
- [ ] no new `21-phase1-*` corrective monkey patch.

## 8. Polling policy

Polling is allowed only for:

- bounded timeout watchdogs;
- periodic telemetry;
- independent invariant checks;
- final acceptance stability confirmation where no native event exists.

Polling is not allowed as the primary source for:

- AUFTRAG mission state;
- FLIGHTGROUP landing/takeoff state;
- cargo loaded/unloaded state;
- mission queue size when a public AIRWING query exists;
- asset counts when public LEGION/AIRWING queries exist.

## 9. Custom code that remains valid

The refactor must preserve these project-owned responsibilities:

- ORBAT and package contracts;
- Mission Editor naming contracts;
- Jalalabad parking and static reservations;
- client-slot protection;
- terrain and corridor acceptance;
- exact runtime test invariants;
- result and incident documentation;
- campaign persistence boundaries;
- later player-request policy and package selection.

## 10. Required validation

Static:

- [ ] Lua 5.1 parse succeeds;
- [ ] no forbidden private-field access without exception;
- [ ] no chained replacement of core factory/controller/observer methods;
- [ ] public MOOSE methods named in this contract exist in the pinned framework;
- [ ] package arithmetic passes;
- [ ] builder produces deterministic source order and header.

DCS isolated tests:

1. OH-58D RECON physical two-ship;
2. AH-64D CAS physical two-ship;
3. UH-60 TROOPTRANSPORT full native cargo lifecycle;
4. CH-47 CARGOTRANSPORT;
5. UH-60 abort/release;
6. complete sequence only after all isolated tests pass.

Final gate:

```text
No additional airfield and no dynamic player tasking
until all isolated tests and the consolidated full sequence pass in DCS.
```
