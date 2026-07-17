# TM01C – Enemy-Unpack route activation timeout

Datum: 17. Juli 2026  
DCS: 2.9.27.25340 Open Beta MT  
Getestete Konfiguration: `TM01C-automatic-player-and-enemy-interest-7`  
Ergebnis: FAIL – Ursache identifiziert und korrigiert; Wiederholung mit Version 8 erforderlich

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

Diese Werte waren kein neuer Scan. Sie waren der letzte gespeicherte Beobachtungsstand vor dem Controller-Halt. Da der gewrappte Controller-Tick bei `halted=true` nicht mehr in den Relevanzservice gelangt, blieb die Anzeige eingefroren.

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

## 6. Wiederholungskriterien

Der nächste DCS-Lauf muss beweisen:

1. Enemy-Proximity löst das Entpacken aus.
2. Ein im Feuerkampf stehender Konvoi erzeugt keinen `convoy_route_activation_timeout`.
3. Nach Tod oder Verlassen des letzten relevanten Gegners wechselt `enemyInterestBand` auf `OUTSIDE`.
4. Bei ebenfalls außerhalb liegendem Spieler startet der gemeinsame 30-s-Pack-Timer.
5. Der Konvoi wird anschließend erfolgreich gepackt.
6. Spätere Infanterieposten können weitere Pack-/Unpack-Zyklen auslösen.

## 7. Nicht geändert

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
