# TM01M MOOSE-native physical convoy acceptance

Status: DCS TEST PENDING

## Purpose

TM01M is a clean-room MOOSE-native replacement baseline. It does not load or call the former TM01B/TM01C custom runtime architecture.

The following former runtime components are intentionally absent:

- `ConvoyProxyController`;
- `ConvoyCacheController`;
- `ProxyCampaignState`;
- `RepresentationInterestMonitor`;
- custom pack/unpack logic;
- proxy movement;
- custom unstuck or relocation watchdog;
- virtual movement and reveal windows.

## Required Mission Editor objects

```text
TPL_TEST_BLUE_CONVOY_01
ZONE_TM01_START_BAGRAM
ZONE_TM01_ROUTE_01
ZONE_TM01_ROUTE_02
ZONE_TM01_ROUTE_03
ZONE_TM01_ROUTE_04
ZONE_TM01_ROUTE_05
ZONE_TM01_ROUTE_06
ZONE_TM01_ROUTE_07
ZONE_TM01_TARGET_JALALABAD
```

The existing TM01C fixture may be copied. The old TM01C bundle must be removed from the mission trigger list.

## Script order

1. `vendor/moose/Moose.lua`
2. generated `mission/tests/tm01-blue-convoy/dist/TM01M.lua`

## Test procedure

1. Start the mission and confirm `TM01M READY`.
2. Use `F10 -> Other -> OMW Tests -> TM01M MOOSE Native Convoy -> Spawn convoy`.
3. Confirm exactly six living vehicles and no duplicate physical convoy.
4. Use `Start route`.
5. Observe the convoy throughout the complete route.
6. Periodically use `Show status`.
7. Allow the convoy to reach `ZONE_TM01_TARGET_JALALABAD`.
8. Preserve `dcs.log` and `debrief.log`.

## PASS criteria

- bootstrap outcome is `READY`;
- exactly one physical six-vehicle group is spawned by MOOSE `SPAWN`;
- duplicate spawn and duplicate route start are rejected;
- route contains seven anchor waypoints plus the target waypoint;
- route is assigned through the MOOSE `GROUP:Route` wrapper;
- movement uses `On Road` and 30 km/h;
- supervision is executed by MOOSE `SCHEDULER`;
- user messages are emitted by MOOSE `MESSAGE`;
- arrival is detected exactly once when the complete living group is inside the target zone;
- no custom proxy, virtual movement, pack/unpack, CampaignState or relocation code is loaded;
- no Lua error occurs.

## FAIL criteria

- any old TM01B/TM01C runtime module is included in the generated bundle;
- more than one runtime convoy exists;
- fewer or more than six vehicles spawn without combat loss;
- route assignment fails;
- the convoy permanently stops before arrival;
- any custom teleport, recovery spawn or relocation occurs;
- arrival is logged more than once;
- any TM01M Lua error occurs.

## Follow-on decision

Only after this physical baseline is tested will missing requirements be added. A custom OMW function may return only when the corresponding MOOSE capability has been tested and documented as insufficient.
