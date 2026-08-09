---
document_id: OMW-EVIDENCE-KANDAHAR-FOUNDATION-LOCAL-BUILD-2026-08-10
status: ACCEPTED_TECHNICAL_BASELINE
authoritative_for:
  - local reproducible Kandahar foundation build result for the exact documented commit
  - Kandahar generated bundle SHA-256 for the exact documented commit
  - lifecycle-guard result for the exact documented commit
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/kandahar-foundation-july-2011-rebuild
source_commit: 865c479cacd6bfb1973dd03a4f46fb4489183cb7
validated_in_dcs: false
---

# Kandahar Foundation – Local Build Validation 2026-08-10

## Scope

This evidence records only the real local PowerShell build and hash output supplied by the project owner for the exact branch and commit below. It does not claim DCS runtime validation.

```text
Branch: agent/kandahar-foundation-july-2011-rebuild
Commit: 865c479cacd6bfb1973dd03a4f46fb4489183cb7
BuilderVersion: KAF-AIR-OPS-FOUNDATION-ONLY-1
Scope: AIRWING_SQUADRON_FOUNDATION_ONLY
```

## Build result

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

Generated bundle:

```text
mission/tests/kandahar-air-operations/dist/OMW_AirOps_Kandahar.lua
```

Builder-reported SHA-256:

```text
ece0625f9a920568332796042b6262939da369de63006ae993284fbc9f6a2f75
```

Independent `Get-FileHash` confirmed the identical bundle SHA-256:

```text
ECE0625F9A920568332796042B6262939DA369DE63006AE993284FBC9F6A2F75
```

Source bootstrap SHA-256:

```text
scripts/air-operations/OMW_AirOps_Kandahar_Bootstrap.lua
A5A9EC8FA6025A18900C050579954021E3B7117FC87B84954E4FC610F9BA7898
```

The local `git rev-parse HEAD` before and after the build returned:

```text
865c479cacd6bfb1973dd03a4f46fb4489183cb7
```

## Working-tree note

The local repository contained generated/untracked test directories before the Kandahar build:

```text
mission/tests/jalalabad-air-operations/dist/
mission/tests/salerno-air-operations/
mission/tests/tarinkot-air-operations/dist/
```

After the build, the generated Kandahar test directory was additionally untracked:

```text
mission/tests/kandahar-air-operations/
```

No tracked source modification was reported by `git status`. The untracked generated artifacts are not treated as repository source changes or acceptance evidence beyond the explicitly hashed Kandahar bundle above.

## Acceptance boundary

Accepted for this exact commit:

```text
local builder execution: PASS
lifecycle guard: PASS
foundation static contract: PASS
bundle hash reproducibility check: PASS
```

Not validated by this evidence:

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

A DCS runtime result may only be recorded after testing the exact mission artifact, generated bundle, DCS version and pinned MOOSE artifact with a complete hash chain.
