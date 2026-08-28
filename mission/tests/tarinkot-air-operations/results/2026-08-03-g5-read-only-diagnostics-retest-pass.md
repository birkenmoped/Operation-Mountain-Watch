---
document_id: OMW-TEST-TKOT-G5-RESULT-2026-08-03-RETEST-PASS
status: BINDING
document_class: DCS_TEST_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - Tarinkot G5 read-only diagnostic PASS on the documented runtime commit
  - corrected Tarinkot Mission Editor static-object state
  - release of G6 parking calibration
not_authoritative_for:
  - final AI parking allowlists
  - AIRWING, SQUADRON, payload, mission, transport or COMMANDER acceptance
  - merge approval or Ready-for-Review approval
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit: 8b2e62878f2421ba894a7abff7c12d526f4cea3d
validated_in_dcs: true
supersedes:
  - mission/tests/tarinkot-air-operations/results/2026-08-03-g5-read-only-diagnostics-initial-fail.md
superseded_by: []
---

# Tarinkot G5 – DCS-Retest-PASS vom 03.08.2026

## 1. Ergebnis

```yaml
result: PASS_STRUCTURE
read_only_behavior: PASS
runtime_provenance: PASS
mission_editor_static_correction: PASS
airbase_and_parking_dump: PASS
warehouse: PASS
clients: PASS
ai_seeds: PASS
statics: PASS_12_OF_12
zones: PASS_EXPECTED_MISSING_SET
name_collisions: PASS
G5_gate: PASS_DCS
G6_authorized: true
```

Der spätere der beiden G5-Läufe in der übergebenen `dcs.log` ist der maßgebliche Retest. Der frühere Lauf auf Commit `2c0d76a...` bleibt als initialer FAIL erhalten; der Retest auf Commit `8b2e628...` schließt den bekannten Static-Fehler.

## 2. Provenienz

```text
Branch:
agent/tarinkot-object-contract-reconciliation

Getesteter Git-Commit:
8b2e62878f2421ba894a7abff7c12d526f4cea3d

Builder:
tools/build-tarinkot-air-operations-g5-diagnostics.ps1

Builder-Version:
TKOT-G5-READONLY-2

Im Bundle protokollierter Build-Zeitpunkt:
2026-08-03T20:07:51.5827458Z

Mission laut DCS-Debrief:
C:\Users\Sven\Saved Games\DCS.openbeta\Missions\OMW_Template_v5_Salerno.miz

Erwartete Source-Mission-SHA-256:
203c99ffa6e025a2d9f00dc899439b0167ed9d81981b612f3a8d4fd078c458f5

DCS:
2.9.28.26385 MT

Embedded MOOSE release:
2.9.18

Embedded MOOSE commit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

Embedded Moose.lua SHA-256:
e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Übergebene Evidenzdateien:

```text
dcs.log SHA-256:
fef394459daccf359635fbf549ec1fa926283d8346c433a0a1470bc529ea302e

