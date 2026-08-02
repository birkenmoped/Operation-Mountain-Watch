# Kandahar UAV G-apron calibration – PASS

Date: 2026-08-01

Status: `PASS`

## Runtime evidence

```text
dcs.log size: 4,382,897 bytes
dcs.log SHA-256: 1373160648aa18d23b2fb5d53d13c29fdbd1c3a81649952bb3760ba0bb1bc1de

debrief.log size: 577,976 bytes
debrief.log SHA-256: 574c3c1b855f0a8676ad2db8c57dce23b97f1fac4684f381b63e16847d2e58de
```

Runtime source artifact:

```text
OMW_Template_v4_Kandahar(9).miz
size: 2,191,639 bytes
SHA-256: 47657b2ae532f98185a9f7c33b04f1ec9fc99ee1264496b44e93184d5ac39f1c
DCS: 2.9.28.26385
terrain revision: 27850
```

The accepted registration and parking-contract preflights passed before calibration:

```text
RegistrationPreflight: PASS
ParkingContract: PASS
```

The latest parking-contract result for the calibration artifact was:

```text
mainTotal=316
mainAllowed=304
mainBlocked=12
heliportTotal=86
heliportAllowed=59
heliportBlocked=27
clientReservations=10
statics=47
safeParking=true
```

## Accepted label-to-runtime mapping

All eleven marker coordinates resolved exactly to native Kandahar Main parking nodes. Every entry reported:

```text
coordinateDelta=0.00
terminalType=104
airdromeId=7
allowed=true
blocked=false
available=true
```

### MQ-1 / RQ-1A Predator pool

```text
G01 -> TerminalID 189
G02 -> TerminalID 303
G03 -> TerminalID 202
G04 -> TerminalID 224
G05 -> TerminalID 46
G06 -> TerminalID 291
G07 -> TerminalID 129
G08 -> TerminalID 143
```

Sorted runtime pool:

```text
46,129,143,189,202,224,291,303
```

### MQ-9 Reaper pool

```text
G09 -> TerminalID 27
G10 -> TerminalID 54
G11 -> TerminalID 263
```

Sorted runtime pool:

```text
27,54,263
```

## Final runtime result

```text
RESULT: PASS
labels=11
mapped=11
mq1Labels=8
mq1Available=8
mq1TerminalIDs=46,129,143,189,202,224,291,303
mq9Labels=3
mq9Available=3
mq9TerminalIDs=27,54,263
unavailableLabels=none
mq1Restricted=true
mq9Restricted=true
noStart=true
noSpawn=true
noMission=true
noTransport=true
noPayloadMutation=true
```

## No-spawn evidence

The calibration did not start a Kandahar AIRWING and did not issue a warehouse request or mission. The debrief contains no `Birth` event. It records only the loaded mission state and the player-controlled AH-64D client during the 97.599-second run. `graveyard = {}`.

## Disposition of marker groups

The eleven `CAL_AIR_US_KAF_UAV_G01` through `CAL_AIR_US_KAF_UAV_G11` groups have completed their purpose and may now be removed from the mission. They are not part of operational inventory.

The normal aircraft statics may be restored. At runtime, any G-apron TerminalID blocked by the accepted Main parking contract is removed from the corresponding UAV SQUADRON pool. There is no fallback to unrestricted Kandahar Main parking.
