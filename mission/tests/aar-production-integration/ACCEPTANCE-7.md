---
document_id: OMW-AAR-PRODUCTION-FINAL-ACCEPTANCE-7
status: ACCEPTED_TECHNICAL_BASELINE
document_class: DCS_ACCEPTANCE_RECORD
owning_policy: OMW-GOV-001
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/aar-fuel-telemetry-calibration
source_commit: 7d55a1383cbf3f52ea776d7354b37dbe5a920466
validated_in_dcs: true
---

# AAR Production Final Acceptance 7

## 1. Zweck und Geltungsgrenze

Dieses Dokument hält den endgültig akzeptierten technischen Stand der OMW-AAR-Kalibrierung vor Erstellung des produktiven Missionsgrundgerüsts fest. Es dokumentiert Designentscheidungen, MOOSE-Vertrag, Fuel-Modell, Entfernungen, Timing, Fehlerhistorie, Test-only Abweichungen und die reale DCS-Acceptance-Provenienz.

Die Acceptance gilt nur für den exakt dokumentierten Branch-/Commit-/Mission-/Bundle-/DCS-/MOOSE-Stand. Sie ersetzt keine spätere Acceptance des produktiven Missionsgrundgerüsts.

## 2. Exakte Acceptance-Provenienz

```text
Date: 2026-08-16
Branch: agent/aar-fuel-telemetry-calibration
Source commit: 7d55a1383cbf3f52ea776d7354b37dbe5a920466
Builder/Test-ID: AAR-PRODUCTION-FINAL-ACCEPTANCE-7
DCS: 2.9.28.26385 MT

Uploaded mission artifact: OMW_Template_v10_AirOps_rdy(5).miz
Internal DCS mission path/name: OMW_Template_v10_AirOps_rdy.miz
Mission SHA-256: 16d0a9b26a648c2dbcbd727b41afc93a28648620f8e2f8c357a770751e48cca5

dcs.log SHA-256: 3157bc87a373f5b55262bf96c6be1cf52f06686bfa6daefd576fc23f88d9e320
debrief.log SHA-256: 66c4fed82e91045ef4ffbc08989dce6cfabf97375ea7faf225e2601ad826a0d4

Controller SHA-256: 547f0336b954b116e43e8a09ca0f001d893ea81d2394025891be5ff078388438
Builder SHA-256: 6ab1432a2b136b6b7c92646520f9407da35f3892c968346dd2ae52b7ada695a3
Validator SHA-256: 52aee90fc4273bc89eb96519f83830f0367f8da915889eefaf77f985f6e88b4f
LateApproach SHA-256: beb236e7abaaa4b988c7e603f94dc8771e5754c2513540a3015fad91a880477f
Bundle SHA-256: 3338d0baa67593be6bff9c22b3ed72b3a8e837cd00820d060eefe920faf91ee2

MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915

Result: PASS
```

## 3. Operatives AAR-Netz

| Area | Profil | Verfügbarkeit | Source | FIR Fix | Track-Höhe | FuelLow | Initial Fuel |
|---|---|---|---|---|---:|---:|---:|
| NELSON | FAST | STANDARD | MANAS | EGPAN | FL275 | 24 % | 91.4067 % |
| PATTY | SLOW | STANDARD | MANAS | EGPAN | FL240 | 26 % | 91.4067 % |
| MILHOUSE | SLOW | STANDARD | AL_UDEID | DAVER | FL220 | 36 % | 79.4558 % |
| KRUSTY | SLOW | STANDARD | AL_UDEID | DAVER | FL220 | 36 % | 79.4558 % |
| LISA | FAST | RESERVE | AL_UDEID | DAVER | FL250 | 38 % | 79.4558 % |
| MOE | FAST | RESERVE | MANAS | PINAX | FL270 | 31 % | 91.4067 % |

STANDARD bedeutet kontinuierliche Verfügbarkeit. LISA und MOE werden nicht automatisch gestartet und dürfen nur durch passenden MissionDemand materialisiert werden.

