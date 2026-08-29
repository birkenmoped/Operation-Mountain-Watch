---
document_id: OMW-MOOSE-GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-ACCEPTANCE-4-RUNTIME-RESULT
status: DRAFT
document_class: TECHNICAL_EVIDENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 1D-P Air PERSONNEL Acceptance-4 runtime evidence
  - LANDATCOORDINATE TaskDone delivery-settlement evidence
  - OMW_FlightPath Jalalabad-Fortress physical-return evidence
  - documented lessons from Acceptance-1 through Acceptance-4
not_authoritative_for:
  - repository-wide production architecture before merge or explicit governance adoption
  - physical infantry-group transport
  - production-wide rotary-wing corridor behavior outside the documented scope
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/automatic-response-orchestration-continuation
source_commit: be8adc3ad1e2cfa6de7a25252cd8b217caeccde3
validated_in_dcs: true
runtime_result: PASS
accepted_technical_baseline: false
acceptance_blocker:
  - final mission MIZ SHA-256 not yet returned by the project owner
---

# Stage 1D-P – Air PERSONNEL FlightPath / Physical Return Acceptance-4

## 1. Ergebnis

Der owner-ausgeführte DCS-Lauf von `AIR-PERSONNEL-FLIGHTPATH-RETURN-ACCEPTANCE-4` hat den beabsichtigten Air-PERSONNEL-Lifecycle technisch als **PASS** ausgeführt:

```text
Jalalabad CH-47 materializes
-> physical takeoff
-> OMW_FlightPath outbound corridor
-> LANDATCOORDINATE at OMW_BLUE_LZ_FORTRESS_01
-> physical intermediate landing / approximately 30 s dwell
-> matching MOOSE TaskDone while 4.1 m from Fortress LZ
-> CampaignState transfer DELIVERED
-> MissionDemand SUCCESS
-> physical departure from Fortress
-> OMW_FlightPath return corridor
-> physical landing at Jalalabad
-> only afterwards LegionAssetReturned
-> PASS
```

Der DCS-Log-PASS lautet:

```text
PASS resource=GROUND_PERSONNEL air=JALALABAD_TO_FORTRESS final=447/160
pathline=OMW_FlightPath rightOffsetM=500 rightHeadingDeltaDeg=+90
corridorPoints=14 outboundWaypoints=14 returnWaypoints=13
takeoffs=1 landTaskDoneCount=1
landingZone=OMW_BLUE_LZ_FORTRESS_01 physicalReturn=JALALABAD
personnelFloor=80_PERCENT_STRICT_BELOW
```

## 2. Exakte Laufzeit-Provenienz

```text
Branch:
agent/automatic-response-orchestration-continuation

Source / builder commit:
be8adc3ad1e2cfa6de7a25252cd8b217caeccde3

BuilderVersion:
AIR-PERSONNEL-FLIGHTPATH-RETURN-ACCEPTANCE-4-1

TestId:
AIR-PERSONNEL-FLIGHTPATH-RETURN-ACCEPTANCE-4

Bundle:
OMW_Air_PERSONNEL_FlightPath_Return_Acceptance_4.lua

Bundle SHA-256:
C2BD325AF48BF6EA08936BCA666E4460293B60CC36FB8FE0181BC5140DF9ABD3

Mission filename:
OMW_Template_v20_GroundWorks.miz

Mission SHA-256:
PENDING OWNER HASH

DCS:
2.9.29.27278 MT

MOOSE release:
2.9.18

MOOSE commit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

Moose.lua SHA-256:
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915

dcs.log SHA-256:
83BB6CECB0DEE23DC4DF7ACAEE3D344347B5E73A101ADEF1536E740090937FF5

debrief.log SHA-256:
AC694CDEC BBD2A76547A63BC1375C5AEC2B6FC9424D7EAEDD2F7EDF14994C40F
```

Hinweis: Der `debrief.log`-Hash ist ohne Leerzeichen zu lesen als:

```text
AC694CDECBBD2A76547A63BC1375C5AEC2B6FC9424D7EAEDD2F7EDF14994C40F
```

### Governance-Grenze

Der reale DCS-Lauf ist ein Runtime-PASS. Das Dokument wird **noch nicht** auf `ACCEPTED_TECHNICAL_BASELINE` gesetzt, weil nach `OMW-GOV-001` zur vollständigen Acceptance-Provenienz auch der Hash der exakt getesteten `.miz` gehört. Dieser Hash liegt für den nachträglich verfeinerten 84-Punkte-FlightPath-Stand noch nicht vor.

