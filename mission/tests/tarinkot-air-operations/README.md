---
document_id: OMW-TEST-TKOT-AIR-OPS-INDEX
status: DRAFT
document_class: TEST_PACKAGE_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - Tarinkot Air Operations test-package layout
  - accepted G5 read-only diagnostic result
  - current G6 parking-calibration entry state
  - separation of diagnostic evidence from operational runtime acceptance
not_authoritative_for:
  - final parking allowlists before a documented G6 PASS
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
G6_parking_calibration: AUTHORIZED_NOT_STARTED
G7_airwing_squadron_payload: BLOCKED_BY_G6
G8_direct_dispatch_and_transport: NOT_STARTED
G9_commander_and_operational_parking: NOT_STARTED
G10_lifecycle_results_handoff: NOT_STARTED
```

G5 war der erste Tarinkot-Lua-Test. Er war ausschließlich diagnostisch und erzeugte keine operativen MOOSE-Objekte.

Der initiale DCS-Lauf schlug ausschließlich wegen des Legacy-Typs von `STATIC_AIR_US_TKOT_AH64_07` fehl. Nach der kontrollierten Mission-Editor-Korrektur auf `AH-64D_BLK_II` bestätigte der Retest alle zwölf Statics und endete mit:

```text
RESULT G5_READ_ONLY_DIAGNOSTICS_COMPLETE status=PASS_STRUCTURE coreMissing=0 zonesMissing=10 mutationCount=0
```

G5 ist damit abgeschlossen. Der erfasste Parking-Datensatz darf nun in G6 klassifiziert werden; positive SQUADRON-Parking-Listen bleiben bis zum G6-PASS gesperrt.

## 2. Verbindliche Referenzen

- `docs/00-project-governance.md`
- `docs/22-test-mission-build-transfer-and-validation-workflow.md` auf dem Jalalabad-Testbranch, bis die Datei nach `main` integriert ist
- `docs/tarinkot-air-operations-manifest.md`
- `docs/evidence/tarinkot-g2-object-contract-acceptance-checklist-2026-08-03.md`
- `docs/evidence/tarinkot-g2-owner-acceptance-2026-08-03.md`
- `docs/evidence/tarinkot-g4-moose-2-9-18-source-review.md`
- `expected/g5-read-only-diagnostics-acceptance.md`
- `results/2026-08-03-g5-read-only-diagnostics-initial-fail.md`
- `results/2026-08-03-g5-read-only-diagnostics-retest-pass.md`

Ein im Projektverlauf referenziertes `mission/tests/GOVERNANCE.md` ist auf diesem Branch und auf `main` nicht vorhanden. Die geltenden Regeln werden daher aus den oben genannten Governance- und Workflow-Dokumenten übernommen.

## 3. Paketstruktur

```text
mission/tests/tarinkot-air-operations/
├── README.md
├── expected/
│   └── g5-read-only-diagnostics-acceptance.md
├── results/
│   ├── 2026-08-03-g5-read-only-diagnostics-initial-fail.md
│   └── 2026-08-03-g5-read-only-diagnostics-retest-pass.md
├── src/
│   └── 01-tarinkot-g5-read-only-diagnostics.lua
└── dist/
    └── OMW_AirOps_Tarinkot_G5_ReadOnly.lua   # lokal generiert

