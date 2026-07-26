# DTC01 – Ausführungskontext, Bebauungsdichte und Ortsnamen

Datum: 16. Juli 2026  
Status: technische Ergänzung zum DTC01-Machbarkeitsentwurf; noch keine Implementierung oder DCS-Abnahme

## 1. Ausgangsbeobachtung

Die im Mission Editor sichtbare Afghanistan-Karte zeigt mehrere getrennte Informationsschichten:

- einzelne Gebäudegrundrisse;
- Straßen, Flüsse, Kanäle, Gleise und Vegetation;
- orange eingefärbte bebaute oder kartographisch hervorgehobene Flächen;
- Ortsbeschriftungen wie `Qarabagh`;
- weitere Kartenlabels und Symbole.

Wichtig ist die technische Trennung:

```text
Kartenrenderer kennt oder zeichnet eine Information
!=
Mission-Scripting-API stellt dieselbe Information bereit
```

Die sichtbaren orangefarbenen Flächen und Ortsnamen sind zunächst Bestandteile der Karten-/UI-Darstellung. Es ist noch nicht nachgewiesen, dass diese Render-Layer als Mission-Scripting-Daten abgefragt werden können.

## 2. Wo der Crawler ausgeführt wird

Der eigentliche Scan läuft nicht im statischen Bearbeitungszustand des Mission Editors.

Der Mission Editor dient dazu:

- eine dedizierte Scanner-Mission anzulegen;
- Scanregionen, Referenzzonen und Startparameter zu definieren;
- das Scanner-Skript über `DO SCRIPT FILE`, Initialisierungsskript oder einen vergleichbaren Missionsmechanismus zu laden;
- die Mission zu speichern und zu starten.

Erst nach dem Start der Mission läuft das Skript in der Mission Scripting Environment und kann auf `world`, `land`, `coord`, `timer` und gefundene DCS-Objekte zugreifen.

Praktischer Ablauf:

```text
Mission Editor
→ Scanner-Mission konfigurieren
→ Mission mit FLY/Start ausführen
→ DTC01 scannt während der laufenden Simulation
→ strukturierte Ergebnisse in Log oder späteren Exportkanal schreiben
→ Mission beenden
→ Ergebnisse offline normalisieren
```

Die Scanner-Mission kann als leere technische Mission ohne Kampagnenlogik aufgebaut werden. Ein Spielerfahrzeug ist nur dann erforderlich, wenn DCS eine Clientposition für Missionsstart oder Tests zur Terrain-Streaming-Abhängigkeit benötigt.

## 3. Native technische Grundlage

Die erste DTC01-Version soll die native DCS-Funktion verwenden:

```lua
world.searchObjects(
  Object.Category.SCENERY,
  volume,
  handler,
  data
)
```

Gefundene `SceneryObject`-Instanzen erben die allgemeinen `Object`-Funktionen. Abhängig vom tatsächlichen Objekt können unter anderem gelesen werden:

```text
getCategory()
getTypeName()
getDesc()
hasAttribute()
getName()
getPoint()
getPosition()
```

Der Descriptor kann technische Typnamen, lokalisierte Anzeigenamen, Attribute, Bounding Box und initiale Lebenspunkte enthalten.

Die DCS-Dokumentation beschreibt `Object.getName()` als den im Mission Editor zugewiesenen Objektnamen. Bei Terrain-Scenery ist daher nicht zu erwarten, dass dieser Wert automatisch dem auf der Karte sichtbaren Ortsnamen entspricht. Bei Scenery kann der Name beispielsweise eine technische oder numerische Kennung sein.

## 4. Suchraster gegen Analyseraster

Der DCS-Crawler und die spätere Siedlungsanalyse benötigen nicht dieselbe Zellgröße.

Empfohlen:

```text
DCS-Suchzelle:
1.000 m × 1.000 m

Offline-Analyseraster:
100 m × 100 m
oder
250 m × 250 m
```

Begründung:

- größere DCS-Suchzellen reduzieren die Anzahl teurer `world.searchObjects`-Aufrufe;
- jedes gefundene Objekt besitzt eine Position und kann offline in beliebig kleine Analysezellen einsortiert werden;
- Klassifikationsregeln können später geändert werden, ohne Afghanistan erneut in DCS zu scannen;
- mehrere Analyseauflösungen können aus demselben Rohkatalog erzeugt werden.

