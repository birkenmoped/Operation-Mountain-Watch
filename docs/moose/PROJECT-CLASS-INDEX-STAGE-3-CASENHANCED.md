---
document_id: OMW-MOOSE-CLASS-INDEX-STAGE-3-CASENHANCED
status: PLANNED
document_class: MOOSE_CLASS_REGISTER_SUPPLEMENT
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 3 source-reviewed MOOSE methods added for Honaker CASENHANCED and AGL telemetry
not_authoritative_for:
  - repository-wide class status replacement
  - DCS runtime validation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Stage 3 MOOSE Class Index Supplement – Honaker CASENHANCED

Dieses Supplement ergaenzt den projektweiten `PROJECT-CLASS-INDEX.md` fuer den noch ungemergten Stage-3-Branch. Nach technischer Acceptance beziehungsweise Reconciliation ist der relevante Status in den Hauptindex zu uebernehmen.

| Klasse / Methode | Status | Stage-3-Scope |
|---|---|---|
| `AUFTRAG:NewCASENHANCED(...)` | `SOURCE_REVIEWED` | Honaker 5-NM tactical CAS area; 2500-ft-AGL-at-center runtime ASL conversion; DCS runtime pending |
| `AUFTRAG:SetEngageDetected(...)` | `SOURCE_REVIEWED` | von `NewCASENHANCED` intern fuer 5-NM detected-target engagement verwendet |
| `ZONE_RADIUS:New(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` + Stage-3 use pending | separate 5-NM CAS tactical zone; nicht die 1000-m alarm OPSZONE |
| `COORDINATE:GetLandHeight()` | `SOURCE_REVIEWED` | Honaker terrain-ASL calculation and waypoint actual-AGL telemetry |
| `UTILS.MetersToFeet(...)` | `SOURCE_REVIEWED` | terrain/actual altitude telemetry and CAS ASL calculation |
| `OPSGROUP:GetCoordinate(true)` | `SOURCE_REVIEWED` for telemetry | event-bound actual aircraft coordinate at `PassingWaypoint` |
| `FLIGHTGROUP/OPSGROUP:OnAfterPassingWaypoint(...)` | `SOURCE_REVIEWED` | event-bound requested-vs-actual AGL telemetry; no polling scheduler |

Gepinnter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Keiner der hier neu aufgefuehrten Stage-3-Pfade wird durch dieses Dokument als DCS-`VALIDATED` erklaert.