## 4. Verbindliche Inbound-/Outbound-Sequenz

### Inbound

```text
EXTERNAL SPAWN
-> FIR INGRESS FIX
-> 60-NM LATE-APPROACH POINT
-> TRACK START
-> AAR TRACK
```

Die inbound LRC-/Transferhöhe bleibt bis einschließlich 60-NM-Punkt erhalten. Erst nach realer Passage des Late-Approach-Punktes wird der Tanker-AUFTRAG hinzugefügt; der Sinkflug auf die exakte Track-Höhe erfolgt danach auf dem letzten Anflugsegment.

Technischer MOOSE-Vertrag:

```text
FLIGHTGROUP:AddWaypoint(FIR fix @ inbound LRC altitude)
-> FLIGHTGROUP:AddWaypoint(60-NM point @ inbound LRC altitude)
-> PassingWaypoint FIR confirmed
-> PassingWaypoint 60-NM confirmed
-> FLIGHTGROUP:AddMission(AUFTRAG)
-> AUFTRAG exact track altitude
```

`AUFTRAG:SetMissionIngressCoord(...)` wird für diesen final akzeptierten Inbound-Pfad nicht verwendet, weil der erste Acceptance-7-Lauf zeigte, dass ein bereits hinzugefügter AUFTRAG den davor gesetzten FIR-Wegpunkt in der tatsächlich geflogenen Route umgehen konnte.

### Outbound

```text
TRACK ABORT/DEPARTURE
-> FIR EGRESS FIX
-> EXTERNAL HANDOFF / DESPAWN
```

Die outbound LRC-/Transferhöhe wird unmittelbar mit dem Missionsabbruch/Verlassen des Tracks angefordert. Der bestehende Egress-Pfad blieb funktional und wurde nicht neu erfunden.

## 5. 60-NM-Geometrie

Der Late-Approach-Punkt liegt entlang der realen geraden FIR-Fix->Track-Geometrie exakt 60 NM vor dem Track. Berechnung mit öffentlichem MOOSE `COORDINATE:GetIntermediateCoordinate(...)` und `Get2DDistance(...)`.

Aus Acceptance-7 Runtime-Telemetrie:

| Area | FIR->Late Approach | Late Approach->Track | FIR->Track gesamt |
|---|---:|---:|---:|
| NELSON | 63.7 NM | 60.0 NM | 123.7 NM |
| PATTY | 150.8 NM | 60.0 NM | 210.8 NM |
| MILHOUSE | 175.2 NM | 60.0 NM | 235.2 NM |
| KRUSTY | 197.5 NM | 60.0 NM | 257.5 NM |
| LISA | 225.6 NM | 60.0 NM | 285.6 NM |
| MOE | 165.2 NM | 60.0 NM | 225.2 NM |

LISA Acceptance-7 Beispiel:

```text
FIR DAVER passed
HIGH_HOLD at 84.6 NM to track: 35,000 ft
Late approach passed at 60.0 NM
sequence: FIR_THEN_LATE_APPROACH_THEN_AUFTRAG
```

## 6. Transitgeschwindigkeit und Höhen

```text
SPAWN initialization: 480 kt
Transit route command: 300 kt

MANAS -> Afghanistan: FL340
Afghanistan -> MANAS: FL350
AL_UDEID -> Afghanistan: FL350
Afghanistan -> AL_UDEID: FL340
```

480 kt ist der initiale In-Air-Materialisierungszustand, nicht ein permanenter KIAS-/Groundspeed-Vertrag. Die Transitroute verwendet 300 kt. Die Track-Geschwindigkeit bleibt area-/profilabhängig.

## 7. Timing- und Lifecycle-Vertrag

