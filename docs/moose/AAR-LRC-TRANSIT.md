---
document_id: OMW-MOOSE-AAR-LRC-TRANSIT
status: ACCEPTED_TECHNICAL_BASELINE
document_class: MOOSE_TECHNICAL_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - accepted AAR LRC transit, late-approach and fuel-calibration contract
  - validated MOOSE methods used by the corrected Acceptance-7 routing path
  - DCS evidence boundary for spawn, transit, track altitude, FIR ordering and fuel planning
  - explicit record of failed Candidate-3/Candidate-4/initial-Acceptance-7 assumptions
not_authoritative_for:
  - main runtime implementation until the feature branch is merged
  - exact KC-135R performance data outside the documented OMW calibration model
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/aar-fuel-telemetry-calibration
source_commit: 7d55a1383cbf3f52ea776d7354b37dbe5a920466
acceptance_branch: agent/aar-fuel-telemetry-calibration
acceptance_commit: 7d55a1383cbf3f52ea776d7354b37dbe5a920466
acceptance_mission: OMW_Template_v10_AirOps_rdy(5).miz
acceptance_mission_sha256: 16d0a9b26a648c2dbcbd727b41afc93a28648620f8e2f8c357a770751e48cca5
dcs_version: 2.9.28.26385 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
validated_in_dcs: true
---

# MOOSE – AAR LRC Transit Calibration

## 1. Acceptance-Provenienz

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
Result: PASS

MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Die vollständige Acceptance mit Fuel-Rechnung, Timing und Produktionsgrenze steht zusätzlich in [`mission/tests/aar-production-integration/ACCEPTANCE-7.md`](../../mission/tests/aar-production-integration/ACCEPTANCE-7.md).

## 2. Geschwindigkeitsvertrag

```text
SPAWN:InitSpeedKnots(480) = initialer In-Air-Materialisierungszustand
MOOSE route speed 300 kt  = Transit-Routenkommando
track speed               = area-/profile-spezifischer Missionswert
```

`480 kt` ist weder ein permanenter KIAS- noch Groundspeed-Befehl. Der Wert dient nur einem plausiblen Energiezustand bei In-Air-Materialisierung in großer Höhe. Danach übernimmt das normale MOOSE-/DCS-Routing.

## 3. Directional LRC

```text
MANAS -> Afghanistan:      FL340
Afghanistan -> MANAS:      FL350
AL_UDEID -> Afghanistan:   FL350
Afghanistan -> AL_UDEID:   FL340
```

Kein routinemäßiger fuel-/weight-basierter Step-Climb.

## 4. Verbindliche Inbound-Sequenz

Owner-Bestätigung und Acceptance-7-Vertrag:

```text
SPAWNPUNKT
-> FIR INGRESS-PUNKT
-> 60-NM-LATE-APPROACH-PUNKT
-> TRACK-START-PUNKT
-> AAR TRACK
```

Die inbound LRC-/Transferhöhe bleibt vom Spawn bis einschließlich des 60-NM-Late-Approach-Punktes erhalten. Erst nach dessen realer Passage wird der Tanker-AUFTRAG hinzugefügt; damit beginnt erst danach die Transition auf die exakte Track-Höhe.

### 4.1 Korrigierter MOOSE-first-Pfad

Der akzeptierte Pfad verwendet ausschließlich öffentliche, im gepinnten `Moose.lua` geprüfte MOOSE-Methoden/FSMs:

```text
External Spawn
-> FLIGHTGROUP:AddWaypoint(FIR fix, inbound LRC altitude)
-> FLIGHTGROUP:AddWaypoint(60-NM late approach, inbound LRC altitude)
-> OnAfterPassingWaypoint confirms FIR waypoint UID
-> OnAfterPassingWaypoint confirms late-approach waypoint UID
-> only now FLIGHTGROUP:AddMission(tanker AUFTRAG)
-> descent / exact AAR track altitude
-> AAR track
```

`AUFTRAG:SetMissionIngressCoord(...)` wird im akzeptierten Inbound-Pfad bewusst nicht verwendet. Das verhindert, dass eine bereits erzeugte AUFTRAG-Route den vorgeschalteten FIR-Wegpunkt ersetzt oder umgeht.

Der Late-Approach-Punkt wird entlang der realen geraden FIR-Fix->Track-Geometrie mit `COORDINATE:GetIntermediateCoordinate(...)` so berechnet, dass exakt 60 NM bis zum Track verbleiben.

### 4.2 Acceptance-7 Runtime-Geometrie

| Area | FIR->Late Approach | Late Approach->Track | FIR->Track gesamt |
|---|---:|---:|---:|
| NELSON | 63.7 NM | 60.0 NM | 123.7 NM |
| PATTY | 150.8 NM | 60.0 NM | 210.8 NM |
| MILHOUSE | 175.2 NM | 60.0 NM | 235.2 NM |
| KRUSTY | 197.5 NM | 60.0 NM | 257.5 NM |
| LISA | 225.6 NM | 60.0 NM | 285.6 NM |
| MOE | 165.2 NM | 60.0 NM | 225.2 NM |

