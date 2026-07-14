# TM01 – Blauer Straßenkonvoi Bagram–Jalalabad

## Ziel

TM01 untersucht die technische Führung einer stabil identifizierten blauen Konvoientität zwischen Bagram und Jalalabad.

Die Testreihe trennt drei Ebenen:

```text
TM01A
- kontrollierter physischer Spawn
- kontrollierte physische Straßenroute

TM01B
- flüchtiger CampaignState im Arbeitsspeicher
- kontrollierte Dematerialisierung
- virtuelle Repräsentation ohne DCS-Gruppe
- kontrollierte Materialisierung

spätere Persistenzstufe
- Snapshot und Backup
- Wiederherstellung nach Missions- oder Serverneustart
```

Cargo Units, Ladung, Warehouses, Feindkräfte und dauerhafte CampaignState-Persistenz sind nicht Bestandteil von TM01A oder TM01B.

Die Strecke Bagram–Jalalabad bleibt eine technische Stress- und Regressionsteststrecke. Sie ist keine reguläre Produktionslogistikroute.

## Testobjekt

Mission-Editor-Template:

```text
TPL_TEST_BLUE_CONVOY_STANDARD_01
```

Zusammensetzung:

```text
1. vordere Sicherung
2. zweite Sicherung
3. schwerer Transport-Lkw
4. schwerer Transport-Lkw
5. Führungs-, Berge- oder Sicherungsfahrzeug
6. rückwärtige Sicherung
```

Die Fahrzeuge führen in TM01 noch keine Cargo-Manifeste. Die Zusammensetzung prüft Gruppenführung, Reihenfolge, Engstellen, Verlustübernahme und Rekonstruktion.

## Stabile Identitäten

```text
Test-ID:             TM01
Entity-ID:           TEST.TM01.CONVOY.001
Route-ID:            ROUTE_TM01_BAGRAM_JALALABAD
Template:            TPL_TEST_BLUE_CONVOY_STANDARD_01
```

DCS-Runtime-Namen sind flüchtige Repräsentationsdaten und nicht die Identität der strategischen Entität.

## Gemeinsame Komponenten

```text
TM01 bootstrap
├── RuntimeGuard
├── ConfigurationValidator
├── StructuredLogger
└── TestMenu

physische Repräsentation
├── PhysicalConvoyController
└── ConvoyRouteController

TM01B zusätzlich
├── InMemoryCampaignState
└── ConvoyCacheController
```

Ein Watchdog, automatisches Unstuck, Reset, Stop oder automatische Routenneuberechnung ist im akzeptierten TM01A-Stand nicht implementiert.

# TM01A – physische Baseline

Missionsdatei:

```text
TM01A-MOOSE-Blue-Convoy-Physical.miz
```

Bundle:

```text
mission/tests/tm01-blue-convoy/dist/TM01A.lua
```

Build:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\build-test-bundle.ps1
```

Ladefolge im Mission Editor:

```text
1. DO SCRIPT FILE: vendor/moose/Moose.lua
2. DO SCRIPT FILE: mission/tests/tm01-blue-convoy/dist/TM01A.lua
```

## TM01A-Bootstrap – akzeptiert

Der Bootstrap:

- prüft beim Build die SHA-256-Prüfsumme von `vendor/moose/Moose.lua` gegen `vendor/moose/VERSION.md`;
- meldet erwartete MOOSE-Provenienz und Konfigurationsversion;
- prüft die benötigten nativen DCS- und MOOSE-APIs;
- prüft Template, Startzone, Zielzone und sieben Routenanker;
- benötigt keine TM01B-Reveal-Zonen;
- meldet `READY`, `FAIL_CONFIGURATION` oder `FAIL_SCRIPT`;
- stellt `Show status` und `Validate configuration` bereit.

`mooseVerificationMode=BUILD_HASH_PLUS_RUNTIME_API_CHECK` bezeichnet getrennte Prüfungen:

- abweichender lokaler Vendor-Hash verhindert den Bundle-Build;
- fehlende Laufzeit-APIs ergeben `FAIL_SCRIPT`;
- fehlende Pflichtobjekte ergeben `FAIL_CONFIGURATION`;
- die tatsächlich geladene MOOSE-Provenienz wird zusätzlich manuell über das MOOSE-Log-Banner bestätigt.

Ergebnis:

```text
PASS
```

## Kontrollierter physischer Spawn – akzeptiert

F10-Befehle:

```text
Spawn convoy
Show convoy status
```

Verwendete Identitäten:

```text
Logische Entity-ID:      TEST.TM01.CONVOY.001
Mission-Editor-Template: TPL_TEST_BLUE_CONVOY_STANDARD_01
Angeforderter Alias:     TM01A_BLUE_CONVOY_001
Spawnzone:               ZONE_TM01_START_BAGRAM
```

Nachgewiesen wurde:

- Bootstrap `READY`;
- genau ein ausgeführter Spawn;
- sechs erwartete und sechs tatsächliche Fahrzeuge;
- tatsächlicher Runtime-Name `TM01A_BLUE_CONVOY_001#001`;
- vollständige Mitgliedschaft in der Startzone;
- das Late-Activation-Template blieb inaktiv;
- ein zweiter Spawnbefehl erzeugte keine zweite Gruppe;
- die Gruppe blieb vor der Routenzuweisung stationär.

