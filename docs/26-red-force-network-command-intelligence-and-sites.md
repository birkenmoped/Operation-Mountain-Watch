# 26 – Rotes Personalnetz, begrenzte Führung, HUMINT und dynamische Standorte

## Zweck und Status

Dieses Dokument konsolidiert die projektweiten Absprachen für das spätere rote Führungs-, Personal-, Bewegungs- und Standortsystem.

Es unterscheidet:

- akzeptierte Architekturentscheidungen;
- vorläufige Testparameter;
- technisch noch zu validierende DCS- und MOOSE-Annahmen;
- Abgrenzungen zu den bestehenden TM02-Tests.

TM02V bleibt ein technischer Nachweis für dynamische Personalkontingente, unabhängige Proxies, Routen, Pack/Unpack und verlustfreie Bilanzierung. Der dort verwendete feste Sechs-Knoten-Baum ist kein Produktionsdatenmodell.

## Zugehörige Entscheidungen

- [ADR 0013 – Rote Kräfte als kostenbewertetes Netzwerk mit begrenzter und verzögerter Führung modellieren](adr/0013-use-costed-red-network-with-bounded-delayed-command.md)
- [ADR 0014 – Designerfreigegebene Landschaftsstandorte mit dynamischer roter Belegung verwenden](adr/0014-use-designer-approved-scenery-sites-with-dynamic-red-occupation.md)

## Historische und spielerische Einordnung

Eine afghanistanweit einheitliche Taliban-Gruppengröße ist nicht belegt. Dokumentierte `delgai` lagen je nach Region und Zeitraum ungefähr zwischen drei und zwanzig Kämpfern. Für Nad Ali wurden häufig sieben bis elf Kämpfer je `delgai` beschrieben; andere Untersuchungen nennen nominell zehn, tatsächlich etwa fünf bis zwanzig.

Für Operation Mountain Watch wird daraus keine historische Sollgliederung abgeleitet. Die Missionsabstraktion lautet:

```text
mobile Lauf-/Verstärkungsgruppe: höchstens 6 Mann
Angriffsverband:                 2 unabhängige Teams zu je 6 Mann
Gesamtstärke Standardangriff:   12 Mann
```

Die Sechsergrenze bildet ein kleines, bewegliches Element ab. Ein Angriffsverband bleibt technisch und taktisch aus zwei getrennten Teams zusammengesetzt.

Quellen:

