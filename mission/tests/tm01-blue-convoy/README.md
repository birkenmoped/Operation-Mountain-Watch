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

## Aktueller Status

```text
TM01A: akzeptierte physische Baseline
TM01B: NICHT BESTANDEN / NICHT ABNAHMEFÄHIG
```

Der aktuelle Stand `TM01B-controlled-caching-5.1` ist ein fehlerhafter Zwischenstand. Version 4 bewies wesentliche Teile der Zustandsmaschine, scheiterte aber an der physischen Spawnrobustheit. Version 5 und 5.1 stoppten bereits während der Routenplanung und erreichten keinen vollständigen DCS-Lauf.

Die vollständige Chronologie, alle Diskussionsergebnisse, verworfenen Annahmen, Vereinbarungen und die priorisierte Fortsetzung stehen in:

```text
notes/2026-07-14-tm01b-handoff.md
```

Kein Teil dieses README darf als Nachweis eines erfolgreichen Version-5-DCS-Laufs verstanden werden.

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

Aktueller, nicht akzeptierter Zwischenstand:

```text
TM01B-controlled-caching-5.1
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

`Start convoy` soll den gesamten automatischen Ablauf starten. Es gibt keine regulären F10-Befehle zum Materialisieren, Dematerialisieren oder Starten einer physischen Teilroute.

## Verbindliches Zielverhalten

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
→ automatische Dematerialisierung oder unmittelbare Terminal-Ankunft
→ ZONE_TM01_TARGET_JALALABAD
```

Während einer virtuellen Phase existiert keine physische DCS-Gruppe.

## Reveal-Fenster im Mission Editor

Das vereinbarte Zielmodell verwendet genau eine kreisförmige Triggerzone pro Fenster:

```text
ZONE_TM01_REVEAL_01
ZONE_TM01_REVEAL_02
```

Der Mittelpunkt und der Radius der jeweiligen Mission-Editor-Zone definieren das vollständige Sichtfenster:

```text
innerhalb des Kreises  = physisch sichtbar
außerhalb des Kreises  = virtuell
```

Separate Entry- und Exit-Zonen werden nicht mehr verwendet. Der Controller soll die Eintritts- und Austrittspunkte automatisch aus dem Schnitt des geordneten Straßenpfades mit dem Kreis bestimmen. Die Fahrtrichtung ist für die Sichtbarkeitsentscheidung irrelevant.

Jeder Kreis soll den globalen Straßenpfad genau einmal in einem zusammenhängenden Abschnitt schneiden. Kein Schnitt oder mehrere getrennte Schnittabschnitte sollen den Test mit `convoy_route_plan_failed` stoppen.

## Globaler Straßenpfad

Start, sieben Routenanker und Ziel werden auf die nächstgelegene Straße projiziert. Zwischen den projizierten Punkten berechnet MOOSE den DCS-Straßenpfad. Dieser Pfad ist die gemeinsame Grundlage für:

- virtuelle Position;
- virtuelle ETA;
- Moving Marker;
- Reveal-Kreis-Schnittpunkte;
- Fahrzeugpositionen beim Spawn;
- lokale Fahrzeug-Headings;
- physische Teilroute.

Aktueller Zwischenstand 5.1:

```text
routeSampleMeters                  = 5
physicalWaypointSpacingMeters      = 100
maximumRoadSnapMeters              = 1500
roadPositionToleranceMeters        = 25
```

Die 25-Meter-Toleranz ist kein Nachweis dafür, dass ein Fahrzeug tatsächlich auf der Straße steht. Die aktuelle Implementierung prüft die nächstgelegene Straße, verwendet aber noch nicht zuverlässig deren finale Koordinate als Spawnposition.

## Virtueller Moving Marker

Während `VIRTUAL_MOVING` soll BLUE einen beweglichen Kartenmarker an der berechneten Position auf dem Straßenpfad sehen. Der Marker enthält:

```text
naechstes Reveal-Fenster oder Ziel
ETA
Fortschritt der aktuellen virtuellen Etappe
```

Aktualisierung:

```text
virtualMarkerUpdateSeconds = 5
```

Während der physischen Darstellung wird der virtuelle Marker entfernt.

Der aktuelle Code setzt zusätzlich nur einen Textmarker am Mittelpunkt jedes Reveal-Fensters. Dieser Textmarker zeigt keine echte Kreisgrenze. Eine echte F10-Kreisvisualisierung ist noch offen.

## Straßenkonformer Spawn

Der Zielentwurf verwendet nicht nur ein starr verschobenes Template. Für jeden Template-Slot sollen berechnet werden:

- finale, tatsächlich auf die Straße projizierte Position;
- definierter Abstand zum vorausfahrenden Fahrzeug;
- individuelles Heading aus dem lokalen Straßenverlauf;
- Oberflächen- und Wasserprüfung;
- Belegungs- und Kollisionsprüfung soweit zuverlässig verfügbar.

