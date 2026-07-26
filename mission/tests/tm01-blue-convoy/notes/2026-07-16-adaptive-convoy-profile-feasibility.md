# Adaptive Konvoiprofile in DCS/MOOSE – Machbarkeit und Laufzeitkosten

Datum: 16. Juli 2026  
Status: Designentscheidung, noch keine Implementierung oder DCS-Abnahme

## Fragestellung

Geprüft wurden:

- Erkennung von Stadt, Dorf und Überlandstrecke;
- dynamische Geschwindigkeitsprofile;
- dynamische Fahrzeugabstände;
- DCS-Wegpunktoption `Formationsintervall`;
- Mehrwert und Grenzen von MOOSE;
- Verhalten im expandierten und im Proxyzustand;
- CPU- und Stabilitätskosten.

## 1. Was DCS direkt kann

### Geschwindigkeit

DCS-Ground-Routen speichern eine Geschwindigkeit pro Wegpunkt. Sie wirkt, wenn `speed_locked` gesetzt ist. MOOSE erzeugt entsprechende Ground-Waypoints über `COORDINATE:WaypointGround(speedKph, formation)`.

Folge: Unterschiedliche Geschwindigkeiten können bereits beim Erzeugen der Reststrecke in die Route eingebaut werden. Dafür ist kein permanentes Umschalten pro Simulationstick erforderlich.

### Formationsintervall

DCS besitzt seit 2.9.6 die Ground-Option `Formation Interval`. MOOSE stellt dafür bereit:

```lua
group:OptionFormationInterval(meters)
```

Der dokumentierte Wertebereich ist 0 bis 100 Meter. Die Mission-Editor-Anzeige kann abhängig vom Einheitensystem Fuß anzeigen; die MOOSE-Funktion erwartet Meter.

Beispielwerte:

```text
20 m  ≈  66 ft
50 m  ≈ 164 ft
60 m  ≈ 197 ft
75 m  ≈ 246 ft
100 m ≈ 328 ft
```

Die Option gilt für `On Road` und `Off Road`. DCS muss praktisch beweisen, wie zuverlässig eine Gruppe den Sollabstand in Kurven, Verkehr und gemischter Fahrzeugzusammensetzung hält.

### ROE, Alarmzustand und Disperse

Diese Optionen sind Controller-Optionen und können mit einem einzelnen `setOption`-Aufruf beziehungsweise über MOOSE-Wrapper gesetzt werden. Ihre Skriptkosten sind vernachlässigbar; die relevante Unsicherheit ist das Verhalten der DCS-AI.

## 2. Was DCS nicht direkt liefert

DCS liefert keine belastbare semantische Abfrage:

```text
Diese Koordinate liegt in einer Stadt.
Diese Koordinate liegt in einem Dorf.
Diese Koordinate liegt auf freier Überlandstrecke.
```

`SceneryObject` stellt Kartenobjekte bereit, aber keine verlässliche Siedlungsfläche oder ein einheitliches Stadt-/Dorfklassifikationsschema. Oberflächentypen unterscheiden unter anderem Straße, Land und Wasser, nicht jedoch Stadt gegen Dorf gegen Freiland.

MOOSE kann Scenery-Objekte in Zonen suchen und stellt eine Towns-Navigationsdatenbank in aktuellen Dokumentationen bereit. Das ist jedoch keine belastbare Gebäudegrundriss- oder Siedlungsgrenzen-Erkennung. Außerdem muss jede Nutzung gegen den gepinnten Projektstand MOOSE 2.9.18 geprüft werden.

## 3. Mögliche Erkennungsmodelle

### A. Autorenseitig klassifizierte Routensegmente – empfohlen

Die Route erhält explizite Profilgrenzen und jedes Segment ein Profil:

```lua
routeProfiles = {
  {
    fromAnchor = "ZONE_TM01_START_BAGRAM",
    toAnchor = "ZONE_TM01_PROFILE_01",
    environment = "URBAN",
    speedKph = 25,
    intervalMeters = 20,
  },
  {
    fromAnchor = "ZONE_TM01_PROFILE_01",
    toAnchor = "ZONE_TM01_PROFILE_02",
    environment = "RURAL",
    speedKph = 45,
    intervalMeters = 60,
  },
}
```

Die Profilpunkte werden beim Missionsstart einmal auf den bereits kompilierten Straßenpfad projiziert. Danach erfolgt die Profilauswahl nur noch über die Routenfortschrittsdistanz.

Kosten:

```text
CPU:                 sehr gering
Mission-Authoring:   gering bis mittel
Zuverlässigkeit:     hoch
Kartenabhängigkeit:  explizit und kontrollierbar
```

### B. Trigger-/Polygonzonen für Siedlungen

MOOSE-Zonen können schnell prüfen, ob die Lead-/Proxykoordinate innerhalb einer markierten Stadt- oder Dorfzone liegt. Für wenige bekannte Siedlungen ist das ebenfalls robust.

Kosten:

```text
CPU:                 gering bei wenigen Zonen
Mission-Authoring:   mittel
Zuverlässigkeit:     hoch innerhalb gepflegter Zonen
```

Nachteile:

- viele Zonen bei langen Routen;
- Übergänge müssen manuell gepflegt werden;
- Siedlungsform und Straßenkorridor können kompliziert sein.

### C. Dynamische Scenery-/Gebäudedichte

Eine bewegliche Zone könnte regelmäßig Kartenobjekte beziehungsweise Gebäude zählen und daraus eine Siedlungsdichte ableiten.

Kosten und Risiken:

```text
CPU:                 mittel bis hoch
Implementierung:     hoch
Zuverlässigkeit:     niedrig bis mittel
Kartenabhängigkeit:  hoch
```

MOOSE warnt selbst, dass Gebäudesuchen in Zonen CPU-intensiv sein können. Objektbezeichnungen und Scenery-Verteilung sind außerdem nicht als stabiles Siedlungsmodell garantiert.

Entscheidung: Nicht für die Produktionslogik verwenden.

### D. MOOSE-Town-Datenbank

Kann gegebenenfalls für eine grobe Nähe zu benannten Orten genutzt werden. Sie ersetzt keine Siedlungsgrenzen und muss für Afghanistan sowie für MOOSE 2.9.18 separat geprüft werden.

Entscheidung: höchstens als Entwicklungs- oder Autorisierungshilfe, nicht als alleinige Laufzeitentscheidung.

## 4. Dynamische Geschwindigkeit

### Empfohlene Umsetzung

Die Geschwindigkeit wird pro Profil bereits beim Aufbau der verbleibenden Route in die Wegpunkte geschrieben.

```text
Route bauen
→ Profilgrenzen als zusätzliche Waypoints aufnehmen
→ jedem Waypoint die Profilgeschwindigkeit geben
→ Route einmal an DCS übergeben
```

Vorteile:

- praktisch keine wiederkehrende Lua-Last;
- funktioniert für expandierte Gruppe und Proxy;
- kein sekündliches Route-Reset;
- DCS kann die Geschwindigkeitswechsel an den Waypoints selbst ausführen.

Nicht empfohlen:

```text
jede Sekunde Geschwindigkeit prüfen
→ Route neu erzeugen
→ Controller.setTask / GROUP:Route erneut aufrufen
```

Die CPU-Kosten wären bei einem einzelnen Konvoi zwar überschaubar. Das größere Risiko ist jedoch DCS-AI-Task-Churn: erneute Routenannahme, kurzes Stoppen, Formationsneubildung oder Wegfindungsänderungen.

## 5. Dynamischer Formationsabstand

`Formation Interval` ist eine Controller-Option und nicht lediglich Spawngeometrie.

Empfohlener Ablauf:

```text
Profilwechsel erkannt
→ nur wenn Sollintervall sich geändert hat
→ group:OptionFormationInterval(newMeters)
→ Änderung loggen
```

Eine Profilauswertung alle zwei bis fünf Sekunden wäre bei wenigen Konvois billig. Noch besser ist die Verwendung des ohnehin bekannten Routenfortschritts. Der Optionsaufruf erfolgt nur am tatsächlichen Segmentwechsel.

Wichtig:

- im Proxyzustand ist das Intervall wirkungslos, weil nur ein Fahrzeug existiert;
- der aktuelle Profilwert muss trotzdem im CampaignState erhalten bleiben;
- beim Unpack wird das aktuelle Intervall auf die neue Survivor-Gruppe angewendet;
- der physische Spawnabstand und das DCS-Formationsintervall sollten zunächst denselben Wert verwenden;
- ein großer Intervallwert verlängert die benötigte Aufstellungsstrecke beim Unpack.

## 6. Kosten im aktuellen TM01C-Controller

TM01C kompiliert den Straßenpfad bereits einmal und speichert pro Sample die kumulierte Routendistanz. `pointAtDistance()` verwendet eine binäre Suche. Das ist eine gute Grundlage für statische Profilgrenzen.

