# 17 – TOWNS-Discovery für Afghanistan

## Zweck

Der erste praktische Schritt der Meta-Kartierung ermittelt, welche benannten Siedlungsreferenzen DCS Afghanistan über die terrain-spezifische `towns.lua` bereitstellt und welche Informationen MOOSE daraus ableiten kann.

Der Discovery-Lauf beantwortet zunächst reproduzierbar:

- wie viele Einträge die aktuelle Afghanistan-Version enthält;
- welche Namen und Anzeigenamen vorhanden sind;
- welche Felder die `towns.lua` tatsächlich bereitstellt;
- welche Koordinaten MOOSE daraus erzeugt;
- wie weit jeder Ortsreferenzpunkt vom nächsten Straßen- und Schienenpunkt entfernt liegt;
- ob Namen oder Koordinaten mehrfach vorkommen;
- welcher andere Ortsreferenzpunkt jeweils am nächsten liegt;
- ob alle Einträge gleichzeitig auf der F10-Karte markiert werden können.

Die Daten sind noch keine freigegebenen Kampagnenorte. Sie bilden einen Rohdatenbestand für die spätere semantische Meta-Kartierung.

## Implementierung

Das Entwicklungswerkzeug liegt unter:

```text
src/dev/world-data/towns_discovery.lua
```

Es verwendet die MOOSE-Klasse `TOWNS` und lädt standardmäßig:

```text
Mods\terrains\Afghanistan\Map\towns.lua
```

Die Klasse erzeugt aus jedem Eintrag eine MOOSE-Koordinate sowie einen nächstgelegenen Straßen- und Schienenpunkt. Das Werkzeug ergänzt daraus Statistik, Export und F10-Markierungen.

## Voraussetzungen

- DCS World mit installierter Afghanistan-Karte;
- eine MOOSE-Version, die `Navigation.Towns` enthält;
- eine ausschließlich für Entwicklung vorgesehene Testmission;
- lesender Dateizugriff auf die terrain-spezifische `towns.lua`;
- für den Dateiexport zusätzlich Schreibzugriff über `io` und `lfs`.

`TOWNS:NewFromFile()` verwendet direkten Dateizugriff. Die Mission-Scripting-Umgebung muss daher für diesen Test entsprechend desanitisiert sein. Änderungen an `Scripts\MissionScripting.lua` werden nur in einer kontrollierten Entwicklungsinstallation vorgenommen und nach dem Test wieder zurückgenommen. Produktionsserver und öffentlich verteilte Missionen verwenden diesen Discovery-Zugriff nicht.

## Testmission anlegen

1. Im DCS Mission Editor eine leere Mission auf der Afghanistan-Karte anlegen.
2. Optional einen einzelnen Client-Slot hinzufügen, damit die F10-Karte interaktiv geprüft werden kann.
3. Beim Missionsstart zuerst die aktuelle `Moose.lua` über **DO SCRIPT FILE** laden.
4. Danach `src/dev/world-data/towns_discovery.lua` über einen zweiten **DO SCRIPT FILE**-Trigger laden.
5. Mission starten und `Saved Games\DCS\Logs\dcs.log` prüfen.

Falls die automatische Pfadsuche die Installation nicht findet, wird vor dem Discovery-Skript ein kleiner **DO SCRIPT**-Block eingefügt:

```lua
OMW_TOWNS_DISCOVERY_CONFIG = {
  townsFile = [[C:\Program Files\Eagle Dynamics\DCS World\Mods\terrains\Afghanistan\Map\towns.lua]],
}
```

Für eine Steam-Installation wird der Pfad entsprechend auf deren DCS-Verzeichnis gesetzt.

## Standardverhalten

Beim erfolgreichen Start:

1. wird die `towns.lua` geladen;
2. werden alle Einträge deterministisch nach Anzeigename sortiert;
3. werden Quelldatenfelder und abgeleitete Werte inventarisiert;
4. werden Statistiken und Duplikate berechnet;
5. werden strukturierte Exportdateien geschrieben;
6. werden alle gefundenen Ortsreferenzen auf der F10-Karte markiert;
7. wird ein F10-Menü `OMW World Data` angelegt.

Das Menü enthält:

- `TOWNS: Zusammenfassung`
- `TOWNS: Marker anzeigen`
- `TOWNS: Marker entfernen`

## Konfiguration

Die Konfiguration kann vor dem Laden des Werkzeugs gesetzt werden:

```lua
OMW_TOWNS_DISCOVERY_CONFIG = {
  terrainName = "Afghanistan",
  townsFile = nil,
  outputBaseName = "OMW-Towns-Afghanistan",
  showMarkersOnStart = true,
  createF10Menu = true,
  writeFiles = true,
  logEachTown = true,
  markerLimit = 0,
  markerTextMode = "INDEX_NAME",
  nearestNeighborMaxCount = 2500,
}
```

Wichtige Optionen:

- `townsFile`: absoluter Pfad; `nil` aktiviert die automatische Suche relativ zum DCS-Arbeitsverzeichnis.
- `markerLimit = 0`: keine Begrenzung; alle Einträge werden markiert.
- `markerTextMode = "NAME"`: nur der Anzeigename.
- `markerTextMode = "INDEX_NAME"`: laufende Nummer und Anzeigename.
- `markerTextMode = "FULL"`: zusätzlich Latitude, Longitude und Straßenentfernung.
- `nearestNeighborMaxCount`: Schutzgrenze für die quadratische Nachbarschaftsanalyse.

