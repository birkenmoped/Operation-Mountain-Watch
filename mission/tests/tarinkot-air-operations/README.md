---
document_id: OMW-TEST-TKOT-AIR-OPS-INDEX
status: DRAFT
document_class: TEST_PACKAGE_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - Tarinkot Air Operations test-package layout
  - accepted G5 read-only diagnostics
  - accepted G6 parking mapping and controlled placement
  - accepted G7 AIRWING, SQUADRON and payload foundation
  - corrected G7 lifecycle and observer-client static guard
  - current G8 block and central-consolidation dependency
  - airport-level batching and failure-isolation boundary
not_authoritative_for:
  - tactical AUFTRAG or vertical-departure acceptance
  - COMMANDER or OPSTRANSPORT acceptance
  - return, landing, recovery, loss or persistence acceptance
  - merge approval or Ready-for-Review approval
scenario_period: 2010-08-01/2011-12-31
project_phase: TARINKOT_G7_ACCEPTED_G8_BLOCKED
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: partial
supersedes: []
superseded_by: []
---

# Tarinkot Air Operations – Testpaket

## 1. Aktueller Gate-Stand

```yaml
G0_provenance: PASS_BRANCH
G1_ORBAT_and_evidence: PASS_BRANCH
G2_object_contract: OWNER_ACCEPTED_BRANCH
G3_mission_editor: PARTIAL_FUNCTION_ZONES_PENDING
G4_MOOSE_source_review: PASS_SOURCE_REVIEW
G5_read_only_diagnostics: PASS_DCS
G6A_geometric_dataset: PASS_DCS_SCOPE_TOO_BROAD_FOR_PRODUCTIVE_LISTS
G6A2_ME_MOOSE_mapping: PASS_DCS
G6B_first_combined_run: FAIL_VISUAL_WRONG_APRON
G6B_final_free_spots: PASS_DCS_OWNER_VISUAL_ACCEPTED
G7_airwing_squadron_payload: PASS_DCS_WITH_TELEMETRY_FIELD_CORRECTION
G7_lifecycle_guard_correction: IMPLEMENTED_STATIC_VALIDATION_REQUIRED
central_lifecycle_consolidation: DRAFT_PR_55_NOT_ON_MAIN
G8_direct_dispatch_vertical_departure: BLOCKED_BY_CENTRAL_CONSOLIDATION_AND_STATIC_GATE
G9_commander: BLOCKED_BY_G8
G10_lifecycle_results_handoff: NOT_STARTED
```

Kein weiterer längerer DCS-Lauf ist zulässig, bevor:

```text
Draft PR #55 als zentrale Projektbaseline geprüft und ausdrücklich für main freigegeben wurde
der G7-Builder den gemeinsamen Lifecycle-Guard erfolgreich durchläuft
README, Acceptance, Manifest, Ergebnisbericht und PR #53 denselben Stand führen
die nächste MIZ-/Bundle-Hashkette vollständig feststeht
```

## 2. Akzeptierte Basis

### G5

```text
Airbase: Tarinkot / ID 9
Parkingnodes: 33
Warehouse: WH_AIR_US_TARINKOT
Clients: 3/3
AI-Seeds: 3/3
Statics: 12/12
Zonen: 1 vorhanden / 10 ausstehend
Namensduplikate: 0
Mutationen: 0
```

Hard Client Exclusions:

```text
TerminalID 3
TerminalID 8
TerminalID 20
```

### G6

G6A verwendete zunächst einen zu breiten `HelicopterUsable`-Scope und nahm type-104-General-Apron-Positionen auf. Dieser Lauf ist für produktive Pools verworfen.

G6A2 mappte alle 33 Mission-Editor-Positionen auf MOOSE-TerminalIDs:

```text
RESULT G6A2_ME_PARKING_MAP
status=PASS_MAP
anchors=30
mapped=30
rejected=0
ambiguous=0
duplicates=0
parkingCount=33
clientReferences=3
```

Der erste kombinierte G6B-Lauf scheiterte visuell:

```text
FAIL_VISUAL_WRONG_APRON
```

Der finale type-40-Lauf bestand Runtime- und Eigentümerprüfung:

