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
  - accepted G7 lifecycle and observer-client static guard
  - current owner-confirmed revised parking contract and G8 revalidation state
  - airport-level batching and failure-isolation boundary
not_authoritative_for:
  - tactical AUFTRAG or vertical-departure acceptance
  - COMMANDER or OPSTRANSPORT acceptance
  - return, landing, recovery, loss or persistence acceptance
  - merge approval or Ready-for-Review approval
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/tarinkot-revised-parking-layout
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
G3_mission_editor: PARTIAL_FUNCTION_ZONES
G4_MOOSE_source_review: PASS_FOR_LIFECYCLE_BUT_PARKING_OVERRIDE_RESEARCH_COMPLETE
G5_read_only_diagnostics: PASS_DCS
G6A_geometric_dataset: PASS_DCS_SCOPE_TOO_BROAD_FOR_PRODUCTIVE_LISTS
G6A2_ME_MOOSE_mapping: PASS_DCS
G6B_first_combined_run: FAIL_VISUAL_WRONG_APRON
G6B_final_free_spots: PASS_DCS_OWNER_VISUAL_ACCEPTED_DIRECT_SPAWN_ONLY
G7_airwing_squadron_payload: PASS_DCS_WITH_TELEMETRY_FIELD_CORRECTION
G7_lifecycle_guard_correction: PASS_STATIC_CI
central_lifecycle_consolidation: PASS_MAIN
Tarinkot_main_sync: PASS
G8_previous_static_implementation: PASS_STATIC_CI
G8_first_runtime_attempt: BLOCKED_MISSING_TARGET_ZONE
G8_second_runtime_attempt: BLOCKED_MOOSE_WAREHOUSE_PARKING_OBSTACLE_CONFLICT
G8_third_runtime_attempt: PASS_WITH_HARNESS_TIMEOUT_LIMITATION
G8_vertical_departure: PASS_DCS_OWNER_VISUAL_ACCEPTED
MOOSE_parking_override_research: COMPLETE
revised_ME_layout: OWNER_CONFIRMED
revised_parking_lua: PASS_DCS_OBJECT_CONTRACT
next_action: BUILD_AND_STATIC_VALIDATE_COMBINED_ALL_REGISTERED_HELICOPTER_DISPATCH
G9_commander: BLOCKED_BY_G8B
G10_lifecycle_results_handoff: NOT_STARTED
```

Die frühere Eigentümerentscheidungssperre für MIZ- und Parking-Pool-Änderungen ist
durch die bestätigte ME-Änderung und den neuen Parkingvertrag aufgehoben. Weiterhin
gilt:

```text
kein DCS-Rerun
kein MOOSE-Override oder MOOSE-Quellpatch
```

Die vorgeschriebene MOOSE-Quellenrecherche ist abgeschlossen:

- [`docs/moose/WAREHOUSE-PARKING-OVERRIDE-RESEARCH.md`](../../../docs/moose/WAREHOUSE-PARKING-OVERRIDE-RESEARCH.md)
- [`results/2026-08-05-g8-moose-parking-override-research-complete.md`](results/2026-08-05-g8-moose-parking-override-research-complete.md)

Sie ergab keinen dokumentierten WAREHOUSE-Setter oder -Hook für die lokalen Scanwerte. Technische Overrides sind möglich, aber nicht autorisiert.

Aktueller, vom Projektinhaber bestätigter Folge-Vertrag:

```yaml
client_terminal_ids:
  AH64: [21, 8]       # C04-H, C05-H
  CH47: [3]           # C07-H
ai_parking_pools:
  AH64: [20, 19]      # C01-H, C21-H
  UH60: [23, 27, 30]  # C11-H, C12-H, C14-H
  CH47: [32, 29, 10]  # C08-H, C09-H, C10-H
