# Bagram HH-60G Controlled Spawn/Cleanup: PASS

Status: `PASS`

Date: `2026-07-30`

## Tested scope

One HH-60G asset group was recruited through the Bagram `AIRWING`/`SQUADRON`/`AUFTRAG` path, observed as a live one-aircraft `FLIGHTGROUP`, cancelled, and fully removed from the mission.

This acceptance does not validate CSAR execution, route generation, pickup, survivor handling, recovery-site delivery, persistent losses or repair timing.

## Environment and provenance

```text
Mission:             OMW_Template_v4_Bagram.miz
OMW branch:          docs/bagram-air-operations-manifest
Prescribed OMW HEAD: 6bf6ca42996708797915486c91e80556dbd3709c
BuilderVersion:      BGRAM-HH60G-POLLING-HARNESS-FIX-8
MOOSE commit:        73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256:   e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
DCS:                 2.9.28.26385
```

The supplied `dcs.log` does not contain the generated bundle header or SHA-256. The prescribed branch HEAD and builder version are therefore recorded from the controlled build instruction, not independently reconstructed from the log. The tested bundle SHA-256 remains an explicit provenance gap.

## Preconditions confirmed

```text
Parking contract:  PASS
Bagram AIRWING:    AW_US_BAGRAM started
Squadrons:         6
Logical inventory: 75
MOOSE managed:     73
Logical reserve:   2
```

## Accepted runtime sequence

```text
21:29:47.487 MISSION_QUEUED
              requiredAssets=1
              squadron=SQ_US_BGRM_HH60G_83_ERQS
              cohortCapability=ALERT5
              payloadMissionType=TROOPTRANSPORT
              requiredPayloadBound=true

21:30:47.500 SPAWN_PASS
              opsGroup=SQ_US_BGRM_HH60G_83_ERQS_AID-57
              assetId=AID-57
              units=1
              alive=true

21:30:57.506 PRE_CANCEL_INSPECT
              opsGroups=1
              aliveGroups=1
              status=executing

21:30:57.506 CLEANUP_REQUEST
              reason=spawn-confirmed
              spawnedExactlyOne=true

21:31:42.508 CLEANUP_INSPECT
              opsGroups=0
              aliveGroups=0
              status=success

21:31:42.508 TEST_PASS
              spawnedExactlyOne=true
              cleanupComplete=true
```

The spawn was first detected approximately 60 seconds after queueing. This confirms that the former single inspection at 45 seconds produced a false negative and that repeated polling was required.

The supplied `debrief.log` also contains:

```text
SQ_US_BGRM_HH60G_83_ERQS_AID-57_FlagHold
```

This independently confirms construction of the corresponding MOOSE `FLIGHTGROUP` object.

## Acceptance decision

```text
Payload binding:             PASS
Exact squadron recruitment:  PASS
Exactly one OPSGROUP:        PASS
Exactly one aircraft:        PASS
Live spawn:                  PASS
Mission execution state:     PASS
Cancellation:                PASS
Cleanup:                     PASS
Overall result:              PASS
```

## Follow-up

- `cfg.Tests.HH60GControlledSpawn` is disabled after acceptance.
- The HH-60G harness remains in source as reproducible test evidence but no longer runs in the active increment.
- The next active runtime increment is the Bagram-to-Jalalabad fixed-wing movement wave.
