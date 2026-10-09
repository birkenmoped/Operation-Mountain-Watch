---
document_id: OMW-FSSR-PRODUCTION-BASE-ACCEPTANCE3-OWNER-PERIMETER-DCS-RUN-2026-09-13
status: DIAGNOSTIC_FAIL
document_class: TEST_RESULT
owning_policy: OMW-GOV-001
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: 1ea9ac12bd07ae11a4aa02babb4b7b074c959c84
validated_in_dcs: false
---

# Production Base Acceptance 3 – owner-defined perimeter DCS run, 2026-09-13

## Provenance

Owner-reported local build and hash verification before this DCS run:

```text
GitCommit: 1ea9ac12bd07ae11a4aa02babb4b7b074c959c84
ProductionBundleSHA256: CEF9C47E24E31AA951E88BFB312C2E0AF00E72653D590F0035D58A078F509E3D
AcceptanceBundleSHA256: C4ED2FA514744526D6479145392A7EF41BABE2AA8108E402B3C5C69F95B3EAF9
MOOSERelease: 2.9.18
MOOSECommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
MooseLuaSHA256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
DCS: 2.9.29.27468 MT
```

The owner observation was: **no QRF spawned**.

## What the log proves

The corrected owner-defined perimeter setup started and the six Guard organisations materialized and moved. The six RED fixtures were then physically routed toward the alarm perimeters.

At 11:19:56 DCS log time, Honaker crossed into the qualified proximity path. The authoritative Base incident opened, but QRF AUFTRAG creation immediately failed inside the pinned MOOSE `AUFTRAG:NewONGUARD()` target conversion:

```text
[OMW][FireSupStratResupply.Base] incident opened ... siteId=COP_HONAKER
Error in SCHEDULER function: ... Moose.lua:180727: attempt to call method 'IsInstanceOf' (a nil value)
stack traceback:
  Moose.lua:38658: in function 'IsInstanceOf'
  Moose.lua:180727: in function '_TargetFromObject'
  Moose.lua:177755: in function 'NewONGUARD'
  OMW_FireSupStratResupply_Production_Base_Acceptance_3.lua:1032
```

The same failure repeated for Bostick, Joyce, Wright, Fortress and, after the acceptance timeout message, Jalalabad.

The later telemetry showed five sites with `proximity=true`, `incident=true`, `demandCount=1`, but `qrfObserved=nil`. Jalalabad reached its incident only immediately after the harness emitted its timeout message. `demandCount=1` does not prove dispatch: Base appends the demand ID to the incident before entering the support adapter dispatch path.

## Root cause

This is not a MOOSE recruitment shortage and not a missing QRF asset. The log shows local QRF `Ground_APC` assets were present in the BRIGADE stock.

The acceptance perimeter incident intentionally stores a serializable copied DCS Vec3 table in `incident.context.position`. The Acceptance-3 `resolveQrfCoordinate` callback returned that plain Vec3 table unchanged. The QRF factory then called the public MOOSE API:

```text
AUFTRAG:NewONGUARD(coordinate)
```

Pinned `Moose.lua` documents `NewONGUARD` as accepting a MOOSE `COORDINATE`; internally `_TargetFromObject()` calls `Object:IsInstanceOf(...)`. A plain Vec3 does not provide that MOOSE method, which explains the exact runtime error.

Pinned MOOSE also provides the public conversion:

```text
COORDINATE:NewFromVec3(Vec3)
```

Therefore the correction belongs at the Acceptance runtime boundary that resolves the strategic/serializable incident position into the physical MOOSE mission coordinate. No native DCS replacement and no MOOSE override are required.

## Correction

Follow-up commit `edf90478490a9828957cca18e8f13ee4554fffda` changes the Acceptance-3 `resolveQrfCoordinate` callback to convert `incident.context.position` using public `COORDINATE:NewFromVec3(...)` before `AUFTRAG:NewONGUARD()` is called.

The same change extends the acceptance timeout from 720 to 900 mission seconds. This is test-harness timing only. The observed run emitted `TIMEOUT_INCOMPLETE_SIX_SITE_PHYSICAL_CHAIN` and then qualified Jalalabad roughly 0.1 seconds of wall-clock log time later, so the previous timeout could race the 120-second OPSZONE evaluation cadence even after the QRF coordinate defect is corrected.

## Status

```text
owner-defined alarm geometry: runtime observed
six Guard materialization/movement: runtime observed
physical fixture routing: runtime observed
PROXIMITY_INTRUSION: observed at all six sites, Jalalabad just after timeout
Base incidents: observed at all six sites
QRF demand bookkeeping: observed
QRF AUFTRAG creation: FAILED due plain Vec3 passed to NewONGUARD
QRF physical spawn/execution: NOT OBSERVED in this run
Acceptance 3: FAIL / diagnostic only
```

A new local build/hash verification is required because the Acceptance source changed. The next DCS run must use the newly built Acceptance bundle and must not reuse the hash from commit `1ea9ac12...`.
