# TM01C – Abnahme automatische RED-Gegnerrelevanz

Status: **Enemy-Proximity-Regression Version 8 bestanden; kombinierter Player-/Enemy-Monitor nur teilweise abgenommen**

## DCS-Ergebnis vom 17. Juli 2026

Ergebnisbericht:

```text
../results/2026-07-17-tm01c-enemy-proximity-regression-pass.md
```

Nachgewiesen:

```text
7 gegnerausgelöste automatische Unpacks
7 enemy-spezifische Aktivierungspolicy-Anpassungen
8 bestätigte Routenaktivierungen einschließlich Initialspawn
8 erfolgreiche Packvorgänge
1 durch Enemy-Hysterese ausgelöster Pack-Timer-Abbruch
0 TM01C-ERROR-Ereignisse im Version-8-Segment
0 convoy_route_activation_timeout
0 halted=true
0 movementState=FAILED
```

Der BLUE-Spieler blieb bei allen gegnerausgelösten Unpacks außerhalb der Player-Pack-Grenze. Alle sieben Anforderungen enthielten `triggeredByEnemy=true` und `triggeredByPlayer=false`.

Damit sind die Tests A bis H für den isolierten Enemy-Proximity-Pfad erfüllt. Test I wurde für einzelne zerstörte beziehungsweise nicht mehr relevante Posten praktisch bestätigt; die vollständige Auslöschung aller zehn Posten war kein eigenes Abnahmekriterium dieses Laufs. Test J, der kombinierte Player-/Enemy-Prioritätstest, bleibt offen.

## Voraussetzungen

- Bundle aus dem aktuellen Branch neu gebaut;
- Startup-Log enthält `TM01C-automatic-player-and-enemy-interest-8`;
- BLUE-Spieler befindet sich für den Haupttest horizontal mehr als 750 m vom Konvoi entfernt;
- zehn separate RED-Ein-Mann-Gruppen heißen exakt:

```text
TEST_TM01E_RED_INFANTRY_01
TEST_TM01E_RED_INFANTRY_02
TEST_TM01E_RED_INFANTRY_03
TEST_TM01E_RED_INFANTRY_04
TEST_TM01E_RED_INFANTRY_05
TEST_TM01E_RED_INFANTRY_06
TEST_TM01E_RED_INFANTRY_07
TEST_TM01E_RED_INFANTRY_08
TEST_TM01E_RED_INFANTRY_09
TEST_TM01E_RED_INFANTRY_10
```

- jede Gruppe enthält genau eine lebende Unit;
- keine Gruppe verwendet Late Activation;
- der Konvoi wurde gestartet und fährt;
- keine weiteren RED-Gruppen sind in `enemyInterest.groupNames` eingetragen.

Empfohlene Beobachterposition:

```text
800–900 m horizontal vom Konvoi
```

Damit ist der BLUE-Spieler außerhalb seiner Pack-Grenze, kann das Entpacken aber noch visuell beobachten.

## Mission-Editor-Aufbau

Die zehn Ein-Mann-Gruppen werden entlang der Route platziert. Empfohlener seitlicher Abstand zur Fahrbahn:

```text
30–100 m
```

Für vollständige Pack-/Unpack-Zyklen werden zwischen zwei isolierten Posten ungefähr 2,2–3,0 km Routenabstand empfohlen. Enger gesetzte Posten dürfen bewusst eine zusammenhängende Gegnerrelevanzzone bilden; dann bleibt der Konvoi erwartungsgemäß expandiert.

Der erste kontrollierte Lauf darf mit `WEAPON HOLD` erfolgen. Der Live-Fire-Lauf prüft anschließend ausdrücklich das Verhalten bei gegnerausgelöstem Entpacken und taktischem Stillstand.

## Test A – Initialisierung

Erwartet:

```text
representation_interest_monitor_initialized
enemy_interest_monitor_initialized
enemyInterestEnabled=true
configuredEnemyGroupCount=10
```

Nach `Show status` muss vor Verlusten gelten:

```text
resolvedEnemyGroupCount=10
aliveEnemyUnitCount=10
```

Fehlt eine Gruppe oder ist ein Name falsch, bleibt `resolvedEnemyGroupCount` kleiner als 10.

## Test B – erstes Enemy-Unpack

