---
document_id: OMW-EVIDENCE-KANDAHAR-FOUNDATION-LOCAL-BUILD-2026-08-10
status: HISTORICAL_TEST_FIXTURE
document_class: TEST_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - local reproducible Kandahar foundation build result for the exact documented commits
  - Kandahar generated bundle SHA-256 values for the exact documented commits
  - lifecycle-guard results for the exact documented commits
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/kandahar-foundation-july-2011-rebuild
source_commit: 578816472c53279290ff6b64296ed8d49982bc72
validated_in_dcs: false
---

# Kandahar Foundation – Local Build Validation 2026-08-10

## Scope

This evidence records the real local PowerShell build and hash output supplied by the project owner. It is static/local build evidence only and does not independently claim DCS runtime validation. The later DCS acceptance is recorded separately in `2026-08-10-kandahar-foundation-dcs-runtime-validation.md`.

## Initial local build

```text
Branch: agent/kandahar-foundation-july-2011-rebuild
Commit: 865c479cacd6bfb1973dd03a4f46fb4489183cb7
BuilderVersion: KAF-AIR-OPS-FOUNDATION-ONLY-1
Scope: AIRWING_SQUADRON_FOUNDATION_ONLY
```

The real local builder output reported:

```text
AirOps lifecycle guard: PASS
Airwings: 2
Squadrons: 9
RegisteredAirframes: 112
DeferredMC12: 6
RolePayloadsExpected: 8
DeferredRolePayloads: 2
LifecycleGuard: PASS
TestDispatch: ABSENT
AUFTRAGInstances: ABSENT
OPSTRANSPORTInstances: ABSENT
Commander: ABSENT
```

Builder-reported and independently confirmed bundle SHA-256:

```text
ece0625f9a920568332796042b6262939da369de63006ae993284fbc9f6a2f75
```

Source bootstrap SHA-256 from this initial build check:

```text
scripts/air-operations/OMW_AirOps_Kandahar_Bootstrap.lua
A5A9EC8FA6025A18900C050579954021E3B7117FC87B84954E4FC610F9BA7898
```

## Rebuild for the DCS-test source commit

After the local-build evidence commit was pulled, the project owner rebuilt the bundle against the exact source commit later used for DCS acceptance:

```text
Commit: 578816472c53279290ff6b64296ed8d49982bc72
BuilderVersion: KAF-AIR-OPS-FOUNDATION-ONLY-1
```

The real builder output again reported:

```text
AirOps lifecycle guard: PASS
Airwings: 2
Squadrons: 9
RegisteredAirframes: 112
DeferredMC12: 6
RolePayloadsExpected: 8
DeferredRolePayloads: 2
LifecycleGuard: PASS
TestDispatch: ABSENT
AUFTRAGInstances: ABSENT
OPSTRANSPORTInstances: ABSENT
Commander: ABSENT
```

Builder-reported SHA-256:

```text
315d046fc781d71de66e11557f0bf000ea672332dfbaf09b85771a4660cc36e4
```

Independent `Get-FileHash` confirmed the identical value:

```text
315D046FC781D71DE66E11557F0BF000EA672332DFBAF09B85771A4660CC36E4
```

This second bundle is the artifact embedded in the subsequently accepted DCS mission.

## Working-tree note

The local repository contained generated/untracked test directories. They were not treated as tracked source modifications or acceptance evidence. The relevant Kandahar bundle was identified by its explicit SHA-256 rather than by filename alone.

## Evidence boundary

Confirmed by the local build evidence:

```text
builder execution: PASS
lifecycle guard: PASS
foundation static contract: PASS
bundle hash reproducibility check: PASS
```

Not independently validated by this document:

```text
DCS mission load
AIRWING runtime start
SQUADRON runtime registration
Warehouse runtime behavior
parking behavior
spawn/recovery behavior
multiplayer behavior
persistence
```

The actual DCS foundation acceptance is documented separately with the complete Mission/MOOSE/log hash chain.
