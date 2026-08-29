---
document_id: OMW-MOOSE-GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-SOURCE-REVIEW
status: SOURCE_REVIEWED
document_class: TECHNICAL_EVIDENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 1D-P MOOSE source review for meta-PERSONNEL resupply
  - Ground Joyce to Honaker PERSONNEL carrier contract
  - Air Jalalabad to Fortress PERSONNEL carrier contract
not_authoritative_for:
  - DCS runtime validation of Stage 1D-P
  - physical infantry-group transport
  - FOB/COP to OP troop deployment
  - tactical AO insertion or extraction
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/automatic-response-orchestration-continuation
validated_in_dcs: false
---

# Stage 1D-P – PERSONNEL Ground/Air Resupply Source Review

## 1. Ziel und fachliche Grenze

Stage 1D-P behandelt `PERSONNEL` als **CampaignState-Meta-Ressource / strategischen Headcount**. Die physische Transportplattform repräsentiert den Transport; es wird keine sichtbare Infanteriegruppe als Cargo erzeugt.

Verbindliche Trennung:

```text
PERSONNEL RESUPPLY
-> CampaignState headcount
-> Ground- oder Air-Carrier als physische Repräsentation
-> keine physische Infantry GROUP als Cargo

FOB/COP -> OP bzw. AO deployment
-> konkrete physische Infantry GROUP
-> eigener späterer Missions-/Acceptance-Scope
```

Damit ist `AUFTRAG:NewTROOPTRANSPORT(...)` für Stage 1D-P bewusst **nicht** die gewählte Semantik. `TROOPTRANSPORT` bleibt Kandidat für den späteren Transport realer Infanteriegruppen.

## 2. Strategischer PERSONNEL-Vertrag

Owner-Entscheidung vom 29.08.2026:

```text
shared resourceId: GROUND_PERSONNEL
reorder trigger: strictly below 80% of target
exactly 80%: no demand
resupply quantity: refill to 100% target
PERSONNEL critical threshold: not defined in this stage
```

Die vorhandene `supplyParent`-Kette bleibt maßgeblich:

```text
Jalalabad -> Fortress
Jalalabad -> Joyce
Jalalabad -> Wright
Jalalabad -> Bostick
Joyce     -> Honaker
```

Die 80-%-Regel ist ein **logistischer Resupply-Trigger** und ersetzt nicht die separat dokumentierten allgemeinen Ground-Capability-Readiness-Stufen.

## 3. Acceptance-Fixture

### 3.1 Ground

```text
Origin:       GROUND_NODE_JOYCE
Destination:  GROUND_NODE_HONAKER
Resource:     GROUND_PERSONNEL
Initial:      Joyce 180 / Honaker 120
Shortage:     Honaker -25 -> 95
80% floor:    96
Transfer:     25
Expected:     Joyce 155 / Honaker 120
Carrier:      TPL_BLUE_CONVOY_LIGHT_06
Mission:      AUFTRAG:NewNOTHING(Honaker ACCESS)
Return:       explicit ARMYGROUP:RTZ(Joyce ACCESS, OnRoad)
```

Der Ground-Teil verändert den akzeptierten Stage-1C-/Stage-1D-S-NOTHING-Lifecycle nicht. Es gibt keinen harten Outbound- oder Return-Travel-Timeout.

### 3.2 Air

```text
Origin resource node: GROUND_NODE_JALALABAD
Destination:          GROUND_NODE_FORTRESS
Resource:             GROUND_PERSONNEL
Initial:              Jalalabad 480 / Fortress 160
Shortage:             Fortress -33 -> 127
80% floor:            128
Transfer:             33
Expected:             Jalalabad 447 / Fortress 160
AIRWING:              AW_US_JBAD_TF_SHOOTER_6_6_CAV
SQUADRON:             SQ_US_JBAD_CH47_HEAVYLIFT
Template:             TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP
Landing target:       OMW_BLUE_LZ_FORTRESS_01
Mission:              AUFTRAG:NewLANDATCOORDINATE(...)
```

Der Helikopter bleibt ein Jalalabad-AIRWING/SQUADRON-Asset. Fortress erhält keinen organischen Helikopterbestand.

## 4. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Maßgeblich geprüft wurde die tatsächlich gepinnte `Moose.lua`, nicht nur die Web-Dokumentation.

## 5. Source-verifizierter Air-Pfad

Im gepinnten Source sind für den Stage-1D-P-Pfad vorhanden:

```text
AUFTRAG:NewLANDATCOORDINATE(Coordinate, OuterRadius, InnerRadius, Time, Speed, MissionAlt, CombatLanding, DirectionAfterLand)
AUFTRAG:SetRequiredAssets(NassetsMin, NassetsMax)
AUFTRAG:AssignSquadrons(Squadrons)
AIRWING:onafterFlightOnMission(From, Event, To, FlightGroup, Mission)
FLIGHTGROUP:onafterTakeoff(From, Event, To, airbase)
OPSGROUP:onafterMissionDone(From, Event, To, Mission)
OPSGROUP:Get2DDistance(Coordinate)
LEGION:onafterLegionAssetReturned(From, Event, To, Cohort, Asset)
```

Zusätzlich ist `FLIGHTGROUP:IsAirborne()` im gepinnten MOOSE-Stand verfügbar und wird als physischer Grounded-Nachweis vor der strategischen Delivery verwendet.

### 5.1 LANDATCOORDINATE-Ziel

`AUFTRAG:NewLANDATCOORDINATE(...)` übernimmt eine `COORDINATE`. Stage 1D-P übergibt die Koordinate der bereits vorhandenen Mission-Editor-Static:

```text
OMW_BLUE_LZ_FORTRESS_01
```

Die Radius-Argumente bleiben `nil`. Dadurch wird keine zusätzliche Zufallsziel-Geometrie eingeführt. Es wird keine neue Triggerzone benötigt.

Der Acceptance-Parameter:

```text
Time = 30 s
```

ist eine kurze Landing-/Dwell-Konfiguration am Ziel, **kein Travel-Timeout**.

### 5.2 Air-Asset-Auswahl

Der vorhandene Jalalabad-Foundation-Code registriert den CH-47-Squadron bereits mit:

```text
AUFTRAG.Type.TROOPTRANSPORT
AUFTRAG.Type.CARGOTRANSPORT
AUFTRAG.Type.LANDATCOORDINATE
```

Stage 1D-P verwendet deshalb keine neue parallele Air-Dispatcher-Logik. Die Acceptance bindet genau einen bestehenden Squadron über:

```text
mission:SetRequiredAssets(1, 1)
mission:AssignSquadrons({ squadron })
airwing:AddMission(mission)
```

### 5.3 Delivery-Nachweis

Die strategische Delivery erfolgt erst nach dem physischen Zielnachweis:

```text
MissionDone for the assigned LANDATCOORDINATE mission
AND FLIGHTGROUP:IsAirborne() == false
AND Get2DDistance(Fortress FARP coordinate) <= 100 m
-> CampaignState MarkDelivered(...)
-> MissionDemand SUCCESS
```

Die 100 m sind ausschließlich eine Acceptance-Toleranz um den vorhandenen FARP-Punkt. Sie erzeugen keine neue Route oder Zielzone.

### 5.4 Rückkehr

Der gepinnte AUFTRAG-/OPSGROUP-Source behandelt die Rückkehr von Air Assets über den normalen Legion/AIRWING-Lifecycle. Der für Army/Navy relevante `SetReturnToLegion(...)`-Schalter ist nicht der Air-Rückkehrmechanismus.

Stage 1D-P beobachtet daher nach erfolgreicher Lieferung:

```text
LEGION/AIRWING LegionAssetReturned
-> gleicher Mission-Assetdatensatz
-> gleicher CH-47-Squadron
-> Asset wieder an Jalalabad zurückgegeben
```

Es wird kein eigener Native-DCS-RTB-Dispatcher eingeführt.

## 6. Ground-Pfad

Der Ground-Pfad übernimmt bewusst den bereits akzeptierten NOTHING-Vertrag:

```text
BRIGADE / PLATOON / ARMYGROUP
AUFTRAG:NewNOTHING(destinationZone)
SetMissionSpeed(27)
SetFormation(ENUMS.Formation.Vehicle.OnRoad)
SetReturnToLegion(false)
BRIGADE:AddMission(...)
destination-zone proof
CampaignState MarkDelivered(...)
MissionDemand SUCCESS
mission cancel
MissionDone
delayed ARMYGROUP:RTZ(originZone, OnRoad)
Returned
WAREHOUSE AddAsset
```

Kein neuer Ground-Routing-Mechanismus und keine neue Honaker-Zone werden eingeführt.

## 7. Ausdrückliche Ausschlüsse

```text
TROOPTRANSPORT
OPSTRANSPORT
physical Infantry GROUP cargo
CTLD troop cargo
native DCS world event dispatcher
MIST
MissionScripting.lua modification
hard outbound travel timeout
hard return travel timeout
new Fortress target zone
new Honaker target zone
```

## 8. Stage-Status

```text
Source review: PASS
Implementation: STAGED
PowerShell build: pending local owner execution
DCS runtime: pending
VALIDATED: no
```

Ein DCS-PASS darf erst nach realem Build-/Hashnachweis, exakter MIZ-Provenienz und beobachtetem Ground- und Air-Lifecycle dokumentiert werden.
