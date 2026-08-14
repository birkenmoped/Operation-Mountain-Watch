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

Der Acceptance-Pfad bleibt MOOSE-first. Verwendet werden insbesondere `SPAWN`, `FLIGHTGROUP`, `AUFTRAG`, `AIRWING`, `SQUADRON`, `COORDINATE` und `SCHEDULER`. Kein MIST, kein nativer Event-Handler und keine automatisierte `.miz`-Mutation.

## 2. Bisherige Acceptance-Ergebnisse

### Acceptance-2

Owner-run Stress-Test mit fünf vorbereiteten KC-135. Alle erreichten `EXECUTING`, 180-s-Dwell, FuelLow/Cancel/Egress und <=10-NM-Off-map-Handoff. Fünf gleichzeitige Tanker bleiben eine Testausnahme; die Produktionsgrenze bleibt zwei Supportmissionen.

### Acceptance-3

Historisches Testfixture mit Teilfehlern: 47X ohne nutzbaren F-16-TACAN-Empfang, Nelson falsche Anfangsausrichtung, 300 KIAS für Clancy/A-10 ungeeignet, Bagram-F-16 nicht materialisiert.

### Acceptance-4

Korrigierte Y-Band-TACAN-Konfiguration, Spawn-Heading Gate->Track, Clancy 220 KIAS, Nelson 300 KIAS und test-only F-16-MissionRange 250 NM. Owner bestätigte 60Y/CLA und 47Y/NEL im F-16-Cockpit sowie beide F-16 am Boom. Fuel-Telemetrie zeigte plausible positive AAR-Wirkung.

### Acceptance-5

Owner-run am 14.08.2026, DCS 2.9.28.26385 MT. Nelson-Gate `N38.83163 E70.95271` (~50 km NNE EGPAN) materialisierte außerhalb des sichtbaren Bereichs. Der 60-s-Post-Refuel-Dwell wurde mit rund 74,9 s erreicht. Beide Tanker erreichten danach den kontrollierten Egress/Off-map-Handoff. Detailprovenienz: `docs/moose/AAR-RUNTIME-ACCEPTANCE-5.md`.

## 3. Acceptance-6 – kombinierter FAST/SLOW-Test

Der Projektinhaber hat entschieden, die verbliebenen Funktionsnachweise in **einem** Test zu kombinieren:

```text
A-10 -> SLOW KC-135
F-16 -> FAST KC-135
FAST + SLOW gleichzeitig im selben AAR-Gebiet
FAST oben / SLOW unten
minimum vertical separation = 3,000 ft
```

AAR-Gebiet:

```text
CLANCY
Gate: N28.90264890 E64.61166667
Track: N31.75441342 E66.82695501
Heading: 225.276 deg
Leg: 35 NM
```

Tanker:

| Profil | Existing template | Höhe | Speed | Radio | Runtime TACAN |
|---|---|---:|---:|---:|---|
| SLOW | `OMW_AAR_KC135_CLANCY` | FL220 | 220 KIAS | 241.600 AM | 60Y / CLA |
| FAST | `OMW_AAR_KC135_PATTY` | FL250 | 300 KIAS | 237.300 AM | 48Y / TX2 |

`TX2` ist ein Acceptance-Ident. Die Patty-Planungsquelle führt Texaco 2, 237.300 AM und 48X; die runtime-seitige Y-Band-Korrektur folgt dem bereits praktisch bestätigten DCS-A/A-TACAN-Pfad aus Acceptance-4.

Die beiden Tanker werden am identischen südlichen Gate für diesen Acceptance-Lauf 60 Sekunden versetzt materialisiert, damit keine gleichzeitige physische Co-Location beim Spawn entsteht. Diese 60 Sekunden sind Acceptance-Sicherheitslogik und werden nicht stillschweigend als neue allgemeine Produktionsregel deklariert.

## 4. Vorhandene Receiver-Foundations

A-10:

```text
AW_US_KAF_451_AEW
-> SQ_US_KAF_A10C_74_EFS
-> TPL_AIR_US_KAF_A10C_CAS_2SHIP
-> intended tanker SLOW / FL220 / 220 kt
```

