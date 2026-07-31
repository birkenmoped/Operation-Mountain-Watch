# Kandahar Dual-Airbase No-Spawn Diagnostic – PASS

Status: `PASS`

Test date:

```text
2026-07-31
```

## Tested branch and bundle

```text
Branch: agent/kandahar-airwing-baseline-contract
Git commit embedded in bundle: 78031766819fff7f7d62020804a8378423e5ec42
BuilderVersion: KAF-DUAL-AIRBASE-NOSPAWN-1
```

## Tested mission artifact

Uploaded test mission:

```text
OMW_Template_v4_Kandahar(2).miz
Size: 2,187,049 bytes
SHA-256: 2d790ec62639037802200c6a8bfacd2a6ab6a2c8f44d8d4d8f64add3717aed81
```

The embedded diagnostic intentionally identifies the underlying authoring source as:

```text
OMW_Template_v4_Kandahar(1).miz
Source size: 2,180,824 bytes
Source SHA-256: 07cc90b18bf3a09fee8c650cb9f1668c9ec6c2412a37be5f005642d216deeb8a
```

The changed `.miz` hash is expected because the diagnostic bundle was embedded and the mission was saved again.

## Environment

```text
DCS: 2.9.28.26385
Theatre: Afghanistan
Mission date: 2011-01-14
Embedded MOOSE SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Expected MOOSE version: 2.9.18
```

The embedded resource order was structurally verified as:

```text
1 Moose.lua
2 TM01M.lua
6 OMW_AirOps_Jalalabad.lua
7 OMW_AirOps_Bagram.lua
8 OMW_AirOps_Kandahar_Diagnostic.lua
```

## Acceptance result

The diagnostic produced both required PASS markers:

```text
[OMW][AirOps.KAF.ObjectAudit] RESULT: PASS objectContract=true runtimeReady=false ... noSpawn=true
[OMW][AirOps.KAF.ParkingDump] RESULT: PASS diagnosticComplete=true objectContract=true mainParking=316 heliportParking=86 noBlacklistMutation=true noSpawn=true runtimeReady=false
```

No Kandahar diagnostic `RESULT: FAIL`, `VIOLATION`, Lua runtime error or timer error occurred.

## Native airbases

Runtime-confirmed:

```text
Main:
  name: Kandahar
  ID: 7
  category: Airdrome
  role: MAIN_FIXED_WING

Heliport:
  name: Kandahar Heliport
  ID: 15
  category: Helipad
  role: MUSTANG_ROTARY_WING
```

This confirms the dual-airbase architecture boundary.

## Warehouse result

Main warehouse anchor:

```text
WH_AIR_US_KANDAHAR
DCS type: container_40ft
coalition: blue / 2
coordinate: x=-270272.8 y=1013.3 z=-30290.2
```

Expected unresolved Heliport blockers were reported exactly once:

```text
HELIPORT_WAREHOUSE_NAME_UNAPPROVED
HELIPORT_WAREHOUSE_ANCHOR_MISSING
```

These are expected architecture blockers and did not invalidate the diagnostic.

## Object-contract counts

```text
CLIENT_OK: 10
TEMPLATE_BEGIN: 10
TEMPLATE_END: 10
OBSOLETE_TEMPLATE_ABSENT: 5
CLIENT_NEAREST: 10
STATIC_NEAREST: 47
```

Static totals:

```text
US aircraft statics: 47
  8 AH-64D_BLK_II
  1 MQ-9 Reaper
 10 UH-60A, including 2 HH-60G role representations
  2 C-130J-30
 10 CH-47Fbl1
  2 RQ-1A Predator
  8 OH58D
  6 A-10C_2

UN aircraft statics: 6
  4 UH-1H
  2 Mi-26
```

The following support objects were also confirmed:

```text
ZONE_AIR_US_KAF_CSAR_UNLOAD
STATIC_GND_US_KAF_M113_MEDIC
```

## Binding client parking contract

### Kandahar Main

```text
TerminalID 282  CLIENT_US_KAF_A10C_01  ME label Z20
TerminalID 287  CLIENT_US_KAF_A10C_02  ME label Z19
TerminalID 294  CLIENT_US_KAF_C130_01  ME label S01
TerminalID  92  CLIENT_US_KAF_C130_02  ME label S02
```

