# FOB Salerno Air Operations – Read-only Diagnostics

## Scope

This test validates only the Mission Editor contract for FOB Salerno. It does not create AIRWING or SQUADRON objects, does not spawn aircraft and does not mutate parking, warehouse, payload or mission state.

## Builder

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File ".\tools\build-salerno-air-operations-bundle.ps1"
```

Output:

```text
mission/tests/salerno-air-operations/dist/OMW_AirOps_Salerno_Diagnostics.lua
```

## Mission Editor integration

Open the current OMW template and add the generated bundle as the final `MISSION START -> DO SCRIPT FILE` action after Moose.lua and all existing project bundles. Re-select the generated file and save the mission after every rebuild.

## Runtime

Run for at least 15 seconds. The test completes when the log contains:

```text
[OMW][SALERNO][DIAG] COMPLETE status=PASS
```

A FAIL result, Lua error, missing airbase, wrong airbase ID, missing warehouse, missing client/template or missing CSAR unload zone is a failed test.

Provide the resulting `dcs.log`. For the first embedding also provide the tested `.miz` so the trigger order and embedded bundle can be verified.
