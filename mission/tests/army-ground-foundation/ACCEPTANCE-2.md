---
document_id: OMW-TEST-ARMY-GROUND-ACCEPTANCE-2
status: PLANNED
document_class: ACCEPTANCE_TEST_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - planned scope and pass/fail criteria for the second ARMY Ground Foundation DCS runtime test
  - mounted Joyce road-approach and observation-halt test contract
not_authoritative_for:
  - accepted runtime behavior before real DCS execution
  - per-vehicle observation sectors
  - final production patrol doctrine
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
supersedes:
superseded_by:
---

# ARMY Ground Foundation – Acceptance 2

## 1. Ziel

Acceptance 2 ersetzt das für Fahrzeuge optisch unpassende `PATROLZONE`-Testverhalten durch einen MOOSE-first Ablauf für eine montierte Sicherungsgruppe:

```text
Joyce ACCESS
-> one 4 x M-ATV ARMYGROUP
-> ARMOREDGUARD approach mission / On Road
-> halt at road-side approach point
-> MissionDone with SetReturnToLegion(false)
-> same physical ARMYGROUP
-> ARMOREDGUARD observation mission / Vee
-> FullStop at observation position
-> stable hold without duplicate materialization
```

Der Test prüft bewusst nur die technische Grundlage eines Fahrzeug-Beobachtungshalts. Er behauptet **keine** individuelle Sektorzuweisung für einzelne Fahrzeuge.

## 2. MOOSE-first Begründung

Im gepinnten MOOSE-Stand ist `AUFTRAG:NewARMOREDGUARD(Coordinate, Formation)` öffentlich vorhanden. Der Konstruktor setzt für Ground Groups `OpenFire`, `AlarmState.Auto`, die übergebene Formation und ein coordinate-based objective. Beim Ausführen eines `ARMOREDGUARD`-Tasks ruft der OPSGROUP-Pfad für ARMYGROUP `FullStop()` auf.

Für Ground-Missionen verwendet `OPSGROUP:RouteToMission(...)` die `mission.optionFormation`; bei einer Restdistanz unter 1000 m wird die Formation allerdings auf `Off Road` gesetzt. Acceptance 2 trennt deshalb Marsch und taktische Endphase in zwei MOOSE-AUFTRÄGE und hält die geplante taktische Vee-Strecke oberhalb 1050 m.

Die Geschwindigkeit wird über `AUFTRAG:SetMissionSpeed(...)` in **knots** gesetzt; der gepinnte Source konvertiert intern nach km/h.

## 3. Gepinnte MOOSE-Basis

```text
MOOSE 2.9.18
commit 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256 e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Source-geprüfte Pfade für Acceptance 2:

```lua
BRIGADE:New(...)
WAREHOUSE:SetSpawnZone(...)
PLATOON:New(...)
COHORT:AddMissionCapability(...)
COHORT:CountAssets(...)
LEGION:AddMission(...)
AUFTRAG:NewARMOREDGUARD(Coordinate, Formation)
AUFTRAG:SetMissionSpeed(Speed)
AUFTRAG:SetReturnToLegion(false)
AUFTRAG:__Cancel(delay)
COORDINATE:GetIntermediateCoordinate(...)
COORDINATE:GetClosestPointToRoad(...)
OPSGROUP MissionExecute / MissionDone callbacks
ARMYGROUP:FullStop()
```

Source-Review ist kein DCS-Acceptance-Nachweis.

## 4. Mission-Editor-Vertrag

Acceptance 2 verwendet **dieselben** bereits vorhandenen Objekte wie Acceptance 1:

```text
WH_BLUE_GND_JOYCE
TPL_BLUE_GND_PATROL_MATV_4
ZON_BLUE_GND_JOYCE_ACCESS
ZON_BLUE_GND_JOYCE_PATROL_TEST_01
```

`ZON_BLUE_GND_JOYCE_PATROL_TEST_01` dient in Acceptance 2 nur noch als definierte Beobachtungsposition; es wird **kein** `PATROLZONE`-Auftrag erzeugt.

Keine weitere `.miz`-Geometrie ist für den ersten A2-Lauf erforderlich. ChatGPT verändert keine `.miz`.

## 5. Runtime-Vertrag

```text
source:
mission/tests/army-ground-foundation/src/02-army-ground-acceptance-2.lua

builder:
tools/build-army-ground-acceptance-2.ps1

bundle:
mission/tests/army-ground-foundation/dist/OMW_Army_Ground_Acceptance_2.lua

