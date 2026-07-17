# TM01B – kreisförmiges Reveal-Window-Caching

## Status

```text
NICHT BESTANDEN
NICHT ABNAHMEFÄHIG
```

Dieses Dokument beschreibt den verbindlichen Zielvertrag. Es dokumentiert keinen erfolgreichen DCS-Lauf.

Aktueller Zwischenstand:

```text
TM01B-controlled-caching-5.1
```

Bekannte Blocker, Versuchsergebnisse und Vereinbarungen stehen vollständig in:

```text
../notes/2026-07-14-tm01b-handoff.md
```

## Verbindlicher Ablauf

TM01B wird genau einmal über `F10 → OMW Tests → TM01B → Start convoy` gestartet. Danach laufen virtuelle Straßenbewegung, Materialisierung und Dematerialisierung automatisch.

```text
ZONE_TM01_START_BAGRAM
→ virtuelle Straßenbewegung mit BLUE-Kartenmarker
→ ZONE_TM01_REVEAL_01
→ automatische Materialisierung auf validierten Straßenpositionen
→ sichtbare Fahrt durch den Kreis
→ alle überlebenden Fahrzeuge außerhalb des Kreises
→ automatische Dematerialisierung
→ virtuelle Straßenbewegung mit BLUE-Kartenmarker
→ ZONE_TM01_REVEAL_02
→ automatische Materialisierung auf validierten Straßenpositionen
→ sichtbare Fahrt durch den Kreis
→ alle überlebenden Fahrzeuge außerhalb des Kreises
→ automatische Dematerialisierung oder terminale Zielankunft
→ ZONE_TM01_TARGET_JALALABAD
```

Es gibt keine regulären manuellen Befehle zum Materialisieren, Dematerialisieren oder Starten einer physischen Teilroute.

## Autoritative Route

```text
ZONE_TM01_START_BAGRAM
→ ZONE_TM01_ROUTE_01
→ ZONE_TM01_ROUTE_02
→ ZONE_TM01_ROUTE_03
→ ZONE_TM01_ROUTE_04
→ ZONE_TM01_ROUTE_05
→ ZONE_TM01_ROUTE_06
→ ZONE_TM01_ROUTE_07
→ ZONE_TM01_TARGET_JALALABAD
```

Die Mittelpunkte von Start, Ziel und Routenankern werden auf die nächstgelegene Straße projiziert. Zwischen den projizierten Punkten wird ein zusammenhängender Straßenpfad berechnet.

Die Pfadberechnung darf nicht für jedes Fahrzeug separat wiederholt werden. Bekannte Reveal-Fenster werden einmal beim Missionsstart geplant und gecacht.

## Reveal-Fenster

Verbindliche Mission-Editor-Zonen:

```text
ZONE_TM01_REVEAL_01
ZONE_TM01_REVEAL_02
```

Jede Zone ist ein vollständiges kreisförmiges Sichtfenster:

```text
innerhalb des Kreises  = physisch sichtbar
außerhalb des Kreises  = virtuell
```

Separate Entry- und Exit-Zonen werden nicht verwendet. Eintritt und Austritt werden automatisch aus den Schnittpunkten des geordneten Straßenpfades mit dem Kreis bestimmt.

Die Fahrtrichtung ist für die Sichtbarkeitsentscheidung irrelevant.

Jeder Reveal-Kreis muss den globalen Straßenpfad in genau einem zusammenhängenden Abschnitt schneiden. Kein Schnitt oder mehrere getrennte Schnittabschnitte ergeben `convoy_route_plan_failed`.

Ein Textmarker mit Durchmesserangabe ist keine echte F10-Kreisvisualisierung. Wird eine grafische Fensterdarstellung gefordert, muss die Kreisgrenze tatsächlich gezeichnet werden.

## Atomare Materialisierung

Der Konvoi ist eine einzige DCS-Gruppe und wird daher atomar materialisiert. Das Fenster muss groß genug sein, damit alle benötigten Templatepositionen gleichzeitig innerhalb des Kreises auf der Straßenlinie liegen.

Für jeden Template-Slot sind erforderlich:

- finale absolute Position auf der tatsächlich verwendeten Straßenkoordinate;
- individuelles lokales Straßen-Heading;
- konfigurierter Fahrzeugabstand;
- zulässiger Oberflächentyp;
- Wasser ausgeschlossen;
- Position innerhalb des Reveal-Kreises;
- keine Überlappung mit anderen Fahrzeugslots;
- Belegungs- und Sceneryprüfung soweit die DCS-API dies zuverlässig ermöglicht.

`GetClosestPointToRoad()` darf nicht nur als Distanzprüfung verwendet werden. Die zurückgegebene Straßenkoordinate muss die tatsächliche Spawnposition bilden.

Ist der erste Kandidat ungeeignet, muss der Planner innerhalb des Fensters eine begrenzte Anzahl weiterer Kandidaten prüfen. Ist kein gültiger vollständiger Kandidat vorhanden, erfolgt kein Notspawn.

## Laufzeitbudget der Spawnplanung

### Bekannte Fenster

- einmalige Planung beim Missionsstart;
- gecachte Layouts und physische Teilrouten;
- keine Pfadsuche beim tatsächlichen Materialisieren;
- mehrere vorbereitete Recovery-Kandidaten zulässig.

### Dynamische unbekannte Spawns

- Aktivierungsereignis liefert Suchregion;
- maximal begrenzte Kandidatenanzahl;
- höchstens eine lokale Straßenpfadberechnung pro Kandidat;
- keine Pfadberechnung pro Fahrzeug;
- Abbruch beim ersten gültigen Layout;
- keine fortlaufende Suche pro Simulationstick;
- gleichzeitige Planungen bei Bedarf über Scheduler-Zyklen verteilen.

