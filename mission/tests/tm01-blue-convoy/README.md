# TM01 – Blauer Straßenkonvoi Bagram–Jalalabad

## Ziel

TM01 untersucht eine stabil identifizierte blaue Konvoientität zwischen Bagram
und Jalalabad.

```text
TM01A
- kontrollierter physischer Spawn
- kontrollierte vollständige Straßenroute

TM01B
- flüchtiger CampaignState im Arbeitsspeicher
- virtuelle Bewegung ohne DCS-Gruppe
- automatische Materialisierung in Reveal-Fenstern
- automatische Dematerialisierung nach dem Reveal-Exit
```

Cargo, Warehouses, Feindkräfte und Persistenz über einen Missions- oder
Serverneustart sind nicht Bestandteil von TM01A oder TM01B.

## Testobjekt

```text
Entity-ID: TEST.TM01.CONVOY.001
Route-ID:  ROUTE_TM01_BAGRAM_JALALABAD
Template:  TPL_TEST_BLUE_CONVOY_STANDARD_01
Fahrzeuge: 6
```

DCS-Gruppennamen sind flüchtige Laufzeitdaten. `CampaignState` bleibt die
autoritative Quelle für die strategische Entität.

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

TM01A hat den kontrollierten Spawn, die einmalige Routenzuweisung und die
vollständige Ankunft in Jalalabad nachgewiesen. Die lange DCS-Fahrzeit und
teilweise großen Umwege bleiben dokumentierte Terrain- und
Pathfinding-Einschränkungen.

# TM01B – automatisches Reveal-Window-Caching

## Konfiguration

```text
TM01B-controlled-caching-4
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

`Start convoy` startet den gesamten automatischen Ablauf. Es gibt keine
regulären F10-Befehle zum Materialisieren, Dematerialisieren oder Starten einer
physischen Teilroute.

## Verbindlicher Ablauf

```text
ZONE_TM01_START_BAGRAM
→ virtuelle Bewegung
→ ZONE_TM01_REVEAL_01_ENTRY
→ automatische Materialisierung
→ sichtbare Fahrt durch Reveal-Fenster 1
→ ZONE_TM01_REVEAL_01_EXIT
→ automatische Dematerialisierung
→ virtuelle Bewegung
→ ZONE_TM01_REVEAL_02_ENTRY
→ automatische Materialisierung
→ sichtbare Fahrt durch Reveal-Fenster 2
→ ZONE_TM01_REVEAL_02_EXIT
→ automatische Dematerialisierung
→ virtuelle Bewegung
→ ZONE_TM01_TARGET_JALALABAD
```

Während einer virtuellen Phase existiert keine physische DCS-Gruppe.

## Reveal-Zonen

```text
ZONE_TM01_REVEAL_01_ENTRY
ZONE_TM01_REVEAL_01_EXIT
ZONE_TM01_REVEAL_02_ENTRY
ZONE_TM01_REVEAL_02_EXIT
```

Entry und Exit sind automatische Sichtbarkeitsgrenzen:

- Beim Entry wird eine physische Gruppe am Entry-Zonenmittelpunkt erzeugt.
- Die physische Route verwendet die innerhalb des Fensters liegenden globalen
  Routenanker und endet an der Exit-Zone.
- Nach dem Exit wird die Gruppe entfernt und die Entität bewegt sich virtuell
  weiter.
- Start und Ziel bleiben eigenständige autoritative Routenpunkte.

Fensterzuordnung:

```text
REVEAL_01: Entry-Segment 0, Exit-Segment 2
REVEAL_02: Entry-Segment 5, Exit-Segment 7
```

## Exit als Durchfahrtstor

Die Exit-Zone ist kein Parkplatz. Der Controller speichert für jeden aktuell
überlebenden Fahrzeugslot, ob er die Exit-Zone mindestens einmal betreten hat.

```text
exitPassageMode = EACH_SURVIVING_SLOT_EVER_INSIDE
```

Damit gilt:

- Fahrzeuge dürfen die Zone nacheinander passieren.
- Der gesamte Konvoi muss niemals gleichzeitig im Kreis stehen.
- Ein vor dem Exit zerstörtes Fahrzeug blockiert die Umschaltung nicht.
- Sobald alle noch lebenden Slots das Tor passiert haben, beginnt die
  automatische Dematerialisierung.

Bei 30 km/h und einem 900-ft-Durchmesser bleibt ein Fahrzeug ungefähr 33
Sekunden innerhalb der Zone. Der automatische Poll läuft jede Sekunde.

## Virtuelle Bewegung

Virtuelle Teilstrecken werden zeitbasiert mit der konfigurierten effektiven
Geschwindigkeit berechnet:

```text
effectiveSpeedKph = 23
automationPollSeconds = 1
```

Die virtuelle Position ist strategischer Zustand; sie erzeugt keine unsichtbar
weiterfahrende DCS-Gruppe.

## Verlustübernahme

Vor jeder Dematerialisierung werden die aktuell lebenden Fahrzeugslots in den
`CampaignState` übernommen. Bei der nächsten Materialisierung wird das Template
erzeugt und auf diese erhaltenen Slots reduziert. Verlorene Fahrzeuge bleiben
verloren.

## Native Destroy-Bestätigung

Nach `Destroy(false)` bleibt die Entity vorläufig
`PHYSICAL / DEMATERIALIZING`. Erst wenn
`Group.getByName(runtimeName):isExist()` die Abwesenheit bestätigt, wechselt die
Entity auf `VIRTUAL_MOVING`.

## Teststatus

Vor dem DCS-Lauf wurden durchgeführt:

- Lua-Parsing aller geänderten Quellen und des generierten Bundles;
- vollständiger gemockter Bundle-Bootstrap bis `READY`;
- ein automatischer Lauf durch zwei Reveal-Fenster;
- zwei automatische Materialisierungen;
- zwei automatische Dematerialisierungen;
- Exit-Passage mit nacheinander eintretenden Fahrzeugen, ohne gleichzeitige
  Vollgruppenmitgliedschaft;
- virtuelle Zielankunft mit `convoy_route_arrived` genau einmal.

Diese Prüfungen ersetzen keinen DCS-Lauf. Ein PASS erfordert weiterhin die
getestete `.miz`, DCS-Logs, beide Runtime-Gruppennamen, Verlustübernahme und eine
Ergebnisdatei unter `results/`.

## Verbindlicher Testvertrag

```text
expected/caching-acceptance.md
```

## Nicht Bestandteil von TM01B

- Persistenz über Missions- oder Serverneustart;
- Cargo und Warehouses;
- Feindkontakte und Hinterhalte;
- automatische Spielerentfernungs-, Sichtlinien- oder Sensorlogik;
- automatische Recovery, Teleport oder Routenneuberechnung;
- mehrere gleichzeitige Konvois.
