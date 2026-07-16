# DTC01 – konsolidierter Befund und vorläufige Projektpause

Datum: 17. Juli 2026  
Status: dokumentierter Zwischenstand; Implementierung pausiert zugunsten des TM01C-Konvoi-Tests

## 1. Zweck dieses Eintrags

Dieser Eintrag schließt die aktuelle Konzept- und Beobachtungsrunde zum Nebenprojekt **DTC01 – DCS Terrain Cartographer** ab. Er ersetzt keine der ausführlichen Grundlagen, sondern hält den nun bestätigten Arbeitsstand und die Trennung der Datenkanäle fest.

Referenzdokumente:

- `tools/dcs-terrain-cartographer/README.md`
- `tools/dcs-terrain-cartographer/notes/2026-07-16-execution-density-and-place-labels.md`
- `tools/dcs-terrain-cartographer/notes/2026-07-16-map-lod-and-scenery-assignment.md`

## 2. Bestätigte Editorbeobachtungen

### 2.1 Karten-LOD

Die Afghanistan-Karte im Mission Editor zeigt abhängig von der Zoomstufe unterschiedliche Detail-Layer. Beim Hineinzoomen werden unter anderem sichtbar:

- einzelne Gebäudegrundrisse;
- Mauern und Compound-Strukturen;
- Vegetation;
- kleinere Straßen und Wege;
- Stromleitungen und Strommasten;
- weitere Infrastrukturdetails.

Diese Beobachtung belegt eine **Darstellungs-LOD des Kartenrenderers**. Sie belegt noch nicht, dass die Mission-Scripting-API dieselben Layer direkt auslesen kann.

Verbindliche Trennung:

```text
Mission-Editor-Karten-LOD
!= 3D-Terrain-Streaming
!= Objektverfügbarkeit über world.searchObjects
```

DTC01 muss deshalb dieselbe Scanfläche bei verschiedenen Karten-Zoomstufen und Spielerentfernungen wiederholt erfassen und die Objektlisten vergleichen.

### 2.2 Scenery-Zuweisung im Mission Editor

Der Mission Editor kann ein ausgewähltes Terrainobjekt über die Scenery-/Triggerzonen-Zuweisung referenzieren. Dabei werden mindestens folgende Werte sichtbar:

```text
OBJECT ID
NAME / technischer Modell- oder Scenery-Typname
```

Beobachtete Beispiele aus Qarabagh:

```text
townhouseafghanistan_01
part...afghanistan_03
part...afghanistan_06
partgarage_03
mitsubishicolt
```

Diese Werte sind technische Objektinformationen. Sie sind nicht mit Ortsnamen wie `Qarabagh` gleichzusetzen.

## 3. Konsequenz für den DTC01-Typkatalog

Die Editorfunktion ist ein wertvoller manueller Kalibrierungs- und Ground-Truth-Kanal:

```text
Objekt im Editor auswählen
→ technischen Namen und OBJECT ID erfassen
→ Objekt visuell klassifizieren
→ dieselbe Umgebung in der laufenden Scanmission erfassen
→ Editorwerte mit getName/getTypeName/getDesc vergleichen
```

Dadurch muss die semantische Typisierung nicht vollständig blind aus Laufzeitdaten erfolgen.

Empfohlene erste Referenzklassen:

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

Unbekannte Typen bleiben `UNKNOWN`.

## 4. Objektidentität

Die Editor-`OBJECT ID` ist nützlich, darf aber nicht als alleinige dauerhafte Identität verwendet werden. Terrain- oder DCS-Updates können IDs verändern.

Vorgeschlagene Katalogidentität:

```text
Terrain
+ DCS-Build
+ technischer Typname
+ präzise Position
+ Orientierung
+ Bounding-Box-Abmessungen
+ optionale OBJECT ID
```

## 5. Bebauungs- und Siedlungsklassifikation

Die grundlegende Hypothese bleibt gültig: Stadt, Dorf, Streusiedlung und unbebautes Gelände können aus bestätigten Gebäudeobjekten pro Fläche abgeleitet werden.

Nicht nur rohe Objektzahl verwenden, sondern mindestens:

- bestätigte Gebäudezahl;
- Gebäude pro Quadratkilometer;
- geschätzte Gebäudegrundfläche;
- bebaute Flächenquote;
- mittleren nächsten Gebäudeabstand;
- Größe zusammenhängender Cluster;
- Industrie-/Sonderobjektanteil;
- Zahl unbekannter Strukturen.

Such- und Analyseraster bleiben getrennt:

```text
DCS-Suchraster:        etwa 1.000 m × 1.000 m
Offline-Analyseraster: 100 m oder 250 m
```

## 6. Ortsnamen

Die sichtbaren Ortsbeschriftungen wie `Qarabagh` gehören wahrscheinlich zu einem Karten-/Terrainlabel-Layer. Die technische Scenery-Zuweisung beweist keinen allgemeinen Zugriff auf diese Ortslabels.

Drei getrennte Datenkanäle:

```text
Scenery-Typname: townhouseafghanistan_01
Scenery-Instanz: OBJECT ID + Position
Ortsname:        Qarabagh
```

DTC01-P0 muss bekannte Ortszentren gezielt scannen und prüfen, ob Ortsnamen in `getName`, `getTypeName`, Descriptoren oder besonderen Scenery-Objekten erscheinen.

Falls kein reproduzierbarer API-Nachweis gelingt, wird ein getrennt versionierter Gazetteer verwendet. OCR, UI-Pixelanalyse und proprietäres Terrain-Dateiparsing sind keine Produktionsabhängigkeiten.

## 7. Ausführungskontext

Der eigentliche Crawler läuft in einer **gestarteten dedizierten DCS-Mission**. Der Mission Editor dient nur zum Anlegen von Referenzzonen, Startparametern und Skripttriggern.

```text
Mission Editor konfigurieren
→ Mission starten
→ world.searchObjects in der Mission Scripting Environment ausführen
→ Rohdaten exportieren
→ offline normalisieren und klassifizieren
```

Die normale OMW-Kampagne führt keinen Vollscan durch. Sie konsumiert später ausschließlich verdichtete, versionierte Terrain- und Routenprofile.

## 8. Nächste DTC01-Phase nach Wiederaufnahme

DTC01-P0 beginnt mit wenigen Referenzflächen und manuell zugewiesenen Referenzobjekten:

1. dichtes Stadtgebiet;
2. Stadtrand;
3. Dorf;
4. Streusiedlung;
5. unbebautes Gebiet;
6. Industrie-/Infrastrukturgebiet.

Kritische Nachweise:

- Reproduzierbarkeit derselben Zelle;
- Unabhängigkeit vom Kartenzoom;
- Abhängigkeit oder Unabhängigkeit von Spielerentfernung/Streaming;
- Editor-NAME gegen Laufzeit-`getTypeName`/`getName`;
- Erkennbarkeit von Häusern, Masten, Leitungen und mindestens einer Infrastrukturklasse;
- belastbare Deduplizierung;
- kontrollierte Laufzeit ohne lange Lua-Blockade.

## 9. Projektentscheidung

```text
1. DTC01 bleibt als Huckepack-Nebenprojekt an OMW angegliedert.
2. Alle bisher gewonnenen Erkenntnisse sind dokumentiert.
3. Es wird jetzt keine Scanner-Implementierung begonnen.
4. Der aktive Entwicklungsfokus wechselt zurück zu TM01C.
5. Nächster Konvoi-Schritt ist automatische BLUE-Spielerrelevanz für Pack/Unpack.
6. DTC01 wird später mit P0 und kleinen Referenzflächen fortgesetzt.
```