## Virtueller Marker

Während `VIRTUAL_MOVING` ist für BLUE ein beweglicher Kartenmarker sichtbar. Er folgt dem berechneten Straßenpfad und zeigt:

- nächstes Reveal-Fenster beziehungsweise Ziel;
- ETA;
- Fortschritt der aktuellen virtuellen Etappe.

Der Marker wird periodisch aktualisiert und während der physischen Darstellung entfernt.

## Physische Bewegung und Watchdog

Eine erfolgreiche Routenzuweisung reicht nicht als Bewegungsnachweis.

Nach jeder Materialisierung muss ein Watchdog prüfen:

- Gruppe existiert und ist lebendig;
- innerhalb einer Anlaufzeit wird eine Mindeststrecke zurückgelegt;
- die Gruppe verbleibt nicht dauerhaft auf dem Spawnpunkt;
- die Bewegung folgt grundsätzlich dem erwarteten Straßenabschnitt.

Bei Stillstand:

1. aktuelle Generation kontrolliert entfernen;
2. native Entfernung bestätigen;
3. nächsten vorbereiteten Spawnkandidaten versuchen;
4. nach Ausschöpfen der Kandidaten präzise mit Fehler abbrechen.

## Dematerialisierung und Terminal-Window

Nach der Materialisierung gilt:

- Solange mindestens ein überlebendes Fahrzeug im Reveal-Kreis liegt, bleibt der Konvoi physisch.
- Nachdem der Kreis zuvor belegt war und kein überlebendes Fahrzeug mehr darin liegt, beginnt die automatische Dematerialisierung.
- Verluste werden vor `Destroy(false)` übernommen.
- Der Zustand wechselt erst nach nativer Bestätigung über `Group.getByName(...):isExist()` zurück auf `VIRTUAL`.
- Jedes Reveal-Fenster wird pro Missionslauf höchstens einmal ausgeführt.

Für das letzte Reveal-Fenster gilt zusätzlich:

```text
positive Reststrecke bis Ziel
→ virtuelle Restetappe

keine positive Reststrecke
→ unmittelbar ARRIVED
```

Eine Resume-Distanz hinter dem globalen Ziel ist ungültig.

## Abnahmekriterien

1. Eine ausdrücklich benannte Kandidatenversion wird geladen.
2. Bootstrap meldet `READY`.
3. Das F10-Menü enthält nur `Start convoy`, `Show status` und `Validate configuration`.
4. Ein einziger Startbefehl startet den gesamten Ablauf.
5. `convoy_road_route_compiled` bestätigt einen zusammenhängenden Straßenpfad und zwei Fenster.
6. Die einmalige Planung protokolliert Planungsdauer, Kandidatenanzahl und gecachte Layouts.
7. Während jeder virtuellen Etappe bewegt sich der BLUE-Marker entlang der berechneten Straße und zeigt eine sinkende ETA.
8. Jedes Fenster wird durch genau eine kreisförmige Mission-Editor-Zone definiert.
9. Jede Materialisierung erzeugt genau eine physische Generation.
10. Alle Template-Slots werden vor dem Pruning auf den tatsächlich verwendeten finalen Straßenkoordinaten mit individuellen Headings erzeugt.
11. Alle finalen Spawnpositionen liegen innerhalb des aktuellen Reveal-Kreises.
12. Kein Fahrzeug wird auf Wasser oder einem ausgeschlossenen Oberflächentyp erzeugt.
13. Der Bewegungs-Watchdog bestätigt nach jeder Materialisierung eine tatsächliche Bewegung.
14. Der Konvoi bleibt physisch, solange mindestens ein überlebendes Fahrzeug im Kreis ist.
15. Nachdem alle überlebenden Fahrzeuge den Kreis verlassen haben, startet automatisch die Dematerialisierung.
16. Verluste aus Fenster 1 bleiben in Generation 2 erhalten.
17. Zwischen den Fenstern existiert keine versteckte DCS-Gruppe.
18. Nach Fenster 2 erreicht die Entität das Ziel virtuell oder über die Terminal-Window-Regel mit `ARRIVED`.
19. `convoy_route_arrived` wird genau einmal protokolliert.
20. Zu keinem Zeitpunkt existieren zwei physische Generationen gleichzeitig.
21. Ein absichtlich ungeeigneter erster Spawnkandidat wird verworfen und ein gültiger Recovery-Kandidat verwendet.
22. Ein absichtlich festgefahrener Spawn führt innerhalb der Watchdog-Frist zu kontrollierter Recovery oder präzisem Abbruch.

## Bekannte fehlgeschlagene Versuche

### Version 4

- erstes Fenster funktionierte;
- zweites Fenster erzeugte sechs Fahrzeuge;
- zwei hintere Fahrzeuge standen sichtbar im Wasser beziehungsweise Fluss;
- Gruppe bewegte sich nicht;
- Controller blieb ohne Fehler in `PHYSICAL_MOVING`.

### Version 5

```text
convoy_route_plan_failed
planned vehicle position is not on road: ZONE_TM01_REVEAL_01
```

Keine physische Generation wurde erzeugt.

### Version 5.1

```text
convoy_route_plan_failed
reveal window exit is too close to route target: ZONE_TM01_REVEAL_02
```

Keine physische Generation wurde erzeugt.

## Nicht Bestandteil

- Persistenz über Missions- oder Serverneustart;
- Cargo- und Warehouse-Buchungen;
- Feindkontakte als TM01B-Testinhalt;
- mehrere gleichzeitig aktive Konvois als TM01B-Abnahmeszenario.

Die RoadSpawnPlanner-Architektur soll spätere dynamische Aktivierung durch Spieler- oder Feindnähe ermöglichen, ohne diese Aktivierungslogik bereits in TM01B zu implementieren.
