---
document_id: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-3
status: DRAFT
document_class: ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - six-site installation-alarm to local-QRF response acceptance scope
  - QRF ACCESS-boundary materialization acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
supersedes:
superseded_by:
---

# Production Base Acceptance 3 – Six-Site Installation Alarm + QRF Response

## Reuse-Gate

Diese Acceptance darf keine bereits abgenommene Ground-/Honaker-Semantik neu definieren. Verbindlich sind `docs/moose/FIRE-SUPPORT-ACCEPTED-IMPLEMENTATION-MATRIX.md`, Ground-Alarm-Entscheidung, Ground ACCESS Contract sowie Honaker Full-Response.

QRF-Vertrag:

```text
AUFTRAG:NewONGUARD(initial threat coordinate)
+ SetEngageDetected(5 NM, {"Ground Units"}, site-local 5 NM tactical zone)
+ SetReturnToLegion(true)
```

`GROUNDATTACK` ist keine zulässige stille Substitution. Bewegung, Perimeter-Clear und Incident-Close besitzen keine Release Authority.

## Alarmgeometrie

```text
JALALABAD_FENTY  8000 ft / 2438.4 m
COP_FORTRESS     5000 ft / 1524.0 m
FOB_JOYCE        9000 ft / 2743.2 m
FOB_WRIGHT       4000 ft / 1219.2 m
COP_HONAKER      9000 ft / 2743.2 m
FOB_BOSTICK      5000 ft / 1524.0 m
```

Jalalabad verwendet `OMW_BLUE_OBJECTIVE_JALALABAD_AIRPORT` nur als Mittelpunktquelle. Keine zusätzliche Mission-Editor-Alarmzone ist erforderlich.

## Motorisierte QRF-Materialisierung

Ausschließlich vorhandene ACCESS-Zonen:

```text
JALALABAD_FENTY -> ZON_BLUE_GND_FENTY_ACCESS
COP_FORTRESS    -> ZON_BLUE_GND_FORTRESS_ACCESS
FOB_JOYCE       -> ZON_BLUE_GND_JOYCE_ACCESS
FOB_WRIGHT      -> ZON_BLUE_GND_WRIGHT_ACCESS
COP_HONAKER     -> ZON_BLUE_GND_HONAKER_ACCESS
FOB_BOSTICK     -> ZON_BLUE_GND_BOSTICK_ACCESS
```

Der vorhandene `OMW_GroundRoadSpawnAdapter` bleibt verantwortlich für road-aligned Spawnpositionen innerhalb ACCESS. Es gibt **keine** `PATROL_TEST`-Abhängigkeit und keine zusätzliche Spawnzone. Die physische Incident-Zielkoordinate ist nur Road-Forward-Richtungsinformation; sie ist keine Materialisierungsgrenze.

Die frühere Acceptance-Fassung mit `ZON_BLUE_GND_<SITE>_PATROL_TEST_01` war falsch und wurde nach einem realen Preflight-Fail verworfen.

## Acceptance-Scope

Der Harness beobachtet ausschließlich die Outbound-Reaktionskette und erzeugt keinen QRF-Release:

```text
6/6 Guards >=25 m physical movement
6/6 owner-defined MOOSE alarm perimeters
6/6 PROXIMITY_INTRUSION
6/6 authoritative installation incidents
exactly one initial QRF demand per site
6/6 local Ground_APC QRF
6/6 initial materialization inside correct ACCESS
6/6 ONGUARD
6/6 physical closing response >=25 m
0 Acceptance-owned QRF release/cancel events
```

`>=25 m` ist nur Runtime-Evidenz, niemals Mission-Ende.

Der Return-Lifecycle bleibt durch die vorhandenen Ground-/Honaker-Acceptances abgedeckt:

```text
explicit supported-element/C2 release
-> mission Cancel
-> SetReturnToLegion(true)
-> ARMYGROUP RTZ to home ACCESS
-> Returned
-> Warehouse AddAsset
-> physical removal
```

## Aktueller Buildstand

Vom Projektinhaber lokal gebaut und gehasht:

```text
Source commit: d63aded64cc7eb63c9f5809f5bf5451067332d3a
Production Builder: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-13
QRF Runtime: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-RUNTIME-10
QRF Mission Factory: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-MISSION-FACTORY-5
Acceptance Builder: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-3-9
Production bundle SHA-256: 7432541B6EA8906BBC6B80ECCA4A3F9E150E6BF523BA403A73C05ACC5F70DE7E
Acceptance bundle SHA-256: 1B3C23AB249A128A9863877CCFE3E3D996EA470CA9F450A18DF8498F324C0873
```

Separate `Get-FileHash`-Prüfungen stimmen überein. GitHub Documentation validation und MissionDemand validation sind für `d63aded...` erfolgreich.

Status: `VERIFIED_LOCAL_BUILD`, noch **nicht DCS-validiert**. Der nächste Schritt ist der reale DCS-Lauf mit exakt diesem Acceptance-Bundle und vollständiger Logauswertung.
