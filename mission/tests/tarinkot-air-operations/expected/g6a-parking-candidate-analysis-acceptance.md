---
document_id: OMW-TEST-TKOT-G6A-PARKING-CANDIDATE-ACCEPTANCE
status: PLANNED
document_class: TEST_ACCEPTANCE_SPECIFICATION
owning_policy: OMW-GOV-001
authoritative_for:
  - Tarinkot G6A read-only parking candidate analysis
  - MOOSE-derived geometric exclusion method for Tarinkot helicopter parking
  - evidence required before any controlled G6B spawn test
not_authoritative_for:
  - final SQUADRON or WAREHOUSE parking ID lists
  - operational spawn compliance
  - post-landing parking behavior
  - AIRWING, SQUADRON, AUFTRAG, COMMANDER or OPSTRANSPORT acceptance
  - merge approval or Ready-for-Review approval
scenario_period: 2010-08-01/2011-12-31
project_phase: TARINKOT_G6_PARKING_CALIBRATION
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
supersedes: []
superseded_by: []
---

# Tarinkot G6A – Parking Candidate Analysis Acceptance

## 1. Testziel

G6A ermittelt ohne Spawn und ohne Parking-Mutation, welche Tarinkot-TerminalIDs nach der in MOOSE 2.9.18 verwendeten Kollisionslogik als Kandidaten für AH-64D, UH-60A und CH-47Fbl1 übrig bleiben.

G6A ist bewusst von G6B getrennt:

```text
G6A: read-only Kandidatenermittlung
G6B: kontrollierte Einzel- und Mehrfach-Spawnversuche
```

Ein G6A-PASS autorisiert ausschließlich die Planung von G6B. Er akzeptiert keine produktive Parking-Liste.

## 2. Ausgangsdaten aus G5

Der erfolgreiche G5-Retest bestätigte:

```yaml
airbase: Tarinkot
airbase_id: 9
runtime_parking_nodes: 33
client_reserved_terminal_ids:
  - 3
  - 8
  - 20
statics_found: 12
warehouse_wrappers: 1
zones_present: 1
zones_missing: 10
```

Bekannte Client-Zuordnung:

```text
TerminalID 20 -> CLIENT_US_TKOT_AH64D_01 / ME C01-H
TerminalID  8 -> CLIENT_US_TKOT_AH64D_02 / ME C05-H
TerminalID  3 -> CLIENT_US_TKOT_CH47F_01 / ME C07-H
```

## 3. MOOSE-first Methode

G6A verwendet aus der exakt eingebetteten MOOSE-Version 2.9.18:

```text
AIRBASE:GetParkingSpotsTable()
AIRBASE.TerminalType.HelicopterUsable
AIRBASE._CheckTerminalType()
COORDINATE:ScanObjects()
POSITIONABLE:GetBoundingRadius()
POSITIONABLE:GetObjectSize()
```

Die Sicherheitsdistanz entspricht exakt der internen Berechnung von `AIRBASE:FindFreeParkingSpotForAircraft()`:

```text
safeDistance = (aircraftRadius + obstacleRadius) * 1.1
```

Der Scanradius beträgt wie im MOOSE-Standardpfad 50 Meter. Units und Statics werden geprüft; Scenery wird in G6A nicht geprüft, weil der native MOOSE-Standardpfad `scanscenery=false` verwendet.

## 4. Modellreferenzen

G6A versucht die Modellgröße in dieser Reihenfolge zu ermitteln:

1. Unit des vorhandenen Late-Activation-Templates;
2. vorhandene Client-Unit;
3. vorhandenes Static derselben Musterfamilie.

Verbindliche Referenzen:

```yaml
AH64:
  template: TPL_AIR_US_TKOT_AH64D_CAS_2SHIP
  client_unit: CLIENT_US_TKOT_AH64D_02_UNIT_01
  static: STATIC_AIR_US_TKOT_AH64_01

UH60:
  template: TPL_AIR_US_TKOT_UH60_MEDEVAC_1SHIP
  static: STATIC_AIR_US_TKOT_UH60_UTILITY_01

CH47:
  template: TPL_AIR_US_TKOT_CH47_HEAVYLIFT_1SHIP
  client_unit: CLIENT_US_TKOT_CH47F_01_UNIT_01
```

Fehlt für eine Familie zur Laufzeit ein Bounding-Radius, ist das Ergebnis `PARTIAL`; die Größe darf nicht durch einen erfundenen Zahlenwert ersetzt werden.

## 5. Read-only-Sperre

G6A darf nicht:

