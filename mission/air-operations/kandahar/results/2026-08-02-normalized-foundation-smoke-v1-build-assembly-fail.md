# Kandahar normalized AirOps foundation smoke V1 — builder assembly failure

Date: `2026-08-02`

Status: `FAIL_BEFORE_KANDAHAR_FOUNDATION_EXECUTION`

## Evidence

```text
dcs(118).log
size: 2,005,627 bytes
SHA-256: 5bb614156c9f021a496517b3bfa5ed4e84d67c44ba4463cda19e4a544834861c

debrief(71).log
size: 557,707 bytes
SHA-256: a01659477697f1ae564a3fb98fb60687b220bb7e6cc1064ad1fbd3b6cf546d10
```

DCS build:

```text
2.9.28.26385
```

Mission:

```text
C:\Users\Sven\Saved Games\DCS.openbeta\Missions\OMW_Template_v4_Kandahar.miz
```

Mission duration recorded by debrief:

```text
98.188 seconds
```

## Failure

At mission initialization DCS rejected the generated file:

```text
2026-08-02 00:03:23.579 ERROR SCRIPTING:
Mission script error: [string "l10n/DEFAULT/OMW_AIROPS_KANDAHAR.lua"]:13:
unexpected symbol near ']'
```

No Kandahar normalized-foundation `BEGIN` or `RESULT` line followed. Therefore none of the Kandahar bundle stages executed during this smoke run:

```text
RegistrationPreflight: not executed by normalized file
ParkingContract: not executed by normalized file
UAVParkingContract: not executed by normalized file
UAVAssetParkingSync: not executed by normalized file
Foundation AIRWING start: not executed
```

The later Jalalabad and Bagram output belongs to the pre-existing mission baseline and does not constitute Kandahar foundation acceptance.

## Root cause

Builder version 1 placed the source-file pipeline directly inside the `$parts` array used by `[string]::Join()`:

```powershell
($sources | ForEach-Object { Get-Content -LiteralPath $_ -Raw })
```

The generated bundle contained a PowerShell object-array type string rather than five flattened Lua source strings. The closing square brackets in that text caused the Lua parser failure reported near `]`.

## Correction

Builder version 2:

```text
OMW-AIROPS-KANDAHAR-FOUNDATION-2
```

uses explicit `List[string]` collections for source text and output parts, appends every source individually, and rejects these assembly-corruption tokens before writing:

```text
System.Object[]
System.String[]
System.Collections.Generic.List
```

It also verifies required tokens after assembly and reads the written output back for exact equality.

## Debrief boundary

The debrief contains:

```text
graveyard = {}
```

and no `SQ_US_KAF_*` runtime group names. This does not prove the intended no-tasking foundation behavior because the Kandahar Lua never parsed. It only confirms that this failed run produced no Kandahar-managed dynamic aircraft before mission end.

## Acceptance decision

```text
Normalized foundation smoke V1: FAIL
AIRWING/SQUADRON component acceptance: unchanged
Production bundle runtime acceptance: pending V2 retest
PR merge: blocked until V2 smoke PASS
```
