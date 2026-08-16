---
document_id: OMW-MOOSE-AAR-LRC-TRANSIT
status: DRAFT
document_class: MOOSE_TECHNICAL_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-reviewed MOOSE methods used by the AAR LRC transit calibration
  - DCS evidence boundary for calibrated spawn, transit, track-altitude and fuel behavior
  - explicit record of failed Candidate-3/Candidate-4 assumptions
not_authoritative_for:
  - final production acceptance before the promoted controller is retested in DCS
  - exact KC-135R performance data outside the documented OMW calibration model
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/aar-fuel-telemetry-calibration
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# MOOSE – AAR LRC Transit Calibration

## Gepinnter Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## Geschwindigkeitsvertrag

Die AAR-Tests zeigen, dass MOOSE-/DCS-Speedwerte nicht ohne Bedeutungsprüfung mit beobachteter IAS oder Groundspeed gleichgesetzt werden dürfen.

```text
IAS / KIAS = angezeigte aerodynamische Geschwindigkeit
TAS        = wahre Geschwindigkeit relativ zur Luftmasse
GS         = Geschwindigkeit über Grund, einschließlich Windeinfluss
```

Für OMW gilt nach der Kalibrierung:

```text
SPAWN:InitSpeedKnots(480) = initialer In-Air-Materialisierungszustand
MOOSE route speed 300 kt  = Transit-Routenkommando
track speed               = area-/profile-spezifischer Missionswert
```

`480 kt` ist weder als `480 KIAS` noch als permanenter `480 kt GS`-Befehl zu interpretieren. Der frühere `300 kt`-Spawnzustand war in großer Höhe zu energiearm; der 480-kt-Kandidat zeigte im realen DCS-Lauf einen plausiblen Materialisierungszustand.

## Directional LRC

OMW verwendet feste geplante LRC-Reiseflughöhen und keinen routinemäßigen fuel-/weight-basierten Step-Climb.

```text
000-179 deg magnetic -> odd flight level
180-359 deg magnetic -> even flight level
```

Daraus gilt:

```text
MANAS -> Afghanistan:      FL340
Afghanistan -> MANAS:      FL350
AL_UDEID -> Afghanistan:   FL350
Afghanistan -> AL_UDEID:   FL340
```

Das sind OMW-Planungswerte, keine Behauptung einer historischen KC-135R-Optimum-Altitude-Tabelle.

## Primärvertrag FIR und External Handoff

Der produktive Routingvertrag bleibt unverändert:

```text
External Spawn
-> AUFTRAG:SetMissionIngressCoord(EGPAN/PINAX/DAVER)
-> AAR track
-> AUFTRAG:SetMissionEgressCoord(EGPAN/PINAX/DAVER)
-> physical FIR egress passage
-> FLIGHTGROUP:AddWaypoint(external handoff)
```

Candidate 3 ersetzte den FIR-Ingress unzulässig durch einen berechneten 60-NM-Late-Approach. Der reale DCS-Lauf zeigte keine zuverlässige PINAX-/DAVER-Passage. Dieser Ansatz ist verworfen.

Candidate 4 stellte den FIR-Ingress über EGPAN/PINAX/DAVER wieder her und bestätigte die Passage aller drei Fixes. Der zusätzliche Late-Approach-Adapter scheiterte dagegen, weil am gewählten Zeitpunkt keine verwendbare MOOSE-Mission-Waypoint-UID verfügbar war. Timer-Tuning ist kein akzeptierter Produktionsweg.

Der 60-NM-Late-Approach ist nach Owner-Entscheidung optional und für die Produktionskalibrierung nicht erforderlich.

## Exact Track Altitude

Der gepinnte MOOSE-Source-Review zeigt für den von `NewTANKER` genutzten ORBIT-Pfad ein Default-Missionshöhenverhalten von 90 Prozent der Orbit-Höhe. OMW setzt deshalb die gewünschte Track-Höhe explizit über die vorhandene öffentliche MOOSE-Methode:

```lua
mission:SetMissionAltitude(profile.altitudeFt)
```

Candidate 5 verwendete diesen Pfad zusammen mit den bestehenden MOOSE-Ingress-/Egress-Methoden. Die sechs Track-Lifecycles liefen vollständig bis External Handoff durch.

## Source-verifizierte und verwendete MOOSE-Methoden

```text
SPAWN:InitSpeedKnots(SpeedKnots)
AUFTRAG:NewTANKER(...)
AUFTRAG:SetMissionIngressCoord(Coordinate, Altitude, Speed)
AUFTRAG:SetMissionAltitude(Altitude)
AUFTRAG:SetMissionEgressCoord(Coordinate, Altitude, Speed)
AUFTRAG:Cancel()
FLIGHTGROUP:AddMission(Mission)
FLIGHTGROUP:AddWaypoint(Coordinate, Speed, AfterWaypointWithID, Altitude, Updateroute)
FLIGHTGROUP:SetFuelLowThreshold(...)
FLIGHTGROUP:SetFuelLowRTB(false)
COORDINATE:Get2DDistance(TargetCoordinate)
UNIT:GetFuel()
UNIT:GetCurrentFuelKgs()
UNIT:GetFuelMassMax()
```

