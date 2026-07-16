# DTC01 – DCS Terrain Cartographer

Datum: 16. Juli 2026  
Status: Machbarkeits- und Architekturentwurf; noch keine Implementierung oder DCS-Abnahme

## 1. Projektidee

DTC01 ist ein vom Kampagnenbetrieb getrenntes Nebenprojekt. Es soll DCS-Terrains über die öffentlich verfügbare Mission-Scripting-Schnittstelle räumlich katalogisieren und daraus wiederverwendbare Metadaten erzeugen.

Das Ziel ist **nicht**, Terrainarchive, 3D-Modelle, Texturen oder proprietäre Kartendateien zu extrahieren. Katalogisiert wird ausschließlich, was DCS einer laufenden Mission als Welt- und Scenery-Objekte zugänglich macht.

Beispiele für spätere Abfragen:

```text
Wie hoch ist die Gebäudedichte in diesem Gebiet?
Ist dieser Straßenabschnitt urban, dörflich oder dünn besiedelt?
Wo befinden sich Objekte eines bestimmten DCS-Typs?
Welche bekannten Industrieobjekte liegen in einem Operationsraum?
Welche Brücken, Strommasten oder sonstigen Scenery-Typen sind über die API sichtbar?
```

DTC01 wird als Werkzeug unter `tools/` geführt. Die normale OMW-Kampagne darf niemals während des Spielbetriebs eine ganze Karte crawlen.

## 2. Grundsätzliche Machbarkeit

Die Grundidee ist technisch machbar.

DCS stellt bereit:

```lua
world.searchObjects(
  Object.Category.SCENERY,
  volume,
  handler,
  data
)
```

Als Suchvolumen sind unter anderem Boxen und Kugeln verfügbar. Jedes gefundene `SceneryObject` erbt die allgemeinen `Object`-Funktionen. Damit können – abhängig vom tatsächlich gelieferten Objekt – unter anderem folgende Informationen abgefragt werden:

```text
Kategorie
DCS-Typname
Descriptor
lokalisierter Anzeigename
Attribute
Lebenspunkte und Bounding Box, sofern im Descriptor vorhanden
Position
Orientierung
Objektname, sofern DCS einen brauchbaren Namen liefert
```

DCS kann lokale Weltkoordinaten außerdem in Breiten- und Längengrad umrechnen.

Damit ist ein Raster-Crawler möglich:

```text
festgelegtes Karten- oder Operationsgebiet
→ in Zellen aufteilen
→ jede Zelle einzeln mit world.searchObjects durchsuchen
→ Rohmetadaten erfassen
→ überlappende Funde deduplizieren
→ außerhalb von DCS klassifizieren und indexieren
```

## 3. Wesentliche Einschränkung

Die API liefert **Scenery-Objekte**, aber keine fertige geographische Semantik.

DCS sagt nicht zuverlässig:

```text
Das ist ein Wohnhaus.
Das ist ein Dorf.
Das ist eine Stadtgrenze.
Das ist eine Fabrik.
Das ist ein Strommast.
Das ist eine Pipeline.
```

Es liefert zunächst technische Typnamen, Descriptoren, Attribute und Positionen. Ob ein Typ beispielsweise als Wohngebäude, Industriebau, Brücke oder Mast zu behandeln ist, muss durch eine eigene Taxonomie ermittelt werden.

Daher besteht das Projekt aus zwei getrennten Problemen:

1. **Inventarisierung:** Welche Objekte und Metadaten liefert DCS tatsächlich?
2. **Semantische Klassifikation:** Was bedeuten diese Typen für unsere Zwecke?

Die Inventarisierung ist direkt machbar. Die semantische Klassifikation benötigt einen empirisch aufgebauten Typkatalog und Stichproben im Mission Editor/F10-Kartenbild.

## 4. Was wahrscheinlich katalogisierbar ist

Gute Kandidaten für den ersten Test:

- Gebäude und Gebäudekomplexe;
- Brücken und markante Bauwerke;
- Industrie- und Infrastrukturmodelle;
- einzelne Masten, Türme und ähnliche Objekte, sofern sie als Scenery-Objekte exponiert werden;
- Kartenobjekte, deren DCS-Typname oder Descriptor wiederholbar ist;
- missionseigene `STATIC`-Objekte in einem getrennten Datenkanal.

Nicht voraussetzen, sondern praktisch prüfen:

