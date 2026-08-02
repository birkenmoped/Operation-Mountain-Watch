---
document_id: OMW-SAL-PARKING-CONTROL-DEFERRED-001
status: HISTORICAL_TEST_FIXTURE
authoritative_for:
  - observed failure to prove Salerno multi-unit parking compliance
  - decision to defer operational Salerno parking control
  - distinction between configuration consistency and realized DCS placement
not_authoritative_for:
  - a single proven root cause inside MOOSE or DCS
  - future parking implementation after new telemetry
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - earlier unqualified parking PASS interpretations
superseded_by:
source_branch: agent/salerno-read-only-diagnostics
source_commit: GIT_HISTORY
validated_in_dcs: true
---

# Salerno Operational Parking Control – FAIL / DEFERRED

## Intended contract

The experimental parking stages attempted to:

- keep CH-47 on a left heavy-lift sector;
- keep AH-64D, OH-58D and UH-60 on type-specific right rotary pools;
- exclude six client terminals;
- exclude static-covered and functional areas;
- apply parking pools to SQUADRONs;
- synchronize all already registered Warehouse assets.

Example pools:

```text
AH-64D: T28,T30
UH-60:  T33,T34,T37
OH-58D: T43,T44
CH-47:  LEFT_HEAVY
```

## Internal configuration result

```text
registered assets synchronized: 20
configuration violations: 0
```

This result proved that the expected tables were present on SQUADRON and asset records.

## Observed runtime failure

At least one Apache was visually observed on a reserved or protected player area. A multi-unit group did not reliably realize all unit positions inside the expected type pool.

Therefore the following were not proven:

```text
actual spawn respects configured asset parkingIDs
client positions are protected during every multi-unit spawn
type-specific apron separation is enforced
cold ground spawn occurs at an accepted terminal
```

## MOOSE source finding

When an asset has its own `parkingIDs`, the used Warehouse allocator follows an asset-specific validation path. The generic AIRBASE blacklist, terminal-type and parking-list path is not applied identically in that branch.

Consequences:

- client terminals must never appear in an asset pool;
- an AIRBASE blacklist alone is not enough to prove safety;
- SQUADRON/asset tables and actual unit coordinates must be checked separately.

## Root-cause boundary

No single cause was proven. Remaining candidates include:

- incomplete or differently interpreted Parkingdata;
- template-relative group offsets;
- DCS relocation;
- fallback after no valid group placement;
- visual or group-versus-unit mapping ambiguity.

These remain hypotheses, not findings.

## Final decision

```yaml
calibration_retained: true
experimental_sources_retained: true
operational_parking_mutation: false
parking_gate_for_airwing_start: false
parking_gate_for_dispatch: false
parking_acceptance: DEFERRED
```

The following sources remain historical/experimental and are not part of the accepted Stage-18 bundle:

```text
06b-apply-runtime-parking-contract.lua
06c-enforce-transition-exclusion.lua
06d-apply-calibrated-parking-contract.lua
```

## Required future telemetry

A later parking effort must record every spawned unit separately:

```text
mission, squadron, asset UID, group, unit, type,
configured asset IDs, configured squadron IDs,
world coordinate, nearest TerminalID, ME mapping,
in expected pool, in client pool, in static exclusion,
spawn mode ground/air
```