Aktueller Zwischenstand 5.1:

```text
vehicleSpacingMeters      = 15
spawnInteriorMarginMeters = 25
```

Die aktuelle Version erfüllt dieses Ziel noch nicht vollständig:

- `nearestRoad` wird geprüft, aber nicht zuverlässig als finale Spawnposition verwendet;
- Wasser wird nicht explizit ausgeschlossen;
- es gibt keine Kandidatensuche innerhalb des Fensters;
- es gibt keinen Bewegungs-Watchdog;
- ein erfolgreicher DCS-Straßenspawn wurde nicht nachgewiesen.

Kann keine vollständige sichere Aufstellung ermittelt werden, darf kein unsicherer Notspawn erfolgen.

## MOOSE-Fähigkeiten und Laufzeitstrategie

MOOSE stellt die benötigten Bausteine bereit:

```text
GetClosestPointToRoad()
GetPathOnRoad()
InitSetUnitAbsolutePositions()
WaypointGround(..., "On Road")
```

MOOSE garantiert jedoch nicht mit einem einzelnen Aufruf eine vollständig kollisionsfreie Straßengruppe.

Vereinbarte Laufzeitstrategie:

- bekannte Reveal-Fenster einmal beim Missionsstart planen und cachen;
- dynamische unbekannte Spawns nur beim Aktivierungsereignis planen;
- eine lokale Pfadberechnung pro Kandidat, nicht pro Fahrzeug;
- harte Obergrenze der Kandidaten;
- keine fortlaufende Spawnplatzsuche pro Simulationstick;
- bei mehreren gleichzeitigen Anforderungen Planung über Scheduler-Zyklen verteilen.

## Dematerialisierung

Nach der Materialisierung soll der Konvoi physisch bleiben, solange mindestens ein überlebendes Fahrzeug innerhalb des Reveal-Kreises liegt. Sobald der Kreis zuvor belegt war und kein überlebendes Fahrzeug mehr darin liegt, beginnt die automatische Dematerialisierung.

Vor dem Destroy-Aufruf werden die aktuell lebenden Fahrzeugslots in den `CampaignState` übernommen. Erst wenn `Group.getByName(runtimeName):isExist()` die Abwesenheit der Laufzeitgruppe bestätigt, wechselt die Entity wieder auf `VIRTUAL_MOVING` oder bei einem terminalen letzten Fenster direkt auf `ARRIVED`.

Jedes Reveal-Fenster wird pro Missionslauf höchstens einmal ausgeführt.

## Dokumentierte Versuchsergebnisse

### Version 4

- Mock-Lauf bestand zwei Materialisierungs-/Dematerialisierungszyklen.
- DCS-Fenster 1 funktionierte gut.
- DCS-Fenster 2 erzeugte Generation 2, aber die Gruppe bewegte sich nicht.
- Sichtbeobachtung: zwei hintere Fahrzeuge standen im Wasser beziehungsweise Fluss.
- Kein automatischer Fehler wurde ausgelöst; die Gruppe blieb in `PHYSICAL_MOVING`.

### Version 5

- Bootstrap `READY`.
- Planung stoppte vor dem Start mit:

```text
planned vehicle position is not on road: ZONE_TM01_REVEAL_01
```

- Kein physischer Spawn und kein vollständiger Marker-Test.

### Version 5.1

- Bootstrap `READY`.
- Planung stoppte vor dem Start mit:

```text
reveal window exit is too close to route target: ZONE_TM01_REVEAL_02
```

- Die anschließende Analyse zeigte zusätzliche Systemfehler: fehlende Terminal-Window-Logik, nicht verwendete finale Straßenprojektion, keine Wasserprüfung, kein Bewegungs-Watchdog und keine echte Kreisvisualisierung.

## Verbindlicher Testvertrag

```text
expected/caching-acceptance.md
```

Der Vertrag beschreibt das Zielverhalten. Sein Status ist derzeit **nicht bestanden**.

## Nicht Bestandteil von TM01B

- Persistenz über Missions- oder Serverneustart;
- Cargo und Warehouses;
- Feindkontakte und Hinterhalte;
- automatische Spielerentfernungs-, Sichtlinien- oder Sensorlogik;
- mehrere gleichzeitige Konvois.

Automatische Recovery und lokale Routenneuberechnung waren ursprünglich ausgeschlossen. Nach dem Version-4-Stillstand ist jedoch mindestens ein begrenzter Spawn-Recovery-Mechanismus mit Bewegungs-Watchdog für einen belastbaren Entwurf erforderlich. Der genaue Scope wird im Handoff-Dokument festgehalten.
