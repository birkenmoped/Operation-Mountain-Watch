---
document_id: OMW-TEST-TKOT-AIR-OPS-INDEX
status: DRAFT
document_class: TEST_PACKAGE_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - Tarinkot Air Operations test-package layout
  - accepted G5 read-only diagnostic result
  - current G6A parking-candidate analysis workflow
  - separation of geometric parking evidence from controlled spawn acceptance
not_authoritative_for:
  - final parking allowlists before a documented G6B PASS
  - AIRWING, SQUADRON, payload, AUFTRAG, COMMANDER or OPSTRANSPORT acceptance
  - merge approval or Ready-for-Review approval
scenario_period: 2010-08-01/2011-12-31
project_phase: TARINKOT_G6_PARKING_CALIBRATION
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: true
supersedes: []
superseded_by: []
---

# Tarinkot Air Operations – Testpaket

## 1. Aktueller Stand

```yaml
G0_provenance: PASS_BRANCH
G1_ORBAT_and_evidence: PASS_BRANCH
G2_object_contract: OWNER_ACCEPTED_BRANCH
G3_mission_editor: PARTIAL_FUNCTION_ZONES_PENDING
G4_MOOSE_source_review: PASS_SOURCE_REVIEW
G5_read_only_diagnostics: PASS_DCS
G6_parking_calibration: G6A_IMPLEMENTED_AWAITING_DCS_TEST
G7_airwing_squadron_payload: BLOCKED_BY_G6
G8_direct_dispatch_and_transport: NOT_STARTED
G9_commander_and_operational_parking: NOT_STARTED
G10_lifecycle_results_handoff: NOT_STARTED
```

Der G5-Retest bestätigte alle zwölf Statics und endete mit:

```text
RESULT G5_READ_ONLY_DIAGNOSTICS_COMPLETE status=PASS_STRUCTURE coreMissing=0 zonesMissing=10 mutationCount=0
```

G6 wird zweistufig durchgeführt:

```text
G6A: read-only Kandidatenanalyse nach MOOSE-Kollisionslogik
G6B: kontrollierte Spawn- und Platzierungstests je Musterfamilie
```

G6A ist implementiert. Positive SQUADRON-Parking-Listen bleiben bis zum dokumentierten G6B-PASS gesperrt.

## 2. Verbindliche Referenzen

- `docs/00-project-governance.md`
- `docs/22-test-mission-build-transfer-and-validation-workflow.md`
- `docs/tarinkot-air-operations-manifest.md`
- `docs/evidence/tarinkot-g2-object-contract-acceptance-checklist-2026-08-03.md`
- `docs/evidence/tarinkot-g2-owner-acceptance-2026-08-03.md`
- `docs/evidence/tarinkot-g4-moose-2-9-18-source-review.md`
- `docs/evidence/tarinkot-g5-pass-and-g6-authorization-2026-08-03.md`
- `expected/g5-read-only-diagnostics-acceptance.md`
- `expected/g6a-parking-candidate-analysis-acceptance.md`
- `results/2026-08-03-g5-read-only-diagnostics-initial-fail.md`
- `results/2026-08-03-g5-read-only-diagnostics-retest-pass.md`

## 3. Paketstruktur

```text
mission/tests/tarinkot-air-operations/
├── README.md
├── expected/
│   ├── g5-read-only-diagnostics-acceptance.md
│   └── g6a-parking-candidate-analysis-acceptance.md
├── results/
│   ├── 2026-08-03-g5-read-only-diagnostics-initial-fail.md
│   └── 2026-08-03-g5-read-only-diagnostics-retest-pass.md
├── src/
│   ├── 01-tarinkot-g5-read-only-diagnostics.lua
│   └── 02-tarinkot-g6a-parking-candidate-analysis.lua
└── dist/
    ├── OMW_AirOps_Tarinkot_G5_ReadOnly.lua
    └── OMW_AirOps_Tarinkot_G6A_ParkingAnalysis.lua

tools/
├── build-tarinkot-air-operations-g5-diagnostics.ps1
└── build-tarinkot-air-operations-g6a-parking-analysis.ps1
```

Dateien unter `dist/` werden ausschließlich durch den jeweiligen Builder erzeugt und nicht manuell bearbeitet.

## 4. Bestätigte G5-Basis

```yaml
runtime_airbase: Tarinkot
runtime_airbase_id: 9
runtime_unique_airbase_id: 9
airbase_id_candidate_count: 1
parking_count: 33
warehouse_wrapper_count: 1
clients_found: 3
ai_seeds_found: 3
statics_found: 12
zones_present: 1
zones_missing: 10
contract_name_duplicates: 0
mutation_count: 0
```

Die drei Client-Reservierungen bleiben harte Sperren:

