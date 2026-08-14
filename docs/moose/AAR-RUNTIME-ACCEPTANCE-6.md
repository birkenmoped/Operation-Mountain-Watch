---
document_id: OMW-MOOSE-AAR-RUNTIME-ACCEPTANCE-6
status: PLANNED
document_class: TECHNICAL_ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - combined same-area FAST/SLOW KC-135 acceptance design
  - A-10 to SLOW and F-16 to FAST receiver acceptance
  - 3000-ft independent tanker vertical separation test
  - spatial receiver-to-tanker inference used only by this acceptance
not_authoritative_for:
  - production MissionDemand/CampaignState activation logic
  - automatic donor identity from DCS or MOOSE
  - final all-area FAST/SLOW altitude and speed matrix
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - OMW-MOOSE-AAR-RUNTIME-ACCEPTANCE-5
superseded_by: []
source_branch: agent/aar-rc-east-runtime-scope
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# AAR Runtime Acceptance-6 – Same-area FAST/SLOW Dual Tanker

## 1. Ziel

Acceptance-6 fasst die nach Acceptance-5 noch offenen AAR-Funktionsnachweise in **einen** Owner-Lauf zusammen:

```text
1. realer A-10 -> SLOW KC-135 Boom-Test
2. FAST + SLOW gleichzeitig im selben AAR-Gebiet
3. FAST oben / SLOW unten
4. mindestens 3,000 ft vertikale Staffelung
5. Receiver-Zuordnung:
   A-10 -> SLOW
   F-16 -> FAST
```

Es werden ausschließlich vorhandene Mission-Editor-Templates und vorhandene AIRWING-/SQUADRON-Foundations verwendet. Der Harness erzeugt keine neuen ME-Templates und verändert die `.miz` nicht automatisiert.

## 2. MOOSE-First-Befund

Gepinnter Stand:

```text
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Für Acceptance-6 wurden zusätzlich geprüft:

```text
FLIGHTGROUP:Refuel(Coordinate)
CONTROLLABLE:TaskRefueling()
COORDINATE:Get3DDistance(TargetCoordinate)
```

Der tatsächliche gepinnte `Moose.lua` zeigt für `FLIGHTGROUP:Refuel(Coordinate)`, dass der Receiver zum übergebenen Refuel-Waypoint geroutet und anschließend der native DCS-`TaskRefueling()` verwendet wird. `TaskRefueling()` tankt beim nächstgelegenen kompatiblen Tanker; der öffentliche `Refuel()`-Aufruf bindet **keine konkrete Tanker-ID**.

`COORDINATE:Get3DDistance()` ist im gepinnten Quellstand vorhanden und liefert die 3D-Distanz in Metern. Acceptance-6 nutzt diese Methode ausschließlich zur instrumentierten räumlichen Plausibilisierung nach dem `Refueled`-Event.

Wichtig:

```text
nearest tanker by 3D proximity after Refueled
!=
DCS/MOOSE donor identity
```

Die Zuordnung gilt erst dann als praktisch bestanden, wenn Log-Inferenz und Owner-Beobachtung konsistent sind.

## 3. Same-area Dual-Tanker-Konfiguration

Beide Tanker verwenden die **Clancy-Geometrie** und denselben südlichen External-Gate-Punkt. Die unabhängigen Orbits werden vertikal und durch unterschiedliche Geschwindigkeitsprofile getrennt.

```text
AAR area: CLANCY
Gate: N28.90264890 E64.61166667
Track reference: N31.75441342 E66.82695501
Heading: 225.276 deg
Leg: 35 NM
```

### 3.1 SLOW

```text
Role: A-10 / slow receiver
Existing template: OMW_AAR_KC135_CLANCY
Altitude: FL220
Speed: 220 KIAS
Radio: 241.600 AM
TACAN: 60Y / CLA
Seed fuel expectation: ~90%
```

### 3.2 FAST

```text
Role: F-15/F-16 / fast receiver
Existing template: OMW_AAR_KC135_PATTY
Altitude: FL250
Speed: 300 KIAS
Radio: 237.300 AM
TACAN runtime: 48Y
Acceptance ident: TX2
Seed fuel expectation: ~96%
```

Die Patty-Planungsquelle führt Texaco 2, 237.300 AM und 48X. Wie bereits in Acceptance-4 praktisch bestätigt, verwendet der DCS-A/A-TACAN-Runtime-Pfad für die OMW-Tanker Y-Band; Acceptance-6 verwendet daher 48Y. `TX2` ist ein ausdrückliches Acceptance-Ident und keine historische Behauptung.

### 3.3 Staffelung

```text
SLOW: FL220
FAST: FL250
vertical separation: 3,000 ft
minimum required: 3,000 ft
```

Damit wird die vom Projektinhaber festgelegte OMW-Regel exakt getestet. Die MOOSE-interne 1,000-ft-Patrolslot-Logik ersetzt diese Projektregel nicht.

Beide Tanker sollen gleichzeitig im Clancy-Gebiet `EXECUTING` sein. Um eine gleichzeitige Materialisierung am identischen Gatepunkt zu vermeiden, wird im Acceptance-Harness ausschließlich für diesen Test ein 60-s-Spawn-Stagger verwendet:

```text
SLOW spawn: t0
FAST spawn: t0 + 60 s
```

Daraus wird ohne weitere Owner-Entscheidung keine neue allgemeine Produktionsregel abgeleitet.

## 4. Receiver

### 4.1 A-10 -> SLOW

Vorhandener Kandahar-Pfad:

```text
AW_US_KAF_451_AEW
-> SQ_US_KAF_A10C_74_EFS
-> TPL_AIR_US_KAF_A10C_CAS_2SHIP
```

Acceptance-Missionsprofil:

```text
Altitude: FL220
Speed: 220 kt
Refuel waypoint: SLOW tanker track coordinate at FL220
Intended tanker: SLOW
```

### 4.2 F-16 -> FAST

Vorhandener Bagram-Pfad:

```text
AW_US_BGRM_455_AEW
-> SQ_US_BGRM_F16C_121_EFS
-> TPL_AIR_US_BGRM_F16C_CAS_2SHIP
```

Acceptance-Missionsprofil:

```text
Altitude: FL250
Speed: 300 kt
Refuel waypoint: FAST tanker track coordinate at FL250
Intended tanker: FAST
```

Beide Acceptance-AUFTRAG-Missionen verwenden test-only:

```lua
mission:SetMissionRange(250)
```

Die produktiven SQUADRON-Reichweiten werden nicht verändert.

## 5. Zuordnungsnachweis

Da der öffentliche `FLIGHTGROUP:Refuel()`-Pfad keine konkrete Tanker-ID annimmt, erzeugt der Harness keinen erfundenen direkten Donor-Nachweis.

Nach jedem `OnAfterRefueled` werden die 3D-Distanzen vom Receiver zu beiden aktiven Tankern gemessen:

```text
A-10:
intended = SLOW
PASS when nearest tanker = SLOW