```text
RESULT G6B_HELICOPTER_APRON_COMBINED
status=PASS_RUNTIME_PLACEMENT
expectedGroups=7
groupsFound=7
expectedUnits=8
unitsFound=8
placementFailures=0
familyFailures=0
spawnCalls=7
expectedTerminalType=HelicopterOnly
```

Akzeptierte operative Pools:

```yaml
AH64:
  ME: [C04-H, C18-H]
  TerminalIDs: [21, 4]
UH60:
  ME: [C14-H, C12-H, C11-H]
  TerminalIDs: [30, 27, 23]
CH47:
  ME: [C08-H, C09-H, C10-H]
  TerminalIDs: [32, 29, 10]
```

G6B ist ausschließlich der Parking-/Platzierungsnachweis. Raw-SPAWN-, direkte UNIT- und standalone-FLIGHTGROUP-Abflugexperimente sind kein Bestandteil des akzeptierten Produktionspfads.

## 3. G7 – akzeptierter Foundation-Lauf

Ergebnisbericht:

```text
results/2026-08-04-g7-airwing-squadron-payload-foundation-pass.md
```

Akzeptierte Provenienz:

```text
Source commit: add569fb3231a5563d9c89f865cce7bd764bc0bb
BuilderVersion: TKOT-G7-AIRWING-FOUNDATION-3
Bundle SHA-256: 7018f4e388a349f91bc4169e6200226a32c001e3c4afdbd4daf69b538de2dea8
MIZ SHA-256: 86ba08f46c78a94cdf6eb54f7abe85145bdabe2817e7a2a89f2cec34932866bb
Internal mission SHA-256: babaaee09f38ecbacb0c564b1686e20ee5b18ccf9b8abd920f32952d4a8f54a8
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
DCS log SHA-256: aeacc9fc9270dc033ed49a41eb1b3264880710265386f1d21e0c787a22739e52
Debrief SHA-256: 8a33b90efdf57f92a95ff2b07d0c016555d79776da3b708367f63ef09a284588
```

Bestätigter G7-Umfang:

```text
AIRWING Running
3 SQUADRONs
5 registrierte Warehouse-Assetgruppen
7 registrierte KI-Luftfahrzeuge
3 Rollen-Payloads
3 automatische RELOCATECOHORT-Payloads
8 akzeptierte HelicopterOnly-ParkingIDs
0 Missionen
0 Transporte
0 Warehouse-Requests
0 OPSGROUPs
0 deliberate Spawns
```

Pre-Start:

```text
Warehouse-Stock: 2 -> 4 -> 5
squadron.assets: 0/0/0 als erwarteter Deferred-Zustand
```

Post-Start:

```text
squadron.assets: 2/2/1
Warehouse-Stock: 5
AIRWING: Running
```

Damit ist die Lifecycle-Grenze praktisch bestätigt:

```text
AIRWING:AddSquadron()
  -> Warehouse-Stock registriert

AIRWING:Start() plus Initialisierung
  -> Assets an COHORT/SQUADRON gebunden
  -> squadron.assets post-start prüfbar
```

## 4. G7-Telemetriekorrektur

Der Lauf erkannte korrekt:

```text
CLIENT_US_TKOT_AH64D_01_UNIT_01
Player: Neues Rufz.
observerClientsDetected: 1
observerClientsAllowed: 1
observerClientsBlocking: 0
```

Das alte Endmarkerfeld:

```text
activePlayerClients=0
```

ist verworfen. Der Builder-Footer hatte nach der korrekten Detektion den Rückgabewert auf null gesetzt. Dies beeinflusste weder AIRWING, SQUADRONs, Stock, Payloads noch Spawns, war aber eine fehlerhafte Ergebnisdarstellung.

Künftige Bundles dürfen den Detektionswert nicht maskieren. Sie protokollieren getrennt:

```text
observerClientsDetected
observerClientsAllowed
observerClientsBlocking
observerClientUnits
```

## 5. Korrigierter statischer Builderstand

Builder:

```text
tools/build-tarinkot-air-operations-g7-foundation.ps1
```

Vorbereitete Builder-Version:

```text
TKOT-G7-AIRWING-FOUNDATION-4
```

Gemeinsamer Guard:

```text
tools/Test-AirOpsLifecycleGuards.ps1
```

