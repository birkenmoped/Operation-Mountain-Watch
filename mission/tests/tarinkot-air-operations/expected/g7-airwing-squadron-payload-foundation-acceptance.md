---
document_id: OMW-TEST-TKOT-G7-AIRWING-SQUADRON-PAYLOAD-FOUNDATION-ACCEPTANCE
status: ACCEPTED_TECHNICAL_BASELINE
document_class: TEST_ACCEPTANCE_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - accepted Tarinkot G7 AIRWING, SQUADRON, capability and payload foundation
  - application of G6-accepted SQUADRON parking pools
  - pre-start Warehouse stock and post-start SQUADRON asset boundaries
  - AIRWING vertical-helicopter policy order before AIRWING start
  - observer-client allowance on hard-excluded client terminals
  - accepted G7 static lifecycle and builder guard
  - stable idle-node PASS criteria and accepted result
not_authoritative_for:
  - tactical AUFTRAG dispatch
  - actual vertical takeoff runtime acceptance
  - COMMANDER or OPSTRANSPORT acceptance
  - return, landing, recovery, loss or persistence acceptance
  - merge approval or Ready-for-Review approval
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit: add569fb3231a5563d9c89f865cce7bd764bc0bb
validated_in_dcs: true
acceptance_branch: agent/tarinkot-object-contract-reconciliation
acceptance_commit: add569fb3231a5563d9c89f865cce7bd764bc0bb
acceptance_mission: OMW_Template_v6_Tarinkot.miz
acceptance_mission_sha256: 86ba08f46c78a94cdf6eb54f7abe85145bdabe2817e7a2a89f2cec34932866bb
dcs_version: 2.9.28.26385 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
supersedes:
  - G7 contract that required all Tarinkot client slots to remain unoccupied
  - pre-start acceptance of nonempty squadron.assets
superseded_by: []
---

# Tarinkot G7 – AIRWING/SQUADRON/Payload Foundation Acceptance

## 1. Ergebnis

```yaml
gate: G7_AIRWING_SQUADRON_PAYLOAD_FOUNDATION
classification: PASS_DCS_WITH_TELEMETRY_FIELD_CORRECTION
core_foundation: PASS
observer_client: PASS_NON_BLOCKING
static_lifecycle_guard: PASS_CI
vertical_departure: NOT_TESTED
G8: BLOCKED_BY_CENTRAL_CONSOLIDATION_AND_NEXT_ARTIFACT_GATE
```

Der G7-Grundknoten ist für den dokumentierten Branch-, Commit-, Bundle-, MIZ-, DCS- und MOOSE-Stand akzeptiert. Der korrigierte Builder und der gemeinsame Lifecycle-Guard haben außerdem die statische CI-Prüfung bestanden.

Ergebnisbericht:

```text
../results/2026-08-04-g7-airwing-squadron-payload-foundation-pass.md
```

## 2. Akzeptierte Provenienz

```yaml
branch: agent/tarinkot-object-contract-reconciliation
source_commit: add569fb3231a5563d9c89f865cce7bd764bc0bb
mission: OMW_Template_v6_Tarinkot.miz
mission_sha256: 86ba08f46c78a94cdf6eb54f7abe85145bdabe2817e7a2a89f2cec34932866bb
internal_mission_sha256: babaaee09f38ecbacb0c564b1686e20ee5b18ccf9b8abd920f32952d4a8f54a8
dcs_version: 2.9.28.26385 MT
moose_release: 2.9.18
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
builder: tools/build-tarinkot-air-operations-g7-foundation.ps1
accepted_builder_version: TKOT-G7-AIRWING-FOUNDATION-3
accepted_bundle: mission/tests/tarinkot-air-operations/dist/OMW_AirOps_Tarinkot_G7_Foundation.lua
accepted_bundle_sha256: 7018f4e388a349f91bc4169e6200226a32c001e3c4afdbd4daf69b538de2dea8
dcs_log_sha256: aeacc9fc9270dc033ed49a41eb1b3264880710265386f1d21e0c787a22739e52
debrief_sha256: 8a33b90efdf57f92a95ff2b07d0c016555d79776da3b708367f63ef09a284588
```

Akzeptierte statische Folgekorrrektur:

```yaml
builder_version: TKOT-G7-AIRWING-FOUNDATION-4
lifecycle_guard: tools/Test-AirOpsLifecycleGuards.ps1
ci_workflow: .github/workflows/tarinkot-g7-static-validation.yml
ci_run_id: 30954380156
ci_result: SUCCESS
validated_head: 940330f5213a8da856bca5c456cd38872b747da7
runtime_retest_required: false
```

