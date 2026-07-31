# Operation Mountain Watch - Bagram current state and Kandahar chat handoff

## Purpose

This document freezes the current Bagram work state and provides the mandatory starting context for a new chat that continues with Kandahar.

The new chat must not rely on this handoff alone. It must first inspect the current documentation in both:

```text
main
and the relevant active working branch or branches
```

For Bagram, the active implementation branch at the time of this handoff is:

```text
docs/bagram-air-operations-manifest
```

Pull request:

```text
PR #24 - Reconcile Bagram and Kandahar air operations documentation
```

Protection:

```text
open
draft
unmerged
must not be merged or marked Ready for Review without explicit project-owner approval
```

## Mandatory project rules

Before any Kandahar or later AIRWING implementation:

1. read the applicable documentation on `main`;
2. read the applicable documentation on the active Kandahar/Bagram branch or stacked branch;
3. inspect the actual vendored MOOSE source and matching documentation before writing custom Lua;
4. use existing MOOSE classes and functions wherever they cover the requirement;
5. do not invent Mission Editor names, template names, SQUADRON names, inventories or object contracts;
6. preserve Draft PR and no-merge protections;
7. after every implemented test increment, provide the complete local pull/build/embed/run instruction block required by `docs/22-test-mission-build-transfer-and-validation-workflow.md`.

## Bagram AIRWING baseline

```text
AIRWING:   AW_US_BAGRAM
Warehouse: WH_AIR_US_BAGRAM
```

Binding active inventory:

```text
SQ_US_BGRM_F15E_335_EFS       13 F-15E
SQ_US_BGRM_F16C_121_EFS       13 F-16C
SQ_US_BGRM_C130_774_EAS       20 C-130-family transport aircraft
SQ_US_BGRM_HH60G_83_ERQS       6 HH-60G role aircraft
SQ_US_BGRM_UH60_A_1_169       10 UH-60 utility aircraft
SQ_US_BGRM_CH47_B_7_158       13 CH-47 aircraft
------------------------------------------------
Total logical inventory:      75
```

Fighter implementation split:

```text
F-15E: 6 MOOSE two-ship groups + 1 logical reserve aircraft
F-16C: 6 MOOSE two-ship groups + 1 logical reserve aircraft
```

Templates:

```text
TPL_AIR_US_BGRM_F15E_CAS_2SHIP
TPL_AIR_US_BGRM_F16_CAS_2SHIP
TPL_AIR_US_BGRM_C130_TRANSPORT_1SHIP
TPL_AIR_US_BGRM_HH60G_CSAR_1SHIP
TPL_AIR_US_BGRM_UH60_UTILITY_1SHIP
TPL_AIR_US_BGRM_CH47_TRANSPORT_1SHIP
```

Current template group sizes:

```text
F-15E: 2
F-16C: 2
C-130: 1
HH-60G representation: 1
UH-60: 1
CH-47: 1
```

## Accepted Bagram runtime results

### AIRWING and six-SQUADRON baseline

Implemented and runtime-proven on the Bagram branch:

- warehouse anchor recognition;
- all six SQUADRON constructions;
- binding inventory registration;
- safe-parking preflight and startup gating;
- no unintended spontaneous missions in the baseline;
- 75-aircraft logical inventory contract.

### HH-60G isolated controlled spawn and cleanup

Status:

```text
PASS
```

The accepted run proved:

- exact HH-60G-role SQUADRON recruitment;
- one spawned aircraft;
- delayed recruitment/spawn around 60 seconds rather than the earlier 45-second assumption;
- controlled cleanup;
- stock restoration;
- no permanent asset loss.

Authoritative result:

```text
mission/tests/bagram-air-operations/results/2026-07-30-bagram-hh60g-controlled-spawn-cleanup-pass.md
```

## Bagram to Jalalabad fixed-wing movement result

Test wave:

```text
2 x F-15E two-ship groups
2 x F-16C two-ship groups
4 x C-130 one-ship groups
8 groups / 12 aircraft
```