Beispiel:

```text
Eine 1-km-Suchzelle liefert 428 Objekte.

Der Offline-Normalisierer verteilt diese anschließend auf:
- 100 einzelne 100-m-Zellen oder
- 16 einzelne 250-m-Zellen.
```

## 5. Bebauungsdichte

Die Grundidee, Bebauung über Häuser pro Fläche zu bestimmen, ist fachlich richtig.

Eine einfache Kennzahl ist:

```text
Gebäudedichte = bestätigte Gebäudeanzahl / Zellfläche in km²
```

Beispiel:

```text
250 m × 250 m = 0,0625 km²
40 bestätigte Gebäude / 0,0625 km²
= 640 Gebäude/km²
```

Eine reine Anzahl reicht jedoch nicht für alle Kartenbereiche. Zusätzlich sollen gespeichert oder berechnet werden:

- bestätigte Gebäudeanzahl;
- Summe der Gebäudegrundflächen aus Bounding Boxes;
- bebaute Flächenquote;
- mittlere und maximale Gebäudegröße;
- Abstand zwischen Gebäuden;
- Clustergröße und Zusammenhang benachbarter Gebäude;
- Anteil industrieller, militärischer oder besonderer Gebäudetypen;
- Verhältnis Gebäude zu Vegetation, Mauern und sonstiger Scenery;
- Abstand zum nächsten dichten Siedlungskern.

Vorgeschlagene Merkmale:

```text
building_count
buildings_per_km2
building_footprint_m2
built_coverage_ratio
median_nearest_building_distance_m
largest_connected_cluster
industrial_object_count
unknown_structure_count
```

## 6. Warum zunächst ein Typkatalog nötig ist

Nicht jedes Scenery-Objekt ist ein Haus.

Eine ungefilterte Objektdichte könnte vermischen:

- Gebäude;
- Mauern;
- Bäume und Büsche;
- Strommasten;
- Brücken;
- Industrieobjekte;
- Trümmer und Dekoration;
- sonstige Terrainmodelle.

Daher muss DTC01 zuerst alle technischen Typen inventarisieren und anschließend empirisch klassifizieren:

```text
DCS typeName
+ displayName
+ attributes
+ Bounding Box
+ Beispielkoordinaten
→ Sichtprüfung im Mission Editor / in der F10-Karte / in 3D
→ interne semantische Klasse
```

Erste Taxonomie:

```text
BUILDING_RESIDENTIAL
BUILDING_COMMERCIAL
BUILDING_INDUSTRIAL
BUILDING_RELIGIOUS
BUILDING_MILITARY
WALL_OR_COMPOUND
BRIDGE
POWER_POLE
POWER_TOWER
COMMUNICATION_TOWER
PIPELINE_OBJECT
RAIL_OBJECT
VEGETATION
LANDMARK
UNKNOWN
```

Unbekannte Typen bleiben `UNKNOWN` und werden nicht automatisch als Gebäude gezählt.

## 7. Siedlungsklassifikation

Nach bestätigter Gebäudetypisierung kann eine regelbasierte oder statistisch kalibrierte Klassifikation entstehen.

Beispielklassen:

```text
URBAN_CORE
URBAN
TOWN_EDGE
VILLAGE
HAMLET
SCATTERED_SETTLEMENT
RURAL_EMPTY
INDUSTRIAL
MILITARY_OR_SPECIAL
UNKNOWN
```

Die Screenshots um Qarabagh zeigen visuell mehrere geeignete Referenztypen:

- dicht bebauter Ortskern;
- lockerer Ortsrand;
- kompakte Dorfcluster;
- weit verteilte Compound-Strukturen;
- fast unbebautes Land;
- Industrie-/Sonderflächen.

Die Schwellenwerte werden nicht vorab erfunden. Sie werden aus manuell beschrifteten Referenzflächen abgeleitet.

Beispiel:

```text
Referenzfläche A: sichtbarer dichter Qarabagh-Kern
Referenzfläche B: Randbereich Qarabagh
Referenzfläche C: kleiner abgegrenzter Siedlungskern
Referenzfläche D: Streusiedlung/Compounds
Referenzfläche E: unbebautes Gebiet
Referenzfläche F: Industrie-/Sondergebiet
```

## 8. Orange Kartenflächen

