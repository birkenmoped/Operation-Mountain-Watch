# TM01 – Blauer Straßenkonvoi Bagram–Jalalabad

## Ziel

TM01 untersucht eine stabil identifizierte blaue Konvoientität zwischen Bagram und Jalalabad.

```text
TM01A
- kontrollierter physischer Spawn
- kontrollierte vollständige Straßenroute

TM01B
- flüchtiger CampaignState im Arbeitsspeicher
- virtuelle Bewegung ohne DCS-Gruppe
- beweglicher virtueller BLUE-Kartenmarker
- automatische Materialisierung in kreisförmigen Reveal-Fenstern
- straßenkonforme Einzelpositionierung aller Fahrzeuge
- automatische Dematerialisierung nach vollständigem Verlassen des Kreises
```

Cargo, Warehouses, Feindkräfte und Persistenz über einen Missions- oder Serverneustart sind nicht Bestandteil von TM01A oder TM01B.

## Testobjekt

```text
Entity-ID: TEST.TM01.CONVOY.001
Route-ID:  ROUTE_TM01_BAGRAM_JALALABAD
Template:  TPL_TEST_BLUE_CONVOY_STANDARD_01
Fahrzeuge: 6
```

DCS-Gruppennamen sind flüchtige Laufzeitdaten. `CampaignState` bleibt die autoritative Quelle für die strategische Entität.

# TM01A – akzeptierte physische Baseline

Die akzeptierte Route lautet:

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

TM01A hat den kontrollierten Spawn, die einmalige Routenzuweisung und die vollständige Ankunft in Jalalabad nachgewiesen. Die lange DCS-Fahrzeit und teilweise großen Umwege bleiben dokumentierte Terrain- und Pathfinding-Einschränkungen.

# TM01B – kreisförmiges Reveal-Window-Caching

## Konfiguration

```text
TM01B-controlled-caching-5
```

Bundle:

```text
mission/tests/tm01-blue-convoy/dist/TM01B.lua
```

Build:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\build-tm01b-bundle.ps1
```

Ladefolge im Mission Editor:

```text
1. DO SCRIPT FILE: vendor/moose/Moose.lua
2. DO SCRIPT FILE: mission/tests/tm01-blue-convoy/dist/TM01B.lua
```

## Bedienmodell

Der reguläre Test besitzt genau einen Startbefehl:

```text
F10
└── OMW Tests
    └── TM01B
        ├── Start convoy
        ├── Show status
        └── Validate configuration
