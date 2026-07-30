# Bagram Controlled Spawn/Despawn Acceptance Contract

Status: `PLANNED_AFTER_PARKING_CONTRACT_PASS`

## Purpose

Prove that each active Bagram aircraft class can be recruited from its MOOSE SQUADRON, spawned on a non-blacklisted Bagram parking node, and removed or returned without inventory corruption.

This is not operational tasking. No COMMANDER-generated mission and no persistent campaign logic is permitted in this increment.

## Test order

Run one class at a time in separate mission executions:

```text
1. HH-60G
2. UH-60 Utility
3. CH-47
4. C-130
5. F-15E
6. F-16C
```

The order starts with single-aircraft helicopter templates, then heavy transport, then two-ship fighter templates.

## Preconditions

Each run requires:

- Bagram parking contract `PASS`;
- effective blacklist of 30 TerminalIDs;
- exactly six active Bagram SQUADRON objects;
- logical inventory total 75;
- no unrelated Bagram mission queued;
- no Bagram aircraft already spawned;
- Safe Parking enabled before recruitment.

## Per-class boundary

For the selected class, prove:

1. exactly one MOOSE asset group is recruited;
2. the runtime group uses the intended Mission Editor template;
3. the assigned parking node is not blacklisted;
4. the runtime group does not overlap a client, static aircraft, or another spawned asset;
5. the asset reaches a stable spawned/parked state;
6. no second asset group is recruited;
7. cleanup/despawn or controlled return completes;
8. SQUADRON stock and active counts return to the expected post-test state;
9. no other Bagram SQUADRON changes inventory state;
10. no Lua or MOOSE error is emitted.

## Grouping expectations

```text
HH-60G: 1 aircraft
UH-60:  1 aircraft
CH-47:  1 aircraft
C-130:  1 aircraft
F-15E:  2 aircraft
F-16C:  2 aircraft
```

The fighter test must not materialize the one-airframe logical reserve. Each fighter run may recruit only one two-ship asset group.

## Required evidence

Each run must log:

```text
class key
squadron name
template name
asset group id
runtime group name
unit count
assigned TerminalID or parking position
blacklist membership=false
spawn state
cleanup/return state
pre-test stock
post-spawn stock
post-cleanup stock
other-squadron delta=0
```

## Hard-fail conditions

The run fails if any of the following occurs:

- parking contract is not `PASS`;
- a blacklisted TerminalID is assigned;
- the runtime group overlaps a client or static aircraft;
- wrong template or wrong aircraft type is used;
- wrong grouping is spawned;
- more than one asset group is recruited;
- another Bagram SQUADRON changes state;
- the logical fighter reserve is spawned;
- cleanup does not complete;
- inventory does not reconcile;
- spontaneous operational tasking occurs;
- Lua or MOOSE error occurs.

## Completion rule

This increment is complete only after six independent class tests pass. A successful test of one class does not authorize another class by inference.
