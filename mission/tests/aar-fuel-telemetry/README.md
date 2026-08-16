---
document_id: OMW-TEST-AAR-FUEL-TELEMETRY
status: DRAFT
document_class: TEST_MANIFEST
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local AAR fuel telemetry test scope
  - build and Mission Editor insertion procedure for AAR fuel calibration
  - interpretation boundaries of inbound and outbound fuel measurements
  - branch-local KC-135 spawn/LRC/mission-altitude candidate evaluation
not_authoritative_for:
  - revised production initial fuel values
  - revised FuelLow thresholds
  - production promotion before owner approval and DCS acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by: []
source_branch: agent/aar-fuel-telemetry-calibration
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# AAR Fuel Telemetry Calibration

## Ziel des nächsten Laufs

`AAR-FUEL-TELEMETRY-5` ergänzt die bereits vorliegende Test-4-Inbound-Evidenz um die noch fehlende direkte Outbound-Telemetrie. Für die erste natürliche Sortie aller sechs AAR-Tracks werden folgende Messpunkte erfasst:

```text
SPAWN
FIR INGRESS
TRACK
TRACK DEPARTURE
FIR EGRESS
EXTERNAL HANDOFF
```

Für die finale FuelLow-Berechnung sind insbesondere diese Segmente maßgeblich:

```text
TRACK DEPARTURE -> FIR EGRESS
TRACK DEPARTURE -> EXTERNAL HANDOFF
```

`FuelLow` bleibt als Trigger und Messgrundlage ausgeschlossen. Der Test soll die Rückfluganforderung messen, nicht eine noch zu kalibrierende FuelLow-Schwelle bestätigen.

## Unveränderter Kandidatenstand

Der generierte Testbundle erhält weiterhin ausschließlich die bereits festgelegten branch-lokalen Kandidaten:

```text
In-air SPAWN initialization: 480 kt
Transit route speed:          300 kt
MANAS -> Afghanistan:         FL340
Afghanistan -> MANAS:         FL350
AL_UDEID -> Afghanistan:      FL350
Afghanistan -> AL_UDEID:      FL340
Mission/track altitude:       exact profile altitude
FIR routing:                  EGPAN / PINAX / DAVER preserved
```

Die produktive Datei `scripts/air-operations/OMW_AAR_Controller.lua` wird vom Builder nicht verändert.

Der optionale 60-NM-Late-Approach-Versuch aus Candidate 4 ist für diesen Test deaktiviert. Er ist laut Worklist kein Erfordernis der Fuel-Kalibrierung und sein fehlgeschlagener Timing-/Waypoint-Adapter wird nicht weiter per Timer-Tuning verfolgt.

## Outbound-Auslösung

Ein normaler produktiver STANDARD-Zyklus würde den Test unnötig um die dreistündige Station-Time und Relief-Transitzeit verlängern. Candidate 5 fügt deshalb **nur im generierten Testbundle** einen Diagnose-Hook `Controller.TestForceEgress(...)` ein.

Dieser Hook implementiert keinen eigenen DCS-/Routing-Lifecycle. Er delegiert direkt an die bereits vorhandene Controller-Funktion `cancelToEgress(...)`. Damit bleibt der bestehende Ablauf erhalten:

```text
AUFTRAG mission Cancel
-> MOOSE mission egress
-> EGPAN / PINAX / DAVER
-> existing FLIGHTGROUP external-handoff waypoint
-> existing CampaignState adapter OnHandoff
-> existing off-map despawn
```

Die Auslösung erfolgt unmittelbar nach dem TRACK-Sample. `TRACK_DEPARTURE` wird direkt nach erfolgreicher Egress-Anordnung erfasst.

## External-Handoff-Messung

Der produktive Controller ruft `strategicAdapter:OnHandoff(...)` auf, solange der Runtime/FLIGHTGROUP noch lebt, und despawnt erst danach. Der Harness dekoriert deshalb im Test ausschließlich die konkrete Adapterinstanz und erfasst dort `EXTERNAL_HANDOFF`, bevor die unveränderte originale `OnHandoff`-Funktion aufgerufen wird.

Damit wird kein zweiter Settlement- oder Handoff-Pfad eingeführt.

## MOOSE-First-Grenze

Gepinnter Stand:

```text
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Die Telemetrie verwendet weiterhin die bereits im Projekt geprüften öffentlichen MOOSE-Mechanismen:

```text
SPAWN:InitSpeedKnots(...)
AUFTRAG:SetMissionIngressCoord(...)
AUFTRAG:SetMissionEgressCoord(...)
AUFTRAG:SetMissionAltitude(...)
UNIT:GetFuel()
UNIT:GetCurrentFuelKgs()
UNIT:GetFuelMassMax()
FLIGHTGROUP:GetCoordinate()
COORDINATE:Get2DDistance(...)
SCHEDULER:New(...)
```

Für Candidate 5 wird keine neue Native-DCS-Funktion und keine MOOSE-Parallelimplementierung eingeführt.

## Tracks

```text
NELSON    FAST  MANAS     EGPAN  STANDARD
PATTY     SLOW  MANAS     EGPAN  STANDARD
LISA      FAST  MANAS     PINAX  RESERVE
MOE       FAST  MANAS     PINAX  RESERVE
MILHOUSE  SLOW  AL_UDEID  DAVER  STANDARD
KRUSTY    SLOW  AL_UDEID  DAVER  STANDARD
```

LISA und MOE werden für den Test weiterhin explizit über MissionDemand geöffnet.

## Erfasste Daten

Jeder Sample-Logeintrag enthält mindestens:

```text
area
profile
source
runtime
point
fuelRel
fuelPct
fuelKg
maxFuelKg
time
distanceToReferenceNm
```

Für den Outbound werden zusätzlich reale, per 1-s-Poll aufsummierte Wegstrecken und Zeiten protokolliert:

```text
pathDepartureToEgressNm
pathEgressToHandoffNm
pathDepartureToHandoffNm
elapsedDepartureToEgressSec
elapsedEgressToHandoffSec
elapsedDepartureToHandoffSec
burnDepartureToEgressPct
burnEgressToHandoffPct
burnDepartureToHandoffPct
```

Die Pfadwerte sind Diagnosewerte aus diskreten Positionssamples. Die Fuel-Samples und die Controller-FIR-/Handoff-Ereignisse bleiben die primären Messgrenzen.

## Build

Auf dem Testbranch:

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch
git switch agent/aar-fuel-telemetry-calibration
git pull --ff-only origin agent/aar-fuel-telemetry-calibration
.\tools\build-aar-fuel-telemetry.ps1
```

Der Builder erzeugt:

```text
mission\tests\aar-fuel-telemetry\dist\OMW_AAR_Fuel_Telemetry.lua
```

Er mutiert keine `.miz` und benötigt lokal kein Python.

Erwartete Kernausgabe:

```text
BuilderVersion: AAR-FUEL-TELEMETRY-5
TestId: AAR-FUEL-TELEMETRY-5
FuelPoints: SPAWN,INGRESS,TRACK,TRACK_DEPARTURE,FIR_EGRESS,EXTERNAL_HANDOFF
FuelLowIncluded: false
CandidateSpawnSpeedKt: 480
ProductionTransitRouteSpeedKt: 300
CandidateManasIngressFt: 34000
CandidateManasEgressFt: 35000
CandidateAlUdeidIngressFt: 35000
CandidateAlUdeidEgressFt: 34000
CandidateMissionAltitudeMode: EXACT_TRACK_ALTITUDE
CandidateIngressEgressContract: PRESERVED_MOOSE_FIR_ROUTING
Optional60NmApproach: DISABLED
DiagnosticEgressHook: EXISTING_CONTROLLER_LIFECYCLE
CandidateScope: OUTBOUND_FUEL_TELEMETRY
MizMutation: false
```

## Mission Editor

ChatGPT verändert keine `.miz`-Datei.

Der Projektinhaber verwendet die vorhandene AAR-Fuel-Telemetry-Testmission und ersetzt im Mission Editor ausschließlich den bisherigen AAR-Telemetrie-`DO SCRIPT FILE` durch den neu gebauten Bundle:

```text
P:\DCS-DEV\Operation-Mountain-Watch\mission\tests\aar-fuel-telemetry\dist\OMW_AAR_Fuel_Telemetry.lua
```

Dabei gilt:

```text
- Moose.lua unverändert und vor dem Testbundle laden;
- nur ein AAR-Testbundle laden;
- keine Tanker-Templates, Fuel-Werte, Routen, Tracks oder Callsigns im Mission Editor verändern;
- Mission unter einem neuen Testnamen speichern.
```

## DCS-Prüfziele

Für alle sechs Tracks soweit praktikabel:

```text
- natürlicher Anstieg vom Track auf das korrekte Return-LRC-Level;
- MANAS return: FL350;
- AL_UDEID return: FL340;
- EGPAN / PINAX / DAVER auf Egress tatsächlich passiert;
- External Handoff natürlich erreicht;
- TRACK DEPARTURE -> FIR EGRESS Fuel-Burn erfasst;
- TRACK DEPARTURE -> EXTERNAL HANDOFF Fuel-Burn erfasst;
- keine Regression des bestehenden FIR-/Handoff-Lifecycles.
```

## Testende

Der Lauf ist erfolgreich abgeschlossen, sobald im `dcs.log` steht:

```text
[OMW][AAR-FUEL-TELEMETRY-5] RESULT PASS allTracks=6 samplesPerTrack=6 points=SPAWN,INGRESS,TRACK,TRACK_DEPARTURE,FIR_EGRESS,EXTERNAL_HANDOFF fuelLowExcluded=true
```

Für die Auswertung werden anschließend benötigt:

```text
dcs.log
debrief.log
exakte getestete .miz
Builder-Ausgabe einschließlich GitCommit und BundleSHA256
```

Erst diese reale Outbound-Evidenz ist Grundlage für die finale per-Track-FuelLow-Berechnung. Candidate 5 selbst ändert keine produktiven Fuel-, FuelLow- oder `.miz`-Werte.
