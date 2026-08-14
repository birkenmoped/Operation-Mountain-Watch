---
document_id: OMW-MOOSE-AAR-RUNTIME-ACCEPTANCE-6
status: PLANNED
document_class: TECHNICAL_ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - combined five-KC-135 acceptance stress-exception design
  - same-area FAST/SLOW KC-135 acceptance design
  - A-10 to SLOW and F-15E/F-16C to FAST receiver acceptance
  - optional C-130J-30 AAR capability probe
  - 3000-ft independent tanker vertical separation test
  - spatial receiver-to-tanker inference used only by this acceptance
not_authoritative_for:
  - production MissionDemand/CampaignState activation logic
  - automatic donor identity from DCS or MOOSE
  - final all-area FAST/SLOW altitude and speed matrix
  - production C-130J AAR capability unless this exact test proves it
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - OMW-MOOSE-AAR-RUNTIME-ACCEPTANCE-5
superseded_by: []
source_branch: agent/aar-rc-east-runtime-scope
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# AAR Runtime Acceptance-6 – Full Tanker + Receiver Matrix

## 1. Ziel

Der Projektinhaber hat entschieden, die noch offenen AAR-Funktionsnachweise in **einem** Owner-Lauf zu kombinieren.

```text
Tanker:
- alle fünf vorbereiteten KC-135 gleichzeitig im Test
- zusätzlicher Same-area FAST/SLOW-Nachweis in CLANCY

Mandatory receiver matrix:
- A-10C  -> SLOW KC-135
- F-15E  -> FAST KC-135
- F-16C  -> FAST KC-135

Optional receiver probe:
- C-130J-30 -> FAST KC-135, non-blocking
```

Der Fünf-Tanker-Lauf bleibt eine ausdrücklich genehmigte **Acceptance-/Stress-Test-Ausnahme**. Die produktive Grenze `maxConcurrentSupportMissions = 2` wird dadurch nicht geändert.

Es werden ausschließlich vorhandene Mission-Editor-Templates und vorhandene AIRWING-/SQUADRON-Foundations verwendet. Es werden keine neuen ME-Templates erzeugt und keine `.miz` automatisiert verändert.

## 2. MOOSE-First-Befund

Gepinnter Stand:

```text
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Verwendete, bereits source-reviewte öffentliche Pfade:

```text
SPAWN:New()
SPAWN:InitHeading()
SPAWN:SpawnFromCoordinate()
FLIGHTGROUP:New()
FLIGHTGROUP:IsAirborne()
FLIGHTGROUP:Refuel()
FLIGHTGROUP:GetFuelMin()
FLIGHTGROUP:SetFuelLowThreshold()
FLIGHTGROUP:SetFuelLowRTB(false)
FLIGHTGROUP:OnAfterRefueled
AUFTRAG:NewTANKER()
AUFTRAG:NewCAS()
AUFTRAG:SetMissionRange()
AUFTRAG:AssignSquadrons()
AUFTRAG:AddRequiredPayload()
AUFTRAG:SetRequiredAssets()
AUFTRAG:SetRadio()
AUFTRAG:SetTACAN()
AUFTRAG:SetMissionEgressCoord()
AUFTRAG:Cancel()
AIRWING:AddMission()
AIRWING:OnAfterFlightOnMission
COORDINATE:HeadingTo()
COORDINATE:Get2DDistance()
COORDINATE:Get3DDistance()
OPSGROUP:Despawn()
SCHEDULER
```

`FLIGHTGROUP:Refuel(Coordinate)` bindet keine konkrete Tanker-ID. Der Receiver wird zum Refuel-Waypoint geroutet und anschließend der native DCS-Refueling-Task verwendet. Deshalb bleibt die Zuordnung zu SLOW/FAST eine Kombination aus gezielter Zielgeometrie, 3D-Proximity-Inferenz nach `Refueled` und Owner-Sichtbeobachtung.

```text
nearest tanker by 3D proximity after Refueled
!=
DCS/MOOSE donor identity
```

## 3. Tanker-Matrix

### 3.1 Same-area FAST/SLOW in CLANCY

```text
CLANCY track:
N31.75441342 E66.82695501
Heading 225.276 deg
Leg 35 NM

SLOW:
Template: OMW_AAR_KC135_CLANCY
FL220
220 KIAS
241.600 AM
60Y / CLA
Seed fuel ~90%

FAST:
Template: OMW_AAR_KC135_PATTY
FL250
300 KIAS
237.300 AM
48Y / TX2
Seed fuel ~96%

Vertical separation:
3,000 ft
```

Damit wird die Owner-Regel `SLOW unten / FAST oben / mindestens 3.000 ft` exakt geprüft. Die MOOSE-interne 1.000-ft-Patrolslot-Logik wird hierfür nicht als Ersatz betrachtet.

### 3.2 Weitere aktive Tanker

```text
HOMER
Template: OMW_AAR_KC135_HOMER
Track: N32.93833333 E68.22333333
FL230 / 300 KIAS
376.000 AM
54Y / HOM
Seed fuel ~90%

