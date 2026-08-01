# Kandahar Controlled Parking Matrix

Status: `V2_PREPARED_NOT_RUNTIME_ACCEPTED`

The primary test validates all nine approved Kandahar SQUADRON templates in one DCS mission run. The earlier single-case builder remains available only for targeted debugging.

Matrix v1 spawned all nine groups and all twelve expected aircraft correctly, but exposed dynamic reuse of already selected TerminalIDs. That result is recorded under:

```text
results/2026-08-01-kandahar-controlled-parking-matrix-v1-fail.md
```

Matrix v2 keeps the native MOOSE warehouse self-request model and removes already used TerminalIDs from each AIRWING's valid parking list before the next request with `AIRWING:SetParkingIDs()`.

## Primary one-run builder

```powershell
powershell -ExecutionPolicy Bypass -File `
  .\tools\build-kandahar-controlled-parking-matrix.ps1
```

Expected builder version:

```text
KAF-CONTROLLED-PARKING-MATRIX-2
```

Generated bundle:

```text
mission\tests\kandahar-air-operations\dist\
OMW_AirOps_Kandahar_ControlledParking_Matrix.lua
```

The bundle already contains:

```text
05-kandahar-dual-airwing-registration-preflight.lua
06-kandahar-dual-airwing-parking-contract-preflight.lua
08-kandahar-controlled-parking-matrix.lua
```

The matrix performs these cases sequentially in the same mission:

```text
OH58D -> AH64D -> UH60 -> CH47 -> MQ1 -> MQ9 -> HH60G -> A10C -> C130
```

Expected aggregate:

```text
cases=9
assetGroups=9
units=12
```

Both AIRWINGs are started only after the registration and parking-contract preflights pass. Every group remains cold and uncontrolled. Spawned groups remain in place, are rechecked before each later request, and must retain unique TerminalIDs within their AIRWING/airbase scope.

Do not load the standalone registration, parking-contract, or single-case bundle in parallel.

## Mission Editor

Replace the previous Kandahar matrix bundle with the newly rebuilt:

```text
OMW_AirOps_Kandahar_ControlledParking_Matrix.lua
```

Keep MOOSE loaded before the bundle. Allow at least 180 seconds after mission start, then return:

```text
dcs.log
debrief.log
```

Automatic-matrix acceptance:

```text
expected/kandahar-controlled-parking-automatic-matrix-acceptance.md
```

## Targeted single-case debug builder

Use this only after the automatic matrix identifies a specific failing case:

```powershell
powershell -ExecutionPolicy Bypass -File `
  .\tools\build-kandahar-controlled-parking-case.ps1 `
  -Case <OH58D|AH64D|UH60|CH47|MQ1|MQ9|HH60G|A10C|C130>
```

The completed OH-58D debug run passed on Heliport TerminalIDs 66 and 82. It is recorded under:

```text
results/2026-08-01-kandahar-controlled-parking-oh58d-pass.md
```
