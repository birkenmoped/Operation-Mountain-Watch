---
document_id: OMW-MOOSE-VERIFIED-METHODS-GROUND-ACCEPTANCE-1
status: ACCEPTED_TECHNICAL_BASELINE
document_class: TECHNICAL_EVIDENCE_REGISTER
owning_policy: OMW-GOV-001
authoritative_for:
  - method-level MOOSE evidence from ARMY Ground Acceptance 1 for the exact documented provenance
not_authoritative_for:
  - ARMOREDGUARD behavior before Acceptance 2
  - production vehicle patrol doctrine
  - other MOOSE or DCS versions
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/army-ground-foundation-reconciliation
source_commit: 998080da9a7a71dae7f713b9590dfeadb5ae93ba
validated_in_dcs: true
acceptance_branch: agent/army-ground-foundation-reconciliation
acceptance_commit: 1e5218cb38dd1db05a0bcf335cf9d00cf2693384
acceptance_mission: OMW_Template_v13_ground_test.miz
acceptance_mission_sha256: fde9e4d7e0e1eb6a9c32c0de5efa02c26ca3afd498c8948ee11bdb4ca0e49b13
dcs_version: 2.9.28.26385 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
supersedes:
superseded_by:
---

# Verifizierte MOOSE-Methoden – Ground Acceptance 1

## Provenienz

```text
DCS: 2.9.28.26385 MT
MOOSE: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Acceptance source commit: 1e5218cb38dd1db05a0bcf335cf9d00cf2693384
Mission: OMW_Template_v13_ground_test.miz
MIZ SHA-256: fde9e4d7e0e1eb6a9c32c0de5efa02c26ca3afd498c8948ee11bdb4ca0e49b13
Embedded A1 bundle SHA-256: e227ac0d8e9647d1ca56d0e8c14919d0be8ba6e6ca38cbc291a077643170c8b4
```

Vollständiges Ergebnis:

- [`OMW-TEST-ARMY-GROUND-ACCEPTANCE-1-RUNTIME-20260818`](../../mission/tests/army-ground-foundation/results/2026-08-18-acceptance-1-runtime.md)

## Praktisch bestätigter Umfang

| Methode/Pfad | Status | Belegter Umfang |
|---|---|---|
| `BRIGADE:New(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Joyce Ground-BRIGADE wurde konstruiert und gestartet |
| `WAREHOUSE:SetSpawnZone(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Joyce ACCESS-Zone als Materialisierungsbereich; optische ACCESS-Qualität bleibt mit Circling-Note offen |
| `PLATOON:New(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | ein Joyce Ground-PLATOON erfolgreich registriert |
| `BRIGADE:AddPlatoon(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | PLATOON-/Assetbindung für den getesteten Ein-Gruppen-Scope |
| `COHORT:AddMissionCapability(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | PATROLZONE-Capability wurde für die Selektion verwendet |
| `COHORT:CountAssets(true, ...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | nach BRIGADE-Start exakt ein passendes In-stock-Asset gemeldet |
| `LEGION:AddMission(...)` via BRIGADE | `VALIDATED_FOR_DOCUMENTED_SCOPE` | zwei sequenzielle Ground-AUFTRÄGE wurden zugewiesen |
| `AUFTRAG:NewPATROLZONE(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | technisch für A1-Lifecycle; ausdrücklich **nicht** als Production-Mounted-Patrol-Verhalten akzeptiert |
| `AUFTRAG:SetReturnToLegion(false)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | nach MissionDone blieb die physische ARMYGROUP im Feld |
| `AUFTRAG:__Cancel(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | verzögerter Cancel-Pfad führte in der Testsequenz zu MissionDone ohne physisches Entfernen |
| `OPSGROUP/ARMYGROUP MissionDone` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | dieselbe physische ARMYGROUP blieb alive und FIELD_DEPLOYED |
| Same-group follow-up | `VALIDATED_FOR_DOCUMENTED_SCOPE` | zweiter Auftrag verwendete `PLT_BLUE_GND_JOYCE_PATROL_AID-211`; `spawnCount=1` |

## Grenzen

Nicht aus Acceptance 1 ableiten:

```text
PATROLZONE is suitable for production vehicle patrols
ACCESS departure is visually clean
ARMOREDGUARD is validated
Vee formation is validated
per-vehicle sectors exist
Returned -> Warehouse is validated
restart/reconstitution is validated
```

Die beobachteten kleinen Runden im ACCESS-Bereich bleiben ein eigener Routing-/Materialization-Quality-Befund. Acceptance 2 prüft deshalb `ARMOREDGUARD`, `On Road` und eine taktische `Vee`-Endphase separat.
