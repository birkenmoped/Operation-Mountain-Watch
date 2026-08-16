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

Der vierte AAR-Telemetrie-Build verbindet die bereits in DCS bestätigte In-Air-Spawninitialisierung mit der rekonstruierten LRC-Transitplanung, ohne den akzeptierten FIR-Ingress-Vertrag zu ersetzen. Der Kandidat bleibt branch-lokal und verändert die produktive Controller-Datei nicht.

## Evidenzgrenze

Die reale KC-135-Betriebsdoktrin fordert für Transit zum und vom AAR-Einsatz Long Range Cruise und optimum altitude. Das öffentlich verfügbare `T.O. 1C-135(K)R(I)-1` verweist für die eigentlichen KC-135R/T-Performance-Daten auf das nicht vorliegende Performance-Appendix `T.O. 1C-135(K)R-1-1`. Die konkreten OMW-Cruise-Level sind deshalb `RECONSTRUCTED_PLANNING_ESTIMATE`, nicht als offizielle KC-135R-Optimum-Altitude-Tabelle auszugeben.

Die historische Afghanistan-AIP-Baseline verwendet die ICAO-Richtungssystematik für IFR-Cruising-Levels. Für OMW wird ein benachbartes LRC-Level-Paar um die konservative Planungsmitte FL345 verwendet:

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

Kein routinemäßiger Step-Climb wird verwendet.

## Candidate 3 – verworfener Routingansatz

Candidate 3 verschob den MOOSE-Mission-Ingress vom veröffentlichten FIR-Fix auf den 60-NM-Track-Approach und versuchte anschließend, EGPAN/PINAX/DAVER per verzögertem `FLIGHTGROUP:AddWaypoint(...)` wieder vor die Mission einzufügen.

Der reale DCS-Lauf zeigte:

```text
480-kt In-Air-Spawnzustand: plausibel
LRC-Höhen FL340/FL350:      sichtbar wirksam
exakte Track-Höhe:          sichtbar wirksam
FIR-Ingress-Vertrag:        FEHLGESCHLAGEN
```

Insbesondere LISA/MOE flogen nicht über PINAX und die südlichen Pfade hielten DAVER nicht zuverlässig ein. Der Ansatz

```text
SetMissionIngressCoord(late approach)
+ delayed AddWaypoint(FIR fix after current UID)
```

ist damit verworfen und darf nicht als Produktionsgrundlage verwendet werden.

## Candidate 4 – korrigierter Ansatz

Unverändert bleiben:

```text
In-air spawn initial speed:      480 kt
MOOSE transit route speed:       300 kt
MANAS inbound cruise level:      FL340
MANAS outbound cruise level:     FL350
AL_UDEID inbound cruise level:   FL350
AL_UDEID outbound cruise level:  FL340
late track-approach distance:    60 NM
track altitude / KIAS:           unverändert
initial fuel / FuelLow:          unverändert
```

Entscheidend korrigiert wird ausschließlich der Ingress-Aufbau:

```text
SetMissionIngressCoord(EGPAN/PINAX/DAVER) bleibt erhalten
-> MOOSE baut FIR ingress -> mission waypoint
-> Adapter prüft die von MOOSE erzeugte Reihenfolge
-> late track approach wird NACH dem FIR waypoint eingefügt
-> mission waypoint bleibt auf exakter Track-Höhe
```

Damit bleibt der akzeptierte FIR-Ingress-Vertrag Primärmechanismus. Der 60-NM-Punkt ergänzt ihn lediglich zwischen FIR-Fix und Tanker-Missionswaypoint.

## MOOSE-first Umsetzung

Gepinnter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Candidate 4 verwendet ausschließlich öffentliche, im gepinnten `Moose.lua` vorhandene Pfade:

```text
SPAWN:InitSpeedKnots(...)
AUFTRAG:SetMissionIngressCoord(...)
AUFTRAG:SetMissionAltitude(...)
AUFTRAG:SetMissionEgressCoord(...)
AUFTRAG:GetGroupWaypointIndex(...)
FLIGHTGROUP:AddMission(...)
FLIGHTGROUP:GetWaypointIndex(...)
FLIGHTGROUP:GetWaypointID(...)
FLIGHTGROUP:GetWaypointCoordinate(...)
FLIGHTGROUP:AddWaypoint(...)
BASE/FLIGHTGROUP:ScheduleOnce(...)
COORDINATE:GetIntermediateCoordinate(...)
COORDINATE:Get2DDistance(...)
```

