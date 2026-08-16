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
validated_in_dcs: partial
---

# AAR LRC Transit Candidate

## Ziel

Die branch-lokale AAR-Telemetrie verbindet den in DCS plausibilisierten In-Air-Spawnzustand mit einer rekonstruierten LRC-Transitplanung, ohne den akzeptierten FIR-Ingress-Vertrag zu ersetzen. Die produktive Controller-Datei bleibt unverändert.

Der vollständige post-merge Erkenntnis-, Fehler- und Kalibrierungsstand steht in:

- [`POST-MERGE-FINDINGS.md`](POST-MERGE-FINDINGS.md)

## Evidenzgrenze

Die reale KC-135-Betriebsdoktrin fordert für Transit zum und vom AAR-Einsatz Long Range Cruise und optimum altitude. Das öffentlich verfügbare Material enthält keine vollständige KC-135R/T-Optimum-Altitude-Tabelle. Die konkreten OMW-Cruise-Level sind deshalb `RECONSTRUCTED_PLANNING_ESTIMATE`.

Die Afghanistan-AIP-Baseline verwendet die ICAO-Richtungssystematik für IFR-Cruising-Levels. OMW verwendet derzeit:

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

Insbesondere LISA/MOE flogen nicht über PINAX und die südlichen Pfade hielten DAVER nicht zuverlässig ein.

Entscheidung:

```text
SetMissionIngressCoord(late approach)
+ delayed AddWaypoint(FIR fix)
= REJECTED
```

Der Ansatz darf nicht als Produktionsgrundlage verwendet werden. Zusätzlich war das Verschieben eines bereits akzeptierten FIR-Ingress-Vertrags ohne ausdrückliche Eigentümerentscheidung eine unzulässige Architekturänderung.

## Candidate 4 – korrigierter Ansatz und reales Ergebnis

Candidate 4 stellte den akzeptierten Primärmechanismus wieder her:

```text
SetMissionIngressCoord(EGPAN/PINAX/DAVER)
```

Der 60-NM-Late-Approach sollte erst danach in den von MOOSE erzeugten Pfad eingefügt werden.

Unverändert blieben:

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

### Reales DCS-Ergebnis

Mission:

```text
OMW_Template_v10_AirOps_rdy.miz
DCS 2.9.28.26385 MT
AAR-FUEL-TELEMETRY-4
```

Positiv bestätigt wurde die tatsächliche FIR-Ingress-Passage:

```text
NELSON/PATTY    -> EGPAN
LISA/MOE        -> PINAX
KRUSTY/MILHOUSE -> DAVER
```

Damit ist die Candidate-3-Regression am FIR-Ingress korrigiert.

Der Late-Approach-Adapter selbst schlug jedoch fehl:

```text
LRC late-approach injection has no MOOSE mission waypoint UID
```

Der 60-NM-Punkt wurde daher nicht eingefügt.

Bewertung:

```text
FIR ingress restoration: PASS for observed run
60-NM late-approach insertion: FAIL
Candidate-4 overall LRC route: NOT ACCEPTED
```

Der Telemetrie-Harness meldete zwar:

```text
RESULT PASS allTracks=6 samplesPerTrack=3 points=SPAWN,INGRESS,TRACK fuelLowExcluded=true
```

Dieser PASS beweist ausschließlich die vollständige Fuel-Telemetrie. Er ist ausdrücklich kein Routing-PASS.

## 60-NM-Late-Approach – Bedeutungsgrenze

Der 60-NM-Punkt ist weder ein neuer FIR-Fix noch ein zusätzlicher gemeinsamer Nord-/Süd-Punkt. Er ist nur ein berechneter Punkt pro Track:

```text
External Spawn
-> FIR Ingress
-> LRC cruise
-> ca. 60 NM vor dem individuellen Track
-> descent
-> track
```

Nach Eigentümerklärung gilt:

- der Punkt ist für die Fuel-Kalibrierung nicht erforderlich;
- ein natürlicher MOOSE/DCS-Sinkflug vom FIR-Ingress zum Track ist akzeptabel, wenn das Flugverhalten plausibel ist;
- der Punkt bleibt ein optionaler Routingversuch und ist keine produktive Anforderung;
- für FuelLow ist der Outbound-Climb und der vollständige Rückflug wichtiger als dieser Inbound-Übergabepunkt.

## MOOSE-first Stand

Gepinnter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Für Candidate 4 waren ausschließlich öffentliche MOOSE-Pfade source-verifiziert:

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

Der reale DCS-Lauf widerlegte jedoch die Annahme, dass die Mission-Waypoint-UID am gewählten Adapterzeitpunkt verfügbar ist. Dieser kombinierte Pfad ist daher nicht validiert.

Die exakte Mission-Waypoint-Höhe wird weiterhin branch-lokal mit

```lua
mission:SetMissionAltitude(profile.altitudeFt)
```

gesetzt, weil `AUFTRAG:NewORBIT` im gepinnten Stand standardmäßig `missionAltitude = orbitAltitude * 0.9` verwendet.

## Fuel-Telemetrie aus Test 4

Für die aktuelle Verbrauchskalibrierung wird ausschließlich Test 4 verwendet. Die älteren Tests dienen nur dem Vergleich.

```text
Maximum DCS KC-135 fuel mass: 90,700 kg
```

| Track | FIR->Track | Burn INGRESS->TRACK | Time |
|---|---:|---:|---:|
| NELSON | 123.698 NM | 3.8939 % | 1101.100 s |
| PATTY | 210.823 NM | 6.3108 % | 2151.149 s |
| LISA | 416.794 NM | 11.3373 % | 4018.014 s |
| MOE | 225.206 NM | 6.4283 % | 2049.047 s |
| MILHOUSE | 235.241 NM | 6.3600 % | 2572.570 s |
| KRUSTY | 257.455 NM | 7.2062 % | 2930.928 s |

Distanzgewichtete Test-4-Raten:

```text
MANAS:     25.98 kg/NM
AL_UDEID:  24.97 kg/NM
```

Aktuelle branch-lokale Initial-Fuel-Kandidaten daraus:

```text
MANAS:     91.4067 %
AL_UDEID:  79.4558 %
```

Aktuelle branch-lokale FuelLow-Kandidaten unter Einbeziehung der übernommenen AFMAN-Reserveplanung:

```text
NELSON:    24 %
PATTY:     25 %
LISA:      33 %
MOE:       29 %
MILHOUSE:  37 %
KRUSTY:    39 %
```

Diese Werte sind noch keine produktive Baseline.

## Nächste Akzeptanzgrenze

Vor finaler FuelLow-Übernahme ist direkte Outbound-Telemetrie besonders wertvoll:

```text
TRACK departure fuel
FIR EGRESS fuel
EXTERNAL HANDOFF fuel
```

Damit kann der reale DCS-Climb-/Outbound-Verbrauch gemessen werden. Eine erneute Veränderung des akzeptierten FIR-Ingress-Vertrags ist dafür nicht erforderlich.

`VALIDATED` bleibt an vollständige DCS-Provenienz und den tatsächlich geprüften Scope gebunden. ChatGPT mutiert keine `.miz`-Datei.
