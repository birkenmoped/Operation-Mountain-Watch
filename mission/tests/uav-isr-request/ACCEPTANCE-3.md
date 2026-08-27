# UAV ISR Acceptance 3 — Kandahar On-Station orbit

## Scope

This separate, non-production acceptance mission extends Acceptance 2. A BLUE
player marker request dispatches the existing Kandahar MQ-9 Mission Editor
template through MOOSE AIRWING. At the submitted marker it enters a MOOSE
`AUFTRAG:NewORBIT_RACETRACK` mission.

The acceptance profile binds the AUFTRAG explicitly to the Kandahar MQ-9
Squadron. This is required because MOOSE adds the generic `ORBIT` capability
to every squadron and payload; the F10 marker text alone does not select a
specific aircraft type.

The 45-minute limit is configured as `SetDuration(2700)`. In the pinned MOOSE
source the execution timestamp is set by the `Executing` event; for an ORBIT
mission this is the orbit waypoint, not aircraft launch. Therefore the timer is
an On-Station limit rather than a transit limit.

The profile remains acceptance-only: 25,000 ft MSL, 180 kt, 5 NM racetrack,
090° heading. It does not clear production terrain corridors, RC-East holding,
Bagram sourcing, queueing, persistence, recovery re-credit, Fog-of-War
behaviour or weapon employment.

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
3. Record these `dcs.log` lifecycle lines for the same Request ID:
   `PAYLOAD_REGISTERED`, `MISSION_QUEUED`, `MISSION_STARTED` and
   `MISSION_ON_STATION`.
4. In an external/F10 view, capture the MQ-9 physically orbiting the submitted
   marker. The marker and aircraft must be visible in the same evidence set.
5. Let the full 45-minute On-Station duration elapse. Record
   `MISSION_RETURNING` and `MISSION_DONE`.
6. Capture `debrief.log`: MQ-9 engine start, takeoff, landing and shutdown at
   Kandahar. Capture the bundle SHA-256 and screenshots.

## Pass criterion

One existing fixed-loadout Kandahar MQ-9 launches without teleporting, reaches
the submitted marker, begins racetrack orbit, remains On-Station for the
configured 2,700 seconds after the MOOSE `Executing` event, and returns
physically to Kandahar. The request lifecycle must progress:

```text
QUEUED -> RESERVED -> ASSIGNED -> LAUNCHING
-> ON_STATION -> RETURNING -> COMPLETED
```