All four clients matched the runtime TerminalID at `0.00 m`.

### Kandahar Heliport

```text
TerminalID 30  CLIENT_US_KAF_AH64D_01  ME label MST38-H
TerminalID 19  CLIENT_US_KAF_AH64D_02  ME label MST30-H
TerminalID 80  CLIENT_US_KAF_OH58D_01  ME label MST01-H
TerminalID 23  CLIENT_US_KAF_OH58D_02  ME label MST11-H
TerminalID  4  CLIENT_US_KAF_CH47F_01  ME label MST75-H
TerminalID 47  CLIENT_US_KAF_CH47F_02  ME label MST82-H
```

All six clients matched the runtime TerminalID at `0.00 m`.

## Parking inventory

### Kandahar Main

```text
Total nodes: 316
Free at diagnostic time: 312
Occupied/reserved by clients: 4

Terminal type 104: 257
Terminal type 40:   34
Terminal type 72:   25
```

### Kandahar Heliport

```text
Total nodes: 86
Free at diagnostic time: 80
Occupied/reserved by clients: 6

Terminal type 40: 86
```

The diagnostic did not mutate any parking blacklist.

## Static-to-parking geometry

All 47 US aircraft statics were associated with the nearest runtime parking node.

Offline analysis of the emitted geometry found:

```text
within 5 m:  26 statics / 26 unique terminals
within 8 m:  31 statics / 31 unique terminals
within 12 m: 32 statics / 32 unique terminals
```

No duplicate static assignment occurred among those close-overlap candidates. These figures are diagnostic evidence only. They do not yet establish the final parking blacklist because several OH-58D and CH-47 representations are intentionally offset from the native node centers.

## Payload findings reconfirmed

The runtime template dump confirmed:

```text
MQ-1A:
  two occupied weapon stations
  CLSID {ee368869-c35a-486a-afe7-284beb7c5d52} on pylons 1 and 2

MQ-9:
  two AGM114x2_OH_58 launcher entries
  two Paveway_II bomb entries
  laser code 1688

OH-58D:
  M260_APKWS_M151
  OH58D_AGM_114_R

AH-64D:
  M261 rocket pods
  two Hellfire rack entries
  IAFS_ComboPak_100
  gun setting 25

CH-47F:
  CH47_PORT_M60D
  CH47_STBD_M60D
```

ISR registration and period-correct OH-58D payload approval remain blocked pending the corresponding project decisions.

## Non-OMW errors observed

No OMW/Kandahar Lua error occurred.

After the player entered an OH-58D slot, DCS emitted module-specific errors including:

```text
Unit [OH58D]: Corrupt damage model
failed OH58D shape mount
cockpit device/link errors
```

These occurred after the diagnostic had already been configured and are not generated by the Kandahar diagnostic. They should be tracked separately as a local DCS/OH-58D installation or module issue.

At mission shutdown the known external hook error also occurred:

```text
Saved Games\DCS.openbeta\Scripts\Hooks\bhHook.lua:168
attempt to index upvalue 'tcp' (a nil value)
```

This is outside the OMW mission bundle.

## Accepted scope

Accepted:

- current Kandahar Mission Editor object contract;
- both native airbases and IDs;
- Main warehouse anchor;
- all 10 clients and exact runtime TerminalIDs;
- all 10 templates and current payload signatures;
- absence of obsolete templates;
- 47 US and 6 UN aircraft statics;
- CSAR unload zone and M113 medic object;
- full parking inventories for both airbases;
- read-only/no-spawn/no-blacklist behavior.

Not accepted and still blocked:

- Heliport AIRWING identifier;
- Heliport warehouse identifier and Mission Editor anchor;
- final Main and Heliport parking blacklists/allowlists;
- logical inventories except A-10C;
- ISR payload/availability policy;
- OH-58D period-correct payload approval;
- AIRWING/SQUADRON construction;
- spawn, AUFTRAG, OPSTRANSPORT, CSAR or ISR execution.

## Final classification

```text
KANDahar Dual-Airbase No-Spawn Diagnostic: PASS
Object contract: ACCEPTED
Parking inventory dump: ACCEPTED
Runtime AIRWING readiness: BLOCKED BY DOCUMENTED OWNER/ORBAT DECISIONS
```
