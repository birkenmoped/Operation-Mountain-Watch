---
document_id: OMW-TEST-AAR-KC135-RUNTIME-INDEX
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - KC-135 AAR runtime acceptance test layout
  - exact active template set and expected test markers
  - source-reviewed MOOSE paths used by the acceptance harness
not_authoritative_for:
  - DCS runtime acceptance before an owner-run test
  - final all-area FAST/SLOW matrix
  - historical tanker callsign authenticity
  - production MissionDemand/CampaignState activation logic
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by: []
source_branch: agent/aar-rc-east-runtime-scope
source_commit: GIT_HISTORY
validated_in_dcs: partial
---

# KC-135 AAR Runtime Acceptance

## 1. Gepinnter MOOSE-Stand

```text
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Der Acceptance-Pfad bleibt MOOSE-first. Kein MIST, kein nativer Event-Handler und keine automatisierte `.miz`-Mutation.

## 2. Bisherige Ergebnisse

```text
Acceptance-2:
5-KC-135 Stress-Test; alle EXECUTING, FuelLow/Cancel/Egress/Handoff PASS.
Fünf Tanker bleiben Testausnahme.

Acceptance-3:
HISTORICAL_TEST_FIXTURE; 47X TACAN, Heading, Speed und F-16-Recruiting-Probleme.

Acceptance-4:
Y-Band TACAN, Gate->Track Heading, 220/300 KIAS und F-16 Boom praktisch bestätigt.

Acceptance-5:
Nelson-Gate ~50 km NNE EGPAN, 60-s Post-Refuel-Dwell und Egress/Handoff praktisch bestätigt.
```

## 3. Acceptance-6 – ein kombinierter Volltest

Der Owner hat entschieden, jetzt alle fünf vorbereiteten KC-135 und die bisher geplanten Receiver in einem Lauf zu prüfen.

### Tanker

| Key | Template | Area/role | Altitude | Speed | Radio | TACAN |
|---|---|---|---:|---:|---:|---|
| SLOW | `OMW_AAR_KC135_CLANCY` | CLANCY SLOW | FL220 | 220 KIAS | 241.600 AM | 60Y / CLA |
| FAST | `OMW_AAR_KC135_PATTY` | CLANCY FAST | FL250 | 300 KIAS | 237.300 AM | 48Y / TX2 |
| HOMER | `OMW_AAR_KC135_HOMER` | HOMER | FL230 | 300 KIAS | 376.000 AM | 54Y / HOM |
| KRUSTY | `OMW_AAR_KC135_KRUSTY` | KRUSTY | FL260 | 300 KIAS | 258.300 AM | 42Y / KRU |
| NELSON | `OMW_AAR_KC135_NELSON` | NELSON | FL275 | 300 KIAS | 384.400 AM | 47Y / NEL |

FAST und SLOW benutzen gleichzeitig die Clancy-Geometrie und sind exakt 3.000 ft vertikal getrennt.

Materialisierung im Acceptance-Harness:

```text
t0:      SLOW + NELSON
t0+60:   FAST
t0+120:  HOMER
t0+180:  KRUSTY
```

### Mandatory Receiver

```text
A-10C:
SQ_US_KAF_A10C_74_EFS
TPL_AIR_US_KAF_A10C_CAS_2SHIP
-> SLOW

F-15E:
SQ_US_BGRM_F15E_335_EFS
TPL_AIR_US_BGRM_F15E_CAS_2SHIP
-> FAST

F-16C:
SQ_US_BGRM_F16C_121_EFS
TPL_AIR_US_BGRM_F16C_CAS_2SHIP
-> FAST
```

Alle drei verwenden test-only `AUFTRAG:SetMissionRange(250)`; produktive SQUADRON-Werte bleiben unverändert.

### Optionaler C-130J-30-Probe

Die vorhandene Test-`.miz` enthält:

```text
TPL_AIR_US_BGRM_C130_TRANSPORT_1SHIP
DCS type: C-130J-30
```

Weil die produktive C-130-SQUADRON eine Transport- und keine CAS-Capability besitzt, wird für den AAR-Probe kein künstlicher CAS-Auftrag erzeugt. Das vorhandene Template wird acceptance-only über MOOSE `SPAWN -> FLIGHTGROUP -> Refuel` getestet.

```text
C-130J-30 -> FAST
blocking=false
probe timeout=600 s
```

`OPTIONAL_C130_AAR_PASS` bestätigt den Probe; `OPTIONAL_C130_AAR_RESULT status=NOT_CONFIRMED` blockiert den übrigen Acceptance-6-PASS nicht.

## 4. MOOSE-Grenze der Donor-Zuordnung

`FLIGHTGROUP:Refuel(Coordinate)` nimmt keine konkrete Tanker-ID. Deshalb wird nach `Refueled` zusätzlich mit `COORDINATE:Get3DDistance()` geprüft, ob der intended Tanker räumlich der nächstgelegene der beiden Clancy-Tanker war.

```text
RECEIVER_TANKER_PROXIMITY_PASS
```

ist nur räumliche Inferenz, keine DCS/MOOSE-Donor-ID. Owner-Sichtbeobachtung bleibt erforderlich.

## 5. Abschlussbedingung

```text
all 5 tankers EXECUTING
+
A10 Refueled
+
F15E Refueled
+
F16 Refueled
+
optional C130 probe concluded
+
>=60 s after latest mandatory Refueled
-> accelerated FuelLow 99%
-> all five Cancel/Egress
-> <=10 NM gate
-> Despawn off-map handoff
```

## 6. Erwartete Kernmarker

```text
FIVE_TANKER_EXECUTING_PASS count=5
RECEIVER_MISSION_ADDED_PASS receiver=A10
RECEIVER_MISSION_ADDED_PASS receiver=F15E
RECEIVER_MISSION_ADDED_PASS receiver=F16
AI_BOOM_REFUELED_PASS receiver=A10
AI_BOOM_REFUELED_PASS receiver=F15E
AI_BOOM_REFUELED_PASS receiver=F16
RECEIVER_TANKER_PROXIMITY_PASS receiver=A10 ... nearestTanker=SLOW
RECEIVER_TANKER_PROXIMITY_PASS receiver=F15E ... nearestTanker=FAST
RECEIVER_TANKER_PROXIMITY_PASS receiver=F16 ... nearestTanker=FAST
OPTIONAL_C130_AAR_PASS
# or:
OPTIONAL_C130_AAR_RESULT status=NOT_CONFIRMED
RECEIVER_MATRIX_REFUEL_PASS mandatoryReceivers=A10,F15E,F16
POST_REFUEL_DWELL_PASS
ACCELERATED_FUEL_LOW_ARMED ... tankerCount=5
FUEL_LOW_PASS x5
EGRESS_GATE_PASS x5
```

## 7. Source / Builder / Dist

```text
mission/tests/aar-kc135-runtime/src/01-aar-kc135-runtime-acceptance.lua
tools/build-aar-kc135-runtime-acceptance.ps1
mission/tests/aar-kc135-runtime/dist/OMW_AAR_KC135_Runtime_Acceptance.lua
```

`dist/` ist builder-generated only.