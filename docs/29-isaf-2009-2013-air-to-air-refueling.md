---
document_id: OMW-AAR-ISAF-ACO
status: BINDING_PROJECT_DECISION
document_class: SOURCE_DERIVED_DESIGN_REFERENCE
source_status: SOURCE_CAPTURE_COMPLETE
owning_policy: OMW-GOV-001
authoritative_for:
  - OMW AAR-area and ACO mission-design reference for Afghanistan 2009-2013
  - source-derived tanker-area geometry and planning constraints
  - OMW 2011-compatible corrected AAR production-planning geometry
  - OMW operational AAR standard/reserve roles and source-domain decisions
  - current production-facing FAST/SLOW, callsign-family, FIR-entry/exit, transit and fuel rules
  - OMW off-map KC-135 strategic design stock and lifecycle semantics
  - AAR production integration status and remaining acceptance work
not_authoritative_for:
  - historical operational ACO authenticity
  - undocumented DCS behavior outside the recorded acceptance scope
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - earlier AAR planning without consolidated runtime evidence and operational source-domain decisions
superseded_by:
source_branch: main
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# 29 – ISAF 2009–2013: Air-to-Air Refuelling und OMW-AAR-Baseline

## 1. Einordnung und Evidenzgrenze

Dieses Dokument ist die verbindliche AAR-Planungs- und Designreferenz für **Operation Mountain Watch**. Der vollständige frühere Quellen-, Tabellen-, KMZ- und CombatFlite-Auswertungstext bleibt als Source-Evidence erhalten:

- [`Legacy-AAR-/ACO-Quellenfassung`](evidence/source-records/legacy-29-isaf-aar-aco-source-capture.md)

Ergänzend gelten:

- [`OMW-AIR-TASKING-AIRSPACE-CAS-REQUESTS`](54-air-tasking-airspace-control-cas-requests-and-mission-data.md)
- [`OMW-AIR-AFGHANISTAN-AIP-2008`](72-afghanistan-aip-2008-airspace-aerodromes-and-flight-procedures.md)
- [`OMW-MOOSE-ISR-FAC-CAS-AAR`](moose/ISR-FAC-CAS-AAR.md)
- [`OMW-MOOSE-AAR-LRC-TRANSIT`](moose/AAR-LRC-TRANSIT.md)
- [`OMW-ARCH-CAMPAIGN-STATE`](04-campaign-state.md)

AIP-Reporting-Points und Airways belegen die veröffentlichte Airspace-Struktur. Sie beweisen nicht, dass konkrete historische KC-135-Sorties exakt diesen Routen folgten. OMW-Callsigns, Tracks, Verfügbarkeitsregeln, Transitwerte, Fuel-Schwellen und Designbestände sind Projektentscheidungen, soweit nicht ausdrücklich anders gekennzeichnet.

## 2. Verbindliche Track-Geometrie

Die produktive Track-Geometrie steht in:

```text
data/air-operations/aar/omw-2011-aar-areas.csv
data/air-operations/aar/omw-2011-aar-areas.geojson
```

Alle 19 Areas bleiben als Geometrien erhalten. Die sechs operativen Areas sind Track-/Area-Namen, keine Tankernamen. KC-135-Templates tragen die Area im Namen zur eindeutigen Konfiguration und bleiben an ihre Area gebunden.

## 3. Operatives AAR-Netz

| Area | Rolle | Profil | Source | Verfügbarkeit | FIR Fix | Callsign-Familie |
|---|---|---|---|---|---|---|
| `NELSON` | primärer Fast-Jet-Support | FAST | MANAS | STANDARD | EGPAN | Texaco |
| `PATTY` | primärer A-10-/RC-East-Support | SLOW | MANAS | STANDARD | EGPAN | Texaco |
| `MILHOUSE` | A-10 Recovery / Kandahar Return | SLOW | AL_UDEID | STANDARD | DAVER | Shell |
| `KRUSTY` | A-10 Recovery East / Southeast | SLOW | AL_UDEID | STANDARD | DAVER | Arco |
| `LISA` | RC-West / Shindand | FAST | AL_UDEID | RESERVE | DAVER | Texaco |
| `MOE` | Swing / Reserve / Central Support | FAST | MANAS | RESERVE | PINAX | Texaco |

