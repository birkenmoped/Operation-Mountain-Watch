# UAV ISR Acceptance 3 — Kandahar On-Station orbit

## Scope

This separate, non-production acceptance mission extends Acceptance 2. A BLUE
player marker request dispatches the existing Kandahar MQ-9 Mission Editor
template through MOOSE AIRWING. At the submitted marker it enters a MOOSE
`AUFTRAG:NewORBIT_CIRCLE` mission centred on that marker.

The acceptance profile binds the AUFTRAG explicitly to the Kandahar MQ-9
Squadron. This is required because MOOSE adds the generic `ORBIT` capability
to every squadron and payload; the F10 marker text alone does not select a
specific aircraft type.

The 45-minute limit is configured as `SetDuration(2700)`. In the pinned MOOSE
source the execution timestamp is set by the `Executing` event; for an ORBIT
mission this is the orbit waypoint, not aircraft launch. Therefore the timer is
an On-Station limit rather than a transit limit.

The profile remains acceptance-only: 25,000 ft MSL and 180 kt IAS in a
circular orbit centred on the marker. The F10 cancel command uses
`AUFTRAG:Cancel()`: before MOOSE starts the mission it removes the queued
mission and releases the acceptance reservation; after start it orders a MOOSE
recall/return-to-base. MOOSE reclaims the returned AIRWING asset after physical
recovery; it does not delete the aircraft at the recall command. The request
remains `RETURNING` until MOOSE no longer reports the recovered OPSGROUP alive.
It does not clear
production terrain corridors, RC-East holding, Bagram sourcing, persistence,
production recovery/repair policy, Fog-of-War behaviour or weapon employment.
The acceptance-local Kandahar MQ-9 count is credited once only after MOOSE has
confirmed physical recovery; this permits a later acceptance request without
treating an airborne or returning aircraft as available. The production
foundation keeps MOOSE's 20-minute regular maintenance plus 40 minutes per
damage point for every asset whose takeoff is confirmed.

### Narrow no-takeoff recall exception

**Requirement:** a spawned MQ-9 that is recalled and removed before actual
takeoff must be immediately reusable; it must not receive the normal
post-flight turnover. This is the observed ISR-0003 ground-recall case.

MOOSE documentation and the pinned source were checked for AIRWING,
SQUADRON/COHORT, LEGION, `FLIGHTGROUP:IsAirborne`, and the documented
`OnAfterElementTakeoff` FSM callback. The callback confirms an actual DCS
takeoff. The pinned LEGION return path unconditionally records
`Asset.Treturned` when it re-adds an asset; no public per-asset API was found
to waive that timestamp while retaining the configured squadron turnover.
Official MOOSE mission examples were also checked; none provides such a
per-asset waiver.

The project owner requested this acceptance correction on 2026-08-28. Its
approved scope is strictly this acceptance adapter. After physical MOOSE
recovery, and only if no `ElementTakeoff` callback or `IsAirborne()` result was
observed, the adapter clears the returned asset's maintenance timestamp. It
does not spawn, route, destroy, or reconfigure MOOSE assets or squadron
turnover. The adapter waits for MOOSE to publish the returned timestamp before
CampaignState is recovered; an unavailable timestamp keeps the request pending
and logs `MISSION_TURNOVER_WAIVER_AWAITING_MOOSE_RETURN`.

A confirmed flight retains normal MOOSE turnover and reports the remaining
time. A waived ground recall reports immediate availability to the requesting
group. This is an acceptance-only, documented fallback—not a production
maintenance policy—and requires the regressions below.

## Build

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build-uav-isr-request-acceptance-3.ps1
```

Inject only `mission/tests/uav-isr-request/dist/OMW_UAV_ISR_Request_Acceptance_3.lua`
into a copy of the mission after MOOSE has loaded. The bundle waits for and
uses the production Kandahar AIRWING foundation; it must not initialise another
Kandahar foundation.

## DCS acceptance

1. Confirm the Acceptance-3 ISR Cell message.
2. As BLUE, set an exact BLUE F10 marker `UAV RECON` within 50 km of the
   client group and submit it under `F10 -> Command -> ISR Cell`.
3. Before submitting, record the matching `dcs.log` marker line:
   `MARKER_ADDED` or `MARKER_CHANGED`, with `accepted=true`. A rejected marker
   line records the actual received coalition and text without exposing it to
   other players.
   An unrelated map-marker deletion must not clear an accepted UAV marker;
   only `UAV_MARKER_DELETED` clears the UAV marker cache.
4. Record these `dcs.log` lifecycle lines for the same Request ID:
   `PAYLOAD_REGISTERED`, `MISSION_QUEUED`, `MISSION_STARTED` and
   `MISSION_ON_STATION`.
5. In an external/F10 view, capture the MQ-9 physically orbiting the submitted
   marker. The marker and aircraft must be visible in the same evidence set.
6. Submit a second request and use `Cancel own UAV request` in each available
   stage: queued/no physical asset, ground launch, airborne transit, and
   On-Station. Before start expect `cancelled before launch`; after start
   expect `recall ordered; returning to base`. Record the matching
   `MISSION_CANCELLED_BEFORE_START` or `MISSION_RECALL_ORDERED` log line.
7. Test both return branches:
   - **Ground recall:** wait for the spawned MQ-9, recall it before taxi/takeoff,
     then capture the empty original parking position. Expect
     `MISSION_TURNOVER_WAIVED_NO_TAKEOFF` followed by `MISSION_RECOVERED`
     with `takeoffConfirmed=false`, `turnoverWaived=true`, and
     `turnoverSeconds=0`. The requesting group must receive the immediate
     availability message. The next request must not be delayed by the normal
     MOOSE turnaround.
   - **Actual flight:** after an observed takeoff, recall or let the task end.
     Expect `MISSION_TAKEOFF_CONFIRMED` and `MISSION_RECOVERED` with
     `takeoffConfirmed=true`, `turnoverWaived=false`, and a positive
     `turnoverSeconds=<n>`. The requesting group must receive the MOOSE
     turnaround-time message.
8. Capture `debrief.log`: MQ-9 engine start, takeoff, landing and shutdown at
   Kandahar for the actual-flight branch. Capture the bundle SHA-256 and
   screenshots for both branches.

## Pass criterion

One existing fixed-loadout Kandahar MQ-9 launches without teleporting, reaches
the submitted marker, begins circular orbit, remains On-Station for the
configured 2,700 seconds after the MOOSE `Executing` event, and returns
physically to Kandahar. The request lifecycle must progress:

```text
QUEUED -> RESERVED -> ASSIGNED -> LAUNCHING
-> ON_STATION -> RETURNING -> COMPLETED
```