Sobald der Owner den realen SHA-256 der getesteten `OMW_Template_v20_GroundWorks.miz` zurückliefert, kann dieser konkrete Stand ohne erneuten DCS-Lauf zur branch-lokalen `ACCEPTED_TECHNICAL_BASELINE` promoviert werden, sofern der Hash zur tatsächlich getesteten Datei gehört.

## 3. Verbindlich festgelegter PERSONNEL-Vertrag

Stage 1D-P verwendet `PERSONNEL` als **strategische CampaignState-Meta-Ressource**, nicht als sichtbare 1:1-Infanterie-Cargoeinheit.

```text
resourceId: GROUND_PERSONNEL
target: 100%
resupply trigger: strictly below 80%
exactly 80%: no demand
requested quantity: refill to 100%
critical threshold: none in this stage
```

Acceptance-Werte:

```text
Jalalabad initial: 480
Fortress target:   160
simulated Fortress shortage: 160 -> 127
Fortress 80% floor: 128
transfer quantity: 33
expected final: Jalalabad 447 / Fortress 160
```

Autorität:

```text
CampaignState
-> sole strategic quantity/status authority

MOOSE
-> physical carrier, mission and lifecycle authority
```

Der strategische Transfer wird von OMW exakt einmal gebucht, nachdem MOOSE den passenden physischen Missionsnachweis liefert.

## 4. Meta-PERSONNEL ist nicht taktischer Truppentransport

Festgelegte Trennung:

```text
ordinary PERSONNEL resupply
-> abstract strategic headcount
-> ground or air carrier may represent transport
-> no visible Infantry GROUP required

FOB/COP -> OP deployment
or FOB/COP/base -> AO insertion/extraction
-> real Infantry GROUP
-> separate tactical transport contract
```

Daher gilt für diesen Resupply-Scope:

```text
AUFTRAG:NewTROOPTRANSPORT(...) = intentionally not used
OPSTRANSPORT = intentionally not used as strategic PERSONNEL authority
CTLD troop cargo = intentionally not used
```

`TROOPTRANSPORT` bleibt ein MOOSE-first Kandidat für späteren **physischen** Infanterietransport.

## 5. Gelernt: Intermediate FARP ist für diesen AIRWING-Pfad ungeeignet

Der erste kombinierte Stage-1D-P-Test verwendete `OMW_BLUE_LZ_FORTRESS_01` als DCS Invisible FARP. Der CH-47 landete dort, wurde aber unmittelbar am fremden FARP als AIRWING/LEGION-Asset zurückgegeben/despawnt statt physisch nach Jalalabad zurückzufliegen.

Der gepinnte MOOSE-Source erklärt dieses Verhalten: `FLIGHTGROUP:onafterArrived(...)` kann einen AIRWING-Flug an das Legion zurückgeben; der Source enthält selbst einen TODO-Hinweis, dass dabei nicht geprüft wird, ob die aktuelle Basis tatsächlich die AIRWING-Heimatbasis ist.

Festlegung für diesen Scope:

```text
Intermediate operational LZ
-> ordinary trigger-zone / coordinate landing anchor
-> no AIRBASE/FARP semantics

Home return
-> real Jalalabad landing
-> only then LegionAssetReturned accepted
```

Die neue Fortress-LZ ist deshalb eine normale Mission-Editor-Triggerzone:

```text
OMW_BLUE_LZ_FORTRESS_01
```

Es wurde kein eigener Native-DCS-RTB-Mechanismus eingeführt.

## 6. Gelernt: `LegionAssetReturned` ist kein physischer RTB-Nachweis

Aus der FARP-Fehlannahme folgt projektweit für den dokumentierten Air-Scope:

```text
MissionDone != physical return
ReturnToLegion != physical return
LegionAssetReturned alone != physical return proof
```

Der akzeptierte Nachweis ist:

```text
FLIGHTGROUP OnAfterLanded at Jalalabad
-> homeLandingConfirmed=true
-> afterwards AIRWING/LEGION LegionAssetReturned
```

Acceptance-4 bestätigt genau diese Reihenfolge:

```text
AIR_HOME_LANDED ... airbase=Jalalabad deliveryConfirmed=true
AIR_LEGION_ASSET_RETURNED ... homeLandingConfirmed=true
PASS ... physicalReturn=JALALABAD
```

## 7. OMW_FlightPath – festgelegter Corridor-Vertrag

Die owner-erstellte Mission-Editor-Linie:

```text
OMW_FlightPath
```

