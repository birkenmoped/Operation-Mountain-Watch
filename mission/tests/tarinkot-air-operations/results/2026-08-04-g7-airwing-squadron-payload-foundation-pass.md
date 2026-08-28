---
document_id: OMW-TEST-TKOT-G7-FOUNDATION-PASS-2026-08-04
status: ACCEPTED_TECHNICAL_BASELINE
document_class: DCS_ACCEPTANCE_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - Tarinkot G7 AIRWING, SQUADRON and payload foundation result
  - pre-start Warehouse stock and post-start SQUADRON asset lifecycle evidence
  - classification of the observer-client telemetry defect
  - accepted static correction and lifecycle guard result
  - gate state before Tarinkot G8
not_authoritative_for:
  - actual vertical departure
  - tactical AUFTRAG execution
  - COMMANDER, OPSTRANSPORT, return, recovery or persistence
  - merge or Ready-for-Review authorization
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
supersedes: []
superseded_by: []
---

# Tarinkot G7 AIRWING/SQUADRON/Payload Foundation – PASS

## 1. Klassifikation

```yaml
gate: G7_AIRWING_SQUADRON_PAYLOAD_FOUNDATION
classification: PASS_DCS_WITH_TELEMETRY_FIELD_CORRECTION
core_foundation: PASS
observer_policy: PASS_NON_BLOCKING
final_activePlayerClients_field: INVALIDATED
static_lifecycle_guard: PASS_CI
vertical_departure: NOT_TESTED
G8: BLOCKED_BY_CENTRAL_CONSOLIDATION_AND_NEXT_ARTIFACT_GATE
```

Der G7-Grundknoten ist technisch bestanden. Ein einzelnes Endmarkerfeld meldete `activePlayerClients=0`, obwohl derselbe Lauf zuvor einen aktiven Beobachter-Client erkannt hatte. Der Harness hatte den Rückgabewert nach der Detektion auf null maskiert. Dieses einzelne Feld wird verworfen; der G7-Kernnachweis bleibt gültig.

Der korrigierte Builder und der gemeinsame Lifecycle-Guard wurden anschließend ohne erneuten DCS-Lauf statisch validiert.

## 2. Provenienz

```text
Branch: agent/tarinkot-object-contract-reconciliation
Source commit: add569fb3231a5563d9c89f865cce7bd764bc0bb
Builder: tools/build-tarinkot-air-operations-g7-foundation.ps1
BuilderVersion: TKOT-G7-AIRWING-FOUNDATION-3
Bundle: mission/tests/tarinkot-air-operations/dist/OMW_AirOps_Tarinkot_G7_Foundation.lua
Bundle SHA-256: 7018f4e388a349f91bc4169e6200226a32c001e3c4afdbd4daf69b538de2dea8
Mission: OMW_Template_v6_Tarinkot.miz
Supplied MIZ SHA-256: 86ba08f46c78a94cdf6eb54f7abe85145bdabe2817e7a2a89f2cec34932866bb
Internal mission SHA-256: babaaee09f38ecbacb0c564b1686e20ee5b18ccf9b8abd920f32952d4a8f54a8
DCS version: 2.9.28.26385 MT
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Embedded Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
DCS log SHA-256: aeacc9fc9270dc033ed49a41eb1b3264880710265386f1d21e0c787a22739e52
Debrief SHA-256: 8a33b90efdf57f92a95ff2b07d0c016555d79776da3b708367f63ef09a284588
Accepted runtime window: 2026-08-04 21:25:52 through 21:26:07 local DCS log time
```

Das Gesamtdokument `dcs.log` enthält einen früheren fehlgeschlagenen G7-Versuch. Für diesen Bericht ist ausschließlich das oben genannte finale Laufzeitfenster maßgeblich.

## 3. Objektvertragssmoke

Bestätigt:

```text
AIRBASE Tarinkot / ID 9
33 Parkingrecords
Warehouse WH_AIR_US_TARINKOT
12/12 Luftfahrzeug-Statics
STATIC_AIR_US_TKOT_AH64_07 vorhanden und AH-64D_BLK_II
3 SQUADRON-Parkingpools
8/8 akzeptierte HelicopterOnly-TerminalIDs
Client-TerminalIDs 3, 8 und 20 nicht in den KI-Pools
```

## 4. Pre-Start-Lifecycle

Bestätigt vor `AIRWING:Start()`:

```text
SQUADRONs: 3
Warehouse-Stock nach AH-64: 2
Warehouse-Stock nach UH-60: 4
Warehouse-Stock nach CH-47: 5
squadron.assets vor Start: 0/0/0
Cohorts: 3
registrierte Assetgruppen: 5
registrierte Luftfahrzeuge: 7
Rollen-Payloads: 3
automatische RELOCATECOHORT-Payloads: 3
Payloads gesamt: 6
Missionqueue: 0
Transportqueue: 0
Requestqueue: 0
OPSGROUPs: 0
Safe Parking: true
Vertikaloption vor Start: true
Takeoff: cold parking
```

Der Wert `squadron.assets=0` vor Start ist der korrekte Deferred-Zustand. Die Assetgruppen waren zu diesem Zeitpunkt bereits im Warehouse-Stock registriert.

## 5. Post-Start-Lifecycle

Nach AIRWING-Start und verzögerter Idle-Prüfung:

```text
AIRWING state: Running
Warehouse stock: 5
AH-64 SQUADRON assets: 2 / erwartet 2
UH-60 SQUADRON assets: 2 / erwartet 2
CH-47 SQUADRON assets: 1 / erwartet 1
Missionqueue: 0
Transportqueue: 0
Requestqueue: 0
OPSGROUPs: 0
spontane Missionen: 0
spontane Spawns: 0
```

