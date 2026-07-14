# TM01B – kreisförmiges Reveal-Window-Caching

## Verbindlicher Ablauf

TM01B wird genau einmal über `F10 → OMW Tests → TM01B → Start convoy` gestartet. Danach laufen virtuelle Straßenbewegung, Materialisierung und Dematerialisierung automatisch.

```text
ZONE_TM01_START_BAGRAM
→ virtuelle Straßenbewegung mit BLUE-Kartenmarker
→ ZONE_TM01_REVEAL_01
→ automatische Materialisierung auf der Straße
→ sichtbare Fahrt durch den Kreis
→ alle überlebenden Fahrzeuge außerhalb des Kreises
→ automatische Dematerialisierung
→ virtuelle Straßenbewegung mit BLUE-Kartenmarker
→ ZONE_TM01_REVEAL_02
→ automatische Materialisierung auf der Straße
→ sichtbare Fahrt durch den Kreis
→ alle überlebenden Fahrzeuge außerhalb des Kreises
→ automatische Dematerialisierung
→ virtuelle Straßenbewegung
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

Die Mittelpunkte von Start, Ziel und Routenankern werden auf die nächstgelegene Straße projiziert. Zwischen den projizierten Punkten wird ein zusammenhängender Straßenpfad berechnet und in höchstens 20 Meter lange Abschnitte unterteilt.

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

Separate Entry- und Exit-Zonen werden nicht mehr verwendet. Eintritt und Austritt werden automatisch aus den Schnittpunkten des geordneten Straßenpfades mit dem Kreis bestimmt.

Jeder Reveal-Kreis muss den globalen Straßenpfad in genau einem zusammenhängenden Abschnitt schneiden. Kein Schnitt oder mehrere getrennte Schnittabschnitte ergeben `convoy_route_plan_failed`.

## Atomare Materialisierung

Der Konvoi ist eine einzige DCS-Gruppe und wird daher atomar materialisiert. Das Fenster muss groß genug sein, damit alle sechs Templatepositionen gleichzeitig innerhalb des Kreises auf der Straßenlinie liegen.

Konfiguration:

```text
vehicleSpacingMeters      = 18
spawnInteriorMarginMeters = 12
```

Der Controller setzt für jeden Template-Slot eine eigene absolute Position und ein eigenes lokales Straßen-Heading. Vor dem Spawn wird jede Position erneut gegen die nächstgelegene Straße geprüft. Ist keine gültige vollständige Aufstellung möglich, erfolgt kein Notspawn; die Automation stoppt mit `convoy_spawn_site_unavailable`.

## Virtueller Marker

Während `VIRTUAL_MOVING` ist für BLUE ein beweglicher Kartenmarker sichtbar. Er folgt dem berechneten Straßenpfad und zeigt:

- nächstes Reveal-Fenster beziehungsweise Ziel;
- ETA;
- Fortschritt der aktuellen virtuellen Etappe.

Der Marker wird alle fünf Sekunden aktualisiert und während der physischen Darstellung entfernt. Zusätzlich erhält jedes Reveal-Fenster einen BLUE-Marker am Zonenmittelpunkt mit dem konfigurierten Durchmesser.

## Dematerialisierung

Nach der Materialisierung gilt:

- Solange mindestens ein überlebendes Fahrzeug im Reveal-Kreis liegt, bleibt der Konvoi physisch.
- Nachdem der Kreis zuvor belegt war und kein überlebendes Fahrzeug mehr darin liegt, beginnt die automatische Dematerialisierung.
- Die Fahrtrichtung ist für diese Sichtbarkeitsentscheidung irrelevant.
- Verluste werden vor `Destroy(false)` übernommen.
- Der Zustand wechselt erst nach nativer Bestätigung über `Group.getByName(...):isExist()` zurück auf `VIRTUAL`.
- Jedes Reveal-Fenster wird pro Missionslauf höchstens einmal ausgeführt.

## Abnahmekriterien

1. Konfigurationsversion `TM01B-controlled-caching-5` wird geladen.
2. Bootstrap meldet `READY`.
3. Das F10-Menü enthält nur `Start convoy`, `Show status` und `Validate configuration`.
4. Ein einziger Startbefehl startet den gesamten Ablauf.
5. `convoy_road_route_compiled` bestätigt einen zusammenhängenden Straßenpfad und zwei Fenster.
6. Während jeder virtuellen Etappe bewegt sich der BLUE-Marker entlang der berechneten Straße und zeigt eine sinkende ETA.
7. Jedes Fenster wird durch genau eine kreisförmige Mission-Editor-Zone definiert.
8. Jede Materialisierung erzeugt genau eine physische Generation.
9. Alle sechs Template-Slots werden vor dem Pruning auf validierten Straßenpositionen mit individuellen Headings erzeugt.
10. Alle erzeugten Templatepositionen liegen beim Spawn innerhalb des aktuellen Reveal-Kreises.
11. Der Konvoi bleibt physisch, solange mindestens ein überlebendes Fahrzeug im Kreis ist.
12. Nachdem alle überlebenden Fahrzeuge den Kreis verlassen haben, startet automatisch die Dematerialisierung.
13. Verluste aus Fenster 1 bleiben in Generation 2 erhalten.
14. Zwischen den Fenstern existiert keine versteckte DCS-Gruppe.
15. Nach Fenster 2 erreicht die Entität das Ziel virtuell mit `ARRIVED`.
16. `convoy_route_arrived` wird genau einmal protokolliert.
17. Zu keinem Zeitpunkt existieren zwei physische Generationen gleichzeitig.

## Nicht Bestandteil

- Persistenz über Missions- oder Serverneustart;
- Cargo- und Warehouse-Buchungen;
- Feindkontakte;
- automatische Spielerentfernungs-, Sichtlinien- oder Sensorlogik;
- automatische Recovery oder Routenneuberechnung;
- mehrere gleichzeitige Konvois.
