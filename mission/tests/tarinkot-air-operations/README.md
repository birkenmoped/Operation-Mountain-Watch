---
document_id: OMW-TEST-TKOT-AIR-OPS-INDEX
status: DRAFT
document_class: TEST_PACKAGE_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - Tarinkot Air Operations test-package layout
  - current G5 read-only diagnostic build and execution workflow
  - separation of diagnostic evidence from runtime acceptance
not_authoritative_for:
  - DCS runtime acceptance before a documented PASS
  - final parking allowlists
  - AIRWING, SQUADRON, AUFTRAG, COMMANDER or OPSTRANSPORT activation
  - merge approval or Ready-for-Review approval
scenario_period: 2010-08-01/2011-12-31
project_phase: TARINKOT_G5_READ_ONLY_DIAGNOSTICS
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
G3_mission_editor: PARTIAL_STATIC_CORRECTION_REQUIRED
G4_MOOSE_source_review: PASS_SOURCE_REVIEW
G5_read_only_diagnostics: FAIL_RETEST_REQUIRED
G6_parking_calibration: BLOCKED_BY_G5
G7_airwing_squadron_payload: NOT_STARTED
G8_direct_dispatch_and_transport: NOT_STARTED
G9_commander_and_operational_parking: NOT_STARTED
G10_lifecycle_results_handoff: NOT_STARTED
```

G5 ist der erste Tarinkot-Lua-Test. Er ist ausschließlich diagnostisch und erzeugt keine operativen MOOSE-Objekte.

Der initiale DCS-Lauf bestätigte Provenienz, read-only-Verhalten, Airbase, Parking, Warehouse, Clients, AI-Seeds, Zonenbild und Namenseindeutigkeit. Der Strukturtest schlug ausschließlich fehl, weil `STATIC_AIR_US_TKOT_AH64_07` nicht als MOOSE-`STATIC` auflösbar war. Vor dem Retest muss dieses Mission-Editor-Objekt vom Legacy-Typ `AH-64D` auf `AH-64D_BLK_II` korrigiert werden.

## 2. Verbindliche Referenzen

- `docs/00-project-governance.md`
- `docs/22-test-mission-build-transfer-and-validation-workflow.md` auf dem Jalalabad-Testbranch, bis die Datei nach `main` integriert ist
- `docs/tarinkot-air-operations-manifest.md`
- `docs/evidence/tarinkot-g2-object-contract-acceptance-checklist-2026-08-03.md`
- `docs/evidence/tarinkot-g2-owner-acceptance-2026-08-03.md`
- `docs/evidence/tarinkot-g4-moose-2-9-18-source-review.md`
- `expected/g5-read-only-diagnostics-acceptance.md`
- `results/2026-08-03-g5-read-only-diagnostics-initial-fail.md`

Ein im Projektverlauf referenziertes `mission/tests/GOVERNANCE.md` ist auf diesem Branch und auf `main` nicht vorhanden. Die geltenden Regeln werden daher aus den oben genannten Governance- und Workflow-Dokumenten übernommen.

## 3. Paketstruktur

```text
mission/tests/tarinkot-air-operations/
├── README.md
├── expected/
│   └── g5-read-only-diagnostics-acceptance.md
├── results/
│   └── 2026-08-03-g5-read-only-diagnostics-initial-fail.md
├── src/
│   └── 01-tarinkot-g5-read-only-diagnostics.lua
└── dist/
    └── OMW_AirOps_Tarinkot_G5_ReadOnly.lua   # lokal generiert

tools/
└── build-tarinkot-air-operations-g5-diagnostics.ps1
```

Dateien unter `dist/` werden ausschließlich durch den Builder erzeugt und nicht manuell bearbeitet.

## 4. G5-Funktionsumfang

Das Diagnosebundle protokolliert:

- Builder-, Branch- und Commit-Provenienz;
- erwartete Mission und Hashes;
- Airbase-ID 9, Runtime-Name, normale und eindeutige ID;
- Airbase-Kategorie, Koalition und Land;
- sämtliche MOOSE-Parking-Datensätze;
- `TerminalID`, `TerminalID0`, `TerminalType`, `Free`, `TOAC`, Belegung und Koordinaten;
- die drei Client-Templates einschließlich Parking-Wert und Lua-Datentyp;
- die drei AI-Seeds einschließlich Typ, Gruppengröße, Skill und Late Activation;
- den Warehouse-Anker und seine Eindeutigkeit;
- zwölf erwartete Tarinkot-Statics;
- eine vorhandene und zehn derzeit erwartbar fehlende Funktionszonen;
- doppelt vergebene Namen innerhalb des angenommenen Objektvertrags.

## 5. Read-only-Sperre

G5 darf nicht:

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

Der Builder prüft den Quelltext vor dem Build gegen verbotene Konstruktoren und mutierende Aufrufe. Diese statische Prüfung ersetzt keinen DCS-Laufzeittest.

Der initiale Lauf bestätigte `mutationCount=0` und enthielt keine G5-Lua-Exception.

## 6. Erwartetes aktuelles Zonenbild

```yaml
expected_zones: 11
expected_present:
  - OMW_LOG_NODE_TARINKOT
expected_missing: 10
```

Fehlende Zonen sind in G5 kein Strukturfehler. Sie werden nur protokolliert und erst vor dem jeweiligen späteren Funktionstest im Mission Editor angelegt.

## 7. Testauswertung

Ein Lauf ist strukturell erfolgreich, wenn die Abschlusszeile enthält:

```text
RESULT G5_READ_ONLY_DIAGNOSTICS_COMPLETE status=PASS_STRUCTURE coreMissing=0 zonesMissing=10 mutationCount=0
```

Initialer Lauf:

```text
RESULT G5_READ_ONLY_DIAGNOSTICS_COMPLETE status=FAIL_STRUCTURE coreMissing=1 zonesMissing=10 mutationCount=0
```

Ursache:

```text
MISSING STATIC name=STATIC_AIR_US_TKOT_AH64_07
```

Ein PASS akzeptiert noch keine KI-Parkplätze und keine AIRWING-/SQUADRON-Laufzeitfunktion. Er liefert ausschließlich den Datensatz für G6.

## 8. Retest-Grenze

Vor dem Retest ist ausschließlich folgendes Mission-Editor-Objekt zu korrigieren:

```text
Name: STATIC_AIR_US_TKOT_AH64_07
Type: AH-64D_BLK_II
Position und Heading: unverändert
```

Andere Statics, Clients, AI-Seeds, Parking-Werte, Warehouse und Funktionszonen bleiben unverändert. Danach muss das Bundle wegen des geänderten Branch-Heads neu gebaut, erneut über `DO SCRIPT FILE` eingebettet und mindestens 25 Sekunden getestet werden.

## 9. Ergebnisdokumentation

Jeder DCS-Lauf erhält einen unveränderlichen Bericht unter `results/`. Er enthält mindestens:

- Branch und Commit;
- Builder-Version;
- Bundle-SHA-256;
- Missionsdatei und MOOSE-Provenienz;
- relevante Logzeilen;
- Parking-Dump;
- PASS, PARTIAL oder FAIL;
- erkannte Parking-/Datentyp-Besonderheiten;
- Folgerungen für G6.
