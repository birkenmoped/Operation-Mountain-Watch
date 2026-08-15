---
document_id: OMW-TEST-CREE-BULLSEYE-COORDINATE
status: DRAFT
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local CREE bullseye WGS84-to-DCS-coordinate diagnostic
not_authoritative_for:
  - production mission bullseye position
  - historical ISAF bullseye authenticity
  - DCS avionics validation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/cree-bullseye-coordinate
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# CREE Bullseye Coordinate Diagnostic

## Ziel

Der Test ermittelt die exakten nativen DCS-Afghanistan-Missionskoordinaten für den vom Projektinhaber ausgewählten OMW-Bullseye `CREE`.

Quellkoordinate:

```text
CREE
N35°17.00' E070°16.00'
35.2833333333333, 70.2666666666667
```

Die Koordinate stammt aus der bereitgestellten Graveyard-of-Empires-Quelle `ISAF 2009-2013 - ACO Building - Bullseye List (9/x)`. Für OMW ist `CREE` eine aktuelle Missionsdesignentscheidung; die Quelle beweist nicht, dass dieser Punkt historisch als realer ISAF-Bullseye 2010/2011 verwendet wurde.

## MOOSE-first-Prüfung

Gepinnter MOOSE-Stand:

```text
MOOSE release/branch: project-pinned 2.9.18 artifact
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Der tatsächlich bereitgestellte `Moose.lua`-Stand enthält:

```lua
COORDINATE:NewFromLLDD(latitude, longitude, altitude)
COORDINATE:GetVec2()
COORDINATE:GetLLDDM()
```

`NewFromLLDD()` ruft intern DCS `coord.LLtoLO(latitude, longitude)` auf. `GetVec2()` liefert anschließend `{ x = self.x, y = self.z }`, also das DCS-Vec2-Format, das dem `x`/`y`-Bullseye-Paar in der `.miz` entspricht.

Für diesen elementaren Konvertierungspfad ist keine eigene native DCS-Parallelimplementierung erforderlich. Offizielle MOOSE-Demos sind für den reinen Konstruktor-/Getter-Aufruf nicht erforderlich; maßgeblich ist die geprüfte Signatur im tatsächlich gepinnten `Moose.lua`.

## Scope

Der Test:

1. konstruiert `CREE` über `COORDINATE:NewFromLLDD()`;
2. liest das native DCS-Vec2 über `GetVec2()`;
3. führt über `GetLLDDM()` einen Roundtrip nach Lat/Lon aus;
4. schreibt die exakten Werte als eindeutige `PASS`-Zeile in `dcs.log`.

Der Test verändert **nicht** den bestehenden BLUE-Bullseye der Mission.

## Build

```powershell
.\mission\tests\cree-bullseye-coordinate\Build-CreeBullseyeCoordinate.ps1
```

Ergebnis:

```text
mission/tests/cree-bullseye-coordinate/dist/cree_bullseye_coordinate.lua
```

Der Builder verwendet ausschließlich PowerShell und erzeugt ein UTF-8-Bundle ohne BOM. Er schreibt Builder-Version, Git-Commit, UTC-Zeit, Test-ID sowie den gepinnten MOOSE-Commit und Moose.lua-Hash in den Header.

## DCS-Einbindung

Die Testmission muss zuerst den gepinnten `Moose.lua`-Stand laden und anschließend das generierte Bundle über `DO SCRIPT FILE` ausführen.

Erwarteter Logmarker:

```text
[OMW][OMW_CREE_BULLSEYE_COORDINATE][PASS] CREE lat=... lon=... -> mission_x=... mission_y=... -> roundtrip_lat=... roundtrip_lon=... delta_lat=... delta_lon=...
```

Erst die reale DCS-Ausgabe dieses Markers liefert die für die Mission zu verwendenden `x`/`y`-Werte.

## Acceptance-Grenze

Ein erfolgreicher Lauf bestätigt ausschließlich:

```text
CREE WGS84 -> DCS Afghanistan mission Vec2
```

Er bestätigt nicht:

- die spätere `.miz`-Mutation;
- das Verhalten einzelner Flugzeugavioniken;
- die Anzeige oder Funkphraseologie des Bullseyes;
- historische Verwendung von `CREE` durch ISAF.

Nach erfolgreicher Koordinatenermittlung wird die tatsächliche Basismission separat geändert, neu gehasht und in DCS geprüft.