- ob jeder Strommast ein eigenes Scenery-Objekt ist;
- ob Gleise als einzelne Objekte, als Netzgeometrie oder gar nicht enumerierbar sind;
- ob Straßen als Scenery-Objekte erscheinen;
- ob Pipelines als einzelne Modelle, Splines oder nicht zugängliche Terrain-Geometrie umgesetzt sind;
- ob Vegetation vollständig, teilweise oder gar nicht über `SCENERY` zurückgegeben wird;
- ob weit entfernte Scenery unabhängig vom Spielerstandort vollständig durchsuchbar ist.

Straßen und Schienen sind ein Sonderfall. DCS besitzt Straßen-/Pfadfunktionen und `land.getSurfaceType()` kann unter anderem `ROAD` zurückgeben. Daraus folgt aber noch keine API zum vollständigen Enumerieren des gesamten Straßennetzes. Eine Scenery-Inventur und eine Netzwerkkartierung sind daher getrennte Teilprobleme.

## 5. Vorgeschlagene Architektur

```text
DCS-Crawler-Mission
    |
    | Rohobjekte und Scanfortschritt
    v
Exporter
    |
    | JSONL/CSV oder strukturierte Logsegmente
    v
Offline-Normalisierer
    |
    | Deduplizierung, Typkatalog, Koordinaten, Versionierung
    v
Terrain-Katalog
    |
    +--> Objektabfragen
    +--> Dichtekarten
    +--> Siedlungsklassifikation
    +--> OMW-Routenprofile
```

### 5.1 DCS-Crawler

Aufgaben:

- Scanregion und Raster erzeugen;
- Zellen nacheinander durchsuchen;
- pro Zelle ein begrenztes Arbeitsbudget einhalten;
- Scenery-Metadaten defensiv per `pcall` lesen;
- Scanfortschritt und Fehler strukturiert protokollieren;
- keine Objektmanipulation durchführen;
- keine Kampagnenlogik laden.

### 5.2 Exporter

Drei mögliche Exportwege:

#### A. Strukturierte DCS-Logausgabe

Vorteile:

- keine Änderung der DCS-Sandbox nötig;
- sicherer Proof of Concept;
- einfach zu diagnostizieren.

Nachteile:

- ungeeignet für Millionen Einzelzeilen;
- Logdateien werden groß;
- Wiederaufnahme und atomare Checkpoints sind schwieriger.

Einsatz: API-Probe und kleine Testgebiete.

#### B. Dedizierte lokale Scanner-Installation mit Datei-I/O

Die Mission Scripting Environment ist isoliert. Direktes Schreiben auf den Datenträger ist in einer normalen, unveränderten Installation nicht als allgemeine Missionsfunktion einzuplanen. Für eine **ausschließlich lokale Offline-Scanner-Installation** könnte Datei-I/O bewusst freigeschaltet werden.

Vorteile:

- JSONL/CSV direkt und effizient schreiben;
- Checkpoints und Wiederaufnahme;
- große Datenmengen handhabbar.

Nachteile und Schutzregeln:

- verändert die lokale Sicherheitsgrenze der Mission-Sandbox;
- nicht auf einem öffentlichen oder produktiven Server verwenden;
- DCS-Updates können lokale Änderungen überschreiben;
- Exportpfad fest auf einen Scanner-Unterordner begrenzen;
- Eingaben nicht aus fremden Missionen übernehmen.

Einsatz: späterer Vollscan nach bestandenem Proof of Concept.

#### C. Externer Hook/Bridge-Prozess

Ein Hook oder lokaler Begleitprozess könnte Scanpakete entgegennehmen und außerhalb der Mission schreiben.

Vorteile:

- Mission-Sandbox kann geschlossen bleiben;
- saubere Trennung zwischen Erfassung und Persistenz.

Nachteile:

- deutlich höhere Implementierungskomplexität;
- eigene Protokoll-, Fehler- und Wiederaufnahmelogik;
- erst nach Nachweis des eigentlichen Scanners sinnvoll.

Entscheidung: DTC01 beginnt mit A. B oder C wird erst nach dem API-Prototyp festgelegt.

### 5.3 Offline-Normalisierer

Aufgaben:

- Rohdatensätze validieren;
- doppelte Funde aus angrenzenden/überlappenden Zellen entfernen;
- DCS-Weltkoordinaten und geographische Koordinaten speichern;
- Typnamen und Attribute normalisieren;
- Typkatalog und manuelle Labels anwenden;
- räumliche Indizes und Dichteprodukte erzeugen;
- Katalogversionen vergleichen.

