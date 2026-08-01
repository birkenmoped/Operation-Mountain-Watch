# Bagram handoff addendum - current mission and disabled transfer test

This addendum supplements:

```text
docs/handoffs/2026-07-31-bagram-current-state-and-kandahar-chat-handoff.md
```

## Current Bagram Mission Editor file

The latest Bagram Mission Editor file supplied by the project owner in the Bagram chat was received under the upload name:

```text
OMW_Template_v4_Bagram(5).miz
```

The project owner clarified that this is the newly renamed mission version and that it already contains the latest Bagram Mission Editor state.

Status:

```text
current Bagram Mission Editor working version
contains the latest Bagram asset/template revision
supplied in chat
not committed to the repository
runtime acceptance after all model substitutions still pending
```

This file is the current Bagram Mission Editor baseline for later Bagram work. It is not a Kandahar mission and must not be treated as the Kandahar Mission Editor source of truth.

Observed intended substitutions include:

```text
F-15E templates/statics: F-15ESE
F-16 templates/statics: F-16C_50
C-130 transport template: C-130J-30
CH-47 transport template: CH-47Fbl1
HH-60G role template: UH-60A representation
UH-60 utility template: UH-60A
```

The Vanilla C-130 statics with identifiers 01, 02, 06 and 07 intentionally represent EC-130H Compass Call aircraft and are not additional transport-squadron inventory.

## Automatic Bagram mass-transfer test disabled

The automatic Bagram-to-Jalalabad fixed-wing test wave is disabled by default at branch commit:

```text
9b0095dfaa7cdc4c4c1951f94e29e8c024a54f0a
```

Configuration:

```lua
Tests = {
  HH60GControlledSpawn = false,
  FixedWingBagramToJalalabad = false
}
```

Consequences:

- the Bagram AIRWING and six SQUADRON baseline remain active;
- the fixed-wing transfer harness remains in the source tree for later repair;
- the normal rebuilt Bagram bundle no longer starts the 8-group / 12-aircraft test wave automatically;
- no new Kandahar work should assume that a Bagram mass-transfer is still running by default.

Before using the current Bagram mission again, rebuild and re-embed:

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch
git pull --ff-only
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\tools\build-bagram-air-operations-bundle.ps1
```

Then reselect:

```text
P:\DCS-DEV\Operation-Mountain-Watch\mission\tests\bagram-air-operations\dist\OMW_AirOps_Bagram.lua
```

in the existing Mission Editor `DO SCRIPT FILE` action and save the current Bagram `.miz`.

## F-15E payload decision added on 2026-08-01

The current project-owner-approved F-15E authoring baseline is now documented in:

```text
docs/evidence/bagram-f15e-cas-strike-payload-decision-2026-08-01.md
```

CAS seed per aircraft:

```text
TPL_AIR_US_BGRM_F15E_CAS_2SHIP
ME task: CAS
3 x GBU-54/B
3 x GBU-38
2 x external fuel tank
1 x AIM-9M
1 x AIM-120
LANTIRN navigation pod
Targeting pod
```

Strike seed per aircraft:

```text
TPL_AIR_US_BGRM_F15E_STRIKE_2SHIP
ME task: Bodenangriff / Ground Attack
MOOSE mission type: AUFTRAG.Type.STRIKE
1 x GBU-31(V)1/B
1 x GBU-31(V)3/B
2 x external fuel tank
1 x AIM-9M
1 x AIM-120
LANTIRN navigation pod
Targeting pod
```

Agreed fuze working baseline:

```text
GBU-31(V)1/B:
  MXU-735
  FMU-139
  ARM 10 s
  function delay 0 s

GBU-31(V)3/B:
  FMU-143
  ARM 12 s
  function delay 60 ms
```

MOOSE 2.9.18 maps:

```text
AUFTRAG.Type.STRIKE
-> ENUMS.MissionTask.GROUNDATTACK
-> DCS/ME Ground Attack / Bodenangriff
```

`Präzisionsangriff / Pinpoint Strike` is not the MOOSE 2.9.18 mapping for `AUFTRAG.Type.STRIKE`.

Current limitation:

- the screenshots establish the working authoring decision but do not replace a final `.miz` extraction;
- exact AIM-120 and pod CLSIDs still require inspection;
- the final saved strike task and fuze values still require verification;
- the current runtime code registers only the F-15E CAS seed and `ALERT5`/`CAS` capabilities;
- the strike payload and `AUFTRAG.Type.STRIKE` capability remain a later MOOSE-first implementation and runtime-test increment;
- CAS and strike remain payloads of the same 13-aircraft F-15E SQUADRON and must not create duplicate inventory.

## Instruction for the Kandahar chat

The Kandahar chat must read both the original handoff and this addendum, then inspect `main`, PR #24, the branch `docs/bagram-air-operations-manifest`, and all Kandahar-specific documents before proposing implementation changes.
