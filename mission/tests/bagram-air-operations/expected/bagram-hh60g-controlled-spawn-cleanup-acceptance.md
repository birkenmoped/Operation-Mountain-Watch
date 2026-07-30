# Bagram HH-60G Controlled Spawn/Cleanup Acceptance

Status: `IMPLEMENTED_PENDING_DCS_VALIDATION`

## Scope

This is the first isolated post-baseline runtime test. It validates only one HH-60G asset group from `SQ_US_BGRM_HH60G_83_ERQS`.

The test uses the MOOSE AIRWING/AUFTRAG path, not direct `SPAWN`, so recruitment, payload selection, parking blacklist and warehouse accounting remain under the same architecture intended for the operational mission.

## Preconditions

- Bagram AIRWING baseline has passed.
- Parking contract has passed with 30 blacklisted TerminalIDs.
- `AW_US_BAGRAM` is started.
- `SQ_US_BGRM_HH60G_83_ERQS` exists and has six one-aircraft asset groups.
- `TPL_AIR_US_BGRM_HH60G_CSAR_1SHIP` exists.
- Test switch `cfg.Tests.HH60GControlledSpawn` is `true` only in this test branch.

## Test mechanism

The harness creates:

```text
AUFTRAG:NewALERT5(AUFTRAG.Type.LANDATCOORDINATE)
required assets: 1..1
assigned squadron: SQ_US_BGRM_HH60G_83_ERQS
repeat: 0
```

`ALERT5` is used deliberately as a parking-only increment. The aircraft is spawned uncontrolled and receives no operational route, CSAR task or transport assignment.

The mission is cancelled after 90 seconds. Cleanup is inspected after 150 seconds.

## PASS criteria

```text
MISSION_QUEUED ... requiredAssets=1
SPAWN_INSPECT opsGroups=1
SPAWN_PASS ... units=1
CLEANUP_REQUEST ...
CLEANUP_INSPECT ... aliveGroups=0
TEST_PASS spawnedExactlyOne=true cleanupComplete=true
```

Additionally:

- no second HH-60G group is recruited;
- no client/static blacklisted terminal is used;
- no F-15E, F-16C, C-130, UH-60 or CH-47 asset is recruited;
- AIRWING accounting remains valid;
- no Commander or CHIEF tasking is active.

## FAIL criteria

- `opsGroups=0` after the recruitment window;
- `opsGroups>1`;
- spawned group has other than one unit;
- parking collision or use of a blacklisted node;
- mission cancellation does not result in cleanup;
- Lua/MOOSE runtime error;
- any unrelated Bagram asset spawns.

## Required evidence

- complete `dcs.log` section for `[OMW][AirOps.BGRAM.Test.HH60G]`;
- Bagram parking-contract PASS block;
- AIRWING baseline PASS block;
- `debrief.log`;
- tested `.miz` name and bundle SHA-256.
