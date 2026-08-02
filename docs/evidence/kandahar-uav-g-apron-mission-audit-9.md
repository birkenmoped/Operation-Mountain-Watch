# Kandahar UAV G-apron Mission Editor audit – artifact (9)

Status: `STRUCTURALLY_AUDITED_NOT_RUNTIME_ACCEPTED`

## Artifact identity

```text
File: OMW_Template_v4_Kandahar(9).miz
Size: 2,191,639 bytes
SHA-256: 47657b2ae532f98185a9f7c33b04f1ec9fc99ee1264496b44e93184d5ac39f1c
```

## Result

All eleven Kandahar G-apron positions are represented by one-unit Late Activation groups at Kandahar Main / airdromeId 7.

```text
G01-G08: RQ-1A Predator
G09-G11: MQ-9 Reaper
```

The operational policy derived from the project-owner fit test is therefore:

```text
MQ-1 pool: G01-G08
MQ-9 pool: G09-G11
```

## Mission-file mapping

```text
Actual label | Marker type       | mission parking | source group
G01          | RQ-1A Predator    | 189             | CAL_AIR_US_KAF_UAV_G01
G02          | RQ-1A Predator    | 303             | CAL_AIR_US_KAF_UAV_G02
G03          | RQ-1A Predator    | 202             | CAL_AIR_US_KAF_UAV_G03
G04          | RQ-1A Predator    | 224             | CAL_AIR_US_KAF_UAV_G04
G05          | RQ-1A Predator    | 46              | CAL_AIR_US_KAF_UAV_G08
G06          | RQ-1A Predator    | 291             | CAL_AIR_US_KAF_UAV_G07
G07          | RQ-1A Predator    | 129             | CAL_AIR_US_KAF_UAV_G06
G08          | RQ-1A Predator    | 143             | CAL_AIR_US_KAF_UAV_G05
G09          | MQ-9 Reaper       | 27              | CAL_AIR_US_KAF_UAV_G09
G10          | MQ-9 Reaper       | 54              | CAL_AIR_US_KAF_UAV_G11
G11          | MQ-9 Reaper       | 263             | CAL_AIR_US_KAF_UAV_G10
```

Several calibration group suffixes do not match the actual assigned stand. The runtime calibration must therefore use the unit's `parking_id` field as the authoritative label and treat the group name only as an object locator.

## Static-aircraft condition

The project owner temporarily moved the relevant aircraft statics away from the G-apron for this fit and mapping test. This permits all eleven positions to be calibrated as physically clear in the test artifact.

The production policy remains conditional: when statics are restored, any G-position blocked by the accepted Main parking contract is excluded from the corresponding SQUADRON parking list.

## Runtime requirement

The mission-file `parking` values are structural data. A DCS runtime test must still confirm:

- native runtime TerminalID;
- terminal type;
- coordinate delta;
- Main allowlist membership;
- static/client blocking state;
- separate MQ-1 and MQ-9 SQUADRON parking lists.