CI-Workflow:

```text
.github/workflows/tarinkot-g7-static-validation.yml
```

Der korrigierte Builder:

- prüft Warehouse-Stock vor Start;
- prüft `squadron.assets` und Parking-Vererbung nach Start;
- setzt `AIRWING:SetOptionPreferVerticalLanding()` vor `AIRWING:Start()`;
- verbietet Observer-Zählwertmaskierung;
- gibt detected/allowed/blocking getrennt aus;
- verbietet COMMANDER, AUFTRAG-Instanzen, OPSTRANSPORT und SPAWN im G7-Foundation-Scope.

Builder-Version 4 ist eine statische Harnesskorrektur. Sie ändert den akzeptierten G7-Funktionsumfang nicht und benötigt keinen erneuten 30-Minuten-DCS-Lauf. Vor G8 muss der Builder-/Guard-Workflow erfolgreich sein.

## 6. Vertikaloption und G8-Grenze

G7 setzte in der akzeptierten Reihenfolge:

```lua
airwing:SetOptionPreferVerticalLanding()
airwing:Start()
```

G7 beweist nur den gesetzten AIRWING-Konfigurationszustand. Im nativen MOOSE-Dispatch wird diese Option im `FlightOnMission`-Pfad auf die erzeugte FLIGHTGROUP weitergegeben.

Noch nicht akzeptiert:

```text
reale FLIGHTGROUP im Tarinkot-Dispatch
Optionweitergabe im Runtimeereignis
tatsächliches vertikales Abheben
kein Taxi- oder Runwayverhalten
```

Diese Punkte gehören gemeinsam in einen einzigen isolierten G8-AIRWING-/AUFTRAG-Lauf nach Abschluss der zentralen Konsolidierung.

## 7. Testbündelung

Technisch zusammengehörige Flughafenprüfungen werden standardmäßig kombiniert:

```text
ein Bundle
eine Mission-Editor-Ersetzung
ein DCS-Lauf
Subsystemmarker
ein Aggregatergebnis
```

Kleinere Läufe entstehen nur, wenn der kombinierte Log die Fehlerursache nicht isolieren kann.

## 8. Paketstruktur

```text
mission/tests/tarinkot-air-operations/
├── README.md
├── expected/
│   ├── g5-read-only-diagnostics-acceptance.md
│   ├── g6a-parking-candidate-analysis-acceptance.md
│   ├── g6b-combined-placement-acceptance.md
│   ├── g6b-controlled-placement-acceptance.md
│   ├── g6b-helicopter-apron-retest-acceptance.md
│   └── g7-airwing-squadron-payload-foundation-acceptance.md
├── results/
│   ├── 2026-08-03-g5-read-only-diagnostics-initial-fail.md
│   ├── 2026-08-03-g5-read-only-diagnostics-retest-pass.md
│   ├── 2026-08-03-g6a-parking-candidate-analysis-pass.md
│   ├── 2026-08-03-g6b-combined-placement-fail-wrong-apron.md
│   ├── 2026-08-04-g6b-final-free-spots-pass-and-departure-scope-correction.md
│   └── 2026-08-04-g7-airwing-squadron-payload-foundation-pass.md
├── src/
│   ├── 01-tarinkot-g5-read-only-diagnostics.lua
│   ├── 02-tarinkot-g6a-parking-candidate-analysis.lua
│   ├── 03-tarinkot-g6b-controlled-placement.lua
│   ├── 04-tarinkot-g6b-combined-placement.lua
│   ├── 05-tarinkot-g6b-helicopter-apron-retest.lua
│   ├── 06-tarinkot-g6a2-me-parking-map.lua
│   └── 07-tarinkot-g7-airwing-squadron-payload-foundation.lua
└── dist/
    └── ausschließlich lokal generierte Bundles
```

## 9. Gate-Wirkung

```yaml
G7: ACCEPTED_TECHNICAL_BASELINE
G8_authorization: WITHHELD
reason:
  - central lifecycle governance remains Draft PR 55 and is not on main
  - corrected G7 builder must pass static workflow
  - next MIZ/bundle identity must be established
```

PR #53 bleibt Draft. Kein Merge und kein Ready for Review ohne ausdrückliche Freigabe des Projektinhabers.
