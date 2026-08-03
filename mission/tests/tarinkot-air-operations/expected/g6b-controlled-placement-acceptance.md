---
document_id: OMW-TEST-TKOT-G6B-CONTROLLED-PLACEMENT-ACCEPTANCE
status: PLANNED
document_class: TEST_ACCEPTANCE_SPECIFICATION
owning_policy: OMW-GOV-001
authoritative_for:
  - Tarinkot G6B isolated per-family spawn and initial placement tests
  - exact TerminalID probe sets derived from the accepted G6A dataset
  - acceptance criteria for MOOSE SPAWN:SpawnAtParkingSpot placement
not_authoritative_for:
  - final SQUADRON, AIRWING or WAREHOUSE parking allowlists
  - engine start, taxi, takeoff, mission, return, landing or recovery acceptance
  - AIRWING, SQUADRON, payload, AUFTRAG, COMMANDER or OPSTRANSPORT acceptance
  - merge approval or Ready-for-Review approval
scenario_period: 2010-08-01/2011-12-31
project_phase: TARINKOT_G6_PARKING_CALIBRATION
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
supersedes: []
superseded_by: []
---

# Tarinkot G6B – Controlled Placement Acceptance

## 1. Testziel

G6B prüft getrennt für AH-64, UH-60 und CH-47, ob DCS die aus G6A abgeleiteten internen MOOSE-TerminalIDs tatsächlich für den angeforderten Cold-Spawn verwendet und ob die erzeugten Luftfahrzeuge eindeutig den geforderten Parking-Datensätzen zugeordnet werden können.

G6B ist kein operativer AIRWING-Test. Es werden keine AIRWING-, SQUADRON-, Payload-, AUFTRAG-, COMMANDER- oder OPSTRANSPORT-Objekte erzeugt.

## 2. MOOSE-first Quellgrundlage

Geprüfter Quellstand:

```yaml
repository: FlightControl-Master/MOOSE
commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
release: 2.9.18
file: Moose Development/Moose/Core/Spawn.lua
```

Verwendeter API-Pfad:

```lua
SPAWN:NewWithAlias(TemplateGroupName, Alias)
SPAWN:InitAIOff()
SPAWN:SpawnAtParkingSpot(Airbase, TerminalIDs, SPAWN.Takeoff.Cold)
```

`SpawnAtParkingSpot()` erwartet ausdrücklich interne Parking-Spot-IDs, nicht Mission-Editor-Labels. Die Methode löst die Parking-Datensätze auf, akzeptiert nur freie Datensätze und reicht die exakten Datensätze an `SpawnAtAirbase()` weiter.

`InitAIOff()` ist absichtlich gesetzt. G6B prüft ausschließlich Spawn und anfängliche Platzierung. Engine Start, Taxi und Takeoff werden dadurch nicht vorweggenommen.

## 3. Testvarianten

Der Builder erzeugt drei getrennte Bundles:

```text
OMW_AirOps_Tarinkot_G6B_AH64_Placement.lua
OMW_AirOps_Tarinkot_G6B_UH60_Placement.lua
OMW_AirOps_Tarinkot_G6B_CH47_Placement.lua
```

Jede Mission enthält genau eines dieser Bundles.

### 3.1 AH-64

```yaml
family: AH64
template: TPL_AIR_US_TKOT_AH64D_CAS_2SHIP
dcs_type: AH-64D_BLK_II
spawn_requests:
  - terminal_ids: [0, 25]
    expected_groups: 1
    expected_units: 2
model_radius_m: 9.967
```

G6A-Abstand:

```text
31.679 m; erforderliche geometrische Mindestdistanz 21.928 m
```

### 3.2 UH-60

```yaml
family: UH60
template: TPL_AIR_US_TKOT_UH60_MEDEVAC_1SHIP
dcs_type: UH-60A
spawn_requests:
  - terminal_ids: [13]
    expected_groups: 1
    expected_units: 1
  - terminal_ids: [22]
    expected_groups: 1
    expected_units: 1
model_radius_m: 10.020
```

Die beiden One-Ships werden als zwei unabhängige Gruppen erzeugt. Der Abstand der Terminalzentren beträgt `31.548 m`; die geometrische Mindestdistanz aus G6A beträgt `22.045 m`.

### 3.3 CH-47

```yaml
family: CH47
template: TPL_AIR_US_TKOT_CH47_HEAVYLIFT_1SHIP
dcs_type: CH-47Fbl1
spawn_requests:
  - terminal_ids: [14]
    expected_groups: 1
    expected_units: 1
model_radius_m: 7.910
```

Terminal `14` hatte im G6A-Scan keine Unit- oder Static-Hindernisse innerhalb von 50 Metern. Terminal `29` bleibt wegen der geringen geometrischen Reserve und der nicht vollständig repräsentierten Rotorfläche ausgeschlossen.

## 4. Voraussetzungen

Vor jedem einzelnen Lauf:

```text
keinen Tarinkot-Client besetzen
nur ein G6B-Familienbundle einbinden
G5- und G6A-Bundle nicht zusätzlich ausführen
keine Tarinkot-Statics, Clients, Seeds, Zonen oder Warehouse-Werte verändern
Mission als separate Testkopie speichern
```

