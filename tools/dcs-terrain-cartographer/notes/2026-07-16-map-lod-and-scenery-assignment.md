# DTC01 – Karten-LOD, Scenery-Objektnamen und Mission-Editor-Zuweisung

Datum: 16. Juli 2026  
Status: empirische Mission-Editor-Beobachtung; noch keine DCS-Laufzeitabnahme

## 1. Neue Beobachtung

Die Afghanistan-Karte zeigt im Mission Editor abhängig von der Zoomstufe unterschiedliche Detailgrade:

- weit herausgezoomt: Siedlungsflächen, Hauptstraßen, Gewässer und grobe Gebäudestrukturen;
- mittlere Zoomstufen: einzelne Gebäude, Nebenstraßen, Vegetationsstrukturen und weitere Infrastruktur;
- nahe Zoomstufen: zusätzliche Details wie Leitungen, Masten, Mauern und kleinere Scenery-Elemente.

Diese Darstellung wird als Karten-LOD beziehungsweise UI-LOD behandelt. Sie beweist zunächst nur, dass der Kartenrenderer diese Elemente bei bestimmten Maßstäben darstellen kann.

Wichtige Trennung:

```text
Mission-Editor-Karten-LOD
!=
3D-Terrain-Streaming
!=
Mission-Scripting-Sichtbarkeit über world.searchObjects
```

Ob `world.searchObjects` dieselben Objekte unabhängig von Kartenzoom, Kameraposition und Spielerentfernung liefert, muss DTC01-P0 empirisch prüfen.

## 2. Mission-Editor-Funktion „Assign as“

Ein Terrain-/Scenery-Objekt kann im Mission Editor per Rechtsklick und `Assign as` einer Triggerzone zugeordnet werden.

Für das ausgewählte Objekt zeigt die Zone mindestens:

```text
OBJECT ID: numerische Scenery-Instanz-ID
NAME:      technischer Objekt-/Typname
```

Im beobachteten Afghanistan-Ausschnitt erscheinen technische Namen wie:

```text
townhouseafghanistan_01
parthouseafghanistan_03
parthouseafghanistan_06
partgarage_03
mitsubishicolt
```

Die automatisch sichtbaren Suffixe wie `-1`, `-2` oder `-3` dienen der Unterscheidung mehrerer zugewiesener Zonen beziehungsweise gleich benannter Objekte im Editor. Sie sind nicht automatisch ein stabiler terrainweiter Objektschlüssel.

## 3. Bedeutung für DTC01

Diese Funktion ist ein wesentlicher Kalibrierungskanal:

1. Ein Missionsautor kann ein bekanntes Objekt visuell auswählen.
2. Der Mission Editor legt eine zugeordnete Zone an.
3. Die Zone enthält technische Objektmetadaten.
4. Der DTC01-Laufzeitscanner sucht dasselbe Objekt räumlich.
5. `getTypeName`, `getName`, Descriptor, Attribute und Position werden mit den Editorwerten verglichen.
6. Der technische Typ kann anschließend einer semantischen Klasse zugeordnet werden.

Beispiel:

```text
Editor NAME: townhouseafghanistan_01
Sichtprüfung: afghanisches Wohn-/Stadthaus
DTC01-Klasse: BUILDING_RESIDENTIAL
```

Dadurch muss der Typkatalog nicht ausschließlich aus anonymen Laufzeitdaten erraten werden.

## 4. Was diese Funktion nicht leistet

`Assign as` ist kein automatischer Vollkartenexport.

Sie erzeugt nur für bewusst ausgewählte Objekte Missionselemente. Der vollständige Terrainobjektbestand wird dadurch nicht automatisch in die `.miz`-Datei geschrieben.

Daher bleibt die Architektur:

```text
Mission Editor
→ manuelle Referenz- und Kalibrierobjekte

laufende Scanner-Mission
→ flächige Inventarisierung mit world.searchObjects

offline
→ Typkatalog, Deduplizierung und Klassifikation
```

## 5. Objekt-ID gegen technischen Typnamen

Die numerische `OBJECT ID` ist für eine konkrete Mission und einen konkreten Terrainstand nützlich, darf aber nicht als langfristig stabile ID behandelt werden.

Terrainupdates können Objekt-IDs verändern. Ein dauerhafter Katalogschlüssel soll deshalb mindestens kombinieren:

```text
Terrain
DCS-Build
technischer Typname
hochpräzise Position
Orientierung
Bounding-Box-Abmessungen
optionaler Objektname
```

Für konkrete Missionsziele kann die Editor-ID weiterhin verwendet werden, wenn Mission und Terrainstand feststehen. Für DTC01-Differenzkataloge ist sie nur ein zusätzlicher Laufzeitwert.

## 6. Verhältnis zu DCS-Laufzeitfunktionen

Die Mission-Editor-Anzeige legt nahe, dass technische Modellnamen vorhanden sind. Der P0-Scanner muss prüfen, ob derselbe Wert durch

