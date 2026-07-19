# OMW Settlement Zones Test 01

This DCS/MOOSE development test validates a deliberately coarse, manually maintained settlement-zone layer. It is intended as an operational prototype, not as a complete Afghanistan map inventory.

## What the test proves

1. Manually placed Mission Editor trigger zones are discovered by naming convention.
2. A configured convoy changes speed automatically when entering and leaving settlement classes.
3. Infantry whose target lies inside a settlement receives a road-oriented route to the target.
4. Infantry whose direct path crosses a settlement, while the target lies outside it, receives a conservative detour around the settlement bounding box.
5. Infantry receives a direct off-road route when no settlement blocks the path.

The first version does **not** change convoy spacing. It isolates and validates zone detection, speed profiles and coarse infantry-routing decisions.

## Required load order

Create a `MISSION START` trigger with these actions:

1. `DO SCRIPT FILE` -> current `Moose.lua`
2. `DO SCRIPT FILE` -> `mission/tests/settlement-zones/dist/OMW_SETTLEMENT_ZONES_TEST.lua`

No system files, `io`, `lfs`, `require` or desanitizing are required.

## Required Mission Editor objects

### Settlement trigger zones

Create one or more circular or quadrilateral trigger zones. Use these exact prefixes and three-digit numbering:

```text
OMW_SETTLEMENT_SPARSE_001
OMW_SETTLEMENT_VILLAGE_001
OMW_SETTLEMENT_URBAN_001
OMW_SETTLEMENT_CITY_001
```

Additional zones continue with `_002`, `_003`, and so on. Missing numbers are allowed. The script scans indices `001` through `099` for every class.

Overlapping zones are allowed. When the convoy is in more than one zone, the highest-priority class wins:

```text
CITY > URBAN > VILLAGE > SPARSE
```

Use generous zone boundaries. The purpose is operational behavior, not exact cadastral mapping.

### Convoy group

Create one active ground convoy named:

```text
TEST_SETTLEMENT_CONVOY_01
```

Give it a route that begins outside a settlement zone, crosses at least one zone, and ends outside again.

Default speed profiles:

```text
OUTSIDE   50 km/h
SPARSE    35 km/h
VILLAGE   25 km/h
URBAN     18 km/h
CITY      12 km/h
```

The script checks the convoy every second and changes speed only when its active settlement profile changes.

### Infantry group

Create one active ground infantry group named:

```text
TEST_SETTLEMENT_INFANTRY_01
```

The group should initially have no complex route. Place it outside the settlement zone used by the test.

### Infantry target zone

Create a small trigger zone named:

```text
ZONE_SETTLEMENT_INFANTRY_TARGET
```

The F10 command uses the center of this zone as the target.

## F10 menu

```text
F10 Other
└── OMW Tests
    └── Settlement Zones
        ├── Status anzeigen
        ├── Zonen markieren
        ├── Zonenmarker entfernen
        └── Infanterieroute berechnen
```

## Recommended three test cases

### Test A: Convoy transition

- Route the convoy from open terrain through one `VILLAGE` zone and back into open terrain.
- Expected messages:
  - `OUTSIDE | 50 km/h`
  - `VILLAGE | 25 km/h`
  - `OUTSIDE | 50 km/h`

### Test B: Infantry target inside settlement

- Place `ZONE_SETTLEMENT_INFANTRY_TARGET` inside a settlement zone.
- Select `Infanterieroute berechnen`.
- Expected result: the script calls MOOSE road routing toward the target and reports `Straßenroute zum Ziel gesetzt`.

### Test C: Infantry settlement avoidance

- Place infantry and target outside a settlement, with the settlement between both points.
- Select `Infanterieroute berechnen`.
- Expected result: the script creates a detour waypoint outside the settlement bounding square plus a 300 m buffer.

## Diagnostics

Search `Saved Games\DCS.openbeta\Logs\dcs.log` for:

```text
[OMW][SETTLEMENT-ZONES]
```

Important records:

```text
zone_discovery_complete
convoy_profile_changed
infantry_route_set mode=ROAD_TO_TARGET
infantry_route_set mode=DETOUR
infantry_route_set mode=DIRECT
```

## Current limitations

- Only manually placed settlement zones are used.
- Convoy spacing is not changed in this version.
- Zone geometry is reduced to its bounding square for infantry avoidance.
- The detour prototype considers the first blocking settlement on the direct path.
- Road routing is used only when the target lies inside a settlement.
- No automatic unstuck, teleport, respawn or destructive recovery is implemented.
