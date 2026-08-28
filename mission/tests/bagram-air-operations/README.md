---
document_id: OMW-TEST-BAGRAM-AIR-OPERATIONS-INDEX
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - Bagram dual-AIRWING foundation test history
  - Bagram parking-policy correction provenance
not_authoritative_for:
  - current production parking allocation
  - tactical tasking
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/bagram-parking-policy-integration
source_commit: GIT_HISTORY
validated_in_dcs: partial
supersedes:
superseded_by:
---

# Bagram Air Operations / Parking

## Current production direction

The production base is now:

```text
scripts/air-operations/OMW_AirOps_Bagram.lua
```

It is built with:

```text
tools/build-bagram-air-operations-foundation.ps1
```

The generated mission-embeddable base is:

```text
mission/tests/bagram-air-operations/dist/OMW_AirOps_Bagram.lua
```

The owner-authored parking source of truth is:

```text
docs/data/bagram-parking-policy.csv
```

The CSV contains exactly 187 Bagram parking rows with four authoritative fields:

```text
Stellplatzkennung
MOOSE TerminalID
Asset
Status
```

Only `Status=AI` rows are eligible for MOOSE AIRWING parking. `Static`, `Client`, and `BLOCKED` rows are excluded from MOOSE AIRWING parking.

The production builder performs a static CSV-to-Lua equality gate before emitting `OMW_AirOps_Bagram.lua`:

```text
rows=187
AI=69
excluded=118
TerminalIDs unique=187
source parking labels match CSV
source parking IDs match CSV
source blacklist equals every non-AI CSV row
```

No range-based or manually normalized parking assignment is allowed.

## Authoritative parking profiles derived 1:1 from CSV

```text
F-15E AI:
E01 E02 E03 E04 E05 M03 M05 M06 M08 M09 M10 M21 M22 M25 M26

F-16 AI:
M13 M14 M15 M16 M17

MQ-1A AI:
N09 N10 N11

C-130J-30 AI:
S03 S04

UH-60 AI:
N01 N02 N03 N04 N05 N06 N07 N08
P01 P02 P03 P04 P07 P08 P09 P10 P11 P12 P13 P14
R01 R02 R03 R04 R05 R06 R07 R26 R28 R29 R31 R32 R33 R34 R35

CH-47F AI:
R08 R09 R10 R13 R14 R17 R18 R19 R20
```

The OMW HH-60G seed is represented in DCS by `UH-60A`; therefore the production base references the owner-authored `UH-60` parking compatibility profile for the HH-60G SQUADRON. No separate HH-60G parking rows exist in the owner CSV.

## Corrected failure history

The earlier branch implementation was wrong because it replaced the owner-authored per-row allocation with invented contiguous blocks such as:

```text
F-15E -> M01-M12
F-16C -> M13-M24
MQ-1A -> B01-B08
```

That interpretation was not authorized by the project owner and contradicted the supplied CSV. Example:

```text
M22 -> TerminalID 148 -> F-15E -> AI
```

but the old Lua placed TerminalID `148` in the F-16 pool. The 28.08.2026 DCS materialization therefore visibly placed an F-16 on owner-designated F-15E parking. The corresponding physical parking acceptance is not a PASS and must not be used as production evidence.

Earlier technical evidence remains limited to the scopes it actually proved:

```text
TerminalID mapping correlation: retained
MOOSE NewAsset parkingIDs propagation mechanism: retained
Owner-authored aircraft-to-parking allocation: corrected after runtime discrepancy
```

The project owner explicitly decided that no additional DCS parking test will be run for this correction. The corrected production base must therefore be described as statically reconciled to the authoritative CSV, not newly DCS-validated.

## MOOSE-first production path

The base continues to use the verified MOOSE path:

```text
AIRBASE:SetParkingSpotBlacklist(...)
SQUADRON:SetParkingIDs(...)
AIRWING:AddSquadron(...)
AIRWING:OnAfterNewAsset(...)
```

No native spawn path, `SPAWN`, `COMMANDER`, `OPSTRANSPORT`, or test `ALERT5` dispatch is part of the production base.

## Foundation accounting

```text
2 AIRWINGs
7 SQUADRONs
69 MOOSE asset groups
81 represented airframes
83 logical airframes
2 logical fighter reserve airframes
8 role-payload registrations
```

## MOOSE pin

```text
commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## Historical test fixtures

The files below remain only as historical acceptance fixtures and must not define production parking allocation:

```text
scripts/air-operations/OMW_AirOps_Bagram_Bootstrap.lua
mission/tests/bagram-air-operations/src/OMW_Bagram_Parking_Final_Acceptance.lua
mission/tests/bagram-air-operations/src/OMW_Bagram_Parking_Final_Retest_Alert5.lua
tools/build-bagram-parking-final-acceptance.ps1
tools/build-bagram-parking-final-retest.ps1
```

They document the development path, including the ALERT5 recruitment correction and the later discovery that the parking pool itself had been incorrectly normalized. Production authority is the owner CSV plus `scripts/air-operations/OMW_AirOps_Bagram.lua`.
