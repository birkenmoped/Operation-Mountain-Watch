---
document_id: OMW-MOOSE-CLASS-INDEX-QRF-CLEARANCE-ADDENDUM
status: BINDING
document_class: MOOSE_CLASS_REGISTER_ADDENDUM
owning_policy: OMW-GOV-001
authoritative_for:
  - class-level source-review status of the owner-approved QRF response-clearance extension
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# PROJECT-CLASS-INDEX – QRF Clearance Addendum

Dieses Addendum ergänzt den bestehenden `PROJECT-CLASS-INDEX.md`, ohne dessen historische Einträge zu ersetzen.

Geprüfter Pin:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

| Klasse | Status für diese Erweiterung | Source-reviewed Methoden/Pfade | Grenze |
|---|---|---|---|
| `AUFTRAG` | `SOURCE_REVIEWED` | `NewPATROLZONE`, `GetOpsGroups`, `SetReturnToLegion`, `SetTeleport`, `Cancel`, `IsOver` | QRF Clearance nach bestehender ONGUARD-Response; noch kein DCS-PASS |
| `OPSGROUP` | `SOURCE_REVIEWED` | `AddMission`, FSM `__MissionDone` | Same-group-Übergang Response -> Clearance; noch kein DCS-PASS |
| `ARMYGROUP` | `SOURCE_REVIEWED` | `SetPatrolAdInfinitum`, `EnableHuntingPatrol`, `DisableHuntingPatrol` | MOOSE-eigene Suche/Engagement innerhalb der site-local tactical zone; noch kein DCS-PASS |

Verbindlicher Lifecycle und Grenzen: `QRF-RESPONSE-CLEARANCE-LIFECYCLE.md` sowie `FIRE-SUPPORT-ACCEPTED-IMPLEMENTATION-MATRIX.md`.

Dieses Addendum erhebt keinen bestehenden Klassenstatus pauschal und ersetzt keine historische Acceptance-Provenienz.
