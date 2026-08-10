---
document_id: OMW-TEST-SHINDAND-HELIPORT-PARKING-MAP
status: PLANNED
document_class: MISSION_RUNTIME_TEST
owning_policy: OMW-GOV-001
authoritative_for:
  - read-only mapping of Shindand Heliport Mission Editor parking labels to MOOSE TerminalIDs
  - tested Shindand Heliport parking-domain evidence
not_authoritative_for:
  - active Shindand ORBAT
  - final productive AI parking allowlist or client blacklist
  - AIRWING/SQUADRON acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/shindand-heliport-parking-diagnostic
source_commit: PENDING_MERGE
validated_in_dcs: partial
supersedes: []
superseded_by: []
---

# Shindand Heliport – ME-Parking zu MOOSE-TerminalID

## 1. Zweck

Dieser Test bildet die im Mission Editor sichtbaren Parkplatzbezeichnungen des **Shindand Heliport** auf die von MOOSE/DCS verwendeten Parking-Datensätze ab.

Der Test ist ausschließlich read-only. Er erzeugt keine AIRWING-, SQUADRON-, AUFTRAG- oder COMMANDER-Instanzen, aktiviert keine Gruppen, erzeugt keine Spawns und verändert keine Parking-Konfiguration.

Ziel ist insbesondere die Auflösung der Mission-Editor-Diskrepanz, dass der sichtbare Parkplatz `34` zweimal angeboten wird. Der Projektinhaber hat den zweiten Eintrag ausschließlich für die Diagnose als `34a` benannt.

## 2. Getesteter Missionsstand

Ausgeführte Mission:

```text
OMW_Template_v7_Shindand.miz
MIZ SHA-256: bbfe3073a41322c1d3d247f075e2cda760c4d3e953a3d7ab250dac007fb04037
internal mission SHA-256: 140c9abb54a6eb4e769652dc51d6e00801c8f6a413eddf14136a1f139706e301
```

Die Mission enthält 45 Late-Activation-Single-Ship-Diagnosegruppen nach dem Schema:

```text
DIAG_SHND_HP_ME_<ME-Parkplatzbezeichnung>
```

Der doppelte sichtbare ME-Eintrag `34` ist vertreten als:

```text
DIAG_SHND_HP_ME_34
DIAG_SHND_HP_ME_34a
```

`34a` ist ausschließlich ein OMW-Diagnosealias und niemals als DCS- oder MOOSE-Parking-ID zu interpretieren.

Der AIROPS-Warehouse-Anker heißt:

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

Gepinnter und im Test tatsächlich eingebetteter MOOSE-Stand:

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

`AIRBASE:GetParkingSpotsTable()` liefert im gepinnten Stand unter anderem `Coordinate`, `TerminalID`, `TerminalType`, `TOAC`, `Free`, `TerminalID0` und `DistToRwy`.

Die offiziellen MOOSE-Missionsrepositories wurden auf einen unmittelbar passenden Parking-Label-Mapping-Demoeinsatz geprüft; ein gleichartiger Demonstrator wurde nicht gefunden. OMW besitzt auf `main` bereits den read-only Tarinkot-G6A2-Mappingtest als projektspezifisches Vorbild. Die Shindand-Version verwendet zusätzlich die öffentliche MOOSE-Methode `COORDINATE:GetClosestParkingSpot()` für die Zuordnung.

Der einzige native Missionszugriff ist die read-only-Auswertung von `env.mission`, um Diagnose-Gruppennamen und gespeicherte Mission-Editor-Koordinaten zu lesen. Es erfolgt keine native Mutation.

## 5. Testquelle und Builder

Source:

```text
mission/tests/shindand-air-operations/src/01-shindand-heliport-me-parking-map.lua
```

Builder:

```text
tools/build-shindand-heliport-parking-map.ps1
```

Generiertes und getestetes Bundle:

```text
mission/tests/shindand-air-operations/dist/OMW_AirOps_Shindand_Heliport_MEParkingMap.lua
BuilderVersion: SHND-HP-ME-PARKING-MAP-1
Source commit: 6180bdc21f241d534eb0c4c92f6e95802303efdd
Bundle SHA-256: 61884006fdd0af75425c796985071d8b47f889b9f863c84afe4f68e51a355066
```

## 6. DCS-Runtime-Ergebnis vom 10.08.2026

Umgebung:

```text
DCS: 2.9.28.26385 MT
Airbase: Shindand Heliport
DCS/MOOSE Airbase ID: 14
MOOSE parking count: 42
Terminal type of mapped spots: 40
```

Ergebnis des Diagnosebundles:

```text
anchors=45
mapped=38
rejected=7
duplicates=6
malformed=0
status=PARTIAL
reason=UNMAPPED_OR_INVALID_ANCHORS
```

