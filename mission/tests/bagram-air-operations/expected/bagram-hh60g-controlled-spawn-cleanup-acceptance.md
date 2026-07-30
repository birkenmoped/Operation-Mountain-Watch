# Bagram HH-60G Controlled Spawn/Cleanup Acceptance

Status: `PASS`

## Scope

This was the first isolated post-baseline runtime test. It validates one HH-60G asset group from `SQ_US_BGRM_HH60G_83_ERQS`.

The test uses the MOOSE `AIRWING`/`SQUADRON`/`AUFTRAG` path, not direct `SPAWN`. Recruitment, explicit payload selection, Safe Parking, the Bagram parking blacklist and warehouse ownership therefore remain under the operational architecture.

The accepted result is documented in:

```text
results/2026-07-30-bagram-hh60g-controlled-spawn-cleanup-pass.md
```

## Preconditions

- Bagram AIRWING baseline passed.
- Parking contract passed with 30 blacklisted TerminalIDs.
- `AW_US_BAGRAM` started.
- `SQ_US_BGRM_HH60G_83_ERQS` contained six one-aircraft asset groups.
- `TPL_AIR_US_BGRM_HH60G_CSAR_1SHIP` existed.
- The test switch was enabled only for the isolated validation and is now disabled.

## Validated mechanism

```lua
local mission = AUFTRAG:NewALERT5(AUFTRAG.Type.TROOPTRANSPORT)
mission:SetRequiredAssets(1, 1)
mission:AssignSquadrons({ cfg.Squadrons.HH60G })
mission:AddRequiredPayload(cfg.Payloads.HH60G)
mission:SetRepeat(0)
cfg.Airwing:AddMission(mission)
```

The harness polls `mission:GetOpsGroups()`:

```text
first inspection:       30 seconds after queueing
inspection interval:     5 seconds
spawn timeout:          150 seconds
cancel after PASS:       10 seconds
cleanup inspection:     45 seconds after cancellation
```

The former single inspection at 45 seconds is superseded because the accepted runtime did not expose the OPSGROUP until approximately 60 seconds after queueing.

## PASS criteria

```text
MISSION_QUEUED ... requiredAssets=1 ... requiredPayloadBound=true
SPAWN_INSPECT ... opsGroups=1
SPAWN_PASS ... units=1 alive=true
PRE_CANCEL_INSPECT ... opsGroups=1 aliveGroups=1
CLEANUP_REQUEST ... spawnedExactlyOne=true
CLEANUP_INSPECT ... opsGroups=0 aliveGroups=0
TEST_PASS spawnedExactlyOne=true cleanupComplete=true
```

Additionally:

- no second HH-60G group is recruited;
- the recruited group contains exactly one aircraft;
- no unrelated Bagram squadron is recruited;
- no client/static blacklisted terminal is used;
- the baseline AIRWING and parking contracts remain valid;
- no additional COMMANDER is created.

## Accepted result

```text
OPSGROUP: SQ_US_BGRM_HH60G_83_ERQS_AID-57
Asset ID: AID-57
Units:     1
Alive:     true
Cleanup:   opsGroups=0 / aliveGroups=0
Result:    PASS
```

## Exclusions

This acceptance does not validate:

- a tactical CSAR mission;
- survivor pickup or delivery;
- navigation to a rescue area;
- escort coordination;
- persistent loss accounting;
- maintenance and repair timing.

## Required evidence for any repetition

- complete `dcs.log` section for `[OMW][AirOps.BGRAM.Test.HH60G]`;
- Bagram parking-contract PASS block;
- AIRWING baseline PASS block;
- `debrief.log`;
- tested `.miz` name;
- generated bundle SHA-256 and builder header.
