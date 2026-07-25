# Follow-up mission blocked after successful UH-60 return

Date: 2026-07-25
Branch: `feature/jalalabad-airwing-phase1-functional-tests`

## Observed runtime result

The UH-60 troop transport completed successfully:

- OPSTRANSPORT reached `DELIVERED`.
- The physical troop-delivery objective passed.
- The aircraft returned to Jalalabad and landed.
- MOOSE emitted `LEGION_ASSET_RETURNED` with `returnedGroups=1` and `expectedGroups=1`.
- The Phase-1 controller emitted a final `PASS` result with `released=true`.

Relevant log sequence:

```text
19:46:29.077 AIRWING_EVENT ... event=LEGION_ASSET_RETURNED ... returnedGroups=1 expectedGroups=1
19:46:29.161 ACCEPTANCE event=ASSET_RELEASED authority=MOOSE_LEGION_FSM ...
19:46:29.161 RESULT testId=UH60_TROOP classification=PASS ... released=true ...
```

The post-return diagnostic snapshot reported:

```text
UH60 total=7 stock=7 spawned=0 onMission=0 pending=0 queued=0
```

The configured startup inventory had been eight UH-60 asset groups.

## Follow-up mission failure

A CH-47 cargo test was selected immediately after the successful UH-60 result. Its mission-specific readiness check ran successfully:

```text
19:46:42.528 SLING_CARGO_PROFILE READY ...
```

The controller then rejected the new mission because `StartTest()` still required all squadron totals to exactly equal the original startup inventory. The controller subsequently showed:

```text
State: WAITING_FOR_BASELINE
Active: none
MOOSE mission queue: 0
Block: total-mismatch-UH60-7-8
UH60_TROOP: PASS
```

This was a harness error. The previous test was no longer active, the native MOOSE queue was empty, and the asset return had already been confirmed by `LEGION_ASSET_RETURNED`.

## MOOSE-first correction

Runtime mission availability is now delegated to the native MOOSE recruitment paths:

- `AIRWING:AddMission()` for AUFTRAG missions.
- `LEGION:TransportAssign()` / native transport recruitment for OPSTRANSPORT missions.

The exact configured inventory count remains a one-time startup/construction assertion only.

The controller no longer uses historic inventory equality to:

- block `StartTest()` after a completed mission;
- return the controller to `WAITING_FOR_BASELINE` after a successful return;
- classify the overall automatic sequence as failed after all individual tests passed and released their assets.

Inventory snapshots remain diagnostic. The native MOOSE queue must still be empty before a new Phase-1 test is dispatched, and MOOSE itself remains responsible for rejecting a mission when no suitable asset is actually available.

## Expected follow-up behavior

After a successful mission, status must remain or recover to:

```text
State: READY
Active: none
MOOSE mission queue: 0
Block: none
```

Selecting another mission must produce:

```text
RUNTIME_READINESS ... authority=MOOSE_RECRUITMENT historicalInventoryEquality=nonBlocking queue=0
START testId=<next-test> ...
```

A diagnostic `total-mismatch-*` value may still be logged, but it must not prevent the next mission from being created and dispatched.