Der gepinnte MOOSE-Quellpfad `OPSGROUP:RouteToMission(...)` erzeugt für FLIGHTGROUP bei gesetztem Mission-Ingress die Reihenfolge:

```text
ingress waypoint
-> mission waypoint
-> optional egress waypoint
```

und speichert die UID des Mission-Waypoints über `mission:SetGroupWaypointIndex(...)`. Candidate 4 löst diese UID über `AUFTRAG:GetGroupWaypointIndex(flightGroup)` auf, bestimmt den direkt vorhergehenden Wegpunkt und prüft dessen Koordinate gegen den konfigurierten FIR-Fix. Nur wenn diese Prüfung innerhalb 0,5 NM besteht, wird der 60-NM-Late-Approach direkt nach diesem FIR-Waypoint eingefügt.

Damit hängt die Korrektur nicht mehr von `GetWaypointCurrentUID()` beziehungsweise dem zufälligen Zustand des zuletzt passierten Waypoints ab.

Der Mission-Waypoint wird weiterhin mit

```lua
mission:SetMissionAltitude(profile.altitudeFt)
```

auf die tatsächliche Track-Höhe gesetzt. Hintergrund ist das source-verifizierte `NewORBIT`-Default `missionAltitude = orbitAltitude * 0.9`.

Sollpfad inbound:

```text
External Spawn @ directional LRC
-> AUFTRAG FIR ingress: EGPAN / PINAX / DAVER @ directional LRC
-> inserted late track approach @ directional LRC
-> descent to exact track altitude
-> AAR racetrack
```

Sollpfad outbound bleibt unverändert:

```text
AAR racetrack
-> AUFTRAG Cancel
-> published FIR egress fix @ opposite-direction LRC
-> existing External Handoff waypoint
-> despawn / strategic settlement
```

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
BuilderVersion: AAR-FUEL-TELEMETRY-4
TestId: AAR-FUEL-TELEMETRY-4
CandidateSpawnSpeedKt: 480
ProductionTransitRouteSpeedKt: 300
CandidateManasIngressFt: 34000
CandidateManasEgressFt: 35000
CandidateAlUdeidIngressFt: 35000
CandidateAlUdeidEgressFt: 34000
CandidateTrackApproachNm: 60
CandidateMissionAltitudeMode: EXACT_TRACK_ALTITUDE
CandidateIngressContract: PRESERVED_MOOSE_FIR_INGRESS
CandidateFirRouting: MOOSE_FIR_INGRESS_THEN_LATE_APPROACH
CandidateScope: SPAWN_SPEED_AND_LRC_ROUTE
MizMutation: false
```

## DCS-Akzeptanzgrenze

Vor produktiver Übernahme muss ein realer DCS-Lauf mindestens bestätigen:

```text
- alle sechs Tanker materialisieren fehlerfrei;
- 480-kt-Spawnzustand bleibt stabil;
- tatsächliche Passage von EGPAN/PINAX/DAVER innerhalb der bestehenden 5-NM-Grenze;
- LRC_LATE_APPROACH_INSERTED wird für jede Sortie erst nach erfolgreicher MOOSE-FIR-Waypoint-Auflösung erzeugt;
- Tanker halten directional LRC altitude bis zum late track approach;
- anschließend natürlicher Sinkflug ohne beobachtbaren Teleport;
- alle sechs erreichen ihren Racetrack auf korrekter Track-Höhe und Track-KIAS;
- Cancel/Egress führt unverändert auf den FIR-Fix mit dem gegenüberliegenden directional LRC level;
- External Handoff / Settlement bleibt regressionsfrei;
- Fuel-Telemetrie liefert erneut SPAWN, INGRESS und TRACK für alle sechs Tracks.
```

`VALIDATED` ist erst nach dokumentiertem DCS-Test mit realer Mission-, Bundle-, DCS- und MOOSE-Provenienz zulässig. ChatGPT mutiert keine `.miz`-Datei.