F-16:

```text
AW_US_BGRM_455_AEW
-> SQ_US_BGRM_F16C_121_EFS
-> TPL_AIR_US_BGRM_F16C_CAS_2SHIP
-> intended tanker FAST / FL250 / 300 kt
```

Beide Test-AUFTRAG-Missionen erhalten `SetMissionRange(250)`; die produktiven SQUADRON-Baselines bleiben unverändert.

## 5. MOOSE-Grenze der Receiver-Zuordnung

Der gepinnte `FLIGHTGROUP:Refuel(Coordinate)`-Pfad routet zum übergebenen Refuel-Waypoint und verwendet anschließend den nativen `TaskRefueling()`. Dieser bindet keine konkrete Tanker-ID, sondern refuelt beim nächstgelegenen kompatiblen Tanker.

Acceptance-6 nutzt deshalb die vertikal getrennten Zielkoordinaten und misst nach `OnAfterRefueled` zusätzlich mit `COORDINATE:Get3DDistance()` die 3D-Distanz des Receivers zu beiden Tankern.

```text
RECEIVER_TANKER_PROXIMITY_PASS
```

ist ausdrücklich nur eine räumliche Inferenz und **keine** von DCS/MOOSE gelieferte Donor-ID. Die Owner-Sichtprüfung bleibt Teil des Zuordnungsnachweises.

## 6. Abschlussbedingung

Der künstliche 99-%-FuelLow wird erst aktiviert, wenn **A-10 und F-16** beide den `Refueled`-Pfad abgeschlossen haben und danach mindestens 60 Sekunden vergangen sind.

```text
A10 Refueled + F16 Refueled
-> DUAL_RECEIVER_REFUEL_PASS
-> 60 s dwell
-> FuelLow 99%
-> Cancel
-> Egress
-> <=10 NM gate
-> Despawn off-map handoff
```

## 7. Erwartete Acceptance-6-Marker

```text
TANKER_START_PASS tankerProfile=SLOW ... altitudeFt=22000 speedKt=220
TANKER_START_PASS tankerProfile=FAST ... altitudeFt=25000 speedKt=300
DUAL_TANKER_STACK_PASS ... separationFt=3000 minimumFt=3000
TANKER_EXECUTING_PASS tankerProfile=SLOW
TANKER_EXECUTING_PASS tankerProfile=FAST
RECEIVER_MISSION_ADDED_PASS receiver=A10 ... intendedTanker=SLOW
RECEIVER_MISSION_ADDED_PASS receiver=F16 ... intendedTanker=FAST
RECEIVER_ASSIGNED_PASS receiver=A10
RECEIVER_ASSIGNED_PASS receiver=F16
AI_BOOM_REFUEL_ORDER_PASS receiver=A10 ... intendedTanker=SLOW
AI_BOOM_REFUEL_ORDER_PASS receiver=F16 ... intendedTanker=FAST
AI_BOOM_REFUELED_PASS receiver=A10
AI_BOOM_REFUELED_PASS receiver=F16
RECEIVER_TANKER_PROXIMITY_PASS receiver=A10 ... nearestTanker=SLOW
RECEIVER_TANKER_PROXIMITY_PASS receiver=F16 ... nearestTanker=FAST
DUAL_RECEIVER_REFUEL_PASS
POST_REFUEL_DWELL_PASS ... startsAfterBothReceivers=true
ACCELERATED_FUEL_LOW_ARMED ... afterBothReceiversRefueled=true
FUEL_LOW_PASS tankerProfile=SLOW
FUEL_LOW_PASS tankerProfile=FAST
EGRESS_GATE_PASS tankerProfile=SLOW
EGRESS_GATE_PASS tankerProfile=FAST
```

## 8. Source / Builder / Dist

```text
mission/tests/aar-kc135-runtime/src/01-aar-kc135-runtime-acceptance.lua
tools/build-aar-kc135-runtime-acceptance.ps1
mission/tests/aar-kc135-runtime/dist/OMW_AAR_KC135_Runtime_Acceptance.lua
```

`dist/` ist builder-generated only.