## 6. Vorgeschlagenes Rohdatenschema

Ein Objekt sollte mindestens enthalten:

```json
{
  "catalogSchemaVersion": 1,
  "terrainId": "Afghanistan",
  "dcsBuild": "2.9.27.25340",
  "scannerVersion": "DTC01-P0",
  "scanRunId": "...",
  "cellId": "...",
  "objectCategory": "SCENERY",
  "objectName": null,
  "typeName": "...",
  "displayName": "...",
  "attributes": [],
  "point": { "x": 0, "y": 0, "z": 0 },
  "lat": 0,
  "lon": 0,
  "altMsl": 0,
  "orientation": null,
  "boundingBox": null,
  "initialLife": null,
  "dedupKey": "..."
}
```

Alle Felder außer den technischen Mindestfeldern müssen `null` beziehungsweise leer sein dürfen. Fehlende oder inkonsistente DCS-Metadaten dürfen den Scan nicht stoppen.

## 7. Deduplizierung und Objektidentität

Benachbarte Zellen können dasselbe Objekt zurückgeben, insbesondere wenn Suchvolumen überlappen oder ein großes Objekt Zellgrenzen schneidet.

Ein Objektname darf nicht ungeprüft als terrainübergreifend stabile ID behandelt werden. Für Deduplizierung innerhalb eines Scanlaufs wird ein zusammengesetzter Schlüssel vorgeschlagen:

```text
Terrain
+ DCS-Build
+ TypeName
+ hochpräzise Objektposition
+ Orientierung
+ Bounding-Box-Abmessungen
+ DCS-Objektname, falls brauchbar
```

Zusätzlich speichert der Normalisierer alle kollidierenden Rohdatensätze. Eine Hashkollision oder zwei gleichartige, sehr nahe Objekte dürfen nicht still zusammengeführt werden.

## 8. Raster- und Scanstrategie

DCS beschreibt die Bodenebene konzeptionell als unbegrenzt. Eine automatische zuverlässige Terrain-Außengrenze steht der Mission-Scripting-Logik daher nicht zur Verfügung.

Folge: Jeder Scan benötigt explizite Grenzen.

Mögliche Grenzen:

- rechteckige Weltkoordinaten;
- Polygon des interessierenden Kartenbereichs;
- mehrere Operationssektoren;
- ein Korridor um eine bekannte Route;
- manuell definierte Eckpunkte im Mission Editor.

Empfohlene Reihenfolge:

1. drei kleine Kalibrierflächen;
2. Bagram–Jalalabad-Korridor;
3. ein zusammenhängender Operationssektor;
4. erst danach größere Afghanistan-Regionen.

Rasterbeispiel:

```text
1.000 m × 1.000 m Basiszellen
500 m × 500 m nur in dichten Testgebieten
50–250 m Analysezellen entstehen später offline aus den Objektpunkten
```

Die Suchzelle und die spätere Analysezelle müssen nicht gleich groß sein. Große Suchzellen reduzieren API-Aufrufe; kleine Analysezellen werden außerhalb von DCS aus dem Objektkatalog gebildet.

Anzahl der Suchaufrufe:

```text
Zellenzahl = Fläche / Zellfläche
```

Beispiel:

```text
100 km × 100 km bei 1-km-Zellen   = 10.000 Suchzellen
100 km × 100 km bei 500-m-Zellen  = 40.000 Suchzellen
```

Ein Vollscan großer Terrainregionen kann deshalb lange dauern. Das ist akzeptabel, weil DTC01 ein Offline-Werkzeug und keine Kampagnenfunktion ist.

## 9. Laufzeitbudget

`world.searchObjects` wird nicht in einer engen Schleife über die gesamte Karte ausgeführt.

Der Crawler arbeitet zeitlich gestaffelt:

```text
Scheduler-Tick
→ eine oder wenige Zellen scannen
→ Treffer verarbeiten
→ Laufzeit messen
→ bei Budgetüberschreitung pausieren
→ nächsten Tick planen
```

Konfigurierbare Grenzen:

```text
maxCellsPerTick
maxObjectsPerTick
maxProcessingMillisecondsPerTick
checkpointEveryCells
pauseSecondsBetweenBatches
```

Die tatsächliche Scanzeit und mögliche Frame-Spitzen müssen in DCS gemessen werden. Theoretische Objektzahlen reichen nicht als Abnahme.

## 10. Typkatalog statt blindem Namensfilter

