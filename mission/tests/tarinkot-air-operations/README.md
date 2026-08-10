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
  - documented G8-G8D diagnostic history
  - current branch closure state for Tarinkot AirOps
not_authoritative_for:
  - repository-wide production acceptance
  - successful AH-64D direct vertical ramp departure at Tarinkot
  - deterministic return-to-original-parking recovery
  - COMMANDER or OPSTRANSPORT acceptance
  - merge approval or Ready-for-Review approval
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit: 585f3c46d4ff0a4b167c984d427bcdb356138e69
validated_in_dcs: partial
supersedes: []
superseded_by: []
---

# Tarinkot Air Operations – Testpaket

## 1. Aktueller Stand

Der Tarinkot-AirOps-Arbeitsgang wird für die aktuelle `COMPLETE_FOUNDATION_BUILD_PHASE` mit bekannten Einschränkungen beendet.

```yaml
G0_provenance: PASS_BRANCH
G1_ORBAT_and_evidence: PASS_BRANCH
G2_object_contract: OWNER_ACCEPTED_BRANCH
G3_mission_editor: PARTIAL_FUNCTION_ZONES
G4_MOOSE_source_review: PASS_FOR_USED_SCOPE
G5_read_only_diagnostics: PASS_DCS
G6A_geometric_dataset: PASS_DCS_SCOPE_TOO_BROAD_FOR_PRODUCTIVE_LISTS
G6A2_ME_MOOSE_mapping: PASS_DCS
G6B_first_combined_run: FAIL_VISUAL_WRONG_APRON
G6B_final_free_spots: PASS_DCS_OWNER_VISUAL_ACCEPTED_DIRECT_SPAWN_ONLY
G7_airwing_squadron_payload: PASS_DCS_FOR_DOCUMENTED_SCOPE
G7_lifecycle_guard_correction: PASS_STATIC_CI
central_lifecycle_consolidation: PASS_MAIN
Tarinkot_main_sync: PASS
parking_contract_reconciliation: COMPLETE_BRANCH
G8_first_runtime_attempt: BLOCKED_MISSING_TARGET_ZONE
G8_second_runtime_attempt: BLOCKED_MOOSE_WAREHOUSE_PARKING_OBSTACLE_CONFLICT
G8C_first_runtime_with_stale_layout: BLOCKED_LAYOUT_CONTRACT_MISMATCH
G8C_uniform_rotary_hover_dispatch: FAIL_AH64_DIRECT_VERTICAL_DEPARTURE
G8D_AH64_Jalalabad_profile_AB: FAIL_AH64_DIRECT_VERTICAL_DEPARTURE
vertical_option_propagation: CONFIRMED_DCS
AH64_direct_vertical_ramp_departure_Tarinkot: UNRESOLVED
return_to_original_parking: UNRESOLVED
root_cause: UNKNOWN
MOOSE_parking_override_research: COMPLETE_NO_AUTHORIZED_OVERRIDE
Tarinkot_AirOps_current_phase: CLOSED_WITH_KNOWN_LIMITATIONS
next_action: NONE_FOR_CURRENT_FOUNDATION_PHASE
```

Der vollständige Abschluss- und Erfahrungsbericht ist:

- [`results/2026-08-09-tarinkot-airops-closure-unresolved-ah64-airbase-behavior.md`](results/2026-08-09-tarinkot-airops-closure-unresolved-ah64-airbase-behavior.md)

Frühere blockierte oder fehlgeschlagene Läufe bleiben historische Evidenz und dürfen nicht als aktuelle Ursache oder Lösung interpretiert werden.

## 2. Aktueller Parking-Vertrag

Verbindliche Arbeitszuordnung im Branch:

```yaml
clients:
  AH64: [21, 8]       # C04-H, C05-H
  CH47: [3]           # C07-H
ai_parking:
  AH64: [20, 19]      # C01-H, C21-H
  UH60: [23, 27, 30]  # C11-H, C12-H, C14-H
  CH47: [32, 29, 10]  # C08-H, C09-H, C10-H
```

Die Client-TerminalIDs `21`, `8` und `3` sind harte KI-Ausschlüsse. Der historische AH-64-Pool `21,4` ist für den aktuellen G7/G8-Pfad verworfen.

## 3. Akzeptierte Foundation-Erkenntnisse

### G5

```text
Airbase: Tarinkot / ID 9
Parkingnodes: 33
Warehouse: WH_AIR_US_TARINKOT
Clients: 3/3
AI-Seeds: 3/3
Statics: 12/12
Namensduplikate: 0
Mutationen: 0
```

### G6

G6A zeigte, dass ein zu breiter `HelicopterUsable`-Scope type-104-General-Apron-Positionen einbezieht und deshalb nicht unmittelbar als produktiver Parking-Pool verwendet werden darf.

