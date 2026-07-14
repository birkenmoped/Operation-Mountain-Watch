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

`InMemoryCampaignState` ist in TM01B die einzige autoritative Quelle für die strategische Entität. DCS-Gruppen und MOOSE-Wrapper sind ausschließlich Laufzeitrepräsentationen.

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

## Akzeptierter Stand

Der TM01A-Bootstrap, der kontrollierte physische Spawn und das vollständige Straßenrouting sind bestanden.

Verwendete Route:

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

Konfiguration:

```text
Geschwindigkeit: 30 km/h
Formation:       ON_ROAD → DCS "On Road"
```

Nachgewiesen wurde:

- Bootstrap `READY`;
- genau ein physischer Spawn mit sechs Fahrzeugen;
- Start in `ZONE_TM01_START_BAGRAM`;
- genau eine Routenzuweisung;
- vollständige Ankunft in `ZONE_TM01_TARGET_JALALABAD`;
- Endstatus `ARRIVED`;
- `convoy_route_arrived` exakt einmal;
- keine automatische Routenneuberechnung oder Recovery.

Ergebnisdateien:

```text
results/2026-07-13-tm01a-physical-spawn.md
results/2026-07-13-tm01a-road-routing.md
```

Die gemessene simulierte Fahrzeit betrug ungefähr 7 Stunden 9 Minuten. DCS wählte zwischen den Ankern erhebliche Umwege. Das ist eine dokumentierte Terrain- und Pathfinding-Einschränkung.

# TM01B – kontrolliertes Caching

Missionsdatei:

```text
TM01B-MOOSE-Blue-Convoy-Virtualized.miz
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

Verbindlicher Testvertrag:

```text
expected/caching-acceptance.md
```

## Verbindliches Routenmodell

Die globale Route bleibt identisch zur akzeptierten TM01A-Route:

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

`ZONE_TM01_START_BAGRAM` ist der autoritative Startpunkt. `ZONE_TM01_TARGET_JALALABAD` ist der autoritative Zielpunkt.

Die Reveal-Zonen sind ausschließlich Sichtfenstergrenzen:

```text
ZONE_TM01_REVEAL_01_ENTRY
ZONE_TM01_REVEAL_01_EXIT
ZONE_TM01_REVEAL_02_ENTRY
ZONE_TM01_REVEAL_02_EXIT
```

Reveal-Zonen:

- sind keine Routenwegpunkte;
- ersetzen weder Start- noch Zielpunkt;
- bestimmen keine Spawnkoordinate;
- werden niemals an DCS als Wegpunkte übergeben.

## Segmentindex und Materialisierung

Der `segmentIndex` beschreibt die autoritative Position auf der globalen Route:

```text
0 = ZONE_TM01_START_BAGRAM
1 = ZONE_TM01_ROUTE_01
2 = ZONE_TM01_ROUTE_02
3 = ZONE_TM01_ROUTE_03
4 = ZONE_TM01_ROUTE_04
5 = ZONE_TM01_ROUTE_05
6 = ZONE_TM01_ROUTE_06
7 = ZONE_TM01_ROUTE_07
8 = ZONE_TM01_TARGET_JALALABAD
```

Fensterzuordnung:

```text
REVEAL_01: Entry 0, Exit 2
REVEAL_02: Entry 5, Exit 7
```

Die erste Materialisierung erfolgt bei `ZONE_TM01_START_BAGRAM`. Nach dem kontrollierten virtuellen Fortschritt erfolgt die zweite Materialisierung bei `ZONE_TM01_ROUTE_05`.

Der Controller verwendet dafür:

```text
SPAWN:NewWithAlias(...)
→ InitPositionCoordinate(globalRouteCoordinate)
→ Spawn()
```

`SpawnInZone(revealEntry, ...)` ist für TM01B unzulässig.

## Reststrecken

Jede physische Generation erhält die noch ausstehende Strecke derselben globalen Route.

Erste Generation:

```text
ZONE_TM01_ROUTE_01
→ ZONE_TM01_ROUTE_02
→ ZONE_TM01_ROUTE_03
→ ZONE_TM01_ROUTE_04
→ ZONE_TM01_ROUTE_05
→ ZONE_TM01_ROUTE_06
→ ZONE_TM01_ROUTE_07
→ ZONE_TM01_TARGET_JALALABAD
```

Zweite Generation:

```text
ZONE_TM01_ROUTE_06
→ ZONE_TM01_ROUTE_07
→ ZONE_TM01_TARGET_JALALABAD
```

## Zustandsmodell

```text
NOT_STARTED
→ MATERIALIZING
→ PHYSICAL_READY
→ PHYSICAL_MOVING
→ DEMATERIALIZING
→ VIRTUAL_MOVING
→ MATERIALIZING
→ PHYSICAL_READY
→ PHYSICAL_MOVING
→ ARRIVED
```

Während `VIRTUAL_MOVING` existiert keine DCS-Gruppe. Caching bedeutet nicht, dass eine unsichtbare physische Gruppe weiterfährt.

## Manuelle F10-Befehle

```text
Show status
Validate configuration
Materialize convoy
Start physical route
Dematerialize convoy
Advance virtual convoy
```

Wiederholte oder im aktuellen Zustand unzulässige Befehle werden abgewiesen und protokolliert. Sie dürfen keine zweite physische Gruppe erzeugen.

## Zweiphasige Dematerialisierung

Der Controller übernimmt vor dem Destroy-Aufruf Fahrzeugslots und logischen Fortschritt. Danach bleibt die Entity vorläufig `PHYSICAL / DEMATERIALIZING`, bis die native DCS-Gruppe in einem späteren Simulationsschritt nicht mehr existiert.

```text
1. Fahrzeugslots und Exit-Segment übernehmen
2. Bestätigungsprüfung planen
3. Destroy(false) anfordern
4. Group.getByName(runtimeName):isExist() zeitversetzt prüfen
5. erst nach bestätigter Entfernung auf VIRTUAL_MOVING wechseln
```

Ein stale MOOSE-Wrapper im Destroy-Tick darf keinen permanenten Lock erzeugen. Bei einem Timeout kehrt der Controller in den erneut bedienbaren Zustand `PHYSICAL / IDLE / PHYSICAL_MOVING` zurück.

## Verlust- und Slot-Erhaltung

Vor der Dematerialisierung werden nur lebende Fahrzeugslots in den `CampaignState` übernommen. Bei der nächsten Materialisierung wird das vollständige Template erzeugt; bereits verlorene Slots werden anschließend ohne künstliches Verlustereignis entfernt.

Diese DCS-Laufzeitannahme bleibt bis zum dokumentierten Verlust- und Rekonstruktionstest unbestätigt.

## Mission-Editor-Pflichtobjekte

```text
TPL_TEST_BLUE_CONVOY_STANDARD_01
ZONE_TM01_START_BAGRAM
ZONE_TM01_ROUTE_01
ZONE_TM01_ROUTE_02
ZONE_TM01_ROUTE_03
ZONE_TM01_ROUTE_04
ZONE_TM01_ROUTE_05
ZONE_TM01_ROUTE_06
ZONE_TM01_ROUTE_07
ZONE_TM01_TARGET_JALALABAD
ZONE_TM01_REVEAL_01_ENTRY
ZONE_TM01_REVEAL_01_EXIT
ZONE_TM01_REVEAL_02_ENTRY
ZONE_TM01_REVEAL_02_EXIT
```

Die Namen sind exakte Lookup-Schlüssel. Abkürzungen oder alternative Beschriftungen sind nicht zulässig.

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
- protokollierte Materialisierungsanker und Route-Slices;
- Nachweis der erhaltenen Fahrzeugslots;
- Nachweis, dass zwischen zwei physischen Generationen keine Restgruppe existierte;
- eine Ergebnisdatei unter `results/`.