## 3. Testziel

Der kombinierte Lauf musste den Tarinkot-Grundknoten ohne operativen Auftrag aufbauen und stabil betreiben:

```text
1 AIRWING
3 SQUADRONs
5 registrierte Assetgruppen
7 registrierte KI-Luftfahrzeuge
3 rollenbezogene Payloads
3 automatische RELOCATECOHORT-Payloads
8 akzeptierte HelicopterOnly-ParkingIDs
0 COMMANDER
0 AUFTRAG-Instanzen
0 OPSTRANSPORT
0 deliberate Spawns
```

Familienweise Einzelläufe waren nicht erforderlich, weil der kombinierte Log alle Subsysteme eindeutig auflöste.

## 4. Objektvertrag

### AIRWING

```text
AW_US_TKOT_TF_ATTACK_3_101_AVN
Warehouse: WH_AIR_US_TARINKOT
Airbase: Tarinkot
DCS Airbase ID: 9
Takeoff baseline: Cold
Safe Parking: enabled
Vertical helicopter policy: enabled before AIRWING:Start()
```

### SQUADRONs

```yaml
AH64:
  name: SQ_US_TKOT_AH64D_3_101_AVN
  template: TPL_AIR_US_TKOT_AH64D_CAS_2SHIP
  type: AH-64D_BLK_II
  Ngroups: 2
  grouping: 2
  registered_aircraft: 4
  parking_ids: [21, 4]
  capabilities: [CAS]
UH60:
  name: SQ_US_TKOT_UH60_TF_ATTACK
  template: TPL_AIR_US_TKOT_UH60_MEDEVAC_1SHIP
  type: UH-60A
  Ngroups: 2
  grouping: 1
  registered_aircraft: 2
  parking_ids: [30, 27, 23]
  capabilities: [TROOPTRANSPORT, CARGOTRANSPORT, LANDATCOORDINATE, GROUNDESCORT]
CH47:
  name: SQ_US_TKOT_CH47_B_1_52_AVN
  template: TPL_AIR_US_TKOT_CH47_HEAVYLIFT_1SHIP
  type: CH-47Fbl1
  Ngroups: 1
  grouping: 1
  registered_aircraft: 1
  parking_ids: [32, 29, 10]
  capabilities: [TROOPTRANSPORT, CARGOTRANSPORT, LANDATCOORDINATE]
```

`OPSTRANSPORT` und `FREIGHTTRANSPORT` sind kein Bestandteil von G7.

## 5. Bestandsledger

```text
AH-64: 8 Statics + 2 Clients + 4 registrierte KI = 14
UH-60: 4 Statics + 0 Clients + 2 registrierte KI = 6
CH-47: 0 Statics + 1 Client  + 1 registrierte KI = 2
```

Late-Activation-Templates sind keine zusätzlichen Luftfahrzeuge.

Die zwei AH-64-ParkingIDs tragen eine Two-Ship-Gruppe gleichzeitig. Die zweite registrierte Two-Ship-Gruppe bleibt Warehouse-Reserve, solange keine weiteren akzeptierten Positionen verfügbar sind.

## 6. Parking-Vertrag

Alle acht IDs waren im Lauf:

```text
vorhanden
TerminalType 40 / HelicopterOnly
Free=true
TOAC nicht true
keine Client-TerminalID
untereinander eindeutig
```

Hard Client Exclusions:

```text
TerminalID 3
TerminalID 8
TerminalID 20
```

Akzeptierte Pools:

```yaml
AH64: [21, 4]
UH60: [30, 27, 23]
CH47: [32, 29, 10]
```

Interne Parking-Vererbung wird post-start geprüft. Sie beweist nicht allein die tatsächliche spätere DCS-Spawnposition.

## 7. Verbindlicher MOOSE-Lifecycle

### Pre-Start

Nach `AIRWING:AddSquadron()` werden geprüft:

```text
airwing.cohorts == 3
airwing.stock == 5
squadron.assets == 0/0/0 als erwarteter Deferred-Zustand
Rollen-Payloads == 3
Payloads gesamt == 6
Queues == 0
OPSGROUPs == 0
Safe Parking == true
Vertikaloption == true
Takeoff == cold parking
```

Nicht zulässig ist ein Pre-Start-Fail, weil `squadron.assets` noch nicht `Ngroups` enthält.

### Post-Start

Nach `AIRWING:Start()` und abgeschlossener WAREHOUSE-/LEGION-Initialisierung werden geprüft:

