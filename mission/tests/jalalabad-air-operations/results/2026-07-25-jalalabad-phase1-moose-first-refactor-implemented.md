# Jalalabad Phase 1 – MOOSE-first refactor implemented

Date: 2026-07-25  
Status: **IMPLEMENTED / LOCAL BUILD AND DCS VALIDATION PENDING**  
BuilderVersion: `JBAD-AIR-OPS-PHASE1-11-MOOSE-FIRST`  
MOOSE-Pin: `73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`

## Implemented replacements

| Removed custom/internal mechanism | MOOSE-native replacement |
|---|---|
| direct `missionqueue` iteration | `AIRWING:CountMissionsInQueue()` |
| direct `squadron.assets` inspection | `SQUADRON:CountAssets()` |
| custom requested/spawned/reserved accounting | `AIRWING:CountAssetsOnMission()` |
| AID-name runtime discovery | `AIRWING:OnAfterFlightOnMission()` and `OPSTRANSPORT:GetCarriers()` |
| custom operative mission FSM | native AUFTRAG and OPSTRANSPORT FSM callbacks |
| polling-based objective authority | `AUFTRAG:AddConditionSuccess()` and native OPSTRANSPORT delivery |
| UH-60-only cargo lifecycle | generic MOOSE logistics profiles |
| manual carrier selection | `LEGION.RecruitCohortAssets()` / `AIRWING:RecruitAssetsForTransport()` |
| chained correction files | one canonical manifest, observer, logistics adapter, factory and controller |

## Native logistics profiles

```text
GROUP_CARGO
  OPSTRANSPORT Loaded / Unloaded / Delivered
  carrier LoadingDone / UnloadingDone
  troops, vehicles, OPSGROUP cargo

STORAGE_CARGO
  OPSTRANSPORT AddCargoStorage
  carrier LoadingDone / UnloadingDone
  fuel, weapons, equipment, warehouse stock

STATIC_SLING_CARGO
  AUFTRAG NewCARGOTRANSPORT
  AUFTRAG native states plus physical Static-in-zone acceptance

STATIC_FREIGHT_CARGO
  AUFTRAG FREIGHTTRANSPORT native states

DYNAMIC_CARGO
  EVENTS DynamicCargoLoaded / DynamicCargoUnloaded / DynamicCargoRemoved
```

## Removed sources

```text
14a-phase1-lifecycle-corrections.lua
14b-phase1-sequence-finalization.lua
16-phase1-moose-compatibility.lua
17-phase1-operational-safety.lua
18-phase1-readiness-and-recon-telemetry.lua
19-phase1-oh58-formation-recovery-counting.lua
20-phase1-uh60-transport-lifecycle.lua
```

## Important pinned-MOOSE behavior

`SQUADRON:SetDespawnAfterLanding(false)` enables despawn in the pinned version. The call is therefore prohibited by the builder. UH-60 and CH-47 leave squadron-wide landing despawn unset. The exact FLIGHTGROUP is armed only after native delivery and independent objective confirmation.

## Validation state

```text
MOOSE source verification: completed
repository refactor: completed
builder architecture gates: implemented
full local PowerShell build: pending
full Lua bundle parse: pending
DCS runtime validation: pending
```

No `.miz` was created or modified.

## Next validation

1. Pull the branch and build the bundle locally.
2. Confirm the builder header and SHA-256.
3. Re-select the generated bundle in the existing mission.
4. Run only the UH-60 native OPSTRANSPORT test first.
5. Require pickup landing, `Loaded`, carrier `LoadingDone`, drop-off landing, `Unloaded`, carrier `UnloadingDone`, `Delivered`, physical troops in target zone, RTB and final Jalalabad landing.

Authoritative design document:

```text
docs/31-jalalabad-air-operations-moose-first-refactor-implementation.md
```