Classification:

```text
PARTIAL PASS - movement proven / destination capacity insufficient
```

Proven:

- multi-squadron recruitment;
- eight groups and twelve aircraft created;
- warehouse stock reduced correctly;
- Bagram spawn, taxi, departure and dispatch worked;
- multiple aircraft reached the Jalalabad arrival sequence;
- at least one F-16 landed and parked.

Observed at cleanup:

```text
first F-15E lead: go-around before touchdown
first F-16 of a two-ship: landed and parked
second F-16 of that group: short final
complete arrived groups: 0
```

Jalalabad proved unsuitable for a mass-transfer wave of this size because of:

- short runway;
- inadequate parallel taxiway capacity;
- required runway backtracking;
- long runway occupancy;
- limited transient parking;
- insufficient capacity for all twelve aircraft.

The global despawn was caused by the test harness reaching its lifecycle timeout and invoking fail-cleanup for all surviving groups. It was not normal AIRWING behavior and was not triggered by a completed group.

Authoritative result:

```text
mission/tests/bagram-air-operations/results/2026-07-31-bagram-jalalabad-fixed-wing-movement-partial-pass.md
```

## Open Bagram harness defects

Before the large transfer harness is reused:

- do not globally despawn airborne, inbound, landing or taxiing groups on timeout;
- make timeout diagnostic first;
- record lifecycle per aircraft and per group;
- explicitly recognize go-around as an intermediate state;
- improve airborne-state telemetry;
- require complete group arrival for a two-ship PASS;
- choose a destination with adequate capacity.

The current large Bagram-to-Jalalabad test switch must not be treated as a production mission feature.

## Current Mission Editor asset revision

The project owner supplied a provisional revised Bagram mission:

```text
OMW_Template_v4_Bagram(5).miz
```

Naming intent:

- preserve all existing functional names one-to-one;
- replace limited Vanilla visual models with module models where useful;
- retain platform role and SQUADRON identity.

Observed intended substitutions:

```text
F-15E templates/statics: F-15ESE
F-16 templates/statics:  F-16C_50
C-130 transport template: C-130J-30
CH-47 transport template: CH-47Fbl1
HH-60G role template: UH-60A representation remains
UH-60 utility template: UH-60A remains
```

The exact DCS type is important for spawn templates. The SQUADRON name alone does not determine the aircraft type. MOOSE clones the Mission Editor template type and its payload/properties.

Functional names that must remain stable unless code and documentation are changed together include:

```text
WH_AIR_US_BAGRAM
all six TPL_AIR_US_BGRM_* template group names
all six SQ_US_BGRM_* SQUADRON names
```

## Static C-130 representation decision

The apparent mixed C-130 static inventory is intentional.

```text
STATIC_AIR_US_BGRM_C130_01 -> Vanilla C-130, Compass Call representation
STATIC_AIR_US_BGRM_C130_02 -> Vanilla C-130, Compass Call representation
STATIC_AIR_US_BGRM_C130_03 -> C-130J-30 transport representation
STATIC_AIR_US_BGRM_C130_04 -> C-130J-30 transport representation
STATIC_AIR_US_BGRM_C130_05 -> C-130J-30 transport representation
STATIC_AIR_US_BGRM_C130_06 -> Vanilla C-130, Compass Call representation
STATIC_AIR_US_BGRM_C130_07 -> Vanilla C-130, Compass Call representation
```

The Vanilla C-130 statics are visual stand-ins for EC-130H Compass Call aircraft. They are not additional active C-130 transport SQUADRON inventory.

## Payload finding after module-model substitutions

Preliminary mission inspection found:

```text
F-15ESE fighter template: payload definitions present
F-16C_50 fighter template: payload definitions present
C-130J-30 transport template: pylons empty / unarmed
CH-47F transport template: pylons empty / unarmed
UH-60A templates: pylons empty / unarmed
```

