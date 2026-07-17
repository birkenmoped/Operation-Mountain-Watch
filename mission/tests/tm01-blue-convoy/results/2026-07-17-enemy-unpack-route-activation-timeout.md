# TM01C – Enemy-Unpack route activation timeout

Datum: 17. Juli 2026  
DCS: 2.9.27.25340 Open Beta MT  
Getestete Konfiguration: `TM01C-automatic-player-and-enemy-interest-7`  
Ergebnis: FAIL – Ursache identifiziert und in Version 8 korrigiert  
Regression: **PASS**, siehe `2026-07-17-tm01c-enemy-proximity-regression-pass.md`

## 1. Beobachtung

Der Konvoi war zunächst erfolgreich als Proxy gepackt. Beim Annähern an den ersten konfigurierten RED-Infanterieposten wurde die Gegnerrelevanz korrekt erkannt und das automatische Entpacken ausgelöst.

Relevante Sequenz:

```text
enemyInterestBand=INSIDE_UNPACK
nearestEnemyDistanceMeters=746.0239
automatic_unpack_requested
triggeredByEnemy=true
triggeredByPlayer=false
convoy_unpack_started
convoy_unpacked
```

Das Enemy-Unpack selbst funktionierte somit bestimmungsgemäß.

## 2. Tatsächliche Fehlerursache

Nach dem Spawn der expandierten Gruppe begann die bestehende Routenaktivierungsprüfung. Sie verlangte innerhalb von 30 Sekunden mindestens 2 m physische Bewegung des überwachten Führungsfahrzeugs.

Gemessener Endstand:

```text
routeAssignmentAttempts=6
forwardMeters=1.8167622801102
displacementMeters=1.8379913797807
maximumDisplacementMeters=1.8380650399055
requiredMovementMeters=2
liveCount=6
```

Die Gruppe blieb lebend und erhielt die Route mehrfach, bewegte sich während des unmittelbaren Feuerkontakts aber nur ungefähr 1,84 m. Der Guard erzeugte deshalb:

```text
convoy_route_activation_timeout
halted=true
movementState=FAILED
representationState=EXPANDED
```

Danach wurde der Controller-Tick nicht mehr fortgesetzt. Folglich konnte die kombinierte Spieler-/Gegnerrelevanz weder den Tod des Infanteristen neu erfassen noch einen Pack-Timer starten.

## 3. Warum der spätere Gegnerstatus irreführend war

Der später über `Show status` ausgegebene Stand enthielt weiterhin:

```text
aliveEnemyUnitCount=10
enemyInterestBand=INSIDE_UNPACK
nearestEnemyDistanceMeters=746.0239
```

Diese Werte waren kein neuer Scan. Sie waren der letzte gespeicherte Beobachtungsstand vor dem Controller-Halt. Da der gewrappte Controller-Tick bei `halted=true` nicht mehr in den Relevanzservice gelangte, blieb die Anzeige eingefroren.

Die primäre Ursache war deshalb nicht eine fehlerhafte Totenerkennung, sondern der vorherige Routenaktivierungs-Halt.

## 4. Konstruktionsfehler

Die bisherige Regel setzte voraus:

```text
Routenzuweisung akzeptiert
UND
physische Bewegung >= 2 m
→ Aktivierung bestätigt
```

Diese Regel ist für einen normalen Spawn sinnvoll, aber nicht für ein gezielt durch Gegnernähe ausgelöstes Entpacken. In diesem Kontext kann DCS Ground AI die Route annehmen und trotzdem taktisch stehen bleiben, um einen unmittelbar nahen Gegner zu bekämpfen.

Physische Bewegung ist dort kein zuverlässiger Nachweis für die Annahme der Route.

## 5. Korrektur in Version 8

Neue Konfiguration:

```text
TM01C-automatic-player-and-enemy-interest-8
```

Neue explizite Einstellung:

```lua
allowStationaryEnemyTriggeredUnpack = true
```

Neue Policy:

```text
Enemy-triggered unpack
+ Routenzuweisung erfolgreich
+ Gruppe lebt
+ Schadenszustand angewendet und bestätigt
→ Routenaktivierung darf ohne Bewegungsnachweis bestätigt werden
```

Die Ausnahme gilt ausschließlich, wenn das aktuelle Unpack durch `automaticEnemyInterest=true` ausgelöst wurde. Für Initialspawn, manuelles Unpack, ausschließlich spielerausgelöstes Unpack und alle anderen Spawnkontexte bleibt der 2-m-Bewegungsnachweis bestehen.

Implementierung:

```text
mission/tests/tm01-blue-convoy/src/convoy_proxy_controller/
03e-enemy-contact-activation-policy.lua
```

Erwartetes zusätzliches Ereignis:

```text
convoy_route_activation_policy_adjusted
confirmationPolicy=ROUTE_ASSIGNED_DAMAGE_VERIFIED_ENEMY_RELEVANCE
movementRequired=false
```

Anschließend muss weiterhin folgen:

```text
convoy_route_activation_confirmed
movementRequired=false
halted=false
movementState=EN_ROUTE
```

## 6. Regressionsergebnis Version 8

Der Wiederholungslauf bestätigte:

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

Die sieben Enemy-Unpacks enthielten jeweils:

```text
triggeredByEnemy=true
triggeredByPlayer=false
```

Der BLUE-Spieler befand sich dabei ungefähr 3,08–15,79 km vom Konvoi entfernt. Damit wurde der korrigierte Pfad isoliert nachgewiesen.

Vollständiger Bericht:

```text
mission/tests/tm01-blue-convoy/results/
2026-07-17-tm01c-enemy-proximity-regression-pass.md
```

## 7. Weiter offen

Die Korrektur ist für den Enemy-Proximity-Pfad bestanden. Noch offen bleiben:

1. Player-only-Unpack und Player-only-Pack innerhalb Version 8.
2. Player-Hysterese und Spieler-Timerabbruch innerhalb Version 8.
3. Kombinierte Prioritätsfälle mit gleichzeitig relevantem Spieler und Gegner.
4. Mehrspieler- und Höhentests.
5. Produktionsradien sowie LOS-/Sensor-/Hostile-Intent-Semantik.

## 8. Nicht geändert

- Gegner-Unpack-Radius: 750 m
- Gegner-Pack-Grenze: 1000 m
- Spieler-Unpack-Radius: 500 m
- Spieler-Pack-Grenze: 750 m
- Pack-Verzögerung: 30 s
- Geschwindigkeit: 30 km/h
- Spawnabstand: 15 m
- Formation: `ON_ROAD`
- kein LOS-, Sensor- oder Hostile-Intent-Modell
- kein Teleport, kein permanentes Rerouting, kein Unstuck-System