G6A2 erzeugte die Mission-Editor-/MOOSE-TerminalID-Abbildung für Tarinkot.

Der erste kombinierte G6B-Lauf scheiterte visuell mit:

```text
FAIL_VISUAL_WRONG_APRON
```

Der finale HelicopterOnly-Platzierungslauf bestätigte die kontrollierte direkte Spawn-Platzierung für seinen exakten Testumfang. Dieser Nachweis ist kein Nachweis für AIRWING-Departure oder Recovery.

### G7

Der G7-Foundation-Pfad bestätigt für seinen dokumentierten DCS-Stand:

```text
AIRWING Running
3 SQUADRONs
5 registered Warehouse asset groups
7 registered AI aircraft
3 role payloads
safeParking=true
verticalPolicy=true
takeoffCold=true
0 operational missions in foundation scope
0 deliberate spawns in foundation scope
```

AH-64D bleibt als physischer Two-Ship modelliert:

```text
TPL_AIR_US_TKOT_AH64D_CAS_2SHIP
units=2
grouping=2
registeredGroups=2
registeredAircraft=4
```

Die G7-Telemetrie unterscheidet Observer-Clients korrekt in `detected`, `allowed` und `blocking`.

## 4. MOOSE-First-Erkenntnisse

Für den gepinnten Projektstand wurde geprüft und praktisch beobachtet:

```text
AIRWING:SetOptionPreferVerticalLanding()
  -> AIRWING configuration
  -> propagation during FlightOnMission
  -> FLIGHTGROUP:SetOptionPreferVertical()
  -> DCS PREFER_VERTICAL option
```

G8C und G8D bestätigten bei realen Tarinkot-FlightGroups `optionPreferVertical=true`.

Damit ist nicht mehr offen, ob die Option grundsätzlich propagiert wird. Offen ist, warum DCS bei Tarinkot für den AH-64D trotzdem nach einem kurzen vertikalen Anheben wieder Boden-/Taxi-/Runway-Verhalten wählt.

Die MOOSE-Parking-Override-Recherche ist dokumentiert unter:

- [`docs/moose/WAREHOUSE-PARKING-OVERRIDE-RESEARCH.md`](../../../docs/moose/WAREHOUSE-PARKING-OVERRIDE-RESEARCH.md)
- [`results/2026-08-05-g8-moose-parking-override-research-complete.md`](results/2026-08-05-g8-moose-parking-override-research-complete.md)

Es existiert keine Freigabe für einen MOOSE-Quellpatch oder einen Native-DCS-Parallelmechanismus.

## 5. G8/G8C – verworfene und blockierte Ansätze

Die G8-Folge dokumentierte mehrere voneinander getrennte Fehlerbilder:

```text
missing target zone
-> blocked before useful runtime dispatch

warehouse parking obstacle conflict
-> parking/recruitment problem, not proof about vertical departure

stale AH64 parking IDs 21,4
-> invalid against current client/AI contract

uniform AUFTRAG:NewHOVER()
-> optionPreferVertical propagated
-> AH64 direct ramp departure still failed visually
```

G8C forderte bewusst zwei AH-64-Two-Ships an. Wiederholte `No free parking spot`-Meldungen für `AID-94` betreffen den zweiten Two-Ship bei nur zwei dedizierten AH-64-AI-Spots. Diese Warnungen erklären nicht das falsche Verhalten des bereits gespawnten ersten Two-Ships.

## 6. G8D – Jalalabad-Profil als Tarinkot-A/B-Test

G8D beseitigte die Nahbereichsgeometrie als Störvariable und testete exakt einen AH-64D-Two-Ship mit einem langen CAS-Profil:

```text
mission type: CAS
target distance: 8000 m
CAS radius: 1500 m
ingress distance: 3000 m
egress distance: 5000 m
altitude: 3500 ft
speed: 110 kt
formation: EchelonRight300
parking IDs: 20,19
required assets: 1 two-ship group
```

Runtime-Telemetrie:

```text
group=SQ_US_TKOT_AH64D_3_101_AVN_AID-93
runtimeUnits=2/2
missionType=CAS
optionPreferVertical=true
```

Automatisiertes Ergebnis:

```text
status=FAIL
reason=TAKEOFF_TIMEOUT
airborneUnits=0/2
assigned=true
runtimeUnits=2/2
takeoff=false
optionPreferVertical=true
```

Die Sichtbeobachtung zeigte nach vollständiger Startbereitschaft weiterhin:

```text
short vertical lift/hover
-> heading alignment
-> touchdown
-> taxi
-> runway departure procedure
```

Damit ist die Hypothese verworfen, dass nur `HOVER` oder ein extrem nahes 35/60-m-Ziel die Ursache sei.

## 7. Vergleich Jalalabad

