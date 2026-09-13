---
document_id: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-3
status: STAGED
document_class: ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - corrected six-site installation-alarm acceptance contract
  - six-site proximity-evidence to incident to local-QRF acceptance scope
  - QRF ACCESS-boundary road materialization acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_LOCAL_BUILD
validated_in_dcs: false
---

# Production Base Acceptance 3 – Six-Site Installation Alarm + QRF

## Verbindliche Alarmsemantik

```text
site-specific installation alarm/security/threat zone
-> hostile proximity / penetration
-> PROXIMITY_INTRUSION
-> authoritative installation attack incident
-> exactly one initial local QRF demand
-> MOOSE recruitment / execution
```

Direct Fire, Indirect Fire und confirmed Hit bleiben zusätzliche Evidence-Kanäle und dürfen denselben Incident erzeugen oder refreshen. Sie dürfen keinen zweiten initialen QRF-Demand erzeugen.

Die Alarmzone ist ausschließlich Detection-/Response-Triggergrenze. Sie ist nicht taktischer Gefechtsraum, WEZ, Fire-Support-Zielgebiet, CAS-Zone oder Mission-End-Bedingung. `ACCESS`, Warehouse-Grenzen und Guard-PATHLINE sind keine Alarmgeometrie.

## Six-Site-Alarmgeometrie

Die fünf Warehouse-basierten Standorte verwenden ihre vorhandene MOOSE-Warehouse-/BRIGADE-Koordinate als Mittelpunkt. Daraus wird zur Laufzeit `MOOSE ZONE_RADIUS -> MOOSE OPSZONE` erzeugt.

Für Jalalabad gilt nach ausdrücklicher Entscheidung des Projektinhabers vom 13.09.2026:

```text
Mittelpunkt:
existing MOOSE zone OMW_BLUE_OBJECTIVE_JALALABAD_AIRPORT

Alarmradius:
8000 ft = 2438.4 m
```

Die vorhandene Mission-Editor-Zone besitzt weiterhin nur 6000 ft / 1828.8 m und ist deshalb nur noch **Mittelpunktquelle**, nicht mehr die Alarmgeometrie. Acceptance 3 löst sie per `ZONE:FindByName(...)` auf, übernimmt ihren Mittelpunkt und erzeugt dort zur Laufzeit einen neuen MOOSE `ZONE_RADIUS` mit 2438.4 m. Die `.miz` wird nicht automatisch verändert.

| Site | Alarmanker | Radius ft | Radius m |
|---|---|---:|---:|
| `JALALABAD_FENTY` | center of `OMW_BLUE_OBJECTIVE_JALALABAD_AIRPORT` | 8000 | 2438.4 |
| `COP_FORTRESS` | `WH_BLUE_GND_FORTRESS` | 5000 | 1524.0 |
| `FOB_JOYCE` | `WH_BLUE_GND_JOYCE` | 9000 | 2743.2 |
| `FOB_WRIGHT` | `WH_BLUE_GND_WRIGHT` | 4000 | 1219.2 |
| `COP_HONAKER` | `WH_BLUE_GND_HONAKER` | 9000 | 2743.2 |
| `FOB_BOSTICK` | `WH_BLUE_GND_BOSTICK` | 5000 | 1524.0 |

Umrechnung: `1 ft = 0.3048 m` exakt.

## Verbindlicher QRF-Materialisierungsvertrag

Motorisierte QRF-Gruppen sind Ground-Fahrzeuggruppen und unterliegen demselben bereits akzeptierten Materialisierungsvertrag wie die Ground-Foundation-/Convoy-Pfade:

```text
MOOSE QRF demand / AUFTRAG / BRIGADE recruitment
-> site-local existing ACCESS zone
-> road-qualified outbound anchor
-> road-axis materialization
-> fixed accepted vehicle spacing
-> all vehicle positions remain inside ACCESS
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

Acceptance 3 verwendet dafür den vorhandenen `OMW_GroundRoadSpawnAdapter`. Für QRF-Fahrzeuggruppen gilt die bereits akzeptierte feste Fahrzeugstaffelung von 18 m. Die Straßenausrichtung wird nicht aus dem beliebigen Incident-Zielpunkt direkt abgeleitet, sondern aus einem per MOOSE qualifizierten Straßenpunkt in Ausrückrichtung.

Die Infantry-Guard ist davon getrennt und bleibt auf ihrem Guard-/PATHLINE-Materialisierungspfad.

## DCS-Diagnose 13.09.2026 – verworfene QRF-ACCESS-Fassung

Der mit Commit `f834e3b5c0416f143585541e2dd17496d1bc3f95` und Acceptance-Bundle

```text
922467FD9803E25CE5C09B8E98BC41F8D9CFAE5668960FED8D8FE53ED89E8690
```

gefahrene DCS-Lauf ist `DIAGNOSTIC_FAIL`.

Jalalabad erreichte nachweislich:

```text
perimeterStarted=true
proximity=true
incident=true
demandCount=1
qrfObserved=nil
```

Der physische QRF-Spawn scheiterte anschließend mit:

```text
[OMW][Ground.RoadSpawnAdapter] outbound road path unavailable entityId=BLUE_GROUND_HUB_JALALABAD_FENTY|QRF
```

Ursache der Implementierung: `QrfRuntime` hatte den Incident-Zielpunkt direkt als `forwardCoordinate` in den RoadSpawnAdapter gegeben. Das entspricht nicht dem bereits akzeptierten Ground-Foundation-Ansatz mit road-qualifiziertem outbound/approach anchor.

Im selben Lauf wurden weitere harte Spawnfehler beobachtet:

```text
COP_FORTRESS:
  road snap exceeds limit
  unit=1
  distanceM=58.300426341027

