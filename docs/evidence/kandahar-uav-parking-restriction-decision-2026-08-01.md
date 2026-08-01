---
document_id: OMW-EVID-KAF-UAV-PARKING-2026-08-01
status: BINDING
approved_by: project_owner
approval_date: 2026-08-01
authoritative_for:
  - Kandahar MQ-1 and MQ-9 spawn parking
  - Kandahar MQ-1 and MQ-9 landing and post-landing parking
  - Kandahar UAV apron runtime acceptance
source_branch: agent/kandahar-airwing-baseline-contract
source_mission: OMW_Template_v4_Kandahar.miz
supersedes:
  - unrestricted Main-airfield parking for SQ_US_KAF_MQ1_361_ERS
  - unrestricted Main-airfield parking for SQ_US_KAF_MQ9_361_ERS
---

# Kandahar UAV parking restriction decision

## Binding decision

The Kandahar MQ-1 and MQ-9 squadrons may use only the following Mission Editor parking labels:

```text
G01
G04
G05
G07
G08
G10
G11
```

This restriction applies to all physical ground handling at Kandahar Main:

- initial spawn;
- cold or hot start;
- return to Kandahar;
- landing;
- post-landing taxi;
- final parking and storage.

The UAV squadrons must not use the unrestricted Kandahar Main AIRWING parking pool.

Affected squadrons:

```text
SQ_US_KAF_MQ1_361_ERS
SQ_US_KAF_MQ9_361_ERS
```

## Runtime evidence that triggered the decision

The automatic controlled-parking matrix used unrestricted Main-airfield parking and produced:

```text
MQ-1 / RQ-1A Predator -> TerminalID 317
MQ-9 Reaper           -> TerminalID 239
```

Both positions were selected from the general Main AIRWING pool. This behavior is rejected for the Kandahar UAV implementation even though both spawns were technically valid, alive, on the ground and outside blocked/client parking.

## Mission Editor labels versus runtime IDs

The labels `G01`, `G04`, `G05`, `G07`, `G08`, `G10` and `G11` are Mission Editor/airfield labels. They are not automatically equivalent to MOOSE/DCS runtime `TerminalID` values.

The runtime implementation must therefore remain fail-closed until the seven labels have been mapped against the current Kandahar mission revision and DCS terrain version.

No TerminalID may be guessed from label order, nearby static placement or visual similarity.

## MOOSE-first implementation boundary

### Spawn restriction

The approved MOOSE mechanism is the squadron-level parking contract:

```lua
SQ_US_KAF_MQ1_361_ERS:SetParkingIDs(UAV_G_APRON_TERMINAL_IDS)
SQ_US_KAF_MQ9_361_ERS:SetParkingIDs(UAV_G_APRON_TERMINAL_IDS)
```

`SQUADRON:SetParkingIDs()` restricts assets of that squadron to the configured runtime parking IDs. The general Main AIRWING safe-parking and client/static blocklists remain active.

### Landing and final parking

Squadron spawn parking alone is not accepted as proof that DCS AI will use the same pool after landing.

A dedicated runtime acceptance test must demonstrate that both MQ-1 and MQ-9:

1. land at Kandahar Main;
2. taxi without entering blocked/client positions;
3. stop only on one of the seven mapped G-apron TerminalIDs;
4. are not returned to stock or declared safely recovered before the final parking position is confirmed.

If the current MOOSE/DCS combination cannot guarantee the post-landing stand, the UAV operational implementation remains blocked. Silent fallback to arbitrary Kandahar parking is prohibited.

## Required calibration evidence

The next calibration increment must produce an explicit table:

```text
ME label | runtime TerminalID | terminal type | coordinate | client/static conflict | accepted
G01      | ...                | ...           | ...        | ...                    | ...
G04      | ...                | ...           | ...        | ...                    | ...
G05      | ...                | ...           | ...        | ...                    | ...
G07      | ...                | ...           | ...        | ...                    | ...
G08      | ...                | ...           | ...        | ...                    | ...
G10      | ...                | ...           | ...        | ...                    | ...
G11      | ...                | ...           | ...        | ...                    | ...
```

The mapping must be tied to the exact `.miz` hash and DCS build used for acceptance.

## Acceptance criteria

The UAV parking contract passes only when all of the following are true:

```text
all seven G labels mapped to runtime TerminalIDs
MQ-1 spawn TerminalID belongs to the mapped G pool
MQ-9 spawn TerminalID belongs to the mapped G pool
MQ-1 landing/final parking TerminalID belongs to the mapped G pool
MQ-9 landing/final parking TerminalID belongs to the mapped G pool
no client-reserved TerminalID used
no static-blocked TerminalID used
no arbitrary Main-airfield fallback
no inferred or guessed mapping
```

Any spawn, landing or final parking outside the mapped G pool is a test failure.

## Current status

```text
Policy decision: BINDING
Runtime TerminalID mapping: REQUIRED
Spawn restriction: NOT YET RUNTIME ACCEPTED
Landing/final-parking restriction: NOT YET RUNTIME ACCEPTED
Operational UAV activation: BLOCKED
```
