---
document_id: OMW-TKOT-G5-PASS-G6-AUTHORIZATION-2026-08-03
status: BINDING_PROJECT_DECISION
document_class: TECHNICAL_GATE_DECISION
owning_policy: OMW-GOV-001
authoritative_for:
  - Tarinkot G5 DCS acceptance state
  - authorization boundary for Tarinkot G6 parking calibration
  - current Tarinkot technical gate status on Draft PR 53
not_authoritative_for:
  - final parking allowlists
  - AIRWING or SQUADRON runtime acceptance
  - merge approval or Ready-for-Review approval
scenario_period: 2010-08-01/2011-12-31
project_phase: TARINKOT_G6_PARKING_CALIBRATION
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: true
supersedes:
  - Tarinkot G5 FAIL_RETEST_REQUIRED gate status
superseded_by: []
---

# Tarinkot G5 PASS und G6-Autorisierung

## Entscheidung

Der korrigierte Tarinkot-G5-Retest ist als `PASS_DCS` angenommen. Die einzige Änderung gegenüber dem initialen FAIL war die Korrektur von `STATIC_AIR_US_TKOT_AH64_07` auf `AH-64D_BLK_II` bei unverändertem Namen, Standort und Heading.

Maßgebliche Abschlusszeile:

```text
RESULT G5_READ_ONLY_DIAGNOSTICS_COMPLETE status=PASS_STRUCTURE coreMissing=0 zonesMissing=10 mutationCount=0
```

## Bestätigte Runtime-Basis

```yaml
airbase: Tarinkot
airbase_id: 9
parking_nodes: 33
warehouse: PASS
clients: 3_of_3
ai_seeds: 3_of_3
statics: 12_of_12
zones_present: 1
zones_missing_expected: 10
contract_name_duplicates: 0
mutations: 0
```

## Autorisierung

G6 Parking-Kalibrierung ist freigegeben. Die Freigabe erfolgt gestuft:

```text
G6A read-only Kandidatenanalyse: autorisiert
G6B kontrollierte Spawn-/Platzierungstests: erst nach Auswertung von G6A
produktive SQUADRON-Parking-Listen: weiterhin gesperrt
```

G6A muss MOOSE-first arbeiten und die in MOOSE 2.9.18 verwendete Bounding-Radius-/Sicherheitsdistanzlogik verwenden. Es dürfen keine Parking-IDs gesetzt und keine Gruppen gespawnt werden.

## Aktueller Gate-Stand

```yaml
G0_provenance: PASS_BRANCH
G1_ORBAT_and_evidence: PASS_BRANCH
G2_object_contract: OWNER_ACCEPTED_BRANCH
G3_mission_editor: PARTIAL_FUNCTION_ZONES_PENDING
G4_MOOSE_source_review: PASS_SOURCE_REVIEW
G5_read_only_diagnostics: PASS_DCS
G6_parking_calibration: G6A_AUTHORIZED
G7_airwing_squadron_payload: BLOCKED_BY_G6
G8_direct_dispatch_and_transport: NOT_STARTED
G9_commander_and_operational_parking: NOT_STARTED
G10_lifecycle_results_handoff: NOT_STARTED
```

## Evidenz

```text
mission/tests/tarinkot-air-operations/results/2026-08-03-g5-read-only-diagnostics-initial-fail.md
mission/tests/tarinkot-air-operations/results/2026-08-03-g5-read-only-diagnostics-retest-pass.md
mission/tests/tarinkot-air-operations/expected/g5-read-only-diagnostics-acceptance.md
```
