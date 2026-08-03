---
document_id: OMW-TEST-TKOT-AIR-OPS-INDEX
status: DRAFT
document_class: TEST_PACKAGE_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - Tarinkot Air Operations test-package layout
  - accepted G5 read-only diagnostic result
  - accepted G6A parking-candidate dataset
  - current G6B controlled placement workflow
  - separation of geometric parking evidence from operational parking acceptance
not_authoritative_for:
  - final parking allowlists before a documented G6B PASS and later operational validation
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
G6_parking_calibration: G6A_PASS_DCS_G6B_IMPLEMENTED_AWAITING_DCS
G7_airwing_squadron_payload: BLOCKED_BY_G6B
G8_direct_dispatch_and_transport: NOT_STARTED
G9_commander_and_operational_parking: NOT_STARTED
G10_lifecycle_results_handoff: NOT_STARTED
```

Der erfolgreiche G5-Retest bestätigte:

```text
RESULT G5_READ_ONLY_DIAGNOSTICS_COMPLETE status=PASS_STRUCTURE coreMissing=0 zonesMissing=10 mutationCount=0
```

Der G6A-Lauf vom 3. August 2026 endete mit:

```text
RESULT G6A_PARKING_CANDIDATE_ANALYSIS status=PASS_DATASET reason=none parkingCount=33 modelMissing=0 candidateSetFailures=0 activePlayerClients=0 parkingMutation=0 spawns=0
```

G6B ist als isolierter MOOSE-SPAWN-Platzierungstest implementiert. Positive SQUADRON-Parking-Listen bleiben weiterhin leer.

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
- `expected/g6b-controlled-placement-acceptance.md`
- `results/2026-08-03-g5-read-only-diagnostics-initial-fail.md`
- `results/2026-08-03-g5-read-only-diagnostics-retest-pass.md`
- `results/2026-08-03-g6a-parking-candidate-analysis-pass.md`

## 3. Paketstruktur

```text
mission/tests/tarinkot-air-operations/
├── README.md
├── expected/
│   ├── g5-read-only-diagnostics-acceptance.md
│   ├── g6a-parking-candidate-analysis-acceptance.md
│   └── g6b-controlled-placement-acceptance.md
├── results/
│   ├── 2026-08-03-g5-read-only-diagnostics-initial-fail.md
│   ├── 2026-08-03-g5-read-only-diagnostics-retest-pass.md
│   └── 2026-08-03-g6a-parking-candidate-analysis-pass.md
├── src/
│   ├── 01-tarinkot-g5-read-only-diagnostics.lua
│   ├── 02-tarinkot-g6a-parking-candidate-analysis.lua
│   └── 03-tarinkot-g6b-controlled-placement.lua
└── dist/
    ├── OMW_AirOps_Tarinkot_G5_ReadOnly.lua
    ├── OMW_AirOps_Tarinkot_G6A_ParkingAnalysis.lua
    ├── OMW_AirOps_Tarinkot_G6B_AH64_Placement.lua
    ├── OMW_AirOps_Tarinkot_G6B_UH60_Placement.lua
    └── OMW_AirOps_Tarinkot_G6B_CH47_Placement.lua

