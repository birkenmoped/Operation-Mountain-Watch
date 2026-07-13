# TM01A Physical Spawn DCS Acceptance - 2026-07-13

## Result

- Result: PASS
- Mission: TM01A-MOOSE-Blue-Convoy-Physical.miz
- Code commit: 0d6370b
- DCS version: 2.9.27.25340 (x86_64, MT)
- Bundle configuration: TM01A-physical-spawn-1
- Bundle build timestamp: 2026-07-13T18:20:04Z
- MOOSE version: 2.9.18
- MOOSE build: 2026-06-14T16:11:05+02:00-73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
- MOOSE SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915

## Validation

- Bootstrap outcome: READY
- Required Mission Editor objects: PASS (10/10)
- Initial convoy state: NOT_SPAWNED
- Spawn request: PASS
- Runtime group: TM01A_BLUE_CONVOY_001#001
- Expected unit count: 6
- Actual unit count: 6
- Start-zone membership: true
- Original template remains inactive: true
- Duplicate spawn rejection: PASS
- Final convoy state: SPAWNED
- Final unit count: 6
- Final status mission time: 259.892 seconds
- Elapsed time from spawn to final status: 241.243 seconds
- Stationarity for more than two minutes: PASS, visually observed

## Scope confirmation

- No route or waypoint assignment executed.
- No cargo, warehouse, persistence, virtualization, hostile-force, or unstuck logic executed.
- No second runtime convoy was created.
- The original Late Activation template was not activated.
