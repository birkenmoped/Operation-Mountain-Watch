---
document_id: OMW-TEST-TKOT-G6B-FINAL-FREE-SPOTS-PASS-2026-08-04
status: HISTORICAL_TEST_FIXTURE
document_class: TEST_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - Tarinkot combined G6B final-free-spots runtime result
  - owner visual acceptance of the eight-aircraft parking layout
  - rejection of departure and lifecycle experiments as outside G6B scope
  - exact MOOSE 2.9.18 vertical-helicopter option boundary for later AIRWING dispatch
not_authoritative_for:
  - Tarinkot AIRWING, SQUADRON or payload runtime acceptance
  - operational AUFTRAG or OPSTRANSPORT acceptance
  - return, landing, despawn or warehouse-ledger acceptance
  - merge approval or Ready-for-Review approval
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit: 585f3c46d4ff0a4b167c984d427bcdb356138e69
validated_in_dcs: true
dcs_version: 2.9.28.26385
source_mission: OMW_Template_v6_Tarinkot.miz
embedded_moose_release: 2.9.18
embedded_moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
embedded_moose_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
supersedes: []
superseded_by: []
---

# Tarinkot G6B – final free spots PASS and departure-scope correction

## 1. Accepted G6B result

The combined run created seven groups with eight helicopters on the mapped Tarinkot helicopter apron:

```yaml
AH64:
  ME_positions: [C04-H, C18-H]
  terminal_ids: [21, 4]
  groups: 1
  aircraft: 2
UH60:
  ME_positions: [C14-H, C12-H, C11-H]
  terminal_ids: [30, 27, 23]
  groups: 3
  aircraft: 3
CH47:
  ME_positions: [C08-H, C09-H, C10-H]
  terminal_ids: [32, 29, 10]
  groups: 3
  aircraft: 3
```

Runtime marker:

```text
RESULT G6B_HELICOPTER_APRON_COMBINED
status=PASS_RUNTIME_PLACEMENT
reason=none
expectedFamilies=3
expectedGroups=7
groupsFound=7
expectedUnits=8
unitsFound=8
placementFailures=0
familyFailures=0
spawnCalls=7
expectedTerminalType=HelicopterOnly
```

Every tested parking record was `TerminalType=40 / HelicopterOnly`. The owner visually confirmed the combined placement as correct. No aircraft overlap, static contact, revetment contact or visible rotor conflict was reported.

G6B is therefore accepted for parking and initial placement.

## 2. Scope violation in the subsequent departure experiments

G6B was defined as a placement-only gate using:

```lua
SPAWN:NewWithAlias(...)
  :InitAIOff()
  :SpawnAtParkingSpot(Airbase, TerminalIDs, SPAWN.Takeoff.Cold)
```

It was not authorized to test:

```text
engine start
taxi
takeoff
AUFTRAG execution
return or landing
FLIGHTGROUP lifecycle
despawn or warehouse return
```

Two later experiments violated this boundary:

1. applying `UNIT:OptionPreferVerticalLanding()` directly after the raw SPAWN;
2. constructing standalone `FLIGHTGROUP:New(group)` objects around raw SPAWN groups and calling `FLIGHTGROUP:SetOptionPreferVertical()`.

The second experiment caused the previously AI-disabled placement objects to enter an unmanaged OPS flight lifecycle. Helicopters taxied toward the runway and the owner then observed all test helicopters disappear. The log contains no Tarinkot-specific destroy, crash or loss marker, and the debrief graveyard is empty. The exact internal disappearance event is therefore not claimed as proven. The standalone FLIGHTGROUP architecture itself is invalid for this gate and has been removed.

## 3. Exact Jalalabad and MOOSE solution

The accepted Jalalabad node does not create standalone FLIGHTGROUP wrappers around raw SPAWN groups. Its authoritative sequence is:

```lua
local airwing = AIRWING:New(WarehouseName, AirwingName)
-- AIRWING/SQUADRON/payload configuration

airwing:SetOptionPreferVerticalLanding()
airwing:Start()
-- later: native AUFTRAG dispatch through AIRWING/COMMANDER
```

The Jalalabad runtime explicitly records:

```text
AIRWING_OPTION preferVerticalTakeoffAndLanding=true beforeAirwingStart=true scope=AUFTRAG
verticalHelicopterOps=AIRWING:SetOptionPreferVerticalLanding
observerHook=OnAfterFlightOnMission
```

The exact embedded MOOSE 2.9.18 source implements the policy in two stages:

```lua
function AIRWING:SetOptionPreferVerticalLanding()
  self.OptionPreferVerticalLanding = true
  return self
end
```

When a native AIRWING mission has created its managed flight, `AIRWING:onafterFlightOnMission(...)` applies:

```lua
if self.OptionPreferVerticalLanding then
  FlightGroup:SetOptionPreferVertical()
end
```

`FLIGHTGROUP:SetOptionPreferVertical()` then forwards the DCS option to the managed group:

```lua
self:GetGroup():OptionPreferVerticalLanding()
```

The required timing and ownership are therefore:

```text
AIRWING flag before AIRWING:Start
native AIRWING/AUFTRAG asset recruitment
MOOSE-managed FLIGHTGROUP creation
option application in FlightOnMission
```

Direct UNIT calls and standalone FLIGHTGROUP wrappers are not equivalent to this sequence.

## 4. Corrected implementation boundary

The final G6B builder is restored to placement-only semantics. It now rejects generated content containing:

```text
AIRWING:New
SQUADRON:New
FLIGHTGROUP:New
SetOptionPreferVertical
OptionPreferVerticalLanding
StartUncontrolled
SetAIOn
AUFTRAG
OPSTRANSPORT
Despawn
Destroy
```

The invalid FLIGHTGROUP wrapper builder was deleted.

No additional G6B DCS run is required. The eight-aircraft parking and placement result is already accepted.

## 5. Gate effect

```yaml
G6B_parking_and_placement: PASS_DCS_OWNER_VISUAL_ACCEPTED
G6B_departure_behavior: OUT_OF_SCOPE_NOT_ACCEPTED
G7_airwing_squadron_payload: UNBLOCKED
vertical_takeoff_policy_for_G7_G8: AIRWING_SET_OPTION_BEFORE_START
G8_vertical_departure_runtime_proof: REQUIRED_WITH_NATIVE_AUFTRAG
```

The next vertical-takeoff acceptance must occur in the first native Tarinkot AIRWING/AUFTRAG dispatch. It must not reuse the raw G6B SPAWN objects as flight-lifecycle objects.