The major remaining risk is not merely an empty payload table. It is compatibility of stored CLSIDs, module-specific aircraft properties, internal gun/ammunition defaults and MOOSE `AIRWING:NewPayload()` behavior after model substitution.

Required future validator extension:

```text
template name
DCS unit type
unit count
pylon count
CLSID list
fuel
AddPropAircraft/module properties
```

The revised mission has not yet received a complete DCS runtime acceptance after these model substitutions.

## Parking finding

The first fixed-wing wave showed that technically valid Bagram parking may still be visually or operationally inappropriate, for example a fighter appearing among parked helicopters.

Future Bagram work should use type-specific parking/ramp policy where MOOSE supports it or where a documented minimal project-side restriction is required:

```text
fighters -> fighter ramp
C-130 -> heavy/transport ramp
rotary wing -> helicopter ramp
```

The MOOSE-first rule applies before custom parking-selection logic is written.

## Why Kandahar is next

No additional Bagram test blocks beginning Kandahar documentation and implementation.

Kandahar is the appropriate next major airfield because:

- it is already part of the documented OMW airfield plan;
- it is a much better candidate than Jalalabad for later mass-transfer testing;
- a later Bagram to Kandahar transfer can validate the full 8-group / 12-aircraft wave under adequate runway, taxiway and parking conditions;
- Kandahar AIRWING/SQUADRON runtime is not implemented yet and must be built before that test.

## Mandatory starting point for the new Kandahar chat

The new chat must begin by reading and reconciling, at minimum:

```text
main documentation
this handoff on main
this handoff on docs/bagram-air-operations-manifest
PR #24 and its current branch files
docs/00-project-governance.md
mission/tests/GOVERNANCE.md
docs/22-test-mission-build-transfer-and-validation-workflow.md
all Kandahar-specific manifests, evidence, ORBAT and Mission Editor audit documents
all Bagram documents relevant to later Bagram <-> Kandahar integration
actual vendored MOOSE 2.9.18 source used by the project
```

Do not assume that `main` alone contains every accepted branch-local result. Do not assume that PR #24 may be merged. Do not start Lua implementation before the Kandahar Mission Editor object contract and inventory are reconciled.

## Recommended Kandahar work sequence

1. inventory all Kandahar documents on `main` and open branches;
2. identify authority conflicts and superseded values;
3. inspect the actual current Kandahar `.miz` or prepared Mission Editor state;
4. confirm warehouse anchor, AIRWING name, SQUADRON names, client groups, templates and statics;
5. confirm exact DCS model substitutions and payloads;
6. establish local logical inventory without double-counting Tarinkot or other detached RC-South assets;
7. survey parking, runway and taxiway capacity;
8. inspect vendored MOOSE APIs for AIRWING, SQUADRON, parking, AUFTRAG and transport behavior;
9. implement the smallest fail-closed runtime baseline;
10. validate Kandahar locally before any Bagram-to-Kandahar mass-transfer test.

## First instruction to paste into the new chat

```text
Continue Operation Mountain Watch with Kandahar AIRWING/SQUADRON preparation.

Before proposing or changing anything, read the current project documentation on main and the relevant open branches, especially docs/handoffs/2026-07-31-bagram-current-state-and-kandahar-chat-handoff.md and PR #24. Reconcile Kandahar-specific manifests, evidence, ORBAT and Mission Editor audits. Follow MOOSE-first and inspect the actual vendored MOOSE 2.9.18 source before custom Lua. Do not invent names or inventories. Do not merge or mark any PR Ready for Review without explicit approval.

Start with a documented Kandahar bestandsaufnahme: current branch/PR structure, authoritative documents, existing Mission Editor objects, AIRWING/SQUADRON/warehouse naming, inventories, templates, statics, parking/runway/taxiway capacity, conflicts, and the next smallest implementation step.
```

## Chat separation

This chat remains the Bagram working thread. Kandahar work should continue in a separate chat using this handoff. Later Bagram corrections, model-substitution validation, parking refinement and transfer-harness repairs should return to this Bagram thread or an explicitly linked Bagram successor.