```text
AIRWING oder SQUADRON erzeugen
Payloads registrieren
Parking-IDs setzen
Airbase-White- oder Blacklists verändern
SafeParking umschalten
Client-Parking freigeben
Gruppen aktivieren oder spawnen
Missionen oder Transporte erzeugen
F10-Marker anlegen
CampaignState oder MIZ verändern
```

Der Builder prüft den Quelltext gegen 18 verbotene Muster.

## 6. Testumgebung

Der Test muss ohne besetzten Tarinkot-Client laufen. Ein aktiver Spieler in einem der drei Tarinkot-Clients verändert die Hindernislage und führt zu:

```text
status=INVALID_ACTIVE_PLAYER_CLIENT
```

Die Mission mindestens 25 Sekunden laufen lassen. Keine Tarinkot-Gruppen, Statics, Parking-Werte, Warehouse-Einstellungen oder Zonen ändern.

## 7. Erwartete Loggruppen

```text
BEGIN Tarinkot G6A parking candidate analysis
BUILD ... version=TKOT-G6A-PARKING-ANALYSIS-1 ...
READ_ONLY_LOCK ... PARKING_ASSIGNMENT=0 ...
MOOSE_PARKING_FORMULA safeDistance=(aircraftRadius+obstacleRadius)*1.1 scanRadiusM=50
AIRBASE name=Tarinkot id=9 parkingCount=33 expectedParkingCount=33
```

Pro Musterfamilie muss ein `MODEL`- oder `MODEL_UNAVAILABLE`-Datensatz erscheinen.

Pro Terminal erscheinen:

```text
SPOT ...
FAMILY_SPOT family=AH64 ...
FAMILY_SPOT family=UH60 ...
FAMILY_SPOT family=CH47 ...
```

Zusammenfassungen:

```text
CANDIDATES family=AH64 ids=...
CANDIDATES family=UH60 ids=...
CANDIDATES family=CH47 ids=...
FAMILY_SUMMARY ...
```

Für AH-64 und UH-60 werden zusätzlich kollisionsfreie Zweierkombinationen als `PAIR` protokolliert, weil der Objektvertrag jeweils zwei gleichzeitig registrierte bzw. aktive KI-Luftfahrzeuge vorsieht.

## 8. Ergebnisstatus

### PASS_DATASET

```text
RESULT G6A_PARKING_CANDIDATE_ANALYSIS status=PASS_DATASET
```

Voraussetzungen:

- 33 Parking-Datensätze;
- kein aktiver Spielerclient;
- Modellradius für alle drei Familien verfügbar;
- mindestens ein geeigneter Einzelplatz für CH-47;
- mindestens eine geeignete Zweierkombination für AH-64;
- mindestens eine geeignete Zweierkombination für UH-60;
- keine Parking- oder Spawn-Mutation.

### PARTIAL

`PARTIAL` ist zulässig, wenn mindestens ein Modellradius nicht verfügbar ist oder noch keine vollständige Kandidatenkombination vorliegt. Es autorisiert keine finale Parking-Liste.

### FAIL oder INVALID

Der Lauf ist nicht verwertbar bei:

- Airbase-ID 9 nicht auflösbar;
- Parking-Anzahl ungleich 33;
- Lua-/Schedulerfehler aus G6A;
- aktiv besetztem Tarinkot-Client;
- nachgewiesener Parking-, Spawn- oder CampaignState-Mutation.

## 9. Abnahmegrenze und G6B

G6A klassifiziert lediglich Kandidaten nach der MOOSE-Kollisionslogik. Nicht bewiesen sind:

```text
DCS-Spawn auf exakt dem angeforderten Terminal
korrekte Platzierung einer AH-64-Zweiergruppe
korrekte parallele Platzierung zweier UH-60-Einzelgruppen
CH-47-Rotor- und Rollfreiheit im sichtbaren 3D-Modell
Cold-Start- und Taxi-Verhalten
Rückkehr- oder Endparkverhalten
```

Diese Punkte werden in separaten G6B-Läufen je Musterfamilie geprüft. Erst danach dürfen positive `SQUADRON:SetParkingIDs()`-Listen in G7 erwogen werden.

## 10. Dateien

```text
mission/tests/tarinkot-air-operations/src/02-tarinkot-g6a-parking-candidate-analysis.lua
mission/tests/tarinkot-air-operations/dist/OMW_AirOps_Tarinkot_G6A_ParkingAnalysis.lua
tools/build-tarinkot-air-operations-g6a-parking-analysis.ps1
```
