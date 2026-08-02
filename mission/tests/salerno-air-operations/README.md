# FOB Salerno staged diagnostics

This test bundle validates the Salerno Mission Editor contract in controlled stages.

## Current stage

Builder version:

```text
SAL-SQUADRON-CONSTRUCT-3
```

The bundle performs:

1. airbase and parking resolution;
2. warehouse, client, template and zone probes;
3. `AIRWING:New()` construction and binding without `Start()`;
4. construction of five `SQUADRON` objects without adding them to the AIRWING.

It does not start the AIRWING, register SQUADRONs with it, add missions or payloads, or spawn aircraft.

## Squadron contracts

| Squadron | Template | Logical aircraft | Units/template | Ngroups | Represented | Residual |
|---|---|---:|---:|---:|---:|---:|
| `SQ_US_SAL_AH64D_TF_TIGERSHARK_ATTACK` | `TPL_AIR_US_SAL_AH64D_CAS_2SHIP` | 8 | 2 | 4 | 8 | 0 |
| `SQ_US_SAL_OH58D_B_6_6_CAV` | `TPL_AIR_US_SAL_OH58D_RECON_2SHIP` | 8 | 2 | 4 | 8 | 0 |
| `SQ_US_SAL_UH60_TF_TIGERSHARK_ASSAULT` | `TPL_AIR_US_SAL_UH60_ASSAULT_2SHIP` | 7 | 2 | 3 | 6 | 1 |
| `SQ_US_SAL_UH60_MEDEVAC_C_5_159_AVN` | `TPL_AIR_US_SAL_UH60_MEDEVAC_1SHIP` | 3 | 1 | 3 | 3 | 0 |
| `SQ_US_SAL_CH47_TF_TIGERSHARK_MEDIUM_LIFT` | `TPL_AIR_US_SAL_CH47_TRANSPORT_1SHIP` | 6 | 1 | 6 | 6 | 0 |

The seventh UH-60 Assault aircraft cannot be represented exactly by an exclusively two-aircraft template. This stage records one residual aircraft and does not silently round the runtime capacity up to eight.

## Build

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File ".\tools\build-salerno-air-operations-bundle.ps1"
```

Output:

```text
mission/tests/salerno-air-operations/dist/OMW_AirOps_Salerno_Diagnostics.lua
```

## Mission Editor integration

Re-select the generated file in the existing Salerno `MISSION START -> DO SCRIPT FILE` action and save the mission after every rebuild.

## Acceptance markers

```text
[OMW][SALERNO][DIAG] COMPLETE status=PASS
[OMW][SALERNO][AIRWING] COMPLETE status=PASS
[OMW][SALERNO][SQUADRON] COMPLETE status=PASS
```

Run the mission for at least 15 seconds and provide `dcs.log`.