wird durch MOOSE als `PATHLINE` aufgelöst. Es gibt keine parallele OMW-Routendatenbank und kein natives `env.mission`-Parsing.

Owner-Festlegung:

```text
OMW_FlightPath = preferred rotary-wing valley centerline
not a hard geographic constraint
mission purpose may leave the corridor when required
```

Der Owner hat die Linie nach Acceptance-1 verfeinert und vor Taleinschnitten, Abzweigungen sowie vor/bei FOB/COP zusätzliche Punkte gesetzt. Der getestete Stand enthält:

```text
PATHLINE points: 84
Jalalabad -> Fortress corridor points used: 14
origin waypoint index: 1
destination waypoint index: 14
nearest owner-authored Fortress corridor point: approximately 692.4 m from LZ
```

Der Acceptance-Harness verwendet bewusst den nächstgelegenen **owner-authored PATHLINE waypoint** als Leave-/Rejoin-Anker. Eine automatische Segmentprojektion oder dynamische Terrain-Suche wurde nicht eingeführt.

## 8. Laterale Trennung – Runtime-Kalibrierung

Owner-Festlegung:

```text
nominal lane = 500 m right of OMW_FlightPath
relative to current direction of travel
```

Damit liegen Gegenrichtungen nominell auf gegenüberliegenden Seiten der Referenzlinie und ungefähr 1000 m auseinander.

Acceptance-1 zeigte visuell, dass die zunächst verwendete Umsetzung mit `heading - 90°` im konkreten OMW/DCS-Pfad links der gewünschten Flugrichtung lag. Acceptance-2 bis -4 verwenden deshalb die owner-runtime-kalibrierte Variante:

```text
right-hand OMW lane = heading + 90°
```

Wichtige Grenze: Das ist eine **OMW-/DCS-Runtime-Kalibrierung für diesen Pfad**, keine pauschale Behauptung, dass MOOSE `+90°` generell als rechts definiert.

Testkonfiguration:

```text
right offset: 500 m
corridor waypoint altitude: 500 ft AGL
outbound waypoints: 14
return waypoints: 13
```

## 9. Acceptance-1 bis Acceptance-4 – Fehlerkette und Korrekturen

### Acceptance-1

Physischer Grundpfad funktionierte, aber:

```text
43-point FlightPath
coarse Fortress leave point
visible detour/U-turn before Fortress
heading -90° appeared on wrong side
```

Lerneffekt:

```text
owner-authored route needs meaningful points before valley branches / FOBs / COPs
right-side offset must be runtime-calibrated
```

### Acceptance-2

Mit verfeinertem 84-Punkte-FlightPath und `+90°` war der physische Ablauf optisch korrekt:

```text
Jalalabad -> corridor -> Fortress landing/dwell -> departure -> corridor -> Jalalabad
```

Der Harness band Delivery jedoch fälschlich an einen zweiten `OnAfterTakeoff`-Callback. Der sichtbare Wiederabflug erfolgte, aber der Harness erhielt keinen für diese Logik verwertbaren zweiten Takeoff-Callback. Ergebnis:

```text
false negative: AIR_HOME_LANDED_BEFORE_DELIVERY
```

Festlegung:

```text
second takeoff is not PERSONNEL delivery authority
```

Es wird ausdrücklich **keine** allgemeine Sonderbehauptung über Pinnacle-Landungen oder DCS-Takeoff-Erkennung daraus abgeleitet.

### Acceptance-3

Delivery wurde anschließend an `MissionDone near Fortress` gebunden. Das war ebenfalls falsch, weil der Auftrag einen Mission-Egress besitzt.

Der gepinnte MOOSE-Lifecycle und der DCS-Lauf zeigten:

```text
LANDATCOORDINATE task at Fortress
-> aircraft departs
-> return corridor / egress
-> only then MissionDone
```

Im Acceptance-3-Lauf kam `MissionDone` ungefähr 48.6 km vom Fortress-LZ entfernt. Damit ist `MissionDone` bei gesetztem Egress zu spät für das Delivery-Settlement.

Festlegung:

```text
MissionDone = mission-level completion diagnostic
not LANDATCOORDINATE delivery instant when egress exists
```

### Acceptance-4

Die endgültige MOOSE-first Korrektur verwendet den Task-Lifecycle:

```text
FLIGHTGROUP / OPSGROUP OnAfterTaskDone
-> compare completed Task with air.mission:GetGroupWaypointTask(flightGroup)
-> require matching Task.id
-> require distance to Fortress LZ <= 250 m
-> MarkDelivered
-> MissionDemand SUCCESS
```