Damit ist die Lifecycle-Grenze praktisch bestätigt:

```text
AIRWING:AddSquadron()
  -> Warehouse-Stock registriert

AIRWING:Start() plus Initialisierung
  -> Warehouse-Assets an SQUADRON/COHORT gebunden
  -> squadron.assets post-start 2/2/1
```

## 6. Observer-Client

Rohmarker:

```text
ACTIVE_PLAYER_CLIENT unit=CLIENT_US_TKOT_AH64D_01_UNIT_01 player=Neues Rufz.
ACTIVE_PLAYER_CLIENT_COUNT=1
ACTIVE_PLAYER_CLIENT_POLICY detected=1 disposition=ALLOWED_HARD_EXCLUDED_CLIENT_TERMINAL blocking=0
```

Korrekte Bewertung:

```yaml
observerClientsDetected: 1
observerClientsAllowed: 1
observerClientsBlocking: 0
observerClientTerminalID: 20
observerClientRole: visual observation
```

Ungültiges Endmarkerfeld:

```text
activePlayerClients=0
```

Ursache war eine Builder-Footer-Überschreibung der Detektionsfunktion. Diese gab nach korrekter Protokollierung des Clients `0` zurück. Künftige Bundles dürfen den Detektionswert nicht verändern und müssen `detected`, `allowed` und `blocking` getrennt ausgeben.

## 7. Finalmarker

Der Kernmarker lautete:

```text
RESULT G7_AIRWING_SQUADRON_PAYLOAD_FOUNDATION
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
commanderCreated=0
auftragCreated=0
opsTransportCreated=0
deliberateSpawns=0
```

Nur das Feld `activePlayerClients=0` ist verworfen. Alle übrigen Werte stimmen mit den vorhergehenden Einzelmarkern überein.

Semantisch korrigierter Observer-Anteil:

```text
observerClientsDetected=1
observerClientsAllowed=1
observerClientsBlocking=0
```

## 8. Debrief

```text
graveyard = {}
```

Der Debrief zeigt den Beobachter im Client `CLIENT_US_TKOT_AH64D_01_UNIT_01`, Missionsstart/-ende und Optionsereignisse. Es gibt keinen Tarinkot-G7-Verlustnachweis.

## 9. Nicht testrelevanter Fehler

Nach dem abgeschlossenen G7-Lauf trat beim Verlassen der Mission ein Fehler in einem lokalen DCS-Hook auf:

```text
Saved Games\DCS.openbeta\Scripts\Hooks\bhHook.lua
attempt to index upvalue 'tcp' (a nil value)
```

Der Fehler stammt nicht aus dem G7-Bundle oder MOOSE-Missionsskript und trat mehrere Minuten nach dem finalen PASS-Marker auf. Er invalidiert den G7-Grundknoten nicht, bleibt aber ein separater lokaler Hook-Befund.

## 10. Nachweisgrenze

Nicht belegt:

```text
nativer AIRWING-/AUFTRAG-Dispatch
Weitergabe der Vertikaloption an eine reale Tarinkot-FLIGHTGROUP
tatsächlicher vertikaler Start
kein Taxi- oder Runway-Verhalten
Taktik, Zielbekämpfung oder Missionsabschluss
Rückkehr, Landung, Recovery oder Verlustbuchung
COMMANDER
OPSTRANSPORT
```

## 11. Statische Korrektur

Implementiert:

```text
BuilderVersion: TKOT-G7-AIRWING-FOUNDATION-4
Shared guard: tools/Test-AirOpsLifecycleGuards.ps1
CI workflow: .github/workflows/tarinkot-g7-static-validation.yml
```

Der korrigierte Builder:

- prüft Warehouse-Stock vor `AIRWING:Start()`;
- prüft `squadron.assets` und Parking-Vererbung nach Start;
- behält tatsächliche Observerwerte bei;
- trennt detected, allowed und blocking;
- setzt die Vertikaloption vor AIRWING-Start;
- verbietet COMMANDER, AUFTRAG-Instanzen, OPSTRANSPORT und SPAWN im G7-Scope.

Statischer Nachweis:

```text
Workflow: Tarinkot G7 static validation
Run ID: 30954380156
Result: SUCCESS
Validated head: 940330f5213a8da856bca5c456cd38872b747da7
```

Damit ist der Tarinkot-spezifische statische Guard bestanden. Ein erneuter langer G7-DCS-Lauf ist nicht erforderlich.

## 12. Zentraler Konsolidierungsstand und nächster Schritt

Draft PR #55 enthält die vorgeschlagene main-weite Konsolidierung:

1. Lifecycle-Matrix;
2. Pre-/Post-Start-Regeln;
3. MIZ-Invalidierungsregel;
4. Observer-Client-Policy;
5. zentrales Methodenregister;
6. kanonisches Dokument 22;
7. `mission/tests/GOVERNANCE.md`;
8. gemeinsamen Builder-Guard;
9. Projektregister- und MOOSE-Index-Synchronisierung;
10. Sperre weiterer langer DCS-Läufe vor dem statischen PASS.

G8 bleibt blockiert, bis diese zentrale Baseline ausdrücklich für `main` freigegeben und integriert wurde und die nächste MIZ-/Bundle-Hashkette feststeht. Für die aktuelle Konsolidierung ist kein weiterer DCS-Lauf erforderlich.
