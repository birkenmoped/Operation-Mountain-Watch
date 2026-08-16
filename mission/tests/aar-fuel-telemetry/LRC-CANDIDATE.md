---
document_id: OMW-TEST-AAR-LRC-TRANSIT-CANDIDATE
status: DRAFT
document_class: TEST_DESIGN
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local AAR LRC transit candidate
  - DCS validation scope for directional transit levels and late track descent
not_authoritative_for:
  - production AAR routing before documented DCS acceptance
  - exact KC-135R optimum-altitude performance data
  - revised production initial fuel or FuelLow values
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/aar-fuel-telemetry-calibration
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# AAR LRC Transit Candidate

## Ziel

Der dritte AAR-Telemetrie-Build verbindet die bereits in DCS bestätigte In-Air-Spawninitialisierung mit einer rekonstruierten LRC-Transitplanung. Der Kandidat bleibt branch-lokal und verändert die produktive Controller-Datei nicht.

## Evidenzgrenze

Die reale KC-135-Betriebsdoktrin fordert für Transit zum und vom AAR-Einsatz Long Range Cruise und optimum altitude. Das öffentlich verfügbare `T.O. 1C-135(K)R(I)-1` verweist für die eigentlichen KC-135R/T-Performance-Daten auf das nicht vorliegende Performance-Appendix `T.O. 1C-135(K)R-1-1`. Die konkreten OMW-Cruise-Level sind deshalb `RECONSTRUCTED_PLANNING_ESTIMATE`, nicht als offizielle KC-135R-Optimum-Altitude-Tabelle auszugeben.

Die historische Afghanistan-AIP-Baseline verwendet die ICAO-Richtungssystematik für IFR-Cruising-Levels. Für OMW wird daher ein benachbartes LRC-Level-Paar um die konservative Planungsmitte FL345 verwendet:

```text
magnetic track 000-179 deg -> odd  -> FL350
magnetic track 180-359 deg -> even -> FL340
```

Für die vorhandenen Source-Domain-Pfade ergibt sich:

```text
MANAS -> Afghanistan:      FL340
Afghanistan -> MANAS:      FL350
AL_UDEID -> Afghanistan:   FL350
Afghanistan -> AL_UDEID:   FL340
```

Kein routinemäßiger Step-Climb wird verwendet. Die Cruise-Höhe wird für die jeweilige Flugrichtung geplant und durchgehend geflogen, bis der Übergang zum AAR-Profil erforderlich wird.

## Candidate 3

```text
In-air spawn initial speed:      480 kt
MOOSE transit route speed:       300 kt, unverändert
MANAS inbound cruise level:      FL340
MANAS outbound cruise level:     FL350
AL_UDEID inbound cruise level:   FL350
AL_UDEID outbound cruise level:  FL340
late track-approach distance:    60 NM
track altitude / KIAS:           unverändert
initial fuel / FuelLow:          unverändert
```

`480 kt` betrifft ausschließlich `SPAWN:InitSpeedKnots(...)`. Der MOOSE-Route-Speed bleibt zunächst `300 kt`, da die bisherigen DCS-Beobachtungen für diese Waypoint-Vorgabe einen plausiblen stabilisierten Hochhöhen-Cruisezustand ergaben. Die verschiedenen Geschwindigkeitsparameter werden nicht gleichgesetzt.

Die 60-NM-Track-Approach-Distanz ist ein branch-lokaler Testkandidat. Sie soll insbesondere den größten aktuellen Übergang `FL350 -> FL220` ohne einen frühen Sinkflug über einen großen Teil der FIR-to-track-Strecke ermöglichen. Sie ist noch keine produktive Baseline.

## MOOSE-first Umsetzung

Gepinnter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Source-verifiziert werden ausschließlich öffentliche MOOSE-Pfade verwendet:

```text
SPAWN:InitSpeedKnots(...)
AUFTRAG:SetMissionIngressCoord(...)
AUFTRAG:SetMissionAltitude(...)
AUFTRAG:SetMissionEgressCoord(...)
FLIGHTGROUP:AddMission(...)
FLIGHTGROUP:AddWaypoint(...)
BASE/FLIGHTGROUP:ScheduleOnce(...)
FLIGHTGROUP:GetWaypointCurrentUID()
COORDINATE:GetIntermediateCoordinate(...)
COORDINATE:Get2DDistance(...)
```