```

`Start convoy` startet den gesamten automatischen Ablauf. Es gibt keine regulären F10-Befehle zum Materialisieren, Dematerialisieren oder Starten einer physischen Teilroute.

## Verbindlicher Ablauf

```text
ZONE_TM01_START_BAGRAM
→ virtuelle Straßenbewegung mit Kartenmarker
→ ZONE_TM01_REVEAL_01
→ automatische straßenkonforme Materialisierung
→ sichtbare Fahrt durch Reveal-Fenster 1
→ alle überlebenden Fahrzeuge außerhalb des Kreises
→ automatische Dematerialisierung
→ virtuelle Straßenbewegung mit Kartenmarker
→ ZONE_TM01_REVEAL_02
→ automatische straßenkonforme Materialisierung
→ sichtbare Fahrt durch Reveal-Fenster 2
→ alle überlebenden Fahrzeuge außerhalb des Kreises
→ automatische Dematerialisierung
→ virtuelle Straßenbewegung
→ ZONE_TM01_TARGET_JALALABAD
```

Während einer virtuellen Phase existiert keine physische DCS-Gruppe.

## Reveal-Fenster im Mission Editor

Version 5 verwendet genau eine kreisförmige Triggerzone pro Fenster:

```text
ZONE_TM01_REVEAL_01
ZONE_TM01_REVEAL_02
```

Der Mittelpunkt und der Radius der jeweiligen Mission-Editor-Zone definieren das vollständige Sichtfenster:

```text
innerhalb des Kreises  = physisch sichtbar
außerhalb des Kreises  = virtuell
```

Separate Entry- und Exit-Zonen werden nicht mehr verwendet. Der Controller berechnet die Eintritts- und Austrittspunkte automatisch aus dem Schnitt des geordneten Straßenpfades mit dem Kreis. Die Fahrtrichtung ist für die Sichtbarkeitsentscheidung irrelevant.

Jeder Kreis muss den globalen Straßenpfad genau einmal in einem zusammenhängenden Abschnitt schneiden. Kein Schnitt oder mehrere getrennte Schnittabschnitte stoppen den Test mit `convoy_route_plan_failed`.

## Globaler Straßenpfad

Start, sieben Routenanker und Ziel werden auf die nächstgelegene Straße projiziert. Zwischen den projizierten Punkten berechnet MOOSE den DCS-Straßenpfad. Dieser Pfad ist die gemeinsame Grundlage für:

- virtuelle Position;
- virtuelle ETA;
- Moving Marker;
- Reveal-Kreis-Schnittpunkte;
- Fahrzeugpositionen beim Spawn;
- lokale Fahrzeug-Headings;
- physische Teilroute.

Konfiguration:

```text
routeSampleMeters                  = 20
physicalWaypointSpacingMeters      = 250
maximumRoadSnapMeters              = 1500
roadPositionToleranceMeters        = 3
```

## Virtueller Moving Marker

Während `VIRTUAL_MOVING` zeigt BLUE einen beweglichen Kartenmarker an der berechneten Position auf dem Straßenpfad. Der Marker enthält:

```text
naechstes Reveal-Fenster oder Ziel
ETA
Fortschritt der aktuellen virtuellen Etappe
```

Aktualisierung:

```text
virtualMarkerUpdateSeconds = 5
```

Während der physischen Darstellung wird der virtuelle Marker entfernt. Zusätzlich wird das Zentrum jedes Reveal-Fensters für BLUE mit ID und Durchmesser markiert.

## Straßenkonformer Spawn

Das Template-Layout wird nicht mehr nur als starre Gruppe an einen Zonenmittelpunkt verschoben. Stattdessen berechnet der Controller für jeden der sechs Template-Slots:

- eine eigene Position auf dem Straßenpfad;
- einen festen Abstand zum vorausfahrenden Fahrzeug;
- ein individuelles Heading aus dem lokalen Straßenverlauf.

Konfiguration:

```text
vehicleSpacingMeters      = 18
spawnInteriorMarginMeters = 12
```

Alle sechs Templatepositionen müssen gleichzeitig innerhalb des aktuellen Reveal-Kreises liegen und die Straßenprüfung bestehen. Danach werden bereits verlorene Slots aus der neuen Generation entfernt.

Ist das Fenster zu klein oder kann keine vollständige Straßenaufstellung validiert werden, erfolgt kein unsicherer Spawn. Die Automation stoppt mit `convoy_spawn_site_unavailable`.

## Dematerialisierung

Nach der Materialisierung bleibt der Konvoi physisch, solange mindestens ein überlebendes Fahrzeug innerhalb des Reveal-Kreises liegt. Sobald der Kreis zuvor belegt war und kein überlebendes Fahrzeug mehr darin liegt, beginnt die automatische Dematerialisierung.

Vor dem Destroy-Aufruf werden die aktuell lebenden Fahrzeugslots in den `CampaignState` übernommen. Erst wenn `Group.getByName(runtimeName):isExist()` die Abwesenheit der Laufzeitgruppe bestätigt, wechselt die Entity wieder auf `VIRTUAL_MOVING`.

Jedes Reveal-Fenster wird pro Missionslauf höchstens einmal ausgeführt.

## Teststatus

Vor dem DCS-Lauf wurden durchgeführt:

- Lua-Parsing aller Version-5-Quellen;
- vollständiger gemockter Bootstrap bis `READY`;
- Kompilierung eines zusammenhängenden Straßenpfades;
- Moving Marker entlang des virtuellen Straßenpfades;
- ein automatischer Lauf durch zwei kreisförmige Reveal-Fenster;
- zwei automatische Materialisierungen;
- zwei automatische Dematerialisierungen;
- sechs absolute Straßenpositionen pro Template-Spawn;
- virtuelle Zielankunft mit `convoy_route_arrived` genau einmal.

Diese Prüfungen ersetzen keinen DCS-Lauf. Ein PASS erfordert weiterhin die getestete `.miz`, DCS-Logs, beide Runtime-Gruppennamen, Verlustübernahme und eine Ergebnisdatei unter `results/`.

## Verbindlicher Testvertrag

```text
expected/caching-acceptance.md
```

## Nicht Bestandteil von TM01B

- Persistenz über Missions- oder Serverneustart;
- Cargo und Warehouses;
- Feindkontakte und Hinterhalte;
- automatische Spielerentfernungs-, Sichtlinien- oder Sensorlogik;
- automatische Recovery oder Routenneuberechnung;
- mehrere gleichzeitige Konvois.
