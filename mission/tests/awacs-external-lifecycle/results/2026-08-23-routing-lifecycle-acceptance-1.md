---
document_id: OMW-AWACS-ACCEPTANCE-1-RUNTIME
status: ACCEPTED_TECHNICAL_BASELINE
document_class: DCS_ACCEPTANCE_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - AWACS Acceptance-1 routing lifecycle runtime evidence for the exact recorded provenance
not_authoritative_for:
  - complete AWACS production validation
  - six-hour relief lifecycle
  - fuel calibration
  - loss and restart reconciliation
  - AWACS aerial-refuelling behavior
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/awacs-external-lifecycle-foundation
source_commit: bde8a6e8d006b7c8d744b739510b08aa9812d48b
validated_in_dcs: true
supersedes:
superseded_by:
---

# AWACS Acceptance 1 – Routing Lifecycle Runtime Evidence

## Result

```text
PASS – routing lifecycle scope only
```

The complete AWACS foundation is not yet production-validated.

## Exact provenance

```text
Test date:                2026-08-23
Branch:                   agent/awacs-external-lifecycle-foundation
Tested source commit:     bde8a6e8d006b7c8d744b739510b08aa9812d48b
Mission:                  OMW_Template_v19(8).miz
Mission SHA-256:          d788af36535d3acd1866d15ffb5d354b2c44b5f8ee40d4baf6fd1d97b7c0f8a5
DCS:                      2.9.28.26385 MT
MOOSE release:            2.9.18
MOOSE commit:             73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Embedded Moose.lua SHA:   e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Embedded Warehouse SHA:   01a9ca70988198ecbd76f4d1cab4304261f2cc56911584b44741c0d49c7b146c
Embedded AWACS bundle SHA:639841a552343f4d0f7180f657a4a0b3141fb0b9af3ed6f1d9915ec955444fc2
Controller source SHA:    6ed1c54465764b5745f1071a59439f29dc08a93d1875492d25ff5ba889bd13bd
dcs.log SHA-256:          593d02d455db0cae04cfd0e7651671d3af1d76ab430ff3232da7b19dac391c2f
debrief.log SHA-256:      32df4af4943f5ca3d2a98dde61e452054b5183fd21fa9f6b78750894ec106eb7
```

The mission archive was inspected read-only after upload. Its embedded `Moose.lua`, Warehouse production bundle and AWACS foundation bundle match the hashes above.

## Successful runtime sequence

```text
15:57:57.133 [OMW][AWACS.Controller] MATERIALIZED
  runtime=AWACS-0001
  role=ACTIVE
  source=AL_DHAFRA
  spawnToRosieNm=15.06
  rosieToApocNm=61.25
  firToLateNm=31.25
  callsign=Wizard1-1
  frequencyMHz=357.300

15:58:58.993 [OMW][AWACS.Controller] FIR_INGRESS_PASSED
  fix=ROSIE
  waypointUid=2

15:59:03.477 [OMW][AWACS.Controller] LATE_APPROACH_PASSED
  distanceToTrackNm=30.0
  action=ADD_AWACS_MISSION

15:59:05.836 [OMW][AWACS.Controller] ON_STATION
  area=APOC
  cycleSec=21600
  reliefLaunchInSec=20984

15:59:18.414 [OMW][AWACS.Controller] EGRESS_ORDERED
  reason=ACCEPTANCE_1_ROUTING_EGRESS
  target=ROSIE
  altitudeFt=34000
  speedKt=300

15:59:27.726 [OMW][AWACS.Controller] FIR_EGRESS_PASSED
  fix=ROSIE
  action=ROUTE_EXTERNAL_HANDOFF

15:59:28.065 MOOSE AUFTRAG
  Mission 3 [AWACS] success!

15:59:29.166 [OMW][AWACS.Controller] EXTERNAL_HANDOFF
  runtime=AWACS-0001
  action=DESPAWN_AND_RECREDIT
```

The debrief state additionally records:

```text
OMW_C2_E3A_WIZARD#001 StopTaskFlag 1
  time  = 1800.801
  value = 1
```

## Accepted scope

For the exact provenance above, DCS runtime evidence confirms:

```text
external SPAWN materialization
-> ROSIE inbound passage
-> late-approach PassingWaypoint
-> FLIGHTGROUP:AddMission(AUFTRAG:NewAWACS(...))
-> APOC ON_STATION transition
-> controlled egress order
-> ROSIE outbound passage
-> external-handoff routing
-> Despawn / strategic recredit path
```

This is practical evidence for the OMW use of `AUFTRAG:NewAWACS(...)` and the surrounding public MOOSE `SPAWN`, `FLIGHTGROUP`, waypoint/FSM and egress path.

## Earlier failed attempt in the same dcs.log

The supplied `dcs.log` contains an earlier mission attempt from the same DCS process:

```text
15:48:30.867
[OMW][CampaignState] unknown nodeId=OFFMAP_AL_DHAFRA
```

That attempt used an older Warehouse bundle and failed before AWACS materialization. It was corrected by rebuilding `OMW_AirOps_Warehouse_Base.lua` with the current strategic stock and embedding the resulting bundle.

The later successful run uses the final uploaded mission whose embedded Warehouse hash is:

```text
01a9ca70988198ecbd76f4d1cab4304261f2cc56911584b44741c0d49c7b146c
```

The earlier failed attempt is diagnostic evidence only and is not part of the PASS.

## Not validated

This result does not establish:

```text
actual cruise altitude/speed compliance throughout the profile
actual APOC 017-degree / 30-NM racetrack geometry
player-side WIZARD service usability on 357.300 MHz AM
fuel state or burn rate
six-hour station endurance
scheduled relief launch and physical handover
loss settlement
restart reconciliation
AWACS aerial refuelling / tanker coordination
```

These remain separate acceptance requirements.
