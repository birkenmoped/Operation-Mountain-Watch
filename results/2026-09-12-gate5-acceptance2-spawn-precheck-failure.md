---
document_id: OMW-RESULT-GATE5-ACCEPTANCE2-SPAWN-PRECHECK-FAILURE-2026-09-12
status: HISTORICAL_TEST_FIXTURE
document_class: TEST_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - exact Gate-5 Acceptance-2 DCS failure observed on 2026-09-12
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: true
---

# Gate 5 Acceptance 2 - Spawn-Precheck-Failure 2026-09-12

## Ergebnis

Der reale DCS-Lauf von Gate 5 Acceptance 2 materialisierte keine Guard-Gruppe. Das Verhalten war kein stiller MOOSE-/WAREHOUSE-Spawnfehler, sondern ein absichtlicher Abbruch des Acceptance-Skripts vor der ersten `BRIGADE`-Erzeugung.

Die entscheidende Runtime-Zeile lautet:

```text
2026-09-12 16:32:20.418 INFO SCRIPTING (Main): [OMW][FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE5-SIX-SITE-GUARD-RUNTIME-ACCEPTANCE-2] [GATE 5][FAIL] JALALABAD_FENTY SPAWN_OUTSIDE_ACCESS_1
```

Damit ist erklaert, warum an keiner der sechs Sites Guards erschienen: `start()` arbeitet die Sites sequenziell ab und beendet den Setup-Lauf beim ersten `false`. `JALALABAD_FENTY` ist der erste Eintrag.

## Ursache

Acceptance 2 hatte zwei Bedingungen gekoppelt, die fuer Fenty in der realen v24-Mission nicht gleichzeitig gelten:

```text
1. kompakte 9-Mann-Linie direkt auf dem ersten Segment der Guard-PATHLINE aufbauen;
2. jeder dieser Spawnpunkte muss innerhalb ZON_BLUE_GND_FENTY_ACCESS liegen.
```

Read-only-Pruefung der vom Projektinhaber gelieferten Mission:

```text
Mission: OMW_Template_v24_GroundWorks_base.miz
Uploaded-copy SHA-256: DEB7ABEAB39DFE386D54CD606C838F50BBDBB2A147EE3BA011F269037113C85B
```

Die Mission enthaelt die vorhandene polygonale `ZON_BLUE_GND_FENTY_ACCESS` und die vorhandene `OMW_RTE_BLUE_GUARD_FENTY_01`. Der erste PATHLINE-Abschnitt liegt jedoch nicht innerhalb dieser ACCESS-Zone. Der Acceptance-Code interpretierte daher die owner-authored PATHLINE faelschlich zugleich als Materialisierungsflaeche und als Bewegungsroute.

Das ist ein Test-/Materialisierungsannahmefehler, kein fehlendes Mission-Editor-Objekt. Es werden weiterhin keine neuen Alarm- oder Spawn-Zonen gefordert und die `.miz` wird nicht veraendert.

## Korrektur

Der kleinste notwendige Fix bleibt innerhalb des bereits genehmigten test-spezifischen Warehouse-Adapters:

```text
bestehende ACCESS-Zone
-> kompakte 9-Mann-Linie um das ACCESS-Zentrum materialisieren
-> Heading weiterhin aus PATHLINE Punkt 1 -> Punkt 2 ableiten
-> Abstand adaptiv 2.00 m bis mindestens 0.75 m, bis alle Units in ACCESS liegen
-> Route vom realen Spawnpunkt zu PATHLINE Punkt 1 und danach entlang der vollstaendigen owner-authored PATHLINE
```

Damit bleiben die getrennten Verantwortungen erhalten:

```text
ACCESS = zulaessige Materialisierungsflaeche
PATHLINE = owner-authored Bewegungsroute und Ausrichtungsreferenz
```

MOOSE-first bleibt unveraendert: `BRIGADE`/`WAREHOUSE`, `PLATOON`, `AUFTRAG:NewONGUARD`, `PATHLINE`, `COORDINATE`, Ground-Waypoints und der MOOSE-Lifecycle bleiben erhalten. Die private Warehouse-Materialisierungsstelle bleibt auf den bereits genehmigten Acceptance-Testscope beschraenkt.

## Status

```text
Acceptance 2 original build: DCS FAIL - pre-spawn geometry validation
Guard materialization: not reached
Six-site movement result: not evaluated
Corrected build: pending owner-local pull/build/hash and new DCS run
```
