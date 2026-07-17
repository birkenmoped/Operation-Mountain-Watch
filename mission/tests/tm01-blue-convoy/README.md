# TM01 – Blauer Straßenkonvoi Bagram–Jalalabad

## Ziel

TM01 untersucht eine stabil identifizierte blaue Konvoientität zwischen Bagram und Jalalabad.

```text
TM01A
- kontrollierter physischer Spawn
- kontrollierte vollständige Straßenroute

TM01B
- historisches Reveal-Window-/Caching-Experiment
- nicht bestanden und nicht abnahmefähig

TM01C
- ein physischer strategischer Konvoi mit zwei Repräsentationen
- EXPANDED: alle überlebenden Fahrzeuge physisch
- COLLAPSED_PROXY: nur das aktuelle Führungsfahrzeug physisch
- Stable Slots, Survivor- und Schadenszustand im CampaignState
- manuelles und automatisches Pack/Unpack
- deterministische BLUE-Spieler- und RED-Gegnernähe als Relevanzquellen
```

Cargo, Warehouses und Persistenz über einen Missions- oder Serverneustart sind noch nicht Bestandteil von TM01C.

## Aktueller Status

```text
TM01A: akzeptierte physische Baseline
TM01B: NICHT BESTANDEN / NICHT ABNAHMEFÄHIG
TM01C manueller Kern: PASS
TM01C automatische BLUE-Spielerrelevanz Version 5: PASS für visuellen Einzelspieler-Nahbereichstest
TM01C automatische RED-Gegnernähe Version 8: PASS für isolierten Enemy-Proximity-Live-Fire-Lauf
TM01C kombinierter Player-/Enemy-Monitor Version 8: PARTIAL PASS
```

Aktuelle Konfiguration:

```text
TM01C-automatic-player-and-enemy-interest-8
```

Aktuelle kombinierte Automatik:

```text
BLUE-Spieler <= 500 m horizontal
ODER
lebende konfigurierte RED-Unit <= 750 m horizontal
→ automatisch entpacken

alle gültigen BLUE-Spieler > 750 m horizontal
UND
alle lebenden konfigurierten RED-Units > 1000 m horizontal
→ 30 Sekunden kontinuierliche gemeinsame Abwesenheit
→ automatisch einpacken

BLUE 500–750 m
RED 750–1000 m
→ Hysterese; bestehende Repräsentation beibehalten
```

### BLUE-Abnahme vom 17. Juli 2026

```text
5/5 automatische Pack-Anforderungen bestätigt
3/3 automatische Unpack-Anforderungen bestätigt
1/1 Pack-Timer korrekt abgebrochen
5/5 Routenaktivierungen bestätigt
0 TM01C-ERROR-Ereignisse
0 halted=true
0 movementState=FAILED
```

Ergebnisbericht:

```text
results/2026-07-17-tm01c-automatic-player-interest-pass.md
```

Dieser Lauf verwendete Version 5. Der BLUE-Pfad muss innerhalb der kombinierten Version-8-Konfiguration noch gezielt regressionsgetestet werden.

### RED-Enemy-Proximity-Abnahme vom 17. Juli 2026

```text
7 gegnerausgelöste automatische Unpacks
7 enemy-spezifische Aktivierungspolicy-Anpassungen
8 bestätigte Routenaktivierungen einschließlich Initialspawn
8 erfolgreiche Packvorgänge
1 Enemy-Hysterese-Timerabbruch
0 TM01C-ERROR-Ereignisse im Version-8-Segment
0 convoy_route_activation_timeout
0 halted=true
0 movementState=FAILED
```

Der BLUE-Spieler lag während aller sieben Enemy-Unpacks deutlich außerhalb der Player-Pack-Grenze. Die Anforderungen enthielten `triggeredByEnemy=true` und `triggeredByPlayer=false`.

Ergebnisbericht:

```text
results/2026-07-17-tm01c-enemy-proximity-regression-pass.md
```

Noch offen:

```text
- Player-only-Regression innerhalb Version 8
- kombinierte Player-/Enemy-Prioritätsfälle
- Mehrspieler-Nähe mit mindestens zwei BLUE-Spielern
- expliziter Höhentest
- operative Produktionsradien
- Sichtlinie, Sensorik und hostile-intent-Semantik
- verbleibende Gesamtregressionen vor Merge-Freigabe
```

## Testobjekt

```text
Entity-ID: TEST.TM01.CONVOY.001
Route-ID:  ROUTE_TM01_BAGRAM_JALALABAD
Template:  TPL_TEST_BLUE_CONVOY_STANDARD_01
Fahrzeuge: 6
```

DCS-Gruppennamen sind flüchtige Laufzeitdaten. `CampaignState` bleibt die autoritative Quelle für die strategische Entität.

## Route

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

Die Route wird einmal aus Start, sieben Ankern und Ziel als geordneter Straßenpfad kompiliert. Dieser Pfad ist Grundlage für:

- Straßenfortschritt;
- Restwegpunkte;
- Fahrzeugpositionen beim Spawn und Unpack;
- lokale Fahrzeug-Headings;
- Proxy- und Lead-Projektion;
- Zielüberwachung.

## Aktive Marschparameter

```text
roadOnly:                       true
speedKph:                       30
formation:                      ON_ROAD
routeSampleMeters:              10
maximumRoadSnapMeters:          1500
roadPositionToleranceMeters:    30
vehicleSpacingMeters:           15
minimumVehicleSeparationMeters: 8
```

`vehicleSpacingMeters` beschreibt den Spawn-/Unpack-Abstand. Die spätere DCS-Option `Formation Interval` ist ein getrennter Mechanismus und noch nicht Teil dieses Tests.

