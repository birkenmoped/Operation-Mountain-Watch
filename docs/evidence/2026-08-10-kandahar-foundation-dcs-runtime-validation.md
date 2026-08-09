---
document_id: OMW-EVIDENCE-KANDAHAR-FOUNDATION-DCS-RUNTIME-2026-08-10
status: ACCEPTED_TECHNICAL_BASELINE
document_class: TEST_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - Kandahar foundation DCS runtime acceptance for the exact documented artifact chain
  - Kandahar AIRWING start and SQUADRON registration result
  - Kandahar foundation no-tasking boundary for this exact run
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/kandahar-foundation-july-2011-rebuild
source_commit: 578816472c53279290ff6b64296ed8d49982bc72
acceptance_branch: agent/kandahar-foundation-july-2011-rebuild
acceptance_commit: 578816472c53279290ff6b64296ed8d49982bc72
acceptance_mission: OMW_Template_v6_Tarinkot(6).miz
acceptance_mission_sha256: a04ff328e3c1c550db0ada4ea34d6b66739f3f28eb71293f398330a46eacbc63
dcs_version: 2.9.28.26385
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
validated_in_dcs: true
---

# Kandahar Foundation – DCS Runtime Validation 2026-08-10

## Classification

```text
PASS
```

This PASS is limited to the Kandahar AIRWING/SQUADRON foundation start gate. It does not validate tactical tasking, recovery, post-landing parking, persistence, multiplayer endurance or MC-12 representation.

## Exact artifact chain

```text
Branch: agent/kandahar-foundation-july-2011-rebuild
Source commit: 578816472c53279290ff6b64296ed8d49982bc72
BuilderVersion: KAF-AIR-OPS-FOUNDATION-ONLY-1

MIZ: OMW_Template_v6_Tarinkot(6).miz
MIZ SHA-256: a04ff328e3c1c550db0ada4ea34d6b66739f3f28eb71293f398330a46eacbc63
Internal mission SHA-256: 69ce449e59f710c3ddc48027d50521f37068e673874ec324b8f8f136c220e05a

Embedded Kandahar bundle:
l10n/DEFAULT/OMW_AirOps_Kandahar.lua
SHA-256: 315d046fc781d71de66e11557f0bf000ea672332dfbaf09b85771a4660cc36e4

Embedded Moose.lua:
l10n/DEFAULT/Moose.lua
SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

DCS log SHA-256: db7c5c3b24439a8505e51e024cf4b9e7e050cdc9bef9bbf6806a5bbe6e93ed76
Debrief SHA-256: 48a56ae6393f556cd2b0619fb3a56ad8f1291ad05f35f46c8c88603cb6e461ac
DCS version: 2.9.28.26385
```

The embedded Kandahar bundle SHA-256 exactly matches the locally built bundle previously verified for source commit `578816472c53279290ff6b64296ed8d49982bc72`.

## Runtime result

The current test run initialized the new foundation at 2026-08-09 23:34 local log time. All nine intended SQUADRONs were registered:

```text
AW_US_KAF_451_AEW
- SQ_US_KAF_A10C_74_EFS       8 groups x 2 = 16
- SQ_US_KAF_HH60G_26_ERQS     6 groups x 1 = 6
- SQ_US_KAF_C130_772_EAS     12 groups x 1 = 12
- SQ_US_KAF_MQ1_361_ERS       4 groups x 1 = 4
- SQ_US_KAF_MQ9_361_ERS       2 groups x 1 = 2

AW_US_KAF_159_CAB_TF_THUNDER
- SQ_US_KAF_AH64_4_227_AVN    4 groups x 2 = 8
- SQ_US_KAF_OH58D_7_17_CAV    8 groups x 2 = 16
- SQ_US_KAF_CH47_7_101_GSAB  16 groups x 1 = 16
- SQ_US_KAF_UH60_7_101_GSAB  16 groups x 2 = 32
```

Observed pre-start MOOSE warehouse stock entries:

```text
Main AIRWING:     32
Heliport AIRWING: 44
Total groups:     76
Total airframes: 112
```

MQ-1 and MQ-9 mission capabilities were registered but their role payloads remained explicitly deferred for ISR payload reconciliation. The other pools produced eight registered role payload entries in total.

Both AIRWINGs started successfully:

```text
AW_US_KAF_451_AEW
Airbase: Kandahar
Airbase ID: 7

AW_US_KAF_159_CAB_TF_THUNDER
Airbase: Kandahar Heliport
Airbase ID: 15
```

Final runtime marker:

```text
[OMW][AirOps.KAF.Foundation] RESULT status=RUNNING airwings=2 squadrons=9 registeredGroups=76 registeredAirframes=112 deferredMC12=6 rolePayloads=8 deferredRolePayloads=2 mainRunning=true heliportRunning=true missionsCreated=0 transportsCreated=0 commanderCreated=false f10Controls=false
```

## Negative evidence and scope boundary

For the current 23:34 test window, no `SQ_US_KAF` dynamic spawn/Birth or Kandahar mission-dispatch event was found in the DCS log, and the debrief contains no `SQ_US_KAF` or `AW_US_KAF` runtime entity entries. This is consistent with the foundation-only no-tasking contract.

No Kandahar-specific Lua/MOOSE error or traceback was found after the foundation start marker.

The DCS log does contain unrelated environment/module errors, including OH-58D damage-model/resource errors after the local player was spawned and a `bhHook.lua` shutdown error (`tcp` nil). These are not emitted by `OMW_AirOps_Kandahar.lua` and are not evidence of a Kandahar foundation failure.

## Acceptance boundary

Validated by this exact run:

```text
embedded bundle identity: PASS
embedded Moose.lua identity: PASS
nine Kandahar SQUADRON registrations: PASS
76 registered MOOSE asset groups: PASS
112 registered physical airframes: PASS
MC-12 deferred count 6: PASS
role payloads 8 plus two ISR deferrals: PASS
451st AEW AIRWING start: PASS
159th CAB / TF Thunder AIRWING start: PASS
foundation no-tasking boundary: PASS
Kandahar-specific Lua/MOOSE errors: none observed
```

Not validated by this run:

```text
production AUFTRAG dispatch
OPSTRANSPORT
COMMANDER/CHIEF
recovery / RTB
post-landing UAV parking enforcement
warehouse return/reconciliation after landing
persistent loss/recovery state
multiplayer/endurance behavior
MC-12 physical representation
```

This result is valid only for the exact source, mission, embedded bundle, DCS and MOOSE hashes recorded above.