LISA wurde im erfolgreichen Lauf nach DAVER physisch bestätigt. Der Harness protokollierte unter anderem `HIGH_HOLD_PASS` bei 84.6 NM Restdistanz und 35,000 ft sowie `LATE_APPROACH_PASSED` bei 60.0 NM.

## 5. Rückflug / Egress

Der bereits funktionierende Rückflugvertrag blieb erhalten:

```text
ABBRUCHPUNKT auf TRACK
-> AUFTRAG:SetMissionEgressCoord(FIR egress fix, outbound LRC altitude)
-> physical FIR egress passage
-> FLIGHTGROUP:AddWaypoint(external handoff, outbound LRC altitude)
-> external handoff / despawn
```

Die outbound LRC-/Transferhöhe gilt ab Missionsabbruch beziehungsweise Verlassen der Tankermission.

## 6. Track-Höhe

Der gepinnte MOOSE-Source-Review zeigte für den von `NewTANKER` verwendeten ORBIT-Pfad ein Default-Missionshöhenverhalten von 90 Prozent der Orbit-Höhe. OMW setzt daher explizit:

```lua
mission:SetMissionAltitude(profile.altitudeFt)
```

Acceptance 7 bestätigte die exakte Track-Höhe innerhalb der Harness-Toleranz.

## 7. LISA South Domain

Verbindliche Owner-Entscheidung vom 16.08.2026:

```text
LISA
Profile: FAST
Availability: RESERVE
Source Domain: AL_UDEID
FIR Fix: DAVER
Initial Fuel: 79.4558 %
FuelLow: 38 %
```

Die Verschiebung erfolgt wegen der kürzeren sichtbaren Reserve-Reaktionsstrecke, nicht wegen Fuel-Optimierung. Die alte PINAX->LISA-Strecke lag bei etwa 416.8 NM bis zum Track; Acceptance 7 bestätigte DAVER->LISA mit rund 285.6 NM bis zum Track. Die sichtbare Strecke verkürzt sich damit um rund 131 NM. MOE bleibt `MANAS / PINAX`.

## 8. Fuel-Kalibrierung

### 8.1 Grunddaten und virtuelle Source-Strecken

```text
KC-135 max fuel used by OMW model: 90,700 kg
13,000 lb planned landing floor: about 5,896.7 kg = 6.5013 %

MANAS source-base -> External Spawn: 300.005 NM
weighted Test-4 planning rate:       25.98 kg/NM
virtual burn:                         about 7,794 kg = 8.5933 %
initial fuel at External Spawn:       91.4067 %

AL_UDEID source-base -> External Spawn: 746.241 NM
weighted Test-4 planning rate:          24.97 kg/NM
virtual burn:                            about 18,633 kg = 20.5443 %
initial fuel at External Spawn:          79.4558 %
```

Die physische Fuel-Menge bleibt Mission-Editor-Templatekonfiguration. Im gepinnten MOOSE-Stand wurde keine öffentliche `SPAWN:InitFuel(...)`-Methode nachgewiesen.

### 8.2 Candidate-5 gemessener Track-Departure->External-Handoff-Burn

| Area | Burn |
|---|---:|
| NELSON | 5.6753 % |
| PATTY | 9.0161 % |
| LISA, alte MANAS/PINAX-Geometrie | 17.7909 % |
| MOE | 13.4644 % |
| MILHOUSE | 8.1344 % |
| KRUSTY | 8.5073 % |

Der alte LISA-Wert ist ausdrücklich **kein** Messwert für die neue AL_UDEID/DAVER-Geometrie.

### 8.3 45-Minuten-Reserve

| Area | Reserve |
|---|---:|
| NELSON | 9.5482 % |
| PATTY | 7.9209 % |
| LISA | 7.6182 % |
| MOE | 8.4708 % |
| MILHOUSE | 6.6748 % |
| KRUSTY | 6.6384 % |

Für alle sechs Profile liegt die 45-Minuten-Reserve über dem 13,000-lb-Floor und ist damit die kontrollierende Reservekomponente im OMW-Planungsmodell.

### 8.4 FuelLow-Formel

Für direkt kalibrierte Areas:

```text
FuelLow raw =
  measured TRACK_DEPARTURE -> EXTERNAL_HANDOFF burn
+ virtual EXTERNAL_HANDOFF -> source-base burn
+ 45-minute reserve
```

Konservative Rundung auf volle Prozentpunkte:

```text
NELSON:    5.6753 +  8.5933 + 9.5482 = 23.8168 -> 24 %
PATTY:     9.0161 +  8.5933 + 7.9209 = 25.5303 -> 26 %
MOE:      13.4644 +  8.5933 + 8.4708 = 30.5285 -> 31 %
MILHOUSE:  8.1344 + 20.5443 + 6.6748 = 35.3535 -> 36 %
KRUSTY:    8.5073 + 20.5443 + 6.6384 = 35.6900 -> 36 %
```

