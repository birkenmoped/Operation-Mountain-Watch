# Jalalabad corrected complete-node package – pending validation

## Status

```text
IMPLEMENTED IN REPOSITORY
NOT YET LOCALLY BUILT AFTER THE FINAL CORRECTIONS
NOT YET EMBEDDED INTO THE TEST .miz
NOT YET VALIDATED IN DCS
```

## Branch

```text
feature/jalalabad-air-operations-diagnostics
```

## Scope of the unvalidated correction

- logical inventory corrected to `24 OH-58D / 8 AH-64D / 8 UH-60 / 8 CH-47`,
- player limit reduced from four to two per usable type at Jalalabad,
- CH-47 template, SQUADRON and payload implementation,
- canonical CH-47 DCS type discovery from the Mission Editor template,
- six required core player groups,
- zero or two optional UH-60L player groups,
- static caps `7/4/4/5`,
- eleven functional zones,
- virtual reserve and permanent-loss model,
- builder version `JBAD-AIR-OPS-COMPLETE-2`,
- corrected final activation gate.

## Previously confirmed results that remain valid

- Jalalabad Airbase ID 19,
- 50 parking entries,
- Warehouse anchor,
- DCS warehouse and MOOSE storage,
- AIRWING construction and airbase linking,
- OH-58D SQUADRON construction,
- AH-64D SQUADRON construction.

These earlier PASS results do not validate the new UH-60 count, CH-47 integration, reduced player-slot policy, revised static caps, zones or final activation.

## Required next validation sequence

1. pull the exact branch commit specified in the next work order,
2. run `tools/build-jalalabad-air-operations-bundle.ps1`,
3. record bundle SHA-256 and Git commit,
4. reselect the generated bundle in Mission Editor `DO SCRIPT FILE`,
5. save the `.miz`,
6. place all objects listed in `expected/jalalabad-complete-node-acceptance.md`,
7. run the complete DCS acceptance test,
8. provide the new `dcs.log`,
9. write a separate PASS, PARTIAL or FAIL report.

Until then PR #18 remains draft and labeled `dcs-test-pending`.
