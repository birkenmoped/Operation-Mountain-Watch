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

Marker dokumentieren Funktion und Lage. Sie ersetzen keine Zonen, Templates oder Laufzeitobjekte, sofern diese technisch benötigt werden.

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

## 4. MOOSE-First-Routing

Vor eigener Routenberechnung sind insbesondere zu prüfen:

- MOOSE `Core.Astar`;
- `COORDINATE`-Routing- und Straßenfunktionen;
- `PATHLINE` und Zonen;
- `OPSGROUP` / `ARMYGROUP`;
- `OPSTRANSPORT`;
- Wrapper-, Set- und Scheduler-Funktionen.

Eigene Routinglogik benötigt das vollständige Ausnahmeverfahren aus Dokument 26.

## 5. DCS-spezifische Regeln

- Fahrzeuge verwenden nur validierte Straßen und Wege.
- Keine unrealistischen Offroad-Routen durch Wald, Wasser oder steile Hänge.
- Abgelegene letzte Strecken können als Infanterie- oder Hybridtransport modelliert werden.
- Routenänderungen während Beobachtung oder Kampf dürfen keine sichtbare Teleportation erzeugen.
- Pack/Unpack und Virtualisierung müssen Tracking, Spielerentfernung und Feindkontakt berücksichtigen.

## 6. Validierung je Segment

- [ ] Draw-/PATHLINE-Geometrie geprüft;
- [ ] Straßenanschluss in DCS geprüft;
- [ ] notwendige Routingpunkte dokumentiert;
- [ ] Hin- und Rückfahrt getestet;
- [ ] Konvoi unterschiedlicher Größen getestet;
- [ ] Brücken, Furten und Engstellen geprüft;
- [ ] Stuck-/Watchguard-Verhalten getestet;
- [ ] alternative Route oder Abbruchverhalten definiert;
- [ ] DCS-, OMW- und MOOSE-Version dokumentiert;
- [ ] Ergebnisbericht mit Logs und Mission-Hash erstellt.

## 7. Status

Das Datenmodell und die Markerregeln sind geplant. Eine Route oder ein Segment wird erst nach reproduzierbarem DCS-Test als technisch akzeptiert geführt.