```lua
object:getTypeName()
```

zurückgegeben wird.

Zusätzlich sollen erfasst werden:

```lua
object:getName()
object:getDesc()
object:getPoint()
object:getPosition()
object:hasAttribute(...)
```

Mögliche Ergebnisse:

```text
A. Editor-NAME == getTypeName()
B. Editor-NAME ist lowercase-normalisierte Variante von getTypeName()
C. getName() liefert nur numerische/technische Instanz-ID
D. Descriptor liefert zusätzliche semantisch brauchbare Attribute
```

Alle Varianten müssen pro Terrain und DCS-Build dokumentiert werden.

## 7. MOOSE-Nutzen

Aktuelle MOOSE-Dokumentation beschreibt einen `SCENERY`-Wrapper, der eine per `Assign as` erzeugte Zone verwenden kann, unter anderem über sinngemäße Funktionen wie:

```lua
SCENERY:FindByZoneName(zoneName)
SCENERY:GetAllProperties()
SCENERY:GetID()
SCENERY:GetName()
```

DTC01 darf diese Funktionen erst einsetzen, nachdem sie gegen den gepinnten Projektstand MOOSE 2.9.18 geprüft wurden.

Vorgesehene Rolle:

- native DCS-API als Wahrheitsquelle;
- MOOSE optional als Komfortlayer für Zone, Suche und Logging;
- kein Verbergen von Abweichungen zwischen Editorwert und DCS-Laufzeitwert.

## 8. Karten-LOD-Testmatrix

DTC01-P0 erhält folgende zusätzliche Tests:

### Test A – Kartenzoom

Dieselbe Referenzfläche wird im Mission Editor bei mehreren Zoomstufen betrachtet und dokumentiert:

```text
weit
mittel
nah
sehr nah
```

Ziel: nur die sichtbaren UI-LOD-Schwellen dokumentieren.

### Test B – Laufzeitscan unabhängig vom F10-Zoom

In einer laufenden Mission wird dieselbe feste Scanbox mehrfach abgefragt, während die F10-Karte unterschiedlich gezoomt ist.

Erwartung:

```text
identische Objektmenge
```

Abweichungen wären ein kritischer Befund.

### Test C – Spieler-/Kameraentfernung

Dieselbe Scanbox wird geprüft:

```text
Spieler direkt vor Ort
Spieler weit entfernt
Kamera/F10-Karte nicht auf Scanfläche
```

Ziel: Streaming- oder Ladereichweitenabhängigkeit erkennen.

### Test D – Editor-gegen-Laufzeit-Identität

Mindestens 20 manuell zugewiesene Referenzobjekte aus mehreren Klassen:

```text
Wohnhaus
größeres Gebäude
Garage
Mauer/Compound
Mast/Leitung
Industrieobjekt
Vegetation
UNKNOWN
```

Für jedes Objekt werden Editor-NAME, OBJECT ID, Laufzeit-TypeName, Laufzeit-Name, Position und Descriptor verglichen.

## 9. Ortsnamen bleiben ein anderer Datenkanal

Technische Scenery-Namen wie `townhouseafghanistan_01` sind Modell-/Objekttypnamen. Sie sind nicht mit Ortslabels wie `Qarabagh` gleichzusetzen.

Daher bleiben getrennt:

```text
Scenery type catalog
= technische Objekt- und Gebäudetypen

Gazetteer
= Ortsnamen, Ortsmittelpunkte und alternative Schreibweisen
```

Die neue Editorbeobachtung verbessert den Scenery-Typkatalog erheblich, liefert aber noch keinen allgemeinen Ortsnamenabruf.

## 10. Angepasste P0-Entscheidung

```text
1. Mission-Editor-LOD wird als visuelle Referenz dokumentiert.
2. Laufzeitinventur darf nicht von der sichtbaren Zoomstufe abgeleitet werden.
3. „Assign as“ wird für einen manuell kuratierten Ground-Truth-Satz verwendet.
4. Editor-OBJECT-ID ist nützlich, aber nicht versionsstabil.
5. Editor-NAME wird gegen getTypeName/getName empirisch geprüft.
6. Der Vollscan bleibt world.searchObjects-basiert.
7. Typkatalog und Ortsnamen-Gazetteer bleiben getrennte Datenprodukte.
8. MOOSE-Scenery-Wrapper werden erst nach Prüfung gegen 2.9.18 verwendet.
```

## 11. Referenzen

- Eagle Dynamics Forum: Rechtsklick auf Scenery-Objekt und `Assign as` erzeugt eine Triggerzone mit Objekt-ID und Typname.
- Eagle Dynamics Forum: Objekt-IDs können sich bei Terrainupdates ändern; Koordinate plus Typname ist robuster.
- MOOSE-Dokumentation: `SCENERY`-Wrapper und Suche über zugewiesene Zonen; Nutzung im Projekt erst nach Prüfung gegen den gepinnten Stand.