1. BLUE-Spieler mehr als 750 m vom Konvoi entfernt halten.
2. Konvoi zunächst automatisch einpacken lassen.
3. Proxy auf den ersten RED-Posten zufahren lassen.
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
```

Für das gegnerausgelöste Entpacken muss zusätzlich erscheinen:

```text
convoy_route_activation_policy_adjusted
confirmationPolicy=ROUTE_ASSIGNED_DAMAGE_VERIFIED_ENEMY_RELEVANCE
movementRequired=false
automaticEnemyInterest=true
```

Danach:

```text
convoy_route_activation_confirmed
movementRequired=false
representationState=EXPANDED
movementState=EN_ROUTE
halted=false
```

Nicht erwartet:

```text
convoy_route_activation_timeout
movementState=FAILED
halted=true
```

## Test C – taktischer Stillstand nach Enemy-Unpack

Der Konvoi darf nach dem Entpacken stehen bleiben, um den nahen Gegner zu bekämpfen. Dieser Stillstand ist in Version 8 kein Aktivierungsfehler, solange:

- die Gruppe lebt;
- die Route erfolgreich zugewiesen wurde;
- der gespeicherte Schadenszustand bestätigt wurde.

Der 2-m-Bewegungsnachweis bleibt für Initialspawn, manuelles Unpack und ausschließlich spielerausgelöstes Unpack weiterhin verpflichtend.

## Test D – Enemy-Hysterese

Während die nächste lebende RED-Unit 750–1000 m entfernt ist:

```text
enemyInterestBand=HYSTERESIS
```

Die bestehende Repräsentation muss erhalten bleiben. Es darf kein Pack-/Unpack-Flattern auftreten.

## Test E – kein Packen im Feindbereich

Solange mindestens eine lebende konfigurierte RED-Unit höchstens 1000 m entfernt ist:

- kein `automatic_pack_timer_started`;
- kein `automatic_pack_requested`;
- kein `convoy_packed`.

Das gilt auch dann, wenn kein BLUE-Spieler relevant ist.

## Test F – zerstörter erster Posten und Auto-Pack

1. BLUE-Spieler weiterhin mehr als 750 m entfernt halten.
2. Den ersten RED-Infanteristen zerstören oder den Konvoi mehr als 1000 m von ihm entfernen lassen.
3. Prüfen, dass der Relevanzmonitor weiterläuft.
4. Warten, bis kein lebender konfigurierter Gegner innerhalb 1000 m liegt.
5. Beide Relevanzquellen 30 Sekunden kontinuierlich außerhalb halten.

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
halted=false
movementState=EN_ROUTE
```

Das ist der zentrale Regressionstest für den Fehler aus Version 7.

## Test G – mehrere Posten

Nach erfolgreichem Packen muss der nächste isolierte Posten erneut auslösen:

```text
enemy_relevance_entered
automatic_unpack_requested
triggeredByEnemy=true
convoy_unpack_started
convoy_unpacked
convoy_route_activation_policy_adjusted
convoy_route_activation_confirmed
```

Mindestens drei vollständige Gegnerzyklen sollen beobachtet werden:

```text
COLLAPSED_PROXY
→ EXPANDED
→ Gegnerrelevanz endet
→ 30-s-Timer
→ COLLAPSED_PROXY
```

## Test H – Timerabbruch durch Gegner

1. Beide Quellen außerhalb halten und `automatic_pack_timer_started` abwarten.
2. Vor Ablauf der 30 Sekunden einen lebenden konfigurierten RED-Posten wieder auf höchstens 1000 m bringen.

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

## Test I – zerstörte Gegner werden ignoriert

Nach Zerstörung eines Postens muss sich `aliveEnemyUnitCount` um eins reduzieren. Nach Zerstörung aller zehn Posten:

```text
aliveEnemyUnitCount=0
enemyInterestBand=OUTSIDE
```

Wracks dürfen den Konvoi nicht dauerhaft expandiert halten.

## Test J – kombinierte Priorität

| Player-Band | Enemy-Band | COLLAPSED_PROXY | EXPANDED |
|---|---|---|---|
| INSIDE_UNPACK | beliebig | Unpack | halten |
| beliebig | INSIDE_UNPACK | Unpack | halten |
| HYSTERESIS | OUTSIDE | halten | halten |
| OUTSIDE | HYSTERESIS | halten | halten |
| OUTSIDE | OUTSIDE | halten | Pack-Timer starten |

## Noch offene kombinierte Regressionen

```text
Player-only unpack <= 500 m mit Version 8
Player-only pack nach > 750 m für 30 s
Player-Hysterese 500–750 m
Timerabbruch durch Rückkehr des Spielers
Player relevant, Enemy fällt weg
Enemy relevant, Player fällt weg
Player und Enemy gleichzeitig relevant
Höhenfall bei kleinem horizontalem Abstand
mehrere gleichzeitige BLUE-Spieler
```

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
convoy_route_activation_policy_adjusted
convoy_route_activation_confirmed
representation_interest_status
convoy_proxy_status
```

## Abgrenzung

Ein bestandener Lauf beweist die deterministische RED-Gegnernähe und die Repräsentationssteuerung unter unmittelbarem Feuerkontakt. Er beweist noch nicht:

- Sichtkontakt;
- DCS-Sensorerkennung;
- Waffenreichweite;
- `hostile act` oder `hostile intent`;
- taktisch vollständige ROE;
- Alarmzustand;
- Disperse-Verhalten;
- Produktionsradien.
