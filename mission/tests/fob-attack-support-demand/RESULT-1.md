---
document_id: OMW-STAGE-2-FOB-ATTACK-THREAT-RESULT-1
status: VALIDATED_FOR_DOCUMENTED_SCOPE
document_class: DCS_ACCEPTANCE_RESULT
owning_policy: OMW-GOV-001
source_branch: agent/fob-attack-support-demand
tested_source_commit: e3bc977e35ab3a06a5417124684250ae50a15a8b
validated_in_dcs: true
---

# Stage 2 – FOB/COP Threat Acceptance 1 Result

## Result

```text
PASS
```

The real DCS runtime demonstrated the intended Stage-2 MOOSE-first chain:

```text
WH_BLUE_GND_FORTRESS
-> BRIGADE/WAREHOUSE:GetCoordinate()
-> runtime ZONE_RADIUS 1000 m
-> BLUE OPSZONE
-> RED Ground presence while BLUE local-security presence remains
-> OPSZONE Attacked(RED)
-> OnAfterAttacked(..., RED)
-> qualified installation threat
-> one CAS_IMMEDIATE MissionDemand
```

No physical RED-on-BLUE hit and no `EVENTS.Hit` / `EVENTS.Shot` qualification was required.

## Runtime evidence

Observed sequence in `dcs.log`:

```text
SENTRY_ON_MISSION
SENTRY_ONGUARD_EXECUTING
OPSZONE OMW_SECURITY_BLUE_GROUND_COP_FORTRESS | Starting OPSZONE v0.6.2
[FobThreatOpsZoneAdapter] started MOOSE OPSZONE security perimeter zone=OMW_SECURITY_BLUE_GROUND_COP_FORTRESS radiusM=1000 owner=2 updateSeconds=5 threatlevel=0 captureNunits=1
READY ... installationId=BLUE_GROUND_COP_FORTRESS personnelCommitted=9 ... securityRadiusM=1000 detection=OPSZONE_ATTACKED scanSeconds=5
QUALIFIED_THREAT count=1 installationId=BLUE_GROUND_COP_FORTRESS ... evidence=OPSZONE_ATTACKED
DEMAND_RESULT ... created=true reason=nil
PASS qualifiedThreats=1 activeDemands=1 ... missionType=CAS_IMMEDIATE installationId=BLUE_GROUND_COP_FORTRESS ... personnelBefore=160 personnelAfterCommit=151 securityRadiusM=1000 detection=OPSZONE_ATTACKED
OPSZONE OMW_SECURITY_BLUE_GROUND_COP_FORTRESS | Stopping OPSZONE
```

The result validates the exact documented Fortress acceptance scope only.

## Provenance

```text
DCS version: 2.9.29.27278
Tested source commit: e3bc977e35ab3a06a5417124684250ae50a15a8b
BuilderVersion: FOB-ATTACK-THREAT-ACCEPTANCE-1-2
Acceptance Lua: OMW_FOB_Attack_Threat_Acceptance_1.lua
Acceptance Lua directory: P:\DCS-DEV\Operation-Mountain-Watch-fob-attack-support-demand\mission\tests\fob-attack-support-demand\dist\
Acceptance bundle SHA-256: 9A3382BF0EE476ED105A5EEF56575C73EBE591AAA00C1C4B1DA7A55F27835650
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
dcs.log SHA-256: 8C8821ABDD412258A1B2ABF18FC9AA8018767E80894B174DAFE982513B3D2B2D
debrief.log SHA-256: 081FE758DAE40933F011CE8156364BAC5EF40C13247150999F7CACE2159FD227
Owner-supplied MIZ artifact: OMW_Template_v20_GroundWorks(10).miz
Owner-supplied MIZ artifact SHA-256: 54E6562A095E771721E417CC8F5AEE0606066EA619E9E72D462E402A6D3EC118
Runtime debrief mission path: C:\Users\Sven\Saved Games\DCS.openbeta\Missions\OMW_Template_v20_GroundWorks.miz
```

The filename difference between the uploaded MIZ artifact and the runtime debrief path is recorded exactly. The hash above is the SHA-256 of the owner-supplied post-run MIZ artifact.

## Validated scope

Validated:

```text
- existing shared CampaignState / GroundBase context
- Fortress 9-person GROUND_PERSONNEL commitment: 160 -> 151
- BRIGADE / PLATOON / Warehouse materialization
- AUFTRAG ONGUARD local-security squad
- Warehouse-derived security anchor
- runtime ZONE_RADIUS with 1000 m radius
- BLUE OPSZONE
- UNIT / GROUND_UNIT filtering
- captureThreatlevel = 0 for the documented defended-zone alarm path
- Acceptance-only UpdateSeconds = 5
- OPSZONE OnAfterAttacked callback
- RED Ground presence -> qualified threat
- qualified threat -> exactly one CAS_IMMEDIATE MissionDemand
```

Not validated by this result:

```text
- CAS dispatch through AUFTRAG / COMMANDER / AIRWING / SQUADRON
- production OPSZONE scan cadence
- generalized capture/ownership behavior
- installations other than Fortress
- persistent threat-incident lifecycle across restart
```