Empfohlene Dateinamen:

```text
OMW_Template_v5_Salerno_TKOT_G6B_AH64.miz
OMW_Template_v5_Salerno_TKOT_G6B_UH60.miz
OMW_Template_v5_Salerno_TKOT_G6B_CH47.miz
```

Die Mission mindestens 35 Sekunden laufen lassen.

## 5. Sicherheitsgrenze

G6B darf nicht:

```text
AIRWING oder SQUADRON erzeugen
Payloads registrieren
SetParkingIDs verwenden
Airbase-White- oder Blacklists verändern
SafeParking umschalten
Client-Parking freigeben
AUFTRAG, COMMANDER oder OPSTRANSPORT erzeugen
F10-Marker anlegen
CampaignState oder MIZ verändern
zufällige Spawnpositionen oder zufällige Templates verwenden
SpawnAtAirbase direkt aufrufen
```

Der einzige zulässige Spawnpfad ist:

```lua
SPAWN:SpawnAtParkingSpot(..., SPAWN.Takeoff.Cold)
```

## 6. Runtime-Prüfung

Der Test prüft vor dem Spawn:

- Airbase-ID `9` ist eindeutig Tarinkot;
- genau `33` Parking-Datensätze sind vorhanden;
- kein Tarinkot-Client ist aktiv;
- jede angeforderte TerminalID existiert;
- jede angeforderte TerminalID ist `Free=true` und `TOAC=false`;
- keine angeforderte TerminalID ist `3`, `8` oder `20`.

Nach dem Spawn wird je erzeugter Unit protokolliert:

```text
Familie
Gruppe
Unitname
DCS-Typ
Lebensstatus
nächstgelegene angeforderte TerminalID
Abstand zum Terminalzentrum
```

Die Zuordnung muss innerhalb des aus G6A stammenden Modellradius liegen und innerhalb eines Spawn-Requests eindeutig sein.

## 7. Erwartete Loggruppen

```text
BEGIN Tarinkot G6B controlled placement
BUILD ... version=TKOT-G6B-CONTROLLED-PLACEMENT-1 ...
CONFIG family=...
MUTATION_LOCK AIRWING=0 SQUADRON=0 PAYLOAD=0 AUFTRAG=0 COMMANDER=0 OPSTRANSPORT=0 PARKING_LIST_MUTATION=0 CAMPAIGNSTATE_MUTATION=0 MIZ_MUTATION=0
ACTIVE_PLAYER_CLIENT_COUNT=0
AIRBASE name=Tarinkot id=9 parkingCount=33 expectedParkingCount=33
REQUEST ...
SPAWNED ...
UNIT_PLACEMENT ...
RESULT G6B_<FAMILY>_CONTROLLED_PLACEMENT status=...
```

## 8. PASS-Kriterien

Ein Lauf erhält `PASS_RUNTIME_PLACEMENT`, wenn:

- alle Vorprüfungen bestanden sind;
- alle erwarteten Gruppen erzeugt wurden;
- alle erwarteten Units vorhanden und lebend sind;
- alle Units den erwarteten DCS-Typ besitzen;
- jede angeforderte TerminalID genau einer Unit des jeweiligen Spawn-Requests zugeordnet wird;
- der Mittelpunktabstand jeder Unit zum zugeordneten Terminalzentrum höchstens dem G6A-Modellradius entspricht;
- keine zusätzliche Tarinkot-Gruppe durch das Testbundle erzeugt wird.

## 9. INVALID- und FAIL-Kriterien

```yaml
INVALID_ACTIVE_PLAYER_CLIENT:
  condition: mindestens ein Tarinkot-Client ist besetzt

FAIL_PREFLIGHT:
  condition: Airbase, Parking-Anzahl oder angeforderter Parking-Datensatz weicht ab

FAIL_SPAWN:
  condition: SpawnAtParkingSpot liefert nil oder eine erwartete Gruppe/Unit fehlt

FAIL_PLACEMENT:
  condition: Typ, eindeutige Terminalzuordnung oder Mittelpunktabstand ist falsch
```

## 10. Visuelle Pflichtprüfung

Auch bei `PASS_RUNTIME_PLACEMENT` muss der Tester je Variante visuell bestätigen:

```text
keine Modellüberschneidung
kein Rotor-/Mast-/Rumpfkontakt mit Statics oder Terrain
keine Unit steht außerhalb der vorgesehenen befestigten Fläche
CH-47-Rotorfläche wirkt frei
```

Die visuelle Prüfung ist insbesondere beim CH-47 zwingend, weil der DCS-Bounding-Radius die vollständige Rotorfläche nicht abbildet.

## 11. Abnahmegrenze

Ein vollständiger G6B-PASS akzeptiert nur die geprüften Probe-Sets für den nächsten technischen Schritt. Er trägt die IDs noch nicht automatisch als produktive SQUADRON-Parking-Listen ein.

Weiterhin offen bleiben:

```text
Engine Start
Taxi und Takeoff
operative AIRWING-/SQUADRON-Zuweisung
Parallelbetrieb mit Clients
Rückkehr, Landung und Endparken
Lifecycle und Inventory-Buchung
```
