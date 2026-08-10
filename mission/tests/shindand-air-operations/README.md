---
document_id: OMW-TEST-SHINDAND-HELIPORT-PARKING-MAP
status: PLANNED
document_class: MISSION_RUNTIME_TEST
owning_policy: OMW-GOV-001
authoritative_for:
  - planned read-only mapping of Shindand Heliport Mission Editor parking labels to MOOSE TerminalIDs
not_authoritative_for:
  - active Shindand ORBAT
  - final Shindand parking pool
  - AIRWING/SQUADRON acceptance
  - DCS runtime acceptance before an executed and documented test
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/shindand-heliport-parking-diagnostic
source_commit: PENDING_MERGE
validated_in_dcs: false
supersedes: []
superseded_by: []
---

# Shindand Heliport – ME-Parking zu MOOSE-TerminalID

## 1. Zweck

Dieser Test bildet die im Mission Editor sichtbaren Parkplatzbezeichnungen des **Shindand Heliport** auf die von MOOSE/DCS verwendeten Parking-Datensätze ab.

Der Test ist ausschließlich read-only. Er erzeugt keine AIRWING-, SQUADRON-, AUFTRAG- oder COMMANDER-Instanzen, aktiviert keine Gruppen, erzeugt keine Spawns und verändert keine Parking-Konfiguration.

Ziel ist insbesondere die Auflösung der bekannten Mission-Editor-Diskrepanz, dass der sichtbare Parkplatz `34` zweimal angeboten wird. Der Projektinhaber hat den zweiten Eintrag ausschließlich für die Diagnose als `34a` benannt.

## 2. Aktueller MIZ-Arbeitsstand

Vom Projektinhaber bereitgestellte Arbeitsdatei:

```text
OMW_Template_v7_Shindand(1).miz
SHA-256: c8f646b58a66c57cb15225dc1282e3c6e30f746c0717592d8da29a11ca7ac610
```

In dieser MIZ sind 45 Late-Activation-Single-Ship-Gruppen nach folgendem Schema gesetzt:

```text
DIAG_SHND_HP_ME_<ME-Parkplatzbezeichnung>
```

Der doppelte sichtbare ME-Eintrag `34` ist vertreten als:

```text
DIAG_SHND_HP_ME_34
DIAG_SHND_HP_ME_34a
```

`34a` ist ausschließlich ein OMW-Diagnosealias und niemals als DCS- oder MOOSE-Parking-ID zu interpretieren.

Der AIROPS-Warehouse-Anker wurde auf den eindeutigen Namen geändert:

```text
WH_AIR_US_SHINDAND_HELIPORT
```

## 3. Fachliche Scope-Grenze

Für den aktuellen AIROPS-Foundation-Schritt gilt:

```text
Shindand Airfield
-> Afghan Air Force / USAF Air Advisor / Training
-> außerhalb dieses AIROPS-Parking-Tests

Shindand Heliport
-> TF Spearhead / 3-227 Assault Aviation
-> operative OMW-Rotary-Wing-Domain
-> logischer OMW-Bestand: 8 AH-64D / 8 UH-60 / 4 CH-47
```

Die Bestandsentscheidung ist nicht Gegenstand dieses Tests. Der Test untersucht nur die DCS-/MOOSE-Parking-Topologie.

## 4. MOOSE-First-Prüfung

Gepinnter MOOSE-Stand:

```yaml
release: 2.9.18
commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Im tatsächlich verwendeten `Moose.lua` sind bestätigt:

```lua
AIRBASE.Afghanistan.Shindand_Heliport
AIRBASE:FindByName(AirbaseName)
AIRBASE:GetParkingSpotsTable(termtype)
COORDINATE:NewFromVec2(Vec2, LandHeightAdd)
COORDINATE:GetClosestParkingSpot(airbase, terminaltype, free)
SCHEDULER:New(...)
```

`AIRBASE:GetParkingSpotsTable()` liefert im gepinnten Stand unter anderem:

```text
Coordinate
TerminalID
TerminalType
TOAC
Free
TerminalID0
DistToRwy
```

`COORDINATE:GetClosestParkingSpot()` liefert die nächste Parking-Koordinate, `TerminalID`, Abstand und den vollständigen ParkingSpot-Datensatz zurück.

Die offiziellen MOOSE-Missionsrepositories wurden auf einen unmittelbar passenden Parking-Label-Mapping-Demoeinsatz geprüft; ein gleichartiger Demonstrator wurde nicht gefunden. OMW besitzt jedoch auf `main` bereits den read-only Tarinkot-G6A2-Mappingtest als projektspezifisches Vorbild. Die Shindand-Version verwendet zusätzlich die vorhandene öffentliche MOOSE-Methode `COORDINATE:GetClosestParkingSpot()` für die eigentliche Zuordnung.

Der einzige native Missionszugriff ist die read-only-Auswertung von `env.mission`, um die vom Projektinhaber gesetzten Diagnose-Gruppennamen und die dazu gespeicherten Mission-Editor-Koordinaten zu lesen. Es erfolgt keine native Mutation.

## 5. Testquelle und Builder

Source:

```text
mission/tests/shindand-air-operations/src/01-shindand-heliport-me-parking-map.lua
```

Builder:

```text
tools/build-shindand-heliport-parking-map.ps1
```

Generiertes Bundle:

```text
mission/tests/shindand-air-operations/dist/OMW_AirOps_Shindand_Heliport_MEParkingMap.lua
```

Der Builder blockiert mutierende Klassen/Pfade und verlangt die für diesen Test relevanten MOOSE-Aufrufe und Diagnosemarker.

## 6. Erwartete Runtime-Telemetrie

Zuerst wird die native Shindand-Heliport-Domain ausgegeben:

```text
AIRBASE name=<...> id=<...> parkingCount=<...> enumName=Shindand Heliport
PARKING_SPOT terminalID=<...> terminalID0=<...> terminalType=<...> ...
```

Danach folgt je Diagnosegruppe:

```text
PARKING_MAP
  meParking=<ME-Label>
  groupName=<DIAG_SHND_HP_ME_*>
  missionParkingField=<gespeicherter mission-Wert>
  mooseTerminalID=<Runtime-TerminalID>
  terminalID0=<Runtime-TerminalID0>
  terminalType=<...>
  distanceM=<Abstand Diagnoseanker zu Parking-Koordinate>
```

Besonders zu prüfen:

```text
DIAG_SHND_HP_ME_34
DIAG_SHND_HP_ME_34a
```

Beide müssen auf unterschiedliche reale MOOSE-TerminalIDs abgebildet werden, sofern DCS sie tatsächlich als zwei getrennte Parking-Spots führt.

## 7. Gate-Kriterien

`PASS_MAP` setzt voraus:

```text
Shindand Heliport über AIRBASE.Afghanistan.Shindand_Heliport aufgelöst
Parking-Datensatz nicht leer
45 Diagnoseanker erkannt
jede Diagnosegruppe ist Late Activation
jede Diagnosegruppe enthält genau ein Luftfahrzeug
alle 45 Anker liegen maximal 5 m von einem MOOSE-Parking-Spot entfernt
keine zwei Diagnoseanker belegen dieselbe MOOSE-TerminalID
```

Andere Resultate:

```text
PARTIAL
-> mindestens ein Anker nicht eindeutig/zulässig zugeordnet oder doppelte TerminalID

FAIL
-> Heliport nicht auflösbar, keine Parking-Daten oder falsche Ankerzahl
```

Ein `PASS_MAP` validiert ausschließlich die Parking-Zuordnung dieses exakten MIZ-/Bundle-/MOOSE-/DCS-Stands. Er legt noch keine finale Client-Blacklist oder KI-Allowlist fest.

## 8. Noch in DCS zu prüfen

Vor einem DCS-Lauf sind gemäß Test-Governance die reale lokale Build-Ausgabe, Bundle-SHA-256, aktuelle MIZ-SHA-256, eingebetteter Bundle-Hash und eingebetteter Moose.lua-Hash zu erfassen.

Der Teststatus bleibt bis zur realen DCS-Ausführung:

```text
NOT_RUN
validated_in_dcs: false
```