Die Screenshots zeigen orange gefüllte Flächen, die stark mit dichter Bebauung korrelieren.

Daraus folgt als Hypothese:

```text
Der Kartenrenderer besitzt eine interne Built-up-/Settlement-Darstellung.
```

Noch nicht bewiesen ist:

```text
Diese Polygone sind über world.searchObjects, land oder eine andere öffentliche Mission-Scripting-Funktion zugänglich.
```

DTC01-P0 soll deshalb ausdrücklich protokollieren:

- ob innerhalb und außerhalb orange markierter Flächen unterschiedliche Scenery-Metadaten erscheinen;
- ob irgendein Objekt oder Descriptor eine Area-/Settlement-Kennung enthält;
- ob Trigger-/Map-Drawing-Daten diese Flächen referenzieren;
- ob die orange Fläche ausschließlich ein UI-Renderprodukt bleibt.

Bis zum Gegenbeweis werden die orangefarbenen Polygone nicht als programmatisch nutzbare Datenquelle behandelt.

## 9. Ortsnamen und Kartenlabels

### 9.1 Aktueller dokumentierter Stand

In der öffentlich dokumentierten Mission-Scripting-API ist keine allgemeine Funktion bekannt wie:

```lua
local place = map.getPlaceNameAtCoordinate(vec2)
local towns = terrain.getAllTownLabels()
```

Die dokumentierten Objektfunktionen liefern Namen von Objekten. Sie liefern nicht automatisch die Beschriftungen des Kartenrenderers.

Die auf der Karte sichtbare Beschriftung `Qarabagh` ist daher wahrscheinlich ein Datensatz des Terrain-/Kartenlayers und kein gewöhnliches `SceneryObject`.

### 9.2 MOOSE

MOOSE registriert Scenery nicht vollständig in seiner globalen Datenbank, weil pro Karte zu viele Scenery-Objekte existieren. Scenery muss räumlich gesucht und anschließend gewrappt werden.

MOOSE erleichtert:

- Koordinaten;
- Zonen;
- Scenery-Scans;
- räumliche Auswertung;
- Logging und Scheduler.

Es ist aber derzeit keine gegen den gepinnten Stand 2.9.18 bestätigte MOOSE-Funktion dokumentiert, die sämtliche sichtbaren Terrain-Ortslabels der Afghanistan-Karte ausliest.

### 9.3 P0-Test für Ortsnamen

Der Scanner soll bekannte Ortszentren gezielt untersuchen:

```text
Qarabagh
Istalif
weitere sichtbare Afghanistan-Labels
```

Für jedes gefundene Scenery-Objekt werden ausgegeben:

```text
getName()
getTypeName()
displayName
attributes
position
```

Ziel:

- prüfen, ob irgendein Scenery-Objekt den Ortsnamen trägt;
- technische IDs von echten Ortsnamen unterscheiden;
- feststellen, ob Ortslabel möglicherweise als unsichtbares oder besonderes Scenery-Objekt existieren.

Erwartung:

```text
wahrscheinlich kein direktes Ortslabel über SCENERY
```

Der Test ist dennoch billig und soll diese Annahme empirisch bestätigen.

## 10. Alternative Ortsnamendatenbank

Falls die DCS-Mission-Scripting-API keine Ortslabels liefert, wird der Objektkatalog um einen getrennten Gazetteer-Datenkanal ergänzt.

Mögliche Quellen:

1. manuell aus der DCS-Karte erfasste Ortsnamen und Mittelpunktkoordinaten;
2. frei verfügbare externe Geodaten, soweit Lizenz und Abweichungen dokumentiert sind;
3. später eventuell ein technisch auslesbarer Terrain-Datensatz, falls eine öffentliche, stabile und rechtlich unproblematische Schnittstelle identifiziert wird.

Wichtig:

```text
DCS-Scenery-Katalog
!=
Ortsnamen-Gazetteer
```

Beide werden räumlich verknüpft:

```text
Siedlungscluster
→ Schwerpunkt berechnen
→ nächstgelegenen Gazetteer-Eintrag suchen
→ Name und Distanz speichern
```

Beispielprodukt:

```json
{
  "clusterId": "AFG-QARABAGH-001",
  "class": "URBAN",
  "centroid": { "lat": 34.843, "lon": 69.151 },
  "nearestPlaceName": "Qarabagh",
  "placeNameSource": "manual_dcs_map_gazetteer",
  "distanceToPlaceCenterMeters": 230,
  "classificationConfidence": 0.93
}
```

