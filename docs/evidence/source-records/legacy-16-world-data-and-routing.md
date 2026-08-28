# 16 – Kartendaten, Orte und Routenermittlung

## Ziel

Die Kampagne benötigt ein belastbares Modell für Orte, Verkehrswege und wichtige Infrastruktur. DCS und MOOSE liefern dafür technische Geometriedaten, aber keine vollständige semantische Datenbank aller Städte, Dörfer, Pässe, Stromleitungen und taktisch relevanten Punkte.

Deshalb kombiniert das Projekt:

- native MOOSE- und DCS-Terrainfunktionen;
- ein eigenes semantisches Ortsregister;
- vorberechnete und validierte Routen;
- optional eine Discovery-Testmission zur Erzeugung von Kandidaten;
- manuelle Freigabe aller spielrelevanten Daten.

## Was MOOSE direkt bereitstellt

### Airbases

MOOSE kennt die Airbases der aktuellen Karte und stellt kartenspezifische Konstanten bereit. Airbases können direkt gesucht, klassifiziert und als strategische Knoten verwendet werden.

### Straßen

`COORDINATE:GetClosestPointToRoad(false)` liefert den nächstgelegenen Straßenpunkt zu einer Koordinate.

`COORDINATE:GetPathOnRoad(destination, includeEndpoints, false)` liefert eine Folge von Koordinaten entlang des DCS-Straßennetzes zwischen zwei vorgegebenen Endpunkten.

### Schienen

Dieselben Methoden unterstützen mit dem Parameter `Railroad=true` das vom Terrain bereitgestellte Schienennetz:

```lua
local nearestRail = coordinate:GetClosestPointToRoad(true)
local path, length, valid = start:GetPathOnRoad(destination, true, true)
```

Die Verfügbarkeit und Vollständigkeit von Schienen ist kartenabhängig. Ein berechneter Schienenpfad bedeutet nicht automatisch, dass normale Bodenfahrzeuge dort sinnvoll oder zulässig bewegt werden können.

### Scenery-Objekte

MOOSE kann Scenery-Objekte innerhalb definierter Zonen scannen und als `SCENERY` beziehungsweise `SET_SCENERY` kapseln.

Scenery wird ausdrücklich nicht vollständig und automatisch in der MOOSE-Datenbank registriert, weil eine Karte zu viele Objekte enthält. Eine Zone oder ein Zonenset muss zuerst festlegen, welcher Bereich gescannt wird.

## Was MOOSE nicht als fertige Datenbank bereitstellt

MOOSE liefert standardmäßig keine vollständige, zuverlässig benannte Liste aller:

- Städte
- Dörfer
- Stadtteile
- Pässe
- Täler
- Kreuzungen
- Brücken
- Stromleitungen
- Transformatoren
- Kraftwerke
- taktisch geeigneten Landezonen
- Hinterhaltpositionen

F10-Kartenbeschriftungen sind nicht automatisch gleichbedeutend mit aus der Mission-Scripting-Umgebung abrufbaren semantischen Ortsobjekten.

Ein Scenery-Scan findet physische Kartenobjekte. Er liefert nicht automatisch die Aussage, dass ein Objektverbund das Dorf X, eine bestimmte Stromleitung oder einen militärisch relevanten Knoten darstellt.

## Verbindliches Ortsmodell

Jeder spielrelevante Ort erhält einen Eintrag in unserem eigenen Register.

```lua
Locations = {
  LOC_JALALABAD_FENTY = {
    displayName = "Jalalabad / FOB Fenty",
    type = "REGIONAL_BASE",
    sectorId = "SECTOR_NANGARHAR_CENTRAL",
    coordinateSource = "AIRBASE",
    airbaseName = AIRBASE.Afghanistan.Jalalabad,
  },

  LOC_VILLAGE_001 = {
    displayName = "Village 001",
    type = "VILLAGE",
    sectorId = "SECTOR_NANGARHAR_EAST",
    coordinateSource = "MISSION_ZONE",
    zoneName = "ZONE_LOC_VILLAGE_001",
    roadAccess = true,
    helicopterAccess = true,
  },
}
```

Zulässige Ortstypen umfassen mindestens:

- `AIRBASE`
- `REGIONAL_BASE`
- `FOB`
- `COP`
- `CHECKPOINT`
- `CITY`
- `TOWN`
- `VILLAGE`
- `VALLEY`
- `PASS`
- `ROAD_JUNCTION`
- `BRIDGE`
- `LANDING_ZONE`
- `DROP_ZONE`
- `CAMP_SLOT`
- `ASSEMBLY_AREA`
- `WITHDRAWAL_AREA`

## Erfassungswege

### 1. Native Airbase-Daten

Airbases und Heliports werden über MOOSE referenziert und durch Missionstests ergänzt.

### 2. Mission-Editor-Zonen

FOBs, Dörfer, Pässe, Checkpoints, Hinterhaltbereiche, Landezonen und andere semantische Orte werden bevorzugt durch eindeutig benannte Mission-Editor-Zonen definiert.

### 3. Straßen- und Schienenpfade

Zwischen bekannten Ortsknoten werden Pfade mit `GetPathOnRoad()` erzeugt. Die resultierende Polylinie wird anschließend validiert und als Kampagnendatensatz gespeichert.

### 4. Discovery-Testmission

Eine separate Testmission kann Kandidaten automatisch ermitteln. Sie ist ein Entwicklungswerkzeug, kein dauerhafter Bestandteil der Produktionsmission.

### 5. Historische und externe Referenzen

Reale Ortsnamen und historische Standorte können zur Benennung und Einordnung verwendet werden. Ihre DCS-Position wird dennoch gegen die tatsächlich dargestellte Karte geprüft.

## Automatische Siedlungskandidaten

Eine Discovery-Testmission kann innerhalb eines begrenzten Sektors ein Raster abarbeiten:

1. Sektor in Suchzellen aufteilen.
2. Pro Zelle Scenery-Objekte scannen.
3. Objektanzahl und räumliche Dichte messen.
4. Benachbarte Zellen mit hoher Dichte clustern.
5. Clusterzentrum bestimmen.
6. Zentrum auf den nächsten Straßenpunkt projizieren.
7. Kandidat mit Koordinate, Radius und Dichtewert exportieren.
8. Kandidat im Mission Editor manuell prüfen und benennen.

Dies erkennt potenzielle Siedlungsflächen, aber keine zuverlässigen Ortsnamen. Ein dichter Gebäudeverbund kann außerdem ein Industriegebiet, eine Basis oder eine andere Struktur sein.

## Straßenrouting

### Erzeugung

Für jede Route werden mindestens Start- und Zielknoten benötigt. MOOSE kann daraus einen Pfad entlang des Terrain-Straßennetzes berechnen.

```lua
local start = Locations.LOC_JALALABAD_FENTY.coordinate
local destination = Locations.LOC_FOB_CONNOLLY.coordinate
local path, length, valid = start:GetPathOnRoad(destination, true, false)
```

### Grenzen

Ein von DCS gelieferter Pfad ist nur ein geometrischer Routenvorschlag. Er garantiert nicht:

- dass jeder Fahrzeugtyp jede Kurve bewältigt;
- dass Brücken und Engstellen fehlerfrei funktionieren;
- dass die AI nicht stecken bleibt;
- dass die Route militärisch plausibel ist;
- dass Materialisierung an jedem Punkt sicher ist;
- dass eine alternative Route wirklich unabhängig ist.

Jede produktiv verwendete Route wird deshalb gefahren und geprüft.

### Fehlende Pfade

`GetPathOnRoad()` kann keinen gültigen Pfad liefern. Dann wird die Verbindung als nicht straßengebunden markiert oder erhält eine manuell definierte Teilstrecke. Direkte Luftlinie wird nicht stillschweigend als Straßenroute akzeptiert.

## Schienen

Schienen werden nur als eigenes Infrastruktur- und Routensystem behandelt, wenn die jeweilige Karte ein nutzbares Schienennetz bereitstellt.

Mögliche Anwendungen:

- Kartenerfassung
- strategische Transportkorridore
- Missionsziele
- Brücken- und Engstellenanalyse
- spätere Zug- oder Infrastrukturmissionen

Im ersten RC-East-Prototyp ist Schiene kein erforderlicher Logistikpfad.

## Stromleitungen und weitere Infrastruktur

Für Stromleitungen existiert kein mit Straßen und Schienen vergleichbares MOOSE-Routingverfahren.

