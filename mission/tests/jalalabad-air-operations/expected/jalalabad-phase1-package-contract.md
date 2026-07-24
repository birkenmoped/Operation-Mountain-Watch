# Jalalabad Phase 1 package contract

Status: implemented in `JBAD-AIR-OPS-PHASE1-7`; DCS validation pending.

This file is the binding package model for the deterministic Phase-1 tests and the later dynamic request layer.

| Squadron/test | Mission Editor template | Physical DCS group | Required MOOSE asset groups | Aircraft | Runtime unit names |
|---|---:|---:|---:|---:|---|
| OH-58D RECON | 2 aircraft | one physical two-ship | 1 | 2 | `<group>-01`, `<group>-02` |
| AH-64D CAS | 2 aircraft | one physical two-ship | 1 | 2 | `<group>-01`, `<group>-02` |
| UH-60 troop test | 1 lead aircraft | one single-ship | 1 | 1 | `<group>-01` |
| UH-60 MEDEVAC production package | separate lead and guard templates | two independent single-ship groups | 2 | 2 | one exact unit per group |
| CH-47 cargo | 1 aircraft | one single-ship | 1 | 1 | `<group>-01` |

## Non-negotiable rules

- `SQUADRON:SetGrouping()` must equal the physical group size defined here.
- A two-aircraft template must not be converted into two unrelated single-ship groups.
- `AUFTRAG:SetRequiredAssets()` counts physical MOOSE asset groups, not aircraft.
- Runtime event counting counts aircraft by exact unit name and groups by exact group name.
- Inventory readiness counts MOOSE asset groups: `OH58D=12`, `AH64D=4`, `UH60=8`, `CH47=8`.
- Package arithmetic must always hold: `RequiredGroups * Grouping = RequiredAircraft`.
- The current UH-60 troop transport test validates one transport lead. It is not the later full MEDEVAC lead/guard package test.

## Phase-1 acceptance order

1. OH-58D physical two-ship RECON and explicit recovery corridor.
2. AH-64D physical two-ship CAS, common return and two-aircraft landing accounting.
3. UH-60 single-ship troop transport.
4. CH-47 single-ship cargo transport.
5. UH-60 reservation/abort release.

The dynamic player-request layer may only consume these package contracts after the deterministic tests pass in DCS.
