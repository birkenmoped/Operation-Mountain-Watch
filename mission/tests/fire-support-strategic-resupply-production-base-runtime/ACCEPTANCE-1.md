---
document_id: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-1
status: PLANNED
document_class: ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - Production Base package DCS acceptance scope
  - six-site Guard regression through production composition root
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Production Base Acceptance 1

## Ziel

Diese Acceptance prueft erstmals das generierte Production-Base-Paket

```text
mission/fire-support-strategic-resupply/dist/OMW_FireSupStratResupply_Base.lua
```

als zusammenhaengenden DCS-Laufzeitbaustein.

Der Test ist bewusst eng abgegrenzt. Er beweist ausschliesslich:

1. das generierte Paket wird nach MOOSE erfolgreich geladen;
2. `OMW.FireSupStratResupply.New(spec)` erzeugt und vorbereitet den allgemeinen Runtime-Composition-Root;
3. die sechs bereits vorhandenen lokalen BRIGADE-/PLATOON-Guard-Organisationen koennen ueber `Runtime:StartSite()` ihren persistenten Guard-Demand erhalten;
4. MOOSE rekrutiert/materialisiert den Guard;
5. der bereits akzeptierte Guard-Materialisierungsadapter und der vorhandene PATHLINE-Routenadapter werden durch den Production-Composition-Root erreicht;
6. alle sechs Guards bleiben lebendig und zeigen mindestens 25 m Positionsaenderung gegenueber der beim `OnAfterArmyOnMission` beobachteten Startposition.

## Nicht Bestandteil dieser Acceptance

Diese Acceptance prueft **nicht**:

- dauerhafte oder endlose Guard-Patrouillenzyklen;
- QRF-Ausfuehrung;
- ARTY-Ausfuehrung;
- CAS-Ausfuehrung;
- Perimeter-/Multi-Evidence-Incident-Ausloesung;
- Ground-/Air-Resupply;
- CampaignState-Settlement eines physischen Transports;
- missionsspezifische Alarmradien, QRF-Ziele, CAS-Zonen oder Resupply-Routen.

Fuer diese Punkte werden keine Geometrien oder Provider erfunden. Sie bleiben gesonderten Acceptance-Schritten vorbehalten.

## Guard-Vertrag

Die bereits genehmigte Ausnahme wird nicht erweitert. Sie betrifft weiterhin ausschliesslich die exakte kompakte Guard-Materialisierung unmittelbar vor der MOOSE-Warehouse-Materialisierung. Rekrutierung, BRIGADE/WAREHOUSE, PLATOON, ARMYGROUP und AUFTRAG bleiben bei MOOSE.

Die bekannte Beobachtung aus Gate 5, dass nicht alle sechs Gruppen nach dem ersten PATHLINE-Lauf dauerhaft identisch weiterpatrouillieren, ist kein Fehlerkriterium dieser Acceptance. Der Projektinhaber hat entschieden, den aktuellen Stand beizubehalten und keine zweite Ausnahme fuer eine eigene Patrol-Loop-Logik zu genehmigen.

## Mission-Editor-Voraussetzungen

Verwendet wird die bestehende Foundation-Mission mit den bereits in Gate 5 bestaetigten Objekten:

```text
TPL_BLUE_GND_INF_RIFLE_SQUAD_9
WH_BLUE_GND_FENTY
WH_BLUE_GND_FORTRESS
WH_BLUE_GND_JOYCE
WH_BLUE_GND_WRIGHT
WH_BLUE_GND_HONAKER
WH_BLUE_GND_BOSTICK
OMW_RTE_BLUE_GUARD_FENTY_01
OMW_RTE_BLUE_GUARD_FORTRESS_01
OMW_RTE_BLUE_GUARD_JOYCE_01
OMW_RTE_BLUE_GUARD_WRIGHT_01
OMW_RTE_BLUE_GUARD_HONAKER_01
OMW_RTE_BLUE_GUARD_BOSTICK_01
```

`ZON_BLUE_GND_*_ACCESS` gehoert nicht zum Guard-Testvertrag.

## Builder

```text
tools/build-fire-support-strategic-resupply-production-base-acceptance-1.ps1
```

Der Builder ruft zuerst den Production-Base-Builder auf und verwendet dessen real erzeugtes Bundle unveraendert als ersten Bestandteil des Acceptance-Bundles. Danach wird nur der Acceptance-Harness angehaengt.

Ausgabe:

```text
mission/tests/fire-support-strategic-resupply-production-base-runtime/dist/OMW_FireSupStratResupply_Production_Base_Acceptance_1.lua
```

## PASS-Kriterium

Der DCS-Log muss den exakten PASS enthalten:

```text
[PRODUCTION BASE][PASS] 6/6 production-package Guards recruited, routed and >=25 m movement observed
```

Zusatzbedingungen:

- kein `[PRODUCTION BASE][FAIL]`;
- alle sechs Site-IDs in der Telemetrie;
- `missionObserved=true` je Site;
- Guard-Gruppe je Site lebendig;
- mindestens 25 m Positionsaenderung je Site.

Das 25-m-Kriterium ist wie bei der akzeptierten Gate-5-Baseline ein initialer Bewegungsnachweis. Es beweist keinen vollstaendigen oder dauerhaften Patrol-Zyklus.

## Provenance nach realem Test

Erst nach lokalem Build und DCS-Lauf werden hier die realen Werte eingetragen und der Status gegebenenfalls auf `ACCEPTED_TECHNICAL_BASELINE` gesetzt:

```text
acceptance_commit
acceptance_mission
acceptance_mission_sha256
dcs_version
Moose.lua SHA-256
Production-Base-Bundle SHA-256
Acceptance-Source SHA-256
Acceptance-Builder SHA-256
Acceptance-Bundle SHA-256
```
