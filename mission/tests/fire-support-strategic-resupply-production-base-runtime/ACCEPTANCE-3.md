---
document_id: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-3
status: DRAFT
document_class: ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - corrected six-site installation-alarm acceptance contract
  - six-site proximity-evidence to incident to local-QRF response acceptance scope
  - QRF ACCESS-boundary road materialization acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Production Base Acceptance 3 – Six-Site Installation Alarm + QRF Response

## 1. Reuse-Gate

Diese Acceptance darf keine bereits abgenommene Ground-/Honaker-Semantik neu definieren. Verbindliche Reuse-Matrix:

```text
docs/moose/FIRE-SUPPORT-ACCEPTED-IMPLEMENTATION-MATRIX.md
```

Insbesondere gilt für QRF:

```text
AUFTRAG:NewONGUARD(initial threat coordinate)
+ SetEngageDetected(5 NM, {"Ground Units"}, site-local 5 NM tactical zone)
+ SetReturnToLegion(true)
```

Das entspricht dem dokumentierten Honaker-Full-Response-Vertrag. `GROUNDATTACK` ist keine zulässige stille Substitution.

## 2. Alarmsemantik

```text
site-specific alarm/security zone
-> hostile proximity / penetration
-> PROXIMITY_INTRUSION
-> authoritative installation attack incident
-> exactly one initial local QRF demand
-> MOOSE recruitment / execution
```

Die Alarmzone ist ausschließlich Detection-/Response-Triggergrenze. Sie ist kein Gefechtsraum, keine WEZ und keine Mission-End-Bedingung. Perimeter-Clear oder lokale Incident-Completion dürfen einen bereits disponierten QRF-Auftrag nicht beenden.

## 3. Six-Site-Alarmgeometrie

| Site | Alarmanker | Radius ft | Radius m |
|---|---|---:|---:|
| `JALALABAD_FENTY` | center of `OMW_BLUE_OBJECTIVE_JALALABAD_AIRPORT` | 8000 | 2438.4 |
| `COP_FORTRESS` | `WH_BLUE_GND_FORTRESS` | 5000 | 1524.0 |
| `FOB_JOYCE` | `WH_BLUE_GND_JOYCE` | 9000 | 2743.2 |
| `FOB_WRIGHT` | `WH_BLUE_GND_WRIGHT` | 4000 | 1219.2 |
| `COP_HONAKER` | `WH_BLUE_GND_HONAKER` | 9000 | 2743.2 |
| `FOB_BOSTICK` | `WH_BLUE_GND_BOSTICK` | 5000 | 1524.0 |

Jalalabad verwendet die vorhandene 6000-ft-Mission-Editor-Zone ausschließlich als Mittelpunktquelle. Die Acceptance erzeugt dort zur Laufzeit einen MOOSE `ZONE_RADIUS` mit 2438.4 m. Keine `.miz`-Mutation.

## 4. QRF Materialisierung

Motorisierte QRF-Gruppen verwenden den bestehenden Ground-Vertrag:

```text
MOOSE QRF demand / AUFTRAG / BRIGADE recruitment
-> existing site ACCESS zone
-> approved OMW_GroundRoadSpawnAdapter
-> road-axis materialization
-> fixed 18 m vehicle spacing
-> MOOSE mission lifecycle
```

Verbindliche Übergabepunkte:

```text
JALALABAD_FENTY -> ZON_BLUE_GND_FENTY_ACCESS
COP_FORTRESS    -> ZON_BLUE_GND_FORTRESS_ACCESS
FOB_JOYCE       -> ZON_BLUE_GND_JOYCE_ACCESS
FOB_WRIGHT      -> ZON_BLUE_GND_WRIGHT_ACCESS
COP_HONAKER     -> ZON_BLUE_GND_HONAKER_ACCESS
FOB_BOSTICK     -> ZON_BLUE_GND_BOSTICK_ACCESS
```

Die ACCESS-Zone ist zugleich der MOOSE Spawn-/Home-Handoff-Punkt. Sie definiert weder Alarmzone noch taktischen Wirkungsraum.

## 5. QRF Einsatz- und Rückkehrvertrag

Der bereits vorhandene Honaker-/Ground-Vertrag bleibt unverändert:

```text
QRF demand
-> ONGUARD + SetEngageDetected
-> physical response / engagement
-> explicit supported-element/C2 release
-> AUFTRAG Cancel
-> SetReturnToLegion(true)
-> ARMYGROUP RTZ to home ACCESS
-> Returned
-> Warehouse AddAsset
-> controlled physical group removal
```

**Release Authority:** Nur ein bereits definierter expliziter Supported-Element-/C2-Release darf den QRF-Auftrag beenden. Folgende Zustände besitzen keine Release Authority:

```text
movement distance
perimeter clear
alarm-zone exit
local incident close
raw RED count
```

