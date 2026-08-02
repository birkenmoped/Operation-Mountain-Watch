---
document_id: OMW-SAL-PARKING-CALIBRATION-001
status: ACCEPTED_TECHNICAL_BASELINE
authoritative_for:
  - Salerno Mission Editor parking label to MOOSE TerminalID mapping
  - Salerno runtime parking-node calibration result
not_authoritative_for:
  - actual AIRWING spawn compliance
  - client exclusion compliance
  - type-specific operational parking acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/salerno-read-only-diagnostics
source_commit: GIT_HISTORY
validated_in_dcs: true
---

# Salerno Parking Calibration – PASS

## Test identity

```text
BuilderVersion: SAL-ME-TERMINAL-CALIBRATION-1
Runtime parking nodes: 44
Resolved mappings: 32
Failures: 0
Result: PASS
```

## Purpose

Determine the actual relationship between Mission Editor parking labels and MOOSE `TerminalID` values at FOB Salerno.

The test was necessary because these number spaces are not interchangeable.

## Confirmed mapping

```text
ME07 -> T08
ME08 -> T13
ME09 -> T14
ME10 -> T15
ME11 -> T16
ME12 -> T17
ME14 -> T09
ME15 -> T10
ME16 -> T11
ME17 -> T12
ME18 -> T21
ME19 -> T22
ME20 -> T19
ME24 -> T41
ME25 -> T42
ME26 -> T43
ME27 -> T44
ME28 -> T45
ME29 -> T32
ME30 -> T33
ME31 -> T34
ME32 -> T35
ME33 -> T36
ME34 -> T37
ME35 -> T38
ME37 -> T26
ME38 -> T27
ME39 -> T28
ME41 -> T30
ME42 -> T31
ME43 -> T23
ME44 -> T24
```

## Client positions

```text
ME13 -> T18   CH-47 client
ME21 -> T20   CH-47 client
ME36 -> T25   AH-64D client
ME40 -> T29   AH-64D client
ME22 -> T39   OH-58D client
ME23 -> T40   OH-58D client
```

## Other critical nodes

```text
ME24 -> T41   static OH-58 area
ME25 -> T42   static OH-58 area
ME35 -> T38   apron access / CSAR unload area
```

## Acceptance boundary

This PASS proves the mapping only. It does not prove that MOOSE or DCS will place every spawned unit at an allowed terminal, preserve a type-specific pool, or avoid a client position during a multi-unit spawn.

Operational parking control is evaluated separately and remains deferred.

## Source artifacts

```text
mission/tests/salerno-air-operations/calibration/01-map-me-parking-to-moose-terminal.lua
tools/build-salerno-parking-calibration.ps1
```
