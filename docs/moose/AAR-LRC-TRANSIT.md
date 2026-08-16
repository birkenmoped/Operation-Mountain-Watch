---
document_id: OMW-MOOSE-AAR-LRC-TRANSIT
status: DRAFT
document_class: MOOSE_TECHNICAL_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-reviewed MOOSE methods used by the AAR LRC transit calibration
  - DCS evidence boundary for calibrated spawn, transit, track-altitude and fuel behavior
  - explicit record of failed Candidate-3/Candidate-4/initial-Acceptance-7 assumptions
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

## Verbindliche Inbound-Sequenz

Owner-Bestätigung 16.08.2026:

```text
SPAWNPUNKT
-> INGRESS-PUNKT
-> 60-NM-LATE-APPROACH-PUNKT
-> TRACK-START-PUNKT
```

Die festgelegte inbound LRC-/Transferhöhe wird vom Spawn bis einschließlich 60-NM-Late-Approach gehalten. Erst nach dessen Passage darf die Transition auf die exakte Track-Höhe beginnen.

Der erste Acceptance-7-Ansatz auf Commit `00ed8e33e05d1c88295a44ae4bda34f18e90f4ca` war technisch falsch aufgebaut:

```text
FLIGHTGROUP:AddWaypoint(FIR fix)
-> AUFTRAG:SetMissionIngressCoord(60-NM point)
-> FLIGHTGROUP:AddMission(AUFTRAG)
```

Im realen DCS-Lauf vom 16.08.2026 funktionierte zwar der 60-NM-Höhenübergang, die Tanker ignorierten jedoch erneut die vorgeschalteten FIR-Ingress-Punkte. Der Lauf wurde deshalb abgebrochen. Dieser Stand ist nicht akzeptiert und darf nicht als funktionierendes FIR-Routing dokumentiert werden.

## Korrigierter MOOSE-first-Pfad

Der gepinnte MOOSE-Source bestätigt:

```text
FLIGHTGROUP:AddWaypoint(Coordinate, Speed, AfterWaypointWithID, Altitude, Updateroute)
-> gibt die erzeugte Waypoint-Tabelle mit uid zurück

OPSGROUP / FLIGHTGROUP PassingWaypoint FSM
-> OnAfterPassingWaypoint(..., Waypoint)
-> Waypoint.uid ist verfügbar

FLIGHTGROUP:AddMission(AUFTRAG)
-> weist den Auftrag dem Flug erst zu diesem Zeitpunkt zu
```

Daraus wird der neue Candidate strikt gestuft:

```text
External Spawn
-> FLIGHTGROUP:AddWaypoint(FIR fix, inbound LRC altitude)
-> FLIGHTGROUP:AddWaypoint(60-NM late approach, inbound LRC altitude)
-> OnAfterPassingWaypoint confirms FIR waypoint UID
-> OnAfterPassingWaypoint confirms late-approach waypoint UID
-> only now FLIGHTGROUP:AddMission(tanker AUFTRAG)
-> descent / exact AAR track altitude
-> AAR track
```

`AUFTRAG:SetMissionIngressCoord(...)` wird im korrigierten Inbound-Pfad bewusst nicht verwendet. Der AUFTRAG wird erst nach bestätigter Passage des Late-Approach-Wegpunkts hinzugefügt. Damit kann die AUFTRAG-Routenerzeugung den FIR-Wegpunkt nicht vor dessen physischer Passage ersetzen.

Der Late-Approach-Punkt liegt entlang der geraden FIR-Fix->Track-Geometrie exakt 60 NM vor dem Track und wird mit `COORDINATE:GetIntermediateCoordinate(...)` berechnet.

Dieser Pfad verwendet ausschließlich öffentliche MOOSE-Methoden/FSM-Callbacks; kein Timer-Tuning, keine Teleports und keine nicht dokumentierten MOOSE-Interna.

## Rückflug / Egress

Der bereits funktionierende Rückflugvertrag bleibt unverändert:

```text
ABBRUCHPUNKT auf TRACK
-> AUFTRAG:SetMissionEgressCoord(FIR egress fix, outbound LRC altitude)
-> physical FIR egress passage
-> FLIGHTGROUP:AddWaypoint(external handoff, outbound LRC altitude)
-> external handoff / despawn
```

Die outbound LRC-/Transferhöhe gilt ab Missionsabbruch beziehungsweise Verlassen der Tankermission. An diesem funktionierenden Pfad wird für die Ingress-Korrektur nichts konzeptionell geändert.

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

Die Verschiebung erfolgt wegen der deutlich kürzeren sichtbaren Reserve-Reaktionsstrecke DAVER->LISA, nicht wegen eines besseren Fuelstands am Track. MOE bleibt `MANAS / PINAX`.

## Exact Track Altitude

Der gepinnte MOOSE-Source-Review zeigt für den von `NewTANKER` genutzten ORBIT-Pfad ein Default-Missionshöhenverhalten von 90 Prozent der Orbit-Höhe. OMW setzt deshalb die gewünschte Track-Höhe explizit:

```lua
mission:SetMissionAltitude(profile.altitudeFt)
```

## Source-verifizierte MOOSE-Methoden

```text
SPAWN:InitSpeedKnots(SpeedKnots)
AUFTRAG:NewTANKER(...)
AUFTRAG:SetMissionAltitude(Altitude)
AUFTRAG:SetMissionEgressCoord(Coordinate, Altitude, Speed)
AUFTRAG:Cancel()
FLIGHTGROUP:AddMission(Mission)
FLIGHTGROUP:AddWaypoint(Coordinate, Speed, AfterWaypointWithID, Altitude, Updateroute)
FLIGHTGROUP / OPSGROUP PassingWaypoint FSM
FLIGHTGROUP OnAfterPassingWaypoint callback override
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

Der korrigierte letzte Abnahmelauf muss mindestens bestätigen:

```text
4 STANDARD tracks initially active
LISA/MOE initially inactive
physical order SPAWN -> FIR -> 60-NM late approach -> track
FIR waypoint event before late-approach waypoint event
AUFTRAG added no earlier than late-approach passage
LISA demand -> AL_UDEID -> DAVER -> 60-NM late approach -> LISA track
MOE demand -> MANAS -> PINAX
high LRC altitude maintained until the late-approach segment
exact track altitude
scheduled MILHOUSE relief
NELSON FuelLow relief
PATTY loss/replacement
natural FIR egress
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
Acceptance 6 lifecycle/calibrated production run: PASS for documented lifecycle scope; visual early-descent finding remained open
Acceptance 7 commit 00ed8e3: ABORTED / FIR ingress bypassed; 60-NM altitude transition observed working
Corrected staged Acceptance 7: SOURCE_REVIEWED / DCS ACCEPTANCE PENDING
```

`VALIDATED` für den neuen Late-Approach-/LISA-Stand wird erst nach dem dokumentierten korrigierten Acceptance-7-DCS-Lauf vergeben.