Die konkrete Honaker-CAS-gekoppelte Release-Bedingung wird nicht stillschweigend auf alle sechs Standorte generalisiert.

## 6. Acceptance-3-Scope nach Regression-Korrektur

Acceptance 3 prüft deshalb ausschließlich die gemeinsame sechs-Site-Outbound-Kette. Sie erzeugt **keinen eigenen QRF-Release** und wartet nicht auf RTZ/Returned/Warehouse-Handoff.

Die 25-m-Grenze bleibt nur physische Runtime-Evidenz:

```text
QRF closing progress >= 25 m
= physical response observed
!= mission complete
!= release
!= cancel
```

Der Rückweg ist bereits separat durch Ground-/Honaker-Acceptances abgedeckt und muss erst dann erneut in einer generischen Six-Site-Acceptance geprüft werden, wenn eine generische Supported-Element-/C2-Release-Policy vom Projektinhaber festgelegt ist.

## 7. RED-Testfixtures

```text
BadGuys_A3_FENTY
BadGuys_A3_FORTRESS
BadGuys_A3_JOYCE
BadGuys_A3_WRIGHT
BadGuys_A3_HONAKER
BadGuys_A3_BOSTICK
```

Die Gruppen sind reine Testfixtures. Nach erfolgreicher Guard-Regression werden sie physisch per MOOSE `RouteGroundTo(...)` in die jeweiligen Alarmperimeter geführt. Kein Teleport, keine `.miz`-Mutation.

## 8. PASS-Kriterium

Der nächste Acceptance-3-Lauf muss mindestens nachweisen:

```text
6/6 Guards >=25 m physical movement
6/6 owner-defined MOOSE alarm perimeters started
Jalalabad runtime perimeter = 8000 ft / 2438.4 m
6/6 PROXIMITY_INTRUSION observed
6/6 authoritative installation incidents observed
6/6 exactly one initial QRF demand
6/6 local Ground_APC QRF observed
6/6 QRF initial materialization inside correct ACCESS zone
6/6 approved road-aligned materialization without spawn exception
6/6 QRF mission type ONGUARD
6/6 local QRF physical closing progress >=25 m
0 Acceptance-owned QRF release/cancel events
```

Ein Spawn außerhalb ACCESS, ein RoadSpawnAdapter-Fehler, eine `GROUNDATTACK`-Mission oder ein QRF-Cancel/RTZ aufgrund des Acceptance-Harness sind harte FAILs.

Timeout: 900 s. Es gibt kein künstliches Return-Fenster mehr, weil dieser Harness keinen Rückruf auslöst.

## 9. Regressionshistorie 13.09.2026

### ACCESS-Fassung `f834e3b5...`

`DIAGNOSTIC_FAIL`: Jalalabad/Fortress/Bostick zeigten Road-Materialisierungsfehler. Joyce/Wright bewiesen nur Teilfunktion. Details:

```text
results/2026-09-13-production-base-acceptance3-qrf-access-dcs-run.md
```

### Build `b4a6505248bf3371ca6b11adcd7f02374e519b84`

Verifizierter lokaler Build:

```text
Production bundle:
EB8DC2C5DD143DD0B4B8C951496499C9909A2A8DD38B1FA1D5334F1064293176

Acceptance bundle:
0AA3448371CA23E8ED1400229D9C3CD5F179271476EAAF727829054A22CACCB8
```

Der reale DCS-Lauf ist `DIAGNOSTIC_FAIL`: die zwischenzeitliche `GROUNDATTACK`-Substitution und insbesondere der Acceptance-eigene Pfad

```text
>=25 m closing progress
-> Base:ExpireDemand(...)
-> Cancel
-> RTZ
```

waren Regressionen gegenüber dem bereits dokumentierten Honaker-Vertrag. Fortress/Joyce konnten dadurch nach kurzer Bewegung sofort umdrehen und in den Return-Lifecycle wechseln.

Dieser Pfad ist verworfen.

## 10. Aktueller Stand

```text
Jalalabad alarm radius: OWNER-DEFINED 8000 ft / 2438.4 m
QRF mission contract: HONAKER BASELINE -> ONGUARD + SetEngageDetected
QRF tactical zone: 5 NM site-local
QRF return capability: SetReturnToLegion(true)
QRF release authority: explicit supported-element/C2 only
movement-driven release: FORBIDDEN
perimeter/incident-driven release: FORBIDDEN
Acceptance-3 return orchestration: REMOVED
Acceptance-3 outbound response harness: STAGED
local build/hash verification of corrected revision: PENDING
real DCS rerun: PENDING
validated_in_dcs: false
```

Ein Build allein ist kein PASS. `VALIDATED` beziehungsweise `ACCEPTED_TECHNICAL_BASELINE` darf nur aus realer dokumentierter DCS-Evidenz für den exakt gebauten Stand folgen.