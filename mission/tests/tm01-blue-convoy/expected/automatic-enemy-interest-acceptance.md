# TM01C – Abnahme automatische RED-Gegnerrelevanz

Status: DCS-Laufzeitnachweis erforderlich

## Voraussetzungen

- Bundle aus dem aktuellen Branch neu gebaut;
- Startup-Log enthält `TM01C-automatic-player-and-enemy-interest-6`;
- BLUE-Spieler befindet sich für den Haupttest horizontal mehr als 750 m vom Konvoi entfernt;
- RED-Ground-Group heißt exakt `TEST_TM01E_RED_INFANTRY_01`;
- die Gruppe enthält mindestens eine lebende Unit;
- der Konvoi wurde gestartet und fährt;
- keine zusätzlichen RED-Gruppen sind in `enemyInterest.groupNames` eingetragen.

Empfohlene Beobachterposition:

```text
800–900 m horizontal vom Konvoi
```

Damit ist der BLUE-Spieler außerhalb seiner Pack-Grenze, kann das Entpacken aber noch visuell beobachten.

## Mission-Editor-Aufbau

Eine RED-Infanteriegruppe neben der Route platzieren:

```text
Group name: TEST_TM01E_RED_INFANTRY_01
```

Für einen gut kontrollierbaren ersten Lauf:

- vier bis sechs Infanteristen;
- ungefähr 50–100 m seitlich der Straße;
- keine zweite gleichnamige Gruppe;
- keine späte Aktivierung im ersten Durchlauf;
- die Gruppe muss beim Missionsstart existieren.

Der erste Lauf darf mit `WEAPON HOLD` erfolgen, um ausschließlich die Relevanzumschaltung zu prüfen. Ein zweiter Lauf kann mit aktivem Feuer durchgeführt werden. ROE-, Alarm- und Disperse-Einstellungen des BLUE-Konvois sind noch nicht Gegenstand dieses Tests.

## Test A – Initialisierung

Erwartet:

```text
representation_interest_monitor_initialized
enemy_interest_monitor_initialized
enemyInterestEnabled=true
configuredEnemyGroupCount=1
```

Nach `Show status` muss bei aufgelöster Gruppe gelten:

```text
resolvedEnemyGroupCount=1
aliveEnemyUnitCount>=1
```

Fehlt die Gruppe oder ist der Name falsch, bleibt `resolvedEnemyGroupCount=0`.

## Test B – Enemy-Unpack

1. BLUE-Spieler mehr als 750 m vom Konvoi entfernt halten.
2. Konvoi zunächst automatisch einpacken lassen.
3. Proxy auf die RED-Gruppe zufahren lassen.
4. Bei höchstens 750 m Entfernung zur nächsten lebenden RED-Unit beobachten.

Erwartet:

```text
enemy_relevance_band_changed
enemy_relevance_entered
enemyInterestBand=INSIDE_UNPACK
automatic_unpack_requested
triggeredByEnemy=true
convoy_unpack_started
convoy_unpacked
convoy_route_activation_confirmed
representationState=EXPANDED
halted=false
```

Nicht erwartet:

```text
triggeredByEnemy=false
convoy_pack_started
```

## Test C – Enemy-Hysterese

Während die nächste lebende RED-Unit 750–1000 m entfernt ist:

```text
enemyInterestBand=HYSTERESIS
```

Die bestehende Repräsentation muss erhalten bleiben. Es darf kein Pack-/Unpack-Flattern auftreten.

## Test D – Kein Packen im Feindbereich

Solange mindestens eine lebende konfigurierte RED-Unit höchstens 1000 m entfernt ist:

- kein `automatic_pack_timer_started`;
- kein `automatic_pack_requested`;
- kein `convoy_packed`.

Das gilt auch dann, wenn kein BLUE-Spieler relevant ist.

## Test E – Auto-Pack nach Verlassen des Feindbereichs

1. BLUE-Spieler weiterhin mehr als 750 m entfernt halten.
2. Konvoi an der RED-Gruppe vorbeifahren lassen oder alle RED-Units zerstören.
3. Warten, bis keine lebende konfigurierte RED-Unit mehr innerhalb 1000 m liegt.
4. 30 Sekunden kontinuierlich beide Relevanzquellen außerhalb halten.

Erwartet:

```text
enemy_relevance_exited
enemyInterestBand=OUTSIDE
playerInterestBand=OUTSIDE
automatic_pack_timer_started
...
automatic_pack_requested
convoy_pack_started
convoy_packed
representationState=COLLAPSED_PROXY
```

## Test F – Timerabbruch durch Gegner

1. Beide Quellen außerhalb halten und `automatic_pack_timer_started` abwarten.
2. Vor Ablauf der 30 Sekunden eine lebende konfigurierte RED-Unit wieder auf höchstens 1000 m bringen.

Erwartet:

```text
automatic_pack_timer_cancelled
reason=player or enemy remains inside pack boundary
```

Nicht erwartet:

```text
automatic_pack_requested
convoy_packed
```

## Test G – Zerstörte Gegner werden ignoriert

Nach Zerstörung aller Units der Testgruppe muss gelten:

```text
aliveEnemyUnitCount=0
enemyInterestBand=OUTSIDE
```

Wracks dürfen den Konvoi nicht dauerhaft expandiert halten.

## Test H – Kombinierte Priorität

Folgende Matrix muss gelten:

| Player-Band | Enemy-Band | COLLAPSED_PROXY | EXPANDED |
|---|---|---|---|
| INSIDE_UNPACK | beliebig | Unpack | halten |
| beliebig | INSIDE_UNPACK | Unpack | halten |
| HYSTERESIS | OUTSIDE | halten | halten |
| OUTSIDE | HYSTERESIS | halten | halten |
| OUTSIDE | OUTSIDE | halten | Pack-Timer starten |

## Fehlerkriterien

```text
representation_interest_monitor_initialization_failed
representation_interest_monitor_failed
proxy_controller_initialization_failed
convoy_route_activation_timeout
convoy_route_activation_failed
convoy_pack_failed
convoy_unpack_failed_proxy_restored
halted=true
movementState=FAILED
```

## Zu sammelnde Logereignisse

```text
startup
configuration_valid
bootstrap_outcome
representation_interest_monitor_initialized
player_interest_monitor_initialized
enemy_interest_monitor_initialized
player_relevance_band_changed
enemy_relevance_band_changed
enemy_relevance_entered
enemy_relevance_exited
automatic_pack_timer_started
automatic_pack_timer_cancelled
automatic_pack_requested
automatic_unpack_requested
convoy_pack_started
convoy_packed
convoy_unpack_started
convoy_unpacked
convoy_route_activation_confirmed
representation_interest_status
convoy_proxy_status
```

## Abgrenzung

Ein bestandener Lauf beweist nur die deterministische RED-Gegnernähe. Er beweist noch nicht:

- Sichtkontakt;
- DCS-Sensorerkennung;
- Waffenreichweite;
- tatsächlichen Feuerkontakt;
- taktisch korrekte ROE;
- Alarmzustand;
- Verhalten unter Beschuss;
- Produktionsradien.