Maschinenlesbar:

- `data/air-operations/aar/omw-2011-aar-operational-core.csv`

Bis eine belastbare ATO-/Zeitfensterregel entwickelt und genehmigt ist, laufen die vier STANDARD-Tracks kontinuierlich. `LISA` und `MOE` sind RESERVE und werden nur bei passendem MissionDemand materialisiert. Das Ende des letzten zugehörigen Demands ordnet Egress an.

Die LISA-Zuordnung `AL_UDEID / DAVER` ist eine ausdrückliche OMW-Designentscheidung vom 16.08.2026. Ausschlaggebend ist die deutlich kürzere sichtbare Reserve-Reaktionsstrecke DAVER->LISA gegenüber PINAX->LISA. Der erwartete Fuelstand am Track ist dabei niedriger als aus MANAS; die Entscheidung wird deshalb nicht als Fuel-Optimierung begründet.

## 4. Tankeridentität und Fuel-Vertrag

Ein physischer Tanker behält seine Callsign-Familie und konkrete `n-1`-Gruppenidentität während seiner gesamten Sortie. Relief ist eine neue 1-Ship-Gruppe derselben Familie mit anderer freier Gruppennummer.

```text
NELSON/PATTY/LISA/MOE -> Texaco n-1
KRUSTY                 -> Arco n-1
MILHOUSE               -> Shell n-1
```

Track-Identität besteht aus Area, Funkfrequenz und TACAN. Radio/TACAN werden nur beim Stationsbesitz aktiviert und vor Egress deaktiviert.

| Area | Frequenz | TACAN | Initial Fuel | FuelLow |
|---|---:|---|---:|---:|
| `NELSON` | 384.400 AM | 47Y `NEL` | 91.4067 % | 24 % |
| `PATTY` | 237.300 AM | 48Y `PAT` | 91.4067 % | 26 % |
| `LISA` | 235.900 AM | 50Y `LIS` | 79.4558 % | 38 % |
| `MOE` | 243.400 AM | 52Y `MOE` | 91.4067 % | 31 % |
| `KRUSTY` | 258.300 AM | 42Y `KRU` | 79.4558 % | 36 % |
| `MILHOUSE` | 272.600 AM | 58Y `MIL` | 79.4558 % | 36 % |

Die Initial-Fuel-Werte bilden den virtuellen Flug von MANAS beziehungsweise AL_UDEID bis zum jeweiligen External Spawn ab. Im gepinnten MOOSE-Stand ist keine öffentliche `SPAWN:InitFuel(...)`-Methode nachgewiesen. Der Controller führt die Werte daher als Konfigurationsvertrag/Metadatum; die physische Fuel-Menge der KC-135-Templates wird im Mission Editor gesetzt.

Für NELSON/PATTY/MOE/KRUSTY/MILHOUSE basiert FuelLow auf der dokumentierten Candidate-5-Messung plus virtuellem Rückflug und 45-Minuten-Reserve. LISA=38 % ist die konservative Neuberechnung für die neue südliche Source Domain und bleibt bis Acceptance 7 ein DCS-zu-validierender Candidate-Wert.

Für Link-16 erzwingt OMW keine `SPAWN:InitSTN(...)`. OMW liest die materialisierte STN über `UNIT:GetSTN()` nur als Runtime-Telemetrie/Identitätsprüfung.

## 5. External Spawn, FIR und 60-NM Late Approach

```text
EXTERNAL SPAWN
= technischer Materialisierungspunkt außerhalb der Kabul FIR

FIR INGRESS FIX
= veröffentlichter Eintritt in die Kabul FIR

60-NM LATE APPROACH
= Punkt entlang FIR-Fix -> Track, exakt 60 NM vor dem Track

TRACK
= AAR Area / Racetrack

FIR EGRESS FIX
= veröffentlichter Austritt aus der Kabul FIR

EXTERNAL HANDOFF / DESPAWN
= technischer Abschluss außerhalb der Kabul FIR
```

