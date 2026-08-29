---
document_id: OMW-MOOSE-GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-FLIGHTPATH-ACCEPTANCE-2-RUNTIME-FINDINGS
status: STAGED
document_class: TECHNICAL_EVIDENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 1D-P Air PERSONNEL Acceptance-1 and Acceptance-2 runtime findings
  - Acceptance-3 correction scope
not_authoritative_for:
  - DCS validation of Acceptance-3
  - production-wide rotary-wing corridor validation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/automatic-response-orchestration-continuation
validated_in_dcs: false
---

# Stage 1D-P – FlightPath Acceptance Runtime Findings

## 1. Acceptance-1: Corridor und Seitenversatz

Der owner-ausgefuehrte DCS-Lauf von `AIR-PERSONNEL-FLIGHTPATH-RETURN-ACCEPTANCE-1` zeigte den grundsaetzlich funktionierenden MOOSE-Pfad:

```text
Jalalabad CH-47 materialisiert
-> OMW_FlightPath wird als Corridor installiert
-> Fortress wird angeflogen
-> normale LZ-Zwischenlandung funktioniert
-> CH-47 startet erneut
-> Rueckflug wird ausgefuehrt
```

Die DCS-Sichtpruefung zeigte bei `heading - 90 degrees` jedoch eine Spur links der jeweiligen Flugrichtung. Acceptance-2 kalibrierte deshalb fuer diesen OMW/DCS-Pfad:

```text
right-hand lane = heading + 90 degrees
```

Das ist eine runtime-basierte OMW-Kalibrierung und keine allgemeine Aussage ueber jedes MOOSE-/DCS-Koordinatensystem.

Der Owner verfeinerte `OMW_FlightPath` danach bewusst mit Punkten vor Taleinschnitten, an Abzweigungen sowie vor und bei FOB/COP. Acceptance-2 nutzt diese owner-authored Geometrie direkt und verlaesst bzw. betritt den Corridor am naechsten passenden PATHLINE-Waypoint. Eine automatische Segmentprojektion wird nicht eingefuehrt.

## 2. Acceptance-2: Physischer Ablauf

Im owner-ausgefuehrten Acceptance-2-Lauf war der physische Ablauf nach Sichtbeobachtung korrekt:

```text
Jalalabad takeoff
-> FlightPath outbound
-> Fortress approach
-> sichtbare Zwischenlandung / dwell an der LZ
-> erneuter Abflug
-> FlightPath return
-> physische Rueckkehr nach Jalalabad
```

Der CH-47 fuehrte an Fortress eine sichtbare Zwischenlandung aus, blieb dort fuer die vorgesehene Bodenphase und hob danach wieder ab.

Gleichzeitig meldete MOOSE den zugehoerigen `AUFTRAG:NewLANDATCOORDINATE(...)` ueber den matching `FLIGHTGROUP:OnAfterMissionDone(...)` erfolgreich als beendet. Der physische Missionsablauf und der MOOSE-Auftrag waren daher nicht die Fehlerquelle des Acceptance-2-Fails.

## 3. Acceptance-2: Harness-Fehler beim PERSONNEL-Settlement

Acceptance-2 hatte den strategischen PERSONNEL-Transfer faelschlich an einen zweiten `FLIGHTGROUP:OnAfterTakeoff(...)` gebunden:

```text
Takeoff #2 near Fortress
-> CampaignState MarkDelivered
-> MissionDemand SUCCESS
```

Im realen Lauf wurde der Wiederabflug sichtbar ausgefuehrt, der Harness erhielt jedoch keinen fuer diese Logik verwertbaren zweiten Takeoff-Callback. Deshalb blieb `deliveryCommitted=false` und die spaetere physische Jalalabad-Landung fuehrte zu:

```text
FAIL reason=AIR_HOME_LANDED_BEFORE_DELIVERY
```

Das ist ein False Negative des Acceptance-Harnesses. Aus diesem Lauf wird keine allgemeine Aussage ueber eine DCS- oder MOOSE-Pinnacle-Landing-Sondersemantik abgeleitet.

## 4. Acceptance-3: korrigierter MOOSE-first Settlement-Punkt

Fuer den hier getesteten Meta-PERSONNEL-Transport ist der geeignete Settlement-Punkt der bereits vorhandene erfolgreiche MOOSE-Missionsabschluss des konkreten `LANDATCOORDINATE`-Auftrags, zusaetzlich raeumlich gegen die Fortress-LZ abgesichert:

```text
matching FLIGHTGROUP:OnAfterMissionDone(Mission)
AND Mission == assigned LANDATCOORDINATE mission
AND FLIGHTGROUP within 250 m of OMW_BLUE_LZ_FORTRESS_01
-> CampaignState MarkDelivered
-> MissionDemand SUCCESS
```

Damit bleibt die Autoritaet sauber getrennt:

```text
MOOSE
-> bestaetigt die physische Ausfuehrung des LANDATCOORDINATE-Auftrags

CampaignState
-> bucht daraufhin den strategischen GROUND_PERSONNEL-Transfer exakt einmal als DELIVERED
```

Ein erfolgreicher `MissionDone` ohne passenden Auftrag oder ausserhalb des Fortress-LZ-Radius reicht nicht fuer das Settlement.

Der spaetere Wiederabflug ist fuer die Lieferung nicht mehr erforderlich. Er gehoert zum physischen Rueckkehr-Lifecycle des Luftfahrzeugs.

## 5. Return-Nachweis bleibt unveraendert streng

Acceptance-3 behaelt die bestehende Trennung zwischen Lieferung und Asset-Rueckkehr bei:

```text
LANDATCOORDINATE MissionDone near Fortress LZ
-> PERSONNEL delivered

spaeter:
physical OnAfterLanded at Jalalabad
-> danach AIRWING OnAfterLegionAssetReturned
-> PASS
```

`MissionDone` ist damit Delivery-Nachweis fuer die transportierte Meta-Ressource, aber weiterhin **kein** physischer RTB-Nachweis fuer den CH-47. `LegionAssetReturned` allein ist ebenfalls weiterhin kein ausreichender physischer Rueckkehrnachweis.

## 6. Unveraenderte Grenzen

```text
CampaignState remains strategic authority.
No physical infantry cargo group.
No TROOPTRANSPORT for meta-PERSONNEL resupply.
No MIST.
No native DCS event handler.
No MissionScripting.lua modification.
No hard Air travel timeout.
No automated MIZ mutation.
```

Acceptance-3 bleibt `STAGED` bis zum realen DCS-Lauf mit exakter Commit-/Bundle-/MIZ-/DCS-/MOOSE-Provenienz.
