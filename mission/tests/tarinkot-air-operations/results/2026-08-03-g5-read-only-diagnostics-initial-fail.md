---
document_id: OMW-TEST-TKOT-G5-RESULT-2026-08-03-INITIAL
status: HISTORICAL_TEST_FIXTURE
document_class: DCS_TEST_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - observed Tarinkot G5 runtime result on the exact documented commit and bundle
  - identification of the single failing Mission Editor static object
  - historical retest boundary before G6
not_authoritative_for:
  - corrected Mission Editor state
  - current G5 PASS acceptance
  - parking allowlists
  - AIRWING, SQUADRON or mission runtime acceptance
  - merge approval or Ready-for-Review approval
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit: 2c0d76aee2f1cb987872d9903909bd21c904609d
validated_in_dcs: true
supersedes: []
superseded_by:
  - mission/tests/tarinkot-air-operations/results/2026-08-03-g5-read-only-diagnostics-retest-pass.md
---

# Tarinkot G5 – initialer DCS-Lauf vom 03.08.2026

## 1. Ergebnis

```yaml
result: FAIL_STRUCTURE
read_only_behavior: PASS
provenance: PASS
airbase_and_parking_dump: PASS
warehouse: PASS
clients: PASS
ai_seeds: PASS
statics: FAIL_ONE_MISSING_MOOSE_WRAPPER
zones: PASS_EXPECTED_MISSING_SET
name_collisions: PASS
next_gate: G5_RETEST
G6_authorized: false
```

Dieser historische Erstlauf wurde durch den späteren dokumentierten Retest-PASS abgelöst. Er bleibt erhalten, weil er die Ursache und die kontrollierte Mission-Editor-Korrektur belegt.

Der erste G5-Lauf hat das Diagnosebundle korrekt geladen und vollständig ausgeführt. Der Lauf ist dennoch `FAIL_STRUCTURE`, weil genau ein erwartetes Tarinkot-Static nicht über `STATIC:FindByName()` auflösbar war.

## 2. Provenienz

