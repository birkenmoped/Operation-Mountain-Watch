# Stage 3 Honaker -> Wright -> Jalalabad CASENHANCED build provenance

Status: BUILD_PROVENANCE_ONLY / NOT_DCS_VALIDATED

This record captures the real local PowerShell build output supplied by the project owner for the next Stage 3 Honaker runtime acceptance. It does not constitute a DCS PASS.

## Exact source/build commit

```text
Branch: agent/fire-support-strategic-resupply-alarm-evidence
GitCommit: 2bfa2b8e9f1b6a1efe2f4699fe59b9e4f4944d8d
BuilderVersion: STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-7
TestId: STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1
GeneratedUtc: 2026-08-31T19:45:50Z
```

## Pinned MOOSE provenance

```text
MOOSECommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
MooseLuaSHA256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## Real local hashes

```text
Bundle:
mission/tests/stage3-honaker-wright-full-response/dist/OMW_Stage3_Honaker_Wright_Full_Response_Acceptance_1.lua
SHA256: BEFBC6E8481980F50030E1A5DF5B5A30FEBADEFE4088C2617C33C96B62B3CFBD

Acceptance contract:
mission/tests/stage3-honaker-wright-full-response/ACCEPTANCE-1.md
SHA256: E6A051E146A3E9578511D4ACD5C6A4A6656892433C8D0B6A082963A110C7994A
```

## Runtime contract represented by this build

```text
Alarm perimeter: MOOSE OPSZONE 1000 m; trigger/evidence only
Attack incident: retains living known RED participants after perimeter exit
ARTY: Wright L118 live coordinate retarget cycle against incident participants
CAS: MOOSE AUFTRAG:NewCASENHANCED
CAS tactical area: 5 NM radius around Honaker
CAS combat height: Honaker terrain ASL + 2500 ft
CAS execution evidence: first real Shot is non-terminal
WEST corridor: 2500 ft AGL / RADIO / Column.D70
WEST telemetry: requested AGL + actual AGL/ASL + terrain at passed corridor waypoints
Strategic closure: one local M1083 rearm 16 -> 15, then exactly one Jalalabad -> Wright 15-package Air-AMMO resupply
MIZ mutation: false
```

## Local worktree observation

Before the build, `git status --short` contained only generated untracked dist directories:

```text
?? mission/tests/air-ammo-resupply/dist/
?? mission/tests/stage3-honaker-wright-full-response/dist/
```

No tracked local modification was reported.

## Acceptance boundary

The next DCS run must use the bundle identified above. Any later repository documentation commit does not change the provenance of that already-built test artifact. Do not call this state `VALIDATED` until the matching DCS/MIZ/log evidence is returned and reviewed.
