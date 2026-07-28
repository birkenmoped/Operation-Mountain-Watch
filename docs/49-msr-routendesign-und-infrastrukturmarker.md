---
document_id: OMW-MSR-ROUTE-DESIGN
status: PLANNED
document_class: DESIGN_WORKLIST
owning_policy: OMW-GOV-001
authoritative_for:
  - MSR route segmentation
  - route geometry and routing-point separation
  - infrastructure marker classification
  - MSR design worklist
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - legacy document title 18 – MSR-Routendesign und Infrastrukturmarker
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit:
validated_in_dcs: false
---

# 49 – MSR-Routendesign und Infrastrukturmarker

## 1. Zweck

Dieses Dokument ist die aktuelle Design- und Arbeitsreferenz für Main Supply Routes, Routensegmente, MOOSE-`PATHLINE`s, Routinganker und Infrastrukturmarker.

Der vollständige frühere Entwurfsstand bleibt unverändert erhalten:

- [`Legacy-MSR-Entwurf`](evidence/source-records/legacy-49-msr-route-design-pre-metadata-migration.md)

Maßgebliche Architektur:

- [`OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`](37-campaign-architecture-and-dynamic-mission-design.md)
- [`OMW-ME-MASTER-WORKLIST`](38-mission-editor-master-worklist.md)
- [`OMW-GOV-MOOSE-FIRST`](26-moose-first-development-policy.md)
- [`OMW-HIST-AFGHANISTAN-WAR-CARLISLE-SOURCE-REVIEW`](53-afghanistan-war-carlisle-source-review.md) für Route-Clearance-, IED- und PRT-Missionsmuster.

## 2. Datenebenen

### 2.1 Routengeometrie

Jedes MSR-Segment besitzt genau eine geordnete Missionseditor-Draw-Linie beziehungsweise MOOSE-`PATHLINE`.

Beispiele:

```text
MSR_EAST_E01
MSR_EAST_E02
MSR_KUNAR_K01
MSR_CAL_C01
```

Die `PATHLINE` beschreibt Korridor und Punktreihenfolge. Sie ist nicht automatisch die endgültige DCS-Gruppenroute.

### 2.2 Technische Routingpunkte

```text
RP_K01_001
RP_K01_002
RP_K01_003
```

Routingpunkte werden nur an tatsächlich erforderlichen Stellen gesetzt, etwa an:

- problematischen Kreuzungen;
- parallelen Straßen;
- zwingenden Brücken oder Furten;
- Talwechseln;
- Basiszufahrten;
- bekannten DCS-Pathfinding-Problemen.

### 2.3 Infrastruktur- und Taktikmarker

```text
BRG_   Brücke
JCT_   relevante Kreuzung
FRD_   Furt oder Wasserübergang
CHK_   Engstelle
GATE_  Basiszufahrt
NODE_  regionaler Routenknoten
AA_    Assembly Area
WP_    Withdrawal Point
TP_    Transfer Point
```

Route-Security- und Engineer-Marker:

```text
RCP_   Route Clearance Point
EOD_   EOD-Arbeits- oder Übergabepunkt
IED_   bestätigter oder historisch definierter IED-Punkt
SUS_   verdächtiger Straßenabschnitt oder Indikator
BYP_   geprüfte Ausweichstelle
HALT_  vorgesehener sicherer Konvoi-Halt
REC_   Recovery-/Bergepunkt
```

Marker dokumentieren Funktion und Lage. Sie ersetzen keine Zonen, Templates oder Laufzeitobjekte, sofern diese technisch benötigt werden.

`IED_` und `SUS_` werden im Mission Editor nicht als dauerhaft sichtbare Spielerinformation verwendet. Sie sind Authoring- beziehungsweise Laufzeitreferenzen und werden nur entsprechend Intelligence-/Detection-Status aufgedeckt.

## 3. Segmentmetadaten

Jedes Segment benötigt mindestens:

```text
segmentId
fromNode
toNode
pathlineName
length
roadClass
vehicleSuitability
infantrySuitability
capacity
risk
blueExposure
knownChokepoints
requiredRoutingPoints
alternativeSegments
validationState
```

Zusätzliche Route-Security-Felder:

```text
clearanceStatus
lastClearanceTime
lastIncidentTime
suspectedIEDCount
confirmedIEDCount
bypassAvailable
engineerRequired
eodRequired
localTipConfidence
civilianTrafficLevel
reconstructionDependency
```

Zulässige `clearanceStatus`-Werte:

```text
UNCLEARED
CHECKING
PARTIAL
CLEARED
BLOCKED
DEGRADED
```

`CLEARED` ist zeitgebunden. Ein Segment bleibt nicht unbegrenzt sicher, wenn sich Feindlage, Beobachtung, ziviler Verkehr oder letzter Prüfzeitpunkt ändern.

## 4. Route-Clearance-Modell

Die Delaram–Bakwa-Vignette aus Dokument 53 wird nicht als exakte OMW-Einheit oder Technikbaseline verwendet, aber als belastbares Missionsmuster:

1. Route-Clearance-Element führt den Hauptkonvoi.
2. verdächtige Indikatoren können zum Halt führen;
3. Engineer-/EOD-Prüfung benötigt Zeit und Sicherung;
4. Bypass ist nur nach Prüfung zulässig;
5. Gegner können den Halt, Stau oder Ausweichweg für einen Complex Ambush nutzen;
6. ausgeschlossene oder voreilende Fahrzeuge verlieren den Schutz des gemeinsamen Verfahrens;
7. Erfolg ist eine sichere, nachvollziehbar freigegebene Route.

