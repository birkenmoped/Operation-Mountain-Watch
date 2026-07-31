---
document_id: OMW-MSR-ROUTE-DESIGN
status: PLANNED
document_class: DESIGN_WORKLIST
owning_policy: OMW-GOV-001
authoritative_for:
  - MSR route segmentation
  - route geometry and routing-point separation
  - infrastructure marker classification
  - historical route baseline for MSR California
  - route-clearance, observation, IED-risk and reinfiltration design worklist
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

Dieses Dokument ist die aktuelle Design- und Arbeitsreferenz für Main Supply Routes, Routensegmente, MOOSE-`PATHLINE`s, Routinganker, Infrastrukturmarker, Route Clearance und RED-Routeneinfluss.

Der vollständige frühere Entwurfsstand bleibt unverändert erhalten:

- [`Legacy-MSR-Entwurf`](evidence/source-records/legacy-49-msr-route-design-pre-metadata-migration.md)

Maßgebliche Architektur und Fachreferenzen:

- [`OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`](37-campaign-architecture-and-dynamic-mission-design.md)
- [`OMW-ME-MASTER-WORKLIST`](38-mission-editor-master-worklist.md)
- [`OMW-GOV-MOOSE-FIRST`](26-moose-first-development-policy.md)
- [`OMW-HIST-AFGHANISTAN-WAR-CARLISLE-SOURCE-REVIEW`](53-afghanistan-war-carlisle-source-review.md) für Route-Clearance-, IED- und PRT-Missionsmuster
- [`OMW-RED-INSURGENT-FACTIONS-BEHAVIOR`](56-insurgent-factions-shadow-governance-and-red-commander-behavior.md)
- [`OMW-RED-KANDAHAR-HELMAND-ENEMY-SYSTEM`](57-kandahar-helmand-enemy-system-and-red-commander-strategy.md) für historisch belegte Route-Observation-, IED-, Ambush-, Support-Zone- und Reinfiltrationsmuster

## 2. Datenebenen

### 2.1 Routengeometrie

Jedes MSR-Segment besitzt genau eine geordnete Missionseditor-Draw-Linie beziehungsweise MOOSE-`PATHLINE`.

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

Routingpunkte werden nur an tatsächlich erforderlichen Stellen gesetzt:

- problematische Kreuzungen;
- parallele Straßen;
- zwingende Brücken oder Furten;
- Talwechsel;
- Basiszufahrten;
- bekannte DCS-Pathfinding-Probleme.

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
OBS_   möglicher Beobachtungs- oder Pattern-of-Life-Punkt
AMB_   quellen- oder testbasierter Hinterhaltsraum
INF_   möglicher Infiltrationszugang zum Routensektor
```

Marker dokumentieren Funktion und Lage. Sie ersetzen keine Zonen, Templates oder Laufzeitobjekte.

`IED_`, `SUS_`, `OBS_`, `AMB_` und `INF_` sind keine dauerhaft sichtbaren Spielerinformationen. Ihre Sichtbarkeit hängt von Intelligence-, Detection- und CampaignState ab.

### 2.4 Historisch belegte Routenbaseline: MSR California

Für den Missionszeitraum ist `MSR California` als reale US-/ISAF-Main-Supply-Route im Kunar-Tal belegt. Die Bezeichnung darf nicht mit der projektinternen Sammelbezeichnung `MSR_KUNAR` gleichgesetzt werden.

#### 2.4.1 Quellenbelegte Strecken- und Funktionsmerkmale

Die Silver-Star-Narrative zu Specialist Jeffrey A. Conn beschreibt `MSR California` für Oktober 2011 mit folgenden Merkmalen:

- eine ausgebaute beziehungsweise verbesserte Straße;
- Nord-Süd-Verlauf parallel zum Kunar River;
- einzige Straßenverbindung zwischen Northern Kunar und der Provinzhauptstadt Asadabad;
- alleinige bodengebundene Versorgungsachse von südlichen Logistikknoten zu FOB Bostick;
- wiederholt für größere Brigade-Nachschubbewegungen genutzt;
- durch dominierendes Hochgelände und seitlich einmündende Täler stark beobachtungs- und hinterhaltsgefährdet.

Damit wird die bereits im Legacy-Entwurf festgehaltene Projektsegmentierung grundsätzlich bestätigt:

```text
MSR_CAL_C01  Asadabad → Asmar
MSR_CAL_C02  Asmar → Naray / FOB Bostick
```

Diese Zweiteilung ist eine projektinterne operative Segmentierung. Die Quellen bestätigen den durchgehenden Nord-Süd-Korridor, die Verbindung nach Asadabad und die Versorgungsfunktion für FOB Bostick. Sie definieren jedoch weder den exakten Segmentwechsel bei Asmar noch eine meter- oder straßengenau übertragbare DCS-Geometrie.

#### 2.4.2 Shal Mountain als schlüsselgebendes Gelände

Die Citation ordnet Shal Mountain im Asmar District als entscheidendes Gelände unmittelbar über dem Routenkorridor ein:

- Shal Mountain liegt ungefähr sieben Kilometer nördlich von COP Monti;
- der Berg erhebt sich laut Narrative etwa 1.100 Fuß über den Talboden;
- er überblickt `MSR California`;
- er dominiert zugleich eine ost-westlich verlaufende insurgente Versorgungs- und Infiltrationsachse im Shal Valley;
- Shal und Dab Valleys dienten als Zuführungs- und Feuerstellungsräume für Angriffe auf Konvois und Sicherungskräfte entlang der MSR.

Aufständische nutzten Shal Mountain über Jahre als Gefechtsstellung gegen ANA- und US-Kräfte auf `MSR California`. Im Juli 2011 wurden bei einem komplexen Hinterhalt während einer größeren Nachschuboperation zwei Soldaten des First Platoon, Bravo Company, getötet.

Während Operation `RUGGED SARAK` vom 8. bis 16. Oktober 2011 nahmen Bravo Company, 2-27 Infantry, und drei ANA-Kompanien Shal Mountain. Ziel war die Kontrolle des schlüsselgebenden Geländes, die Unterbindung der insurgenten Ost-West-Versorgungsroute und der Aufbau eines neuen ANA-Außenpostens. Second und Third Platoon sicherten Gefechtsstellungen an `MSR California`, während First Platoon das Hochgelände hielt.

#### 2.4.3 Ergänzende Gefechtsraumindizien

Ein offizieller U.S.-Army-Rückblick auf einen Einsatz im September 2009 beschreibt eine Patrouille von COP Pirtle-King zu FOB Bostick auf `MSR California`. Der Hinterhalt erfolgte gleichzeitig aus dem Hochgelände unmittelbar neben der Straße und von der gegenüberliegenden Seite des Flusses. Dies stützt für das Missionsdesign folgende Geländelogik:

- die Straße ist zwischen Fluss und Steilhängen kanalisiert;
- BLUE kann von derselben Straßenseite aus erhöhten Feuerstellungen bekämpft werden;
- zusätzliche Feuerstellungen können jenseits des Flusses liegen;
- verwundete oder liegengebliebene Fahrzeuge besitzen unter solchen Bedingungen keine eindeutig sichere Bergeseite.

#### 2.4.4 Konsequenzen für OMW-Geometrie und Marker

Für die spätere Einzeichnung und Validierung gelten folgende Arbeitsannahmen:

1. `MSR_CAL_C01` und `MSR_CAL_C02` müssen dem tatsächlich im DCS-Terrain vorhandenen straßengebundenen Kunar-River-Korridor folgen.
2. Asadabad, Asmar und die Zufahrt zu FOB Bostick bleiben die primären Routenknoten.
3. Der Shal-Mountain-/Shal-Valley-Raum ist als quellenbelegter Route-Dominance- und Ambush-Sektor zu erfassen.
4. Beobachtungs- und Hinterhaltsräume sind nicht nur straßennah, sondern auch auf dominierendem Hochgelände und jenseits des Flusses vorzusehen.
5. Für den historischen Kernkorridor ist keine gleichwertige, dauerhaft nutzbare Parallelstraße belegt. Ein DCS-Bypass darf daher nicht automatisch als strategisch gleichwertige Alternativ-MSR behandelt werden.
6. Der Verlust von Shal Mountain beziehungsweise unzureichende Hold-Präsenz muss den RED-Beobachtungs-, Ambush- und Infiltrationszugang erhöhen können.
7. Eine Operation zur Einnahme oder dauerhaften Sicherung des Hochgeländes kann als Route-Security-, ANA-Outpost- oder Clear-and-Hold-Mission umgesetzt werden.

Vorzusehende Markerklassen, zunächst ohne endgültige Koordinate:

```text
NODE_ASADABAD
NODE_ASMAR
NODE_BOSTICK_GATE
OBS_CAL_SHAL_MOUNTAIN
AMB_CAL_SHAL_DAB_SECTOR
INF_CAL_SHAL_VALLEY
CHK_CAL_KUNAR_CORRIDOR
GATE_BOSTICK
```

Die Silver-Star-Narrative belegt einen komplexen Hinterhalt, aber keinen exakten IED-Punkt. Aus dieser Quelle allein darf deshalb kein punktgenauer `IED_`-Marker erzeugt werden. Exakte Markerkoordinaten erfordern separate Karten-, Satellitenbild- oder SIGACT-Validierung.

#### 2.4.5 Quellenqualität und Provenienz

Primär verwendete Quelle:

- [Military Times Hall of Valor – Jeffrey A. Conn, Silver Star](https://valor.militarytimes.com/recipient/recipient-84896/), abgerufene Award Narrative für Operation `RUGGED SARAK`, 8.–16. Oktober 2011.

Offizielle inhaltliche Bestätigung:

- [U.S. Army Medical Department Center of History and Heritage – Silver Star citations OIF/OEF](https://achh.army.mil/regiment/silverstar-oifoef-oifoef1/), weitgehend gleichlautende Citation.

Ergänzende Gefechtsraumquelle:

- [Army University Press, NCO Journal – Reaching the Finish Line](https://www.armyupress.army.mil/Journals/NCO-Journal/Muddy-Boots/Reaching-the-Finish-Line/), retrospektiver Bericht zum Hinterhalt auf `MSR California` im September 2009.

Die Hall-of-Valor-Seite ist eine Sekundärpublikation einer militärischen Auszeichnungsnarrative. Die wesentlichen Routenangaben werden durch die offizielle AMEDD-Veröffentlichung bestätigt. Die Quellen liefern eine hohe Sicherheit für Name, allgemeinen Verlauf, Funktion und taktische Bedeutung der Route, aber keine ausreichende Grundlage für eine punktgenaue DCS- oder Google-Earth-Linienführung.

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

Zusätzliche Route-Security- und RED-Einflussfelder:

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
redObservationLevel
redPatternKnowledge
redCacheAccess
redAmbushAccess
redReinfiltrationAccess
bluePatrolFrequency
blueHoldStrength
routePredictability
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

`CLEARED` ist zeitgebunden. Ein Segment bleibt nicht unbegrenzt sicher, wenn sich Feindlage, Beobachtung, ziviler Verkehr, Hold-Präsenz oder letzter Prüfzeitpunkt ändern.

## 4. Route-Clearance-Modell

Die Delaram–Bakwa-Vignette aus Dokument 53 und die Helmand-/Kandahar-Studien aus Dokument 57 werden als Missionsmuster, nicht als exakte OMW-Einheitsbaseline verwendet:

1. Route-Clearance-Element führt den Hauptkonvoi;
2. verdächtige Indikatoren können zum Halt führen;
3. Engineer-/EOD-Prüfung benötigt Zeit und Sicherung;
4. Bypass ist nur nach Prüfung zulässig;
5. Gegner können Halt, Stau, Ausweichweg oder zurückliegende Strecke für einen Hinterhalt nutzen;
6. einzelne Fahrzeuge außerhalb der Formation verlieren Schutz;
7. RED kann Wege hinter oder neben einer Bewegung erneut mit IEDs versehen;
8. Erfolg ist eine sichere, nachvollziehbar freigegebene Route, nicht nur das Erreichen des Zielpunkts.

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

Erkennungswahrscheinlichkeit, Sprengwirkung und technische Neutralisierung werden in separaten Testmissionen validiert.

## 5. RED-Route-Cycle

Quellenbasierter Zyklus des konsolidierten RED Commanders:

```text
OBSERVE_ROUTE
→ LEARN_PATTERN
→ BUILD_OR_REFRESH_CACHE
→ EMPLACE_IED_OR_PREPARE_AMBUSH
→ ATTACK_OR_FORCE_HALT
→ DISPERSE
→ ASSESS_BLUE_REACTION
→ REINFILTRATE_IF_PRESSURE_DROPS
```

### 5.1 Beobachtung

Route-Observation kann virtuell erfolgen. Physische Beobachter werden nur erzeugt, wenn:

- ihre Entdeckung spielerisch relevant ist;
- ein RECCE-/HUMINT-Auftrag sie aufklären kann;
- ihr Verlust oder Rückzug einen CampaignState-Effekt besitzt.

### 5.2 Predictability

`routePredictability` steigt unter anderem bei:

- identischen Abfahrtszeiten;
- wiederholten Haltepunkten;
- unveränderten Marschgeschwindigkeiten;
- stets gleichen Ausweichrouten;
- fehlender Gegenaufklärung.

Höhere Vorhersagbarkeit erhöht RED-Aktionsqualität, nicht automatisch die Zahl der Spawn-Gruppen.

### 5.3 Reinfiltration

Nach einer erfolgreichen Route-Clearance sinkt RED-Einfluss zunächst. Ohne Patrouillen, Hold, lokale Meldungen und erneute Prüfung kann der Sektor wechseln:

```text
CLEARED
→ DEGRADED
→ RED_OBSERVED
→ RED_CACHE_REBUILT
→ UNCLEARED_OR_ATTACK_READY
```

Die technische Benennung der Zwischenzustände darf intern abweichen; die Wirkung muss erhalten bleiben.

## 6. Taktische Erweiterungen

Spätere, nicht zum MVP gehörende Muster:

```text
FEINT_ATTACK
MULTI_DIRECTION_ATTACK
SECONDARY_ATTACK_ON_RESPONDERS
MOTORCYCLE_IED
SVBIED_ATTACK
ROUTE_BOXING
```

`SECONDARY_ATTACK_ON_RESPONDERS` darf nur mit klaren Voraussetzungen und geringer Häufigkeit erzeugt werden. Es darf keine allwissende KI-Reaktion auf jeden BLUE-Responder entstehen.

## 7. MOOSE-First-Routing

Vor eigener Routenberechnung sind insbesondere zu prüfen:

- MOOSE `Core.Astar`;
- `COORDINATE`-Routing- und Straßenfunktionen;
- `PATHLINE` und Zonen;
- `OPSGROUP` / `ARMYGROUP`;
- `OPSTRANSPORT`;
- Wrapper-, Set-, Detection-, Event- und Scheduler-Funktionen.

Vor eigener Route-Clearance-, IED-, Beobachtungs- oder Reinfiltrationslogik ist zusätzlich zu prüfen, welche MOOSE-Funktionen bereits abbilden:

- Detektion und Intel-Level;
- Zonen- und Wegereignisse;
- Aufgaben/FSMs;
- Escort-/Convoy-Verhalten;
- Cargo-/Engineer-Transport;
- dynamische Re-Route und Halt/Resume;
- lokales INTEL-/DETECTION-Lagebild;
- Spawn, Despawn und persistente Zustandsübergabe.

Eigene Logik benötigt das vollständige Ausnahmeverfahren aus Dokument 26.

## 8. DCS-spezifische Regeln

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
- Ein RED-Beobachter oder eine vorbereitete Zelle darf nicht sichtbar direkt neben Spielern gespawnt werden.
- Reinfiltration erfolgt zeitverzögert und aus plausiblen Zuführungsräumen.

## 9. PRT- und Infrastrukturabhängigkeit

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

## 10. Validierung je Segment

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
- [ ] RED-Observation und Pattern-Knowledge geprüft;
- [ ] Dispersal und plausibler Rückzug geprüft;
- [ ] Reinfiltration nach sinkender Hold-Präsenz geprüft;
- [ ] keine unmittelbaren Spawns im Sicht- oder Sensorsbereich der Spieler;
- [ ] CampaignState-/Persistenzübergabe geprüft;
- [ ] DCS-, OMW- und MOOSE-Version dokumentiert;
- [ ] Ergebnisbericht mit Logs und Mission-Hash erstellt.

## 11. Status

Das Datenmodell und die Markerregeln sind geplant. Eine Route, ein Segment, eine Route-Clearance-Sequenz, ein IED-Verfahren oder ein RED-Reinfiltrationszyklus wird erst nach reproduzierbarem DCS-Test als technisch akzeptiert geführt.
