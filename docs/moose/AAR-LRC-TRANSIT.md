---
document_id: OMW-MOOSE-AAR-LRC-TRANSIT
status: DRAFT
document_class: MOOSE_TECHNICAL_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-reviewed MOOSE methods used by the branch-local AAR LRC transit candidate
  - evidence boundary for late AAR-track ingress routing
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

## Source-verifizierte Methoden

Der branch-lokale Kandidat verwendet nur öffentliche, im gepinnten `Moose.lua` vorhandene Pfade:

```text
SPAWN:InitSpeedKnots(SpeedKnots)
AUFTRAG:SetMissionIngressCoord(Coordinate, Altitude, Speed)
AUFTRAG:SetMissionAltitude(Altitude)
AUFTRAG:SetMissionEgressCoord(Coordinate, Altitude, Speed)
FLIGHTGROUP:AddMission(Mission)
FLIGHTGROUP:AddWaypoint(Coordinate, Speed, AfterWaypointWithID, Altitude, Updateroute)
OPSGROUP:GetWaypointCurrentUID()
BASE:ScheduleOnce(Start, SchedulerFunction, ...)
COORDINATE:GetIntermediateCoordinate(ToCoordinate, Fraction)
COORDINATE:Get2DDistance(TargetCoordinate)
```

`SPAWN:InitSpeedKnots(...)` wandelt knots über `UTILS.KnotsToMps(...)` für die physische In-Air-Materialisierung um. Der vorangegangene DCS-Test bestätigte `480 kt` branch-lokal als plausiblen Spawn-Energiezustand; dies ist keine Aussage über den AUFTRAG-/Waypoint-Speed-Parameter.

`AUFTRAG:SetMissionIngressCoord(...)` und `SetMissionEgressCoord(...)` erwarten Höhe in feet und Speed in knots. `SetMissionAltitude(...)` speichert die Missions-Waypoint-Höhe in feet-basiertem API-Aufruf und überschreibt die von `NewORBIT` erzeugte Missionshöhe.

## Relevantes NewORBIT-Verhalten

Im gepinnten Stand setzt `AUFTRAG:NewORBIT` standardmäßig:

```text
missionAltitude = orbitAltitude * 0.9
missionFraction = 0.9
```

`AUFTRAG:NewTANKER(...)` verwendet den ORBIT-RACETRACK-Pfad. `AUFTRAG:GetMissionWaypointCoord(...)` startet bei gesetztem Mission-Ingress von dessen Koordinate, bildet über `missionFraction` einen Zwischenpunkt Richtung Ziel und setzt dort `missionAltitude`.

Damit erklärt der Source-Pfad die im DCS-Lauf beobachteten Anflughöhen:

```text
NELSON: 27,500 ft * 0.9 = 24,750 ft
PATTY:  24,000 ft * 0.9 = 21,600 ft
```

Der Kandidat verwendet deshalb:

```lua
mission:SetMissionAltitude(profile.altitudeFt)
```

Dadurch bleibt MOOSE für die Missionserzeugung zuständig, während der projektseitig unerwünschte 90%-Höhenwert am Missions-Waypoint explizit auf die reale Track-Höhe gesetzt wird.

## Später Mission-Ingress bei erhaltener FIR-Passage

Nur den `SetMissionIngressCoord(...)` vom publizierten FIR-Fix auf einen späten Track-Approach-Punkt zu verschieben, würde den verbindlichen FIR-Fix aus der Route entfernen. Der Kandidat trennt deshalb beide Rollen:

```text
FIR waypoint
= veröffentlichter Entry-/Exit-Fix

AUFTRAG mission ingress
= später LRC-Übergabepunkt vor dem AAR-Track
```

Der späte Approach-Punkt wird mit `COORDINATE:GetIntermediateCoordinate(...)` 60 NM vom Track in Richtung FIR-Fix erzeugt. Im gepinnten Code gilt für einen `Fraction`-Wert größer 1: der Wert wird durch die Vektornorm geteilt und wirkt damit als Distanz entlang des Vektors in Metern. Der Kandidat übergibt deshalb `UTILS.NMToMeters(60)`.

Nach `FLIGHTGROUP:AddMission(...)` baut MOOSE den Mission-Routeplan auf. Der Kandidat verwendet anschließend ein einmaliges `ScheduleOnce` und fügt den publizierten FIR-Fix mit `FLIGHTGROUP:AddWaypoint(...)` nach dem aktuell passierten Waypoint ein. `GetWaypointIndexAfterID(...)` setzt den neuen Wegpunkt direkt hinter die angegebene UID; `AddWaypoint(...)` aktualisiert danach den MOOSE-Routenplan.

Sollreihenfolge:

```text
current / spawn
-> explicit FIR waypoint @ LRC altitude
-> AUFTRAG late ingress @ LRC altitude
-> AUFTRAG mission waypoint @ exact track altitude
-> tanker orbit
```

Dieser Adapter ist absichtlich klein und verwendet keine native DCS-Routenmanipulation, keinen Frame-Scan und keinen parallelen Missionsrouter.

## Noch nicht validiert

Folgende Kombination ist nur source-reviewed und muss in DCS bestätigt werden:

```text
AddMission
-> delayed AddWaypoint after current UID
-> preserved FIR passage
-> late mission ingress
-> exact mission waypoint altitude
-> normal tanker task execution
```

Vor DCS-PASS wird diese Kombination nicht in `VERIFIED-METHODS.md` als praktisch bestätigt eingetragen und nicht als produktive Baseline behandelt.