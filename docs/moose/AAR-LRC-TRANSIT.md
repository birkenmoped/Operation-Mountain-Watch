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
  - final production acceptance before the current controller candidate is retested in DCS
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

Für OMW gilt nach der Kalibrierung:

```text
SPAWN:InitSpeedKnots(480) = initialer In-Air-Materialisierungszustand
MOOSE route speed 300 kt  = Transit-Routenkommando
track speed               = area-/profile-spezifischer Missionswert
```

`480 kt` ist weder als permanenter KIAS- noch als Groundspeed-Befehl zu interpretieren. Der 480-kt-Kandidat zeigte im realen DCS-Lauf einen plausiblen Materialisierungszustand.

## Directional LRC

```text
MANAS -> Afghanistan:      FL340
Afghanistan -> MANAS:      FL350
AL_UDEID -> Afghanistan:   FL350
Afghanistan -> AL_UDEID:   FL340
```

Kein routinemäßiger fuel-/weight-basierter Step-Climb.

## FIR, 60-NM Late Approach und External Handoff

Der finale Candidate trennt die reale FIR-Passage vom AUFTRAG-Ingress:

```text
External Spawn
-> public FLIGHTGROUP:AddWaypoint(FIR fix, inbound LRC altitude)
-> AUFTRAG:SetMissionIngressCoord(60-NM late-approach point, inbound LRC altitude)
-> mission waypoint / exact AAR track altitude
-> AAR track
-> AUFTRAG:SetMissionEgressCoord(FIR fix, outbound LRC altitude)
-> physical FIR egress passage
-> FLIGHTGROUP:AddWaypoint(external handoff, outbound LRC altitude)
```

Der Late-Approach-Punkt liegt entlang der geraden FIR-Fix->Track-Geometrie exakt 60 NM vor dem Track und wird mit der öffentlichen Methode `COORDINATE:GetIntermediateCoordinate(...)` berechnet. Der reale FIR-Fix bleibt ausdrücklich als eigener MOOSE-FLIGHTGROUP-Wegpunkt erhalten.

Damit wird der in Candidate 3 verworfene Ansatz **nicht** wiederholt: Candidate 3 ersetzte den FIR-Ingress durch den Late-Approach. Candidate 4 stellte den FIR-Fix wieder her, scheiterte aber mit einem UID-/Timing-basierten nachträglichen Adapter. Der finale Candidate verwendet weder Timer-Tuning noch undokumentierte MOOSE-Interna.

Dieser neue Pfad ist source-reviewed, aber bis zum vorgesehenen Acceptance-7-Lauf **nicht DCS-validiert**.

## LISA South Domain

Owner-Entscheidung 16.08.2026:

```text
LISA:
Profile: FAST
Availability: RESERVE
Source Domain: AL_UDEID
FIR Fix: DAVER
Initial Fuel contract: 79.4558 %
FuelLow candidate: 38 %
```

Die Verschiebung erfolgt wegen der deutlich kürzeren sichtbaren Reserve-Reaktionsstrecke DAVER->LISA, nicht wegen eines besseren Fuelstands am Track. Der neue FuelLow-Wert ist konservativ aus südlichem Return-Vertrag, 45-Minuten-Reserve und der für die südliche LISA-Geometrie abgeschätzten Rückflugkomponente abgeleitet und bleibt bis zum finalen DCS-Acceptance ein Kandidatenwert.

MOE bleibt `MANAS / PINAX`.

## Exact Track Altitude

Der gepinnte MOOSE-Source-Review zeigt für den von `NewTANKER` genutzten ORBIT-Pfad ein Default-Missionshöhenverhalten von 90 Prozent der Orbit-Höhe. OMW setzt deshalb die gewünschte Track-Höhe explizit:

```lua
mission:SetMissionAltitude(profile.altitudeFt)
```

