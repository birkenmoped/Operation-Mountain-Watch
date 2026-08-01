---
document_id: OMW-MSR-ROUTE-DESIGN
status: PLANNED
document_class: DESIGN_WORKLIST
owning_policy: OMW-GOV-001
authoritative_for:
  - MSR route segmentation
  - route geometry and routing-point separation
  - infrastructure marker classification
  - historical route baselines for MSR California, MSR Vermont and MSR Oregon
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

#### 2.4.6 Kartografische Arbeitsanker für Shal, Dab und COP Monti

Für die weitere Google-Earth- und DCS-Prüfung sind folgende Gazetteer- und Ortsanker verwendbar:

```text
Asmar              35.033328, 71.358087
Shal locality       35.088560, 71.366070
Dab locality        35.096950, 71.354380
```

Diese Koordinaten bezeichnen Asmar sowie die benannten Siedlungsräume Shal und Dab. Sie sind keine verifizierten Koordinaten des Gipfels `Shal Mountain`, der Talachsen oder eines konkreten Hinterhaltsorts.

Zusätzliche Einordnung:

- offizielle und zeitgenössische Quellen verorten COP Monti unmittelbar bei beziehungsweise in Asmar;
- die Citation setzt Shal Mountain ungefähr sieben Kilometer nördlich von COP Monti an;
- die Ortsanker Shal und Dab liegen in einer dafür plausiblen Distanz nördlich von Asmar;
- der exakte Gipfel, die Achse des Shal Valley, die Achse des Dab Valley und die Position des im Oktober 2011 errichteten ANA-Außenpostens bleiben kartografisch offen;
- DVIDS-Bildunterschriften zu Operation `BOW` verwenden teilweise die Schreibweise `Shaw Valley`. Diese wird nicht ohne weiteren Beleg stillschweigend mit `Shal Valley` gleichgesetzt.

Damit dürfen Shal und Dab als Suchräume und Arbeitsanker verwendet werden. Ein endgültiger `OBS_CAL_SHAL_MOUNTAIN`- oder `INF_CAL_SHAL_VALLEY`-Punkt erfordert weiterhin visuelle Geländeprüfung und möglichst eine zweite georeferenzierte Quelle.

### 2.5 Historisch belegte Routenbaseline: MSR Vermont

`MSR Vermont` ist als reale Koalitions-Main-Supply-Route im Raum Surobi–Tagab–Kapisa belegt. Für die OMW-Dokumentation ist zwischen dem quellenbestätigten Kernkorridor und einer noch nicht abschließend belegten nördlichen Fortsetzung zu unterscheiden.

#### 2.5.1 Quellenbelegte Lage- und Streckenmerkmale

Eine DVIDS-Bildserie vom Januar 2008 verortet `MSR Vermont` eindeutig im Tagab District der Kapisa Province:

- ANA- und Koalitionskräfte sammelten sich an einem Checkpoint an der Route;
- sie patrouillierten von der Straße nach Osten in ein Wadi;
- nach der Patrouille bewegten sie sich westwärts zurück zur MSR;
- eine weitere offizielle DVIDS-Bildunterschrift nennt `Checkpoint 5` entlang der Route; zugehörige Metadaten referenzieren außerdem `Checkpoint 6`.

Die Bildunterschriften belegen damit nicht nur den Namen, sondern auch die lokale Ost-West-Beziehung zwischen Straße und Wadi im Tagab District. Die Checkpoint-Nummern dürfen bis zur Kartenvalidierung jedoch nicht als exakte, dauerhaft gleichbleibende Positionsbezeichnungen behandelt werden.

Französische amtliche Bild- und Filmarchive dokumentieren für den 4. November 2009 die Operation `Road Again`:

- Engineer-/IED-Reconnaissance auf `MSR Vermont`;
- Bezug zum Kora-Pass;
- Operationen bei den Dörfern Maktab und Landakhel;
- Sicherung durch Infanterie während der technischen IED-Suche;
- nach Abschluss der Prüfung wurde die Achse als sicher erklärt und für Konvois freigegeben.

Christophe Lafayes militärhistorische Studie beschreibt darüber hinaus eine offensive Aufklärung der Achse Vermont zwischen der FOB Tagab und dem Naghlu-See am 29. September 2009. Zweck waren die Vorbereitung von Polizeiposten und die Bestimmung künftiger Verkehrswege. Diese Angabe liefert den bislang stärksten Quellenbeleg für die südliche räumliche Ausdehnung des benannten Korridors.

Für den OMW-Missionszeitraum ist der Name weiterhin belegt: Ein DVIDS-Bericht vom April 2011 nennt den Wiederaufbau einer Brücke auf `Main Supply Route Vermont` als gemeinsames Projekt von Kapisa-Regierung und PRT seit Oktober 2010.

