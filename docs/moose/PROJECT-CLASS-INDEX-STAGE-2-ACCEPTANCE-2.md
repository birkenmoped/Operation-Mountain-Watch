---
document_id: OMW-MOOSE-CLASS-INDEX-STAGE-2-ACCEPTANCE-2
status: PLANNED
document_class: MOOSE_CLASS_REGISTER_ADDENDUM
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Stage 2B MOOSE class/API evidence pending DCS Acceptance 2
not_authoritative_for:
  - master PROJECT-CLASS-INDEX status on main
  - DCS validation before Acceptance 2 passes
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Stage 2 Acceptance 2 – MOOSE class evidence

Pinned framework:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

| Klasse/Pfad | Status vor DCS-Test | Stage-2B-Verwendung |
|---|---|---|
| `AUFTRAG:NewCAS` | `SOURCE_VERIFIED` | CAS-Zone aus dem bereits erzeugten Fortress-`ZONE_RADIUS`; Acceptance-Profil 10000 ft / 120 kt |
| `AIRWING` / `LEGION:AddMission` | `SOURCE_VERIFIED`, vorhandene OMW Foundation | vorhandener Jalalabad-AIRWING nimmt den CAS-AUFTRAG in seine Mission Queue auf |
| `SQUADRON` / `COHORT:AddMissionCapability` | `SOURCE_VERIFIED`, vorhandene OMW Foundation | vorhandener AH-64D-SQUADRON besitzt `AUFTRAG.Type.CAS` |
| `AIRWING OnAfterFlightOnMission` | `SOURCE_VERIFIED` | Acceptance-Beleg für reale FLIGHTGROUP-Materialisierung/Missionszuordnung |
| `AUFTRAG OnAfterExecuting` | `SOURCE_VERIFIED` | Acceptance-Beleg, dass reale Missionausführung begonnen hat; setzt MissionDemand `ACTIVE` |
| `AUFTRAG OnAfterSuccess` | `SOURCE_VERIFIED` | spiegelt erfolgreichen MOOSE-Abschluss auf MissionDemand `SUCCESS` |
| `AUFTRAG OnAfterFailed` | `SOURCE_VERIFIED` | spiegelt MOOSE-Fehlschlag auf MissionDemand `FAILED` |

`VALIDATED_FOR_DOCUMENTED_SCOPE` darf für diese Stage-2B-Komposition erst nach dem dokumentierten Acceptance-2-DCS-PASS vergeben werden.