Ergebnis:

```text
PASS
```

Nachweis:

```text
results/2026-07-13-tm01a-physical-spawn.md
```

## Kontrolliertes Straßenrouting – akzeptiert

F10-Befehle:

```text
Start convoy route
Show route status
```

Konfiguration:

```text
Start:                    ZONE_TM01_START_BAGRAM
Routenanker:              ZONE_TM01_ROUTE_01 bis _07
Ziel:                     ZONE_TM01_TARGET_JALALABAD
Gesamtzahl Wegpunkte:     8
Geschwindigkeit:          30 km/h
Formation:                ON_ROAD → DCS "On Road"
```

Der Controller erzeugt alle Wegpunkte vollständig und weist die Route genau einmal zu. Es gibt keinen Scheduler, keine automatische Statusabfrage, keine Routenneuberechnung und keinen Skripteingriff in die DCS-Wegfindung.

Verifizierte MOOSE-APIs aus Release 2.9.18:

- `ZONE_BASE:GetCoordinate`;
- `COORDINATE:WaypointGround`;
- `CONTROLLABLE:Route`.

`WaypointGround` erwartet km/h und konvertiert intern nach m/s. `CONTROLLABLE:Route(route, 0)` setzt die Aufgabe unmittelbar.

Nachgewiesen wurde:

- Route startete nur nach dem F10-Befehl;
- Status während der Fahrt `EN_ROUTE`;
- `routeAssigned=true`;
- alle sechs Fahrzeuge blieben erhalten;
- vollständige Ankunft in der Jalalabad-Zielzone;
- Endstatus `ARRIVED`;
- `convoy_route_arrived` exakt einmal;
- wiederholte Statusabfragen erzeugten kein zweites Arrival-Ereignis;
- Duplikatschutz des Routenbefehls wurde durch Operatorbeobachtung bestätigt.

Gemessene simulierte Fahrzeit ab Routenzuweisung:

```text
25756.685 Sekunden
≈ 7 Stunden 9 Minuten
```

Ergebnis:

```text
PASS
```

Nachweis:

```text
results/2026-07-13-tm01a-road-routing.md
```

## DCS-Routenlimit

Der vollständige physische Gesamtlauf ist abgeschlossen. Die bestehenden sieben Anker und die Zielzone reichen nachweislich aus, damit DCS den Konvoi bis Jalalabad führt.

DCS wählte zwischen den Ankern jedoch erhebliche Umwege gegenüber der optisch direkten Strecke. Das ist kein offener Controllerfehler und kein fehlender Gesamtroutentest. Es ist eine dokumentierte Grenze des Terrain-Straßengraphen beziehungsweise der vorhandenen groben Routendaten.

Die Bagram–Jalalabad-Anker dürfen für spätere Regressionen verfeinert werden. Diese Verfeinerung ist keine Voraussetzung für den ersten kontrollierten Cache-Zyklus.

# TM01B – kontrolliertes Caching

Missionsdatei:

```text
TM01B-MOOSE-Blue-Convoy-Virtualized.miz
```

Verbindlicher Testvertrag:

```text
expected/caching-acceptance.md
```

## Ziel der ersten Stufe

TM01B.1 prüft einen kontrollierten Cache-Zyklus innerhalb derselben laufenden Mission:

```text
MATERIALIZING
→ PHYSICAL_MOVING
→ DEMATERIALIZING
→ VIRTUAL_MOVING
→ MATERIALIZING
→ PHYSICAL_MOVING
→ ARRIVED
```

Der strategische Zustand bleibt ausschließlich im Arbeitsspeicher. Ein Missions- oder Serverneustart darf den Testzustand verlieren.

Caching bedeutet ausdrücklich nicht, dass eine unsichtbare DCS-Gruppe weiterfährt. Während `VIRTUAL_MOVING` existiert keine physische Gruppe.

## Reveal- und Übergangszonen

Zusätzliche Pflichtzonen:

```text
ZONE_TM01_REVEAL_01_ENTRY
ZONE_TM01_REVEAL_01_EXIT
ZONE_TM01_REVEAL_02_ENTRY
ZONE_TM01_REVEAL_02_EXIT
```

Entry-Zonen dienen als validierte Materialisierungsanker. Exit-Zonen dienen als kontrollierte Dematerialisierungsbereiche.

Die erste Stufe darf den virtuellen Übergang zwischen den Reveal-Abschnitten manuell über F10 auslösen. Automatische zeitbasierte Bewegung, Spielererkennung, Sichtlinie und Sensorlogik folgen erst nach einem bestandenen kontrollierten Cache-Zyklus.

## Autoritativer In-Memory-Zustand

Mindestens erforderlich:

```lua
{
  entityId = "TEST.TM01.CONVOY.001",
  representationState = "VIRTUAL",
  movementState = "VIRTUAL_MOVING",
  routeId = "ROUTE_TM01_BAGRAM_JALALABAD",
  segmentIndex = 1,
  segmentProgress = 0,
  routeDistanceMeters = 0,
  configuredSpeedKph = 30,
  effectiveSpeedKph = 23,
  lastMovementUpdateCampaignTime = 0,
  survivingVehicleSlots = { 1, 2, 3, 4, 5, 6 },
  physicalGeneration = 0,
}
```

Eine Entität darf nie gleichzeitig `VIRTUAL` und `PHYSICAL` sein.

## Offene Mission-Editor-Arbeit

Noch offen sind ausschließlich TM01B-spezifische Arbeiten:

- vier Reveal-Zonen auf geeigneten Straßenabschnitten platzieren;
- Entry-Zonen als sichere Materialisierungsanker prüfen;
- Exit-Zonen so platzieren, dass die vollständige Gruppe dort zuverlässig erkannt werden kann;
- Beobachter- oder Debugslots für beide Abschnitte anlegen;
- eine Kopie der akzeptierten TM01A-Mission als TM01B-Mission vorbereiten;
- das TM01B-Bundle nach der Implementierung als zweite Skriptdatei einbinden.

Nicht mehr offen sind:

- die physische Gesamtstrecke Bagram–Jalalabad abzufahren;
- den grundlegenden physischen Spawn nachzuweisen;
- die vorhandenen sieben Stressroutenanker grundsätzlich funktionsfähig zu machen;
- die vollständige Ankunft in Jalalabad nachzuweisen.

## Nicht Bestandteil von TM01B.1

- Persistenz über Missions- oder Serverneustart;
- Snapshot, Backup oder Transaktionsjournal;
- Cargo und Warehouses;
- Feindkontakte und Hinterhalte;
- automatische Interest-, Sichtlinien- oder Sensorlogik;
- automatische Routenneuberechnung;
- Teleport-, Recovery- oder Unstuck-Logik;
- mehrere Konvois oder Serials.

## Testdisziplin

Ein Bundle-Build oder eine statische Lua-Prüfung belegt nur, dass der Test technisch vorbereitet ist.

Ein PASS erfordert:

- die getestete `.miz`-Datei;
- DCS-Lognachweise;
- beide Runtime-Gruppennamen;
- Nachweis der erhaltenen Fahrzeugslots;
- Nachweis, dass zwischen zwei physischen Generationen keine Restgruppe existierte;
- eine Ergebnisdatei unter `results/`.