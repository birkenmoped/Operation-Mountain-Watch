# Jalalabad Phase 1 package-contract consolidation

Date: 2026-07-25

Status: **IMPLEMENTED / DCS VALIDATION PENDING**

## Authoritative documentation

- `docs/27-jalalabad-air-operations-phase1-postmortem-and-guardrails.md`
- `docs/28-jalalabad-air-operations-development-incident-log.md`
- `mission/tests/jalalabad-air-operations/expected/jalalabad-phase1-package-contract.md`
- `mission/tests/jalalabad-air-operations/expected/jalalabad-phase1-architecture-regression-checklist.md`

## Reason

The previous Phase-1 implementation validated two-aircraft OH-58D and AH-64D Mission Editor templates but then used `SQUADRON:SetGrouping(1)`. This converted the intended physical two-ships into unrelated single-ship DCS groups. Package structure, MOOSE asset accounting, aircraft event counting and tactical behavior were therefore inconsistent.

The same development cycle also exposed broader category errors: MOOSE templates, dynamic AIRWING spawns, visible statics, Client groups, logical inventory and tactical packages were treated as if they were interchangeable representations. They are separate layers and are now documented and checked separately.

## Binding model

- OH-58D RECON: one physical DCS group, two aircraft, one required MOOSE asset group.
- AH-64D CAS: one physical DCS group, two aircraft, one required MOOSE asset group.
- UH-60 squadron: independent single-ship assets; the later MEDEVAC package coordinates one lead and one guard as two groups.
- CH-47 cargo: one physical single-ship group.

Asset-group inventory:

```text
OH58D 12 groups / 24 aircraft
AH64D  4 groups /  8 aircraft
UH60   8 groups /  8 aircraft
CH47   8 groups /  8 aircraft
```

## Implemented changes

- Added one canonical package contract consumed by squadron construction, test manifest, exact runtime-name handling, inventory readiness and sequence finalization.
- Changed OH-58D and AH-64D to `SetGrouping(2)`.
- Changed both tests to `ExpectedGroups=1`, `ExpectedAircraft=2` with exact unit suffixes `-01` and `-02`.
- Kept UH-60 and CH-47 at `SetGrouping(1)`.
- Removed the obsolete OH-58-only runtime event override.
- Kept the explicit OH-58D recovery route `RECON_03 -> RECON_02 -> RECON_01 -> Jalalabad`.
- Separated package selection/readiness from phased lifecycle handling.
- Updated the bundle version to `JBAD-AIR-OPS-PHASE1-7`.
- Added a complete incident history and a mandatory architecture regression checklist.

## Required DCS validation

Run deterministic tests individually in this order:

1. OH-58D RECON.
2. AH-64D CAS.
3. UH-60 troop transport.
4. CH-47 cargo transport.
5. UH-60 abort/release.

Do not begin dynamic player-request implementation or copy the node to another airfield until these package contracts and lifecycle rules pass in DCS.
