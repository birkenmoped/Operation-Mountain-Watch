---
document_id: OMW-MOOSE-VERIFIED-METHODS-AAR-ACCEPTANCE-7
status: BINDING
document_class: TECHNICAL_EVIDENCE_REGISTER_SUPPLEMENT
owning_policy: OMW-GOV-001
authoritative_for:
  - method-level MOOSE evidence from AAR Production Final Acceptance 7
  - exact provenance and validation boundary of the corrected FIR/late-approach routing path
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/aar-fuel-telemetry-calibration
source_commit: 7d55a1383cbf3f52ea776d7354b37dbe5a920466
validated_in_dcs: true
---

# Verifizierte MOOSE-Methoden – AAR Acceptance 7

Dieses Supplement ergänzt `VERIFIED-METHODS.md` um die nach dessen letztem AAR-Eintrag praktisch bestätigten Methoden des korrigierten Acceptance-7-Pfads. Es gilt ausschließlich für die unten dokumentierte Provenienz.

## Provenienz

```text
Testdatum: 2026-08-16
Branch: agent/aar-fuel-telemetry-calibration
Accepted source commit: 7d55a1383cbf3f52ea776d7354b37dbe5a920466
Builder/Test-ID: AAR-PRODUCTION-FINAL-ACCEPTANCE-7
Mission artifact: OMW_Template_v10_AirOps_rdy(5).miz
Mission SHA-256: 16d0a9b26a648c2dbcbd727b41afc93a28648620f8e2f8c357a770751e48cca5
Bundle SHA-256: 3338d0baa67593be6bff9c22b3ed72b3a8e837cd00820d060eefe920faf91ee2
Controller SHA-256: 547f0336b954b116e43e8a09ca0f001d893ea81d2394025891be5ff078388438
dcs.log SHA-256: 3157bc87a373f5b55262bf96c6be1cf52f06686bfa6daefd576fc23f88d9e320
debrief.log SHA-256: 66c4fed82e91045ef4ffbc08989dce6cfabf97375ea7faf225e2601ad826a0d4
DCS: 2.9.28.26385 MT
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Result: PASS
```

## Praktisch bestätigte Methoden und Pfade

| Methode / Pfad | Status | Belegter Acceptance-7-Umfang |
|---|---|---|
| `SPAWN:InitCallSign(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | stabile Sortie-Callsign-Familien im AAR-Lifecycle |
| `SPAWN:InitHeading(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | initiale Ausrichtung vom External Spawn auf den FIR-Ingress |
| `SPAWN:InitSpeedKnots(480)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | plausibler In-Air-Materialisierungszustand der KC-135 im dokumentierten Kalibrierungsscope |
| `SPAWN:SpawnFromCoordinate(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | External-Spawn-Materialisierung für MANAS-/AL_UDEID-Domänen |
| `FLIGHTGROUP:New(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | physischer AAR-Fluggruppen-Lifecycle |
| `FLIGHTGROUP:AddWaypoint(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | expliziter FIR-Ingress, danach 60-NM-Late-Approach sowie bestehender External-Handoff-Pfad |
| `FLIGHTGROUP:AddMission(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Tanker-AUFTRAG wird erst nach bestätigter 60-NM-Waypoint-Passage hinzugefügt |
| `FLIGHTGROUP / OPSGROUP PassingWaypoint` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | reale Reihenfolge FIR-Waypoint vor Late-Approach-Waypoint praktisch bestätigt |
| `FLIGHTGROUP:OnAfterPassingWaypoint(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | UID-basierte Zuordnung der beiden vom öffentlichen `AddWaypoint` zurückgegebenen Waypoints; kein Timer-/Internal-Hack |
| `FLIGHTGROUP:GetCoordinate()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Distanz-/Höhen- und Track-Entry-Prüfung im Acceptance-Harness |
| `FLIGHTGROUP:SetFuelLowThreshold(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | per-Area FuelLow-Schwellen im realen Lifecycle |
| `FLIGHTGROUP:SetFuelLowRTB(false)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | OMW behält den kontrollierten Relief-/Egress-Lifecycle statt eines parallelen automatischen RTB-Pfads |
| `FLIGHTGROUP FuelLow callback` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | NELSON Acceptance-Trigger und zusätzlicher natürlicher KRUSTY-FuelLow nach `RESULT PASS` führten zum vorgesehenen Relief/Egress-Pfad |
| `FLIGHTGROUP Dead / OnAfterDead` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | PATTY-Testverlust lief über den realen Loss-/Replacement-Pfad ohne Aircraft-Recredit |
| `AUFTRAG:NewTANKER(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Tankeraufträge für STANDARD- und MissionDemand-RESERVE-Tracks |
| `AUFTRAG:SetMissionAltitude(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | exakte profilabhängige Track-Höhe praktisch bestätigt |
| `AUFTRAG:SetMissionEgressCoord(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | FIR-Egress auf directional outbound LRC altitude vor External Handoff |
| `AUFTRAG:Cancel()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Scheduled Relief, FuelLow und Reserve-Ende führen in den bestätigten Egress-Pfad |
| `COORDINATE:GetIntermediateCoordinate(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | 60-NM-Late-Approach entlang FIR->Track-Geometrie; Harness bestätigte 60.0 NM |
| `COORDINATE:Get2DDistance(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | FIR-, Late-Approach-, Track- und Handoff-Geometrie |
| `COORDINATE:HeadingTo(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Initialheading zum FIR-Waypoint |
| `UNIT:GetSTN()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | materialisierte Link-16-STN gelesen; OMW setzt keine eigene `InitSTN()`-Parallellogik |
| `UNIT:Explode(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` / `TEST_ONLY` | absichtliche PATTY-Verlustinjektion zur Prüfung des realen Dead/OnAfterDead-Pfads; nicht produktiv verwenden |
| `SCHEDULER:New(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Dispatcher, Station-Monitoring und Acceptance-Koordination; kein Timer-basiertes Routing des Late-Approach |

## Wichtige Negativgrenzen

```text
AUFTRAG:SetMissionIngressCoord(lateApproachCoord, ...)
= REJECTED for the final inbound path
```

Der erste Acceptance-7-Lauf zeigte, dass ein früh hinzugefügter AUFTRAG den davor gesetzten FIR-Waypoint umgehen konnte. Der akzeptierte Pfad fügt den AUFTRAG deshalb erst nach realer Passage des 60-NM-Waypoints hinzu.

Nicht nachgewiesen:

```text
SPAWN:InitFuel(...)
```

Die physische Initial-Fuel-Menge bleibt Mission-Editor-Templatekonfiguration.

## Belegter Routing-/Lifecycle-Scope

```text
Inbound:
External Spawn -> FIR Ingress -> 60-NM Late Approach -> Track
high LRC altitude through 60-NM point
exact track altitude after AUFTRAG addition

Outbound:
Track departure/abort -> FIR Egress -> External Handoff/Despawn
outbound LRC altitude from mission departure

STANDARD continuous:
NELSON / PATTY / MILHOUSE / KRUSTY

RESERVE MissionDemand-only:
LISA / MOE
```

Acceptance 7 bestätigte außerdem Scheduled Relief, FuelLow Relief, Reserve open/close, Loss/Replacement, CampaignState exact-once settlement und finalen steady state `4 STANDARD / 0 RESERVE`.

Test-only künstliche FuelLow-/Loss-Auslösungen und Acceptance-Zeitbeschleunigung sind keine Produktionsfunktionen.