debrief.log SHA-256:
125f8db6abc845f00393944834b31ebcfb80e6c26fd10dea60a4a712142f9803
```

Der neu gebaute Bundle-SHA-256 ist in den übergebenen Logs nicht enthalten. Die Runtime-Provenienz ist dennoch eindeutig, weil das tatsächlich eingebettete Bundle Builder-Version, getesteten Commit und Build-Zeitpunkt ausgibt. Die G5-Acceptance definiert die aktuelle `dcs.log` als Standardübergabe; die fehlende separate Hash-Ausgabe wird deshalb als nicht blockierende Nachweisnotiz behandelt.

## 3. Read-only-Nachweis

```text
READ_ONLY_LOCK AIRWING=0 SQUADRON=0 PAYLOAD=0 SPAWN=0 AUFTRAG=0 COMMANDER=0 OPSTRANSPORT=0 CAMPAIGNSTATE_MUTATION=0 MIZ_MUTATION=0
```

Abschlusszeile:

```text
RESULT G5_READ_ONLY_DIAGNOSTICS_COMPLETE status=PASS_STRUCTURE coreMissing=0 zonesMissing=10 mutationCount=0
```

Es existiert keine Tarinkot-G5-spezifische Lua-, Scheduler- oder Timer-Exception. G5 erzeugte keine operativen MOOSE-Objekte und löste keine Aktivierung oder Spawn-Aktivität aus.

## 4. Korrigiertes Static

Der Retest bestätigt:

```text
STATIC_AIR_US_TKOT_AH64_07
type=AH-64D_BLK_II
x=-149029.391
y=1356.546
z=-30900.779
```

Der DCS-Debrief führt die zugehörige Unit-ID `1624` ebenfalls als `AH-64D_BLK_II`, `dead=false` und an derselben Position. Damit ist die einzige Ursache des initialen G5-FAIL beseitigt.

Gesamtergebnis:

```text
STATIC_SUMMARY expected=12 missing=0
```

## 5. Airbase und Parking-Datensatz

```text
AIRBASE idRequested=9 name=Tarinkot
normal ID=9
unique ID=9
candidate count=1
category=Airdrome
coalition=Blue
PARKING_COUNT=33
```

Bestätigte Client-Reservierungen:

```text
TerminalID 20 / C01-H / CLIENT_US_TKOT_AH64D_01
TerminalID  8 / C05-H / CLIENT_US_TKOT_AH64D_02
TerminalID  3 / C07-H / CLIENT_US_TKOT_CH47F_01
```

Alle drei Runtime-Terminals sind `TerminalType=40`, `Free=false`, `TOAC=true`.

Datentypbesonderheit:

```text
CLIENT_US_TKOT_AH64D_01 unit.parking = "20"  # Lua string
CLIENT_US_TKOT_AH64D_02 unit.parking = 8     # Lua number
CLIENT_US_TKOT_CH47F_01 unit.parking = 3     # Lua number
```

G6 muss deshalb interne Terminal-IDs als Zahlen behandeln und darf den Stringwert des ersten Mission-Editor-Templates nicht ungeprüft übernehmen.

## 6. Warehouse, Templates, Zonen und Namen

```text
WAREHOUSE_ANCHOR name=WH_AIR_US_TARINKOT staticFound=true unitFound=false wrapperCount=1
WAREHOUSE_DETAILS type=container_20ft coalition=Blue country=USA
```

Gefunden wurden alle drei Clients und alle drei Late-Activation-Seeds:

```text
TPL_AIR_US_TKOT_AH64D_CAS_2SHIP      2 x AH-64D_BLK_II
TPL_AIR_US_TKOT_UH60_MEDEVAC_1SHIP   1 x UH-60A
TPL_AIR_US_TKOT_CH47_HEAVYLIFT_1SHIP 1 x CH-47Fbl1
```

Die Seeds besitzen weiterhin keine Parking-Zuweisungen.

```text
ZONE_SUMMARY expected=11 present=1 missing=10
CONTRACT_NAME_DUPLICATE_COUNT=0
```

Vorhanden ist ausschließlich `OMW_LOG_NODE_TARINKOT`. Die zehn fehlenden Funktionszonen entsprechen exakt dem erwarteten G5-Ausgangszustand und sind kein Strukturfehler.

## 7. Gate-Folge

```yaml
G3_mission_editor: PARTIAL_FUNCTION_ZONES_PENDING
G5_read_only_diagnostics: PASS_DCS
G6_parking_calibration: AUTHORIZED_NOT_STARTED
G7_airwing_squadron_payload: BLOCKED_BY_G6
```

G5 bestätigt keine Parking-Eignung und keine operative AIRWING-/SQUADRON-Funktion. G6 darf jetzt ausschließlich die 33 erfassten Parking-Terminals klassifizieren und anschließend isolierte Spawn-/Starttests vorbereiten. Positive `SQUADRON:SetParkingIDs()`-Listen bleiben bis zu einem dokumentierten G6-PASS gesperrt.
