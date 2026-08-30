---
document_id: OMW-STAGE-2-FOB-ATTACK-THREAT-ACCEPTANCE-1
status: ACCEPTED_TECHNICAL_BASELINE
document_class: DCS_ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - exact Stage 2A Fortress DCS acceptance scope
  - Fortress runtime 1000 m OPSZONE security-perimeter acceptance
not_authoritative_for:
  - CAS aircraft dispatch
  - installations other than Fortress
  - production OPSZONE cadence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - Stage 2 Acceptance-1 requirement for real RED-on-BLUE EVENTS.Hit
  - dedicated BLUE hit-target acceptance variant
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: e3bc977e35ab3a06a5417124684250ae50a15a8b
acceptance_branch: agent/fob-attack-support-demand
acceptance_commit: e3bc977e35ab3a06a5417124684250ae50a15a8b
acceptance_mission: OMW_Template_v20_GroundWorks(10).miz
acceptance_mission_sha256: 54E6562A095E771721E417CC8F5AEE0606066EA619E9E72D462E402A6D3EC118
dcs_version: 2.9.29.27278
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
validated_in_dcs: true
---

# Stage 2 – FOB Attack Threat Acceptance 1

## Ergebnis

```text
PASS
```

Der reale DCS-Lauf vom 29.08.2026 bestätigte:

```text
existing OMW Ground/CampaignState context
-> Fortress rifle-squad local security
-> WH_BLUE_GND_FORTRESS coordinate
-> runtime ZONE_RADIUS 1000 m
-> BLUE OPSZONE
-> RED Ground presence while BLUE remains
-> OPSZONE OnAfterAttacked(..., RED)
-> qualified installation threat
-> exactly one CAS_IMMEDIATE MissionDemand
```

Kein physischer Treffer und kein `EVENTS.Hit`/`EVENTS.Shot` waren als Primäralarm erforderlich.

## MOOSE-first Scope

```text
BRIGADE / LEGION / WAREHOUSE:GetCoordinate()
PLATOON / COHORT
AUFTRAG:NewONGUARD(...)
ARMYGROUP / OPSGROUP lifecycle
ZONE_RADIUS
OPSZONE
OPSZONE OnAfterAttacked
SCHEDULER
```

Keine Mission-Editor-Security-Zone, kein MIST, kein `world.addEventHandler`, kein eigener Präsenzscanner.

## Provenienz

```text
Tested source commit: e3bc977e35ab3a06a5417124684250ae50a15a8b
BuilderVersion: FOB-ATTACK-THREAT-ACCEPTANCE-1-2
Acceptance bundle SHA-256: 9A3382BF0EE476ED105A5EEF56575C73EBE591AAA00C1C4B1DA7A55F27835650
DCS: 2.9.29.27278
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
dcs.log SHA-256: 8C8821ABDD412258A1B2ABF18FC9AA8018767E80894B174DAFE982513B3D2B2D
debrief.log SHA-256: 081FE758DAE40933F011CE8156364BAC5EF40C13247150999F7CACE2159FD227
Mission: OMW_Template_v20_GroundWorks(10).miz
Mission SHA-256: 54E6562A095E771721E417CC8F5AEE0606066EA619E9E72D462E402A6D3EC118
```

Detailed result: `RESULT-1.md`.