Im gepinnten `Moose.lua` wurde **keine** öffentliche `SPAWN:InitFuel(...)`-Methode nachgewiesen. OMW erfindet daher keinen Fuel-Setter. Die produktive Lua führt den genehmigten Initial-Fuel-Wert als Vertrag/Metadatum; der physische Tankinhalt des KC-135-Templates muss im Mission Editor eingestellt werden.

## Candidate 5 – Outbound Fuel Telemetry

Dokumentierter Owner-DCS-Lauf:

```text
Testdatum: 2026-08-16
Branch: agent/aar-fuel-telemetry-calibration
Source commit: 40965420d4c6dea7a6b0fa27b4e3cd80d2a2b26a
Builder/Test-ID: AAR-FUEL-TELEMETRY-5
Mission: OMW_Template_v10_AirOps_rdy.miz
Mission SHA-256: 9dbff62a28e858d6eaf85d9037399dd591dd64edeccbe39bc74ecc63c43b6ca3
Bundle SHA-256: dd2386bd5bb2b0d2f89ac4e225a2e76ab171df1008f1d46eda16a9757c592a94
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Result: PASS
```

Harness-Endzustand:

```text
RESULT PASS allTracks=6 samplesPerTrack=6
points=SPAWN,INGRESS,TRACK,TRACK_DEPARTURE,FIR_EGRESS,EXTERNAL_HANDOFF
fuelLowExcluded=true
```

Gemessener `TRACK_DEPARTURE -> EXTERNAL_HANDOFF`-Verbrauch:

| Area | Burn |
|---|---:|
| NELSON | 5.6753 % |
| PATTY | 9.0161 % |
| LISA | 17.7909 % |
| MOE | 13.4644 % |
| MILHOUSE | 8.1344 % |
| KRUSTY | 8.5073 % |

Der Lauf bestätigt für diesen exakten Candidate-5-Stand die natürliche FIR-Egress-Passage und den External Handoff aller sechs Tracks unter dem directional LRC-/Exact-Altitude-Kandidaten. Er ist noch **keine** finale Production-Acceptance des anschließend promovierten Controllers.

## FuelLow-Kalibrierung

Berechnungsmodell:

```text
FuelLow =
real gemessener TRACK_DEPARTURE -> EXTERNAL_HANDOFF burn
+ virtueller EXTERNAL_HANDOFF -> source-base burn
+ 45-minute reserve

planned landing fuel >= 13,000 lb
```

Test-4-Domainbasis für den virtuellen Off-map-Restflug:

```text
KC-135 max fuel: 90,700 kg
MANAS:     25.98 kg/NM over 300.005 NM -> 8.5933 %
AL_UDEID:  24.97 kg/NM over 746.241 NM -> 20.5443 %
```

Die 45-Minuten-Reserve ist für alle sechs Tracks größer als der 13,000-lb-Planungsfloor und kontrolliert daher die aktuelle Berechnung.

| Area | Raw FuelLow | genehmigter Trigger |
|---|---:|---:|
| NELSON | 23.8168 % | 24 % |
| PATTY | 25.5303 % | 26 % |
| LISA | 34.0025 % | 35 % |
| MOE | 30.5285 % | 31 % |
| MILHOUSE | 35.3534 % | 36 % |
| KRUSTY | 35.6899 % | 36 % |

Die Ganzzahlwerte werden konservativ aufgerundet, damit der operative Trigger die berechnete Recovery-Anforderung nicht unterschreitet.

## Initial Fuel

Aus der Test-4-Domainrate und dem virtuellen Source-Base -> External-Spawn-Flug sind genehmigt:

```text
MANAS:     91.4067 %
AL_UDEID:  79.4558 %
```

Wichtig: Candidate 5 zeigte zugleich, dass `initialFuelPct` im bisherigen Controller nur Metadatum war; die physische Spawnmenge stammte aus dem `.miz`-Template. Die Promotion dieser Werte in Lua dokumentiert daher den Vertrag, ersetzt aber keine Mission-Editor-Änderung.

## Nachweisgrenze

```text
Candidate 3 late-ingress approach: REJECTED
Candidate 4 FIR restoration: PASS for observed FIR passage
Candidate 4 late-approach UID adapter: FAILED / not validated
Candidate 5 outbound telemetry: PASS for six-point fuel/lifecycle measurement
Production-promoted calibration: DCS acceptance still pending
```

`VALIDATED` für den Produktionsstand wird erst nach einem DCS-Lauf der promovierten Produktionsquelle mit vollständiger Commit-/Mission-/Bundle-/DCS-/MOOSE-Provenienz vergeben.