Die Abfrage „finde alle Objekte mit Namen xyz“ ist nur zuverlässig, wenn DCS tatsächlich stabile und aussagekräftige Namen liefert. Wahrscheinlicher ist, dass `typeName`, `displayName`, Attribute und Bounding Box wichtiger sind.

Daher erzeugt der erste Scan eine Typinventur:

```text
TypeName
Anzahl
Beispielkoordinaten
DisplayName
Attribute
Bounding-Box-Größe
manuelle Klasse
Vertrauensgrad
```

Beispiel für unsere eigene Taxonomie:

```text
BUILDING_RESIDENTIAL
BUILDING_COMMERCIAL
BUILDING_INDUSTRIAL
BUILDING_RELIGIOUS
BRIDGE
POWER_POLE
POWER_TOWER
COMMUNICATION_TOWER
PIPELINE_OBJECT
RAIL_OBJECT
ROAD_OBJECT
FORTIFICATION
VEGETATION
LANDMARK
UNKNOWN
```

Ein technischer DCS-Typ wird erst nach Sichtprüfung einer semantischen Klasse zugeordnet. Unbekannte Typen bleiben `UNKNOWN`; sie werden nicht geraten.

## 11. Siedlungsklassifikation

Eine Stadt-/Dorf-/Land-Klassifikation sollte nicht nur rohe Objektanzahlen verwenden.

Bessere Merkmale pro Analysezelle beziehungsweise Nachbarschaft:

- Anzahl bestätigter Gebäude;
- Gebäudegrundfläche aus Bounding Boxes;
- geschätzte bebaute Flächendichte;
- mittlere und maximale Objektgröße;
- Anzahl industrieller oder markanter Gebäudetypen;
- zusammenhängende Cluster statt einzelner isolierter Häuser;
- Abstand zum nächsten Gebäudekern;
- optional Straßenoberflächen-/Netzmerkmale, falls später belastbar gewonnen;
- optional manuelle Ausschluss- und Korrekturzonen.

Erster Klassifikationsvorschlag:

```text
URBAN_CORE
URBAN
VILLAGE
HAMLET / SCATTERED
RURAL_EMPTY
INDUSTRIAL
UNKNOWN
```

Die Grenzwerte werden nicht vorab erfunden. Sie werden aus beschrifteten Referenzflächen abgeleitet:

```text
bekanntes Stadtzentrum
bekannter Stadtrand
bekanntes Dorf
Streusiedlung
unbebautes Tal/Gebirge
Industrie-/Militärfläche
```

Für OMW kann die feinere Klassifikation später auf wenige operative Profile reduziert werden:

```text
URBAN
SETTLEMENT
RURAL
SPECIAL
```

## 12. Was DTC01 nicht automatisch lösen kann

- offizielle oder administrative Stadtgrenzen;
- Einwohnerzahlen;
- reale Gebäudenutzung aus einem generischen DCS-Modell;
- exakte Straßenklassen ohne zusätzliche Datenquelle;
- garantierte Identifikation jedes Strommasts, Gleises oder Pipelineabschnitts;
- semantische Bedeutung eines DCS-Typnamens ohne Kalibrierung;
- Vollständigkeit, falls DCS weit entfernte Scenery nicht global exponiert;
- Stabilität über Terrainupdates ohne erneuten Scan;
- Qualität von Kartenbereichen, die im Terrain nur gering detailliert umgesetzt sind.

Der Katalog beschreibt die **DCS-Abbildung der Welt**, nicht die reale Geographie Afghanistans.

## 13. Versionierung und Reproduzierbarkeit

Jeder Katalog ist an mindestens folgende Größen gebunden:

```text
DCS-Build
Terrain/Modul
Scanner-Version
Katalogschema-Version
Scanregion
Rasterdefinition
Typkatalog-Version
Klassifikator-Version
```

Nach einem DCS- oder Terrainupdate wird nicht automatisch behauptet, der alte Katalog sei weiterhin identisch. Ein Differenzscan muss zeigen:

- neue Objekte;
- entfernte Objekte;
- verschobene Objekte;
- veränderte Typnamen oder Descriptoren;
- veränderte Dichte- und Profilklassen.

## 14. Beziehung zu OMW

DTC01 darf die Kampagne nicht mit Rohdaten belasten.

OMW konsumiert später nur ein kleines, kompiliertes Produkt, beispielsweise:

```lua
routeEnvironmentProfiles = {
  {
    fromDistanceMeters = 0,
    toDistanceMeters = 4200,
    environment = "URBAN",
    confidence = 0.94,
  },
  {
    fromDistanceMeters = 4200,
    toDistanceMeters = 18100,
    environment = "RURAL",
    confidence = 0.88,
  },
}
```

Der vollständige Objektkatalog bleibt ein Entwicklungsartefakt. Die Kampagnenlaufzeit enthält weder flächige Scenery-Scans noch Gebäudedichteberechnungen.

Nutzen für OMW:

- objektivere URBAN-/RURAL-Routenprofile;
- automatische Vorschläge für Geschwindigkeits- und Formation-Interval-Segmente;
- Auffinden von Brücken, Engstellen und Infrastrukturkandidaten;
- Missionsdesign- und Plausibilitätsprüfungen;
- reproduzierbare Kartenanalyse statt rein visueller Handarbeit.

## 15. MOOSE-Rolle

Der erste Proof of Concept soll die native DCS-Funktion `world.searchObjects` direkt verwenden. Dadurch ist eindeutig, welche Daten DCS selbst liefert.

MOOSE kann später helfen bei:

- Zonen- und Koordinatenverwaltung;
- Scheduler-Orchestrierung;
- Logging;
- räumlichen Hilfsfunktionen;
- Wrappern für Scenery-Objekte, sofern im gepinnten Stand vorhanden und geprüft.

MOOSE erzeugt aber keine verborgenen Terrainmetadaten. Es kann nur DCS-Daten komfortabler verarbeiten. Jede verwendete Funktion muss gegen den im Projekt gepinnten Stand MOOSE 2.9.18 geprüft werden.

## 16. Proof-of-Concept DTC01-P0

Der erste Test scannt **nicht Afghanistan vollständig**.

### 16.1 Testflächen

Drei bis sechs manuell gesetzte Flächen:

```text
A: dichtes Stadtgebiet
B: Stadtrand
C: Dorf
D: Streusiedlung
E: unbebautes Land
F: Industrie-/Infrastrukturgebiet
```

### 16.2 Erfasste Daten

- alle gefundenen `SCENERY`-Objekte;
- optional getrennt alle `STATIC`-Objekte;
- Typname, Name, Descriptor, Attribute, Position und Orientierung;
- Koordinatenumrechnung;
- Anzahl je technischem Typ;
- Laufzeit je Suchzelle;
- Fehler je API-Feld;
- Deduplizierungsstatistik.

### 16.3 Kritische Experimente

1. Dieselbe Fläche zweimal scannen: Sind Anzahl und Datensätze reproduzierbar?
2. Fläche bei Spieler in unmittelbarer Nähe und weit entfernt scannen: Sind die Ergebnisse gleich?
3. Überlappende Zellen scannen: Funktioniert Deduplizierung?
4. Bekannte Häuser, Brücken, Masten und Industrieobjekte visuell markieren: Welche Typnamen liefert DCS?
5. Sehr große und sehr kleine Suchvolumen vergleichen: Wie skaliert die Laufzeit?
6. Leere Fläche und dichte Stadt vergleichen: Wie stark variiert die Callbacklast?
7. Prüfen, ob zerstörte Scenery noch erscheint und welchen Zustand der Descriptor liefert.

### 16.4 P0-Abnahmekriterien

- mindestens drei Testflächen erfolgreich katalogisiert;
- reproduzierbare Rohdaten bei Wiederholung;
- dokumentierte Liste tatsächlich verfügbarer Felder;
- dokumentierte Liste fehlender/instabiler Felder;
- keine stille Deduplizierungskollision;
- Scan kann pausieren und fortgesetzt werden;
- keine unkontrollierte lange Lua-Blockade;
- klarer Nachweis, ob entfernte Scenery global suchbar ist;
- erster manuell bestätigter Typkatalog für Gebäude und mindestens eine Infrastrukturklasse.

## 17. Weitere Phasen

### DTC01-P1 – Bagram–Jalalabad-Korridor

```text
bekannte Route
+ begrenzter Korridor links/rechts der Route
+ Gebäude- und Infrastrukturinventur
+ erste automatische Siedlungsdichte
```

Nutzen: unmittelbarer Vergleich mit den bisher manuell diskutierten Konvoiprofilen.

### DTC01-P2 – Klassifikator

- beschriftete Referenzflächen;
- Dichte- und Clustermerkmale;
- nachvollziehbare Regeln;
- Konfidenzwert;
- manuelle Korrekturen;
- Validierung gegen Sichtprüfung.