```text
Branch:
agent/tarinkot-object-contract-reconciliation

Git commit:
2c0d76aee2f1cb987872d9903909bd21c904609d

Builder:
tools/build-tarinkot-air-operations-g5-diagnostics.ps1

Builder version:
TKOT-G5-READONLY-2

Bundle:
mission/tests/tarinkot-air-operations/dist/OMW_AirOps_Tarinkot_G5_ReadOnly.lua

Bundle SHA-256:
8108bc7706976ad33de4017e9e6a6b72d7dfd493a38cde3b51d9b9f3702701cc

Mission reported by DCS/debrief:
OMW_Template_v5_Salerno.miz

Expected source-mission SHA-256:
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

## 3. Bestätigte read-only-Ausführung

```text
READ_ONLY_LOCK AIRWING=0 SQUADRON=0 PAYLOAD=0 SPAWN=0 AUFTRAG=0 COMMANDER=0 OPSTRANSPORT=0 CAMPAIGNSTATE_MUTATION=0 MIZ_MUTATION=0
```

Abschluss:

```text
RESULT G5_READ_ONLY_DIAGNOSTICS_COMPLETE status=FAIL_STRUCTURE coreMissing=1 zonesMissing=10 mutationCount=0
```

Es trat keine G5-Lua-Exception auf. Der Spieler übernahm regulär den vorhandenen Client `CLIENT_US_TKOT_AH64D_01`; dies ist kein durch G5 erzeugter Spawn.

## 4. Bestätigte Runtime-Daten

### Airbase

```text
name=Tarinkot
requested ID=9
normal ID=9
unique ID=9
candidate count=1
category=Airdrome
coalition=Blue
```

`GetCountryName()` lieferte für die Airbase `nil`. Das ist für G5 kein Strukturfehler.

### Parking

```text
PARKING_COUNT=33
```

Bestätigte Client-Reservierungen:

```text
TerminalID 20 / C01-H / CLIENT_US_TKOT_AH64D_01
TerminalID  8 / C05-H / CLIENT_US_TKOT_AH64D_02
TerminalID  3 / C07-H / CLIENT_US_TKOT_CH47F_01
```

Alle drei Runtime-Einträge waren:

```text
TerminalType=40
Free=false
TOAC=true
TerminalID0 entspricht TerminalID
```

Besonderheit des Mission-Templates:

```text
CLIENT_US_TKOT_AH64D_01 unit.parking = "20"  # Lua string
CLIENT_US_TKOT_AH64D_02 unit.parking = 8     # Lua number
CLIENT_US_TKOT_CH47F_01 unit.parking = 3     # Lua number
```

### Warehouse

```text
WAREHOUSE_ANCHOR name=WH_AIR_US_TARINKOT staticFound=true unitFound=false wrapperCount=1
WAREHOUSE_DETAILS type=container_20ft coalition=Blue country=USA
```

### Clients und AI-Seeds

Alle drei Clients und alle drei AI-Seeds wurden gefunden. Bestätigte Seeds:

```text
TPL_AIR_US_TKOT_AH64D_CAS_2SHIP      2 x AH-64D_BLK_II, Late Activation
TPL_AIR_US_TKOT_UH60_MEDEVAC_1SHIP   1 x UH-60A, Late Activation
TPL_AIR_US_TKOT_CH47_HEAVYLIFT_1SHIP 1 x CH-47Fbl1, Late Activation
```

Die Seeds besitzen weiterhin keine zugewiesenen Parking-Werte.

### Zonen und Namenskollisionen

```text
ZONE_SUMMARY expected=11 present=1 missing=10
CONTRACT_NAME_DUPLICATE_COUNT=0
```

Vorhanden:

```text
OMW_LOG_NODE_TARINKOT
```

Die zehn fehlenden Funktionszonen entsprechen exakt dem erwarteten G5-Ausgangszustand und verursachen keinen Strukturfehler.

## 5. Fehler

```text
MISSING STATIC name=STATIC_AIR_US_TKOT_AH64_07
STATIC_SUMMARY expected=12 missing=1
```

Alle übrigen sieben AH-64-Statics und alle vier UH-60-Statics wurden gefunden.

Der Mission-Editor-Audit weist für das fehlende Objekt als einzige Abweichung innerhalb der AH-64-Reihe den älteren Typ aus:

```text
STATIC_AIR_US_TKOT_AH64_01 bis _06: AH-64D_BLK_II
STATIC_AIR_US_TKOT_AH64_07:         AH-64D
STATIC_AIR_US_TKOT_AH64_08:         AH-64D_BLK_II
```

Der DCS-Debrief-Weltzustand führt dieselbe Unit-ID 1624 an derselben Position als `AH-64D_BLK_II`. Trotzdem existiert unter dem erwarteten Namen kein MOOSE-`STATIC`-Wrapper. Das belegt eine Runtime-/Wrapper-Inkonsistenz für dieses einzelne Legacy-Typobjekt; es belegt nicht, dass der Objektname absichtlich geändert wurde.

## 6. Korrektur

Im Mission Editor war ausschließlich folgendes Objekt zu korrigieren:

```text
STATIC_AIR_US_TKOT_AH64_07
```

Verbindliche Zielkonfiguration:

```text
Name:      STATIC_AIR_US_TKOT_AH64_07
Type:      AH-64D_BLK_II
Position:  unverändert
Heading:   unverändert
Coalition: unverändert
Country:   unverändert
```

Nicht zu ändern waren:

- andere Tarinkot-Statics;
- Clients oder AI-Seeds;
- Parking-Werte;
- Warehouse;
- Funktionszonen;
- G5-Lua oder Builder.

## 7. Abgelöst durch Retest-PASS

Der kontrollierte Retest ist dokumentiert unter:

```text
mission/tests/tarinkot-air-operations/results/2026-08-03-g5-read-only-diagnostics-retest-pass.md
```

Dort wurde bestätigt:

```text
STATIC_SUMMARY expected=12 missing=0
RESULT G5_READ_ONLY_DIAGNOSTICS_COMPLETE status=PASS_STRUCTURE coreMissing=0 zonesMissing=10 mutationCount=0
```