Die bestehende allgemeine `projectToRoute()`-Funktion durchsucht dagegen aktuell alle Routensegmente. Sie sollte nicht zusätzlich jede Sekunde nur für Profilentscheidungen aufgerufen werden.

Empfohlene Optimierung für spätere Profile:

- CampaignState-Routenfortschritt während der Fahrt mit einem lokalen Suchfenster um den zuletzt bekannten Sampleindex aktualisieren;
- alternativ Profilwechsel nur an vorab projizierten Übergangszonen erkennen;
- keine Vollprojektion über den gesamten Bagram–Jalalabad-Pfad pro Tick und Konvoi.

Qualitative Kostenübersicht:

| Funktion | Skript-/CPU-Kosten | DCS-AI-Risiko | Empfehlung |
|---|---:|---:|---|
| Fester ROE/Alarm/Disperse-Satz beim Spawn | sehr gering | niedrig bis mittel | verwenden |
| Fester Formation-Interval-Wert beim Spawn | sehr gering | mittel | separat testen |
| Intervallwechsel nur an Profilgrenzen | sehr gering | mittel | sinnvoll |
| Geschwindigkeiten in Route vorab kodieren | sehr gering | niedrig | bevorzugt |
| Route bei jedem Profil-Poll neu zuweisen | gering bis mittel | hoch | vermeiden |
| Punkt-in-Zone gegen wenige Autorenzonen | gering | niedrig | sinnvoll |
| Scenery-/Gebäudescan während der Fahrt | mittel bis hoch | niedrig, aber unzuverlässig | vermeiden |
| Vollständige Route-Projektion jede Sekunde | wächst mit Routenlänge und Konvoizahl | niedrig | vermeiden |

## 7. Expandiert gegen Proxy

| Eigenschaft | EXPANDED | COLLAPSED_PROXY |
|---|---|---|
| Geschwindigkeit | Profil gilt | dasselbe Profil gilt |
| Formationsintervall | relevant | wirkungslos, aber Zustand speichern |
| ROE/Alarmzustand | relevant | relevant für Proxyfahrzeug |
| Siedlungsprofil | anhand Leadposition | anhand Proxyposition |
| Profilwechsel | Option und ggf. Waypointtempo | nur Waypointtempo; Intervall später anwenden |

## 8. Empfohlene Reihenfolge

### Jetzt: Spielerrelevanz isoliert testen

Unverändert:

```text
speedKph = 30
vehicleSpacingMeters = 15
```

ROE, Alarm und Disperse können als feste Spawnoptionen ergänzt werden, sofern sie in einem kurzen Regressionstest die Bewegung nicht stören.

### Danach: Formation-Interval-Techniktest

Zwei feste Testläufe, noch ohne Stadtlogik:

```text
Lauf 1: 20 m
Lauf 2: 60 m
```

Zu prüfen:

- hält DCS den Abstand auf Geraden und in Kurven;
- wie schnell schließt die Gruppe nach Bremsmanövern auf;
- beeinflusst der Wert Pack/Unpack und Routenaktivierung;
- bleibt die gemischte Gruppe stabil.

### Danach: statisches Zwei-Profil-Modell

```text
URBAN: speed 25–30 km/h, interval 20 m
RURAL: speed 40–45 km/h, interval 60 m
```

Die Grenzen werden autorenseitig gesetzt und beim Start in Routendistanzen übersetzt. Keine laufende Gebäudeerkennung.

## 9. Quellen

- Eagle Dynamics, DCS Scripting Engine, Controller und Routen-/Behavior-Optionen: https://www.digitalcombatsimulator.com/en/support/faq/1267/
- Eagle Dynamics, SceneryObject: https://www.digitalcombatsimulator.com/en/support/faq/1265/
- MOOSE, `CONTROLLABLE:OptionFormationInterval(meters)`: https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Wrapper.Client.html
- MOOSE, Ground-Routen und Geschwindigkeiten: https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Wrapper.Group.html
- MOOSE, Zonen und Scenery-Scans: https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Core.Zone.html

## Entscheidung

Für OMW wird keine automatische Stadt-/Dorferkennung pro Laufzeittick entwickelt. Das Zielmodell ist ein statisch klassifiziertes, bei Missionsstart kompiliertes Routenprofil. Geschwindigkeiten werden in die Route eingebaut; Formationsintervalle werden ausschließlich bei Profilwechseln gesetzt. Dadurch bleiben die CPU-Kosten niedrig und die DCS-AI erhält möglichst wenige neue Tasks.