FOB_BOSTICK:
  road spawn position outside access zone
  unit=1
```

Joyce und Wright materialisierten dagegen beobachtbare `Ground_APC`-QRFs. Das beweist den MOOSE-AUFTRAG-/BRIGADE-Pfad bis zur physischen Materialisierung grundsätzlich, aber nicht die allgemeine sechs-Site-ACCESS-Geometrie.

Der detaillierte Laufbericht liegt unter:

```text
results/2026-09-13-production-base-acceptance3-qrf-access-dcs-run.md
```

## RED-Testfixtures und physische Intrusion

Die sechs late-activated Gruppen bleiben reine Testfixtures:

```text
BadGuys_A3_FENTY
BadGuys_A3_FORTRESS
BadGuys_A3_JOYCE
BadGuys_A3_WRIGHT
BadGuys_A3_HONAKER
BadGuys_A3_BOSTICK
```

Sie sind keine produktive RED-ORBAT und kein späteres RED-C2-Modell. Nach erfolgreicher Six-Guard-Regression aktiviert der Harness die vorhandenen Fixtures und routet sie physisch mit MOOSE `CONTROLLABLE:RouteGroundTo(...)` auf einen Punkt bei 65 % des jeweiligen Alarmradius. Es gibt keinen Teleport und keine `.miz`-Mutation.

## MOOSE-first-Pfad

```text
Alarm center
-> MOOSE ZONE_RADIUS
-> MOOSE OPSZONE
-> OMW_FobThreatOpsZoneAdapter
-> OMW_FireSupStratResupply_PerimeterBridge
-> PROXIMITY_INTRUSION
-> InstallationIncidentRuntime
-> OMW_GroundInstallationAttackIncident
-> InstallationIncidentBridge
-> Base
-> local QRF demand
-> MOOSE AUFTRAG / LEGION / BRIGADE recruitment
-> OMW_GroundRoadSpawnAdapter at site ACCESS
-> MOOSE mission execution
```

Für Jalalabad kommt nur die Mittelpunktauflösung der vorhandenen MOOSE-Zone hinzu. Es wird keine native DCS-Zonensuche und kein paralleler Recruitment-/Mission-Lifecycle eingeführt.

## PASS-Kriterium

Der nächste Acceptance-3-Lauf muss mindestens nachweisen:

```text
6/6 Guards regression condition satisfied
6/6 owner-defined MOOSE alarm perimeters started
Jalalabad runtime perimeter = 8000 ft / 2438.4 m
6/6 PROXIMITY_INTRUSION evidence observed
6/6 authoritative installation incidents observed
6/6 exactly one initial QRF demand
6/6 local Ground_APC QRF mission observed
6/6 QRF initial materialization inside the correct site ACCESS zone
6/6 accepted road-aligned GroundRoadSpawnAdapter path without spawn error
6/6 local QRF physical progress >=25 m toward the incident coordinate
```

Ein QRF-Spawn im FOB/COP/Warehouse-Bereich außerhalb des vorgesehenen ACCESS-Übergabepunkts ist unabhängig vom übrigen Lauf ein harter FAIL.

Ein Build allein ist kein PASS. `VALIDATED` beziehungsweise `ACCEPTED_TECHNICAL_BASELINE` darf erst nach dem dokumentierten realen DCS-Lauf und dessen exakter Provenienz vergeben werden.

## Aktueller Stand

```text
old Guard-only alarm correlation: REJECTED
previous QRF warehouse/FOB materialization: REJECTED
f834e3b5 QRF ACCESS DCS run: DIAGNOSTIC_FAIL
Jalalabad alarm radius: OWNER-DEFINED 8000 ft / 2438.4 m
Jalalabad existing ME zone: center source only; existing 6000-ft geometry insufficient
five other centers: existing MOOSE Warehouse/BRIGADE coordinates
QRF vehicle materialization: site ACCESS + accepted road-aligned adapter
corrected harness/builders: STAGED
local build/hash verification: PENDING
real DCS Acceptance-3 rerun: PENDING
validated_in_dcs: false
```
