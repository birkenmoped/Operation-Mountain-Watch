# TM01M – Vorbereitung des Fünf-Konvoi-Stresstests mit 50 km/h

Datum: 26. Juli 2026  
Status: IMPLEMENTIERT, DCS-REGRESSION AUSSTEHEND

## Ausgangspunkt

Die Einzelkonvoi-Baseline `TM01M-moose-native-msr-pathline-1` wurde in DCS vollständig bestanden. Der Konvoi fuhr mit 30 km/h von Bagram über Kabul nach Jalalabad und erreichte die Zielzone mit allen sechs Fahrzeugen.

Der geplante 40-km/h-Einzelkonvoi-Zwischentest wurde nicht ausgeführt. Stattdessen wird TM01M unmittelbar zu einem größeren Paralleltest mit fünf gleichzeitigen Konvois und 50 km/h erweitert.

## Prüfung der hochgeladenen Missionsdatei

Geprüfte Datei:

```text
OMW_TEST_TM01M_MooseFirst(3).miz
```

Die Missionsdatei enthält alle zehn angegebenen Triggerzonen, alle sechs benötigten internen PATHLINE-Namen und das gemeinsame Template `TPL_TEST_BLUE_CONVOY_STANDARD_01`.

Die eingebettete Datei `l10n/DEFAULT/TM01M.lua` ist jedoch noch veraltet:

```text
configurationVersion = TM01M-moose-native-msr-pathline-1
speedKph = 30
Einzelroute = MSR_EAST_E03 + MSR_EAST_E02
```

Vor dem DCS-Test muss deshalb das neu gebaute Bundle im Mission Editor erneut ausgewählt und die Mission gespeichert werden.

## Verifizierte Mission-Editor-Objekte

### PATHLINEs

```text
MSR_EAST_E03   100 Punkte
MSR_EAST_E02   541 Punkte
MSR_EAST_E01    99 Punkte
MSR_KUNAR_K01  367 Punkte
MSR_CAL_C01    273 Punkte
MSR_CAL_C02    238 Punkte
```

Gesamt:

```text
6 PATHLINEs
1618 Quellpunkte
```

Die Missionsdatei enthält zusätzlich sichtbare Textbeschriftungen wie `MSR EAST-E3 — Kabul–Bagram`. Diese Textobjekte sind nicht die PATHLINE-Namen und dürfen nicht an `PATHLINE:FindByName()` übergeben werden.

### Zonen

Alle zehn Zonen besitzen in der geprüften Mission einen Radius von `182,88 m`:

```text
MSR_EAST_E3_START_BAGRAM
MSR_EAST_E3_TARGET_KABUL
MSR_EAST_E2_START_KABUL
MSR_EAST_E2_TARGET_JALALABAD
MSR_EAST_E1_START_TORKHAM
MSR_EAST_E1_TARGET_JALALABAD
MSR_KUNAR K1_START_JALALABAD
MSR_KUNAR K1_TARGET_ASADABAD
MSR_CALIFORNIA_START_ASADABAD
MSR_CALIFORNIA_TARGET_FOB_BOSTIK
```

## Geometrische Besonderheiten

### Jalalabad

```text
Abstand EAST-E2-Ziel ↔ EAST-E1-Ziel:   ca. 6 m
Abstand EAST-E2-Ziel ↔ KUNAR-K1-Start: ca. 66 m
Abstand EAST-E1-Ziel ↔ KUNAR-K1-Start: ca. 72 m
```

Die drei Zonen überlappen stark. Der KUNAR-K1-Konvoi startet dort sofort und sollte den Bereich lange vor der späteren Ankunft der EAST-E1- und EAST-E2-Konvois verlassen. Trotzdem ist dieser Bereich ein verbindlicher Beobachtungspunkt für gegenseitige Blockaden.

### Asadabad

```text
Abstand KUNAR-K1-Ziel ↔ CALIFORNIA-Start: ca. 111 m
```

Beide Zonen überlappen. Der CALIFORNIA-Konvoi startet sofort in Richtung FOB Bostik; der KUNAR-K1-Konvoi trifft später ein.

### Kabul

```text
Abstand EAST-E3-Ziel ↔ EAST-E2-Start: ca. 492 m
```

Bei jeweils `182,88 m` Radius überlappen diese beiden Zonen nicht.

## PATHLINE-Richtungen

Die automatische MOOSE-orientierte Verwendung muss ergeben:

```text
MSR_EAST_E03   reversed  Bagram → Kabul
MSR_EAST_E02   reversed  Kabul → Jalalabad
MSR_EAST_E01   forward   Torkham → Jalalabad
MSR_KUNAR_K01  forward   Jalalabad → Asadabad
MSR_CAL_C01    forward   Asadabad → Asmar
MSR_CAL_C02    forward   Asmar → Naray / FOB Bostik
```

`MSR_CAL_C01` und `MSR_CAL_C02` besitzen in der Missionsdatei einen gemeinsamen End-/Startpunkt. Der geometrische Abstand beträgt praktisch `0 m`; der konfigurierte maximale PATHLINE-Anschlussabstand von 250 m wird damit eingehalten.

## MOOSE-First-Entscheidung

Für mehrere parallele Verbände ist keine eigene DCS-Gruppenerzeugung und keine eigene Wegfindungs-API erforderlich.

Verwendet werden:

- ein gemeinsames Mission-Editor-Template;
- fünf unabhängige `SPAWN:NewWithAlias()`-Instanzen;
- je Verband `SPAWN:InitSetUnitAbsolutePositions()` und `SPAWN:Spawn()`;
- je Route MOOSE-`PATHLINE` und `COORDINATE`;
- je Verband genau eine Zuweisung über `GROUP:Route()`;
- ein gemeinsamer MOOSE-`SCHEDULER` zur Überwachung aller fünf Verbände.

Projekteigene Logik beschränkt sich auf Konfigurationsverwaltung, Routenverkettung, Distanzinterpolation, Validierung, eindeutige Zustandsführung und Diagnostik.

## Neue Konfiguration

```text
TM01M-moose-native-five-convoys-1
```

Gemeinsame Parameter:

```text
speedKph:                        50
formation:                       On Road
waypointSpacingMeters:           2500
vehicleSpacingMeters:            18
minimumVehicleSeparationMeters:  8
maximumZoneRoadSnapMeters:       175
maximumSpawnRoadSnapMeters:      30
maximumPathlineJoinMeters:       250
maximumWaypointRoadSnapMeters:   250
```

## Laufzeitsteuerung

Der neue F10-Hauptbefehl lautet:

```text
Launch all five convoys
```

Er erzeugt alle fünf Verbände aus demselben Template und weist anschließend allen Gruppen ihre jeweilige Route zu.

Zusätzliche Sammelbefehle:

```text
Spawn all convoys
Start all MSR routes
Show fleet status
```

Für Fehlersuche stehen außerdem Einzelmenüs pro Konvoi zur Verfügung.

## Diagnostik

Jedes Einzelereignis enthält eine stabile Konvoi-ID:

```text
convoyId=EAST_E3_BGR_KBL
convoyId=EAST_E2_KBL_JBAD
convoyId=EAST_E1_TRK_JBAD
convoyId=KUNAR_K1_JBAD_ASAD
convoyId=CAL_ASAD_BOSTIK
```

Neue Sammelereignisse:

```text
multi_convoy_route_plans_compiled
multi_convoy_spawn_completed
multi_convoy_routes_started
multi_convoy_launch_completed
all_convoys_arrived
```

## Statische Verifikation

Der Harness prüft:

- genau fünf konfigurierte Konvois;
- 50 km/h für jeden erzeugten Wegpunkt;
- Nutzung eines gemeinsamen Templates mit fünf eindeutigen Laufzeitaliasen;
- fünf unabhängige Routenpläne;
- korrekte automatische Richtung für reversed und forward PATHLINEs;
- Verkettung der zwei CALIFORNIA-PATHLINEs;
- 30 individuelle absolute Spawnpositionen;
- genau einen gemeinsamen MOOSE-Scheduler;
- fünf Spawn-, Routenstart- und Ankunftsereignisse;
- genau ein aggregiertes `all_convoys_arrived`;
- Ausschluss der alten Proxy-, Timer-, Teleport- und `TaskGroundOnRoad()`-Architektur.

## Noch nicht bewiesen

- tatsächliche Straßensnap-Werte aller zehn Zonen;
- kollisionsfreier Spawn aller 30 konkreten Fahrzeuge;
- dauerhafte Verbandsstabilität bei 50 km/h;
- gleichzeitige DCS-Ground-AI-Wegfindung auf fünf Routen;
- störungsfreie Kreuzungs- und Zielbereichsnutzung in Jalalabad und Asadabad;
- vollständige Ankunft aller 30 Fahrzeuge;
- Multiplayer-Synchronisierung.

Diese Punkte müssen im nächsten DCS-Lauf belegt werden.