KRUSTY
Template: OMW_AAR_KC135_KRUSTY
Track: N32.65123012 E68.15946309
FL260 / 300 KIAS
258.300 AM
42Y / KRU
Seed fuel ~90%

NELSON
Template: OMW_AAR_KC135_NELSON
Track: N36.37666667 E71.01833333
FL275 / 300 KIAS
384.400 AM
47Y / NEL
Seed fuel ~96%
Gate: N38.83163 E70.95271 (~50 km NNE EGPAN)
```

Patty wird in diesem Acceptance-Lauf bewusst als FAST-Tanker im Clancy-Same-area-Paar verwendet. Damit sind alle fünf vorbereiteten KC-135-Templates gleichzeitig aktiv, aber Patty fliegt in diesem Test nicht ihre normale Patty-Geometrie.

### 3.3 Materialisierungsfolge

Zur Vermeidung lokaler Spawn-Häufung am südlichen Gate gilt nur für diesen Acceptance-Lauf:

```text
t0:      SLOW / CLANCY
t0:      NELSON
t0+60:   FAST / PATTY template in CLANCY
t0+120:  HOMER
t0+180:  KRUSTY
```

Diese Staffelung ist Acceptance-Sicherheitslogik und keine neue allgemeine Produktionsregel.

## 4. Mandatory Receiver Matrix

### 4.1 A-10C -> SLOW

Vorhandener Kandahar-Pfad:

```text
AW_US_KAF_451_AEW
-> SQ_US_KAF_A10C_74_EFS
-> TPL_AIR_US_KAF_A10C_CAS_2SHIP
```

Acceptance-Profil:

```text
Target tanker: SLOW
Target altitude: FL220
Target speed profile: 220 KIAS
```

### 4.2 F-15E -> FAST

Vorhandener Bagram-Pfad:

```text
AW_US_BGRM_455_AEW
-> SQ_US_BGRM_F15E_335_EFS
-> TPL_AIR_US_BGRM_F15E_CAS_2SHIP
```

Acceptance-Profil:

```text
Target tanker: FAST
Target altitude: FL250
Target speed profile: 300 KIAS
```

### 4.3 F-16C -> FAST

Vorhandener Bagram-Pfad:

```text
AW_US_BGRM_455_AEW
-> SQ_US_BGRM_F16C_121_EFS
-> TPL_AIR_US_BGRM_F16C_CAS_2SHIP
```

Acceptance-Profil:

```text
Target tanker: FAST
Target altitude: FL250
Target speed profile: 300 KIAS
```

Alle drei test-only CAS-AUFTRAG-Missionen verwenden:

```lua
mission:SetMissionRange(250)
```

Die produktiven SQUADRON-Reichweiten werden nicht geändert.

## 5. Optionaler C-130J-30-AAR-Probe

Die tatsächlich getestete `.miz` enthält für den vorhandenen Bagram-C-130-Templatepfad:

```text
Template: TPL_AIR_US_BGRM_C130_TRANSPORT_1SHIP
DCS unit type: C-130J-30
```

Die produktive Bagram-C-130-SQUADRON besitzt `TROOPTRANSPORT`, nicht CAS. Für diesen isolierten AAR-Fähigkeitsprobe wird deshalb **kein erfundener CAS-AUFTRAG** an die C-130-SQUADRON gehängt. Stattdessen wird das vorhandene Template acceptance-only über die bereits source-reviewten MOOSE-Pfade `SPAWN -> FLIGHTGROUP -> Refuel` airborne materialisiert.

```text
Target tanker: FAST
Altitude: FL250
Timeout: 600 s
blocking: false
```

Der Probe ist bewusst nicht-blockierend:

```text
OPTIONAL_C130_AAR_PASS
```

belegt einen erfolgreichen Refuel-FSM-Pfad mit plausibler Fuel-Zunahme.

```text
OPTIONAL_C130_AAR_RESULT status=NOT_CONFIRMED ...
```

bedeutet dagegen nur, dass AAR mit dem aktuellen DCS-C-130J-30 in diesem Lauf nicht bestätigt wurde. Daraus wird ohne weiteren Nachweis keine allgemeine negative DCS-Fähigkeitsbehauptung abgeleitet.

## 6. Testablauf

Der Receiver-AAR-Teil startet erst, wenn alle fünf Tanker gleichzeitig `EXECUTING` sind:

```text
FIVE_TANKER_EXECUTING_PASS count=5
```

Danach:

```text
A-10 -> SLOW
F-15E -> FAST
F-16C -> FAST
optional C-130J-30 -> FAST
```

Mandatory Receiver PASS verlangt für A-10, F-15E und F-16C jeweils:

```text
RECEIVER_ASSIGNED_PASS
AI_BOOM_REFUEL_ORDER_PASS
AI_BOOM_REFUELED_PASS
RECEIVER_TANKER_PROXIMITY_PASS
plausible positive fuel effect
Owner visual confirmation of the intended lower/upper tanker
```

## 7. Abschlusslogik

Der künstliche 99-%-FuelLow darf erst scharfgeschaltet werden, wenn:

```text
A-10 Refueled
+
F-15E Refueled
+
F-16C Refueled
-> RECEIVER_MATRIX_REFUEL_PASS
```

Der optionale C-130-Probe muss außerdem entweder abgeschlossen oder nach 600 s als `NOT_CONFIRMED` beendet sein. Anschließend gelten mindestens 60 s Dwell ab dem letzten Mandatory-`Refueled`-Zeitpunkt.

```text
mandatory receiver matrix complete
+
optional C-130 probe concluded
+
>=60 s dwell after latest mandatory Refueled
-> FuelLow threshold 99%
-> all five tanker AUFTRAG missions Cancel
-> Egress
-> <=10 NM assigned gate
-> Despawn off-map handoff
```

## 8. Erwartete Kernmarker

```text
TANKER_START_PASS tankerProfile=SLOW ...
TANKER_START_PASS tankerProfile=FAST ...
TANKER_START_PASS tankerProfile=HOMER ...
TANKER_START_PASS tankerProfile=KRUSTY ...
TANKER_START_PASS tankerProfile=NELSON ...
FIVE_TANKER_EXECUTING_PASS count=5