## 11. Nicht empfohlene Ortsnamengewinnung

Nicht als Produktionsweg vorgesehen:

- OCR über Screenshots der Karte;
- automatisiertes Lesen der UI-Pixel;
- Abhängigkeit von undokumentierten Terrain-Dateiformaten;
- Extraktion proprietärer Terrainarchive;
- festes Parsen interner Dateien, die sich bei jedem Update ändern können.

Diese Wege wären instabil, schwer reproduzierbar und teilweise lizenz- oder distributionsrechtlich problematisch.

## 12. Beziehung zu OMW

OMW benötigt später nicht alle Einzelhäuser.

DTC01 kann aus dem Rohkatalog kompakte Produkte erzeugen:

```lua
routeEnvironmentProfiles = {
  {
    fromDistanceMeters = 0,
    toDistanceMeters = 3200,
    environment = "URBAN",
    settlementName = "Qarabagh",
    confidence = 0.94,
  },
  {
    fromDistanceMeters = 3200,
    toDistanceMeters = 9600,
    environment = "SCATTERED_SETTLEMENT",
    settlementName = nil,
    confidence = 0.81,
  },
}
```

Die normale Kampagnenmission führt keine Scenery-Dichteanalyse aus. Sie liest nur das vorkompilierte Profil.

## 13. Ergänzte P0-Abnahmekriterien

Zusätzlich zu den bisherigen DTC01-P0-Kriterien:

- Scanner läuft nach Missionsstart in einer dedizierten Scanmission;
- dieselbe Zelle liefert bei Wiederholung reproduzierbare Objekte;
- mindestens ein dichter, ein dörflicher und ein unbebauter Referenzbereich wird verglichen;
- Rohobjekte werden erfolgreich in kleinere Offline-Analyseraster einsortiert;
- erster bestätigter Gebäudetypkatalog liegt vor;
- Gebäudeanzahl und bebaute Flächenquote werden je Analysezelle berechnet;
- orange Kartenflächen werden als API-zugänglich oder reines Render-Layer klassifiziert;
- bekannte Ortsnamen werden auf mögliche Objektmetadaten getestet;
- direkter Ortsnamenabruf wird nur behauptet, wenn ein reproduzierbarer API-Nachweis vorliegt;
- andernfalls wird ein getrennt versionierter Gazetteer verwendet.

## 14. Technische Quellen

- Eagle Dynamics, Mission Scripting Environment und Skriptausführung:
  https://www.digitalcombatsimulator.com/en/support/faq/1253/
- Eagle Dynamics, Game Objects und verfügbare Singletons:
  https://www.digitalcombatsimulator.com/en/support/faq/1254/
- Eagle Dynamics, Object-Klasse und Objektmetadaten:
  https://www.digitalcombatsimulator.com/en/support/faq/1259/
- Eagle Dynamics, SceneryObject:
  https://www.digitalcombatsimulator.com/en/support/faq/1265/
- MOOSE, SCENERY-Wrapper und notwendige räumliche Scans:
  https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Wrapper.Scenery.html

## 15. Entscheidung

```text
1. Der Crawler wird in einer laufenden dedizierten DCS-Mission ausgeführt.
2. Der Mission Editor definiert Scanregionen und lädt das Skript, führt den Scan aber nicht selbst im Bearbeitungsmodus aus.
3. Bebauung wird aus bestätigten Gebäudeobjekten pro Fläche und zusätzlichen Cluster-/Grundflächenmerkmalen abgeleitet.
4. Suchraster und Analyseraster werden getrennt.
5. Orange Kartenflächen gelten zunächst nur als visuelle Referenz, nicht als verfügbare API-Daten.
6. Für sichtbare Ortsnamen existiert derzeit kein bestätigter allgemeiner Mission-Scripting-Abruf.
7. P0 prüft empirisch, ob bekannte Ortsnamen in Scenery-Metadaten auftauchen.
8. Falls nicht, erhält DTC01 einen getrennten, versionierten Gazetteer.
9. OMW konsumiert nur vorkompilierte Siedlungs- und Routenprofile.
10. Kein OCR-, UI-Pixel- oder proprietärer Terrain-Datei-Crawler wird als Produktionsabhängigkeit verwendet.
```
