# Operation Mountain Watch - Bagram current state and Kandahar chat handoff

## Purpose

This main-branch handoff records the current Bagram state and the mandatory starting point for a new Kandahar chat.

The new chat must read both:

```text
main
and the relevant active working branch or branches
```

The detailed Bagram runtime and Mission Editor state is maintained on:

```text
branch: docs/bagram-air-operations-manifest
PR:     #24 - Reconcile Bagram and Kandahar air operations documentation
```

PR #24 remains open, Draft and unmerged. It must not be merged or marked Ready for Review without explicit project-owner approval.

## Mandatory reading before Kandahar work

The new chat must inspect and reconcile at minimum:

```text
docs/00-project-governance.md
mission/tests/GOVERNANCE.md
docs/22-test-mission-build-transfer-and-validation-workflow.md
this handoff on main
this handoff on docs/bagram-air-operations-manifest
PR #24 and its branch-local files
all Kandahar-specific manifests, evidence, ORBAT and Mission Editor audits
all Bagram documents relevant to later Bagram <-> Kandahar integration
the actual vendored MOOSE 2.9.18 source used by the project
```

Do not assume that `main` contains every accepted branch-local runtime result. Do not invent names, inventories, templates or Mission Editor contracts. MOOSE-first remains binding.

## Current Bagram baseline

```text
AIRWING:   AW_US_BAGRAM
Warehouse: WH_AIR_US_BAGRAM
```

Binding logical inventory:

```text
13 F-15E
13 F-16C
20 C-130-family transport aircraft
 6 HH-60G-role aircraft
10 UH-60 utility aircraft
13 CH-47 aircraft
----------------
75 total
```

Binding SQUADRON names:

```text
SQ_US_BGRM_F15E_335_EFS
SQ_US_BGRM_F16C_121_EFS
SQ_US_BGRM_C130_774_EAS
SQ_US_BGRM_HH60G_83_ERQS
SQ_US_BGRM_UH60_A_1_169
SQ_US_BGRM_CH47_B_7_158
```

Binding template group names:

```text
TPL_AIR_US_BGRM_F15E_CAS_2SHIP
TPL_AIR_US_BGRM_F16_CAS_2SHIP
TPL_AIR_US_BGRM_C130_TRANSPORT_1SHIP
TPL_AIR_US_BGRM_HH60G_CSAR_1SHIP
TPL_AIR_US_BGRM_UH60_UTILITY_1SHIP
TPL_AIR_US_BGRM_CH47_TRANSPORT_1SHIP
```

## Accepted and partial Bagram results

Accepted:

```text
Bagram AIRWING / six-SQUADRON baseline: PASS
HH-60G isolated controlled spawn and cleanup: PASS
```

Latest large movement test:

```text
Bagram -> Jalalabad
2 x F-15E two-ship
2 x F-16C two-ship
4 x C-130 one-ship
8 groups / 12 aircraft
```

Classification:

```text
PARTIAL PASS - movement proven / destination capacity insufficient
```

The run proved recruitment, stock reduction, spawn, taxi, departure and movement toward Jalalabad. At least one F-16 landed and parked. No complete two-ship group had completed arrival when the test harness reached its lifecycle timeout.

Jalalabad was unsuitable for a wave of this size because of short runway, inadequate parallel taxiway capacity, runway backtracking, long runway occupancy and insufficient transient parking.

The global despawn was caused by the test harness fail-cleanup at timeout. It was not normal AIRWING behavior.

Detailed result on the Bagram branch:

```text
mission/tests/bagram-air-operations/results/2026-07-31-bagram-jalalabad-fixed-wing-movement-partial-pass.md
```

## Provisional Bagram Mission Editor revision

The project owner supplied:

```text
OMW_Template_v4_Bagram(5).miz
```

Intended model substitutions while preserving functional names:

```text
F-15E -> F-15ESE
F-16C -> F-16C_50
C-130 transport -> C-130J-30
CH-47 transport -> CH-47Fbl1
HH-60G role representation remains UH-60A
UH-60 utility remains UH-60A
```

Static C-130 decision:

```text
STATIC_AIR_US_BGRM_C130_01 -> Vanilla C-130, Compass Call representation
STATIC_AIR_US_BGRM_C130_02 -> Vanilla C-130, Compass Call representation
STATIC_AIR_US_BGRM_C130_03 -> C-130J-30 transport representation
STATIC_AIR_US_BGRM_C130_04 -> C-130J-30 transport representation
STATIC_AIR_US_BGRM_C130_05 -> C-130J-30 transport representation
STATIC_AIR_US_BGRM_C130_06 -> Vanilla C-130, Compass Call representation
STATIC_AIR_US_BGRM_C130_07 -> Vanilla C-130, Compass Call representation
```

The Vanilla C-130 statics are visual stand-ins for EC-130H Compass Call aircraft and are not extra active transport inventory.

Preliminary payload finding:

```text
F-15ESE fighter payload definitions present
F-16C_50 fighter payload definitions present
C-130J-30 transport pylons empty/unarmed
CH-47F transport pylons empty/unarmed
UH-60A templates pylons empty/unarmed
```

The revised mission still requires runtime validation after the model substitutions. Future validation must inspect template type, unit count, pylon count, CLSIDs, fuel and module-specific aircraft properties.

## Open Bagram work

- correct the destructive global timeout cleanup;
- improve per-aircraft and per-group lifecycle telemetry;
- recognize go-around as a valid intermediate state;
- avoid despawning airborne/inbound/landing/taxiing groups at timeout;
- refine type-specific parking/ramp policy;
- runtime-validate the revised module-model templates and payloads;
- use Jalalabad only for small arrival tests;
- reserve full mass-transfer acceptance for a capable destination such as Kandahar.

## Why Kandahar is next

Kandahar is the appropriate next major implementation target and the later destination for a proper Bagram mass-transfer test. Kandahar AIRWING/SQUADRON runtime is not implemented yet.

Required work sequence:

1. inventory Kandahar documentation on main and open branches;
2. resolve authority conflicts and superseded values;
3. inspect the actual Kandahar Mission Editor state;
4. confirm warehouse, AIRWING, SQUADRON, client, template and static names;
5. confirm exact model substitutions and payloads;
6. prevent double-counting Tarinkot and other detached RC-South assets;
7. survey runway, taxiway and parking capacity;
8. inspect vendored MOOSE APIs;
9. implement the smallest fail-closed runtime baseline;
10. validate Kandahar before Bagram -> Kandahar mass transfer.

## First instruction for the new chat

```text
Continue Operation Mountain Watch with Kandahar AIRWING/SQUADRON preparation.

Before proposing or changing anything, read the current project documentation on main and the relevant open branches, especially docs/handoffs/2026-07-31-bagram-current-state-and-kandahar-chat-handoff.md and PR #24. Reconcile Kandahar-specific manifests, evidence, ORBAT and Mission Editor audits. Follow MOOSE-first and inspect the actual vendored MOOSE 2.9.18 source before custom Lua. Do not invent names or inventories. Do not merge or mark any PR Ready for Review without explicit approval.

Start with a documented Kandahar bestandsaufnahme: current branch/PR structure, authoritative documents, existing Mission Editor objects, AIRWING/SQUADRON/warehouse naming, inventories, templates, statics, parking/runway/taxiway capacity, conflicts, and the next smallest implementation step.
```

This chat remains the Bagram working thread. Kandahar continues in a separate chat. Later Bagram corrections return to this thread or an explicitly linked Bagram successor.