Real gemessen:

```text
AIR_DELIVERY_CONFIRMED_ON_LANDAT_TASK_DONE
distanceM=4.1
landTaskDoneCount=1
quantity=33
campaignStateStatus=DELIVERED
demandStatus=SUCCESS
```

Danach kam `MissionDone` nur noch diagnostisch und `deliveryCommitted=true`.

## 10. Akzeptierter Delivery- und Return-Lifecycle

Für diesen exakten Meta-PERSONNEL-Air-Scope gilt:

```text
CampaignState shortage below 80%
-> MissionDemand RESUPPLY
-> CampaignState reserve/transfer Jalalabad -> Fortress
-> Jalalabad AIRWING / SQ_US_JBAD_CH47_HEAVYLIFT
-> AUFTRAG:NewLANDATCOORDINATE(Fortress LZ, dwell=30 s)
-> OMW_FlightPath outbound
-> physical Fortress landing
-> MOOSE matching OnAfterTaskDone near Fortress
-> exact-once CampaignState MarkDelivered
-> MissionDemand SUCCESS
-> physical return corridor
-> MissionDone may occur later at/after egress and is diagnostic
-> physical OnAfterLanded at Jalalabad
-> LegionAssetReturned
-> PASS
```

Der 30-s-Wert ist Landing-/Dwell-Zeit, **kein Travel-Timeout**.

Es gibt weiterhin:

```text
no hard outbound travel timeout
no hard return travel timeout
```

## 11. MOOSE-first Methoden/Funktionen – in diesem Scope praktisch bestätigt

Gepinnter Stand wie in Abschnitt 2.

Praktisch bestätigt bzw. als Teil des bestandenen Pfads verwendet:

```text
PATHLINE:FindByName(...)
PATHLINE:GetCoordinates(...)
COORDINATE:HeadingTo(...)
COORDINATE:Translate(...)

AUFTRAG:NewLANDATCOORDINATE(...)
AUFTRAG:SetMissionEgressCoord(...)
AUFTRAG:AssignSquadrons(...)
AUFTRAG:GetGroupWaypointIndex(...)
AUFTRAG:GetGroupEgressWaypointUID(...)
AUFTRAG:GetGroupWaypointTask(...)

FLIGHTGROUP:AddWaypoint(...)
FLIGHTGROUP OnAfterTakeoff
FLIGHTGROUP / OPSGROUP OnAfterTaskDone
FLIGHTGROUP OnAfterMissionDone
FLIGHTGROUP OnAfterLanded
OPSGROUP:Get2DDistance(...)

AIRWING:AddMission(...)
AIRWING OnAfterFlightOnMission
LEGION/AIRWING OnAfterLegionAssetReturned
```

Scope-Grenze: Der PASS validiert diese Methoden nur in der hier dokumentierten Kombination, Mission, DCS-/MOOSE-Version und Geometrie.

## 12. Bewusst nicht verwendete / verworfene Pfade

```text
MIST
native DCS world event handler
native DCS routing dispatcher
MissionScripting.lua modification
TROOPTRANSPORT for meta-PERSONNEL
OPSTRANSPORT as strategic PERSONNEL owner
physical Infantry GROUP cargo for ordinary PERSONNEL resupply
Intermediate Invisible FARP at Fortress for this AIRWING mission
LegionAssetReturned as sole physical-return proof
MissionDone as Fortress delivery instant when mission egress exists
second Takeoff as mandatory delivery signal
hard Air travel timeout
automated MIZ mutation
dynamic terrain scanner
parallel FlightPath database
```

## 13. Was dieser PASS nicht beweist

Nicht pauschal validiert sind:

```text
- jeder andere Flugkorridor;
- jede andere LZ;
- jedes andere Helikoptermuster;
- taktischer Infantry GROUP transport;
- Multiplayer-Failure-/Restart-/Restore-Idempotence;
- andere MOOSE- oder DCS-Versionen;
- production-wide automatic response orchestration.
```

## 14. Nächster formaler Schritt

Kein weiterer DCS-Wiederholungslauf ist für diesen identischen technischen Pfad erforderlich, **wenn** der Owner den SHA-256 der tatsächlich getesteten `.miz` nachliefert und dieser Stand unverändert ist.

Danach:

```text
complete exact provenance
-> promote this branch-local runtime result to ACCEPTED_TECHNICAL_BASELINE
-> update handoff / method and class evidence
-> proceed to next planned orchestration stage
```