F-16:
intended = FAST
PASS when nearest tanker = FAST
```

Erwartete Marker:

```text
RECEIVER_TANKER_PROXIMITY_PASS receiver=A10 ... intendedTanker=SLOW nearestTanker=SLOW ... evidence=SPATIAL_INFERENCE_NOT_DONOR_ID
RECEIVER_TANKER_PROXIMITY_PASS receiver=F16 ... intendedTanker=FAST nearestTanker=FAST ... evidence=SPATIAL_INFERENCE_NOT_DONOR_ID
```

Der Owner soll zusätzlich visuell prüfen, dass die A-10 tatsächlich am unteren 220-KIAS-Tanker und die F-16 am oberen 300-KIAS-Tanker tanken.

## 6. Abschlusslogik

FuelLow wird erst beschleunigt, nachdem **beide Receiver** ihren `Refueled`-Pfad erreicht haben.

```text
A-10 Refueled
+
F-16 Refueled
-> DUAL_RECEIVER_REFUEL_PASS
-> 60 s dwell ab dem späteren Refueled-Zeitpunkt
-> POST_REFUEL_DWELL_PASS
-> tanker FuelLow threshold = 99%
-> FuelLow -> Cancel -> Egress
-> <= 10 NM south gate
-> Despawn off-map handoff
```

Damit kann weder der A-10- noch der F-16-Tankvorgang durch den künstlichen Acceptance-FuelLow des anderen Receivers vorzeitig beendet werden.

## 7. Erwartete Kernmarker

```text
TANKER_START_PASS tankerProfile=SLOW ... altitudeFt=22000 speedKt=220 ... tacan=60Y ...
TANKER_START_PASS tankerProfile=FAST ... altitudeFt=25000 speedKt=300 ... tacan=48Y ...
DUAL_TANKER_STACK_PASS area=CLANCY ... separationFt=3000 minimumFt=3000
TANKER_EXECUTING_PASS tankerProfile=SLOW ...
TANKER_EXECUTING_PASS tankerProfile=FAST ...
RECEIVER_MISSION_ADDED_PASS receiver=A10 ... intendedTanker=SLOW ...
RECEIVER_MISSION_ADDED_PASS receiver=F16 ... intendedTanker=FAST ...
RECEIVER_ASSIGNED_PASS receiver=A10 ...
RECEIVER_ASSIGNED_PASS receiver=F16 ...
AI_BOOM_REFUEL_ORDER_PASS receiver=A10 ... intendedTanker=SLOW targetAltitudeFt=22000 ...
AI_BOOM_REFUEL_ORDER_PASS receiver=F16 ... intendedTanker=FAST targetAltitudeFt=25000 ...
AI_BOOM_REFUELED_PASS receiver=A10 ...
AI_BOOM_REFUELED_PASS receiver=F16 ...
RECEIVER_TANKER_PROXIMITY_PASS receiver=A10 ... nearestTanker=SLOW ...
RECEIVER_TANKER_PROXIMITY_PASS receiver=F16 ... nearestTanker=FAST ...
DUAL_RECEIVER_REFUEL_PASS ...
POST_REFUEL_DWELL_PASS ... startsAfterBothReceivers=true
ACCELERATED_FUEL_LOW_ARMED ... afterBothReceiversRefueled=true
FUEL_LOW_PASS tankerProfile=SLOW ...
FUEL_LOW_PASS tankerProfile=FAST ...
EGRESS_GATE_PASS tankerProfile=SLOW ...
EGRESS_GATE_PASS tankerProfile=FAST ...
```

## 8. Acceptance-Kriterien

Der kombinierte Lauf ist für den vorgesehenen Scope nur dann erfolgreich, wenn:

1. SLOW und FAST gleichzeitig im Clancy-AAR-Gebiet `EXECUTING` erreichen;
2. SLOW bei FL220 / 220 KIAS und FAST bei FL250 / 300 KIAS betrieben werden;
3. die vertikale Tanker-zu-Tanker-Staffelung 3,000 ft beträgt;
4. der vorhandene Kandahar-A-10C-2-Ship tatsächlich materialisiert und Boom-AAR durchführt;
5. der vorhandene Bagram-F-16C-2-Ship tatsächlich materialisiert und Boom-AAR durchführt;
6. die räumliche Inferenz A-10 -> SLOW und F-16 -> FAST ergibt;
7. der Owner diese Zuordnung visuell plausibilisiert;
8. Fuel-Readbacks für beide Receiver eine plausible positive AAR-Wirkung zeigen;
9. der künstliche FuelLow erst mindestens 60 s nach dem späteren der beiden `Refueled`-Events aktiviert wird;
10. beide Tanker anschließend den kontrollierten Egress/Off-map-Handoff erreichen;
11. keine neuen ME-Templates, kein MIST, kein nativer Event-Handler und keine automatisierte `.miz`-Mutation eingeführt werden.

## 9. Grenzen

Acceptance-6 validiert nicht automatisch:

```text
- F-15 als separaten Receiver; F-16 repräsentiert den FAST-Jet-Testpfad
- alle 19 AAR-Areas
- sämtliche zukünftigen FAST/SLOW-Höhenpaare
- produktive dynamische MissionDemand-Auswahl
- eine direkte DCS-/MOOSE-Donor-ID
- CampaignState-Ressourcenabrechnung
```

Ein Status `VALIDATED` wird erst nach dokumentiertem Owner-DCS-Lauf für den exakt gebauten Acceptance-6-Stand vergeben.