```text
TerminalID 20 / C01-H / CLIENT_US_TKOT_AH64D_01
TerminalID  8 / C05-H / CLIENT_US_TKOT_AH64D_02
TerminalID  3 / C07-H / CLIENT_US_TKOT_CH47F_01
```

Datentypbesonderheit:

```text
CLIENT_US_TKOT_AH64D_01 unit.parking = "20"  # Lua string
CLIENT_US_TKOT_AH64D_02 unit.parking = 8     # Lua number
CLIENT_US_TKOT_CH47F_01 unit.parking = 3     # Lua number
```

Parking-IDs werden für Vergleiche numerisch normalisiert, ohne die Mission-Editor-Templates stillschweigend umzuschreiben.

## 5. G6A – MOOSE-first Kandidatenanalyse

G6A verwendet aus der exakt eingebetteten MOOSE-Version 2.9.18:

```text
AIRBASE:GetParkingSpotsTable()
AIRBASE.TerminalType.HelicopterUsable
AIRBASE._CheckTerminalType()
COORDINATE:ScanObjects()
POSITIONABLE:GetBoundingRadius()
POSITIONABLE:GetObjectSize()
```

Die Sicherheitsdistanz entspricht der internen MOOSE-Berechnung:

```text
safeDistance = (aircraftRadius + obstacleRadius) * 1.1
scanRadius = 50 m
```

Untersuchte Musterfamilien:

```yaml
AH64:
  type: AH-64D_BLK_II
  required_simultaneous_spots: 2
UH60:
  type: UH-60A
  required_simultaneous_spots: 2
CH47:
  type: CH-47Fbl1
  required_simultaneous_spots: 1
```

G6A liest Modellradien aus vorhandenen Template-, Client- oder Static-Objekten. Ein fehlender Radius führt zu `PARTIAL`; es wird kein Ersatzwert erfunden.

## 6. G6A-Sicherheitsgrenze

G6A darf und wird nicht:

```text
AIRWING oder SQUADRON erzeugen
Payloads registrieren
Parking-IDs setzen
Parking-White- oder Blacklists verändern
SafeParking umschalten
Client-Parking freigeben
Gruppen aktivieren oder spawnen
Missionen oder Transporte erzeugen
F10-Marker anlegen
CampaignState oder MIZ verändern
```

Der Builder prüft den Quelltext gegen 18 verbotene Muster.

Der Test muss ohne besetzten Tarinkot-Client laufen. Ein aktiver Spieler in einem Tarinkot-Client führt zu:

```text
status=INVALID_ACTIVE_PLAYER_CLIENT
```

## 7. Erwartete G6A-Ergebnisse

Zulässiger vollständiger Ergebnisstatus:

```text
RESULT G6A_PARKING_CANDIDATE_ANALYSIS status=PASS_DATASET
```

`PASS_DATASET` erfordert:

- exakt 33 Parking-Datensätze;
- keinen aktiven Tarinkot-Spielerclient;
- Modellradien für AH-64, UH-60 und CH-47;
- mindestens eine geeignete AH-64-Zweierkombination;
- mindestens eine geeignete UH-60-Zweierkombination;
- mindestens einen geeigneten CH-47-Einzelplatz;
- `parkingMutation=0` und `spawns=0`.

`PARTIAL` autorisiert noch keine Parking-Liste. `FAIL` oder `INVALID_ACTIVE_PLAYER_CLIENT` erfordern einen korrigierten Wiederholungslauf.

## 8. Abnahmegrenze

G6A beweist nur geometrische Kandidaten nach der MOOSE-Kollisionslogik. Nicht bewiesen sind:

```text
Spawn auf exakt dem angeforderten Terminal
AH-64-Zweiergruppen-Platzierung
parallele UH-60-Einzelgruppen-Platzierung
CH-47-Rotor- und Rollfreiheit
Cold-Start und Taxi
Rückkehr- oder Endparkverhalten
```

Diese Nachweise gehören zu G6B und werden erst aus dem tatsächlichen G6A-Datensatz abgeleitet.

Noch nicht akzeptiert:

```yaml
acceptedAHParkingIds: []
acceptedUH60ParkingIds: []
acceptedCH47ParkingIds: []
```

## 9. Zonenbild

```yaml
expected_zones: 11
expected_present:
  - OMW_LOG_NODE_TARINKOT
expected_missing: 10
```

G6A benötigt keine Funktionszone. Zonenabhängige Missionstests bleiben bis zur jeweiligen Mission-Editor-Anlage gesperrt.

## 10. Ergebnisdokumentation

Jeder DCS-Lauf erhält einen unveränderlichen Bericht unter `results/`. Er enthält mindestens:

- Branch und Commit;
- Builder-Version und Bundle-Hash;
- Missions- und MOOSE-Provenienz;
- Modellradien;
- Kandidatenlisten und gültige Zweierkombinationen;
- PASS, PARTIAL, FAIL oder INVALID;
- Folgerungen für G6B.