#### 2.5.2 Vorläufige OMW-Segmentierung

Der quellenbestätigte Kernkorridor wird zunächst als ein Segment geführt:

```text
MSR_VT_V01  Naghlu Lake / südlicher Surobi-Anschluss → FOB Tagab
```

Die Route setzt sich funktional in die Tagab-/Kapisa-Verkehrsachsen fort. Ob der Name `MSR Vermont` im Missionszeitraum für die gesamte Verbindung bis Nijrab oder nur für definierte Teilabschnitte verwendet wurde, ist noch nicht ausreichend belegt. Eine nördliche Erweiterung darf deshalb erst nach weiterer Quellen- oder Kartenprüfung als separates `MSR_VT_V02` angelegt werden.

#### 2.5.3 Taktische und infrastrukturelle Bedeutung

Die Quellen stützen folgende Routeneigenschaften:

- logistischer Hauptkorridor für Koalitions- und afghanische Kräfte;
- wiederkehrender Bedarf an Engineer- und IED-Aufklärung;
- Nutzung von Checkpoints und geplanten beziehungsweise errichteten Polizeiposten;
- Wadis und seitliche Geländeeinschnitte unmittelbar neben der Straße;
- Kora-Pass als geländebedingter Schlüssel- oder Engstellenraum;
- Brücken als kritische Infrastruktur und Reconstruction-Ziel;
- konkurrierender Bedarf zwischen dauerhafter Routensicherung und Operationen in den umliegenden Tälern.

Vorzusehende Marker- und Arbeitsanker, zunächst ohne endgültige Koordinate:

```text
NODE_NAGHLU_LAKE
NODE_TAGAB_FOB
CHK_VT_KORA_PASS
NODE_VT_MAKTAB
NODE_VT_LANDAKHEL
RCP_VT_ROAD_AGAIN
BRG_VT_KAPISA_RECONSTRUCTION
CHK_VT_CHECKPOINT_5
CHK_VT_CHECKPOINT_6_CANDIDATE
INF_VT_TAGAB_EAST_WADI
```

Aus den Bildunterschriften darf kein punktgenauer IED-Ort abgeleitet werden. `Road Again` belegt eine IED-Suche entlang der Achse, aber keinen dauerhaft wiederverwendbaren Sprengsatzpunkt.

#### 2.5.4 Missionsdesign

Quellennahe Missionsmuster für MSR Vermont sind:

1. Engineer Route Reconnaissance mit Infanteriesicherung;
2. Prüfung von Straßenrand, Halteflächen und Wadi-Zugängen;
3. Konvoi erst nach technischer Freigabe der Achse;
4. Sicherung oder Wiederaufbau einer Brücke;
5. Patrouille von einem Route-Checkpoint in ein seitliches Wadi;
6. Aufbau, Versorgung oder Verteidigung von ANP-Checkpoints;
7. Route-Security-Operation am Kora-Pass;
8. Wechselwirkung zwischen hoher BLUE-Routenpräsenz und RED-Reinfiltration in benachbarte Täler.

#### 2.5.5 Quellenqualität und Provenienz

Primäre beziehungsweise amtliche Quellen:

- [PICRYL/DVIDS – Soldiers from the Afghan national army and coalition](https://picryl.com/media/soldiers-from-the-afghan-national-army-and-coalition-6f0301), DVIDS-Bildbeschreibung vom 19. Januar 2008;
- [DVIDS – Checkpoint](https://www.dvidshub.net/image/75194/checkpoint), offizielle Bildbeschreibung zu Checkpoint 5 auf MSR Vermont vom 11. Januar 2008;
- [ImagesDéfense – Opération Road Again](https://imagesdefense.gouv.fr/fr/operation-road-again.html), amtlicher französischer Bildbestand vom 4. November 2009;
- [ImagesDéfense – Reconnaissance du génie avec le GTIA Kapisa](https://imagesdefense.gouv.fr/fr/reconnaissance-du-genie-avec-le-gtia-kapisa.html), amtlicher französischer Film- und Inhaltsnachweis;
- [DVIDS – PRT welcomes new governor of Kapisa](https://www.dvidshub.net/news/68420/prt-welcomes-new-governor-kapisa), Bericht vom April 2011 mit Brückenprojekt auf MSR Vermont.

Ergänzende historische Synthese:

- Christophe Lafaye, *L’armée française en Afghanistan. Le Génie au combat. 2001–2012*, CNRS Éditions/Ministère de la Défense, 2016.

Die Quellen liefern hohe Sicherheit für Name, Tagab-Lage, südlichen Kernkorridor bis zum Naghlu-See, Engineer-/IED-Bedeutung und Nutzung bis in den OMW-Zeitraum. Sie reichen noch nicht für eine punktgenaue Gesamtlinie bis Nijrab oder für dauerhaft nummerierte Checkpoint-Koordinaten aus.

### 2.6 Historisch belegte Routenbaseline: MSR Oregon

`MSR Oregon` ist für 2008 als Main Supply Route zwischen Kandahar Airfield und Tarin Kowt belegt. Der physische Kandahar–Tarin-Kowt-Korridor blieb auch danach eine wesentliche Logistikverbindung. Ob der Codename `MSR Oregon` im gesamten OMW-Missionszeitraum 2010–2011 unverändert weiterverwendet wurde, ist derzeit nicht belegt.

#### 2.6.1 Quellenbelegter Verlauf und Konvoizweck

Der Bericht der niederländischen Vereniging Officieren Artillerie beschreibt eine tatsächlich durchgeführte Mission des niederländischen Marine Corps Fire Support Team im Jahr 2008:

- Sicherung eines Konvois von dreizehn zivilen Kraftstoff-Lkw;
- Abfahrt von Kandahar Airfield;
- Ziel Tarin Kowt;
- Marsch über `Main Supply Route Oregon`;
- vorausfahrendes Aufklärungs- und Sicherungselement;
- Einbindung des Fire Support Team in dieses Vorauskommando.

Damit ist folgende OMW-Baseline zulässig:

```text
MSR_OR_O01  Kandahar Airfield → Tarin Kowt
```

Diese Segmentierung beschreibt zunächst den vollständigen historischen Korridor. Eine Aufteilung in Teilsegmente darf erst erfolgen, wenn die tatsächlich genutzte Straßenlinie, wichtige Talräume, Distriktgrenzen und belastbare Zwischenknoten kartografisch bestimmt sind.

#### 2.6.2 Gefechtsverlauf als Route-Threat-Vignette

Der Bericht beschreibt für den Konvoi eine mehrstufige Bedrohung:

1. Über ICOM wurde gemeldet, dass in der vorausliegenden Talstrecke ein Hinterhalt vorbereitet werde.
2. Zwei niederländische F-16 führten zunächst eine Show of Force mit Flares durch und kehrten anschließend zur Basis zurück.
3. Beim Einfahren in das Tal geriet das Vorauskommando unter 82-mm-Mörserfeuer.
4. Ein gegnerischer Observation Post und eine Mörserstellung wurden auf einem vorausliegenden Bergrücken erkannt.
5. Die eigene 81-mm-Mörsergruppe bezog Stellung; der gegnerische OP wurde zunächst mit Phosphor markiert.
6. Später standen zwei F/A-18 und zwei Apache aus Tarin Kowt als Luftunterstützung zur Verfügung.
7. Der OP wurde mit einer 500-lb-Bombe bekämpft; Apache und eigene Mörser unterdrückten weitere Kräfte und die gegnerische Mörserstellung.
8. Aufständische näherten sich bis auf etwa 150 Meter, wodurch Danger-Close-Feuerunterstützung und enge Deconfliction erforderlich wurden.
9. Nach mehr als fünf Stunden konnte der Konvoi weiterfahren.
10. Ein beschädigter Kraftstoff-Lkw musste zurückgelassen werden; der zivile Fahrer wurde verwundet und per CASEVAC nach Kandahar Airfield ausgeflogen.

Diese Vignette belegt keinen einzelnen dauerhaft wiederkehrenden Hinterhaltsort. Sie belegt jedoch ein realistisches Bedrohungsmuster für kanalisiertes Gelände entlang des KAF–Tarin-Kowt-Korridors:

- Vorwarnung über lokale beziehungsweise insurgente Kommunikation;
- vorbereiteter Hinterhalt in einer Talstrecke;
- Beobachter und indirektes Feuer vom dominierenden Bergrücken;
- Annäherung von Kämpfern an gebundene BLUE-Kräfte;
- gleichzeitig notwendige Konvoibewegung, Luftnahunterstützung, Mörserfeuer und Deconfliction;
- besondere Verwundbarkeit ziviler Kraftstofffahrzeuge und ihrer Fahrer.

#### 2.6.3 Korridor-Kontinuität und Namensgrenze

Weitere Quellen bestätigen die dauerhafte Bedeutung der Verbindung zwischen Kandahar und Tarin Kowt:

- 2004 begann der Ausbau einer rund 130 Kilometer langen Kandahar–Tarin-Kowt-Straße mit dem Ziel, die Fahrzeit von ungefähr zwölf auf drei Stunden zu reduzieren;
- ein U.S.-Army-Sustainment-Bericht von Januar 2011 dokumentiert gemeinsame US-/niederländische Logistikbewegungen zwischen Tarin Kowt und Kandahar;
- 2011/2012 wurde ein Teil des Korridors unter der Bezeichnung `Route Bear` weiter ausgebaut; beschrieben werden zuvor unbefestigte Abschnitte, steile Anstiege, enge Kurven, weiche Schultern, Culverts und ein Low-Water Crossing.

Diese Belege bestätigen die physische und logistische Kontinuität des Korridors, aber nicht automatisch die Identität der Namen:

```text
MSR Oregon (2008 belegt) ≠ automatisch Route Bear (2011/2012 belegt)
```

`Route Bear` kann derselbe übergeordnete Stadt-zu-Stadt-Korridor oder ein Teilprojekt darin sein. Ohne direkte Namenskonkordanz darf die Bezeichnung nicht rückwirkend gleichgesetzt werden.

#### 2.6.4 OMW-Arbeitsstatus

```text
historicalNameConfidence2008: HIGH
corridorEndpointsConfidence: HIGH
scenarioPeriodCorridorUse: HIGH
scenarioPeriodNameContinuity: UNCONFIRMED
exactDcsGeometry: UNVALIDATED
exactAmbushLocation: UNKNOWN
```

Vorzusehende Marker- und Arbeitsklassen:

```text
NODE_KANDAHAR_AIRFIELD
NODE_TARIN_KOWT
GATE_KAF_MSR_OR
GATE_TK_MSR_OR
AMB_OR_VALLEY_SECTOR_CANDIDATE
OBS_OR_RIDGE_OP_CANDIDATE
IDF_OR_MORTAR_POSITION_CANDIDATE
REC_OR_DISABLED_FUEL_TRUCK
CASEVAC_OR_KAF
```

Die drei mit `CANDIDATE` bezeichneten taktischen Marker dürfen erst nach kartografischer oder SIGACT-basierter Lokalisierung mit Koordinaten versehen werden.

#### 2.6.5 Missionsdesign

Quellennahe Missionsmuster für den KAF–Tarin-Kowt-Korridor sind:

1. Eskorte eines zivilen Kraftstoffkonvois;
2. vorausfahrende Recon-/Route-Security-Gruppe mit eingebettetem FST/JTAC;
3. ICOM-/HUMINT-Warnung mit unsicherer Verlässlichkeit;
4. Show of Force als nichtletale Vorstufe ohne garantierte Abschreckungswirkung;
5. komplexer Hinterhalt mit OP, indirektem Feuer und anschließendem Nahkampf;
6. zeitversetzte Verfügbarkeit unterschiedlicher Luftunterstützung;
7. Deconfliction zwischen CAS, Attack Aviation und eigenen Mörsern;
8. Recovery-Entscheidung bei undichtem oder bewegungsunfähigem Kraftstofffahrzeug;
9. zivile Verwundete und CASEVAC nach KAF;
10. Missionsziel als sichere Passage des Konvois, nicht als vollständige Vernichtung aller Angreifer.

#### 2.6.6 Quellenqualität und Provenienz

Primäre Vignette:

- [Vereniging Officieren Artillerie – AFGHANISTAN 2008 Main Supply Route (MSR) Oregon](https://voaweb.nl/afghanistan-2008-main-supply-route-msr-oregon/), rückblickende Erstpersonenschilderung eines tatsächlich durchgeführten Einsatzes, veröffentlicht 2020.

Ergänzende amtliche Korridorquellen:

- [U.S. Department of State – Groundbreaking of the Kandahar to Tarin Kowt Road](https://2001-2009.state.gov/r/pa/ei/pix/b/sa/af/36146.htm), 2004;
- [U.S. Army – The first 100 days: a story of sustainment](https://www.army.mil/article/50711/the_first_100_daysa_story_of_sustainment), Januar 2011;
- [U.S. Army Corps of Engineers – Route Bear highway](https://www.usace.army.mil/Media/News/Article/475345/usace-completes-major-section-of-route-bear-highway/), Februar 2012.

Die VOA-Schilderung ist detailreich und stammt aus Teilnehmerperspektive, wurde jedoch zwölf Jahre nach dem Ereignis veröffentlicht und nennt weder das genaue Datum noch die konkrete Talposition. Sie ist stark für Auftrag, Endpunkte, Fahrzeugtyp und Gefechtsmuster, aber nicht ausreichend für eine punktgenaue Linien- oder Incident-Georeferenzierung. Die amtlichen Zusatzquellen bestätigen den Korridor, nicht die fortdauernde Verwendung des Namens `MSR Oregon`.

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
