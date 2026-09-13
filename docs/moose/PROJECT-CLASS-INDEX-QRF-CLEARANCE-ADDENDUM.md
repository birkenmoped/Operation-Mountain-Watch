---
document_id: OMW-MOOSE-CLASS-INDEX-QRF-CLEARANCE-ADDENDUM
status: BINDING
document_class: MOOSE_CLASS_REGISTER_ADDENDUM
owning_policy: OMW-GOV-001
authoritative_for:
  - class-level source-review status of the owner-approved QRF direct-target extension
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# PROJECT-CLASS-INDEX – QRF Direct-Target Addendum

Dieses Addendum ergänzt den bestehenden `PROJECT-CLASS-INDEX.md`, ohne dessen historische Einträge zu ersetzen.

Geprüfter Pin:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

| Klasse | Status für diese Erweiterung | Source-reviewed Methoden/Pfade | Grenze |
|---|---|---|---|
| `BRIGADE` | `SOURCE_REVIEWED` | FSM `ArmyOnMission` / `OnAfterArmyOnMission` | Übergibt die bereits materialisierte QRF als physische `ARMYGROUP`; Direct-Target-Einsatz noch kein DCS-PASS |
| `AUFTRAG` | `SOURCE_REVIEWED` | `NewONGUARD`, `SetReturnToLegion`, `SetTeleport`, `Cancel`, `IsOver` | ONGUARD ist Recruitment-/Materialization-Anchor; Target-Ausführung erfolgt danach direkt auf derselben ARMYGROUP |
| `ARMYGROUP` | `SOURCE_REVIEWED` | `EngageTarget`, `OnAfterDisengage`, `_UpdateEngageTarget`, `RTZ`, `Returned` | MOOSE verfolgt konkretes `UNIT`; Reacquire ist an `Disengage` gebunden; noch kein DCS-PASS |
| `ZONE_BASE` | `SOURCE_REVIEWED` | `IsCoordinateInZone` | Filtert bekannte Incident-Targets auf die site-local 5-NM-Tactical-Zone |

`PATROLZONE`, `SetPatrolAdInfinitum` und `EnableHuntingPatrol` wurden im gepinnten Source geprüft, sind für den aktuellen OMW-QRF-Vertrag jedoch **nicht ausgewählt**. Der reale Joyce-A4-Lauf vom 13.09.2026 hat den daraus gebauten QRF-Clearance-Ansatz als ungeeignet gezeigt; dies ist negative DCS-Evidenz.

Verbindlicher Lifecycle und Grenzen: `QRF-RESPONSE-CLEARANCE-LIFECYCLE.md` sowie `FIRE-SUPPORT-ACCEPTED-IMPLEMENTATION-MATRIX.md`.

Dieses Addendum erhebt keinen bestehenden Klassenstatus pauschal und ersetzt keine historische Acceptance-Provenienz.
