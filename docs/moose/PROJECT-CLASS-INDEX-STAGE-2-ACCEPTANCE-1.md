---
document_id: OMW-MOOSE-CLASS-INDEX-STAGE-2-ACCEPTANCE-1
status: ACCEPTED_TECHNICAL_BASELINE
document_class: MOOSE_CLASS_REGISTER_ADDENDUM
owning_policy: OMW-GOV-001
authoritative_for:
  - exact-provenance Stage 2A Fortress MOOSE class evidence
not_authoritative_for:
  - broader OPSZONE behavior outside the accepted Fortress scope
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - Stage 2 Acceptance-1 EVENTS.Hit qualification evidence
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

# Stage 2 Acceptance 1 – MOOSE class evidence

Pinned framework:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

DCS Acceptance 1 validated the exact Fortress composition below:

| Klasse/Pfad | Accepted scope |
|---|---|
| `BRIGADE` / `LEGION` / `WAREHOUSE` | Fortress materialization and `WAREHOUSE:GetCoordinate()` anchor |
| `PLATOON` / `COHORT` | existing 9-person rifle-squad ONGUARD capability |
| `AUFTRAG:NewONGUARD` | real Fortress local-security mission |
| `ARMYGROUP` / `OPSGROUP` | observed sentry mission lifecycle |
| `ZONE_RADIUS` | runtime 1000 m Fortress security perimeter |
| `OPSZONE` | BLUE-owned perimeter raised `Attacked(RED)` from RED Ground presence |
| `OPSZONE:SetObjectCategories` | UNIT-only scan |
| `OPSZONE:SetUnitCategories` | GROUND_UNIT-only scan |
| `OPSZONE:SetCaptureThreatlevel` | acceptance value 0 |
| `OPSZONE:SetCaptureNunits` | configured for separate capture semantics |
| `OPSZONE:SetDrawZone` / `SetMarkZone` | hidden runtime perimeter |
| `OPSZONE.UpdateSeconds` | acceptance-only 5-second update interval |
| `OPSZONE OnAfterAttacked` | qualified threat callback |

Accepted chain:

```text
Warehouse coordinate
-> runtime ZONE_RADIUS 1000 m
-> BLUE OPSZONE
-> RED Ground presence while BLUE remains
-> OPSZONE Attacked(RED)
-> qualified threat
-> one CAS_IMMEDIATE MissionDemand
```

No `EVENTS.Hit`, `EVENTS.Shot`, custom presence scanner, MIST or native event handler was required.

## Provenienz

```text
Tested source commit: e3bc977e35ab3a06a5417124684250ae50a15a8b
BuilderVersion: FOB-ATTACK-THREAT-ACCEPTANCE-1-2
Bundle SHA-256: 9A3382BF0EE476ED105A5EEF56575C73EBE591AAA00C1C4B1DA7A55F27835650
DCS: 2.9.29.27278
Mission: OMW_Template_v20_GroundWorks(10).miz
Mission SHA-256: 54E6562A095E771721E417CC8F5AEE0606066EA619E9E72D462E402A6D3EC118
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

The status is limited to this exact accepted runtime composition.