BuilderVersion / Test-ID:
ARMY-GROUND-ACCEPTANCE-2-1
```

Der Builder verändert keine `.miz`.

## 6. Testgeometrie

Runtime berechnet aus ACCESS-Zentrum und Beobachtungszentrumskoordinate:

```text
observation target = center of ZON_BLUE_GND_JOYCE_PATROL_TEST_01
road approach      = ca. 1500 m before target
road approach      -> snapped to closest road point
tactical Vee leg   > 1050 m required
```

Wenn diese Geometrie nicht erfüllt werden kann, bricht der Harness mit `FAIL` ab.

Die Werte sind Testparameter, keine historische taktische Distanzvorgabe.

## 7. Testsequenz

### Phase A – Materialisierung

```text
BRIGADE starts
PLATOON reports exactly one ARMOREDGUARD-capable in-stock asset
one physical 4 x M-ATV group materializes in Joyce ACCESS
```

### Phase B – Road approach

```text
Mission 1:
AUFTRAG:NewARMOREDGUARD(approachCoord, On Road)
SetMissionSpeed(10 kt)
SetReturnToLegion(false)
```

Erwartung:

```text
convoy leaves ACCESS without repeated local circling
road-biased transit looks plausible
same four vehicles remain one group
arrival at approach position
ARMOREDGUARD reaches MissionExecute / FullStop
```

Nach zehn Sekunden Halt wird Mission 1 über den AUFTRAG-FSM abgebrochen. Die Gruppe muss physisch bestehen bleiben.

### Phase C – Tactical observation leg

```text
Mission 2:
AUFTRAG:NewARMOREDGUARD(observationCoord, Vee)
SetMissionSpeed(8 kt)
SetReturnToLegion(false)
```

Erwartung:

```text
same physical ARMYGROUP is reused
no second spawn
formation changes from road convoy toward Vee during the tactical leg
group reaches observation position
ARMOREDGUARD executes FullStop
```

### Phase D – Hold stability

20 Sekunden nach MissionExecute von Mission 2 prüft der Harness:

```text
group alive
movement since hold start <= 75 m
distance to observation target <= 250 m
spawnCount == 1
```

Bei erfüllten Runtime-Kriterien wird absichtlich nur geloggt:

```text
OMW_GND_A2 RUNTIME_PASS_VISUAL_PENDING ...
```

Ein endgültiges Acceptance-PASS erfordert zusätzlich die visuelle Owner-Beobachtung.

## 8. Visuelle Acceptance

Der Owner muss mindestens bestätigen:

```text
[ ] keine auffälligen wiederholten Kreise im ACCESS-Bereich vor dem Abmarsch
[ ] plausibler Convoy-/On-Road-Abmarsch
[ ] keine sichtbare Teleportation
[ ] keine zweite Fahrzeuggruppe / Dublette
[ ] nachvollziehbarer Übergang in die taktische Endphase
[ ] Vee bzw. eine erkennbar aufgefächerte taktische Fahrzeugformation ist am Endanflug/Halt sichtbar
[ ] vier Fahrzeuge fahren am Ziel nicht zufällig Patrol-Runden
[ ] Gruppe kommt zu einem stabilen Beobachtungs-/Sicherungshalt
```

Wenn DCS die Vee-Geometrie nicht überzeugend darstellt, ist das kein Grund, individuelle Fahrzeugpositionen per eigener Teleport-/Spawn-Logik zu erzwingen. Dann wird zunächst die vorhandene MOOSE/DCS-Formation weiter kalibriert.

## 9. Erforderliche Logmarker

```text
OMW_GND_A2 START
OMW_GND_A2 GEOMETRY ...
OMW_GND_A2 BRIGADE_STARTED
OMW_GND_A2 PLATOON_READY assets=1
OMW_GND_A2 MISSION1_QUEUED ... formation=On Road
OMW_GND_A2 GROUP_MATERIALIZED ...
OMW_GND_A2 APPROACH_GUARD_EXECUTING ...
OMW_GND_A2 MISSION1_DONE reservation=FIELD_DEPLOYED
OMW_GND_A2 GROUP_STILL_ALIVE ...
OMW_GND_A2 MISSION2_QUEUED formation=Vee ...
OMW_GND_A2 MISSION2_SAME_GROUP ...
OMW_GND_A2 OBS_GUARD_EXECUTING ... formation=Vee
OMW_GND_A2 GUARD_HOLD_STABLE ...
OMW_GND_A2 RUNTIME_PASS_VISUAL_PENDING ... spawnCount=1 formation=Vee
```

## 10. FAIL-Kriterien

```text
missing ME object
invalid test geometry
PLATOON asset count != 1
more than one materialization
Mission 2 receives a different ARMYGROUP
group removed after Mission 1
tactical leg collapses below 1050 m
hold movement > 75 m after MissionExecute
final target distance > 250 m
runtime Lua error
visible teleport/despawn
unusable or visibly looping ACCESS departure
```

## 11. Nicht durch Acceptance 2 validiert

```text
per-vehicle observation sector assignment
historical vehicle battle drill detail
enemy contact / combat response
QRF
OP reinforcement
OPSTRANSPORT
return to warehouse
cross-session reconstitution
full CampaignState adapter
multiplayer synchronization
```

## 12. Provenienzregel

`VALIDATED` bzw. `ACCEPTED_TECHNICAL_BASELINE` ist erst zulässig, wenn reale Evidenz vorliegt für:

```text
branch
source commit
BuilderVersion/Test-ID
mission filename
mission SHA-256
internal mission SHA-256
runtime bundle SHA-256
embedded bundle SHA-256
DCS version
Moose.lua SHA-256 / commit
relevant dcs.log markers
owner visual observations
```