## Source-verifizierte MOOSE-Methoden

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
COORDINATE:GetIntermediateCoordinate(ToCoordinate, Fraction)
COORDINATE:Get2DDistance(TargetCoordinate)
UNIT:GetFuel()
UNIT:GetCurrentFuelKgs()
UNIT:GetFuelMassMax()
```

Im gepinnten `Moose.lua` wurde keine öffentliche `SPAWN:InitFuel(...)`-Methode nachgewiesen. Die physische Template-Fuel-Menge bleibt Mission-Editor-Konfiguration.

## Candidate 5 – Outbound Fuel Telemetry

```text
Testdatum: 2026-08-16
Branch: agent/aar-fuel-telemetry-calibration
Source commit: 40965420d4c6dea7a6b0fa27b4e3cd80d2a2b26a
Builder/Test-ID: AAR-FUEL-TELEMETRY-5
Mission: OMW_Template_v10_AirOps_rdy.miz
Mission SHA-256: 9dbff62a28e858d6eaf85d9037399dd591dd64edeccbe39bc74ecc63c43b6ca3
Bundle SHA-256: dd2386bd5bb2b0d2f89ac4e225a2e76ab171df1008f1d46eda16a9757c592a94
DCS: 2.9.28.26385 MT
Result: PASS
```

Gemessener `TRACK_DEPARTURE -> EXTERNAL_HANDOFF`-Verbrauch des damaligen Routingstands:

| Area | Burn |
|---|---:|
| NELSON | 5.6753 % |
| PATTY | 9.0161 % |
| LISA | 17.7909 % |
| MOE | 13.4644 % |
| MILHOUSE | 8.1344 % |
| KRUSTY | 8.5073 % |

Der damalige LISA-Wert gehört zur früheren MANAS/PINAX-Geometrie und darf nicht als Messwert für die neue AL_UDEID/DAVER-Zuordnung ausgegeben werden.

## FuelLow-Basis

Planungsmodell:

```text
FuelLow =
TRACK_DEPARTURE -> EXTERNAL_HANDOFF burn
+ virtual EXTERNAL_HANDOFF -> source-base burn
+ 45-minute reserve

planned landing fuel >= 13,000 lb
```

Domainbasis:

```text
KC-135 max fuel: 90,700 kg
MANAS:     25.98 kg/NM over 300.005 NM -> 8.5933 %
AL_UDEID:  24.97 kg/NM over 746.241 NM -> 20.5443 %
```

Aktueller Candidate:

| Area | FuelLow |
|---|---:|
| NELSON | 24 % |
| PATTY | 26 % |
| LISA | 38 % |
| MOE | 31 % |
| MILHOUSE | 36 % |
| KRUSTY | 36 % |

Für NELSON/PATTY/MOE/MILHOUSE/KRUSTY stammen die Schwellen aus der dokumentierten Candidate-5-Kalibrierung. LISA=38 % ist die konservative Neuberechnung für die neue südliche Source Domain und muss im Acceptance-7-Lauf zusammen mit dem neuen Routing regressiert werden.

## Initial Fuel

```text
MANAS:     91.4067 %
AL_UDEID:  79.4558 %
```

LISA verwendet nach der Source-Domain-Umstellung den AL_UDEID-Wert. `initialFuelPct` im Controller ist Vertrag/Metadatum; der physische Tankinhalt stammt aus dem `.miz`-Template.

## Acceptance-7-Gate

Der letzte geplante Abnahmelauf muss mindestens bestätigen:

```text
4 STANDARD tracks initially active
LISA/MOE initially inactive
LISA demand -> AL_UDEID -> DAVER -> 60-NM late approach -> LISA track
MOE demand -> MANAS -> PINAX
high LRC altitude maintained until the late-approach segment
exact track altitude
scheduled MILHOUSE relief
NELSON FuelLow relief
PATTY loss/replacement
natural FIR ingress/egress
external handoff and exact-once CampaignState settlement
final steady state = 4 STANDARD / 0 RESERVE
```

Test-only Loss/FuelLow-Injektionen bleiben ausschließlich im Acceptance-Harness. Das anschließend zu erstellende Missionsgrundgerüst enthält keine künstliche Verlust- oder FuelLow-Auslösung.

## Nachweisgrenze

```text
Candidate 3 late-ingress approach: REJECTED
Candidate 4 FIR restoration: PASS for observed FIR passage
Candidate 4 UID late-approach adapter: FAILED / not validated
Candidate 5 outbound telemetry: PASS
Acceptance 6 lifecycle/calibrated production run: PASS for documented lifecycle scope; visual early-descent finding remains open
Acceptance 7 LISA south-domain + 60-NM late approach: DCS ACCEPTANCE PENDING
```

`VALIDATED` für den neuen Late-Approach-/LISA-Stand wird erst nach dem dokumentierten Acceptance-7-DCS-Lauf vergeben.