tools/
└── build-tarinkot-air-operations-g5-diagnostics.ps1
```

Dateien unter `dist/` werden ausschließlich durch den Builder erzeugt und nicht manuell bearbeitet.

## 4. G5-Funktionsumfang und bestätigtes Ergebnis

Das Diagnosebundle protokollierte:

- Builder-, Branch- und Commit-Provenienz;
- erwartete Mission und Hashes;
- Airbase-ID 9, Runtime-Name, normale und eindeutige ID;
- sämtliche MOOSE-Parking-Datensätze;
- `TerminalID`, `TerminalID0`, `TerminalType`, `Free`, `TOAC`, Belegung und Koordinaten;
- die drei Client-Templates einschließlich Parking-Wert und Lua-Datentyp;
- die drei AI-Seeds einschließlich Typ, Gruppengröße, Skill und Late Activation;
- den Warehouse-Anker und seine Eindeutigkeit;
- zwölf erwartete Tarinkot-Statics;
- eine vorhandene und zehn erwartbar fehlende Funktionszonen;
- doppelt vergebene Namen innerhalb des angenommenen Objektvertrags.

Bestätigt:

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

## 5. Read-only-Sperre

G5 durfte und hat nicht:

```text
AIRWING erzeugen
SQUADRON erzeugen
Payloads registrieren
SQUADRON-Parking-IDs setzen
Assets anfordern oder spawnen
Gruppen aktivieren
AUFTRAG erzeugen
COMMANDER erzeugen oder starten
OPSTRANSPORT erzeugen
CampaignState verändern
MIZ-Strukturen verändern
```

Bestätigte Laufzeitzeile:

```text
READ_ONLY_LOCK AIRWING=0 SQUADRON=0 PAYLOAD=0 SPAWN=0 AUFTRAG=0 COMMANDER=0 OPSTRANSPORT=0 CAMPAIGNSTATE_MUTATION=0 MIZ_MUTATION=0
```

Der Retest enthielt keine Tarinkot-G5-spezifische Lua-, Scheduler- oder Timer-Exception.

## 6. Parking-Ausgangsdaten für G6

G5 erfasste 33 Parking-Datensätze. Die drei belegten Client-Reservierungen bleiben harte Sperren:

```text
TerminalID 20 / C01-H / CLIENT_US_TKOT_AH64D_01
TerminalID  8 / C05-H / CLIENT_US_TKOT_AH64D_02
TerminalID  3 / C07-H / CLIENT_US_TKOT_CH47F_01
```

Alle drei besitzen Runtime-`TerminalType=40`, `Free=false` und `TOAC=true`.

Datentypbesonderheit:

```text
CLIENT_US_TKOT_AH64D_01 unit.parking = "20"  # Lua string
CLIENT_US_TKOT_AH64D_02 unit.parking = 8     # Lua number
CLIENT_US_TKOT_CH47F_01 unit.parking = 3     # Lua number
```

G6 muss Terminal-IDs numerisch normalisieren, ohne das Mission-Editor-Template stillschweigend zu verändern.

Noch nicht akzeptiert:

```yaml
acceptedAHParkingIds: []
acceptedUH60ParkingIds: []
acceptedCH47ParkingIds: []
```

## 7. Aktuelles Zonenbild

```yaml
expected_zones: 11
expected_present:
  - OMW_LOG_NODE_TARINKOT
expected_missing: 10
```

Die fehlenden Funktionszonen waren in G5 kein Strukturfehler. G6 benötigt noch keine Funktionszone. Zonenabhängige Missionstests bleiben jedoch bis zur jeweiligen Mission-Editor-Anlage gesperrt.

## 8. Ergebnisfolge

Initialer Lauf:

```text
Commit: 2c0d76aee2f1cb987872d9903909bd21c904609d
RESULT ... status=FAIL_STRUCTURE coreMissing=1 zonesMissing=10 mutationCount=0
MISSING STATIC name=STATIC_AIR_US_TKOT_AH64_07
```

Maßgeblicher Retest:

```text
Commit: 8b2e62878f2421ba894a7abff7c12d526f4cea3d
STATIC_AIR_US_TKOT_AH64_07 type=AH-64D_BLK_II
STATIC_SUMMARY expected=12 missing=0
RESULT ... status=PASS_STRUCTURE coreMissing=0 zonesMissing=10 mutationCount=0
```

Der PASS bestätigt nur die read-only Datenerfassung und den G5-Strukturvertrag. Er bestätigt keine Parking-Eignung, keine Rotorfreiheit und keine operative MOOSE-Funktion.

## 9. Nächster zulässiger Schritt: G6

G6 darf jetzt:

1. die 33 Parking-Terminals nach Terminaltyp und physischer Lage klassifizieren;
2. Client- und Static-Überlappungen bestimmen;
3. Kandidatenlisten getrennt für AH-64, UH-60 und CH-47 bilden;
4. isolierte Spawn-/Cold-Start-Kalibrierungen definieren;
5. fehlerhafte oder kollidierende Kandidaten verwerfen.

G6 darf vor dem dokumentierten PASS weiterhin nicht:

```text
SQUADRON:SetParkingIDs() in die operative Foundation übernehmen
SetAllowSpawnOnClientParking() aktivieren
mehrere Fluggerätfamilien gleichzeitig testen
operative Missionen oder Transporte starten
G7-AIRWING/SQUADRON aktivieren
```

## 10. Ergebnisdokumentation

Jeder DCS-Lauf erhält einen unveränderlichen Bericht unter `results/`. Er enthält mindestens:

- Branch und Commit;
- Builder-Version;
- Bundle- oder Evidenz-Hash soweit im Testartefakt verfügbar;
- Missionsdatei und MOOSE-Provenienz;
- relevante Logzeilen;
- Parking-Dump;
- PASS, PARTIAL oder FAIL;
- Parking-/Datentyp-Besonderheiten;
- Folgerungen für das nächste Gate.
