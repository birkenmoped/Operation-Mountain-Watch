---
document_id: OMW-TEST-AAR-FUEL-CALIBRATION-TODO
status: DRAFT
document_class: WORKLIST
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local worklist for the current AAR fuel, speed and LRC transit recalibration workstream
  - current target state, completed findings and remaining production-acceptance steps
not_authoritative_for:
  - final production validation before the promoted source is rebuilt and retested in DCS
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/aar-fuel-telemetry-calibration
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# AAR Fuel / Speed / LRC Recalibration – To-do

## 1. Workstream

```text
Branch: agent/aar-fuel-telemetry-calibration
Workstream ID: OMW-TEST-AAR-FUEL-CALIBRATION-TODO
Calibration source commit: 40965420d4c6dea7a6b0fa27b4e3cd80d2a2b26a
```

Die `.miz` wird in diesem Workstream nicht durch ChatGPT verändert. Mission-Editor-Änderungen bleiben beim Projektinhaber.

## 2. Genehmigter Zielzustand

Vom Projektinhaber am 16.08.2026 genehmigt:

```text
SPAWN initial speed: 480 kt
Transit route speed: 300 kt

MANAS -> Afghanistan:      FL340
Afghanistan -> MANAS:      FL350
AL_UDEID -> Afghanistan:   FL350
Afghanistan -> AL_UDEID:   FL340

Exact track mission altitude: enabled
60-NM late approach: not required / not implemented

Initial Fuel:
MANAS:     91.4067 %
AL_UDEID:  79.4558 %

FuelLow:
NELSON:    24 %
PATTY:     26 %
LISA:      35 %
MOE:       31 %
MILHOUSE:  36 %
KRUSTY:    36 %
```

Unverändert bleiben CampaignState/off-map stock lifecycle, Callsign-Familien, STANDARD/RESERVE-Rollen, MissionDemand-Semantik und FIR/External-Trennung.

## 3. Abgeschlossene Kalibrierung

### 3.1 Speed

```text
SPAWN:InitSpeedKnots(480)
= initialer In-Air-Materialisierungszustand

MOOSE route speed 300 kt
= Transit-Routenkommando
```

Der 480-kt-Kandidat zeigte im DCS-Lauf einen plausiblen Materialisierungszustand; der frühere 300-kt-Spawnzustand war in großer Höhe zu energiearm.

### 3.2 Directional LRC

```text
MANAS inbound:      FL340
MANAS outbound:     FL350
AL_UDEID inbound:   FL350
AL_UDEID outbound:  FL340
```

Kein routinemäßiger fuel-/weight-basierter Step-Climb.

### 3.3 Exact Track Altitude

Pinned MOOSE source review:

```text
AUFTRAG:NewORBIT default missionAltitude = orbitAltitude * 0.9
```

Genehmigter Korrekturpfad:

```lua
mission:SetMissionAltitude(profile.altitudeFt)
```

### 3.4 FIR-Vertrag

```text
NELSON / PATTY    -> EGPAN
LISA / MOE        -> PINAX
KRUSTY / MILHOUSE -> DAVER
```

Candidate 3, der den FIR-Ingress durch einen Late-Approach ersetzte, bleibt verworfen. Candidate 4 stellte die reale FIR-Passage wieder her. Der zusätzliche UID-basierte 60-NM-Adapter scheiterte und ist nicht Produktionsanforderung.

## 4. Fuel-Basis

KC-135 DCS max fuel:

```text
90,700 kg
```

Test-4-Domainraten:

```text
MANAS:     25.98 kg/NM
AL_UDEID:  24.97 kg/NM
```

Virtual source-base -> External Spawn:

```text
MANAS:      300.005 NM -> initial fuel 91.4067 %
AL_UDEID:   746.241 NM -> initial fuel 79.4558 %
```

Im gepinnten `Moose.lua` wurde keine öffentliche `SPAWN:InitFuel(...)`-Methode nachgewiesen. `initialFuelPct` im Controller ist deshalb der projektseitige Vertrag/Metadatum; die physische Template-Menge muss im Mission Editor gesetzt werden.

