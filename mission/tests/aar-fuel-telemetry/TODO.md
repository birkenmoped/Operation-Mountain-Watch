---
document_id: OMW-TEST-AAR-FUEL-CALIBRATION-TODO
status: DRAFT
document_class: WORKLIST
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local worklist for the current AAR fuel, speed, LRC transit and final routing workstream
  - current target state, completed findings and remaining production-acceptance steps
not_authoritative_for:
  - final production validation before Acceptance 7 is run in DCS
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/aar-fuel-telemetry-calibration
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# AAR Fuel / Speed / LRC – Final Acceptance Worklist

## 1. Workstream

```text
Branch: agent/aar-fuel-telemetry-calibration
Calibration source commit: 40965420d4c6dea7a6b0fa27b4e3cd80d2a2b26a
Production calibration promotion: 89fb472109a725d57184b476ad012014d2ae45cf
Final combined acceptance target: AAR-PRODUCTION-FINAL-ACCEPTANCE-7
```

ChatGPT verändert keine `.miz`. Mission-Editor-Änderungen bleiben beim Projektinhaber.

## 2. Bereits bestätigte Baseline

Candidate 5 bestätigte im DCS-Lauf vom 16.08.2026:

```text
SPAWN initial speed: 480 kt
Transit route speed: 300 kt
MANAS inbound/outbound: FL340/FL350
AL_UDEID inbound/outbound: FL350/FL340
exact track mission altitude
natural FIR ingress/egress
external handoff
six-point fuel telemetry
```

Provenienz:

```text
Source commit: 40965420d4c6dea7a6b0fa27b4e3cd80d2a2b26a
Test ID: AAR-FUEL-TELEMETRY-5
Mission: OMW_Template_v10_AirOps_rdy.miz
Mission SHA-256: 9dbff62a28e858d6eaf85d9037399dd591dd64edeccbe39bc74ecc63c43b6ca3
Bundle SHA-256: dd2386bd5bb2b0d2f89ac4e225a2e76ab171df1008f1d46eda16a9757c592a94
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Result: PASS
```

Acceptance 6 bestätigte anschließend den Produktions-Lifecycle, zeigte aber zwei verbleibende Designabweichungen:

```text
1. Tanker beginnen nach dem FIR-Ingress zu früh mit dem Sinkflug.
2. LISA läuft noch über MANAS / PINAX statt über die gewünschte Südgruppe.
```

## 3. Finaler Owner-Entscheid 16.08.2026

### LISA

```text
Profile: FAST
Availability: RESERVE
Source Domain: AL_UDEID
FIR Fix: DAVER
Initial Fuel contract: 79.4558 %
FuelLow candidate: 38 %
```

Der Projektinhaber hat den physischen Startfuel des LISA-Templates im Mission Editor bereits auf die südliche Baseline angepasst.

### 60-NM Late Approach

Verbindliche Interpretation:

```text
60 NM vor Eintritt in den eigentlichen AAR-Track
entlang der realen Inbound-Geometrie
nicht 60 NM vor dem FIR-Fix
nicht als Radius um den Control Point
```

Zielpfad:

```text
External Spawn
-> FIR Fix @ inbound LRC altitude
-> 60-NM Late Approach @ inbound LRC altitude
-> descent on final inbound leg
-> exact track altitude
-> track
```

Outbound bleibt:

```text
track
-> climb toward outbound LRC altitude
-> FIR egress
-> external handoff
```

## 4. MOOSE-first Umsetzung

Pinned source review bestätigt öffentliche APIs:

```text
FLIGHTGROUP:AddWaypoint(Coordinate, Speed, AfterWaypointWithID, Altitude, Updateroute)
AUFTRAG:SetMissionIngressCoord(Coordinate, Altitude, Speed)
AUFTRAG:SetMissionAltitude(Altitude)
AUFTRAG:SetMissionEgressCoord(Coordinate, Altitude, Speed)
COORDINATE:GetIntermediateCoordinate(ToCoordinate, Fraction)
```

Finaler Candidate:

```text
FLIGHTGROUP waypoint = real FIR fix at inbound LRC altitude
AUFTRAG ingress      = calculated point 60 NM before track at inbound LRC altitude
mission waypoint     = exact track altitude
```

Kein UID-Hack, kein Timer-basiertes Routing, keine Native-DCS-Parallellogik, keine Teleports.

## 5. Fuel-Vertrag für Acceptance 7

```text
Initial Fuel:
MANAS:      91.4067 %
AL_UDEID:   79.4558 %

FuelLow:
NELSON:     24 %
PATTY:      26 %
LISA:       38 %
MOE:        31 %
MILHOUSE:   36 %
KRUSTY:     36 %
```

LISA=38 % ist die konservative Neuberechnung für die südliche Source Domain. Die frühere LISA-Messung 17.7909 % `TRACK_DEPARTURE -> EXTERNAL_HANDOFF` gehört zur alten MANAS/PINAX-Geometrie und darf nicht als südlicher Messwert ausgegeben werden.

## 6. Acceptance-7-Scope

Der letzte geplante DCS-Abnahmelauf muss bestätigen:

```text
- 4 STANDARD tracks initial active
- LISA/MOE initial inactive
- 480-kt spawn / 300-kt route
- directional LRC FL340/FL350
- real FIR ingress retained
- high LRC altitude retained before 60-NM late approach
- 60-NM late-approach geometry
- exact track altitude
- LISA demand from AL_UDEID via DAVER
- MOE demand from MANAS via PINAX
- scheduled MILHOUSE relief
- NELSON FuelLow relief
- PATTY loss/replacement
- natural FIR egress
- external handoff
- CampaignState exact-once accounting
- final steady state 4 STANDARD / 0 RESERVE
```

Der Acceptance-Harness darf test-only FuelLow- und Loss-Injektionen verwenden. Diese gehören **nicht** in das anschließend zu erstellende Missionsgrundgerüst.

## 7. Nach Acceptance-7-PASS

Erst nach realem, vollständig dokumentiertem PASS:

```text
1. Acceptance-Provenienz dokumentieren.
2. docs/moose/VERIFIED-METHODS.md für den neuen Routing-Scope aktualisieren.
3. POST-MERGE-FINDINGS/Acceptance-Dokumentation reconciliieren.
4. endgültiges AAR-Missionsgrundgerüst erstellen:
   - NELSON/PATTY/MILHOUSE/KRUSTY kontinuierlich;
   - automatische geplante Ablösung;
   - reale FuelLow-Ablösung;
   - reale Loss-Replacement-Logik;
   - LISA/MOE standardmäßig inaktiv;
   - Reserve jederzeit über MissionDemand anforderbar;
   - keine test-only Loss-/FuelLow-Auslösung.
```

`VALIDATED` bleibt bis zum dokumentierten Acceptance-7-PASS gesperrt.