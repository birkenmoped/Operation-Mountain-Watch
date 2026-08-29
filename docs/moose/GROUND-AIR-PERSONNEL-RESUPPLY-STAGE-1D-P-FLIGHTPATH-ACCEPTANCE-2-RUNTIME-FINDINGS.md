---
document_id: OMW-MOOSE-GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-FLIGHTPATH-ACCEPTANCE-2-RUNTIME-FINDINGS
status: STAGED
document_class: TECHNICAL_EVIDENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 1D-P Air PERSONNEL Acceptance-1 runtime findings
  - Acceptance-2 correction scope
not_authoritative_for:
  - DCS validation of Acceptance-2
  - production-wide rotary-wing corridor validation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/automatic-response-orchestration-continuation
validated_in_dcs: false
---

# Stage 1D-P – FlightPath Acceptance-2 Runtime Findings

## 1. Anlass

Der owner-ausgefuehrte DCS-Lauf von `AIR-PERSONNEL-FLIGHTPATH-RETURN-ACCEPTANCE-1` zeigte, dass der grundsaetzliche MOOSE-Pfad funktioniert:

```text
Jalalabad CH-47 materialisiert
-> OMW_FlightPath wird als Corridor installiert
-> Fortress wird angeflogen
-> normale LZ-Zwischenlandung funktioniert
-> CH-47 startet erneut
-> Rueckflug wird ausgefuehrt
```

Der Lauf wird trotzdem nicht als PASS akzeptiert. Zwei Acceptance-1-Annahmen waren falsch bzw. zu streng.

## 2. DCS-runtime-kalibrierter Seitenversatz

Acceptance-1 berechnete die laterale Sollspur mit:

```text
heading - 90 degrees
```

Die owner-seitige Sichtpruefung zeigte sowohl outbound als auch inbound eine Flugspur links der jeweiligen Flugrichtung. Fuer Acceptance-2 wird deshalb fuer diesen OMW/DCS-Pfad kalibriert:

```text
right-hand lane = heading + 90 degrees
```

Das ist eine runtime-basierte OMW-Kalibrierung. Sie wird nicht als allgemeine Aussage ueber jedes MOOSE-/DCS-Koordinatensystem verallgemeinert.

## 3. FlightPath-Exit an owner-authored Waypoints

Acceptance-1 waehlt den OMW_FlightPath-Punkt mit der kleinsten 2D-Distanz zur Fortress-LZ und fuegt alle Corridor-Punkte bis einschliesslich dieses Punkts als MOOSE-Waypoints vor den `LANDATCOORDINATE`-Mission-Waypoint ein.

Damit verlaesst das Luftfahrzeug den Corridor an einem definierten FlightPath-Waypoint, nicht frei zwischen zwei Punkten. Im ersten Lauf lag der letzte verwendete Corridor-Punkt fuer den optimalen Fortress-Anflug unguenstig, wodurch der CH-47 vor der LZ sichtbar zurueckdrehen musste.

Der Owner hat `OMW_FlightPath` danach bewusst verfeinert und zusaetzliche Punkte gesetzt:

```text
- vor Taleinschnitten,
- an Abzweigungen,
- vor FOB/COP,
- bei FOB/COP,
- an weiteren taktisch sinnvollen Join-/Leave-Stellen.
```

Acceptance-2 nutzt diese owner-validierte Geometrie bewusst direkt. Es wird keine zusaetzliche automatische Segmentprojektion eingefuehrt.

## 4. Delivery-Lifecycle

Acceptance-1 erwartete `FLIGHTGROUP:OnAfterLandedAt(...)` als Delivery-Nachweis. Im realen Lauf trat jedoch `MissionDone` auf, bevor dieser Harness-Nachweis die Delivery committed hatte. Der Harness erzeugte dadurch:

```text
FAIL reason=AIR_MISSION_DONE_BEFORE_DELIVERY
```

Die physische Zwischenlandung und der anschliessende Wiederstart waren visuell trotzdem vorhanden.

Acceptance-2 verwendet deshalb einen staerkeren beobachtbaren Nachweis:

```text
Takeoff #1 at Jalalabad
-> TRANSFER IN_TRANSIT

LANDATCOORDINATE Fortress
-> dwell 30 s

Takeoff #2 within 250 m of OMW_BLUE_LZ_FORTRESS_01
-> physical intermediate landing/restart proven
-> CampaignState MarkDelivered
-> MissionDemand SUCCESS
```

`MissionDone` wird nur noch diagnostisch protokolliert. Sein Zeitpunkt ist kein strategischer Delivery-Trigger.

## 5. Finaler Return-Nachweis

Acceptance-2 bleibt streng fuer die physische Rueckkehr:

```text
PERSONNEL delivered
AND second Fortress takeoff proven
AND physical OnAfterLanded at Jalalabad
AND only afterwards AIRWING OnAfterLegionAssetReturned
-> PASS
```

`LegionAssetReturned` allein ist weiterhin kein physischer RTB-Nachweis.

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

Acceptance-2 bleibt `STAGED` bis zum realen DCS-Lauf mit exakter Commit-/Bundle-/MIZ-/DCS-/MOOSE-Provenienz.