## Ausgaben

### DCS-Log

Jeder Eintrag wird als maschinenlesbare Zeile protokolliert:

```text
[OMW-TOWNS] TOWN|index=...|name=...|display=...|lat=...|lon=...|road_distance_m=...
```

Damit bleibt der vollständige Rohbestand auch verfügbar, falls der direkte Dateiexport scheitert.

### CSV-Bestand

```text
Saved Games\DCS\Logs\OMW-Towns-Afghanistan.csv
```

Enthalten sind unter anderem:

- interner Name und Anzeigename;
- geographische und DCS-interne Koordinaten;
- Geländehöhe und Oberflächentyp am Referenzpunkt;
- MGRS- und Latitude/Longitude-Darstellung;
- nächster Straßen- und Schienenpunkt;
- Entfernung zu Straße und Schiene;
- nächster anderer Ortsreferenzpunkt und dessen Entfernung.

### Feldinventar

```text
Saved Games\DCS\Logs\OMW-Towns-Afghanistan-fields.csv
```

Das Feldinventar zeigt für jedes in der `towns.lua` beobachtete Quelldatenfeld:

- Feldname;
- Lua-Datentyp;
- Anzahl befüllter Einträge;
- Abdeckungsgrad;
- Beispielwerte.

Dieses Inventar ist entscheidend, weil nicht vorausgesetzt wird, dass Afghanistan dieselbe Struktur wie andere Terrains verwendet.

### Projektfähige Lua-Tabelle

```text
Saved Games\DCS\Logs\OMW-Towns-Afghanistan.lua
```

Die Datei enthält eine deterministisch sortierte Lua-Tabelle mit den Quelldaten. Sie kann nach manueller Prüfung als Ausgangspunkt für eine versionierte Projektdatei dienen. Sie wird nicht ungeprüft in die produktive Kampagnenkonfiguration übernommen.

### Zusammenfassung

```text
Saved Games\DCS\Logs\OMW-Towns-Afghanistan-summary.txt
```

Die Zusammenfassung enthält Gesamtzahl, eindeutige Namen, Duplikate, geographische Ausdehnung, fehlende Werte, Straßen-/Schienendistanzen und das Quelldaten-Feldinventar.

## Auswertung des ersten Laufs

Der erste Lauf gilt als erfolgreich, wenn:

- die Gesamtzahl ohne Lua-Fehler ermittelt wird;
- alle Einträge im Log erscheinen;
- die Marker auf der F10-Karte sichtbar und entfernbar sind;
- CSV-, Lua-, Feldinventar- und Zusammenfassungsdatei geschrieben werden;
- mindestens Name, Latitude und Longitude für den überwiegenden Teil der Einträge vorhanden sind;
- Straßenpunkte für einen plausiblen Anteil der Siedlungen berechnet werden.

Danach werden insbesondere folgende Fragen beantwortet:

1. Deckt `towns.lua` nur große Städte oder auch kleine Dörfer ab?
2. Stimmen die Referenzpunkte sichtbar mit den dargestellten Siedlungen überein?
3. Welche F10-Ortsnamen fehlen in `towns.lua`?
4. Gibt es unterschiedliche Schreibweisen oder doppelte Namen?
5. Sind Straßenpunkte in Städten und Dörfern plausibel gesetzt?
6. Liefert die Schienenprojektion in Afghanistan verwertbare oder irreführende Werte?
7. Reicht der Datenbestand als Grundgerüst für `locations.lua` aus?

## Grenzen

Die Discovery liefert benannte Referenzpunkte, aber weiterhin keine:

- Stadt- oder Dorfgrenzen;
- Bebauungspolygone;
- verlässliche Klassifikation als `CITY`, `TOWN` oder `VILLAGE`;
- Einwohnerzahlen oder Verwaltungszugehörigkeiten;
- Aussage, ob jeder Eintrag militärisch oder spielerisch relevant ist;
- Garantie, dass der nächste Straßenpunkt eine sinnvolle Ortsdurchfahrt darstellt.

Die nächste Stufe kombiniert die exportierten Ortsreferenzen mit manuellen Urban-Polygonen, Scenery-Dichte, Straßenknoten und externer geographischer Validierung.

## Abnahmekriterien

- Ein einziger Missionslauf erzeugt die Gesamtzahl aller von MOOSE geladenen Afghanistan-Ortsreferenzen.
- Jeder Eintrag kann als sichtbarer F10-Marker dargestellt werden.
- Der vollständige Rohbestand wird in `dcs.log` protokolliert.
- CSV-, Lua-, Feldinventar- und Zusammenfassungsdateien werden erzeugt oder ein klarer Fehler wird protokolliert.
- Quelldaten und von MOOSE abgeleitete Werte bleiben im Export unterscheidbar.
- Keine der gewonnenen Ortsreferenzen wird ohne Sichtprüfung automatisch als produktiver Kampagnenort freigegeben.
