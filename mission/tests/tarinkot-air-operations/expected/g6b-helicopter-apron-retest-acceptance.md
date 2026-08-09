---
document_id: OMW-TEST-TKOT-G6B-HELICOPTER-APRON-RETEST-ACCEPTANCE
status: PLANNED
document_class: TEST_ACCEPTANCE_SPECIFICATION
owning_policy: OMW-GOV-001
authoritative_for:
  - Tarinkot G6B combined HelicopterOnly placement retest
  - exact TerminalID probe set after the wrong-apron failure
  - visual and log acceptance criteria for designated helicopter-apron placement
not_authoritative_for:
  - final productive SQUADRON or WAREHOUSE parking allowlists
  - engine start, taxi, takeoff, mission execution, return, landing or recovery acceptance
  - AIRWING, SQUADRON, payload, AUFTRAG, COMMANDER or OPSTRANSPORT acceptance
  - merge approval or Ready-for-Review approval
scenario_period: 2010-08-01/2011-12-31
project_phase: TARINKOT_G6_PARKING_CALIBRATION
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
supersedes: []
superseded_by: []
---

# Tarinkot G6B – Helicopter-apron combined retest

## Scope

One bundle and one DCS run validate all three Tarinkot helicopter families together.

```yaml
AH64:
  groups: 1
  aircraft: 2
  terminal_ids: [4, 23]
UH60:
  groups: 2
  aircraft: 2
  terminal_ids: [21, 30]
CH47:
  groups: 1
  aircraft: 1
  terminal_ids: [29]
```

Total:

```text
3 families
4 groups
5 aircraft
5 TerminalIDs
1 DCS run
```

## Mandatory apron class

Every requested terminal must satisfy:

```text
TerminalType == AIRBASE.TerminalType.HelicopterOnly
TerminalType == 40
```

`AIRBASE.TerminalType.HelicopterUsable` is explicitly insufficient because it also accepts general apron nodes such as type `104`.

The preflight must fail before spawning if any configured TerminalID is not exactly type `40`.

## Safety boundary

The retest may use only:

```text
SPAWN:NewWithAlias
SPAWN:InitLimit
SPAWN:InitAIOff
SPAWN:SpawnAtParkingSpot
SPAWN.Takeoff.Cold
```

It must not create or modify:

```text
AIRWING
SQUADRON
payloads
AUFTRAG
COMMANDER
OPSTRANSPORT
SQUADRON:SetParkingIDs
parking white-/blacklists
CampaignState
MIZ objects
```

Client TerminalIDs `3`, `8` and `20` remain hard exclusions.

## Required log evidence

Preflight:

```text
APRON_CONTRACT expectedTerminalTypeName=HelicopterOnly expectedTerminalTypeValue=40 openBigRejected=true
PREFLIGHT status=PASS families=3 groups=4 units=5 terminals=5 terminalType=40
```

Every terminal line must contain:

```text
type=40 typeName=HelicopterOnly
```

Family results:

```text
FAMILY_RESULT family=AH64 status=PASS_RUNTIME_PLACEMENT
FAMILY_RESULT family=UH60 status=PASS_RUNTIME_PLACEMENT
FAMILY_RESULT family=CH47 status=PASS_RUNTIME_PLACEMENT
```

Overall result:

```text
RESULT G6B_HELICOPTER_APRON_COMBINED status=PASS_RUNTIME_PLACEMENT reason=none expectedFamilies=3 expectedGroups=4 groupsFound=4 expectedUnits=5 unitsFound=5 placementFailures=0 familyFailures=0 activePlayerClients=0 spawnCalls=4 expectedTerminalType=HelicopterOnly visualConfirmationRequired=true
```

## Mandatory visual acceptance

All five aircraft must be visible on the designated Tarinkot helicopter parking area.

Additionally:

- no aircraft-aircraft overlap;
- no static-aircraft contact;
- no revetment or structure contact;
- all landing gear on prepared surface;
- sufficient main- and tail-rotor clearance;
- CH-47 forward and aft rotor clearance confirmed separately.

A technically successful terminal-coordinate assignment is not sufficient when the aircraft is outside the designated helicopter apron.

## Result classification

```yaml
PASS:
  logs: all required values pass
  visual: all five aircraft on designated helicopter apron and clear
FAIL_VISUAL_WRONG_APRON:
  any aircraft outside designated helicopter apron
FAIL_VISUAL_CLEARANCE:
  aircraft, static, revetment, structure or rotor conflict
FAIL_PREFLIGHT:
  wrong terminal type, unavailable terminal, active Tarinkot client or object mismatch
FAIL_PLACEMENT:
  missing group/unit or terminal-coordinate assignment failure
```

Only `PASS` authorizes productive parking-list derivation and G7.
