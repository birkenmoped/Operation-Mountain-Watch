# TM01A Bootstrap DCS Acceptance - 2026-07-13

## Result

- Result: PASS
- Mission: TM01A-MOOSE-Blue-Convoy-Physical.miz
- Code commit: 69df66c
- DCS version: 2.9.27.25340 (x86_64, MT)
- Bundle build timestamp loaded by mission: 2026-07-13T17:01:30Z
- Expected MOOSE version: 2.9.18
- Expected MOOSE SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
- Loaded MOOSE build: 2026-06-14T16:11:05+02:00-73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

## Validation

- Native runtime APIs: PASS (3)
- MOOSE runtime APIs: PASS (4)
- Required Mission Editor objects: PASS (10/10)
- TM01B reveal zones required: No
- Initial bootstrap outcome: READY
- F10 Show status: PASS
- F10 Validate configuration: PASS
- Convoy spawned: No, expected for the bootstrap milestone
- Convoy movement: None, expected

## Observations

- The first run reported FAIL_CONFIGURATION because ZONE_TM01_START_BAGRAM was named incorrectly.
- The marker name was corrected in the Mission Editor.
- The subsequent mission start and manual revalidation both returned READY.
- Physical spawning and routing remain outside this milestone.