Der gepinnte MOOSE-Stand setzt für `AUFTRAG:NewORBIT` standardmäßig `missionAltitude = orbitAltitude * 0.9` und `missionFraction = 0.9`. Die DCS-Screenshots des vorherigen Laufs korrelierten exakt damit: NELSON wurde während des Missionsanflugs bei ungefähr 24,750 ft statt 27,500 ft und PATTY bei ungefähr 21,600 ft statt 24,000 ft beobachtet. Der Kandidat verwendet deshalb `AUFTRAG:SetMissionAltitude(profile.altitudeFt)`, damit der MOOSE-Mission-Waypoint die tatsächliche Track-Höhe erhält.

Der publizierte FIR-Fix darf durch einen späten Mission-Ingress nicht verloren gehen. Deshalb wird nach dem von MOOSE aufgebauten Mission-Routeplan einmalig ein expliziter FIR-Waypoint unmittelbar nach dem aktuellen Waypoint eingefügt. Danach folgt der späte AUFTRAG-Ingress 60 NM vor dem Track und erst anschließend der Mission-Waypoint auf Track-Höhe.

Sollpfad inbound:

```text
External Spawn @ directional LRC
-> published FIR fix @ directional LRC
-> late track approach @ directional LRC
-> descent to exact track altitude
-> AAR racetrack
```

Sollpfad outbound:

```text
AAR racetrack
-> AUFTRAG Cancel
-> published FIR egress fix @ opposite-direction LRC
-> existing External Handoff waypoint
-> despawn / strategic settlement
```

Die FIR-Waypoint-Injektion wird als einmaliges `ScheduleOnce` fünf Sekunden nach `AddMission` ausgeführt. Das ist ein gezielter Adapter um den öffentlichen MOOSE-Routingpfad; es gibt keinen Frame-Scan und keinen parallelen Missionsrouter.

## Build

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch
git switch agent/aar-fuel-telemetry-calibration
git pull --ff-only origin agent/aar-fuel-telemetry-calibration
.\tools\build-aar-fuel-telemetry.ps1
```

Erzeugt:

```text
mission\tests\aar-fuel-telemetry\dist\OMW_AAR_Fuel_Telemetry.lua
```

Erwartete Builder-Marker:

```text
BuilderVersion: AAR-FUEL-TELEMETRY-3
TestId: AAR-FUEL-TELEMETRY-3
CandidateSpawnSpeedKt: 480
ProductionTransitRouteSpeedKt: 300
CandidateManasIngressFt: 34000
CandidateManasEgressFt: 35000
CandidateAlUdeidIngressFt: 35000
CandidateAlUdeidEgressFt: 34000
CandidateTrackApproachNm: 60
CandidateMissionAltitudeMode: EXACT_TRACK_ALTITUDE
CandidateFirRouting: EXPLICIT_FIR_WAYPOINT_THEN_LATE_MISSION_INGRESS
CandidateScope: SPAWN_SPEED_AND_LRC_ROUTE
MizMutation: false
```

## DCS-Akzeptanzgrenze

Vor produktiver Übernahme muss ein realer DCS-Lauf mindestens bestätigen:

```text
- alle sechs Tanker materialisieren fehlerfrei;
- 480-kt-Spawnzustand bleibt stabil;
- tatsächliche Passage von EGPAN/PINAX/DAVER bleibt erhalten;
- Tanker halten die directional LRC altitude bis zum late track approach;
- anschließend natürlicher Sinkflug ohne beobachtbaren Teleport;
- NELSON/PATTY zeigen keinen 90%-Altitude-Unterschwinger als geplanten Mission-Waypoint;
- alle sechs erreichen ihren Racetrack auf korrekter Track-Höhe und Track-KIAS;
- Cancel/Egress führt auf den FIR-Fix mit dem gegenüberliegenden directional LRC level;
- External Handoff / Settlement bleibt regressionsfrei;
- Fuel-Telemetrie liefert erneut SPAWN, INGRESS und TRACK für alle sechs Tracks.
```

`VALIDATED` ist erst nach dokumentiertem DCS-Test mit realer Mission-, Bundle-, DCS- und MOOSE-Provenienz zulässig. ChatGPT mutiert keine `.miz`-Datei.