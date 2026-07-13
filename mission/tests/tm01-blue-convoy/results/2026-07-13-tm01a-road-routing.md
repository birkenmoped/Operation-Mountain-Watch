# TM01A Road Routing DCS Acceptance - 2026-07-13

## Result

- Result: PASS
- Mission: TM01A-MOOSE-Blue-Convoy-Physical.miz
- Code commit: 82d2954
- DCS version: 2.9.27.25340 (x86_64, MT)
- Bundle configuration: TM01A-road-routing-1
- Bundle build timestamp: 2026-07-13T19:12:57Z
- MOOSE version: 2.9.18
- MOOSE build: 2026-06-14T16:11:05+02:00-73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
- MOOSE SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915

## Spawn validation

- Bootstrap outcome: READY
- Initial convoy state: NOT_SPAWNED
- Manual spawn: PASS
- Runtime group: TM01A_BLUE_CONVOY_001#001
- Expected unit count: 6
- Actual unit count: 6
- Original Late Activation template remained inactive: true
- Duplicate convoy spawn rejection: PASS

## Route validation

- Route ID: ROUTE_TM01_BAGRAM_JALALABAD
- Route start: PASS
- Anchor count: 7
- Total waypoint count: 8
- First route zone: ZONE_TM01_ROUTE_01
- Final target zone: ZONE_TM01_TARGET_JALALABAD
- Configured speed: 30 km/h
- Formation: ON_ROAD
- Road-only flag: true
- Route assignment count: one
- EN_ROUTE status: PASS
- ARRIVED status: PASS
- Final living unit count: 6
- Final target-zone membership: true
- Arrival mission time: 25946.837 seconds
- convoy_route_arrived event count: 1
- Duplicate route-command protection: accepted by operator observation
- A dedicated convoy_route_rejected event was not captured in the supplied log

## Observations

- DCS selected a substantially longer road path than the apparent direct route.
- The detour is treated as DCS road-network or pathfinding behavior rather than a controller failure.
- The convoy nevertheless followed the road network and reached the configured target zone.
- No automatic route recalculation or unstuck behavior was executed.

## Scope confirmation

- No automatic spawn or automatic route start occurred.
- No second runtime convoy was created.
- No reset, despawn, respawn, recovery, route recalculation, or automatic unstuck logic executed.
- No cargo, warehouse, persistence, virtualization, hostile-force, CSAR, or HVT logic executed.
- The original Late Activation template was not activated or routed.