```

Siehe
[`results/2026-08-09-owner-confirmed-revised-parking-layout-and-lua-contract.md`](results/2026-08-09-owner-confirmed-revised-parking-layout-and-lua-contract.md).
Der Vertrag ist implementiert, aber noch nicht im DCS revalidiert.

## 2. Akzeptierte Basis

Die folgenden G5–G7-Angaben sind historische Acceptance-Evidenz für die frühere
Missionsgeometrie. Sie werden nicht rückwirkend auf den neuen Parkingvertrag
umgeschrieben.

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

Builder-Version:

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

Akzeptierte statische Prüfung:

```text
GitHub Actions workflow: Tarinkot G7 static validation
Run ID: 30954380156
Result: SUCCESS
Validated head: 940330f5213a8da856bca5c456cd38872b747da7
```

Der korrigierte Builder:

- prüft Warehouse-Stock vor Start;
- prüft `squadron.assets` und Parking-Vererbung nach Start;
- setzt `AIRWING:SetOptionPreferVerticalLanding()` vor `AIRWING:Start()`;
- verbietet Observer-Zählwertmaskierung;
- gibt detected/allowed/blocking getrennt aus;
- verbietet COMMANDER, AUFTRAG-Instanzen, OPSTRANSPORT und SPAWN im G7-Foundation-Scope.

Builder-Version 4 ist eine statisch akzeptierte Harnesskorrektur. Sie ändert den akzeptierten G7-Funktionsumfang nicht und benötigt keinen erneuten 30-Minuten-DCS-Lauf.

## 6. Vertikaloption, G8 und gebündelter G8B-Folgetest

G7 setzte in der akzeptierten Reihenfolge:

```lua
airwing:SetOptionPreferVerticalLanding()
airwing:Start()
```

Der G8-2-Lauf bestätigte den nativen `FlightOnMission`-Pfad,
`optionPreferVertical=true`, vertikalen UH-60-Abflug, Zielflug und Außenlandung.
Der automatische 240-Sekunden-Timeout war ein False Negative und wird nicht in
einem weiteren UH-60-Einzellauf wiederholt.

G8B bündelt stattdessen alle fünf registrierten KI-Gruppen in einem Lauf:

```text
2 AH-64-Zweiergruppen
2 UH-60-Einzelgruppen
1 CH-47-Einzelgruppe
7 Runtime-Luftfahrzeuge
```

Einzelläufe sind nur noch zur Isolation eines konkret protokollierten Fehlers
zulässig.

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
│   ├── g7-airwing-squadron-payload-foundation-acceptance.md
│   ├── g8-uh60-native-vertical-departure-acceptance.md
│   └── g8b-combined-helicopter-dispatch-acceptance.md
├── results/
│   ├── 2026-08-03-g5-read-only-diagnostics-initial-fail.md
│   ├── 2026-08-03-g5-read-only-diagnostics-retest-pass.md
│   ├── 2026-08-03-g6a-parking-candidate-analysis-pass.md
│   ├── 2026-08-03-g6b-combined-placement-fail-wrong-apron.md
│   ├── 2026-08-04-g6b-final-free-spots-pass-and-departure-scope-correction.md
│   ├── 2026-08-04-g7-airwing-squadron-payload-foundation-pass.md
│   └── 2026-08-09-g8-uh60-pass-with-harness-limitation.md
├── src/
│   ├── 01-tarinkot-g5-read-only-diagnostics.lua
│   ├── 02-tarinkot-g6a-parking-candidate-analysis.lua
│   ├── 03-tarinkot-g6b-controlled-placement.lua
│   ├── 04-tarinkot-g6b-combined-placement.lua
│   ├── 05-tarinkot-g6b-helicopter-apron-retest.lua
│   ├── 06-tarinkot-g6a2-me-parking-map.lua
│   ├── 07-tarinkot-g7-airwing-squadron-payload-foundation.lua
│   ├── 08-tarinkot-g8-uh60-native-vertical-dispatch.lua
│   └── 09-tarinkot-g8b-combined-helicopter-dispatch.lua
└── dist/
    └── ausschließlich lokal generierte Bundles
```

## 9. Gate-Wirkung

```yaml
G7: ACCEPTED_TECHNICAL_BASELINE
G7_static_guard: PASS_STATIC_CI
central_lifecycle_governance: PASS_MAIN
G8: PASS_WITH_HARNESS_LIMITATION
G8B_combined_dispatch: IMPLEMENTED_AWAITING_BUILD_AND_DCS
G9_commander: BLOCKED_BY_G8B
```

PR #53 bleibt Draft. Kein Merge und kein Ready for Review ohne ausdrückliche Freigabe des Projektinhabers.