```text
AIRWING Running
squadron.assets == 2/2/1
Warehouse-Stock == 5
SQUADRON.parkingIDs unverändert
Missionqueue == 0
Transportqueue == 0
Requestqueue == 0
OPSGROUPs == 0
```

Der akzeptierte Lauf erfüllte sämtliche Werte.

## 8. Vertikaloption

Verbindliche Reihenfolge:

```lua
airwing:SetOptionPreferVerticalLanding()
airwing:Start()
```

G7 akzeptiert nur:

```text
Option vor Start gesetzt
AIRWING stabil Running
kein spontaner Spawn
```

Nicht durch G7 akzeptiert:

```text
Weitergabe an eine reale Tarinkot-FLIGHTGROUP
tatsächliches vertikales Abheben
Vermeidung von Taxi oder Runway
```

Dies gehört in den isolierten nativen G8-AIRWING-/AUFTRAG-Dispatch.

## 9. Observer-Client

Ein Beobachter-Client ist zulässig, wenn seine TerminalID hart aus allen KI-Pools ausgeschlossen ist und der Foundation-Test keine Flugbewegung erzeugt.

Der akzeptierte Lauf enthielt:

```text
Clientunit: CLIENT_US_TKOT_AH64D_01_UNIT_01
TerminalID: 20
Player: Neues Rufz.
observerClientsDetected: 1
observerClientsAllowed: 1
observerClientsBlocking: 0
```

Das alte Endmarkerfeld `activePlayerClients=0` ist verworfen. Es entstand durch eine nachträgliche Maskierung des bereits erkannten Clients. Künftige Bundles behalten den tatsächlichen Detektionswert und protokollieren:

```text
observerClientsDetected
observerClientsAllowed
observerClientsBlocking
observerClientUnits
```

## 10. Verbotene Inhalte

Das G7-Bundle enthält keine:

```text
COMMANDER:New
AUFTRAG-Konstruktoren
OPSTRANSPORT:New
SPAWN
FLIGHTGROUP:New
SetAIOn
StartUncontrolled
Despawn
Destroy
coalition.addGroup
synthetische Testzone
CampaignState-Mutation
AIRWING:AddMission
```

## 11. Akzeptierter Finalzustand

```text
status=PASS
reason=none
violations=0
airwingRunning=true
squadrons=3
registeredGroups=5
registeredAircraft=7
stock=5
rolePayloads=3
totalPayloads=6
parkingPools=3
parkingIDs=8
missionQueue=0
transportQueue=0
requestQueue=0
opsGroups=0
safeParking=true
verticalPolicy=true
takeoffCold=true
observerClientsDetected=1
observerClientsAllowed=1
observerClientsBlocking=0
commanderCreated=0
auftragCreated=0
opsTransportCreated=0
deliberateSpawns=0
```

Die drei Observer-Felder sind die korrigierte semantische Darstellung der Rohmarker; der akzeptierte Builder v3 gab im letzten Resultat nur das maskierte Altfeld aus.

## 12. Akzeptierter statischer Guard

Builder-Version 4 führt den gemeinsamen Guard aus:

```powershell
./tools/Test-AirOpsLifecycleGuards.ps1 `
  -SourceFile <transformed-source> `
  -GeneratedFile <bundle> `
  -RequirePostStartAssetValidation `
  -RequireVerticalPolicyBeforeStart `
  -FoundationScope
```

Der GitHub-Actions-Lauf `30954380156` bestand auf Head `940330f5213a8da856bca5c456cd38872b747da7`.

Der Guard blockiert:

- positive Pre-Start-Sollprüfung von `squadron.assets`;
- Pre-Start-Prüfung geerbter Asset-ParkingIDs;
- Vertikaloption nach `AIRWING:Start()`;
- Observer-Zählwertmaskierung;
- COMMANDER-, AUFTRAG-, OPSTRANSPORT- oder SPAWN-Pfade im Foundation-Gate.

## 13. Gate-Wirkung

```yaml
G7_airwing_squadron_payload: PASS_DCS_WITH_TELEMETRY_FIELD_CORRECTION
G7_static_lifecycle_guard: PASS_CI
G8_direct_dispatch_vertical_departure: BLOCKED
g8_blockers:
  - central lifecycle consolidation remains Draft PR 55 and is not on main
  - next MIZ and embedded bundle identity are not yet established
G9_commander: BLOCKED_BY_G8
G10_lifecycle: NOT_STARTED
```

Ein erneuter langer G7-DCS-Lauf ist nicht erforderlich. Der nächste DCS-Lauf ist erst nach Abschluss der zentralen Konsolidierung der isolierte G8-Dispatch.