- [Afghanistan Analysts Network – Living with the Taleban in Nad Ali](https://www.afghanistan-analysts.org/en/reports/war-and-peace/living-with-the-taleban-2-local-experiences-in-nad-ali-district-helmand-province/)
- [Human Rights Watch – No Forgiveness for People Like You](https://www.hrw.org/report/2021/11/30/no-forgiveness-people-you/executions-and-enforced-disappearances-afghanistan)
- [Small Arms Survey – Taliban Arms Management Practices](https://www.smallarmssurvey.org/taliban-arms-management-practices/policies-and-practices)

## Grundentscheidung: Netzwerk statt Produktionsbaum

Das Produktionssystem verwendet einen gewichteten Graphen.

```text
Knoten = HQ, Unter-HQ, Station, Sammelraum oder zeitweiser Standort
Kanten = geprüfte Marsch- oder Transportverbindungen
```

Ein Baum ist weiterhin als einfacher Graph ohne Quer- und Rückverbindungen zulässig. Der Controller darf jedoch nicht voraussetzen, dass jeder Knoten genau einen Elternknoten oder nur einen Versorgungsweg besitzt.

Das Netzwerk erlaubt:

- mehrere Personalquellen;
- Versorgung über den zeit- oder kostenmäßig günstigsten erreichbaren Knoten;
- lokale Reservebildung;
- Nachersatz aus HQ, Unter-HQ oder benachbarten Stationen;
- temporäre Unterbesetzung einer Quelle;
- Angriffe, Patrouillen, Rückzüge und Verlegungen;
- dauerhafte Ausfälle und neue Ersatzstandorte.

## Getrennte Strukturen

Kommando, Bewegung und Personal dürfen nicht in dieselbe Hierarchie gepresst werden.

### Kommandostruktur

```text
Haupt-HQ
└── optionale Unter-HQs
    └── regionale oder lokale Zuständigkeiten
```

Sie bestimmt Meldewege, Entscheidungsrechte und Budgets.

### Bewegungsnetz

Das Bewegungsnetz enthält gerichtete oder ungerichtete Kanten mit mindestens:

```lua
{
  linkId = "...",
  sourceSiteId = "...",
  targetSiteId = "...",
  distanceMeters = 0,
  expectedTravelSeconds = 0,
  movementMode = "FOOT",
  routeRisk = 0,
  enabled = true,
}
```

### Personalnetz

Jeder geeignete besetzte Knoten kann Quelle oder Ziel einer Bewegung sein. Das Personal ist nicht dauerhaft Eigentum eines Knotens, sondern befindet sich dort aktuell und kann für einen Auftrag gebunden werden.

## Knotenbestand und Kapazität

Eine feste Regel „jeder Knoten muss immer mit zehn Mann besetzt sein“ wird verworfen. Sie würde operative Kräfte dauerhaft binden und Angriffe verhindern.

Jeder Knoten erhält mindestens:

```lua
{
  guardFloor = 2,
  readinessTarget = 6,
  hardCapacity = 12,

  currentPersonnel = 0,
  reservedInbound = 0,
  reservedOutbound = 0,
}
```

Bedeutung:

- `guardFloor`: reguläre untere Sicherheitsgrenze;
- `readinessTarget`: gewünschter normaler Bereitschaftsbestand;
- `hardCapacity`: maximal haltbarer Bestand am Standort;
- `reservedInbound`: bereits verbindlich ankommendes Personal;
- `reservedOutbound`: bereits für Abmarsch oder Auftrag gebundenes Personal.

### Vorläufige Standardklassen

| Klasse | Grundwache | Bereitschaftsziel | Harte Kapazität |
|---|---:|---:|---:|
| `STATION` | 2 | 6 | 12 |
| `REGIONAL_HUB` / `SUB_HQ` | 4 | 12 | 24 |

Diese Werte sind erste Missions- und Testparameter, keine historische Taliban-Sollgliederung. Ein Hub repräsentiert gegebenenfalls mehrere Gebäude, Gehöfte oder einen räumlich verteilten Komplex.

### Temporäre Unterbesetzung

Ein höher priorisierter Auftrag darf einen Knoten unter sein Bereitschaftsziel und bei ausdrücklicher Risikofreigabe auch unter seinen normalen `guardFloor` bringen.

```lua
{
  acceptedTemporaryFloor = 0,
  reason = "ATTACK_COMMITMENT",
  validUntil = 0,
}
```

Geplante und ungeplante Defizite bleiben getrennt:

```text
PLANNED_DEFICIT   bewusste Abgabe für Angriff, Verlegung oder Nachbarschaftshilfe
UNPLANNED_DEFICIT Verlust, Vernichtung, Ausfall oder unerwartete Abwesenheit
```

Ungeplante Defizite erhalten normalerweise die höhere Wiederauffüllpriorität.

## Mobile Teams und Angriffsverbände

### Lauf- und Verstärkungsgruppen

```text
zulässige Stärke: 1 bis 6 Mann
bevorzugt: größtes sinnvoll einsetzbares Team innerhalb der Kosten- und Routenregeln
```

Die maximale Teamgröße ist eine Obergrenze. Sie darf nicht durch unnötige Rundreisen erzwungen werden, wenn mehrere direkte kleinere Bewegungen die Aufgabe schneller und risikoärmer erfüllen.

Retention entlang einer direkten Route bleibt erlaubt:

```text
Quelle → Station A → Station B
6 Mann starten
2 bleiben in A
4 laufen nach B weiter
```

Ein Team darf nicht gleichzeitig verzweigen. Mehrere Zweige werden grundsätzlich durch getrennte Teams bedient. Rundreisen über mehrere Äste sind eine spätere optionale Optimierung, kein Basiskonzept.

### Angriffsverband

```lua
{
  taskType = "ATTACK",
  teamCount = 2,
  teamStrength = 6,
  totalStrength = 12,
}
```

Beide Teams besitzen:

- eigene Identität;
- eigenen Proxy und eigene physische Repräsentation;
- eigene Verluste und Position;
- gegebenenfalls unterschiedliche Quellknoten;
- einen gemeinsamen Auftrag und optionalen Sammelpunkt.

Ein Angriff darf bei verspätetem oder ausgefallenem Team abgebrochen, verschoben oder ausdrücklich auf einen kleineren Auftrag reduziert werden.

## Kostenbewertete Quellen- und Routenwahl

Der rote Kommandeur wählt nicht automatisch den geometrisch nächsten Quellknoten.

Mindestens zu bewerten sind:

```text
erwartete Reisezeit
Entfernung
Routenrisiko
Schwächung der Quelle
Zeit bis zur Wiederauffüllung der Quelle
Alter und Zuverlässigkeit der Feindmeldung
bereits gebundene Teams
Routen- oder Knotenüberlastung
```

Beispielhafte Kostenfunktion:

```lua
cost =
    travelTimeCost
  + distanceCost
  + routeRiskCost
  + sourceDepletionCost
  + sourceReplenishmentDelayCost
  + intelUncertaintyCost
  + congestionCost
```

Auftragsnutzen und Kosten werden getrennt betrachtet. Kritische Aufgaben dürfen teurer sein als Routineauffüllung.

Der erste Produktionsansatz ist ein ereignisgesteuerter Greedy-Dispatcher:

1. wichtigste bekannte Aufgabe wählen;
2. begrenzte Zahl plausibler Quellen bestimmen;
3. vorhandene oder gecachte Routen bewerten;
4. günstigste zulässige Quelle wählen;
5. größtes sinnvolles Team bis Stärke sechs bilden;
6. Quelle, Ziel und Route atomar reservieren;
7. Auftrag erteilen;
8. nach relevanter Zustandsänderung neu bewerten.

Ein globaler mathematischer Optimierer ist nicht erforderlich.

## Führungs- und Informationsmodell

### Technische Wahrheit und Kommandowissen

```text
Simulationscontroller kennt den tatsächlichen Zustand.
Roter Kommandeur kennt nur eingetroffene Meldungen.
```

Beispiel:

```lua
node.actualPersonnel = 3
node.commandKnownPersonnel = 6
node.lastConfirmedCampaignTime = 7200
```

Die technische Ebene verhindert trotzdem unzulässige Duplikation oder Überfüllung. Fehlentscheidungen aufgrund veralteter Meldungen bleiben möglich.

### Informationsquellen

Der rote Kommandeur besitzt:

- gute lokale Kenntnis eigener Kräfte;
- verzögerte Meldungen von Nachbarknoten und Unter-HQs;
- lokale HUMINT über Dörfer, Straßen, wiederkehrende Patrouillen und offene Blue-Bewegungen;
- punktuelle Informanten in oder nahe Einrichtungen;
- nur begrenzte technische Aufklärung;
- keine allwissende Kenntnis exakter Blue-Positionen, Aufträge, Munition oder Sensorbilder.

Historische Untersuchungen beschreiben wirksame lokale Informantennetze und frühe Warnungen vor ISAF-Bewegungen, zugleich aber begrenzte zentrale Auswertung und schwache Fähigkeit gegen verschlüsselte westliche Funkkommunikation.

Quelle:

- [Combating Terrorism Center – The Taliban’s Conduct of Intelligence and Counterintelligence](https://ctc.westpoint.edu/the-talibans-conduct-of-intelligence-and-counterintelligence/)

### Meldungsqualität

```text
CONFIRMED direkt beobachtet, relativ genau, kurze Gültigkeit
REPORTED  glaubwürdige lokale Meldung, ungefähre Position
RUMORED   unbestätigte Einzelquelle
STALE     veraltete Meldung
```

Blue-Kontakte werden als Gebiet, Größenband, Zeitstempel, Zuverlässigkeit und Ablaufzeit gespeichert, nicht als dauerhaft exakt verfolgte DCS-Einheit.

### Meldungsverzögerung

Ereignisse werden nicht sofort zum Kommandowissen.

```lua
{
  eventTime = 0,
  deliveryTime = 0,
  confidence = 0.0,
}
```

Die Verzögerung kann aus Entfernung, Kommandostufen, Kommunikationsqualität, Isolation und einem begrenzten Zufallsanteil bestehen.

## Begrenzte Entscheidungsleistung

Die Bewegungsüberwachung und der strategische Planer bleiben getrennt.

```text
Bewegungscontroller: häufig und billig, nur aktive Gruppen
Meldungssystem:      ereignisgesteuert
lokaler Führer:      relativ kurze Zyklen, kleiner Wirkraum
Unter-HQ:            mittlere Zyklen, regionaler Wirkraum
Haupt-HQ:            langsame Zyklen, gesamtes Netz
```

Vorläufige Testwerte:

```lua
commander = {
  localCycleSeconds = 45,
  subHqCycleSeconds = 120,
  mainHqCycleSeconds = 240,

  localOrdersPerCycle = 1,
  subHqOrdersPerCycle = 2,
  mainHqOrdersPerCycle = 2,
}
```

Zusätzliche technische Budgets begrenzen Kandidaten- und Routensuchen:

```lua
{
  maxTasksEvaluatedPerCycle = 8,
  maxSourcesPerTask = 4,
  maxRouteSearchesPerCycle = 12,
}
```

Entscheidungstokens dürfen später unterschiedliche Auftragskomplexitäten abbilden. Sie sind optional und erst nach einem einfachen Auftragsbudget einzuführen.

### Stabilität

Mindestens erforderlich:

```text
Auftragsbindungszeit
Quellknoten-Cooldown
Mindeständerung vor Neuplanung
Altersbonus für lange wartende Aufgaben
```

Dadurch werden Pendelbewegungen und hektische Reaktionen auf einzelne Verluste vermieden.

## Hybridmodell für Missionsdesigner und Kommandeur

Der Missionsdesigner bestimmt den glaubwürdigen und spielbaren Rahmen. Der Kommandeur wählt innerhalb dieses Rahmens dynamisch.

### Designer setzt

- feste Haupt-HQs;
- optionale Unter-HQs;
- geprüfte Landschaftsstandorte;
- Kandidatengebiete für spätere automatische Auswahl;
- zulässige Routen oder Bewegungskorridore;
- Schlüsselstellungen, die narrativ zwingend sind.

### Kommandeur entscheidet

- welcher freie Standort besetzt wird;
- welche Rolle er aktuell erhält;
- wann er verstärkt, geschwächt oder aufgegeben wird;
- welcher Ersatzstandort nach Verlust gewählt wird;
- welche Quelle und Route einen Auftrag bedienen.

## Mission-Editor-Namenskonvention

Der Präfix bestimmt den Objekttyp. Der Rest des Namens ist frei und muss nicht global durchnummeriert werden.

```text
OMW_RED_HQ_<freier Name>
OMW_RED_SUBHQ_<freier Name>
OMW_RED_SITE_<freier Name>
OMW_RED_NODEAREA_<freier Name>
OMW_RED_ROUTE_<freier Name>
```

DCS-seitig automatisch ergänzte Namenssuffixe bleiben zulässig. Der vollständige tatsächliche Name ist der eindeutige Laufzeitschlüssel.

### Bedeutung

- `HQ`: festes strategisches Hauptquartier;
- `SUBHQ`: optionaler regionaler Führungs- und Reserveknoten;
- `SITE`: konkreter designerfreigegebener Standortanker;
- `NODEAREA`: Gebiet, in dem später automatisch Standorte gesucht werden dürfen;
- `ROUTE`: designergeprüfte Verbindung oder Wegpunktkette.

Die Topologie wird nicht über fortlaufende Nummern oder Parent-IDs im Namen codiert.

## Landschaftsgebäude als Standortanker

Afghanistan-Szeneriegebäude dürfen als glaubwürdige Standortanker verwendet werden. Der Knoten besteht aus:

```text
Landschaftsgebäude oder Compound als Anker
+ Aufenthalts- und Materialisierungsbereich
+ aktuell anwesendes Personal
+ logischer Knoten- und Standortzustand
```

MOOSE kann Landschaftsobjekte über zugewiesene Zonen und räumliche Scans finden sowie Koordinate, Eigenschaften und Lebenszustand abfragen. Gleichzeitig weisen die MOOSE-Dokumente darauf hin, dass manche Landschaftsobjekte unbrauchbare Lebenswerte liefern und Landschaftsobjekte nicht per Skript zerstört werden sollen.

Quelle:

- [MOOSE SCENERY wrapper](https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Wrapper.Scenery.html)

### Standort und Knoten getrennt halten

```lua
site = {
  siteId = "...",
  anchorCoordinate = nil,
  anchorSceneryId = nil,
  status = "AVAILABLE",
  capacityClass = "STATION",
}

node = {
  nodeId = "...",
  siteId = "...",
  role = "STATION",
  status = "ACTIVE",
  currentPersonnel = 0,
}
```

Der Standort ist der physische Ort. Der Knoten ist die aktuell dort betriebene rote Einrichtung.

### Auswahlstrategie

Erste produktive Stufe:

```text
Designer markiert geeignete Landschaftsgebäude als SITE.
Kommandeur entscheidet nur über deren Belegung.
```

Spätere optionale Stufe:

```text
Designer setzt NODEAREA.
System scannt das Gebiet nach Kandidatengebäuden.
Kommandeur bewertet den gefilterten Kandidatenpool.
```

Eine vollständig freie globale Gebäudesuche ist nicht vorgesehen.

## Abstände und Reisezeit

Primäre Größe ist die erwartete Reisezeit über einen geprüften Link, nicht die Luftlinie.

Vorläufige Fußmarschwerte:

```text
Mindestabstand:          etwa 0,75 bis 1,0 km
bevorzugter Abstand:     etwa 1,5 bis 3,5 km
regulärer Höchstabstand: etwa 5 km
```

Vorläufige motorisierte Werte:

```text
Mindestabstand:          etwa 2 km
bevorzugter Abstand:     etwa 5 bis 12 km
regulärer Höchstabstand: etwa 15 bis 20 km
```

Bevorzugte Reisezeit zwischen normalen Stationen:

```text
ungefähr 15 bis 40 Minuten
```

Diese Werte sind Kandidaten für praktische DCS-Tests. Gelände, Straßennetz, Steigung, Deckung und tatsächliches DCS-Pathfinding haben Vorrang.

## Zerstörung, Neutralisierung und Ersatzstandorte

Blau muss aufgeklärte rote Knoten dauerhaft ausschalten können.

### Garnison neutralisiert

```text
Gebäude steht noch.
Garnison wurde vernichtet oder vertrieben.
```

Möglicher Zustand:

```text
NODE_NEUTRALIZED
SITE_COMPROMISED
```

Der Standort bleibt physisch vorhanden, wird aber wegen bekannter Blue-Aufklärung stark abgewertet oder zeitweise gesperrt.

### Standort zerstört

```text
Ankergebäude oder definierter Compound gilt als zerstört.
```

Zustand:

```text
NODE_DESTROYED
SITE_DESTROYED
```

Ein bestätigter `SITE_DESTROYED`-Zustand ist ein dauerhafter Latch für die laufende Kampagne und darf nicht automatisch zurückgenommen werden.

Die Erkennung kombiniert soweit verfügbar:

- DCS-Todesereignis;
- periodische Objektprüfung;
- Ankerkoordinate und Objekttyp;
- Verlust der Garnison;
- missionsinternen Destroyed-Latch.

### Ersatzstandort

Rot darf nicht denselben zerstörten Standort reaktivieren. Der Kommandeur kann später einen anderen verfügbaren Standort mit neuer Identität besetzen.

```text
SELECTED
→ OCCUPYING
→ ESTABLISHING
→ ACTIVE
```

Vorläufige Regeln:

```text
Mindestabstand zum zerstörten Standort: 1 bis 2 km
regionale Sperrzeit:                    10 bis 30 Minuten
Aufbauzeit neuer Standort:              5 bis 15 Minuten
```

Diese Werte sind Testparameter und müssen spielerisch kalibriert werden.

## Blue-Aufklärung und Ziellegitimität

Ein ziviles Landschaftsgebäude ist nicht allein deshalb ein rotes Ziel, weil es als Kandidatenstandort existiert.

Aufklärungshinweise entstehen durch Nutzung:

- sichtbare bewaffnete Personen;
- wiederkehrende Laufgruppen;
- Fahrzeuge oder Motorräder;
- Beobachtungsposten;
- Versorgungsvorgänge;
- Funk-, HUMINT- oder SIGINT-Meldungen;
- wiederkehrende Aktivität am selben Ort.

Blau muss die rote Nutzung erkennen oder bestätigt gemeldet bekommen. Der Standort kann danach als Ziel klassifiziert werden.

## Performancegrundsätze

```text
kein permanenter globaler Optimierer
keine sofortige HQ-Reaktion auf jeden Verlust
nur aktive Bewegungen häufig prüfen
Meldungen ereignisgesteuert zustellen
nur veränderte Knoten als dirty markieren
Routen und Grundkosten cachen
pro Zyklus Kandidaten und Aufträge begrenzen
```

Die begrenzte Reaktionsgeschwindigkeit ist zugleich Performancegrenze und glaubwürdige Führungsbeschränkung.

## Testfolgen

### TM02V

TM02V bleibt zuständig für:

- dynamische Gruppengrößen;
- unabhängige Proxyrepräsentationen;
- Pack/Unpack;
- Retention und Materialisierung;
- Verluste und Personalbilanz;
- mehrere gleichzeitig aktive Gruppen.

Die Version-6-Konfiguration mit maximal sechs Mann je Packet bleibt ein isolierter technischer Gruppengrößentest. Eine feste Produktionsregel „jeder Knoten wird exakt mit 6 + 4 auf zehn aufgefüllt“ ist verworfen.

### Nächste geplante Testfamilie

Die nachfolgende Netzstufe muss separat prüfen:

1. Präfixbasierte Registry ohne globale Nummerierung;
2. Graph aus designerdefinierten Sites und Routes;
3. mehrere mögliche Personalquellen;
4. Kostenwahl nach Zeit, Entfernung und Quellschwächung;
5. begrenzte Kommandeurszyklen und Auftragsbudgets;
6. verzögerte, unvollständige Lagebilder;
7. Station `2 / 6 / 12` und Hub `4 / 12 / 24`;
8. Angriffsauftrag aus zwei unabhängigen Sechserteams;
9. geplante Unterbesetzung und spätere Wiederauffüllung;
10. dauerhafte Zerstörung eines Site-Ankers;
11. Auswahl und Aufbau eines neuen Ersatzstandorts.

Der geplante Abnahmeentwurf liegt unter:

```text
mission/tests/tm02-red-relay/expected/tm02w-red-network-commander-acceptance.md
```

## Offene technische Validierungen

- Welche Afghanistan-Landschaftsgebäude liefern stabile Identität und Koordinate?
- Welche liefern zuverlässige DCS-Todesereignisse oder Lebenswerte?
- Wie robust ist die Zuordnung per Mission-Editor-Scenery-Zone nach Kartenupdates?
- Wo können Infanteriegruppen plausibel materialisiert werden, ohne in Gebäudegeometrie zu spawnen?
- Welche Fuß- und Fahrzeugrouten funktionieren in DCS tatsächlich?
- Wie viele aktive Gruppen und Kandidatensuchen bleiben auf dem Zielserver performant?
- Welche Melde- und Entscheidungsintervalle erzeugen glaubwürdiges, aber nicht passives Verhalten?

## Verbindlicher Architekturgrundsatz

```text
Der Missionsdesigner definiert den glaubwürdigen Möglichkeitsraum.
Der rote Kommandeur entscheidet innerhalb dieses Raumes begrenzt und verzögert.

Personal ist beweglich und nicht dauerhaft an einen Knoten gebunden.
Mobile Teams sind höchstens sechs Mann stark.
Ein Standardangriff besteht aus zwei unabhängigen Sechserteams.

Der technische Controller kennt die Wahrheit.
Der Kommandeur kennt nur gemeldete, gealterte und unsichere Informationen.

Zerstörte Standorte bleiben zerstört.
Rot darf nur an einem neuen Standort einen neuen Knoten aufbauen.
```