Verbindlicher Candidate-Pfad:

```text
External Spawn
-> FIR Ingress Fix @ inbound LRC altitude
-> 60-NM Late Approach @ inbound LRC altitude
-> descent on final inbound leg
-> exact AAR Track altitude
-> AAR Track
-> climb toward outbound LRC altitude
-> FIR Egress Fix @ outbound LRC altitude
-> External Handoff
-> Despawn / exact-once strategic settlement
```

Zuordnung:

```text
NELSON / PATTY    -> MANAS / EGPAN
MOE               -> MANAS / PINAX
LISA              -> AL_UDEID / DAVER
KRUSTY / MILHOUSE -> AL_UDEID / DAVER
```

External Points:

```text
MANAS:     N38.83163 E70.95271
AL_UDEID:  N28.90264890 E64.61166667
```

FIR-Fixes:

```text
EGPAN: N38°25'00" E70°44'00"
PINAX: N37°15'00" E69°06'00"
DAVER: N29°34'18" E64°40'36"
```

DAVER-Evidenzgrenze: Die 2011er AIP enthält zwischen ENR-Route-/Navfix-Daten und ENR 1.10 eine widersprüchliche DAVER-Koordinate. OMW verwendet die projektseitig etablierte M375-/Navfix-Koordinate. Die Quelleninkonsistenz bleibt offen.

Vollständiges Lower-/Upper-Airway-Routing zwischen FIR-Fix und Track bleibt optional/später.

## 6. Kalibrierter Transitvertrag und Inbound-Routing

Gepinnter MOOSE-Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

```text
SPAWN:InitSpeedKnots(480) = initiale In-Air-Materialisierung
route speed 300 kt        = Transit-Routenkommando
track speed               = area-/profile-spezifischer Missionswert
```

Directional LRC:

```text
MANAS -> Afghanistan:      FL340
Afghanistan -> MANAS:      FL350
AL_UDEID -> Afghanistan:   FL350
Afghanistan -> AL_UDEID:   FL340
```

Die Track-Höhe wird explizit gesetzt:

```lua
mission:SetMissionAltitude(profile.altitudeFt)
```

Der 60-NM-Late-Approach verwendet ausschließlich öffentliche, im gepinnten `Moose.lua` geprüfte MOOSE-Funktionen/FSMs:

```text
COORDINATE:GetIntermediateCoordinate(...)
FLIGHTGROUP:AddWaypoint(...)
FLIGHTGROUP / OPSGROUP PassingWaypoint
FLIGHTGROUP OnAfterPassingWaypoint(...)
FLIGHTGROUP:AddMission(...)
```

Die Reihenfolge wird technisch erzwungen: Der FIR-Fix und danach der 60-NM-Punkt werden zuerst als echte FLIGHTGROUP-Wegpunkte auf inbound LRC-Höhe geroutet. Erst wenn MOOSE über `OnAfterPassingWaypoint` die Passage des 60-NM-Wegpunkts meldet, wird der Tanker-AUFTRAG hinzugefügt. `AUFTRAG:SetMissionIngressCoord(...)` wird für diesen Inbound-Pfad nicht verwendet.

Damit wird der im ersten Acceptance-7-Lauf beobachtete Fehler beseitigt, bei dem ein bereits hinzugefügter AUFTRAG den vorgeschalteten FIR-Wegpunkt in der tatsächlich geflogenen Route umging.

## 7. MOOSE-first Routing und Fuel-Lifecycle

Produktiv relevant und im gepinnten Source geprüft:

```text
AUFTRAG:NewTANKER(...)
AUFTRAG:SetMissionAltitude(...)
AUFTRAG:SetMissionEgressCoord(...)
AUFTRAG:Cancel()

SPAWN:InitCallSign(...)
SPAWN:InitSpeedKnots(...)
UNIT:GetSTN()

FLIGHTGROUP:AddWaypoint(...)
FLIGHTGROUP:AddMission(...)
FLIGHTGROUP / OPSGROUP PassingWaypoint
FLIGHTGROUP OnAfterPassingWaypoint(...)
FLIGHTGROUP:SetFuelLowThreshold(...)
FLIGHTGROUP:SetFuelLowRTB(false)
FLIGHTGROUP FuelLow
FLIGHTGROUP Dead / OnAfterDead

OPSGROUP:SwitchRadio(...)
OPSGROUP:TurnOffRadio()
OPSGROUP:SwitchTACAN(...)
OPSGROUP:TurnOffTACAN()
OPSGROUP:Despawn(...)

COORDINATE:GetIntermediateCoordinate(...)
COORDINATE:Get2DDistance(...)
SCHEDULER:New(...)
```

## 8. Relief und MissionDemand

Scheduled Relief:

```text
1 ACTIVE
-> genau 1 RELIEF
-> gleiche Callsign-Familie, andere n-1-Gruppennummer
-> natürliche Route External Spawn -> FIR Fix -> 60-NM Late Approach -> Track
-> ETA <= 5 min armt nur Handover
-> outgoing bleibt ACTIVE bis reale Track-Ankunft
-> erst dann Station Owner wechseln, Radio/TACAN übertragen und outgoing Cancel/Egress
```

FuelLow:

```text
ACTIVE FuelLow
-> vorhandenen Relief wiederverwenden oder genau einen Emergency-Relief erzeugen
-> outgoing verlässt Station sofort und geht auf Egress
-> Ersatz übernimmt erst nach natürlicher Track-Ankunft
```

STANDARD-Demand-Ende schließt den kontinuierlichen Track nicht. RESERVE schließt nach Ende des letzten Demands und ordnet vorhandenen ACTIVE/RELIEF auf Egress.

## 9. Strategische Pools und CampaignState

```text
OFFMAP_MANAS
AIRCRAFT_KC135 = 16 count

OFFMAP_AL_UDEID
AIRCRAFT_KC135 = 40 count
```

CampaignState bleibt alleinige strategische Ressourcenautorität. MOOSE SPAWN/FLIGHTGROUP/AUFTRAG sind physische Repräsentationen.

```text
materialization
-> consume 1 AIRCRAFT_KC135

confirmed external handoff
-> exact-once +1 AIRCRAFT_KC135

aircraft loss
-> kein Aircraft-Recredit
-> exact-once +1 AIRCRAFT_KC135_LOST audit counter
```

## 10. Concurrency und Source Spacing

```text
Standard steady state: 4 Tanker
Reserve: +1 Tanker je geöffnetem Reserve-Track
pro Track maximal: 1 ACTIVE + 1 RELIEF

MANAS: mindestens 60 s zwischen zwei Materialisierungen
AL_UDEID: mindestens 60 s zwischen zwei Materialisierungen
MANAS und AL_UDEID dürfen parallel materialisieren
```

## 11. DCS-Evidenz

### 11.1 Frühere Production Final Acceptance

Der dokumentierte Acceptance-Stand auf `agent/aar-runtime-finalization` bestätigte vier STANDARD-/zwei RESERVE-Tracks, Scheduled Relief, FuelLow Immediate Egress, FIR-Fixes, External Handoff, Loss/Replacement und CampaignState exact-once Accounting. Die genaue Provenienz steht in `docs/moose/VERIFIED-METHODS.md`.

### 11.2 AAR Fuel Telemetry Candidate 5 – 16.08.2026