RECEIVER_MISSION_ADDED_PASS receiver=A10 ... intendedTanker=SLOW
RECEIVER_MISSION_ADDED_PASS receiver=F15E ... intendedTanker=FAST
RECEIVER_MISSION_ADDED_PASS receiver=F16 ... intendedTanker=FAST

AI_BOOM_REFUELED_PASS receiver=A10 ...
AI_BOOM_REFUELED_PASS receiver=F15E ...
AI_BOOM_REFUELED_PASS receiver=F16 ...

RECEIVER_TANKER_PROXIMITY_PASS receiver=A10 ... nearestTanker=SLOW
RECEIVER_TANKER_PROXIMITY_PASS receiver=F15E ... nearestTanker=FAST
RECEIVER_TANKER_PROXIMITY_PASS receiver=F16 ... nearestTanker=FAST

OPTIONAL_C130_SPAWN_PASS ...
OPTIONAL_C130_REFUEL_ORDER_PASS ...
OPTIONAL_C130_AAR_PASS ...
# or non-blocking:
OPTIONAL_C130_AAR_RESULT status=NOT_CONFIRMED ...

RECEIVER_MATRIX_REFUEL_PASS mandatoryReceivers=A10,F15E,F16 ...
POST_REFUEL_DWELL_PASS ... optionalC130Concluded=true
ACCELERATED_FUEL_LOW_ARMED ... tankerCount=5

FUEL_LOW_PASS ... x5
EGRESS_GATE_PASS ... x5
```

## 9. Acceptance-Kriterien

Der kombinierte Lauf ist für den Mandatory-Scope nur dann erfolgreich, wenn:

1. alle fünf vorbereiteten KC-135 gleichzeitig `EXECUTING` erreichen;
2. SLOW und FAST gleichzeitig in Clancy stabil mit FL220/220 KIAS und FL250/300 KIAS laufen;
3. die Same-area-Staffelung exakt 3.000 ft beträgt;
4. der Kandahar-A-10C-2-Ship Boom-AAR durchführt und räumlich/visuell dem SLOW-Tanker zugeordnet werden kann;
5. der Bagram-F-15E-2-Ship Boom-AAR durchführt und räumlich/visuell dem FAST-Tanker zugeordnet werden kann;
6. der Bagram-F-16C-2-Ship Boom-AAR durchführt und räumlich/visuell dem FAST-Tanker zugeordnet werden kann;
7. die drei Mandatory Receiver plausible positive Fuel-Wirkung zeigen;
8. der optionale C-130J-30-Probe als PASS oder `NOT_CONFIRMED` reproduzierbar protokolliert wird;
9. der künstliche FuelLow erst nach Mandatory-Matrix, C-130-Probe-Abschluss und mindestens 60 s Dwell aktiviert wird;
10. alle fünf Tanker anschließend kontrollierten Egress/Off-map-Handoff erreichen;
11. keine neuen ME-Templates, kein MIST, kein nativer Event-Handler und keine automatisierte `.miz`-Mutation eingeführt werden.

## 10. Grenzen

Acceptance-6 validiert nicht automatisch:

```text
- alle 19 AAR-Areas
- sämtliche zukünftigen FAST/SLOW-Höhenpaare
- produktive dynamische MissionDemand-Auswahl
- eine direkte DCS-/MOOSE-Donor-ID
- CampaignState-Ressourcenabrechnung
- C-130J-30 AAR, falls der optionale Probe nur NOT_CONFIRMED ergibt
```

Ein DCS-PASS darf nur für den exakt gebauten und dokumentierten Acceptance-6-Stand eingetragen werden.