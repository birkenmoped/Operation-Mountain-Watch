---
document_id: OMW-RESULT-GATE5-ACCEPTANCE2-BUILDER4-DCS-PASS-2026-09-12
status: VALIDATED
document_class: TEST_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - exact Gate-5 Acceptance-2 Builder-4 DCS runtime result observed on 2026-09-12
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: true
---

# Gate 5 Acceptance 2 - Builder 4 DCS PASS 2026-09-12

## Provenance

Owner-local source HEAD used for the build:

```text
a7944a995954a962d2a3b33b7a6d4c459d845f1e
```

Builder:

```text
FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE5-SIX-SITE-GUARD-RUNTIME-4
```

TestId:

```text
FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE5-SIX-SITE-GUARD-RUNTIME-ACCEPTANCE-2
```

Pinned MOOSE:

```text
commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Owner-local build evidence:

```text
SpawnAlignment: PATHLINE_FIRST_SEGMENT
GuardAccessZoneDependency: none
Formation: Off Road
FormationIntervalM: 2
Encoding: UTF-8 without BOM
MIZ mutation: false
```

Hashes returned by the project owner:

```text
Bundle SHA-256:
E1CBF5341D608714C912380FA4806D73BFBF42BBE5F2D0E8513298C96555E9DC

Acceptance-2 source SHA-256:
DDADEA6531EA05A31E836EC0AC35319F83673B9AC4B16D2465A9E218E2C1AE36

Builder SHA-256:
BC6A28F1D167BB4DF768D8FB3F6FAAE60468B7111C77313BCE9715E1186D4D59
```

The uploaded post-test mission copy `OMW_Template_v24_GroundWorks_base(2).miz` had SHA-256:

```text
865BCB91FD3EF8F81E71E3ACEF0E0E0A7BF74737117549F7E059815C94929F91
```

This mission hash is recorded only as provenance for the uploaded test copy. ChatGPT did not mutate the `.miz`.

## DCS runtime evidence

The corrected Acceptance-2 runtime materialized all six Guards with the compact Warehouse adapter using the first Guard-PATHLINE segment as the spawn and heading reference. The runtime reported:

```text
[GATE 5][PASS] 6/6 Guards compact/aligned and >=25 m movement observed
```

Final reported movement values at the acceptance checkpoint:

```text
JALALABAD_FENTY   alive=true  routeStarted=true  movementM=176.2
COP_FORTRESS      alive=true  routeStarted=true  movementM=195.1
FOB_JOYCE         alive=true  routeStarted=true  movementM=195.6
FOB_WRIGHT        alive=true  routeStarted=true  movementM=235.0
COP_HONAKER       alive=true  routeStarted=true  movementM=165.6
FOB_BOSTICK       alive=true  routeStarted=true  movementM=137.1
```

All six therefore exceeded the required 25 m movement within the 300-second observation window while alive and with `routeStarted=true`.

Subsequent telemetry showed continued movement of all six groups, which is additional evidence that the groups were not merely completing a short initial displacement.

## Visual owner observation

After the log-based PASS was reviewed, the project owner confirmed for the same run:

```text
No problems could be identified visually.
```

This satisfies the Acceptance-2 visual criterion that no obvious soldier is stuck in HESCOs, buildings or other statics during spawn and initial movement and that no obvious formation problem is visible.

## Result

```text
6/6 compact PATHLINE-aligned materialization: PASS
6/6 alive: PASS
6/6 routeStarted: PASS
6/6 >=25 m within 300 s: PASS
Visual obstacle/formation check: PASS
Convoy ACCESS dependency: none
Gate 5 Acceptance 2 exact scope: VALIDATED / PASS
```

## Scope boundary

This PASS validates only the documented Gate-5 Acceptance-2 compact Guard materialization/runtime scope for the exact build and evidence above. It does not constitute productive general approval of the private MOOSE Warehouse materializer and does not validate QRF, ARTY, CAS, resupply, CampaignState settlement or generic six-site incident response.