Jalalabad liefert im selben DCS-/MOOSE-Kontext einen wichtigen Gegenbeleg:

```text
AH-64D physical two-ship
AUFTRAG CAS
preferVerticalTakeoffAndLanding=true
parking pool with dedicated helicopter positions
```

Dort wurde visuell ein sauberer direkter Ramp-Abflug ohne Taxi zur Startbahn beobachtet.

Deshalb sind folgende Pauschalhypothesen für Tarinkot verworfen:

```text
AH-64D cannot vertically depart under MOOSE
Two-Ship inherently prevents vertical departure
CAS inherently forces runway departure
SetOptionPreferVerticalLanding is missing
only short target geometry causes the Tarinkot behavior
```

Die Root Cause bleibt unbekannt. Airbase-/Parking-/Taxi-Graph-/Route-spezifisches DCS-Verhalten bleibt eine mögliche, aber nicht bewiesene Erklärung.

## 8. Recovery-/Landing-Grenze

Zurückkehrende Rotary-Gruppen landen in Tarinkot nicht zuverlässig an ihrem ursprünglichen Abstellplatz. Sichtbar waren auch geometrisch unplausible beziehungsweise quer zur erwarteten Ramp-Geometrie liegende Landungen.

`SQUADRON:SetParkingIDs()` wird im Projekt als erlaubter Parking-Pool für die Asset-/Spawn-Seite behandelt. Für den getesteten Stand existiert kein Nachweis, dass diese Methode eine persistente Zuordnung

```text
aircraft -> original terminal -> deterministic return to same terminal
```

garantiert.

Ein künftiger Ansatz über MOOSE-Lifecycle beziehungsweise `despawnAfterLanding` wäre eine neue Designentscheidung und ist für Tarinkot weder genehmigt noch validiert.

## 9. Wiederaufnahmegrenze

Eine spätere Wiederaufnahme soll nicht wieder bei den bereits verworfenen Hypothesen beginnen. Noch offen und technisch sinnvoll wären insbesondere:

```text
Tarinkot versus Jalalabad DCS parking/taxi graph comparison
Terminal type and taxi-link topology for IDs 20/19 versus 51/26
generated DCS route/task comparison after AIRWING dispatch
alternative Tarinkot HelicopterOnly pair as an isolated airbase-geometry test
public MOOSE recovery/lifecycle APIs for deterministic-looking return behavior
DCS-engine-only reproduction, only after explicit owner authorization
```

Vor projektspezifischer oder nativer DCS-Logik gilt weiterhin `docs/26-moose-first-development-policy.md`.

## 10. Zentrale Ergebnisberichte

```text
results/2026-08-03-g5-read-only-diagnostics-initial-fail.md
results/2026-08-03-g5-read-only-diagnostics-retest-pass.md
results/2026-08-03-g6a-parking-candidate-analysis-pass.md
results/2026-08-03-g6b-combined-placement-fail-wrong-apron.md
results/2026-08-04-g6b-final-free-spots-pass-and-departure-scope-correction.md
results/2026-08-04-g7-airwing-squadron-payload-foundation-pass.md
results/2026-08-05-g8-moose-parking-override-research-complete.md
results/2026-08-09-g8c-blocked-layout-contract-mismatch.md
results/2026-08-09-tarinkot-airops-closure-unresolved-ah64-airbase-behavior.md
```

## 11. Paketstruktur

```text
mission/tests/tarinkot-air-operations/
├── README.md
├── expected/
├── results/
├── src/
│   ├── 01-... diagnostics
│   ├── 02-... parking candidate analysis
│   ├── 03-... controlled placement
│   ├── 04-... combined placement
│   ├── 05-... helicopter apron retest
│   ├── 06-... ME parking map
│   ├── 07-... G7 foundation
│   ├── 08-... G8 UH60 vertical dispatch
│   ├── 10-... G8C uniform rotary hover dispatch
│   └── 11-... G8D AH64 Jalalabad-profile A/B
└── dist/
    └── locally generated bundles only
```

## 12. Abschlussstatus

```yaml
foundation: COMPLETE_FOR_CURRENT_PHASE
parking_contract: RECONCILED_BRANCH
vertical_option_propagation: CONFIRMED_IN_DCS
AH64_direct_vertical_ramp_departure_Tarinkot: FAIL_VISUAL_UNRESOLVED
return_to_original_parking: NOT_PROVEN_AND_VISUALLY_UNSATISFACTORY
root_cause: UNKNOWN
native_DCS_override: NOT_AUTHORIZED
MOOSE_source_patch: NOT_AUTHORIZED
current_phase_action: CLOSE_TARINKOT_AIROPS_WITH_KNOWN_LIMITATIONS
```

PR #53 bleibt Draft. Merge beziehungsweise Ready-for-Review ist von diesem Testpaket-Abschluss nicht automatisch freigegeben.