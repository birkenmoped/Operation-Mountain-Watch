# Kandahar Controlled Parking Matrix

Status: `PREPARED_NOT_RUNTIME_ACCEPTED`

This test family validates physical parking placement for the nine approved Kandahar SQUADRON templates, one warehouse asset group per mission run.

## Builder

```powershell
powershell -ExecutionPolicy Bypass -File `
  .\tools\build-kandahar-controlled-parking-case.ps1 `
  -Case OH58D
```

Supported cases:

```text
OH58D
AH64D
UH60
CH47
MQ1
MQ9
HH60G
A10C
C130
```

Generated file pattern:

```text
mission\tests\kandahar-air-operations\dist\
OMW_AirOps_Kandahar_ControlledParking_<CASE>.lua
```

## Execution order

Run one case per mission load:

```text
OH58D -> AH64D -> UH60 -> CH47 -> MQ1 -> MQ9 -> HH60G -> A10C -> C130
```

The generated bundle already contains:

```text
05-kandahar-dual-airwing-registration-preflight.lua
06-kandahar-dual-airwing-parking-contract-preflight.lua
07-kandahar-controlled-parking-case.lua
```

Do not load the standalone registration or parking-contract bundle in parallel.

## Mission Editor

Replace the previous Kandahar test bundle with the generated controlled-parking bundle. Keep MOOSE loaded before it.

Allow at least 90 seconds after mission start, then return:

```text
dcs.log
debrief.log
```

Detailed acceptance criteria:

```text
expected/kandahar-controlled-parking-matrix-acceptance.md
```
