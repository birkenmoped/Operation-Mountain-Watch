---
document_id: OMW-MOOSE-AAR-LRC-TRANSIT
status: DRAFT
document_class: MOOSE_TECHNICAL_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-reviewed MOOSE methods used by the branch-local AAR LRC transit candidate
  - evidence boundary for late AAR-track approach routing
  - explicit record of failed Candidate-3/Candidate-4 assumptions
not_authoritative_for:
  - production AAR LRC routing before documented DCS acceptance
  - exact KC-135R performance data
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/aar-fuel-telemetry-calibration
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# MOOSE – AAR LRC Transit Candidate

## Gepinnter Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## Akzeptierter Primärvertrag bleibt unangetastet

Der produktiv akzeptierte AAR-Routingvertrag bleibt:

```text
External Spawn
-> AUFTRAG:SetMissionIngressCoord(EGPAN/PINAX/DAVER)
-> AAR track
-> AUFTRAG:SetMissionEgressCoord(EGPAN/PINAX/DAVER)
-> physical FIR egress passage
-> FLIGHTGROUP:AddWaypoint(external handoff)
```

Branch-lokale LRC-Experimente dürfen diesen Primärvertrag nicht stillschweigend ersetzen.

## Candidate 3 – verworfene Annahme

Candidate 3 verschob `SetMissionIngressCoord(...)` vom veröffentlichten FIR-Fix auf einen berechneten 60-NM-Late-Approach und versuchte den FIR-Fix anschließend per verzögertem `FLIGHTGROUP:AddWaypoint(...)` nach `AddMission(...)` wieder vor die Mission einzufügen.

Der reale DCS-Lauf zeigte keine zuverlässige PINAX-/DAVER-Passage. Damit wurde ein bereits akzeptierter Vertrag unnötig ersetzt.

Entscheidung:

```text
SetMissionIngressCoord(late approach)
+ delayed AddWaypoint(FIR fix after current UID)
= REJECTED
```

Diese Kombination wird nicht in `VERIFIED-METHODS.md` als praktisch bestätigt eingetragen.

## Candidate 4 – korrigierter Primärvertrag, fehlgeschlagener Adapter

Candidate 4 stellte wieder her:

```text
AUFTRAG:SetMissionIngressCoord(EGPAN/PINAX/DAVER, ...)
```

Der reale DCS-Lauf bestätigte die tatsächliche FIR-Passage für alle sechs operativen Tracks:

```text
NELSON/PATTY    -> EGPAN
LISA/MOE        -> PINAX
KRUSTY/MILHOUSE -> DAVER
```

Der Versuch, nach dem MOOSE-Routeaufbau zusätzlich einen 60-NM-Late-Approach einzufügen, schlug dagegen fehl mit:

```text
LRC late-approach injection has no MOOSE mission waypoint UID
```

Die source-reviewte Annahme, dass `AUFTRAG:GetGroupWaypointIndex(opsgroup)` am gewählten `ScheduleOnce`-Zeitpunkt bereits eine verwendbare Mission-Waypoint-UID liefert, wurde damit im realen DCS-Lauf widerlegt.

Bewertung:

```text
SetMissionIngressCoord(FIR fix): praktisch erneut bestätigt
Candidate-4 mission-waypoint UID timing assumption: disproved in DCS
Candidate-4 late-approach insertion: failed
```

Ein bloßes Vergrößern des Timers wäre kein belastbarer Fix und soll nicht als Trial-and-Error-Produktionsweg verwendet werden.

## Source-verifizierte öffentliche Methoden

Die Kandidaten verwendeten nur öffentliche, im gepinnten `Moose.lua` vorhandene Pfade:

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

`SPAWN:InitSpeedKnots(...)` ist von der AUFTRAG-/Waypoint-Geschwindigkeit getrennt. Der branch-lokale DCS-Test zeigte `480 kt` als plausiblen In-Air-Materialisierungszustand; der MOOSE-Route-Speed blieb `300 kt`.

## Relevantes NewORBIT-Verhalten

Im gepinnten Stand setzt `AUFTRAG:NewORBIT` standardmäßig:

```text
missionAltitude = orbitAltitude * 0.9
missionFraction = 0.9
```

Die zuvor beobachteten Werte korrelierten damit exakt:

```text
NELSON: 27,500 ft * 0.9 = 24,750 ft
PATTY:  24,000 ft * 0.9 = 21,600 ft
```

Der branch-lokale Kandidat verwendet deshalb:

```lua
mission:SetMissionAltitude(profile.altitudeFt)
```

Damit bleibt MOOSE für die Missionserzeugung zuständig, während der projektseitig unerwünschte 90-Prozent-Missionswaypoint auf die reale Track-Höhe gesetzt wird.

## 60-NM-Late-Approach – technische und fachliche Grenze

Der 60-NM-Punkt ist kein neuer FIR-Fix und kein gemeinsamer Nord-/Süd-Waypoint. Er ist lediglich ein berechneter Punkt pro Track auf der Linie FIR-Fix -> Track.

Ursprünglicher Zweck:

```text
FIR ingress at directional LRC altitude
-> remain at LRC altitude
-> approximately 60 NM before track
-> descent
-> exact track altitude
```

Nach dem realen Candidate-4-Lauf und der Eigentümerklärung gilt:

- der Punkt ist nicht erforderlich, um die Fuel-Telemetrie `INGRESS -> TRACK` auszuwerten;
- ein natürlicher MOOSE/DCS-Sinkflug zum Track kann fachlich ausreichend sein;
- der 60-NM-Punkt ist daher ein optionales Routingexperiment und keine akzeptierte Produktionsanforderung;
- das wichtigere offene FuelLow-Thema ist der Outbound-Climb von Track-Höhe auf das directional return LRC level sowie der weitere Rückweg.

Es besteht daher kein Auftrag, den Candidate-4-Adapter durch bloßes Timer-Tuning weiterzuverfolgen.

## Fuel- und FuelLow-relevante MOOSE-Grenze

Die Fuel-Telemetrie verwendet praktisch bestätigte öffentliche UNIT-Wrapper:

```text
UNIT:GetFuel()
UNIT:GetCurrentFuelKgs()
UNIT:GetFuelMassMax()
```

`FLIGHTGROUP:SetFuelLowThreshold(...)`, `SetFuelLowRTB(false)` und der FuelLow-Callback bleiben Teil des bereits akzeptierten AAR-Lifecycles. Neu zu kalibrieren ist der projektseitige Schwellenwert, nicht der MOOSE-Mechanismus.

Die aktuell bevorzugte nächste Messung erfordert keine neue Routingarchitektur:

```text
TRACK departure fuel
FIR EGRESS fuel
EXTERNAL HANDOFF fuel
```

Damit kann der reale Outbound-Climb-/Return-Verbrauch bestimmt werden, bevor die neuen FuelLow-Schwellen produktiv übernommen werden.

## Nachweisgrenze

Candidate 3 ist für den Inbound-Routingansatz fehlgeschlagen.

Candidate 4 hat den FIR-Ingress wieder korrekt hergestellt, aber der zusätzliche Late-Approach-Adapter ist fehlgeschlagen. Ein Telemetrie-`RESULT PASS` beweist nur vollständige SPAWN/INGRESS/TRACK-Fuel-Samples und darf nicht als LRC-Routing-PASS interpretiert werden.

Keine der fehlgeschlagenen Kombinationen wird als `VALIDATED` oder praktisch bestätigt in `VERIFIED-METHODS.md` eingetragen.