Zustände eines IED-Objekts:

```text
SUSPECTED
LOCATED
MARKED
RENDER_SAFE
CONTROLLED_DETONATION
DETONATED
BYPASSED
FALSE_INDICATOR
```

Mögliche Triggerklassen:

```text
PRESSURE
COMMAND_WIRE
RADIO
UNKNOWN
```

Die konkrete Erkennungswahrscheinlichkeit, Sprengwirkung und technische Neutralisierung werden nicht aus Dokument 53 übernommen, sondern in separaten Testmissionen validiert.

## 5. MOOSE-First-Routing

Vor eigener Routenberechnung sind insbesondere zu prüfen:

- MOOSE `Core.Astar`;
- `COORDINATE`-Routing- und Straßenfunktionen;
- `PATHLINE` und Zonen;
- `OPSGROUP` / `ARMYGROUP`;
- `OPSTRANSPORT`;
- Wrapper-, Set-, Detection-, Event- und Scheduler-Funktionen.

Vor eigener Route-Clearance- oder IED-Zustandslogik ist zusätzlich zu prüfen, welche MOOSE-Funktionen bereits abbilden:

- Detektion und Intel-Level;
- Zonen- und Wegereignisse;
- Aufgaben/FSMs;
- Escort-/Convoy-Verhalten;
- Cargo-/Engineer-Transport;
- dynamische Re-Route und Halt/Resume.

Eigene Routing- oder IED-Logik benötigt das vollständige Ausnahmeverfahren aus Dokument 26.

## 6. DCS-spezifische Regeln

- Fahrzeuge verwenden nur validierte Straßen und Wege.
- Keine unrealistischen Offroad-Routen durch Wald, Wasser oder steile Hänge.
- Abgelegene letzte Strecken können als Infanterie- oder Hybridtransport modelliert werden.
- Routenänderungen während Beobachtung oder Kampf dürfen keine sichtbare Teleportation erzeugen.
- Pack/Unpack und Virtualisierung müssen Tracking, Spielerentfernung und Feindkontakt berücksichtigen.
- Ein ungeklärtes Segment darf nicht allein wegen einer vorhandenen DCS-Straße als sicher gelten.
- Haltende Route-Clearance- und Convoy-Gruppen müssen ausreichenden Abstand halten, ohne Kreuzungen oder Brücken vollständig zu blockieren.
- Bypass-Entscheidungen dürfen keine unrealistische Geländequerung erzeugen.
- Zerstörte oder bewegungsunfähige Fahrzeuge erzeugen einen Blockage-/Recovery-Zustand.
- Watchguard-Teleportation ist bei Feindkontakt, Aufklärung oder Angriff zu sperren beziehungsweise kontrolliert zu begrenzen.

## 7. PRT- und Infrastrukturabhängigkeit

Routen können von Reconstruction-Projekten abhängen:

```text
ROAD_REPAIR
BRIDGE_REPAIR
CULVERT_REPAIR
WATER_CROSSING
MARKET_ACCESS
CLINIC_ACCESS
POWER_INFRASTRUCTURE
```

Ein beschädigtes Projekt kann:

- Kapazität reduzieren;
- Fahrzeit erhöhen;
- alternative Segmente erzwingen;
- lokale Unterstützung verändern;
- zusätzliche Engineer-/Security-Missionen erzeugen.

Die Wiederherstellung wird nicht allein durch das Platzieren eines statischen Objekts abgeschlossen. CampaignState, Transport, Sicherung und Übergabe müssen zusammengeführt werden.

## 8. Validierung je Segment

- [ ] Draw-/PATHLINE-Geometrie geprüft;
- [ ] Straßenanschluss in DCS geprüft;
- [ ] notwendige Routingpunkte dokumentiert;
- [ ] Hin- und Rückfahrt getestet;
- [ ] Konvoi unterschiedlicher Größen getestet;
- [ ] Brücken, Furten und Engstellen geprüft;
- [ ] Route-Clearance-Halt und Staffelabstand getestet;
- [ ] EOD-/Engineer-Übergabe getestet;
- [ ] IED-Detection-/Reveal-Zustand geprüft;
- [ ] Bypass praktisch befahrbar und geprüft;
- [ ] Blockage-/Recovery-Verhalten definiert;
- [ ] Stuck-/Watchguard-Verhalten getestet;
- [ ] Watchguard bei Beobachtung/Feindkontakt/Angriff geprüft;
- [ ] alternative Route oder Abbruchverhalten definiert;
- [ ] zeitliche Gültigkeit von `CLEARED` geprüft;
- [ ] CampaignState-/Persistenzübergabe geprüft;
- [ ] DCS-, OMW- und MOOSE-Version dokumentiert;
- [ ] Ergebnisbericht mit Logs und Mission-Hash erstellt.

## 9. Status

Das Datenmodell und die Markerregeln sind geplant. Eine Route, ein Segment, eine Route-Clearance-Sequenz oder ein IED-Verfahren wird erst nach reproduzierbarem DCS-Test als technisch akzeptiert geführt.