### DTC01-P3 – Operationssektor

- größere zusammenhängende Region;
- Checkpoints und Wiederaufnahme;
- Differenzscan;
- räumlicher Index;
- Karten- und Analyseexport.

### DTC01-P4 – Generisches Terrainwerkzeug

- beliebige DCS-Terrains;
- konfigurierbare Objektklassen;
- Suche nach Typname, Attribut und Raum;
- optionaler GeoJSON-/SQLite-Export;
- getrennte terrainabhängige Taxonomien.

## 18. Kostenbewertung

### Entwicklungskosten

```text
P0 API-Probe:                  gering bis mittel
robuster Raster-Crawler:       mittel
Dateiexport/Checkpoints:       mittel
Typkatalog:                    mittel, stark datenabhängig
Siedlungsklassifikator:        mittel
vollständiges generisches Tool: hoch
```

### Laufzeitkosten

```text
während Scanmission:           potenziell hoch, aber budgetierbar
während Offline-Normalisierung: außerhalb von DCS
während normaler OMW-Mission:  nahezu null
```

Die entscheidende Architekturregel lautet:

```text
teure Erfassung einmal offline
→ kompaktes Ergebnis versionieren
→ im Kampagnenbetrieb nur O(1)- oder kleine Indexabfragen
```

## 19. Risiken

- DCS exponiert nicht alle gewünschten Terrainmerkmale als Scenery-Objekte;
- Scenery-Typnamen sind technisch und terrainabhängig;
- Objektname kann unbrauchbar oder instabil sein;
- die API-Dokumentation beschreibt Teile einer älteren Scripting-Generation;
- große Suchvolumen können erhebliche Callbacklast erzeugen;
- weit entfernte Objekte könnten abhängig vom Terrain-Streaming sein;
- Terrainupdates können den Katalog invalidieren;
- ein ganzer Afghanistan-Scan kann sehr lange dauern und große Datenmengen erzeugen;
- eine reine Objektzählung kann Industrie, Militärflächen und Wohnbebauung verwechseln;
- Straßen, Schienen und Pipelines können als Netzgeometrie statt als enumerierbare Objekte umgesetzt sein.

Alle diese Risiken sind durch den kleinen P0-Test gezielt prüfbar. Kein Risiko rechtfertigt einen sofortigen Vollscan ohne vorherige API-Inventur.

## 20. Entscheidung

DTC01 wird als Nebenprojekt an OMW angegliedert.

Verbindliche Leitlinien:

```text
1. Native DCS-API zuerst, MOOSE erst als geprüfter Komfortlayer.
2. Kein Vollscan während einer Kampagnenmission.
3. Keine Extraktion proprietärer Terraindateien.
4. Scanregionen sind explizit begrenzt und versioniert.
5. Erst Rohdaten inventarisieren, dann Semantik klassifizieren.
6. Unbekannte Typen bleiben UNKNOWN.
7. Kataloge sind an DCS-Build und Terrainversion gebunden.
8. OMW lädt nur verdichtete Profilprodukte, nicht den Rohkatalog.
9. P0 beginnt mit wenigen Referenzflächen und Logexport.
10. Erst nach P0 wird über Datei-I/O, Hook-Bridge und Vollscan entschieden.
```

## 21. Primäre technische Referenzen

- Eagle Dynamics, DCS Scripting Engine – `world.searchObjects`, Suchvolumen und Callback:
  https://www.digitalcombatsimulator.com/es/support/faq/1646/
- Eagle Dynamics, Object-Klasse – Kategorie, Typ, Descriptor, Name, Position und Orientierung:
  https://www.digitalcombatsimulator.com/en/support/faq/1259/
- Eagle Dynamics, SceneryObject – Vererbung von Object und Descriptor:
  https://www.digitalcombatsimulator.com/en/support/faq/1265/
- Eagle Dynamics, Koordinaten, Descriptoren und Attribute:
  https://www.digitalcombatsimulator.com/en/support/faq/1256/
- Eagle Dynamics, Mission Scripting Environment:
  https://www.digitalcombatsimulator.com/en/support/faq/1253/

Die offizielle DCS-Scripting-Dokumentation weist selbst auf ihr historisches Alter und mögliche Einschränkungen hin. Deshalb ist der DCS-2.9-P0-Lauf die maßgebliche Quelle für das tatsächlich verfügbare Verhalten.