tools/
├── build-tarinkot-air-operations-g5-diagnostics.ps1
├── build-tarinkot-air-operations-g6a-parking-analysis.ps1
└── build-tarinkot-air-operations-g6b-controlled-placement.ps1
```

Dateien unter `dist/` werden ausschließlich durch den jeweiligen Builder erzeugt und nicht manuell bearbeitet oder eingecheckt.

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

Harte Client-Sperren:

```text
TerminalID 20 / C01-H / CLIENT_US_TKOT_AH64D_01
TerminalID  8 / C05-H / CLIENT_US_TKOT_AH64D_02
TerminalID  3 / C07-H / CLIENT_US_TKOT_CH47F_01
```

Der abweichende Mission-Editor-Datentyp von `CLIENT_US_TKOT_AH64D_01 unit.parking = "20"` wird nur für Vergleiche numerisch normalisiert; die Mission wird nicht stillschweigend umgeschrieben.

## 5. Akzeptierter G6A-Datensatz

```yaml
AH64_candidates: [0, 1, 6, 11, 13, 14, 18, 22, 24, 25, 28, 33]
AH64_valid_pairs: 66
UH60_candidates: [0, 1, 6, 11, 13, 14, 18, 22, 24, 25, 28, 33]
UH60_valid_pairs: 66
CH47_candidates: [0, 1, 6, 11, 13, 14, 18, 22, 24, 25, 28, 29, 33]
```

Modellradien aus der eingebetteten Runtime:

```yaml
AH64_radius_m: 9.967
UH60_radius_m: 10.020
CH47_radius_m: 7.910
```

Die CH-47-Abmessungen bilden die Rotorfläche nicht vollständig ab. Jeder CH-47-Spawn benötigt deshalb zusätzlich zur automatischen Prüfung eine visuelle Rotor- und Hindernisprüfung.

Der DCS-Debrief führte weiterhin den Quellmissionsnamen `OMW_Template_v5_Salerno.miz`. Das ist als Provenienz-Warnung dokumentiert; der G6A-Lauf bleibt aufgrund eindeutiger Builder-, Commit-, Airbase-, Parking- und Ergebnismarker verwertbar.

## 6. G6B – kontrollierte Platzierung

Der exakte MOOSE-Quellstand bestätigt:

```lua
SPAWN:SpawnAtParkingSpot(Airbase, TerminalIDs, SPAWN.Takeoff.Cold)
```

G6B verwendet ausschließlich diesen Pfad. `InitAIOff()` hält die erzeugten Luftfahrzeuge nach dem Spawn stationär. Dadurch wird nur die anfängliche Platzierung geprüft; Engine Start, Taxi und Takeoff bleiben späteren Tests vorbehalten.

Probe-Sets:

```yaml
AH64:
  template: TPL_AIR_US_TKOT_AH64D_CAS_2SHIP
  terminal_ids: [0, 25]
  groups: 1
  units: 2
UH60:
  template: TPL_AIR_US_TKOT_UH60_MEDEVAC_1SHIP
  terminal_ids: [13, 22]
  groups: 2
  units_per_group: 1
CH47:
  template: TPL_AIR_US_TKOT_CH47_HEAVYLIFT_1SHIP
  terminal_ids: [14]
  groups: 1
  units: 1
```

Terminal `29` wird wegen der geringen geometrischen Reserve und der unvollständig abgebildeten CH-47-Rotorfläche nicht im ersten Test verwendet.

## 7. G6B-Sicherheitsgrenze

G6B erzeugt keine:

```text
AIRWING- oder SQUADRON-Objekte
Payloads
AUFTRAG-Missionen
COMMANDER
OPSTRANSPORT
Parking-White- oder Blacklists
SetParkingIDs-Zuweisungen
SafeParking-Mutationen
CampaignState- oder MIZ-Änderungen
zufälligen Spawnpositionen
```

Der Builder prüft verbotene Muster und verlangt ausdrücklich:

```text
SPAWN:NewWithAlias
InitAIOff
SpawnAtParkingSpot
SPAWN.Takeoff.Cold
```

## 8. G6B-Durchführung

Jede Musterfamilie wird in einer separaten Mission getestet. In jeder Testmission wird nur das jeweilige G6B-Bundle eingebunden:

```text
OMW_Template_v5_Salerno_TKOT_G6B_AH64.miz
OMW_Template_v5_Salerno_TKOT_G6B_UH60.miz
OMW_Template_v5_Salerno_TKOT_G6B_CH47.miz
```

Keinen Tarinkot-Client besetzen. Die Mission mindestens 35 Sekunden laufen lassen.

Erwarteter automatischer Erfolgsmarker:

```text
RESULT G6B_<FAMILY>_CONTROLLED_PLACEMENT status=PASS_RUNTIME_PLACEMENT
```

Zusätzlich visuell prüfen:

```text
keine Modellüberschneidung
kein Kontakt zu Static oder Terrain
Luftfahrzeug steht auf vorbereiteter Fläche
CH-47-Rotorfläche ist frei
```

## 9. Abnahmegrenze

Auch nach drei erfolgreichen G6B-Läufen bleiben die produktiven Listen zunächst leer:

```yaml
acceptedAHParkingIds: []
acceptedUH60ParkingIds: []
acceptedCH47ParkingIds: []
```

G6B akzeptiert nur die konkret getesteten Probe-Sets als technische Basis für die nachfolgende Parking-Entscheidung. G7 bleibt bis zur Auswertung aller drei Logs und visuellen Bestätigungen gesperrt.