## 5. Candidate 5 – Outbound Telemetry PASS

```text
Testdatum: 2026-08-16
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

```text
RESULT PASS allTracks=6 samplesPerTrack=6
points=SPAWN,INGRESS,TRACK,TRACK_DEPARTURE,FIR_EGRESS,EXTERNAL_HANDOFF
fuelLowExcluded=true
```

Gemessener `TRACK_DEPARTURE -> EXTERNAL_HANDOFF`-Burn:

| Area | Burn |
|---|---:|
| NELSON | 5.6753 % |
| PATTY | 9.0161 % |
| LISA | 17.7909 % |
| MOE | 13.4644 % |
| MILHOUSE | 8.1344 % |
| KRUSTY | 8.5073 % |

## 6. Final FuelLow calculation

Planungsregel:

```text
FuelLow =
measured TRACK_DEPARTURE -> EXTERNAL_HANDOFF
+ virtual EXTERNAL_HANDOFF -> source base
+ 45-minute reserve

planned landing fuel >= 13,000 lb
```

Die 45-Minuten-Reserve ist in allen sechs Fällen größer als der 13,000-lb-Floor und kontrolliert die Berechnung.

| Area | Raw FuelLow | Approved integer trigger |
|---|---:|---:|
| NELSON | 23.8168 % | 24 % |
| PATTY | 25.5303 % | 26 % |
| LISA | 34.0025 % | 35 % |
| MOE | 30.5285 % | 31 % |
| MILHOUSE | 35.3534 % | 36 % |
| KRUSTY | 35.6899 % | 36 % |

Die Integer-Trigger werden konservativ aufgerundet.

## 7. Production promotion status

Owner approval: **GRANTED 2026-08-16**.

Die kleinste Produktionsänderung ist auf diesem Branch umzusetzen:

```text
OMW_AAR_Controller.lua
- separate SPAWN_INITIAL_SPEED_KT = 480
- TRANSIT_SPEED_KT bleibt 300
- directional FL340/FL350
- mission:SetMissionAltitude(profile.altitudeFt)
- approved initialFuelPct contracts
- approved per-area FuelLow thresholds
```

Keine neue Native-DCS-Routing- oder Fuel-Setter-Logik. Kein 60-NM-Adapter. Keine `.miz`-Mutation durch ChatGPT.

## 8. Remaining gates

### Step A – Source/build gate

```text
- complete diff review
- production validator must assert calibrated constants and per-area values
- verify pinned MOOSE provenance
- documentation validator for changed docs
- remote commit/publish
```

### Step B – Owner local verification

Nach Remote-Publish nur:

```text
git pull
production source/build validation
hash verification
```

Nur reale Owner-Ausgabe ist Evidenz.

### Step C – Mission Editor

Nach bestandenem lokalen Source/Build-Gate setzt der Projektinhaber die physischen KC-135-Template-Fuelwerte:

```text
MANAS templates:
NELSON / PATTY / LISA / MOE -> 91.4067 %

AL_UDEID templates:
MILHOUSE / KRUSTY -> 79.4558 %
```

Die `.miz` wird danach separat gehasht.

### Step D – Final DCS production acceptance

Der promovierte Produktionsstand muss mit vollständiger Provenienz getestet werden. Zu regressieren sind mindestens:

```text
480-kt materialization
300-kt route command
directional FL340/FL350
exact track altitude
EGPAN/PINAX/DAVER ingress and egress
External Handoff
FuelLow trigger/recovery behavior
Scheduled Relief handover semantics
STANDARD/RESERVE lifecycle
Callsign family identity
60-s source spacing
CampaignState exact-once settlement
loss/replacement and restore behavior
```

Erst danach darf der promovierte Produktionsstand als `VALIDATED` bezeichnet und die Merge-/Readiness-Entscheidung getroffen werden.