Mögliche Erfassung:

- manuelle Korridorzonen;
- Scenery-Scan in begrenzten Gebieten;
- Prüfung verfügbarer DCS-Descriptor- oder Attributdaten;
- manuelle Verbindung erkannter Masten oder Anlagen;
- Speicherung als nicht befahrbarer Infrastrukturgraph.

Stromleitungen werden zunächst als Landmarke, Hindernis, Navigationsrisiko oder potenzielles Missionsziel behandelt, nicht als automatisch routbares Netz.

Dasselbe gilt für Pipelines, Kanäle und ähnliche Infrastruktur, sofern die Karte sie nicht über eine spezielle Terrain-API bereitstellt.

## Routengraph

Das Kampagnenmodell speichert keine bloße Liste von Wegpunkten, sondern einen Graphen.

### Knoten

```yaml
id: NODE_CONNOLLY
location_id: LOC_FOB_CONNOLLY
type: FOB
```

### Kanten

```yaml
id: EDGE_FENTY_CONNOLLY_PRIMARY
from: NODE_FENTY
to: NODE_CONNOLLY
network: ROAD
path_source: DCS_TERRAIN
validated: false
allowed_classes:
  - LIGHT_TRUCK
  - HEAVY_TRUCK
  - APC
risk:
  ambush: HIGH
  ied: HIGH
known_issues: []
```

Eine freigegebene Kante enthält zusätzlich:

- gespeicherte Polylinie
- Gesamtlänge
- typische Fahrzeit
- Fahrzeugklassen
- Brücken und Engstellen
- Materialisierungsanker
- Hinterhaltzonen
- Blockadezustand
- letzte Validierung und DCS-Version

## Datenablage

Vorgesehene Konfigurationsdateien:

```text
src/config/locations.lua
src/config/sectors.lua
src/config/routes.lua
src/config/infrastructure.lua
```

Generierte Entwicklungsdaten können zusätzlich unterhalb von `test-results/world-data/` abgelegt werden. Nur geprüfte Daten werden in die produktive Konfiguration übernommen.

## Exportwerkzeug

Eine spätere Testmission oder ein Debugmodul soll exportieren:

- Airbase-Namen und Koordinaten
- Orts- und Zonenkandidaten
- Straßen- und Schienenpfade
- Pfadlängen
- Scenery-Dichten
- fehlgeschlagene Pfadberechnungen
- erkannte Engstellenkandidaten

Die Ausgabe erfolgt strukturiert über `dcs.log` oder eine erlaubte Persistenzschnittstelle und wird anschließend in versionierte Lua-Daten überführt.

## Performance-Regel

Die Produktionsmission führt keinen flächendeckenden Scenery-Scan über Afghanistan bei jedem Start aus.

Große Scans erfolgen nur:

- in Entwicklungs- und Discovery-Missionen;
- sektorenweise;
- mit begrenzter Zellgröße und Suchrate;
- mit exportiertem und anschließend gecachtem Ergebnis.

## Prototypumfang

Für den ersten Prototyp werden benötigt:

- Jalalabad/Fenty als MOOSE-Airbase-Knoten;
- FOB Connolly als manuell bestätigter Ortsknoten;
- ein afghanischer Checkpoint;
- drei bis fünf relevante Siedlungs- oder Geländeknoten;
- eine automatisch erzeugte und manuell validierte Primärroute;
- nach Möglichkeit eine unabhängige Alternativroute;
- vier bis acht Materialisierungsanker;
- drei bis sechs Hinterhaltzonen;
- ein dokumentierter Bericht über fehlende oder fehlerhafte Terrainpfade.

## Abnahmekriterien

- Straßenpfade können aus zwei bekannten Ortsknoten erzeugt werden.
- Ein fehlender Pfad wird erkannt und nicht als gültige Straßenroute gespeichert.
- Die Primärroute wird mit den vorgesehenen Fahrzeugtypen praktisch validiert.
- Ortsnamen und Kampagnenrollen stammen aus unserem Register, nicht aus ungesicherten Scenery-Namen.
- Discovery-Scans laufen nur im Entwicklungsmodus.
- Stromleitungen und andere nicht routbare Infrastruktur werden nicht mit Straßen- oder Schienennetzen verwechselt.
