# Kandahar UAV G-Apron Calibration – FAIL (marker groups missing)

Date: 2026-08-01

Status: `FAIL`

## Runtime baseline

The accepted Kandahar registration and parking-contract preflights passed in the same mission run:

```text
[OMW][AirOps.KAF.RegistrationPreflight] RESULT: PASS
[OMW][AirOps.KAF.ParkingContract] RESULT: PASS
```

The calibration itself remained within the intended no-start/no-spawn boundary.

## Failure

All seven required Mission Editor calibration groups were absent from the loaded mission database:

```text
CAL_AIR_US_KAF_UAV_G01
CAL_AIR_US_KAF_UAV_G04
CAL_AIR_US_KAF_UAV_G05
CAL_AIR_US_KAF_UAV_G07
CAL_AIR_US_KAF_UAV_G08
CAL_AIR_US_KAF_UAV_G10
CAL_AIR_US_KAF_UAV_G11
```

Runtime result:

```text
[OMW][AirOps.KAF.UAVGApronCalibration] RESULT: FAIL
violations=7
labels=7
mapped=0
noStart=true
noSpawn=true
noMission=true
noTransport=true
noPayloadMutation=true
```

Each violation was `MARKER_TEMPLATE_MISSING` for one required group.

## Interpretation

No G-apron runtime TerminalID could be derived from this run. This is a mission-content issue, not a MOOSE registration or parking-contract failure.

The calibration bundle expects each marker to be a one-unit late-activation aircraft group on Kandahar Main, with the exact group name listed above and assigned to the matching Mission Editor parking label.

Naming only the unit is insufficient; `_DATABASE:GetGroupTemplate()` resolves the group name.

## Required correction

Create or rename the seven groups in the Mission Editor, save the `.miz`, reload that saved mission, and rerun the unchanged calibration bundle.

Required mapping intent:

```text
CAL_AIR_US_KAF_UAV_G01 -> G01
CAL_AIR_US_KAF_UAV_G04 -> G04
CAL_AIR_US_KAF_UAV_G05 -> G05
CAL_AIR_US_KAF_UAV_G07 -> G07
CAL_AIR_US_KAF_UAV_G08 -> G08
CAL_AIR_US_KAF_UAV_G10 -> G10
CAL_AIR_US_KAF_UAV_G11 -> G11
```

No source-code correction is required for this failure.