LISA verwendet 38 %. Dieser Wert ist die akzeptierte konservative Neuberechnung für die südliche Source Domain. Acceptance 7 bestätigte Konfiguration, Routing, Source/FIR-Zuordnung und Lifecycle. Ein separater südlicher `TRACK_DEPARTURE -> EXTERNAL_HANDOFF`-Fuel-Telemetrielauf für LISA wurde nicht durchgeführt; diese Evidenzgrenze bleibt bestehen.

## 9. Lifecycle-Timing

```text
Same-source materialization spacing: >= 60 s
Dispatcher interval:                 5 s
Station monitor interval:            5 s
Planned station cycle:               10,800 s = 3 h
Relief handover ETA arm gate:        300 s = 5 min
FIR passage radius:                  5 NM
Track-entry radius:                  5 NM
External handoff radius:             10 NM
Per-track physical maximum:          1 ACTIVE + 1 RELIEF
```

MANAS und AL_UDEID dürfen parallel materialisieren. Das 5-Minuten-Gate armt Scheduled Relief nur; Stationsbesitz und Radio/TACAN wechseln erst bei realer Track-Ankunft des Reliefs. FuelLow bleibt davon getrennt und ordnet für den outgoing Tanker Immediate Egress an.

## 10. Source-verifizierte und Acceptance-7-validierte MOOSE-Methoden

Für den exakt dokumentierten Acceptance-7-Scope sind folgende Pfade praktisch bestätigt:

```text
SPAWN:InitCallSign(...)
SPAWN:InitHeading(...)
SPAWN:InitSpeedKnots(...)
SPAWN:SpawnFromCoordinate(...)

AUFTRAG:NewTANKER(...)
AUFTRAG:SetMissionAltitude(...)
AUFTRAG:SetMissionEgressCoord(...)
AUFTRAG:Cancel()

FLIGHTGROUP:New(...)
FLIGHTGROUP:AddWaypoint(...)
FLIGHTGROUP:AddMission(...)
FLIGHTGROUP:GetCoordinate()
FLIGHTGROUP:SetFuelLowThreshold(...)
FLIGHTGROUP:SetFuelLowRTB(false)
FLIGHTGROUP / OPSGROUP PassingWaypoint FSM
FLIGHTGROUP OnAfterPassingWaypoint(...)
FLIGHTGROUP FuelLow callback
FLIGHTGROUP Dead / OnAfterDead

COORDINATE:GetIntermediateCoordinate(...)
COORDINATE:Get2DDistance(...)
COORDINATE:HeadingTo(...)

OPSGROUP radio/TACAN on/off paths
OPSGROUP/FLIGHTGROUP Despawn path
SCHEDULER:New(...)
UNIT:GetSTN()
UNIT:Explode(...) [test-only]
```

Nicht nachgewiesen und nicht angenommen:

```text
SPAWN:InitFuel(...)
MIST
native DCS replacement controller
MissionScripting.lua modification
```

## 11. Fehlerhistorie

```text
Candidate 3 late-ingress approach:
REJECTED — ersetzte den FIR-Ingress durch den Late-Approach und verursachte FIR-Routing-Regression.

Candidate 4 FIR restoration:
PASS für beobachtete FIR-Passage.

Candidate 4 UID late-approach adapter:
FAILED — Mission-Waypoint-UID war am gewählten Adapterzeitpunkt nicht verfügbar.

Candidate 5 outbound telemetry:
PASS — sechs Messpunkte pro Track; Grundlage der finalen FuelLow-Rechnung.

Acceptance 6:
PASS für dokumentierten Lifecycle-/Kalibrierungsscope; visueller Frühabstieg blieb offen.

Acceptance 7 commit 00ed8e3:
ABORTED — 60-NM-Höhenübergang funktionierte, FIR-Ingress wurde jedoch umgangen.

Corrected Acceptance 7 commit 7d55a13:
PASS — FIR -> 60-NM -> AUFTRAG-Reihenfolge, High-Hold, exakte Track-Höhe, LISA South Domain und Lifecycle bestätigt.
```

## 12. Produktionsgrenze

Acceptance 7 verwendete test-only Mechanismen für beschleunigtes ausgewähltes Relief, Background-Cycle-Isolation, künstlichen NELSON-FuelLow, absichtlichen PATTY-Verlust über `UNIT:Explode()` und einen in-process Restore-Test. Diese Mechanismen gehören nicht in das endgültige Missionsgrundgerüst.

Produktiv vorgesehen:

```text
STANDARD kontinuierlich:
NELSON / PATTY / MILHOUSE / KRUSTY

RESERVE default inactive, MissionDemand-only:
LISA / MOE

nur reale Runtime-Trigger:
actual FuelLow
normal planned/scheduled relief
actual aircraft loss
MissionDemand open/close
```

Der hier dokumentierte Stand ist für die exakte Acceptance-7-Provenienz validiert. Die Integration in `main` und das anschließend testfrei gebaute produktive Missionsgrundgerüst sind separate Schritte.