```text
Same-source spawn spacing: >= 60 s
Dispatcher interval: 5 s
Station monitor interval: 5 s
Planned station cycle: 10,800 s = 3 h
Relief handover ETA arm gate: 300 s = 5 min
FIR-fix passage radius: 5 NM
Track-entry radius: 5 NM
External handoff radius: 10 NM
Per-track physical maximum: 1 ACTIVE + 1 RELIEF
```

MANAS und AL_UDEID dürfen parallel materialisieren. Innerhalb derselben Source Domain müssen Materialisierungen mindestens 60 Sekunden auseinanderliegen.

Scheduled Relief:

```text
ACTIVE
-> genau ein RELIEF
-> gleicher Callsign-Familienvertrag, andere freie n-1 Nummer
-> natürliche Route über FIR + 60-NM Late Approach
-> ETA <= 5 min armt Handover nur
-> outgoing bleibt Station Owner
-> Ownership/Radio/TACAN erst bei realer Track-Ankunft übertragen
-> outgoing danach Cancel/Egress
```

FuelLow:

```text
ACTIVE FuelLow
-> vorhandenen RELIEF wiederverwenden oder genau einen RELIEF erzeugen
-> outgoing sofort Station Identity off + Egress
-> Ersatz übernimmt erst nach natürlicher Track-Ankunft
```

Loss:

```text
physical loss
-> CampaignState no aircraft recredit
-> AIRCRAFT_KC135_LOST audit increment exact-once
-> replacement materialization according to station state
```

## 8. Strategische Ressourcen

```text
OFFMAP_MANAS:
AIRCRAFT_KC135 = 16 count

OFFMAP_AL_UDEID:
AIRCRAFT_KC135 = 40 count
```

CampaignState bleibt alleinige strategische Ressourcenautorität. MOOSE SPAWN/FLIGHTGROUP/AUFTRAG materialisieren nur die physische Repräsentation.

```text
materialization -> consume 1 AIRCRAFT_KC135
confirmed external handoff -> exact-once +1 AIRCRAFT_KC135
loss -> no recredit; exact-once AIRCRAFT_KC135_LOST audit
```

## 9. Fuel-Modell und Berechnungsgrundlagen

### 9.1 Grunddaten

```text
KC-135 max fuel used by OMW model: 90,700 kg
13,000 lb planned landing floor: 5,896.7 kg = 6.5013 %
```

Die 45-Minuten-Reserve ist für alle sechs betrachteten Profile größer als der 13,000-lb-Floor und ist daher im OMW FuelLow-Modell die kontrollierende Reservekomponente.

### 9.2 Virtueller Source-Base->External-Spawn-Verbrauch

Die External Spawn Points liegen technisch auf der DCS-Karte; MANAS bzw. AL_UDEID werden strategisch als reale Source Bases außerhalb dieses sichtbaren Abschnitts modelliert. Der bis zum External Spawn bereits verbrauchte Fuel wird daher aus dem initialen Tankinhalt abgezogen.

```text
MANAS virtual distance: 300.005 NM
weighted planning rate: 25.98 kg/NM
virtual burn: 7,794 kg = 8.5933 %
initial fuel at External Spawn: 91.4067 %

AL_UDEID virtual distance: 746.241 NM
weighted planning rate: 24.97 kg/NM
virtual burn: 18,633 kg = 20.5443 %
initial fuel at External Spawn: 79.4558 %
```

Die physischen Startfuel-Werte werden im Mission-Editor-Template gesetzt. Im gepinnten MOOSE-Stand ist keine öffentliche `SPAWN:InitFuel(...)`-Methode nachgewiesen.

### 9.3 45-Minuten-Reserve pro Area

| Area | 45-min Reserve |
|---|---:|
| NELSON | 9.5482 % |
| PATTY | 7.9209 % |
| LISA | 7.6182 % |
| MOE | 8.4708 % |
| MILHOUSE | 6.6748 % |
| KRUSTY | 6.6384 % |

### 9.4 Candidate-5 gemessener Track-Departure->External-Handoff-Burn