## Repräsentationsmodell

### EXPANDED

- alle überlebenden Stable Slots besitzen physische Fahrzeuge;
- Verluste und Teilschäden werden laufend in den CampaignState übernommen;
- das vorderste überlebende Fahrzeug ist die aktuelle Lead-Rolle.

### COLLAPSED_PROXY

- genau das aktuelle Führungsfahrzeug bleibt physisch;
- alle anderen Survivor bleiben als Domainzustand gespeichert;
- der Proxy fährt weiterhin dieselbe Reststrecke;
- das Proxyfahrzeug ist keine andere strategische Entität.

## Pack

```text
EXPANDED
→ lebende Stable Slots erfassen
→ aktuelles Lead bestimmen
→ reale Leadposition auf Route projizieren
→ Restweg erneut zuweisen
→ alle anderen physischen Survivor entfernen
→ Entfernung nativ bestätigen
→ COLLAPSED_PROXY
```

## Unpack

```text
COLLAPSED_PROXY
→ reale Proxyposition auf globale Route projizieren
→ sichere vollständige Aufstellung hinter dem Lead suchen
→ für jeden Survivor eigene Straßenposition und eigenes Heading berechnen
→ Wasser und unzulässige Abstände ausschließen
→ alte Proxygruppe entfernen und Entfernung bestätigen
→ Survivor-Gruppe neu erzeugen
→ gespeicherte Schäden wiederherstellen und verifizieren
→ Routenaktivierung nach kontextabhängiger Policy bestätigen
→ EXPANDED / EN_ROUTE
```

Normalerweise ist ein physischer Bewegungsnachweis von 2 m erforderlich. Bei einem ausschließlich gegnerausgelösten Unpack darf DCS Ground AI taktisch stehen bleiben. In diesem Kontext genügen erfolgreiche Routenzuweisung, lebende Runtime-Gruppe und bestätigte Schadenswiederherstellung.

Zerstörte Stable Slots werden nicht wiederhergestellt.

## Spielerrelevanz

Quelle:

```lua
coalition.getPlayers(coalition.side.BLUE)
```

Gültig sind nur lebende, tatsächlich besetzte BLUE-Spielerunits mit gültiger Position. Zuschauer, normale AI und unbesetzte Client-Slots zählen nicht. Bei mehreren Spielern zählt die kleinste horizontale Distanz.

```text
Unpack: <= 500 m
Hysterese: 500–750 m
Pack-freigebend: > 750 m
```

## Gegnerrelevanz

Quelle:

```lua
Group.getByName(configuredGroupName)
group:getUnits()
```

Berücksichtigt werden nur lebende Units in den ausdrücklich konfigurierten Gruppen:

```text
TEST_TM01E_RED_INFANTRY_01
...
TEST_TM01E_RED_INFANTRY_10
```

```text
Unpack: <= 750 m
Hysterese: 750–1000 m
Pack-freigebend: > 1000 m
```

Das ist deterministische horizontale Gegnernähe. Es ist noch keine Sichtlinien-, Sensor-, Waffenreichweiten- oder Hostile-Intent-Auswertung.

## Gemeinsamer Repräsentationsmonitor

Der `representation_interest_monitor.lua` umschließt den bestehenden Konvoi-Tick. Es gibt keinen zusätzlichen Hochfrequenz-Scheduler.

Keine neue automatische Aktion während:

```text
PACKING
UNPACKING
ACTIVATING_ROUTE
```

Der Pack-Timer darf nur laufen, wenn **alle aktivierten Relevanzquellen** außerhalb ihrer jeweiligen Pack-Grenze liegen.

## F10-Menü

```text
OMW Tests
└── TM01C
    ├── Start convoy
    ├── Pack convoy
    ├── Unpack convoy
    ├── Show status
    └── Validate configuration
```

Die manuellen Befehle bleiben Diagnosewerkzeuge. Sie deaktivieren die Automatik nicht dauerhaft.

## Build

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\build-tm01c-bundle.ps1
```

Mission-Editor-Ladereihenfolge:

```text
1. DO SCRIPT FILE: vendor/moose/Moose.lua
2. DO SCRIPT FILE: mission/tests/tm01-blue-convoy/dist/TM01C.lua
```

## Verbindliche Dokumente

```text
notes/2026-07-16-tm01c-dcs-findings.md
notes/2026-07-16-convoy-doctrine-settings-capabilities-and-decisions.md
notes/2026-07-17-automatic-player-interest-implementation.md
notes/2026-07-17-automatic-enemy-interest-implementation.md
notes/2026-07-17-ten-red-picket-layout.md
expected/proxy-pack-unpack-acceptance.md
expected/automatic-player-interest-acceptance.md
expected/automatic-enemy-interest-acceptance.md
results/2026-07-16-tm01c-manual-cycle-heading-pass.md
results/2026-07-17-tm01c-automatic-player-interest-pass.md
results/2026-07-17-enemy-unpack-route-activation-timeout.md
results/2026-07-17-tm01c-enemy-proximity-regression-pass.md
```

## Scope-Schutz

Nicht automatisch ergänzen:

- Recovery oder Unstuck;
- Teleport;
- permanentes Re-Routing;
- automatische Straßensuche pro Fahrzeug und Tick;
- nicht konfigurierte RED-Gruppen als implizite Relevanzquelle;
- Sichtlinie oder Sensorik ohne eigenen Entwurf;
- Persistenz über Missionsneustart ohne Persistenzvertrag.

PR #8 bleibt Draft. Es besteht keine Merge-Freigabe.
