---
document_id: OMW-STAGE-2-FOB-ATTACK-THREAT-OPSZONE
status: ACCEPTED_TECHNICAL_BASELINE
document_class: MOOSE_ADAPTER_SOURCE_REVIEW
owning_policy: OMW-GOV-001
authoritative_for:
  - exact-provenance Stage 2 Fortress OPSZONE threat-qualification path
  - runtime Warehouse-centered security perimeter for the accepted Fortress scope
not_authoritative_for:
  - production-wide final security-radius policy
  - installations other than Fortress
  - production OPSZONE cadence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - OMW-STAGE-2-FOB-ATTACK-HIT-ADAPTER
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: e3bc977e35ab3a06a5417124684250ae50a15a8b
acceptance_branch: agent/fob-attack-support-demand
acceptance_commit: e3bc977e35ab3a06a5417124684250ae50a15a8b
acceptance_mission: OMW_Template_v20_GroundWorks(10).miz
acceptance_mission_sha256: 54e6562a095e771721e417cc8f5aee0606066ea619e9e72d462e402a6d3ec118
dcs_version: 2.9.29.27278
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
validated_in_dcs: true
---

# Stage 2 – MOOSE OPSZONE Threat Qualification Adapter

## Accepted Fortress path

```text
WH_BLUE_GND_FORTRESS
-> WAREHOUSE:GetCoordinate()
-> runtime ZONE_RADIUS 1000 m
-> OPSZONE(owner=BLUE)
-> real BLUE Ground security remains present
-> RED Ground presence
-> OPSZONE Attacked(RED)
-> OnAfterAttacked(..., RED)
-> OMW qualified threat incident
-> CAS_IMMEDIATE MissionDemand
```

Der Pfad wurde am 29.08.2026 real in DCS validiert. Ein physischer Treffer war nicht erforderlich.

## MOOSE-first evidence

Pinned framework:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Verwendet werden öffentliche MOOSE-Pfade:

```text
ZONE_RADIUS:New(...)
OPSZONE:New(...)
OPSZONE:SetObjectCategories(...)
OPSZONE:SetUnitCategories(...)
OPSZONE:SetCaptureThreatlevel(...)
OPSZONE:SetCaptureNunits(...)
OPSZONE:SetDrawZone(false)
OPSZONE:SetMarkZone(false)
OPSZONE:Start()
OPSZONE OnAfterAttacked(...)
OPSZONE:Stop()
```

Acceptance-Konfiguration:

```text
ObjectCategories = UNIT
UnitCategories = GROUND_UNIT
CaptureThreatlevel = 0
CaptureNunits = 1 for separate capture semantics
UpdateSeconds = 5 acceptance-only
Draw/Mark = false
```

Kein MIST, kein eigener `world.addEventHandler`, kein paralleler Präsenzscanner und keine zusätzliche Mission-Editor-Security-Zone.

## Provenienz

```text
Result: PASS
Tested source commit: e3bc977e35ab3a06a5417124684250ae50a15a8b
BuilderVersion: FOB-ATTACK-THREAT-ACCEPTANCE-1-2
Acceptance bundle SHA-256: 9A3382BF0EE476ED105A5EEF56575C73EBE591AAA00C1C4B1DA7A55F27835650
DCS version: 2.9.29.27278
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
dcs.log SHA-256: 8C8821ABDD412258A1B2ABF18FC9AA8018767E80894B174DAFE982513B3D2B2D
debrief.log SHA-256: 081FE758DAE40933F011CE8156364BAC5EF40C13247150999F7CACE2159FD227
Mission: OMW_Template_v20_GroundWorks(10).miz
Mission SHA-256: 54E6562A095E771721E417CC8F5AEE0606066EA619E9E72D462E402A6D3EC118
```

Detailed result: `../../mission/tests/fob-attack-support-demand/RESULT-1.md`.