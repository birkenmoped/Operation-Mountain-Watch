---
document_id: OMW-MOOSE-AAR-LRC-TRANSIT
status: DRAFT
document_class: MOOSE_TECHNICAL_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-reviewed MOOSE methods used by the branch-local AAR LRC transit candidate
  - evidence boundary for late AAR-track approach routing
not_authoritative_for:
  - production AAR LRC routing before documented DCS acceptance
  - exact KC-135R performance data
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/aar-fuel-telemetry-calibration
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# MOOSE – AAR LRC Transit Candidate

## Gepinnter Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## Verbindliche Korrektur nach Candidate 3

Der in `AAR-FUEL-TELEMETRY-3` getestete Ansatz, `AUFTRAG:SetMissionIngressCoord(...)` vom veröffentlichten FIR-Fix auf einen 60-NM-Late-Approach zu verschieben und den FIR-Fix anschließend per verzögertem `FLIGHTGROUP:AddWaypoint(...)` vor die Mission einzufügen, ist verworfen.

Der reale DCS-Lauf zeigte zwar die gewünschten LRC-Höhen und die korrigierte Track-Höhe, aber keine zuverlässige Passage von PINAX/DAVER. Damit wurde ein zuvor akzeptierter Vertrag unnötig ersetzt.

Candidate 4 stellt deshalb den akzeptierten Primärmechanismus wieder her:

```text
AUFTRAG:SetMissionIngressCoord(EGPAN/PINAX/DAVER, ...)
```

Der 60-NM-Late-Approach wird nur noch **nach** dem von MOOSE erzeugten FIR-Ingress-Waypoint ergänzt.

## Source-verifizierte Methoden

Der korrigierte branch-lokale Kandidat verwendet nur öffentliche, im gepinnten `Moose.lua` vorhandene Pfade:

```text
SPAWN:InitSpeedKnots(SpeedKnots)
AUFTRAG:SetMissionIngressCoord(Coordinate, Altitude, Speed)
AUFTRAG:SetMissionAltitude(Altitude)
AUFTRAG:SetMissionEgressCoord(Coordinate, Altitude, Speed)
AUFTRAG:GetGroupWaypointIndex(opsgroup)
FLIGHTGROUP:AddMission(Mission)
OPSGROUP:GetWaypointIndex(uid)
OPSGROUP:GetWaypointID(index)
OPSGROUP:GetWaypointCoordinate(index)
FLIGHTGROUP:AddWaypoint(Coordinate, Speed, AfterWaypointWithID, Altitude, Updateroute)
BASE:ScheduleOnce(Start, SchedulerFunction, ...)
COORDINATE:GetIntermediateCoordinate(ToCoordinate, Fraction)
COORDINATE:Get2DDistance(TargetCoordinate)
```

`SPAWN:InitSpeedKnots(...)` wandelt knots über `UTILS.KnotsToMps(...)` für die physische In-Air-Materialisierung um. Der vorangegangene DCS-Test bestätigte `480 kt` branch-lokal als plausiblen Spawn-Energiezustand; dies ist keine Aussage über den AUFTRAG-/Waypoint-Speed-Parameter.

`AUFTRAG:SetMissionIngressCoord(...)` und `SetMissionEgressCoord(...)` erwarten Höhe in feet und Speed in knots.

## RouteToMission-Vertrag im gepinnten MOOSE

Der relevante `OPSGROUP:RouteToMission(...)`-Pfad baut für einen FLIGHTGROUP mit gesetztem Mission-Ingress die Wegpunkte in dieser Reihenfolge auf:

```text
optional holding waypoint
-> mission ingress waypoint
-> mission waypoint
-> optional mission egress waypoint
```

Beim Erzeugen des Mission-Waypoints speichert MOOSE dessen UID über:

```text
mission:SetGroupWaypointIndex(self, waypoint.uid)
```

Die öffentliche Methode `AUFTRAG:GetGroupWaypointIndex(opsgroup)` liefert diese UID zurück. Mit `OPSGROUP:GetWaypointIndex(uid)` kann deren aktuelle Position in der MOOSE-Waypoint-Liste bestimmt werden. Der unmittelbar vorherige Wegpunkt ist im hier verwendeten RouteToMission-Pfad der gesetzte Mission-Ingress.

Candidate 4 verwendet genau diesen source-verifizierten Vertrag und prüft zusätzlich die Geometrie, bevor die Route verändert wird:

```text
mission waypoint UID auflösen
-> mission waypoint index bestimmen
-> vorherigen waypoint als ingress candidate bestimmen
-> dessen Koordinate gegen runtime.firIngressCoord prüfen
-> nur bei <= 0.5 NM Abweichung Late-Approach danach einfügen
```

Schlägt diese Prüfung fehl, wird die Route nicht stillschweigend verändert, sondern der Test bricht mit einem eindeutigen Fehler ab.

## Relevantes NewORBIT-Verhalten

Im gepinnten Stand setzt `AUFTRAG:NewORBIT` standardmäßig:

```text
missionAltitude = orbitAltitude * 0.9
missionFraction = 0.9
```

`AUFTRAG:NewTANKER(...)` verwendet den ORBIT-RACETRACK-Pfad. Die früher beobachteten Anflughöhen korrelierten damit:

```text
NELSON: 27,500 ft * 0.9 = 24,750 ft
PATTY:  24,000 ft * 0.9 = 21,600 ft
```

Der Kandidat verwendet deshalb weiterhin:

```lua
mission:SetMissionAltitude(profile.altitudeFt)
```

Dadurch bleibt MOOSE für die Missionserzeugung zuständig, während der projektseitig unerwünschte 90%-Höhenwert am Missions-Waypoint auf die reale Track-Höhe gesetzt wird.

## Late Track Approach

Der späte Approach-Punkt wird mit `COORDINATE:GetIntermediateCoordinate(...)` 60 NM vom Track in Richtung FIR-Fix erzeugt. Er bleibt auf der jeweiligen LRC-Ingress-Höhe.

Die Sollreihenfolge lautet nun:

```text
current / spawn @ directional LRC
-> AUFTRAG FIR ingress @ directional LRC
-> inserted 60-NM late approach @ directional LRC
-> AUFTRAG mission waypoint @ exact track altitude
-> tanker orbit
```

Outbound bleibt der bereits akzeptierte Mechanismus unangetastet:

```text
AUFTRAG Cancel
-> SetMissionEgressCoord(FIR fix)
-> physische FIR-Passage
-> FLIGHTGROUP:AddWaypoint(external handoff)
-> off-map settlement / despawn
```

## Noch nicht validiert

Source-reviewed, aber als Kombination noch in DCS zu bestätigen:

```text
AddMission
-> MOOSE RouteToMission builds FIR ingress -> mission waypoint
-> resolve mission waypoint UID through public AUFTRAG API
-> verify preceding waypoint equals configured FIR fix
-> insert late approach after FIR fix
-> preserve FIR passage
-> exact mission waypoint altitude
-> normal tanker task execution
```

Candidate 3 ist für den Inbound-Routingansatz ausdrücklich fehlgeschlagen und wird nicht in `VERIFIED-METHODS.md` als praktisch bestätigt eingetragen. Candidate 4 darf erst nach dokumentiertem DCS-PASS als produktive Baseline übernommen werden.