```text
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

### 11.3 Acceptance 6 – Beobachtete Restlücke

Der Acceptance-6-Lauf bestätigte den Produktions-Lifecycle, die kalibrierten Speed-/FL-/FuelLow-Werte sowie Egress/External-Handoff. Dabei wurde visuell festgestellt, dass die Tanker nach dem FIR-Ingress bereits auf Track-Höhe sanken. Diese Eigenschaft war vom Acceptance-6-Harness nicht geprüft und bleibt deshalb keine akzeptierte Zielwirkung.

Außerdem war LISA in Acceptance 6 weiterhin `MANAS / PINAX`. Beide Restpunkte werden im Acceptance-7-Candidate gemeinsam korrigiert.

### 11.4 Acceptance 7 Commit `00ed8e3` – abgebrochen

Der erste Acceptance-7-Lauf am 16.08.2026 bestätigte, dass der 60-NM-Höhenübergang grundsätzlich funktionierte. Gleichzeitig wurde visuell festgestellt, dass die vorgeschalteten FIR-Ingress-Punkte erneut umgangen wurden. Der Lauf wurde deshalb ausdrücklich abgebrochen und ist **kein** PASS.

Die Ursache liegt im Aufbau `AddWaypoint(FIR) -> AddMission(AUFTRAG mit Late-Approach-Ingress)`: Die AUFTRAG-Routenerzeugung konnte den vorher angefügten FIR-Wegpunkt in der tatsächlich geflogenen Route umgehen. Der korrigierte Candidate verschiebt `AddMission` deshalb hinter die physisch bestätigte Passage des Late-Approach-Wegpunkts.

## 12. Korrigierter finaler Acceptance-7-Candidate

Vom Projektinhaber am 16.08.2026 ausdrücklich gefordert:

```text
Hinflug:
SPAWNPUNKT
-> INGRESS-PUNKT
-> 60-NM-LATE-APPROACH-PUNKT
-> TRACK-START-PUNKT

Inbound LRC-/Transferhöhe:
fest bis einschließlich 60-NM-LATE-APPROACH

Rückflug:
ABBRUCHPUNKT auf TRACK
-> EGRESS-PUNKT
-> DESPAWN-PUNKT

Outbound LRC-/Transferhöhe:
ab Missionsabbruch / Verlassen der Mission
```

Weitere Candidate-Werte:

```text
Spawn initialization: 480 kt
Transit route:         300 kt

MANAS -> Afghanistan:      FL340
Afghanistan -> MANAS:      FL350
AL_UDEID -> Afghanistan:   FL350
Afghanistan -> AL_UDEID:   FL340

60-NM late approach: enabled
Exact track mission altitude: enabled

LISA:
Source = AL_UDEID
FIR Fix = DAVER
Availability = RESERVE
Initial Fuel = 79.4558 %
FuelLow = 38 %

Other FuelLow:
NELSON:    24 %
PATTY:     26 %
MOE:       31 %
MILHOUSE:  36 %
KRUSTY:    36 %
```

Der letzte Abnahmelauf muss neben den bestehenden Lifecycle-Gates ausdrücklich nachweisen:

```text
- LISA und MOE starten nicht automatisch;
- LISA wird durch MissionDemand aus AL_UDEID über DAVER materialisiert;
- FIR-Passage erfolgt als echter MOOSE-Waypoint vor dem Late-Approach;
- FIR PassingWaypoint-Zeitpunkt <= Late-Approach PassingWaypoint-Zeitpunkt;
- AUFTRAG wird nicht vor Late-Approach-Passage hinzugefügt;
- Tanker halten die LRC-Höhe bis zum 60-NM-Late-Approach;
- danach erfolgt der Übergang auf die exakte Track-Höhe;
- Egress steigt weiterhin auf die outbound LRC-Höhe;
- Scheduled Relief, FuelLow Relief, Loss/Replacement und CampaignState-Settlement regressieren nicht.
```

Erst nach realem korrigiertem Acceptance-7-PASS wird das endgültige Missions-AAR-Grundgerüst erstellt. Dieses enthält **keine test-only Verlustinjektion und keine künstliche FuelLow-Auslösung**. Die vier STANDARD-Tracks werden kontinuierlich erhalten; `LISA` und `MOE` bleiben standardmäßig inaktiv und werden ausschließlich über den produktiven MissionDemand-Vertrag geöffnet.