| Area | Burn |
|---|---:|
| NELSON | 5.6753 % |
| PATTY | 9.0161 % |
| LISA, alte MANAS/PINAX-Geometrie | 17.7909 % |
| MOE | 13.4644 % |
| MILHOUSE | 8.1344 % |
| KRUSTY | 8.5073 % |

Der alte LISA-Wert darf nicht auf die neue AL_UDEID/DAVER-Geometrie übertragen werden.

### 9.5 FuelLow-Formel

Für die direkt kalibrierten Areas:

```text
FuelLow raw =
  measured TRACK_DEPARTURE -> EXTERNAL_HANDOFF burn
+ virtual EXTERNAL_HANDOFF -> source-base burn
+ 45-minute reserve
```

Danach konservative Rundung auf volle Prozentpunkte.

Rechenbeispiele:

```text
NELSON:
5.6753 + 8.5933 + 9.5482 = 23.8168 -> 24 %

PATTY:
9.0161 + 8.5933 + 7.9209 = 25.5303 -> 26 %

MOE:
13.4644 + 8.5933 + 8.4708 = 30.5285 -> 31 %

MILHOUSE:
8.1344 + 20.5443 + 6.6748 = 35.3535 -> 36 %

KRUSTY:
8.5073 + 20.5443 + 6.6384 = 35.6900 -> 36 %
```

LISA wurde nach Owner-Entscheidung von MANAS/PINAX auf AL_UDEID/DAVER verschoben. Der Accepted-Candidate verwendet 38 %. Dieser Wert ist eine konservative südliche Neuberechnung; der exakte Track-Departure->External-Handoff-Burn für die neue LISA-Geometrie wurde nicht in einem separaten Fuel-Telemetry-Lauf gemessen. Acceptance 7 bestätigt Konfiguration, Routing, Source/FIR-Zuordnung und Gesamt-Lifecycle, nicht einen separaten LISA-FuelBurn-Messwert. Diese Evidenzgrenze ist bewusst festgehalten.

## 10. LISA-Entscheidung

Verbindliche Owner-Entscheidung vom 16.08.2026:

```text
LISA
Profile: FAST
Availability: RESERVE
Source Domain: AL_UDEID
FIR ingress/egress: DAVER
Initial Fuel: 79.4558 %
FuelLow: 38 %
```

Grund ist die kürzere sichtbare Reaktionsstrecke für MissionDemand, nicht Fuel-Optimierung. Die vorherige PINAX->LISA-Strecke betrug ca. 416.8 NM bis zum Track; DAVER->LISA liegt im neuen MOOSE-Trackmodell bei ca. 285.6 NM bis Track bzw. 225.6 NM bis zum 60-NM-Punkt. Damit wird die sichtbare Reserve-Reaktionsstrecke um rund 131 NM verkürzt.

## 11. Acceptance-7 Fehlerhistorie

Der erste Acceptance-7-Lauf wurde abgebrochen. Beobachtung:

```text
60-NM late approach worked
FIR ingress points were ignored
```

Fehlerursache:

```text
AddWaypoint(FIR)
-> AddMission(AUFTRAG with own ingress/mission route)
```

Der zu früh hinzugefügte AUFTRAG konnte die zuvor angelegte FLIGHTGROUP-Route ersetzen/übergehen. Korrektur:

```text
AddWaypoint(FIR)
-> AddWaypoint(60NM)
-> wait for PassingWaypoint(FIR)
-> wait for PassingWaypoint(60NM)
-> only then AddMission(AUFTRAG)
```

Der erfolgreiche Nachtest bestätigte die Reihenfolge praktisch.

## 12. Acceptance-7 Laufzeitnachweise

Der erfolgreiche Lauf bestätigte mindestens:

```text
AAR_POLICY_BASELINE_PASS
RESTORE_RECONCILIATION_PASS
POOL_BASELINE_PASS MANAS=16 AL_UDEID=40
STANDARD_TRACKS_4_PASS initialAircraft=4 reserveAircraft=0
natural FIR ingress for STANDARD tracks
exact FIR-before-late-approach ordering
60-NM high-hold behavior
exact track altitude
STANDARD demand end retains continuous track
MILHOUSE scheduled relief with natural transit
RELIEF_TRANSIT_OVERLAP_PASS physicalTankers=2 stationOwners=1
SINGLE_SCHEDULED_RELIEF_PASS
NELSON FuelLow immediate egress + natural relief
FUEL_LOW_RELIEF_PASS
LISA reserve MissionDemand -> AL_UDEID/DAVER
MOE reserve MissionDemand -> MANAS/PINAX
RESERVE_DEMAND_LIFECYCLE_PASS
PATTY intentional test loss -> no recredit -> replacement
FINAL_STEADY_STATE_PASS standardTracks=4 reserveTracks=0 supportAircraft=4
RESULT PASS
```

Nach dem offiziellen RESULT PASS trat zusätzlich ein natürlicher KRUSTY FuelLow auf; der Controller erzeugte korrekt Relief und Egress. Das ist zusätzliche Runtime-Evidenz, aber nicht erforderlich für das bereits abgeschlossene Acceptance-Ergebnis.

## 13. Test-only Mechanismen und Produktionsgrenze

Acceptance 7 enthält bewusst Testinstrumentierung:

```text
accelerated selected scheduled relief timing
background scheduled-relief isolation
artificial NELSON FuelLow trigger
intentional PATTY loss via public MOOSE UNIT:Explode()
in-process CampaignState Snapshot/Restore exercise
```

Diese Mechanismen gehören nicht in das endgültige Missions-AAR-Grundgerüst.

Das produktive Grundgerüst muss enthalten:

```text
STANDARD auto-start/continuous:
NELSON
PATTY
MILHOUSE
KRUSTY

RESERVE default inactive / MissionDemand-only:
LISA
MOE

real runtime triggers only:
actual FuelLow
normal planned/scheduled relief
actual aircraft loss
MissionDemand open/close
```

Keine künstliche Verlustinjektion, kein vorgetriggerter FuelLow-Status und keine Acceptance-Zeitbeschleunigung.

## 14. Verifizierter MOOSE-Scope durch Acceptance 7

Für diesen exakten Scope praktisch bestätigt:

```text
SPAWN:InitCallSign(...)
SPAWN:InitHeading(...)
SPAWN:InitSpeedKnots(...)
SPAWN:SpawnFromCoordinate(...)

FLIGHTGROUP:New(...)
FLIGHTGROUP:AddWaypoint(...)
FLIGHTGROUP:AddMission(...)
FLIGHTGROUP:GetCoordinate()
FLIGHTGROUP:SetFuelLowThreshold(...)
FLIGHTGROUP:SetFuelLowRTB(false)
FLIGHTGROUP PassingWaypoint / OnAfterPassingWaypoint
FLIGHTGROUP FuelLow callback
FLIGHTGROUP Dead / OnAfterDead

AUFTRAG:NewTANKER(...)
AUFTRAG:SetMissionAltitude(...)
AUFTRAG:SetMissionEgressCoord(...)
AUFTRAG:Cancel()

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

## 15. Merge- und Folgearbeitsgrenze

Dieser Acceptance-Stand ist eine `ACCEPTED_TECHNICAL_BASELINE` für exakt die dokumentierte Provenienz. Vor Merge nach `main` sind Diff, Dokumentation, MOOSE-Index/Methodenregister und PR-Scope zu prüfen.

Nach Integration nach `main` folgt die Erstellung des produktiven AAR-Missionsgrundgerüsts. Dieses Grundgerüst benötigt einen eigenen Build-/Hash-Nachweis und mindestens einen realen DCS-Sanity-/Acceptance-Lauf, weil die Acceptance-7-Testinstrumentierung entfernt wird.
