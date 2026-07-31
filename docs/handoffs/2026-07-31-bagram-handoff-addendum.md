# Bagram handoff addendum - revised mission and disabled transfer test

This addendum supplements:

```text
docs/handoffs/2026-07-31-bagram-current-state-and-kandahar-chat-handoff.md
```

## Revised provisional Bagram Mission Editor file

The latest provisional Bagram Mission Editor file supplied by the project owner in the Bagram chat is:

```text
OMW_Template_v4_Bagram(5).miz
```

Status:

```text
provisional
supplied in chat
not committed to the repository
not yet a complete DCS runtime acceptance baseline after the model substitutions
```

The file is the latest known visual and template-editing state for Bagram. It is not a Kandahar mission and must not be treated as the Kandahar Mission Editor source of truth.

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

Before using the Bagram mission again, rebuild and re-embed:

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

in the existing Mission Editor `DO SCRIPT FILE` action and save the `.miz`.

## Instruction for the Kandahar chat

The Kandahar chat must read both the original handoff and this addendum, then inspect `main`, PR #24, the branch `docs/bagram-air-operations-manifest`, and all Kandahar-specific documents before proposing implementation changes.