Die sechs gemeldeten `DUPLICATE_TERMINAL`-Marker entstehen ausschließlich dadurch, dass mehrere der sieben außerhalb der bestätigten Heliport-Domain liegenden Anker denselben geometrisch nächsten Heliport-Terminal als Kandidaten erhalten. Sie sind keine Doppelbelegung innerhalb der 38 akzeptierten Mappings.

### 6.1 Bestätigter Heliport-Parking-Contract

Für diesen exakt getesteten Missions-/MOOSE-/DCS-Stand gelten folgende 38 Zuordnungen als bestätigt:

| ME-Label | MOOSE TerminalID | TerminalID0 |
|---:|---:|---:|
| 01 | 21 | 21 |
| 02 | 3 | 3 |
| 03 | 1 | 1 |
| 04 | 32 | 32 |
| 05 | 34 | 34 |
| 07 | 15 | 15 |
| 08 | 35 | 35 |
| 10 | 31 | 31 |
| 11 | 0 | 0 |
| 12 | 16 | 16 |
| 13 | 24 | 24 |
| 14 | 33 | 33 |
| 15 | 14 | 14 |
| 16 | 25 | 25 |
| 17 | 42 | 42 |
| 18 | 27 | 27 |
| 19 | 22 | 22 |
| 20 | 39 | 39 |
| 21 | 38 | 38 |
| 22 | 5 | 5 |
| 23 | 29 | 29 |
| 24 | 11 | 11 |
| 25 | 26 | 26 |
| 26 | 40 | 40 |
| 27 | 9 | 9 |
| 28 | 17 | 17 |
| 29 | 41 | 41 |
| 30 | 18 | 18 |
| 31 | 13 | 13 |
| 32 | 37 | 37 |
| 33 | 4 | 4 |
| 34 | 20 | 20 |
| 34a | 19 | -1 |
| 36 | 2 | 2 |
| 37 | 23 | 23 |
| 39 | 10 | 10 |
| 41 | 30 | 30 |
| 42 | 7 | 7 |

Alle 38 akzeptierten Diagnoseanker lagen exakt auf der jeweiligen MOOSE-Parking-Koordinate (`distanceM=0.000`).

Der doppelte Mission-Editor-Eintrag `34` ist damit technisch aufgelöst:

```text
ME 34  -> MOOSE TerminalID 20
ME 34a -> MOOSE TerminalID 19
```

Für TerminalID `19` liefert MOOSE in diesem Lauf `TerminalID0=-1`. Für den OMW-Parking-Contract ist deshalb `TerminalID` maßgeblich; `TerminalID0` wird nur als beobachtetes Zusatzfeld dokumentiert.

### 6.2 Aus Heliport-Contract ausgeschlossen

Die folgenden Diagnoseanker lagen deutlich außerhalb der bestätigten Heliport-Parking-Domain und sind deshalb aus dem Heliport-Contract ausgeschlossen:

```text
ME 46
ME 47
ME 48
ME 49
ME 50
ME 51
ME 52
```

Der Test weist ihnen **keine andere Airbase-Domain zu**. Ihre Zuordnung zu `Shindand Airfield` wurde nicht getestet und wird nicht behauptet.

## 7. Artefaktprovenienz

```text
Branch: agent/shindand-heliport-parking-diagnostic
Source commit: 6180bdc21f241d534eb0c4c92f6e95802303efdd
BuilderVersion: SHND-HP-ME-PARKING-MAP-1
Bundle SHA-256: 61884006fdd0af75425c796985071d8b47f889b9f863c84afe4f68e51a355066
MIZ SHA-256: bbfe3073a41322c1d3d247f075e2cda760c4d3e953a3d7ab250dac007fb04037
internal mission SHA-256: 140c9abb54a6eb4e769652dc51d6e00801c8f6a413eddf14136a1f139706e301
embedded Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
DCS log SHA-256: cd4cc5e6d79fa0b857b9e32ccb5f2155b6fb42867f3130d763c9816fb7ba8aee
Debrief SHA-256: 7c98ba7683f8e05126b1ac8854b2ac0a3eb7febce3d08964f196adaa57036c8c
DCS: 2.9.28.26385 MT
Test date: 2026-08-10
```

## 8. Geltungsgrenze

Dieser DCS-Lauf bestätigt die Identität des `Shindand Heliport`, seine 42 von MOOSE gelieferten Parking-Spots sowie die 38 oben aufgeführten ME-Label-zu-TerminalID-Zuordnungen für die dokumentierte Artefaktkette.

Der Lauf legt noch keine produktive AI-Parking-Allowlist, Client-Blacklist oder SQUADRON-Parking-Verteilung fest. Diese werden erst aus dem bestätigten Heliport-Contract und den konkreten Client-/Template-/Static-Anforderungen abgeleitet.
