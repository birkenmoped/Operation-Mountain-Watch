---
document_id: OMW-FIRE-SUPPORT-GATE5B-SIX-SITE-PERIMETER-RUNTIME-ACCEPTANCE-1
status: PLANNED
document_class: ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - Gate-5B six-site runtime alarm-perimeter DCS acceptance procedure
  - physical OPSZONE intrusion to installation-incident evidence path
  - exactly-one initial QRF-demand observation for the alarm trigger path
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Gate 5B – Six-Site Perimeter Runtime Acceptance 1

## Ziel

Diese Acceptance prueft den noch offenen Gate-5B-Vertrag isoliert vom bereits in Gate 4 akzeptierten QRF-Ausfuehrungs-Lifecycle:

```text
persistent site Guard physically present
-> approved installation anchor + approved radius
-> runtime MOOSE ZONE_RADIUS
-> MOOSE OPSZONE
-> physical RED ground intrusion
-> OPSZONE Attacked
-> PROXIMITY_INTRUSION evidence
-> authoritative OMW_GroundInstallationAttackIncident
-> exactly one initial QRF demand
```

Der Test bewertet **nicht** QRF-Materialisierung, QRF-Zielbindung, QRF-Bewegung, QRF-Kampf oder QRF-Rueckkehr. Dafuer bleibt Production Base Acceptance 4 / A4-8 die aktuelle akzeptierte technische Baseline.

## Verbindliche Six-Site-Geometrie

Die vom Projektinhaber am 14.09.2026 bestaetigten Werte werden unveraendert verwendet:

```text
JALALABAD_FENTY   2438.4 m   8000 ft
COP_FORTRESS      1524.0 m   5000 ft
FOB_JOYCE         2743.2 m   9000 ft
FOB_WRIGHT        1219.2 m   4000 ft
COP_HONAKER       2743.2 m   9000 ft
FOB_BOSTICK       1524.0 m   5000 ft
```

Anchor-Vertrag:

```text
JALALABAD_FENTY
-> OMW_BLUE_OBJECTIVE_JALALABAD_AIRPORT center
-> ausdrueckliche Airfield-Ausnahme von der Warehouse-Regel

COP_FORTRESS -> WH_BLUE_GND_FORTRESS
FOB_JOYCE    -> WH_BLUE_GND_JOYCE
FOB_WRIGHT   -> WH_BLUE_GND_WRIGHT
COP_HONAKER  -> WH_BLUE_GND_HONAKER
FOB_BOSTICK  -> WH_BLUE_GND_BOSTICK
```

Die Jalalabad-Quellzone liefert nur den Mittelpunkt. Der Alarmperimeter wird weiterhin als **neue Runtime-`ZONE_RADIUS` mit 2438.4 m** erzeugt; der Radius der vorhandenen Quellzone wird nicht als Security-Perimeter uebernommen.

## MOOSE-First / gepinnter Source

Pinned MOOSE:

```text
release: 2.9.18
commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Im tatsaechlich gepinnten `Moose.lua` fuer diesen Test erneut geprueft:

```text
ZONE_RADIUS:New(ZoneName, Vec2, Radius, DoNotRegisterZone)
OPSZONE:New(Zone, CoalitionOwner)
OPSZONE:SetUnitCategories(...)
OPSZONE:SetCaptureThreatlevel(...)
OPSZONE:SetCaptureNunits(...)
OPSZONE:GetScannedGroupSet()
OPSZONE:Start()
OPSZONE:Stop()
OPSZONE OnAfterAttacked / OnAfterDefeated / OnAfterEvaluated FSM callbacks
COORDINATE:GetIntermediateCoordinate(ToCoordinate, FractionOrDistance)
CONTROLLABLE:RouteGroundTo(ToCoordinate, Speed, Formation, DelaySeconds, ...)
```

Der gepinnte `OPSZONE`-Source erzeugt `Attacked` fuer eine BLUE-eigene Zone, wenn BLUE Ground Units in der Zone vorhanden sind und RED Ground Units die qualifizierte Zone betreten. Deshalb startet die Acceptance zuerst die bereits vorhandene persistent-site Guard-Funktion und startet die Perimeter erst, wenn alle sechs Guards physisch materialisiert sind.

Der Test setzt **kein eigenes `updateSeconds`**. Damit wird der aktuelle Produktions-/MOOSE-Default des Perimeterpfads getestet und nicht fuer einen schnelleren PASS manipuliert.

## Reuse-Gate

Wiederverwendet werden ausschliesslich vorhandene Produktionspfade:

```text
OMW_FireSupStratResupply_SiteRegistry.lua
OMW_FireSupStratResupply_Runtime.lua
OMW_FireSupStratResupply_PerimeterRuntime.lua
OMW_FireSupStratResupply_PerimeterBridge.lua
OMW_FobThreatOpsZoneAdapter.lua
OMW_FireSupStratResupply_InstallationIncidentRuntime.lua
OMW_GroundInstallationAttackIncident.lua
OMW_FireSupStratResupply_InstallationIncidentBridge.lua
OMW_FireSupStratResupply_Base.lua
```

Keine zweite Detection-, Incident-, Demand- oder QRF-Autoritaet wird im Acceptance-Code eingefuehrt.

## Physischer Teststimulus

Die bereits vorhandenen RED-Fixture-Gruppen werden ausschliesslich als physischer Teststimulus verwendet:

```text
BadGuys_A3_FENTY
BadGuys_A3_FORTRESS
BadGuys_A3_JOYCE
BadGuys_A3_WRIGHT
BadGuys_A3_HONAKER
BadGuys_A3_BOSTICK
```

Nach dem Guard-/Perimeter-Gate werden sie aktiviert und mit dem source-geprueften MOOSE-`CONTROLLABLE:RouteGroundTo(...)` physisch zu einem Punkt innerhalb des jeweiligen Alarmradius gefahren.

Der Zielpunkt wird vom **Perimeter-Anchor nach aussen** auf 65 Prozent des Radius gesetzt:

```text
anchor:GetIntermediateCoordinate(fixtureStart, radiusM * 0.65)
```

Damit ist der Zielpunkt per Konstruktion innerhalb des Runtime-Perimeters. Es gibt keinen Teleport und keine direkte Evidence-Injektion.

## PASS-Kriterien

PASS nur wenn fuer **alle sechs Sites** gilt:

```text
1. persistenter Guard wurde physisch materialisiert und lebt;
2. Guard befindet sich beim Perimeter-Start innerhalb des Runtime-Perimeters;
3. PerimeterRuntime hat fuer die Site eine Security-Zone erzeugt;
4. die reale Runtime-Zone meldet den genehmigten Radius (Toleranz 0.5 m);
5. RED-Fixture wurde physisch aktiviert und befindet sich beobachtet innerhalb des Runtime-Perimeters;
6. der autoritative Installation-Incident enthaelt PROXIMITY_INTRUSION;
7. der zugehoerige Base-Incident existiert;
8. der Base-Incident besitzt exakt einen Demand;
9. dieser Demand ist QRF / INSTALLATION_ATTACK_INITIAL_QRF;
10. cancelWhenIncidentClosed ist fuer diesen QRF-Demand false.
```

Der Test darf fuer PASS **nicht** verlangen, dass eine QRF physisch materialisiert oder einen Gegner bekaempft. QRF-Ausfuehrung gehoert nicht zu Gate 5B Acceptance 1.

## Harte Exclusions

```text
- keine Mission-Editor-Alarmzone;
- keine ACCESS-Zone als Perimeter-Anchor oder Radiusquelle;
- keine direkte ReportInstallationEvidence()-Injektion;
- kein Acceptance-eigenes Incident-Close;
- kein ExpireDemand();
- kein Acceptance-eigenes QRF-Cancel/Release;
- keine QRF-Zielauswahl im Harness;
- kein GROUNDATTACK;
- kein PATROLZONE/HuntingPatrol;
- keine Aenderung der bereits akzeptierten A4-8-QRF-Semantik;
- keine MIZ-Mutation.
```

Das Auftreten oder die physische Ausfuehrung eines durch den echten Produktionspfad erzeugten QRF-Auftrags ist fuer diesen Test weder PASS- noch FAIL-Kriterium.

## Timeout / Diagnose

```text
Telemetry: 20 s
Perimeter settle before RED release: 5 s
Total timeout: 900 s
```

Der relativ lange Timeout beruecksichtigt den aktuellen MOOSE-OPSZONE-Statuszyklus. Der Acceptance-Code verkuerzt den produktiven Update-Zyklus bewusst nicht.

Pro Site wird geloggt:

```text
anchorSource
runtime radius
perimeterStarted
guardObserved
guardInside
fixtureAlive
fixtureInside
PROXIMITY_INTRUSION
sourceIncident
baseIncident
demandCount
qrfDemand contract
```

## Builder

```text
tools/build-fire-support-strategic-resupply-gate5b-perimeter-runtime.ps1
```

Output:

```text
mission/tests/fire-support-strategic-resupply-gate5b-six-site-perimeter-runtime/dist/OMW_FireSupStratResupply_Gate5B_Perimeter_Runtime.lua
```

Der Builder erzeugt zuerst das aktuelle Production-Base-Bundle und haengt anschliessend nur den Acceptance-Harness an. Er prueft die aktuellen Runtime-/QRF-/Perimeter-Schemata und blockiert im Acceptance-Source insbesondere direkte Evidence-Injektion, Incident-Close, `ExpireDemand`, historische `PATROL_TEST`-Abhaengigkeiten und alte `SetEngageDetected`-Semantik.

## Statusgrenze

Vor einem realen Owner-local Build und anschliessendem DCS-Lauf gilt:

```text
Source/Builder: STAGED
DCS: NOT VALIDATED
Acceptance: PLANNED
```

Ein erfolgreicher Build beweist nur Bundle-/Hash-Konsistenz. `ACCEPTED_TECHNICAL_BASELINE` darf erst nach realem DCS-Lauf mit dokumentierter Mission-, Bundle-, DCS- und MOOSE-Provenienz gesetzt werden.
